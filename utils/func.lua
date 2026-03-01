-- UtilityModule by Claude
-- local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/Damix-hash/roblox-stuff/refs/heads/main/utils/func.lua"))()

local Utils = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local function timestamp()
    return "[" .. os.date("%H:%M:%S") .. "]"
end

local function log(tag, msg)
    print(timestamp() .. " [Utils:" .. tag .. "] " .. tostring(msg))
end

local function warn_log(tag, msg)
    warn(timestamp() .. " [Utils:" .. tag .. "] " .. tostring(msg))
end

-- SAFE GETSERVICE
-- Returns the service or nil instead of erroring if it doesn't exist
function Utils.SafeGetService(name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    if ok and svc then
        log("SafeGetService", "Got service: " .. name)
        return svc
    end
    warn_log("SafeGetService", "Service not found: " .. name)
    return nil
end

-- CHARACTER / PLAYER

function Utils.GetChar(player)
    player = player or LP
    return player.Character or player.CharacterAdded:Wait()
end

-- Finds the character even if it's parented to a non-standard location (folder, etc.)
-- Logs a warning if the parent is unexpected
function Utils.GetHumanoid(target)
    local char
    if typeof(target) == "Instance" and target:IsA("Player") then
        char = Utils.GetChar(target)
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        char = target
    else
        char = Utils.GetChar()
    end
    if char then
        local parent = char.Parent
        if parent and parent ~= workspace and not parent:IsA("WorldRoot") then
            warn_log("GetHumanoid", "Character '" .. char.Name .. "' is parented to: " .. parent:GetFullName() .. " (not workspace!)")
        end
    end
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.GetRoot(target)
    local char
    if typeof(target) == "Instance" and target:IsA("Player") then
        char = Utils.GetChar(target)
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        char = target
    else
        char = Utils.GetChar()
    end
    if char then
        local parent = char.Parent
        if parent and parent ~= workspace and not parent:IsA("WorldRoot") then
            warn_log("GetRoot", "Character '" .. char.Name .. "' is parented to unexpected location: " .. parent:GetFullName())
        end
    end
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.GetPlayer(name)
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) then return p end
    end
    return nil
end

function Utils.GetOtherPlayers()
    local result = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(result, p) end
    end
    return result
end

function Utils.IsAlive(player)
    local hum = Utils.GetHumanoid(player)
    return hum ~= nil and hum.Health > 0
end

function Utils.GetPos(player)
    local root = Utils.GetRoot(player)
    return root and root.Position
end

-- ANCHOR / UNANCHOR LOCAL CHARACTER
-- Anchors every BasePart in your character so you can't be moved or fall
function Utils.AnchorChar()
    local char = Utils.GetChar()
    if not char then return false end
    local count = 0
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            count = count + 1
        end
    end
    log("AnchorChar", "Anchored " .. count .. " parts " .. timestamp())
    return true
end

-- Unanchors your character (restores normal physics)
function Utils.UnanchorChar()
    local char = Utils.GetChar()
    if not char then return false end
    local count = 0
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            count = count + 1
        end
    end
    log("UnanchorChar", "Unanchored " .. count .. " parts " .. timestamp())
    return true
end

-- TELEPORT

function Utils.TeleportTo(target)
    local root = Utils.GetRoot()
    if not root then return end
    if typeof(target) == "Instance" and target:IsA("Player") then
        local targetRoot = Utils.GetRoot(target)
        if targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            log("TeleportTo", "Teleported to player: " .. target.Name)
        end
    elseif typeof(target) == "Vector3" then
        root.CFrame = CFrame.new(target)
        log("TeleportTo", "Teleported to Vector3: " .. tostring(target))
    elseif typeof(target) == "CFrame" then
        root.CFrame = target
        log("TeleportTo", "Teleported to CFrame")
    end
end

function Utils.TeleportToPart(part, offset)
    local root = Utils.GetRoot()
    if not root then return end
    if not (typeof(part) == "Instance" and part:IsA("BasePart")) then
        warn_log("TeleportToPart", "Expected BasePart, got " .. typeof(part))
        return
    end
    offset = offset or Vector3.new(0, (part.Size.Y / 2) + 3, 0)
    root.CFrame = part.CFrame + offset
    log("TeleportToPart", "Teleported to part: " .. part:GetFullName())
end

-- SAFE REMOTE / FIRE CALLS

function Utils.SafeFireServer(remotePath, ...)
    local ok, remote = pcall(function()
        return typeof(remotePath) == "Instance" and remotePath
            or game:FindFirstChild(remotePath, true)
    end)
    if not ok or not remote then
        warn_log("SafeFireServer", "Remote not found: " .. tostring(remotePath))
        return false
    end
    if not remote:IsA("RemoteEvent") then
        warn_log("SafeFireServer", "Not a RemoteEvent: " .. remote:GetFullName())
        return false
    end
    local success, err = pcall(function() remote:FireServer(...) end)
    if not success then
        warn_log("SafeFireServer", "FireServer failed: " .. tostring(err))
        return false
    end
    log("SafeFireServer", "Fired " .. remote:GetFullName() .. " " .. timestamp())
    return true
end

function Utils.SafeInvokeServer(remotePath, ...)
    local ok, remote = pcall(function()
        return typeof(remotePath) == "Instance" and remotePath
            or game:FindFirstChild(remotePath, true)
    end)
    if not ok or not remote then
        warn_log("SafeInvokeServer", "RemoteFunction not found: " .. tostring(remotePath))
        return nil
    end
    if not remote:IsA("RemoteFunction") then
        warn_log("SafeInvokeServer", "Not a RemoteFunction: " .. remote:GetFullName())
        return nil
    end
    local success, result = pcall(function() return remote:InvokeServer(...) end)
    if not success then
        warn_log("SafeInvokeServer", "InvokeServer failed: " .. tostring(result))
        return nil
    end
    log("SafeInvokeServer", "Invoked " .. remote:GetFullName() .. " " .. timestamp())
    return result
end

function Utils.SafeFireBindable(bindablePath, ...)
    local ok, bindable = pcall(function()
        return typeof(bindablePath) == "Instance" and bindablePath
            or game:FindFirstChild(bindablePath, true)
    end)
    if not ok or not bindable then
        warn_log("SafeFireBindable", "Bindable not found: " .. tostring(bindablePath))
        return false
    end
    if not bindable:IsA("BindableEvent") then
        warn_log("SafeFireBindable", "Not a BindableEvent: " .. bindable:GetFullName())
        return false
    end
    local success, err = pcall(function() bindable:Fire(...) end)
    if not success then
        warn_log("SafeFireBindable", "Fire failed: " .. tostring(err))
        return false
    end
    log("SafeFireBindable", "Fired " .. bindable:GetFullName() .. " " .. timestamp())
    return true
end

-- TOOL UTILS

function Utils.EquipTool(name, waitTime)
    if waitTime and waitTime > 0 then
        log("EquipTool", "Waiting " .. waitTime .. "s before equipping '" .. name .. "' " .. timestamp())
        task.wait(waitTime)
    end
    local char = Utils.GetChar()
    local hum = Utils.GetHumanoid()
    if not hum then
        warn_log("EquipTool", "No humanoid found")
        return false
    end
    name = name:lower()
    for _, item in ipairs(LP.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find(name) then
            hum:EquipTool(item)
            log("EquipTool", "Equipped: " .. item.Name .. " " .. timestamp())
            return true
        end
    end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find(name) then
            log("EquipTool", "Already equipped: " .. item.Name)
            return true
        end
    end
    warn_log("EquipTool", "Tool not found: " .. name)
    return false
end

function Utils.UnequipTool(waitTime)
    if waitTime and waitTime > 0 then
        log("UnequipTool", "Waiting " .. waitTime .. "s before unequipping " .. timestamp())
        task.wait(waitTime)
    end
    local hum = Utils.GetHumanoid()
    if hum then
        hum:UnequipTools()
        log("UnequipTool", "Unequipped all tools " .. timestamp())
        return true
    end
    return false
end

function Utils.GetEquippedTool()
    local char = Utils.GetChar()
    return char and char:FindFirstChildOfClass("Tool")
end

function Utils.ActivateTool(waitTime)
    if waitTime and waitTime > 0 then
        log("ActivateTool", "Waiting " .. waitTime .. "s before activating " .. timestamp())
        task.wait(waitTime)
    end
    local tool = Utils.GetEquippedTool()
    if not tool then
        warn_log("ActivateTool", "No tool equipped")
        return false
    end
    local success, err = pcall(function()
        local activate = tool:FindFirstChild("Activate")
        if activate and activate:IsA("BindableEvent") then
            activate:Fire()
        else
            tool.Activated:Fire()
        end
    end)
    if not success then
        warn_log("ActivateTool", "Activation failed: " .. tostring(err))
        return false
    end
    log("ActivateTool", "Activated: " .. tool.Name .. " " .. timestamp())
    return true
end

function Utils.DeactivateTool(waitTime)
    if waitTime and waitTime > 0 then task.wait(waitTime) end
    local tool = Utils.GetEquippedTool()
    if not tool then
        warn_log("DeactivateTool", "No tool equipped")
        return false
    end
    local success, err = pcall(function() tool.Deactivated:Fire() end)
    if not success then
        warn_log("DeactivateTool", "Deactivation failed: " .. tostring(err))
        return false
    end
    log("DeactivateTool", "Deactivated: " .. tool.Name .. " " .. timestamp())
    return true
end

function Utils.EquipAndActivate(name, equipDelay, activateDelay)
    local equipped = Utils.EquipTool(name, equipDelay)
    if not equipped then return false end
    return Utils.ActivateTool(activateDelay or 0.1)
end

-- Parents all backpack tools directly to character so they all "exist" at once
-- without hum:EquipTool which would unequip the previous one each time
-- delay: optional seconds between each
function Utils.EquipAllTools(delay)
    delay = delay or 0
    local char = Utils.GetChar()
    if not char then
        warn_log("EquipAllTools", "No character found")
        return {}
    end
    local tools = {}
    for _, item in ipairs(LP.Backpack:GetChildren()) do
        if item:IsA("Tool") then table.insert(tools, item) end
    end
    if #tools == 0 then
        warn_log("EquipAllTools", "No tools in backpack")
        return {}
    end
    local equipped = {}
    for _, tool in ipairs(tools) do
        local ok, err = pcall(function() tool.Parent = char end)
        if ok then
            log("EquipAllTools", "Parented to char: " .. tool.Name .. " " .. timestamp())
            table.insert(equipped, tool.Name)
        else
            warn_log("EquipAllTools", "Failed for " .. tool.Name .. ": " .. tostring(err))
        end
        if delay > 0 then task.wait(delay) end
    end
    log("EquipAllTools", "Done. " .. #equipped .. "/" .. #tools .. " tools in character " .. timestamp())
    return equipped
end

function Utils.GetAllTools()
    local tools = {}
    for _, item in ipairs(LP.Backpack:GetChildren()) do
        if item:IsA("Tool") then table.insert(tools, item) end
    end
    local char = Utils.GetChar()
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then table.insert(tools, item) end
        end
    end
    return tools
end

function Utils.DropTool()
    local tool = Utils.GetEquippedTool()
    if not tool then
        warn_log("DropTool", "No tool currently equipped")
        return false
    end
    local ok, err = pcall(function() tool.Parent = workspace end)
    if not ok then
        warn_log("DropTool", "Failed to drop: " .. tostring(err))
        return false
    end
    log("DropTool", "Dropped: " .. tool.Name .. " " .. timestamp())
    return true
end

-- Get the GripPos / GripCFrame of the equipped tool's handle
-- GripPos controls where in the character's hand the tool sits
-- Changing it is client-side only in FE games but still useful for visual tricks
function Utils.GetToolGrip()
    local tool = Utils.GetEquippedTool()
    if not tool then
        warn_log("GetToolGrip", "No tool equipped")
        return nil
    end
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        warn_log("GetToolGrip", "Tool has no Handle part: " .. tool.Name)
        return nil
    end
    log("GetToolGrip", tool.Name .. " GripPos=" .. tostring(tool.GripPos) .. " GripCFrame=" .. tostring(tool.GripCFrame))
    return {
        GripPos    = tool.GripPos,
        GripUp     = tool.GripUp,
        GripRight  = tool.GripRight,
        GripForward = tool.GripForward,
        GripCFrame = tool.GripCFrame,
        Handle     = handle,
    }
end

-- Set the GripPos of the equipped tool (moves where it sits in your hand)
function Utils.SetToolGripPos(pos)
    local tool = Utils.GetEquippedTool()
    if not tool then
        warn_log("SetToolGripPos", "No tool equipped")
        return false
    end
    local ok, err = pcall(function() tool.GripPos = pos end)
    if not ok then
        warn_log("SetToolGripPos", "Failed: " .. tostring(err))
        return false
    end
    log("SetToolGripPos", "Set GripPos to " .. tostring(pos) .. " on " .. tool.Name .. " " .. timestamp())
    return true
end

-- WAIT UTILS

function Utils.TimedWait(seconds, label)
    label = label or "Wait"
    log(label, "Waiting " .. seconds .. "s... " .. timestamp())
    task.wait(seconds)
    log(label, "Done. " .. timestamp())
end

function Utils.WaitUntil(conditionFn, timeout, label)
    label = label or "WaitUntil"
    timeout = timeout or 10
    local start = tick()
    log(label, "Waiting for condition (timeout: " .. timeout .. "s) " .. timestamp())
    while not conditionFn() do
        if tick() - start >= timeout then
            warn_log(label, "Timed out after " .. timeout .. "s " .. timestamp())
            return false
        end
        task.wait(0.1)
    end
    log(label, "Condition met in " .. string.format("%.2f", tick() - start) .. "s " .. timestamp())
    return true
end

function Utils.WaitForChild(parent, childName, timeout)
    timeout = timeout or 10
    log("WaitForChild", "Waiting for '" .. childName .. "' " .. timestamp())
    local child = parent:WaitForChild(childName, timeout)
    if child then
        log("WaitForChild", "Found: " .. child:GetFullName() .. " " .. timestamp())
    else
        warn_log("WaitForChild", "Timed out waiting for: " .. childName .. " " .. timestamp())
    end
    return child
end

function Utils.WaitForChildOfClass(parent, className, timeout)
    timeout = timeout or 10
    log("WaitForChildOfClass", "Waiting for class '" .. className .. "' in " .. parent:GetFullName() .. " " .. timestamp())
    local start = tick()
    local existing = parent:FindFirstChildOfClass(className)
    if existing then
        log("WaitForChildOfClass", "Already exists: " .. existing:GetFullName())
        return existing
    end
    local found = nil
    local conn
    conn = parent.ChildAdded:Connect(function(child)
        if child:IsA(className) and not found then found = child end
    end)
    while not found do
        if tick() - start >= timeout then
            conn:Disconnect()
            warn_log("WaitForChildOfClass", "Timed out waiting for: " .. className .. " " .. timestamp())
            return nil
        end
        task.wait(0.05)
    end
    conn:Disconnect()
    log("WaitForChildOfClass", "Found: " .. found:GetFullName() .. " in " .. string.format("%.2f", tick() - start) .. "s " .. timestamp())
    return found
end

function Utils.WaitForDescendantOfClass(parent, className, timeout)
    timeout = timeout or 10
    log("WaitForDescendantOfClass", "Waiting for class '" .. className .. "' under " .. parent:GetFullName() .. " " .. timestamp())
    local start = tick()
    local existing = parent:FindFirstChildOfClass(className, true)
    if existing then
        log("WaitForDescendantOfClass", "Already exists: " .. existing:GetFullName())
        return existing
    end
    local found = nil
    local conn
    conn = parent.DescendantAdded:Connect(function(desc)
        if desc:IsA(className) and not found then found = desc end
    end)
    while not found do
        if tick() - start >= timeout then
            conn:Disconnect()
            warn_log("WaitForDescendantOfClass", "Timed out waiting for: " .. className .. " " .. timestamp())
            return nil
        end
        task.wait(0.05)
    end
    conn:Disconnect()
    log("WaitForDescendantOfClass", "Found: " .. found:GetFullName() .. " " .. timestamp())
    return found
end

-- BRING PART

function Utils.BringPart(part, offset)
    if not (typeof(part) == "Instance" and part:IsA("BasePart")) then
        warn_log("BringPart", "Expected a BasePart, got " .. typeof(part))
        return false
    end
    local root = Utils.GetRoot()
    if not root then return false end
    offset = offset or Vector3.new(0, 0, -3)
    local ok, err = pcall(function() part.CFrame = root.CFrame + offset end)
    if not ok then
        warn_log("BringPart", "Failed: " .. tostring(err))
        return false
    end
    log("BringPart", "Brought: " .. part:GetFullName() .. " " .. timestamp())
    return true
end

function Utils.BringPartLoop(part, interval, offset)
    interval = interval or 0.1
    offset = offset or Vector3.new(0, 0, -3)
    local running = true
    log("BringPartLoop", "Started for: " .. part:GetFullName() .. " " .. timestamp())
    task.spawn(function()
        while running do
            Utils.BringPart(part, offset)
            task.wait(interval)
        end
        log("BringPartLoop", "Stopped for: " .. part:GetFullName() .. " " .. timestamp())
    end)
    return function() running = false end
end

-- Bring all BaseParts within radius studs to you.
-- parent: where to search (default workspace)
-- options table (all optional):
--   excludeCharacters : bool   -- skip all player character parts (default true)
--   excludeBaseplate  : bool   -- skip parts named "Baseplate" (default true)
--   excludeAnchored   : bool   -- skip already-anchored parts (default false)
--   onlyFromParent    : Instance -- ONLY bring direct children of this specific instance
--                                  e.g. onlyFromParent = workspace.Drops
--   offset            : Vector3 -- where to drop them relative to you (default 0,2,-3)
function Utils.BringPartsInRadius(radius, parent, options)
    radius  = radius  or 50
    parent  = parent  or workspace
    options = options or {}

    local excludeCharacters = options.excludeCharacters ~= false  -- default true
    local excludeBaseplate  = options.excludeBaseplate  ~= false  -- default true
    local excludeAnchored   = options.excludeAnchored   == true   -- default false
    local onlyFromParent    = options.onlyFromParent              -- nil = no filter
    local offset            = options.offset or Vector3.new(0, 2, -3)

    local root = Utils.GetRoot()
    if not root then return 0 end

    -- build a set of all character parts to skip
    local charParts = {}
    if excludeCharacters then
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    charParts[part] = true
                end
                charParts[c] = true
            end
        end
    end

    local count = 0
    local candidates = onlyFromParent
        and onlyFromParent:GetChildren()   -- only direct children of the given parent
        or  parent:GetDescendants()        -- everything under workspace (or custom parent)

    for _, v in ipairs(candidates) do
        if v:IsA("BasePart") and v ~= root then
            -- apply filters
            if charParts[v] then goto continue end
            if excludeBaseplate and v.Name == "Baseplate" then goto continue end
            if excludeAnchored and v.Anchored then goto continue end
            if (v.Position - root.Position).Magnitude > radius then goto continue end

            local ok, err = pcall(function() v.CFrame = root.CFrame + offset end)
            if ok then
                count = count + 1
            else
                warn_log("BringPartsInRadius", "Skipped " .. v:GetFullName() .. ": " .. tostring(err))
            end
        end
        ::continue::
    end

    log("BringPartsInRadius", "Brought " .. count .. " parts within " .. radius .. " studs " .. timestamp())
    return count
end

-- MISC

function Utils.SafeGet(instance, property)
    local ok, val = pcall(function() return instance[property] end)
    return ok and val or nil
end

function Utils.SafeSet(instance, property, value)
    local ok, err = pcall(function() instance[property] = value end)
    if not ok then warn_log("SafeSet", "Failed to set '" .. property .. "': " .. tostring(err)) end
    return ok
end

function Utils.GetDistance(a, b)
    local function toVec(v)
        if typeof(v) == "Vector3" then return v end
        if typeof(v) == "Instance" then
            if v:IsA("Player") then return Utils.GetPos(v)
            elseif v:IsA("BasePart") then return v.Position
            elseif v:IsA("Model") then
                local r = v:FindFirstChild("HumanoidRootPart")
                return r and r.Position
            end
        end
    end
    local va, vb = toVec(a), toVec(b)
    if va and vb then return (va - vb).Magnitude end
    warn_log("GetDistance", "Could not resolve positions")
    return nil
end

-- LIST SCRIPTS

-- List all RemoteEvents, RemoteFunctions, BindableEvents
function Utils.ListRemotes(parent)
    parent = parent or game
    log("ListRemotes", "Scanning under " .. parent:GetFullName() .. "...")
    local found = {}
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
            local line = v:GetFullName() .. " [" .. v.ClassName .. "]"
            table.insert(found, line)
            print(line)
        end
    end
    log("ListRemotes", "Found " .. #found .. " total.")
    return found
end

-- List all LocalScripts in the game (exploits can decompile these)
function Utils.ListLocalScripts(parent)
    parent = parent or game
    log("ListLocalScripts", "Scanning under " .. parent:GetFullName() .. "...")
    local found = {}
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("LocalScript") then
            local line = v:GetFullName() .. (v.Disabled and " [DISABLED]" or " [ACTIVE]")
            table.insert(found, line)
            print(line)
        end
    end
    log("ListLocalScripts", "Found " .. #found .. " LocalScripts total.")
    return found
end

-- List all ModuleScripts in the game (exploits can decompile these too)
function Utils.ListModuleScripts(parent)
    parent = parent or game
    log("ListModuleScripts", "Scanning under " .. parent:GetFullName() .. "...")
    local found = {}
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("ModuleScript") then
            local line = v:GetFullName()
            table.insert(found, line)
            print(line)
        end
    end
    log("ListModuleScripts", "Found " .. #found .. " ModuleScripts total.")
    return found
end

-- List ALL scripts at once (LocalScripts + ModuleScripts + regular Scripts visible client-side)
function Utils.ListAllScripts(parent)
    parent = parent or game
    log("ListAllScripts", "Full script scan under " .. parent:GetFullName() .. " " .. timestamp())
    local counts = { LocalScript = 0, ModuleScript = 0, Script = 0 }
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Script") then
            counts[v.ClassName] = (counts[v.ClassName] or 0) + 1
            print("[" .. v.ClassName .. "] " .. v:GetFullName())
        end
    end
    log("ListAllScripts", string.format("Done: %d LocalScripts, %d ModuleScripts, %d Scripts",
        counts.LocalScript, counts.ModuleScript, counts.Script))
    return counts
end

-- LOOP / RETRY

function Utils.Loop(interval, fn, maxRuns, label)
    label = label or "Loop"
    local running = true
    local runs = 0
    log(label, "Started (interval=" .. interval .. "s, max=" .. tostring(maxRuns) .. ") " .. timestamp())
    task.spawn(function()
        while running do
            local ok, err = pcall(fn)
            if not ok then warn_log(label, "Error: " .. tostring(err)) end
            runs = runs + 1
            if maxRuns and runs >= maxRuns then running = false break end
            task.wait(interval)
        end
        log(label, "Stopped after " .. runs .. " run(s) " .. timestamp())
    end)
    return function() running = false end
end

function Utils.Retry(fn, maxAttempts, delay, label)
    label = label or "Retry"
    maxAttempts = maxAttempts or 3
    delay = delay or 0.5
    for i = 1, maxAttempts do
        local ok, result = pcall(fn)
        if ok and result then
            log(label, "Succeeded on attempt " .. i .. " " .. timestamp())
            return result
        end
        warn_log(label, "Attempt " .. i .. "/" .. maxAttempts .. " failed " .. timestamp())
        if i < maxAttempts then task.wait(delay) end
    end
    warn_log(label, "All " .. maxAttempts .. " attempts failed " .. timestamp())
    return nil
end

-- PLAYER / CHARACTER EXTRAS

function Utils.GetClosestPlayer(fromPos)
    local root = Utils.GetRoot()
    fromPos = fromPos or (root and root.Position)
    if not fromPos then return nil end
    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and Utils.IsAlive(p) then
            local pos = Utils.GetPos(p)
            if pos then
                local d = (pos - fromPos).Magnitude
                if d < closestDist then closestDist = d closest = p end
            end
        end
    end
    if closest then
        log("GetClosestPlayer", "Closest: " .. closest.Name .. " at " .. string.format("%.1f", closestDist) .. " studs")
    end
    return closest, closestDist
end

function Utils.GetPlayersInRadius(radius, fromPos)
    local root = Utils.GetRoot()
    fromPos = fromPos or (root and root.Position)
    if not fromPos then return {} end
    local result = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and Utils.IsAlive(p) then
            local pos = Utils.GetPos(p)
            if pos and (pos - fromPos).Magnitude <= radius then
                table.insert(result, p)
            end
        end
    end
    log("GetPlayersInRadius", "Found " .. #result .. " players within " .. radius .. " studs")
    return result
end

function Utils.PlayerInfo()
    local root = Utils.GetRoot()
    log("PlayerInfo", "=== Player List " .. timestamp() .. " ===")
    for _, p in ipairs(Players:GetPlayers()) do
        local alive = Utils.IsAlive(p) and "alive" or "dead"
        local dist = root and Utils.GetDistance(root, p)
        local distStr = dist and string.format("%.1f studs", dist) or "unknown"
        local char = p.Character
        local charParent = char and char.Parent and char.Parent:GetFullName() or "none"
        print(string.format("  [%d] %s | %s | %s | char parent: %s", p.UserId, p.Name, alive, distStr, charParent))
    end
end

return Utils
