--[[
    esp_module.lua  |  external ESP module (ScreenGui-based), loaded with loadstring
    scraped
    Plain Lua: NO MV_* macros, NO `continue`, no compound
    assignment, because this file is never obfuscated and never passes through darklua. [USER][INF]

    Returns: function(ctx) -> ESP
      ESP.add(plr)       start ESP (creates the render loop once); was API.ESP
      ESP.refresh()      same as start; the loop covers every player
      ESP.cleanupAll()   clears the entire ESP table: bundles, pools, registries, loop, root
      ESP.state          the ESPState table (debugging)

    ctx (built by the main script):
      ENV, Services, Player, API, HRP     required (API needs getMyUserId, unc)
      guiName      string  ScreenGui name; the brand stays protected in the main script
      track        function(key, handle) -> handle   registers a connection for the exit sweep
      FOVState     table   optional, only .hueOffset is read (rainbow color)
      getStatuses  function(char) -> { {key=, label=}, ... } | nil     optional, game-specific
      getIcon      function(key) -> asset string | nil                 optional, game-specific
      getExtras    function() -> { {model=, label=, color=}, ... } | nil   optional, called every
                   frame: keep it cheap (cache inside it)

    ENV.CONFIG keys read: espEnabled espBoxes espNames espHealth espDistance espTeamColors
      espTransparency espTracers espColor espRainbow espMaxDistance espStatusIcons espStatusText
      espWeaponName
]]

return function(ctx)
    local ENV, Services, Player, API, HRP = ctx.ENV, ctx.Services, ctx.Player, ctx.API, ctx.HRP
    local FOVState = ctx.FOVState
    local ESPFont = Enum.Font.Gotham
    local DEFAULT_EXTRA_COLOR = Color3.fromRGB(255, 130, 0)

    local ESP = {}

    local ESPState = {
        renderLoop = nil,
        root = nil,
        pools = { boxes = {} },
        PlayerRegistry = {},
        ExtraRegistry = {},
    }
    ESP.state = ESPState

    -- ------------------------------------------------------------------
    -- Infrastructure
    -- ------------------------------------------------------------------
    local function parentGui(gui)
        local gethui = gethui or get_hidden_gui
        local protect_gui = (syn and syn.protect_gui) or protect_gui

        if gethui then
            local ok = pcall(function() gui.Parent = gethui() end)
            if ok and gui.Parent then return true end
        end
        if protect_gui then
            local ok = pcall(function()
                protect_gui(gui)
                gui.Parent = Services.CoreGui
            end)
            if ok and gui.Parent then return true end
        end
        pcall(function() gui.Parent = Services.CoreGui end)
        return gui.Parent ~= nil
    end

    local function getRoot()
        if ESPState.root and ESPState.root.Parent then
            return ESPState.root
        end

        local gui = Instance.new("ScreenGui")
        gui.Name = ctx.guiName or "ESP"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 999
        parentGui(gui)

        ESPState.root = gui
        return gui
    end

    local function projectBox(model, out)
        local root = model:FindFirstChild(HRP)
            or model:FindFirstChild("Torso")
        if not root then return nil end

        local pos = root.Position

        local screenMid, midOnScreen = Player.Camera:WorldToViewportPoint(pos)
        if not midOnScreen or screenMid.Z <= 0 then return nil end

        local screenTop, topOnScreen = Player.Camera:WorldToViewportPoint(
            Vector3.new(pos.X, pos.Y + 2.8, pos.Z)
        )
        local screenBot, botOnScreen = Player.Camera:WorldToViewportPoint(
            Vector3.new(pos.X, pos.Y - 2.8, pos.Z)
        )

        if not topOnScreen and not botOnScreen then return nil end

        local sMinY = math.min(screenTop.Y, screenBot.Y)
        local sMaxY = math.max(screenTop.Y, screenBot.Y)
        local h = sMaxY - sMinY
        local w = h * 0.4  -- characters are roughly 40% as wide as tall on screen

        local r = out or {}
        r.x = screenMid.X - w / 2
        r.y = sMinY
        r.w = w
        r.h = h
        return r
    end

    local function resolveColor(plr, override)
        if override then return override end

        if ENV.CONFIG.espRainbow then
            local hue = ((FOVState and FOVState.hueOffset) or 0) % 1
            return Color3.fromHSV(hue, 0.8, 1)
        end

        if ENV.CONFIG.espTeamColors and plr and Player.Local.Team then
            if plr.Team == Player.Local.Team then
                return Color3.fromRGB(80, 180, 255)
            end
        end

        return ENV.CONFIG.espColor or Color3.new(1, 1, 1)
    end

    -- ------------------------------------------------------------------
    -- Bundles (pooled GUI objects for one target)
    -- ------------------------------------------------------------------
    local function makeLabel(parent, size, zindex, yAlign, xAlign)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1, 1, 1)
        l.TextStrokeTransparency = 0
        l.TextStrokeColor3 = Color3.new(0, 0, 0)
        l.Font = ESPFont
        l.TextSize = size
        l.TextXAlignment = xAlign or Enum.TextXAlignment.Center
        l.TextYAlignment = yAlign or Enum.TextYAlignment.Bottom
        l.Visible = false
        l.ZIndex = zindex
        l.Parent = parent
        return l
    end

    local function buildBundle()
        local parent = getRoot()

        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.ZIndex = 2
        box.Parent = parent

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 2
        boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        boxStroke.Parent = box

        local nameLabel = makeLabel(parent, 13, 3)
        local weaponLabel = makeLabel(parent, 11, 3)
        local infoLabel = makeLabel(parent, 11, 3)

        local healthBG = Instance.new("Frame")
        healthBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        healthBG.BackgroundTransparency = 0.25
        healthBG.BorderSizePixel = 0
        healthBG.Visible = false
        healthBG.ZIndex = 2
        healthBG.Parent = parent

        local healthFill = Instance.new("Frame")
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFill.BorderSizePixel = 0
        healthFill.AnchorPoint = Vector2.new(0, 1)
        healthFill.Visible = false
        healthFill.ZIndex = 3
        healthFill.Parent = healthBG

        local statusIcons = Instance.new("Frame")
        statusIcons.BackgroundTransparency = 1
        statusIcons.Size = UDim2.fromOffset(0, 0)
        statusIcons.Visible = false
        statusIcons.ZIndex = 3
        statusIcons.Parent = parent

        -- pre-create 6 icon+text slots
        local iconSlots = {}
        for i = 1, 6 do
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromOffset(16, 16)
            icon.BackgroundTransparency = 1
            icon.ImageColor3 = Color3.new(1, 1, 1)
            icon.ScaleType = Enum.ScaleType.Fit
            icon.Visible = false
            icon.ZIndex = 3
            icon.Parent = statusIcons

            local text = makeLabel(statusIcons, 11, 3, Enum.TextYAlignment.Center, Enum.TextXAlignment.Left)

            iconSlots[i] = { icon = icon, text = text }
        end

        local tracer = Instance.new("Frame")
        tracer.BackgroundColor3 = Color3.new(1, 1, 1)
        tracer.BorderSizePixel = 0
        tracer.AnchorPoint = Vector2.new(0.5, 0)
        tracer.Visible = false
        tracer.ZIndex = 1
        tracer.Parent = parent

        return {
            box = box,
            boxStroke = boxStroke,
            nameLabel = nameLabel,
            weaponLabel = weaponLabel,
            infoLabel = infoLabel,
            healthBG = healthBG,
            healthFill = healthFill,
            statusIcons = statusIcons,
            iconSlots = iconSlots,
            tracer = tracer,

            _lastName = nil,
            _lastWeapon = nil,
            _lastInfo = nil,
        }
    end

    local function acquireBundle()
        local pooled = table.remove(ESPState.pools.boxes)
        if pooled then
            local parent = getRoot()
            pooled.box.Parent = parent
            pooled.nameLabel.Parent = parent
            pooled.weaponLabel.Parent = parent
            pooled.infoLabel.Parent = parent
            pooled.healthBG.Parent = parent
            pooled.statusIcons.Parent = parent
            pooled.tracer.Parent = parent
            return pooled
        end
        return buildBundle()
    end

    local function hideBundle(bundle)
        if bundle._hidden then return end
        bundle._hidden = true
        bundle.box.Visible = false
        bundle.nameLabel.Visible = false
        bundle.weaponLabel.Visible = false
        bundle.infoLabel.Visible = false
        bundle.healthBG.Visible = false
        bundle.healthFill.Visible = false
        bundle.statusIcons.Visible = false
        bundle.tracer.Visible = false

        for _, slot in ipairs(bundle.iconSlots) do
            slot.icon.Visible = false
            slot.text.Visible = false
        end
    end

    local function destroyBundle(bundle)
        bundle.box:Destroy()
        bundle.nameLabel:Destroy()
        bundle.weaponLabel:Destroy()
        bundle.infoLabel:Destroy()
        bundle.healthBG:Destroy()
        bundle.statusIcons:Destroy()
        bundle.tracer:Destroy()
    end

    local ESP_MAX_POOL = 64
    local function releaseBundle(bundle)
        hideBundle(bundle)

        if #ESPState.pools.boxes >= ESP_MAX_POOL then
            destroyBundle(bundle)
            return
        end

        bundle.box.Parent = nil
        bundle.nameLabel.Parent = nil
        bundle.weaponLabel.Parent = nil
        bundle.infoLabel.Parent = nil
        bundle.healthBG.Parent = nil
        bundle.statusIcons.Parent = nil
        bundle.tracer.Parent = nil

        table.insert(ESPState.pools.boxes, bundle)
    end

    local function resolveHealth(hum)
        local char = hum.Parent
        if ctx.getHealth and char then
            local hp, mhp = ctx.getHealth(char)
            if type(hp) == "number" and type(mhp) == "number" then
                return hp, mhp
            end
        end
        return hum.Health, hum.MaxHealth
    end

    local function formatHealth(hum)
        local hp, mhp = resolveHealth(hum)
        if hp > mhp then return "inf" end
        return tostring(math.floor(hp))
    end

    local function formatMaxHealth(hum)
        local hp, mhp = resolveHealth(hum)
        if hp > mhp then return "inf" end
        return tostring(math.floor(mhp))
    end

    -- ------------------------------------------------------------------
    -- Draw one bundle (per frame, per visible target)
    -- ------------------------------------------------------------------
    local function drawBundle(bundle, rect, hum, plr, label, dist, color)
        local cfg = ENV.CONFIG
        local char = hum.Parent

        bundle._hidden = false
        if bundle._owner ~= char then
            bundle._owner = char
            bundle._slowT = nil
            bundle._weaponName = nil
            bundle._active = nil
            bundle._infoD = nil
        end
        if not bundle._anchored then
            local a = Vector2.new(0.5, 1)
            bundle.nameLabel.AnchorPoint = a
            bundle.weaponLabel.AnchorPoint = a
            bundle.infoLabel.AnchorPoint = a
            bundle._anchored = true
        end

        -- distance-scaled font sizing
        local BASE_DIST   = 50
        local MIN_SCALE   = 0.7
        local MAX_SCALE   = 1.6
        local scale = math.clamp(BASE_DIST / math.max(dist, 5), MIN_SCALE, MAX_SCALE)

        local nameTextSize   = math.max(8, math.floor(13 * scale))
        local weaponTextSize = math.max(7, math.floor(11 * scale))
        local infoTextSize   = math.max(7, math.floor(11 * scale))
        local iconSize       = math.max(10, math.floor(16 * scale))

        -- slow-changing data refreshes about 10x/s per bundle
        local now = os.clock()
        local slowTick = (not bundle._slowT) or (now - bundle._slowT) >= 0.1
        if slowTick then bundle._slowT = now end

        local weaponName = nil
        if cfg.espWeaponName and char then
            if slowTick then
                if ctx.getWeaponName then
                    bundle._weaponName = ctx.getWeaponName(char) or false
                else
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    bundle._weaponName = tool and tool.Name or false
                end
            end
            weaponName = bundle._weaponName or nil
        end

        -- box
        if cfg.espBoxes then
            bundle.box.Visible = true
            bundle.box.Position = UDim2.fromOffset(rect.x, rect.y)
            bundle.box.Size = UDim2.fromOffset(rect.w, rect.h)
            if bundle._boxCol ~= color then
                bundle.boxStroke.Color = color
                bundle._boxCol = color
            end
            local boxTr = cfg.espTransparency or 0.15
            if bundle._boxTr ~= boxTr then
                bundle.boxStroke.Transparency = boxTr
                bundle._boxTr = boxTr
            end
        else
            bundle.box.Visible = false
        end

        -- stack layout
        local NAME_H   = nameTextSize + 2
        local WEAPON_H = weaponTextSize + 2
        local INFO_H   = infoTextSize + 2
        local GAP      = 2
        local BOX_GAP  = 4
        local stackBottom = rect.y - BOX_GAP

        -- name label
        if cfg.espNames and label then
            if bundle._lastName ~= label then
                bundle.nameLabel.Text = label
                bundle._lastName = label
            end

            local nameY = stackBottom - INFO_H - GAP
            if weaponName then
                nameY = nameY - WEAPON_H - GAP
            end

            if bundle._nameTS ~= nameTextSize then
                bundle.nameLabel.TextSize = nameTextSize
                bundle._nameTS = nameTextSize
            end
            local textWidth = #label * (nameTextSize * 0.55)
            bundle.nameLabel.Size = UDim2.fromOffset(math.max(textWidth + 12, rect.w), NAME_H)
            bundle.nameLabel.Position = UDim2.new(0, rect.x + rect.w / 2, 0, nameY)
            if bundle._nameCol ~= color then
                bundle.nameLabel.TextColor3 = color
                bundle._nameCol = color
            end
            bundle.nameLabel.Visible = true
        else
            bundle.nameLabel.Visible = false
        end

        -- weapon label
        if weaponName then
            if bundle._lastWeapon ~= weaponName then
                bundle.weaponLabel.Text = weaponName
                bundle._lastWeapon = weaponName
            end

            local weaponY = stackBottom - INFO_H - GAP

            if bundle._weaponTS ~= weaponTextSize then
                bundle.weaponLabel.TextSize = weaponTextSize
                bundle._weaponTS = weaponTextSize
            end
            local textWidth = #weaponName * (weaponTextSize * 0.55)
            bundle.weaponLabel.Size = UDim2.fromOffset(math.max(textWidth + 12, rect.w), WEAPON_H)
            bundle.weaponLabel.Position = UDim2.new(0, rect.x + rect.w / 2, 0, weaponY)
            if bundle._weaponCol ~= color then
                bundle.weaponLabel.TextColor3 = color
                bundle._weaponCol = color
            end
            bundle.weaponLabel.Visible = true
        else
            bundle.weaponLabel.Visible = false
        end

        -- info label (distance + health)
        local fd = math.floor(dist)
        local hp, mhp = resolveHealth(hum)
        local infoStr
        if bundle._infoD == fd and bundle._infoH == hp and bundle._infoM == mhp
            and bundle._infoCD == cfg.espDistance and bundle._infoCH == cfg.espHealth then
            infoStr = bundle._infoStr
        else
            local infoParts = {}
            if cfg.espDistance then
                infoParts[#infoParts + 1] = "[" .. fd .. "m]"
            end
            if cfg.espHealth then
                infoParts[#infoParts + 1] = "[" .. formatHealth(hum) .. "/" .. formatMaxHealth(hum) .. "]"
            end
            infoStr = table.concat(infoParts, " ")
            bundle._infoD, bundle._infoH, bundle._infoM = fd, hp, mhp
            bundle._infoCD, bundle._infoCH = cfg.espDistance, cfg.espHealth
            bundle._infoStr = infoStr
        end

        if infoStr ~= "" then
            if bundle._lastInfo ~= infoStr then
                bundle.infoLabel.Text = infoStr
                bundle._lastInfo = infoStr
            end

            if bundle._infoTS ~= infoTextSize then
                bundle.infoLabel.TextSize = infoTextSize
                bundle._infoTS = infoTextSize
            end
            local textWidth = #infoStr * (infoTextSize * 0.55)
            bundle.infoLabel.Size = UDim2.fromOffset(math.max(textWidth + 12, rect.w), INFO_H)
            bundle.infoLabel.Position = UDim2.new(0, rect.x + rect.w / 2, 0, stackBottom)
            if not bundle._infoWhite then
                bundle.infoLabel.TextColor3 = Color3.new(1, 1, 1)
                bundle._infoWhite = true
            end
            bundle.infoLabel.Visible = true
        else
            bundle.infoLabel.Visible = false
        end

        -- health bar
        if cfg.espHealth then
            local maxH = math.max(mhp, 1)
            local ratio
            if hp > mhp then
                ratio = 1
            else
                ratio = math.clamp(hp / maxH, 0, 1)
            end

            local barX = rect.x - 6

            bundle.healthBG.Visible = true
            bundle.healthBG.Position = UDim2.fromOffset(barX, rect.y)
            bundle.healthBG.Size = UDim2.fromOffset(3, rect.h)

            bundle.healthFill.Visible = true
            local over = hp > mhp
            if bundle._hpRatio ~= ratio or bundle._hpOver ~= over then
                bundle._hpRatio = ratio
                bundle._hpOver = over
                bundle.healthFill.Position = UDim2.new(0, 0, 1, 0)
                bundle.healthFill.Size = UDim2.new(1, 0, ratio, 0)
                if over then
                    bundle.healthFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                else
                    bundle.healthFill.BackgroundColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), ratio)
                end
            end
        else
            bundle.healthBG.Visible = false
            bundle.healthFill.Visible = false
        end

        -- status icons: data comes from ctx.getStatuses (game-specific), icons from ctx.getIcon
        if cfg.espStatusIcons and char and ctx.getStatuses then
            local active = bundle._active
            if slowTick or not active then
                active = ctx.getStatuses(char) or {}
                bundle._active = active
            end

            if #active > 0 then
                local ICON_GAP = 3
                local TEXT_GAP = 4
                local showText = cfg.espStatusText ~= false
                local colX = rect.x + rect.w + 5
                local startY = rect.y

                for i, status in ipairs(active) do
                    local slot = bundle.iconSlots[i]
                    if slot then
                        local iconAsset = ctx.getIcon and ctx.getIcon(status.key) or nil
                        local slotY = startY + (i - 1) * (iconSize + ICON_GAP)

                        if iconAsset then
                            slot.icon.Size = UDim2.fromOffset(iconSize, iconSize)
                            if slot._img ~= iconAsset then
                                slot.icon.Image = iconAsset
                                slot._img = iconAsset
                            end
                            if slot._icol ~= color then
                                slot.icon.ImageColor3 = color
                                slot._icol = color
                            end
                            slot.icon.Position = UDim2.fromOffset(colX, slotY)
                            slot.icon.Visible = true
                        else
                            slot.icon.Visible = false
                        end

                        if showText and status.label then
                            local slotTS = math.max(7, math.floor(11 * scale))
                            if slot._ts ~= slotTS then
                                slot.text.TextSize = slotTS
                                slot._ts = slotTS
                            end
                            if slot._label ~= status.label then
                                slot.text.Text = status.label
                                slot._label = status.label
                            end
                            local textX = colX
                            if iconAsset then textX = colX + iconSize + TEXT_GAP end
                            slot.text.Size = UDim2.fromOffset(120, iconSize)
                            slot.text.Position = UDim2.fromOffset(textX, slotY)
                            if slot._tcol ~= color then
                                slot.text.TextColor3 = color
                                slot._tcol = color
                            end
                            slot.text.Visible = true
                        else
                            slot.text.Visible = false
                        end
                    end
                end

                for i = #active + 1, #bundle.iconSlots do
                    bundle.iconSlots[i].icon.Visible = false
                    bundle.iconSlots[i].text.Visible = false
                end

                bundle.statusIcons.Visible = true
            else
                bundle.statusIcons.Visible = false
                for i = 1, #bundle.iconSlots do
                    bundle.iconSlots[i].icon.Visible = false
                    bundle.iconSlots[i].text.Visible = false
                end
            end
        else
            bundle.statusIcons.Visible = false
        end

        -- tracer
        if cfg.espTracers then
            local vpW = Player.Camera.ViewportSize.X
            local vpH = Player.Camera.ViewportSize.Y

            local from = Vector2.new(vpW / 2, vpH)
            local to = Vector2.new(rect.x + rect.w / 2, rect.y + rect.h)

            local delta = to - from
            local length = delta.Magnitude
            local angle = math.deg(math.atan2(delta.Y, delta.X)) + 90

            bundle.tracer.Visible = true
            bundle.tracer.Position = UDim2.fromOffset(from.X, from.Y)
            bundle.tracer.Size = UDim2.fromOffset(1, length)
            bundle.tracer.Rotation = angle
            bundle.tracer.BackgroundColor3 = color
            bundle.tracer.BackgroundTransparency = 0.3
        else
            bundle.tracer.Visible = false
        end
    end

    -- ------------------------------------------------------------------
    -- Render loop (scratch tables are reused every frame to avoid garbage)
    -- ------------------------------------------------------------------
    local rectBuf = {}
    local ownerOf = {}
    local seenP = {}
    local seenX = {}

    local function hideEntry(reg, key)
        local entry = reg[key]
        if entry then hideBundle(entry.bundle) end
    end

    local function stepPlayer(plr, camPos, maxDist)
        local reg = ESPState.PlayerRegistry
        local char = plr.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        local root = char and char:FindFirstChild(HRP)

        if not char or not hum or not root or hum.Health <= 0 then
            hideEntry(reg, plr)
            return
        end

        seenP[plr] = true

        local dist = (root.Position - camPos).Magnitude
        if dist > maxDist then
            hideEntry(reg, plr)
            return
        end

        local entry = reg[plr]
        if not entry then
            entry = { bundle = acquireBundle(), model = char, player = plr }
            reg[plr] = entry
        end
        entry.model = char

        local rect = projectBox(char, rectBuf)
        if not rect then
            hideBundle(entry.bundle)
            return
        end

        local label = entry._label
        if not label then
            label = plr.DisplayName ~= plr.Name
                and (plr.DisplayName .. " (" .. plr.Name .. ")")
                or plr.Name
            entry._label = label
        end

        drawBundle(entry.bundle, rect, hum, plr, label, dist, resolveColor(plr, nil))
    end

    local function stepExtra(item, camPos, maxDist)
        local reg = ESPState.ExtraRegistry
        local m = item.model
        if not m or not m.Parent then return end
        if ownerOf[m] then return end  -- a player's current character, handled in the player pass

        local hum = m:FindFirstChildWhichIsA("Humanoid")
        local root = m:FindFirstChild(HRP) or m:FindFirstChild("Torso")

        if not hum or not root or hum.Health <= 0 then
            hideEntry(reg, m)
            return
        end

        seenX[m] = true

        local dist = (root.Position - camPos).Magnitude
        if dist > maxDist then
            hideEntry(reg, m)
            return
        end

        local entry = reg[m]
        if not entry then
            entry = { bundle = acquireBundle(), model = m, player = nil }
            reg[m] = entry
        end

        local rect = projectBox(m, rectBuf)
        if not rect then
            hideBundle(entry.bundle)
            return
        end

        drawBundle(entry.bundle, rect, hum, nil, item.label or m.Name, dist, item.color or DEFAULT_EXTRA_COLOR)
    end

    local function frame()
        local cfg = ENV.CONFIG
        local playerReg, extraReg = ESPState.PlayerRegistry, ESPState.ExtraRegistry

        if not cfg.espEnabled then
            for _, entry in pairs(playerReg) do hideBundle(entry.bundle) end
            for _, entry in pairs(extraReg) do hideBundle(entry.bundle) end
            return
        end

        local camPos = Player.Camera.CFrame.Position
        local maxDist = cfg.espMaxDistance or 500

        table.clear(ownerOf)
        table.clear(seenP)
        table.clear(seenX)

        -- players (UserId rule: never compare against Player.Local)
        local myId = API.getMyUserId()
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            local char = plr.Character
            if char then ownerOf[char] = plr end
            if plr.UserId ~= myId then
                stepPlayer(plr, camPos, maxDist)
            end
        end

        for plr, entry in pairs(playerReg) do
            if not seenP[plr] then
                releaseBundle(entry.bundle)
                playerReg[plr] = nil
            end
        end

        -- extra targets supplied by the game (NPCs and so on)
        local getExtras = ctx.getExtras
        if getExtras then
            local list = getExtras()
            if list then
                for _, item in ipairs(list) do
                    stepExtra(item, camPos, maxDist)
                end
            end
        end

        for m, entry in pairs(extraReg) do
            if not seenX[m] then
                releaseBundle(entry.bundle)
                extraReg[m] = nil
            end
        end
    end

    local function ensureRenderLoop()
        if ESPState.renderLoop then return end
        ESPState.renderLoop = ctx.track("espRenderConn", Services.RunService.RenderStepped:Connect(frame))
    end

    -- ------------------------------------------------------------------
    -- Public
    -- ------------------------------------------------------------------
    function ESP.add(plr)
        if plr.UserId == API.getMyUserId() then return end
        ensureRenderLoop()
    end

    function ESP.refresh()
        ensureRenderLoop()
    end

    -- Clears the ENTIRE ESP table (owner decision): bundles, pools, registries, loop, root.
    function ESP.cleanupAll()
        for _, entry in pairs(ESPState.PlayerRegistry) do
            hideBundle(entry.bundle)
            destroyBundle(entry.bundle)
        end
        for _, entry in pairs(ESPState.ExtraRegistry) do
            hideBundle(entry.bundle)
            destroyBundle(entry.bundle)
        end
        table.clear(ESPState.PlayerRegistry)
        table.clear(ESPState.ExtraRegistry)

        for _, bundle in ipairs(ESPState.pools.boxes) do
            pcall(destroyBundle, bundle)
        end
        table.clear(ESPState.pools.boxes)

        if ESPState.renderLoop then
            API.unc(ENV.CONNS, "espRenderConn")   -- disconnects and clears the tracked handle
            pcall(function() ESPState.renderLoop:Disconnect() end)
            ESPState.renderLoop = nil
        end

        table.clear(ownerOf)
        table.clear(seenP)
        table.clear(seenX)

        if ESPState.root then
            pcall(function() ESPState.root:Destroy() end)
            ESPState.root = nil
        end
    end

    return ESP
end
