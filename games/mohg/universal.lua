repeat task.wait() until game:IsLoaded()

cloneref = cloneref or function(obj) return obj end
queueFn = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local getGlobalEnv = function()
    if typeof(getgenv) == "function" then
        return getgenv()
    else
        return _G
    end
end

local ENV = getGlobalEnv()

if ENV.alreadyRunning then warn("Already running...") return end
ENV.alreadyRunning = true

ENV.CONNS = ENV.CONNS or {}

for key, value in pairs(ENV.CONNS) do
    if typeof(value) == "RBXScriptConnection" then
        pcall(function() value:Disconnect() end)
    elseif type(value) == "thread" then
        pcall(function() task.cancel(value) end)
    end
    ENV.CONNS[key] = nil
end

local LANDING    = "https://raw.githubusercontent.com/Damix-hash/roblox-stuff/"
local BASE       = LANDING .. "main/"
local LOADER_URL = BASE .. "games/mohg/universal.lua"
local loader = string.format("if getgenv then getgenv().alreadyRunning = nil end; loadstring(game:HttpGet(%q))()", LOADER_URL)
local HRP = "HumanoidRootPart"
local NS = { Type = "success", Duration = 2 }
local NW = { Type = "warning", Duration = 2 }
local NE = { Type = "error",   Duration = 2 }
local API = {}
local UILib
local Window

API.unc = function(tbl, key)
    local c = tbl[key]
    if not c then tbl[key] = nil; return end
    if typeof(c) == "RBXScriptConnection" then
        pcall(function() c:Disconnect() end)
    elseif type(c) == "thread" then
        pcall(function() task.cancel(c) end)
    end
    tbl[key] = nil
end

local Services = {
    UserInputService    = game:GetService("UserInputService"),
    VirtualInput        = nil,
    HttpService         = game:GetService("HttpService"),
    RunService          = game:GetService("RunService"),
    Lighting            = game:GetService("Lighting"),
    Players             = game:GetService("Players"),
    CoreGui             = game:GetService("CoreGui"),
}

local Player = {
    Local   = Services.Players.LocalPlayer,
    Gui     = Services.Players.LocalPlayer.PlayerGui,
    Mouse   = Services.Players.LocalPlayer:GetMouse(),
}
setmetatable(Player, {
    __index = function(_, k)
        if k == "Camera" then return workspace.CurrentCamera end
        if k == "Backpack" then return Player.Local:FindFirstChildOfClass("Backpack") end
        return nil
    end,
})
if queueFn then
    local queued = false
    Player.Local.OnTeleport:Connect(function()
        if not ENV.CONFIG or not ENV.CONFIG.queueTeleport or queued then return end
        queued = true
        queueFn(loader)
    end)
end

local _lp = nil
local _myUserId = nil

API.getMyUserId = function()
    if _myUserId then return _myUserId end
    _lp = _lp or Services.Players.LocalPlayer
    if _lp then _myUserId = _lp.UserId end
    return _myUserId
end

Services.VirtualInput = Services.UserInputService:CreateVirtualInput()

local FORCEFIELD = setmetatable({}, { __mode = "k" })
local CHAR_WATCHERS = setmetatable({}, { __mode = "k" })
local SKIP_SELF     = true

local SHIELD_NAME_PATTERNS = {
    "shield", "force", "immune", "invulnerable", "invincible",
    "safe", "protect", "godmode", "god_mode", "god",
    "spawnprotect", "spawn_protect", "pvpdisable", "pvp_disable",
    "pvpoff", "pvp_off", "nopvp", "no_pvp",
    "cannotdamage", "cantdamage", "untargetable", "notarget",
    "peacemode", "peace_mode", "graceperiod", "grace_period",
    "spawnshield", "spawn_shield", "spawnguard", "spawn_guard",
    "hitbox_disabled", "hitboxdisabled",
    "damagedisabled", "no_damage", "nodamage", "invuln",
}

local RigTypes = {
    R6 = {
        Head      = {"Head"},
        Torso     = {"Torso"},
        ["Left Arm"]  = {"Left Arm"},
        ["Right Arm"] = {"Right Arm"},
        ["Left Leg"]  = {"Left Leg"},
        ["Right Leg"] = {"Right Leg"},
    },
    R15 = {
        Head      = {"Head"},
        Torso     = {"UpperTorso", "LowerTorso"},
        ["Left Arm"]  = {"LeftUpperArm",  "LeftLowerArm",  "LeftHand"},
        ["Right Arm"] = {"RightUpperArm", "RightLowerArm", "RightHand"},
        ["Left Leg"]  = {"LeftUpperLeg",  "LeftLowerLeg",  "LeftFoot"},
        ["Right Leg"] = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
    },
}

local ESP_STATUSES = {}

local TARGET_PART_VALUES = {"Head", "Torso", "Left_arm", "Right_arm", "Left_leg", "Right_leg"}
local TARGET_PART_LABELS = {
    Head      = "Head",
    Torso     = "Torso",
    Left_arm  = "Left Arm",
    Right_arm = "Right Arm",
    Left_leg  = "Left Leg",
    Right_leg = "Right Leg",
}


local SKYBOX_URL = BASE .. "games/mohg/skyboxes/loader.lua"

local SKYBOXES = {}
task.spawn(function()
    local ok, src = pcall(function() return game:HttpGet(SKYBOX_URL) end)
    if not ok or not src or #src == 0 then
        warn("[Universal] failed to fetch skyboxes")
        return
    end
    local ok2, data = pcall(function() return loadstring(src)() end)
    if ok2 and type(data) == "table" then
        SKYBOXES = data
    else
        warn("[Universal] failed to parse skybox data")
    end
end)


local CONFIG_FOLDER = "MOHG/UNIVERSAL/CONFIG"

if not isfolder("MOHG") then makefolder("MOHG") end
if not isfolder("MOHG/UNIVERSAL") then makefolder("MOHG/UNIVERSAL") end
if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end


local configPath = function(name)
    local safe = tostring(name):gsub("[^%w_%-%. ]", "_")
    if safe == "" then safe = "unnamed" end
    return CONFIG_FOLDER .. "/cfg_" .. safe .. ".json"
end

local configExists = function(name)
    return isfile(configPath(name))
end

local saveConfigToDisk = function(name, data)
    local ok, encoded = pcall(function()
        return Services.HttpService:JSONEncode(data)
    end)
    if not ok or not encoded then return false, "encode failed" end
    local writeOk, err = pcall(function() writefile(configPath(name), encoded) end)
    if not writeOk then return false, tostring(err) end
    return true
end

local loadConfigFromDisk = function(name)
    local path = configPath(name)
    if not isfile(path) then return nil, "no such profile" end
    local readOk, raw = pcall(function() return readfile(path) end)
    if not readOk or not raw or #raw == 0 then return nil, "read failed" end
    local decodeOk, decoded = pcall(function() return Services.HttpService:JSONDecode(raw) end)
    if not decodeOk or type(decoded) ~= "table" then return nil, "decode failed" end
    return decoded
end

local listConfigsOnDisk = function()
    local out = {}
    local ok, files = pcall(function() return listfiles(CONFIG_FOLDER) end)
    if not ok or type(files) ~= "table" then return out end
    for _, path in ipairs(files) do
        local name = path:match("cfg_([^/\\]+)%.json$")
        if name then table.insert(out, name) end
    end
    table.sort(out)
    return out
end

local deleteConfigFromDisk = function(name)
    local path = configPath(name)
    if not isfile(path) then return false end
    return pcall(function() delfile(path) end)
end

local ProfileSave = function(name)
    if not name or name == "" then return false, "empty name" end
    local data = Window:GetConfig()
    return saveConfigToDisk(name, data)
end

local ProfileLoad = function(name)
    if not name or name == "" then return false, "empty name" end
    local data, err = loadConfigFromDisk(name)
    if not data then return false, err end
    Window:LoadConfig(data, true)
    return true
end

local ProfileList = function() return listConfigsOnDisk() end

local ProfileDelete = function(name) return deleteConfigFromDisk(name) end

local ProfileExists = function(name) return configExists(name) end


ENV.CONFIG = ENV.CONFIG or (function()
    return {
        mobileMode = (function()
            local uis = Services.UserInputService
            return uis.TouchEnabled and not uis.KeyboardEnabled
        end)(),

        aimbotTargetPart    = "Torso",
        checkTeam           = false,
        selectType          = "closest",
        FOVRadius           = 90,
        showFOVCircle       = false,
        fovCircleRGB        = true,
        fovCircleColor      = Color3.new(1, 0, 0),
        fovCircleAlpha      = 0.7,
        smoothing           = 0.2,
        maxDistance         = 650,
        checkDistance       = true,
        aimbotEnabled       = false,
        rageMode            = false,
        jitterEnabled       = false,
        jitterAmount        = 0.35,
        jitterSpeed         = 12,
        jitterMode          = "Random",
        camWriterMaxStep    = 2.5,
        camWriterBudget     = 5,
        triggerbotEnabled   = false,
        triggerDelay        = 0.05,
        triggerOnZoomOnly   = false,
        mobileTriggerRadius = 25,
        autoClickEnabled    = false,
        autoClickDelay      = 0.1,
        autoClickHoldTime   = 0.02,
        autoClickOnlyZoom   = false,
        noArms              = true,
        trailEnabled        = false,
        trailColorMode      = "Solid",
        trailColor          = Color3.fromRGB(255, 50, 50),
        trailWidth          = 0.2,
        trailLifetime       = 0.25,
        trailMinLength      = 0.1,
        espEnabled          = false,
        espBoxes            = true,
        espNames            = true,
        espHealth           = true,
        espDistance         = true,
        espTeamColors       = true,
        espTransparency     = 0.3,
        espTracers          = false,
        espColor            = Color3.new(1, 1, 1),
        espRainbow          = true,
        espMaxDistance      = 700,
        espStatusIcons      = true,
        espStatusText       = true,
        espWeaponName       = true,
        speedEnabled        = false,
        speedSpeed          = 18,
        jumpEnabled         = false,
        jumpPower           = 50,
        spinEnabled         = false,
        spinSpeed           = 20,
        tpWalkEnabled       = false,
        tpWalkSpeed         = 30,
        bhopEnabled         = false,
        bhopInterval        = 0.1,
        noclipEnabled       = false,
        spinEngineSpeed     = 99999,
        flingMode           = "auto",
        flingGap            = 0.8,
        fullBright          = false,
        queueTeleport = false,
    }
end)()

ENV.__beamHue = ENV.__beamHue or 0

local success, uisrc = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/kio6z/Azurite/refs/heads/main/library/azulib.lua")
end)

if success and uisrc then
    pcall(function()
        UILib = loadstring(uisrc)()
        writefile("azulib.lua", tostring(uisrc))
    end)
end

if not UILib then
    if isfile("azulib.lua") then
        UILib = loadstring(readfile("azulib.lua"))()
    end
end

if not UILib then
    warn("Failed to load azulib!")
    return
end

Window = UILib:Window({
    Title    = "Mohg",
    Subtitle = "Private",
    AutoSave = true,
})


local regToggle = function(group, name, flag, cfgKey)
    return group:Toggle(name, ENV.CONFIG[cfgKey or flag], function(v)
        ENV.CONFIG[cfgKey or flag] = v
    end, { Flag = flag })
        :OnEnabled(function() Window:Notify(name .. " enabled!", NS) end)
        :OnDisabled(function() Window:Notify(name .. " disabled!", NW) end)
end

API.joinDiscord = function(invite)
    task.spawn(function()
        pcall(function()
            request({
                Url = "http://127.0.0.1:6463/rpc",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    args = {
                        code = invite
                    },
                    nonce = Services.HttpService:GenerateGUID(false)
                })
            })
        end)
    end)
end

API.shouldPromptDiscord = function()
    local PROMPT_INTERVAL = 3 * 24 * 60 * 60
    if not isfile("MOHG/discord_prompt.json") then
        return true
    end

    local ok, data = pcall(readfile, "MOHG/discord_prompt.json")
    if not ok then return true end

    local ok2, json = pcall(Services.HttpService.JSONDecode, Services.HttpService, data)
    if not ok2 then return true end

    local lastPrompt = json.lastPrompted or 0
    return (os.time() - lastPrompt) >= PROMPT_INTERVAL
end

if API.shouldPromptDiscord() then
    API.joinDiscord("Pee57xu9w4")
    writefile(
        "MOHG/discord_prompt.json",
        Services.HttpService:JSONEncode({
            lastPrompted = os.time(),
            invite = "Pee57xu9w4"
        })
    )
end

API.getChar = function(plr)
    if not plr then return nil end
    if plr:IsA("Player") then return plr.Character end
    if plr:IsA("Model") then return plr end
    return nil
end

API.getRoot = function(plr)
    local char = API.getChar(plr)
    if not char then return nil end
    return char:FindFirstChild(HRP)
        or char:FindFirstChild("Torso")
        or char.PrimaryPart
end

API.getHum = function(plr)
    local char = API.getChar(plr)
    if not char then return nil end
    return char:FindFirstChildWhichIsA("Humanoid")
end

API.getLimbMap = function(plr)
    local hum = API.getHum(plr)
    if not hum then return nil end
    return hum.RigType == Enum.HumanoidRigType.R6 and RigTypes.R6 or RigTypes.R15
end

API.getTorso = function(char)
    char = char or API.getChar(Player.Local)
    if not char then return nil end
    local limbMap = API.getLimbMap(Player.Local)
    local names = limbMap and (limbMap["Torso"] or limbMap["UpperTorso"])
    if not names then return nil end
    for _, name in ipairs(names) do
        local part = char:FindFirstChild(name)
        if part then return part end
    end
    return nil
end


API.getPlayerById = function(userId)
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.UserId == userId then return player end
    end
    return nil
end

API.matchesShieldName = function(name)
    if not name or name == "" then return false end
    local lower = string.lower(name)
    for i = 1, #SHIELD_NAME_PATTERNS do
        if string.find(lower, SHIELD_NAME_PATTERNS[i], 1, true) then
            return true
        end
    end
    return false
end

API.findOwnerCharacter = function(instance)
    local node = instance
    while node do
        if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then
            return node
        end
        node = node.Parent
    end
    return nil
end

API.registerShield = function(parent, childName)
    if not parent then return end
    local char = API.findOwnerCharacter(parent)
    if not char then return end
    FORCEFIELD[char] = { parent = parent, name = childName }
end

API.unregisterShield = function(parent, childName)
    if not parent then return end
    local char = API.findOwnerCharacter(parent)
    if not char then return end
    local entry = FORCEFIELD[char]
    if entry and entry.parent == parent and entry.name == childName then
        FORCEFIELD[char] = nil
    end
end

API.initialShieldScan = function(char)
    if not char or not char.Parent then return end
    for _, d in ipairs(char:GetDescendants()) do
        if API.matchesShieldName(d.Name) and d.Parent then
            API.registerShield(d.Parent, d.Name)
            return
        end
    end
end

API.watchCharacterShields = function(char)
    if not char then return end
    if SKIP_SELF and char == Player.Local.Character then return end
    if CHAR_WATCHERS[char] then return end

    local conns = {}

    table.insert(conns, char.DescendantAdded:Connect(function(instance)
        if not API.matchesShieldName(instance.Name) then return end
        if instance.Parent then
            API.registerShield(instance.Parent, instance.Name)
        end
    end))

    table.insert(conns, char.DescendantRemoving:Connect(function(instance)
        if not API.matchesShieldName(instance.Name) then return end
        if instance.Parent then
            API.unregisterShield(instance.Parent, instance.Name)
        end
    end))

    table.insert(conns, char.Destroying:Connect(function()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        CHAR_WATCHERS[char] = nil
        FORCEFIELD[char]    = nil
    end))

    CHAR_WATCHERS[char] = conns

    task.spawn(function()
        for _ = 1, 3 do
            if not char.Parent then return end
            if FORCEFIELD[char] then return end
            API.initialShieldScan(char)
            task.wait(1)
        end
    end)
end

API.attachShieldWatcher = function(plr)
    if SKIP_SELF and plr == Player.Local then return end
    if plr.Character then API.watchCharacterShields(plr.Character) end
    plr.CharacterAdded:Connect(API.watchCharacterShields)
end

for _, plr in ipairs(Services.Players:GetPlayers()) do
    API.attachShieldWatcher(plr)
end
Services.Players.PlayerAdded:Connect(API.attachShieldWatcher)

API.isAlive = function(plr)
    local hum = API.getHum(plr)
    return hum ~= nil and hum.Health > 0
end

API.isImmune = function(plr)
    if not plr then return true end
    if not plr:IsA("Player") then return false end

    local char = API.getChar(plr)
    if not char then return true end

    if char:FindFirstChildOfClass("ForceField") then return true end

    local entry = FORCEFIELD[char]
    if entry and entry.parent:FindFirstChild(entry.name) then
        return true
    end

    if char:GetAttribute("Immune")         then return true end
    if char:GetAttribute("InSafeZone")     then return true end
    if char:GetAttribute("SpawnProtected") then return true end
    if char:GetAttribute("Invulnerable")   then return true end

    return false
end

API.isEnemy = function(plr)
    if not plr then return false end
    if not plr:IsA("Player") then return true end
    if plr.UserId == API.getMyUserId() then return false end
    if not ENV.CONFIG.checkTeam then return true end
    local myTeam, theirTeam = Player.Local.Team, plr.Team
    if not myTeam or not theirTeam then return true end
    return theirTeam ~= myTeam
end

API.isPlayerAfk = function(player, timeout)
    local startRoot = API.getRoot(player)
    if not startRoot then return true end
    local startPos = startRoot.Position
    while os.time() < timeout do
        task.wait(1)
        if not player.Parent then return true end
        local root = API.getRoot(player)
        if not root then return true end
        if (root.Position - startPos).Magnitude > 1 then return false end
    end
    return true
end


API.pickNamedPart = function(char, partName)
    if not char or not partName then
        return char and char:FindFirstChild("Head") or nil
    end
    local plr = Services.Players:GetPlayerFromCharacter(char)
    local limbMap = plr and API.getLimbMap(plr) or nil
    if not limbMap then return char:FindFirstChild("Head") end
    partName = ({ Left_arm="Left Arm", Right_arm="Right Arm", Left_leg="Left Leg", Right_leg="Right Leg" })[partName] or partName
    local partNames = limbMap[partName] or limbMap["Torso"]
    for _, name in ipairs(partNames) do
        local part = char:FindFirstChild(name)
        if part then return part end
    end
    return char:FindFirstChild("Head")
end

API.getTargetPart = function(plr)
    local char = API.getChar(plr)
    if not char then return nil end
    return API.pickNamedPart(char, ENV.CONFIG.aimbotTargetPart)
end


API.moveTo = function(targetPos, distance, timeout, shouldJump)
    distance = distance or 5
    timeout  = timeout  or 8

    local char  = API.getChar(Player.Local)
    local hum   = API.getHum(Player.Local)
    local root  = API.getRoot(Player.Local)
    if not char or not hum or not root then return false end

    if shouldJump then
        task.wait(1)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    local start = os.clock()
    while char.Parent and hum.Health > 0 do
        hum:MoveTo(targetPos)
        if (root.Position - targetPos).Magnitude <= distance then return true end
        if os.clock() - start >= timeout then return false end
        task.wait(0.1)
    end
    return false
end


API.TRAIL_NAME = "MOHG_TRAIL"
API.TRAIL_ATT0 = "MOHG_TRAIL_ATT0"
API.TRAIL_ATT1 = "MOHG_TRAIL_ATT1"
API.trailHue   = 0

API.buildRainbowSequence = function(animated)
    if animated then
        local h = (API.trailHue or 0) % 1
        return ColorSequence.new(Color3.fromHSV(h, 1, 1), Color3.fromHSV((h+0.15)%1, 1, 1))
    end
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0,   0)),
        ColorSequenceKeypoint.new(1/7,  Color3.fromRGB(255, 136, 0)),
        ColorSequenceKeypoint.new(2/7,  Color3.fromRGB(255, 228, 17)),
        ColorSequenceKeypoint.new(3/7,  Color3.fromRGB(135, 255, 7)),
        ColorSequenceKeypoint.new(4/7,  Color3.fromRGB(11,  255, 207)),
        ColorSequenceKeypoint.new(5/7,  Color3.fromRGB(10,  46,  255)),
        ColorSequenceKeypoint.new(6/7,  Color3.fromRGB(255, 55,  255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(170, 0,   127)),
    }
end

API.removeTrail = function(char)
    char = char or API.getChar(Player.Local)
    if not char then return end
    local torso = API.getTorso(char)
    if not torso then return end
    local trail = torso:FindFirstChild(API.TRAIL_NAME)
    if trail then trail:Destroy() end
    local a0 = torso:FindFirstChild(API.TRAIL_ATT0); if a0 then a0:Destroy() end
    local a1 = torso:FindFirstChild(API.TRAIL_ATT1); if a1 then a1:Destroy() end
end

API.applyTrail = function(char)
    char = char or API.getChar(Player.Local)
    if not char then return end
    local torso = API.getTorso(char)
    if not torso or not torso:IsA("BasePart") then return end
    API.removeTrail(char)

    local half = (ENV.CONFIG.trailWidth or 0.2) / 2
    local att0 = Instance.new("Attachment"); att0.Name=API.TRAIL_ATT0; att0.Position=Vector3.new(0, half, 0); att0.Parent=torso
    local att1 = Instance.new("Attachment"); att1.Name=API.TRAIL_ATT1; att1.Position=Vector3.new(0,-half, 0); att1.Parent=torso

    local mode     = ENV.CONFIG.trailColorMode or "Solid"
    local colorSeq = mode == "Solid"
        and ColorSequence.new(ENV.CONFIG.trailColor or Color3.new(1,1,1))
        or  API.buildRainbowSequence(mode == "Rainbow (Animated)")

    local trail         = Instance.new("Trail")
    trail.Name          = API.TRAIL_NAME
    trail.Attachment0   = att0
    trail.Attachment1   = att1
    trail.Color         = colorSeq
    trail.Lifetime      = ENV.CONFIG.trailLifetime  or 0.25
    trail.MinLength     = ENV.CONFIG.trailMinLength or 0.1
    trail.LightEmission = 1
    trail.LightInfluence= 0
    trail.FaceCamera    = true
    trail.Parent        = torso
    return trail
end

API.refreshTrail = function()
    local char = API.getChar(Player.Local)
    if not char then return end
    if ENV.CONFIG.trailEnabled then API.applyTrail(char) else API.removeTrail(char) end
end


API.applySkybox = function(preset)
    if not preset then return end
    local lighting = Services.Lighting
    if not ENV.CONFIG.__originalSky then
        local existing = lighting:FindFirstChildOfClass("Sky")
        ENV.CONFIG.__originalSky = {
            hadSky         = existing ~= nil,
            SkyboxBk       = existing and existing.SkyboxBk,
            SkyboxDn       = existing and existing.SkyboxDn,
            SkyboxFt       = existing and existing.SkyboxFt,
            SkyboxLf       = existing and existing.SkyboxLf,
            SkyboxRt       = existing and existing.SkyboxRt,
            SkyboxUp       = existing and existing.SkyboxUp,
            StarCount      = existing and existing.StarCount,
            SunAngularSize = existing and existing.SunAngularSize,
            MoonAngularSize= existing and existing.MoonAngularSize,
            SunTextureId   = existing and existing.SunTextureId,
            MoonTextureId  = existing and existing.MoonTextureId,
        }
    end
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then sky = Instance.new("Sky"); sky.Parent = lighting end
    sky.SkyboxBk = preset.SkyboxBk or ""
    sky.SkyboxDn = preset.SkyboxDn or ""
    sky.SkyboxFt = preset.SkyboxFt or ""
    sky.SkyboxLf = preset.SkyboxLf or ""
    sky.SkyboxRt = preset.SkyboxRt or ""
    sky.SkyboxUp = preset.SkyboxUp or ""
    if preset.StarCount       ~= nil then sky.StarCount       = preset.StarCount end
    if preset.SunAngularSize  ~= nil then sky.SunAngularSize  = preset.SunAngularSize end
    if preset.MoonAngularSize ~= nil then sky.MoonAngularSize = preset.MoonAngularSize end
    if preset.SunTextureId    ~= nil then sky.SunTextureId    = preset.SunTextureId end
    if preset.MoonTextureId   ~= nil then sky.MoonTextureId   = preset.MoonTextureId end
end

API.restoreSkybox = function()
    local original = ENV.CONFIG.__originalSky
    if not original then return end
    local lighting = Services.Lighting
    local sky      = lighting:FindFirstChildOfClass("Sky")
    if not original.hadSky then
        if sky then sky:Destroy() end
    elseif sky then
        sky.SkyboxBk        = original.SkyboxBk        or ""
        sky.SkyboxDn        = original.SkyboxDn        or ""
        sky.SkyboxFt        = original.SkyboxFt        or ""
        sky.SkyboxLf        = original.SkyboxLf        or ""
        sky.SkyboxRt        = original.SkyboxRt        or ""
        sky.SkyboxUp        = original.SkyboxUp        or ""
        sky.StarCount       = original.StarCount        or 3000
        sky.SunAngularSize  = original.SunAngularSize   or 21
        sky.MoonAngularSize = original.MoonAngularSize  or 11
        sky.SunTextureId    = original.SunTextureId     or ""
        sky.MoonTextureId   = original.MoonTextureId    or ""
    end
    ENV.CONFIG.__originalSky = nil
end


API.setupSpin = function()
    task.spawn(function()
        while task.wait() do
            if not ENV.CONFIG.spinEnabled then break end
            local hrp = API.getRoot(Player.Local); if not hrp then break end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(ENV.CONFIG.spinSpeed % 150), 0)
        end
    end)
end

API.startTpWalk = function()
    API.unc(ENV.CONNS, "tpWalkConn")
    ENV.CONNS.tpWalkConn = Services.RunService.Heartbeat:Connect(function()
        if not ENV.CONFIG.tpWalkEnabled then return end

        local char = API.getChar(Player.Local)
        if not char then return end
        local hum  = API.getHum(Player.Local)
        local root = API.getRoot(Player.Local)
        if not hum or not root then return end
        if hum.Health <= 0 or hum.Sit then return end
        if hum.MoveDirection.Magnitude <= 0.01 then return end

        local speed = ENV.CONFIG.tpWalkSpeed or 30
        root.AssemblyLinearVelocity = Vector3.new(
            hum.MoveDirection.X * speed,
            root.AssemblyLinearVelocity.Y,
            hum.MoveDirection.Z * speed
        )
    end)
end

API.startBhop = function()
    API.unc(ENV.CONNS, "bhopConn")
    local lastJump = 0
    ENV.CONNS.bhopConn = Services.RunService.Heartbeat:Connect(function()
        if not ENV.CONFIG.bhopEnabled then return end

        local hum = API.getHum(Player.Local)
        if not hum or hum.Health <= 0 or hum.Sit then return end

        local now = os.clock()
        if now - lastJump < (ENV.CONFIG.bhopInterval or 0.1) then return end

        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Landed
           or state == Enum.HumanoidStateType.Running
           or state == Enum.HumanoidStateType.RunningNoPhysics then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            lastJump = now
        end
    end)
end

API.stopBhop = function()
    API.unc(ENV.CONNS, "bhopConn")
end

API.stopTpWalk = function()
    API.unc(ENV.CONNS, "tpWalkConn")
    local root = API.getRoot(Player.Local)
    if root then root.AssemblyLinearVelocity = Vector3.zero end
end

local FOVState = {
    drawContainer = nil,
    circle        = nil,
    hueOffset     = 0,
}

API.protectAndParentFOVCircle = function(gui)
    local gethui       = gethui or get_hidden_gui
    local protect_gui  = (syn and syn.protect_gui) or protect_gui
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return true end
    end
    if protect_gui then
        local ok = pcall(function() protect_gui(gui); gui.Parent = Services.CoreGui end)
        if ok and gui.Parent then return true end
    end
    pcall(function() gui.Parent = Services.CoreGui end)
    return gui.Parent ~= nil
end

API.getDrawContainer = function()
    if FOVState.drawContainer then return FOVState.drawContainer end
    local gui = Instance.new("ScreenGui")
    gui.Name           = "DrawContainer"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    API.protectAndParentFOVCircle(gui)
    FOVState.drawContainer = gui
    return gui
end

API.createFOVCircle = function()
    local screenGui = API.getDrawContainer()
    local fovCircle = Instance.new("Frame")
    fovCircle.Name                 = "FOVCircle"
    fovCircle.Size                 = UDim2.new(0,0,0,0)
    fovCircle.Position             = UDim2.new(0.5,0,0.5,0)
    fovCircle.AnchorPoint          = Vector2.new(0.5,0.5)
    fovCircle.BackgroundColor3     = Color3.fromRGB(0,255,0)
    fovCircle.BackgroundTransparency = 0.7
    fovCircle.BorderSizePixel      = 0
    fovCircle.Parent               = screenGui
    local corner  = Instance.new("UICorner");  corner.CornerRadius = UDim.new(1,0); corner.Parent = fovCircle
    local stroke  = Instance.new("UIStroke");  stroke.Color = Color3.fromRGB(0,255,0); stroke.Thickness = 2; stroke.Parent = fovCircle
    return fovCircle
end

FOVState.circle = API.createFOVCircle()


local Cursor = {
    pos = Vector2.zero,
    vp  = Vector2.zero,
}

local function refreshViewport()
    Cursor.vp = Player.Camera.ViewportSize
    if Cursor.pos == Vector2.zero then
        Cursor.pos = Vector2.new(Cursor.vp.X/2, Cursor.vp.Y/2)
    end
end
refreshViewport()
Player.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshViewport)

Services.RunService.RenderStepped:Connect(function()
    local mb = Services.UserInputService.MouseBehavior
    if mb == Enum.MouseBehavior.LockCenter
       or mb == Enum.MouseBehavior.LockCurrentPosition then
        Cursor.pos = Vector2.new(Cursor.vp.X/2, Cursor.vp.Y/2)
    else
        local loc = Services.UserInputService:GetMouseLocation()
        Cursor.pos = Vector2.new(
            math.clamp(loc.X, 0, Cursor.vp.X),
            math.clamp(loc.Y, 0, Cursor.vp.Y)
        )
    end
end)

API.getCursorPos = function()
    return Cursor.pos
end

API.getAimReferencePoint = function()
    return API.getCursorPos()
end


local ESPFont = Enum.Font.Gotham

local ESPState = {
    playerCharConns = {},
    renderLoop      = nil,
    root            = nil,
    pools           = { boxes = {} },
    PlayerRegistry  = {},
}

API.espParentGui = function(gui)
    local gethui      = gethui or get_hidden_gui
    local protect_gui = (syn and syn.protect_gui) or protect_gui
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return true end
    end
    if protect_gui then
        local ok = pcall(function() protect_gui(gui); gui.Parent = Services.CoreGui end)
        if ok and gui.Parent then return true end
    end
    pcall(function() gui.Parent = Services.CoreGui end)
    return gui.Parent ~= nil
end

API.espGetRoot = function()
    if ESPState.root and ESPState.root.Parent then return ESPState.root end
    local gui = Instance.new("ScreenGui")
    gui.Name           = "UniversalESP"
    gui.ResetOnSpawn   = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder   = 999
    API.espParentGui(gui)
    ESPState.root = gui
    return gui
end

API.espProjectBox = function(model, out)
    local root = model:FindFirstChild(HRP) or model:FindFirstChild("Torso")
    if not root then return nil end
    local pos = root.Position
    local screenMid, midOnScreen = Player.Camera:WorldToViewportPoint(pos)
    if not midOnScreen or screenMid.Z <= 0 then return nil end
    local screenTop, topOnScreen = Player.Camera:WorldToViewportPoint(Vector3.new(pos.X, pos.Y+2.8, pos.Z))
    local screenBot, botOnScreen = Player.Camera:WorldToViewportPoint(Vector3.new(pos.X, pos.Y-2.8, pos.Z))
    if not topOnScreen and not botOnScreen then return nil end
    local sMinY = math.min(screenTop.Y, screenBot.Y)
    local sMaxY = math.max(screenTop.Y, screenBot.Y)
    local h = sMaxY - sMinY
    local w = h * 0.4
    local r = out or {}
    r.x = screenMid.X - w/2; r.y = sMinY; r.w = w; r.h = h
    return r
end

API.espResolveColor = function(plr, override)
    if override then return override end
    if ENV.CONFIG.espRainbow then
        return Color3.fromHSV((FOVState.hueOffset or 0) % 1, 0.8, 1)
    end
    if ENV.CONFIG.espTeamColors and plr and Player.Local.Team then
        if plr.Team == Player.Local.Team then return Color3.fromRGB(80,180,255) end
    end
    return ENV.CONFIG.espColor or Color3.new(1,1,1)
end

API.espBuildBundle = function()
    local parent = API.espGetRoot()

    local box = Instance.new("Frame")
    box.BackgroundTransparency=1; box.BorderSizePixel=0; box.Visible=false; box.ZIndex=2; box.Parent=parent
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness=2; boxStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; boxStroke.Parent=box

    local function makeLabel(size)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency=1; l.TextColor3=Color3.new(1,1,1)
        l.TextStrokeTransparency=0; l.TextStrokeColor3=Color3.new(0,0,0)
        l.Font=ESPFont; l.TextSize=size; l.TextXAlignment=Enum.TextXAlignment.Center
        l.TextYAlignment=Enum.TextYAlignment.Bottom; l.Visible=false; l.ZIndex=3; l.Parent=parent
        return l
    end

    local nameLabel   = makeLabel(13)
    local weaponLabel = makeLabel(11)
    local infoLabel   = makeLabel(11)

    local healthBG = Instance.new("Frame")
    healthBG.BackgroundColor3=Color3.fromRGB(20,20,20); healthBG.BackgroundTransparency=0.25
    healthBG.BorderSizePixel=0; healthBG.Visible=false; healthBG.ZIndex=2; healthBG.Parent=parent

    local healthFill = Instance.new("Frame")
    healthFill.BackgroundColor3=Color3.fromRGB(0,255,0); healthFill.BorderSizePixel=0
    healthFill.AnchorPoint=Vector2.new(0,1); healthFill.Visible=false; healthFill.ZIndex=3; healthFill.Parent=healthBG

    local statusIcons = Instance.new("Frame")
    statusIcons.BackgroundTransparency=1; statusIcons.Size=UDim2.fromOffset(0,0)
    statusIcons.Visible=false; statusIcons.ZIndex=3; statusIcons.Parent=parent

    local iconSlots = {}
    for i = 1, 6 do
        local icon = Instance.new("ImageLabel")
        icon.Size=UDim2.fromOffset(16,16); icon.BackgroundTransparency=1
        icon.ImageColor3=Color3.new(1,1,1); icon.ScaleType=Enum.ScaleType.Fit
        icon.Visible=false; icon.ZIndex=3; icon.Parent=statusIcons
        local text = Instance.new("TextLabel")
        text.BackgroundTransparency=1; text.TextColor3=Color3.new(1,1,1)
        text.TextStrokeTransparency=0; text.TextStrokeColor3=Color3.new(0,0,0)
        text.Font=ESPFont; text.TextSize=11; text.TextXAlignment=Enum.TextXAlignment.Left
        text.TextYAlignment=Enum.TextYAlignment.Center; text.Visible=false; text.ZIndex=3; text.Parent=statusIcons
        iconSlots[i] = { icon=icon, text=text }
    end

    local tracer = Instance.new("Frame")
    tracer.BackgroundColor3=Color3.new(1,1,1); tracer.BorderSizePixel=0
    tracer.AnchorPoint=Vector2.new(0.5,0); tracer.Visible=false; tracer.ZIndex=1; tracer.Parent=parent

    return {
        box=box, boxStroke=boxStroke, nameLabel=nameLabel, weaponLabel=weaponLabel,
        infoLabel=infoLabel, healthBG=healthBG, healthFill=healthFill,
        statusIcons=statusIcons, iconSlots=iconSlots, tracer=tracer,
        _lastName=nil, _lastWeapon=nil, _lastInfo=nil,
    }
end

API.espAcquireBundle = function()
    local pooled = table.remove(ESPState.pools.boxes)
    if pooled then
        local parent = API.espGetRoot()
        pooled.box.Parent=parent; pooled.nameLabel.Parent=parent; pooled.weaponLabel.Parent=parent
        pooled.infoLabel.Parent=parent; pooled.healthBG.Parent=parent
        pooled.statusIcons.Parent=parent; pooled.tracer.Parent=parent
        return pooled
    end
    return API.espBuildBundle()
end

API.espHideBundle = function(bundle)
    if bundle._hidden then return end
    bundle._hidden=true
    bundle.box.Visible=false; bundle.nameLabel.Visible=false; bundle.weaponLabel.Visible=false
    bundle.infoLabel.Visible=false; bundle.healthBG.Visible=false; bundle.healthFill.Visible=false
    bundle.statusIcons.Visible=false; bundle.tracer.Visible=false
    for _, slot in ipairs(bundle.iconSlots) do slot.icon.Visible=false; slot.text.Visible=false end
end

local ESP_MAX_POOL = 64
API.espReleaseBundle = function(bundle)
    API.espHideBundle(bundle)
    if #ESPState.pools.boxes >= ESP_MAX_POOL then
        bundle.box:Destroy(); bundle.nameLabel:Destroy(); bundle.weaponLabel:Destroy()
        bundle.infoLabel:Destroy(); bundle.healthBG:Destroy(); bundle.statusIcons:Destroy(); bundle.tracer:Destroy()
        return
    end
    bundle.box.Parent=nil; bundle.nameLabel.Parent=nil; bundle.weaponLabel.Parent=nil
    bundle.infoLabel.Parent=nil; bundle.healthBG.Parent=nil; bundle.statusIcons.Parent=nil; bundle.tracer.Parent=nil
    table.insert(ESPState.pools.boxes, bundle)
end

local espDrawBundle = function(bundle, rect, hum, plr, label, dist, color)
    local cfg  = ENV.CONFIG
    local char = hum.Parent
    bundle._hidden = false
    if bundle._owner ~= char then
        bundle._owner=char; bundle._slowT=nil; bundle._weaponName=nil; bundle._active=nil; bundle._infoD=nil
    end
    if not bundle._anchored then
        local a = Vector2.new(0.5,1)
        bundle.nameLabel.AnchorPoint=a; bundle.weaponLabel.AnchorPoint=a; bundle.infoLabel.AnchorPoint=a
        bundle._anchored=true
    end

    local BASE_DIST=50; local MIN_SCALE=0.7; local MAX_SCALE=1.6
    local scale = math.clamp(BASE_DIST / math.max(dist,5), MIN_SCALE, MAX_SCALE)
    local nameTextSize   = math.max(8,  math.floor(13 * scale))
    local weaponTextSize = math.max(7,  math.floor(11 * scale))
    local infoTextSize   = math.max(7,  math.floor(11 * scale))
    local iconSize       = math.max(10, math.floor(16 * scale))

    local now = os.clock()
    local slowTick = (not bundle._slowT) or (now - bundle._slowT) >= 0.1
    if slowTick then bundle._slowT = now end

    local weaponName = nil
    if cfg.espWeaponName and char then
        if slowTick then
            local tool = char:FindFirstChildWhichIsA("Tool")
            bundle._weaponName = tool and tool.Name or false
        end
        weaponName = bundle._weaponName or nil
    end

    if cfg.espBoxes then
        bundle.box.Visible=true
        bundle.box.Position=UDim2.fromOffset(rect.x, rect.y)
        bundle.box.Size=UDim2.fromOffset(rect.w, rect.h)
        if bundle._boxCol ~= color then bundle.boxStroke.Color=color; bundle._boxCol=color end
        local boxTr = cfg.espTransparency or 0.15
        if bundle._boxTr ~= boxTr then bundle.boxStroke.Transparency=boxTr; bundle._boxTr=boxTr end
    else
        bundle.box.Visible=false
    end

    local NAME_H=nameTextSize+2; local WEAPON_H=weaponTextSize+2; local INFO_H=infoTextSize+2
    local GAP=2; local BOX_GAP=4
    local stackBottom = rect.y - BOX_GAP

    if cfg.espNames and label then
        if bundle._lastName ~= label then bundle.nameLabel.Text=label; bundle._lastName=label end
        local nameY = stackBottom - INFO_H - GAP - (weaponName and (WEAPON_H+GAP) or 0)
        if bundle._nameTS ~= nameTextSize then bundle.nameLabel.TextSize=nameTextSize; bundle._nameTS=nameTextSize end
        bundle.nameLabel.Size=UDim2.fromOffset(math.max(#label*(nameTextSize*0.55)+12, rect.w), NAME_H)
        bundle.nameLabel.Position=UDim2.new(0, rect.x+rect.w/2, 0, nameY)
        if bundle._nameCol ~= color then bundle.nameLabel.TextColor3=color; bundle._nameCol=color end
        bundle.nameLabel.Visible=true
    else
        bundle.nameLabel.Visible=false
    end

    if weaponName then
        if bundle._lastWeapon ~= weaponName then bundle.weaponLabel.Text=weaponName; bundle._lastWeapon=weaponName end
        local weaponY = stackBottom - INFO_H - GAP
        if bundle._weaponTS ~= weaponTextSize then bundle.weaponLabel.TextSize=weaponTextSize; bundle._weaponTS=weaponTextSize end
        bundle.weaponLabel.Size=UDim2.fromOffset(math.max(#weaponName*(weaponTextSize*0.55)+12, rect.w), WEAPON_H)
        bundle.weaponLabel.Position=UDim2.new(0, rect.x+rect.w/2, 0, weaponY)
        if bundle._weaponCol ~= color then bundle.weaponLabel.TextColor3=color; bundle._weaponCol=color end
        bundle.weaponLabel.Visible=true
    else
        bundle.weaponLabel.Visible=false
    end

    local fd=math.floor(dist); local hp,mhp=hum.Health, hum.MaxHealth
    local infoStr
    if bundle._infoD==fd and bundle._infoH==hp and bundle._infoM==mhp
       and bundle._infoCD==cfg.espDistance and bundle._infoCH==cfg.espHealth then
        infoStr = bundle._infoStr
    else
        local infoParts = {}
        if cfg.espDistance then infoParts[#infoParts+1] = "["..fd.."m]" end
        if cfg.espHealth   then
            local hStr = hp>mhp and "inf" or tostring(math.floor(hp))
            local mStr = hp>mhp and "inf" or tostring(math.floor(mhp))
            infoParts[#infoParts+1] = "["..hStr.."/"..mStr.."]"
        end
        infoStr = table.concat(infoParts, " ")
        bundle._infoD,bundle._infoH,bundle._infoM=fd,hp,mhp
        bundle._infoCD,bundle._infoCH=cfg.espDistance,cfg.espHealth
        bundle._infoStr=infoStr
    end

    if infoStr ~= "" then
        if bundle._lastInfo ~= infoStr then bundle.infoLabel.Text=infoStr; bundle._lastInfo=infoStr end
        if bundle._infoTS ~= infoTextSize then bundle.infoLabel.TextSize=infoTextSize; bundle._infoTS=infoTextSize end
        bundle.infoLabel.Size=UDim2.fromOffset(math.max(#infoStr*(infoTextSize*0.55)+12, rect.w), INFO_H)
        bundle.infoLabel.Position=UDim2.new(0, rect.x+rect.w/2, 0, stackBottom)
        if not bundle._infoWhite then bundle.infoLabel.TextColor3=Color3.new(1,1,1); bundle._infoWhite=true end
        bundle.infoLabel.Visible=true
    else
        bundle.infoLabel.Visible=false
    end

    if cfg.espHealth then
        local maxH = math.max(mhp,1)
        local ratio = hp>mhp and 1 or math.clamp(hp/maxH, 0, 1)
        local barX  = rect.x - 6
        bundle.healthBG.Visible=true; bundle.healthBG.Position=UDim2.fromOffset(barX, rect.y); bundle.healthBG.Size=UDim2.fromOffset(3, rect.h)
        bundle.healthFill.Visible=true
        local over = hp > mhp
        if bundle._hpRatio ~= ratio or bundle._hpOver ~= over then
            bundle._hpRatio=ratio; bundle._hpOver=over
            bundle.healthFill.Position=UDim2.new(0,0,1,0); bundle.healthFill.Size=UDim2.new(1,0,ratio,0)
            bundle.healthFill.BackgroundColor3 = over and Color3.fromRGB(255,215,0) or Color3.new(1,0,0):Lerp(Color3.new(0,1,0), ratio)
        end
    else
        bundle.healthBG.Visible=false; bundle.healthFill.Visible=false
    end

    if cfg.espStatusIcons and char then
        local active = bundle._active
        if slowTick or not active then
            active = {}
            for _, status in ipairs(ESP_STATUSES) do
                if char:GetAttribute(status.attr) then active[#active+1] = status end
            end
            bundle._active = active
        end

        if #active > 0 then
            local ICON_GAP=3; local TEXT_GAP=4
            local showText = cfg.espStatusText ~= false
            local colX     = rect.x + rect.w + 5
            local startY   = rect.y

            for i, status in ipairs(active) do
                local slot = bundle.iconSlots[i]
                if slot then
                    local slotY = startY + (i-1)*(iconSize+ICON_GAP)
                    slot.icon.Size=UDim2.fromOffset(iconSize,iconSize)
                    slot.icon.Position=UDim2.fromOffset(colX, slotY)
                    if slot._icol ~= color then slot.icon.ImageColor3=color; slot._icol=color end
                    slot.icon.Visible=true
                    if showText then
                        local slotTS = math.max(7, math.floor(11*scale))
                        if slot._ts ~= slotTS then slot.text.TextSize=slotTS; slot._ts=slotTS end
                        if slot._label ~= status.label then slot.text.Text=status.label; slot._label=status.label end
                        slot.text.Size=UDim2.fromOffset(120,iconSize); slot.text.Position=UDim2.fromOffset(colX+iconSize+TEXT_GAP, slotY)
                        if slot._tcol ~= color then slot.text.TextColor3=color; slot._tcol=color end
                        slot.text.Visible=true
                    else
                        slot.text.Visible=false
                    end
                end
            end

            for i = #active+1, #bundle.iconSlots do
                bundle.iconSlots[i].icon.Visible=false; bundle.iconSlots[i].text.Visible=false
            end
            bundle.statusIcons.Visible=true
        else
            bundle.statusIcons.Visible=false
            for i=1,#bundle.iconSlots do bundle.iconSlots[i].icon.Visible=false; bundle.iconSlots[i].text.Visible=false end
        end
    else
        bundle.statusIcons.Visible=false
    end

    if cfg.espTracers then
        local vpW=Player.Camera.ViewportSize.X; local vpH=Player.Camera.ViewportSize.Y
        local from=Vector2.new(vpW/2, vpH); local to=Vector2.new(rect.x+rect.w/2, rect.y+rect.h)
        local delta=to-from; local length=delta.Magnitude; local angle=math.deg(math.atan2(delta.Y,delta.X))+90
        bundle.tracer.Visible=true; bundle.tracer.Position=UDim2.fromOffset(from.X, from.Y)
        bundle.tracer.Size=UDim2.fromOffset(1, length); bundle.tracer.Rotation=angle
        bundle.tracer.BackgroundColor3=color; bundle.tracer.BackgroundTransparency=0.3
    else
        bundle.tracer.Visible=false
    end
end

local ensureRenderLoop = function()
    if ESPState.renderLoop then return end

    local rectBuf = {}
    local seenP   = {}

    ESPState.renderLoop = Services.RunService.RenderStepped:Connect(function()
        local cfg           = ENV.CONFIG
        local playerReg     = ESPState.PlayerRegistry
        local hideBundle    = API.espHideBundle
        local projectBox    = API.espProjectBox
        local acquireBundle = API.espAcquireBundle
        local releaseBundle = API.espReleaseBundle
        local buf, seenPlayers = rectBuf, seenP

        if not cfg.espEnabled then
            for _, entry in pairs(playerReg) do hideBundle(entry.bundle) end
            return
        end

        local camPos  = Player.Camera.CFrame.Position
        local maxDist = cfg.espMaxDistance or 500
        table.clear(seenPlayers)

        local myId = API.getMyUserId()
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr.UserId == myId then continue end
            local char = plr.Character
            local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
            local root = char and char:FindFirstChild(HRP)

            if not char or not hum or not root or hum.Health <= 0 then
                local entry = playerReg[plr]
                if entry then hideBundle(entry.bundle) end
                continue
            end

            seenPlayers[plr] = true
            local dist = (root.Position - camPos).Magnitude
            if dist > maxDist then
                local entry = playerReg[plr]
                if entry then hideBundle(entry.bundle) end
                continue
            end

            local entry = playerReg[plr]
            if not entry then
                entry = { bundle=acquireBundle(), model=char, player=plr }
                playerReg[plr] = entry
            end
            entry.model = char

            local rect = projectBox(char, buf)
            if not rect then hideBundle(entry.bundle); continue end

            local label = entry._label
            if not label then
                label = plr.DisplayName ~= plr.Name
                    and (plr.DisplayName.." ("..plr.Name..")") or plr.Name
                entry._label = label
            end

            espDrawBundle(entry.bundle, rect, hum, plr, label, dist, API.espResolveColor(plr, nil))
        end

        for plr, entry in pairs(playerReg) do
            if not seenPlayers[plr] then releaseBundle(entry.bundle); playerReg[plr]=nil end
        end
    end)
end

API.ESP = function(plr)
    if plr.UserId == API.getMyUserId() then return end
    ensureRenderLoop()
    if ESPState.playerCharConns[plr] then
        pcall(function() ESPState.playerCharConns[plr]:Disconnect() end)
    end
    ESPState.playerCharConns[plr] = plr.CharacterAdded:Connect(function() task.wait(0.5) end)
end

API.cleanupAllESP = function()
    for plr, entry in pairs(ESPState.PlayerRegistry) do API.espReleaseBundle(entry.bundle) end
    table.clear(ESPState.PlayerRegistry)
    for plr, conn in pairs(ESPState.playerCharConns) do pcall(function() conn:Disconnect() end) end
    table.clear(ESPState.playerCharConns)
    if ESPState.root then ESPState.root:Destroy(); ESPState.root=nil end
end


API.GetBulletOrigin = function()
    local char = API.getChar(Player.Local)
    if not char then return nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return nil end

    local tipAttachment, tipPart = nil, nil
    for _, child in ipairs(tool:GetDescendants()) do
        if child.Name == "Tip" then
            if child:IsA("Attachment") then tipAttachment = child; break
            elseif child:IsA("BasePart") then tipPart = child; break end
        end
    end

    if tipAttachment then
        local parent = tipAttachment.Parent
        if parent and parent:IsA("BasePart") then
            return parent.Position + (parent.CFrame:VectorToWorldSpace(tipAttachment.Position))
        end
    end
    if tipPart then return tipPart.Position end

    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then return handle.Position end

    local root = API.getRoot(Player.Local)
    if root then return root.Position + Vector3.new(0, 1.5, 0) end
    return nil
end

API.toScreen = function(part)
    local pos, visible = Player.Camera:WorldToViewportPoint(part.Position)
    return Vector2.new(pos.X, pos.Y), visible
end

API.hasLineOfSight = function(part)
    local char = Player.Local.Character
    if not char then return false end

    local targetModel = part:FindFirstAncestorOfClass("Model")
    if not targetModel then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char, targetModel }
    params.IgnoreWater = true

    local origin = Player.Camera.CFrame.Position
    local result = workspace:Raycast(origin, part.Position - origin, params)

    if not result then return true end

    local hit = result.Instance
    return hit.Transparency >= 0.95 or not hit.CanCollide
end

API.isTargetVisible = function(targetPart)
    if not targetPart then return false end
    local char = Player.Local.Character
    if not char then return false end
    local origin = API.GetBulletOrigin()
    if not origin then return false end

    local targetModel = targetPart:FindFirstAncestorOfClass("Model")
    if not targetModel then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char, targetModel }
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, targetPart.Position - origin, params)
    if not result then return true end
    local hit = result.Instance
    return hit.Transparency >= 0.95 or not hit.CanCollide
end


local CandidateCache = {
    list        = {},
    lastRefresh = 0,
    dirty       = true,
    TTL         = 0.05,
}

API.rebuildCandidates = function()
    local myId = API.getMyUserId()
    local list  = {}
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr.UserId ~= myId
           and API.isEnemy(plr)
           and API.isAlive(plr)
           and not API.isImmune(plr) then
            list[#list + 1] = plr
        end
    end
    CandidateCache.list        = list
    CandidateCache.lastRefresh = os.clock()
    CandidateCache.dirty       = false
end

API.getCandidates = function()
    local now = os.clock()
    if CandidateCache.dirty or (now - CandidateCache.lastRefresh) >= CandidateCache.TTL then
        API.rebuildCandidates()
    end
    return CandidateCache.list
end

API.invalidateCandidates = function()
    CandidateCache.dirty = true
end


local SELECTORS = {
    closest  = function(a, b) return a.screenDist < b.screenDist end,
    farthest = function(a, b) return a.screenDist > b.screenDist end,
    lowestHP = function(a, b)
        local hA = API.getHum(a.player) and API.getHum(a.player).Health or math.huge
        local hB = API.getHum(b.player) and API.getHum(b.player).Health or math.huge
        return hA < hB
    end,
}

local RAGE_SELECTORS = {
    closest  = function(a, b) return a.dist3D < b.dist3D end,
    farthest = function(a, b) return a.dist3D > b.dist3D end,
    lowestHP = function(a, b)
        local hA = API.getHum(a.player) and API.getHum(a.player).Health or math.huge
        local hB = API.getHum(b.player) and API.getHum(b.player).Health or math.huge
        return hA < hB
    end,
}

API.getTargetRageMode = function()
    local selector = RAGE_SELECTORS[ENV.CONFIG.selectType] or RAGE_SELECTORS.closest
    local entries  = {}

    local players = API.getCandidates()
    for _, plr in ipairs(players) do
        local part = API.getTargetPart(plr)
        if not part then continue end
        
        if not API.hasLineOfSight(part) then continue end
        local screenPos, onScreen = API.toScreen(part)
        local screenDist = onScreen and (screenPos - API.getAimReferencePoint()).Magnitude or math.huge
        local dist3D = (part.Position - Player.Camera.CFrame.Position).Magnitude
        
        table.insert(entries, {
            player = plr,
            part = part,
            screenDist = screenDist,
            dist3D = dist3D,
        })
    end

    if #entries == 0 then return nil end
    table.sort(entries, selector)
    local best = entries[1]
    return best.player, best.screenDist, best.part
end

API.getTarget = function()
    local center   = API.getAimReferencePoint()
    local selector = SELECTORS[ENV.CONFIG.selectType] or SELECTORS.closest
    local entries  = {}

    local players = API.getCandidates()
    for _, plr in ipairs(players) do
        local part = API.getTargetPart(plr)
        if not part then continue end
        local screenPos, visible = API.toScreen(part)
        if not visible then continue end
        local dist = (screenPos - center).Magnitude
        local jitterPad = ENV.CONFIG.jitterEnabled
            and (ENV.CONFIG.jitterAmount or 0.35) * 4
            or 0
        if dist > ENV.CONFIG.FOVRadius + jitterPad then continue end
        if ENV.CONFIG.checkDistance then
            local dist3D = (part.Position - Player.Camera.CFrame.Position).Magnitude
            if dist3D > ENV.CONFIG.maxDistance then continue end
        end
        if not API.hasLineOfSight(part) then continue end
        table.insert(entries, { player=plr, part=part, screenDist=dist })
    end

    if #entries == 0 then return nil end
    table.sort(entries, selector)
    local best = entries[1]
    return best.player, best.screenDist, best.part
end


API.smoothLookAt = function(targetPos)
    local cam  = Player.Camera
    local goal = CFrame.lookAt(cam.CFrame.Position, targetPos)
    if ENV.CONFIG.jitterEnabled then
        goal = API.applyJitter(goal)
    end
    cam.CFrame = cam.CFrame:Lerp(goal, 1 - (ENV.CONFIG.smoothing or 0.2))
end

API.instantLookAt = function(targetPos)
    local cam  = Player.Camera
    local goal = CFrame.lookAt(cam.CFrame.Position, targetPos)
    if ENV.CONFIG.jitterEnabled then
        goal = API.applyJitter(goal)
    end
    cam.CFrame = goal
end


local JitterState = {
    t       = 0,
    offset  = Vector3.zero,
    nextAt  = 0,
}

local function jitterRandom()
    local a = ENV.CONFIG.jitterAmount or 0.35
    local r = math.rad(a)
    local theta = math.random() * math.pi * 2
    local phi   = math.random() * r
    return Vector3.new(math.cos(theta) * math.sin(phi), math.sin(theta) * math.sin(phi), 0)
end

local function jitterSine()
    local a  = math.rad(ENV.CONFIG.jitterAmount or 2.0)
    local sp = (ENV.CONFIG.jitterSpeed or 12) * math.pi
    local t  = os.clock()
    local env = 0.5 + 0.5 * math.sin(t * sp * 0.17)
    return Vector3.new(math.sin(t * sp) * a * env, 0, 0)
end

local function jitterCircle()
    local a  = math.rad(ENV.CONFIG.jitterAmount or 2.0)
    local sp = (ENV.CONFIG.jitterSpeed or 12) * math.pi
    local t  = os.clock()
    return Vector3.new(math.cos(t * sp) * a, math.sin(t * sp) * a, 0)
end

API.applyJitter = function(goalCF)
    if not ENV.CONFIG.jitterEnabled then return goalCF end
    local mode = ENV.CONFIG.jitterMode or "Random"
    if mode == "Random" then
        local now = os.clock()
        if now >= JitterState.nextAt then
            JitterState.offset = jitterRandom()
            JitterState.nextAt = now + 1 / math.max(ENV.CONFIG.jitterSpeed or 12, 0.1)
        end
    elseif mode == "Sine" then
        JitterState.offset = jitterSine()
    elseif mode == "Circle" then
        JitterState.offset = jitterCircle()
    end
    local off = JitterState.offset
    return goalCF * CFrame.Angles(off.Y, off.X, 0)
end


local InputState = {
    lastShot       = 0,
    isZooming      = false,
    mobileAimHeld  = false,
}

API.fireShoot = function()
    if not Services.VirtualInput then return end
    local now = tick()
    if now - InputState.lastShot < ENV.CONFIG.triggerDelay then return end
    InputState.lastShot = now
    local mousePos = Services.UserInputService:GetMouseLocation()
    Services.VirtualInput:SendMouseButton(mousePos, Enum.UserInputType.MouseButton1, true,  0)
    Services.VirtualInput:SendMouseButton(mousePos, Enum.UserInputType.MouseButton1, false, 0)
end

Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        InputState.isZooming = true
    end
end)

Services.UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        InputState.isZooming = false
    end
end)

task.spawn(function()
    if not ENV.CONFIG.mobileMode then return end
    local aimButton = nil
    local deadline  = os.clock() + 15
    while os.clock() < deadline and not aimButton do
        local mobileInput = Player.Gui:FindFirstChild("MobileInput")
        if mobileInput then
            local input = mobileInput:FindFirstChild("Input")
            if input then aimButton = input:FindFirstChild("Aim") end
        end
        if not aimButton then task.wait(0.25) end
    end
    if not aimButton then return end
    InputState.aimButtonFound = true
    aimButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then InputState.mobileAimHeld = true end
    end)
    aimButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then InputState.mobileAimHeld = false end
    end)
end)

API.isZooming = function()
    if ENV.CONFIG.mobileMode then
        if not InputState.aimButtonFound then return true end
        return InputState.mobileAimHeld
    end
    return InputState.isZooming
end

API.startAutoClick = function()
    if ENV.CONNS.autoClickRunning then return end
    ENV.CONNS.autoClickRunning = true
    ENV.CONNS.autoClickThread = task.spawn(function()
        while ENV.CONNS.autoClickRunning do
            if not ENV.CONFIG.autoClickEnabled then
                task.wait(0.1)
                continue
            end
            if ENV.CONFIG.autoClickOnlyZoom and not API.isZooming() then
                task.wait(0.05)
                continue
            end

            local delay    = math.max(ENV.CONFIG.autoClickDelay or 0.1, 0.01)
            local holdTime = math.clamp(ENV.CONFIG.autoClickHoldTime or 0.02, 0.005, delay * 0.9)

            local mousePos = Services.UserInputService:GetMouseLocation()
            Services.VirtualInput:SendMouseButton(mousePos, Enum.UserInputType.MouseButton1, true,  0)
            task.wait(holdTime)
            Services.VirtualInput:SendMouseButton(mousePos, Enum.UserInputType.MouseButton1, false, 0)
            task.wait(math.max(delay - holdTime, 0.005))
        end
    end)
end

API.stopAutoClick = function()
    ENV.CONNS.autoClickRunning = false
    API.unc(ENV.CONNS, "autoClickThread")
end


API.isPlayerUnderMouse = function()
    if ENV.CONFIG.mobileMode then
        local center  = API.getAimReferencePoint()
        local players = API.getCandidates()
        local radius  = math.max(ENV.CONFIG.mobileTriggerRadius or 25, 8)
        local bestEntity, bestDist = nil, radius
        for _, plr in ipairs(players) do
            local part = API.getTargetPart(plr)
            if not part then continue end
            local screenPos, onScreen = API.toScreen(part)
            if not onScreen then continue end
            local dist = (screenPos - center).Magnitude
            if dist > bestDist then continue end
            if not API.hasLineOfSight(part) then continue end
            bestDist   = dist
            bestEntity = plr
        end
        if bestEntity then return true, bestEntity end
        return false, nil
    end

    local target = Player.Mouse.Target
    if not target then return false, nil end
    local character = target:FindFirstAncestorOfClass("Model")
    if not character then return false, nil end
    local targetPlayer = Services.Players:FindFirstChild(character.Name)
    if not targetPlayer then return false, nil end
    for _, candidate in ipairs(API.getCandidates()) do
        if candidate == targetPlayer then return true, targetPlayer end
    end
    return false, nil
end


local Categories = {
    Combat    = Window:Category("Combat"),
    Move      = Window:Category("Movement"),
    ESP       = Window:Category("ESP"),
    Visuals   = Window:Category("Visuals"),
    Misc      = Window:Category("Miscellaneous"),
}

local Groups = {
    Aimbot      = Categories.Combat:Groupbox("Aimbot"),
    Triggerbot  = Categories.Combat:Groupbox("Triggerbot"),
    AutoClick   = Categories.Combat:Groupbox("Auto Click"),

    ESPSettings = Categories.ESP:Groupbox("ESP Settings"),

    LocalPlayer = Categories.Visuals:Groupbox("LocalPlayer"),
    Gameplay    = Categories.Visuals:Groupbox("Gameplay"),
    Sky         = Categories.Visuals:Groupbox("Sky"),

    Walkspeed   = Categories.Move:Groupbox("Speed"),
    JumpPower   = Categories.Move:Groupbox("Jump Power"),
    TpWalk = Categories.Move:Groupbox("TP Walk"),
    Bhop   = Categories.Move:Groupbox("Bhop"),
    AntiAim = Categories.Move:Groupbox("Anti Aim"),

    Server      = Categories.Misc:Groupbox("Server"),
    Discord     = Categories.Misc:Groupbox("Discord"),
    Profiles    = Categories.Misc:Groupbox("Profiles"),
    Client      = Categories.Misc:Groupbox("Client"),
}


Groups.Aimbot:Toggle("Aimbot", ENV.CONFIG.aimbotEnabled, function(v)
    ENV.CONFIG.aimbotEnabled = v
end, { Flag="aimbotEnabled", Keybind=Enum.KeyCode.T, KeybindMode="Toggle" })
    :OnEnabled(function() Window:Notify("Aimbot enabled!", NS) end)
    :OnDisabled(function()
        Window:Notify("Aimbot disabled!", NW)
        API._aimInit = false
    end)
    :OnRender(function()
        if not ENV.CONFIG.aimbotEnabled then return end
        local target, dist, part
        if ENV.CONFIG.rageMode then
            target, dist, part = API.getTargetRageMode()
            if part then API.instantLookAt(part.Position) end
        else
            target, dist, part = API.getTarget()
            if part then API.smoothLookAt(part.Position) end
        end
    end)

regToggle(Groups.Aimbot, "Rage Mode", "rageAimbot", "rageMode")

Groups.Aimbot:Dropdown("Target Part",
    (function()
        local labels = {}
        for _, v in ipairs(TARGET_PART_VALUES) do labels[#labels+1] = TARGET_PART_LABELS[v] or v end
        return labels
    end)(),
    TARGET_PART_LABELS[ENV.CONFIG.aimbotTargetPart] or ENV.CONFIG.aimbotTargetPart,
    function(v)
        for raw, label in pairs(TARGET_PART_LABELS) do
            if label == v then ENV.CONFIG.aimbotTargetPart = raw; return end
        end
        ENV.CONFIG.aimbotTargetPart = v
    end,
    { Flag="aimbotTargetPart" })

Groups.Aimbot:Dropdown("Selection Type", {"closest","farthest","lowestHP"}, "closest", function(v) ENV.CONFIG.selectType=v end, {Flag="aimbotSelectType"})
Groups.Aimbot:Slider("FOV Radius", math.clamp(ENV.CONFIG.FOVRadius,1,500), 1, 500, function(v) ENV.CONFIG.FOVRadius=v end, {Flag="aimbotFOVRadius"})
Groups.Aimbot:Toggle("Show FOV Circle", ENV.CONFIG.showFOVCircle, function(v) ENV.CONFIG.showFOVCircle=v; FOVState.circle.Visible=v end, {Flag="aimbotShowFOV"})
    :OnEnabled(function() Window:Notify("FOV Circle shown!", NS) end)
    :OnDisabled(function() Window:Notify("FOV Circle hidden!", NW) end)
regToggle(Groups.Aimbot, "Rainbow FOV", "aimbotFOVRGB", "fovCircleRGB")
Groups.Aimbot:Colorpicker("FOV Color", ENV.CONFIG.fovCircleColor, function(v) ENV.CONFIG.fovCircleColor=v end, {Flag="aimbotFOVColor"})
Groups.Aimbot:Slider("FOV Circle Alpha", math.clamp(ENV.CONFIG.fovCircleAlpha,0,1), 0, 1, function(v) ENV.CONFIG.fovCircleAlpha=v end, {Flag="aimbotFOVAlpha", Step=0.01})
Groups.Aimbot:Slider("Smoothing", math.clamp(ENV.CONFIG.smoothing,0,1), 0, 1, function(v) ENV.CONFIG.smoothing=v end, {Flag="aimbotSmoothing", Step=0.01})
regToggle(Groups.Aimbot, "Check Distance", "aimbotCheckDistance", "checkDistance")
Groups.Aimbot:Slider("Max Distance", math.clamp(ENV.CONFIG.maxDistance,100,2000), 100, 2000, function(v) ENV.CONFIG.maxDistance=v end, {Flag="aimbotMaxDistance", Step=10})
regToggle(Groups.Aimbot, "Check Team", "aimbotTeamCheck", "checkTeam")


Groups.Aimbot:Toggle("Aim Jitter", ENV.CONFIG.jitterEnabled, function(v) ENV.CONFIG.jitterEnabled = v end, {Flag="jitterEnabled"})
    :OnEnabled(function() Window:Notify("Aim Jitter enabled!", NS) end)
    :OnDisabled(function()
        Window:Notify("Aim Jitter disabled!", NW)
    end)

Groups.Aimbot:Dropdown("Jitter Mode", {"Random","Sine","Circle"}, ENV.CONFIG.jitterMode,
    function(v) ENV.CONFIG.jitterMode = v end, {Flag="jitterMode"})

Groups.Aimbot:Slider("Jitter Amount (deg)",
    math.clamp(ENV.CONFIG.jitterAmount, 0, 5), 0, 5,
    function(v) ENV.CONFIG.jitterAmount = v end,
    { Flag="jitterAmount", Step=0.05 })

Groups.Aimbot:Slider("Jitter Speed (Hz)",
    math.clamp(ENV.CONFIG.jitterSpeed, 0.5, 60), 0.5, 60,
    function(v) ENV.CONFIG.jitterSpeed = v end,
    { Flag="jitterSpeed", Step=0.5 })

Groups.Aimbot:Slider("Cam Writer Max Step (deg)",
    math.clamp(ENV.CONFIG.camWriterMaxStep, 0.1, 2.99), 0.1, 2.99,
    function(v) ENV.CONFIG.camWriterMaxStep = v end,
    { Flag="camWriterMaxStep", Step=0.01 })

Groups.Aimbot:Slider("Cam Writer Burst Budget",
    math.clamp(ENV.CONFIG.camWriterBudget, 1, 5), 1, 5,
    function(v) ENV.CONFIG.camWriterBudget = v end,
    { Flag="camWriterBudget", Step=1 })


Groups.Triggerbot:Toggle("Triggerbot", ENV.CONFIG.triggerbotEnabled, function(v)
    ENV.CONFIG.triggerbotEnabled=v
end, { Flag="triggerBotEnabled", Keybind=Enum.KeyCode.G, KeybindMode="Toggle" })
    :OnEnabled(function() Window:Notify("Triggerbot enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Triggerbot disabled!", NW) end)
    :OnRender(function()
        if not ENV.CONFIG.triggerbotEnabled then return end
        if ENV.CONFIG.triggerOnZoomOnly and not API.isZooming() then return end
        local isUnder = API.isPlayerUnderMouse()
        if isUnder then API.fireShoot() end
    end)
Groups.Triggerbot:Slider("Trigger Delay", math.clamp(ENV.CONFIG.triggerDelay,0.01,0.5), 0.01, 0.5, function(v) ENV.CONFIG.triggerDelay=v end, {Flag="triggerDelay", Step=0.01})
regToggle(Groups.Triggerbot, "Fire on Zoom Only", "triggerOnZoomOnly", "triggerOnZoomOnly")
Groups.Triggerbot:Slider("Mobile Trigger Radius", math.clamp(ENV.CONFIG.mobileTriggerRadius or 25, 8, 120), 8, 120, function(v) ENV.CONFIG.mobileTriggerRadius=v end, {Flag="mobileTriggerRadius", Step=1})


Groups.AutoClick:Toggle("Auto Click", ENV.CONFIG.autoClickEnabled, function(v)
    ENV.CONFIG.autoClickEnabled = v
    if v then API.startAutoClick() else API.stopAutoClick() end
end, { Flag="autoClickEnabled", Keybind=Enum.KeyCode.H, KeybindMode="Toggle" })
    :OnEnabled(function() Window:Notify("Auto Click enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Auto Click disabled!", NW) end)

Groups.AutoClick:Slider("Click Delay (s)",
    math.clamp(ENV.CONFIG.autoClickDelay, 0.01, 1), 0.01, 1,
    function(v) ENV.CONFIG.autoClickDelay = v end,
    { Flag="autoClickDelay", Step=0.01 })

Groups.AutoClick:Slider("Hold Time (s)",
    math.clamp(ENV.CONFIG.autoClickHoldTime, 0.005, 0.5), 0.005, 0.5,
    function(v) ENV.CONFIG.autoClickHoldTime = v end,
    { Flag="autoClickHoldTime", Step=0.005 })

regToggle(Groups.AutoClick, "Only While Zoomed", "autoClickOnlyZoom", "autoClickOnlyZoom")


Groups.ESPSettings:Toggle("ESP Enabled", ENV.CONFIG.espEnabled, function(v) ENV.CONFIG.espEnabled=v end, {Flag="espEnabled"})
    :OnEnabled(function()
        Window:Notify("ESP enabled!", NS)
        task.spawn(function()
            task.wait(0.1)
            local myId = API.getMyUserId()
            for _, player in ipairs(Services.Players:GetPlayers()) do
                if player.UserId ~= myId then API.ESP(player) end
            end
        end)
    end)
    :OnDisabled(function() Window:Notify("ESP disabled!", NW); API.cleanupAllESP() end)

regToggle(Groups.ESPSettings, "Rainbow ESP",   "espRainbow",       "espRainbow")
Groups.ESPSettings:Colorpicker("ESP Color",    ENV.CONFIG.espColor, function(v) ENV.CONFIG.espColor=v end, {Flag="espColor"})
regToggle(Groups.ESPSettings, "Names",         "espNames",         "espNames")
regToggle(Groups.ESPSettings, "Health",        "espHealth",        "espHealth")
regToggle(Groups.ESPSettings, "Status Icons",  "espStatusIcons",   "espStatusIcons")
regToggle(Groups.ESPSettings, "Status Text",   "espStatusText",    "espStatusText")
regToggle(Groups.ESPSettings, "Weapon Name",   "espWeaponName",    "espWeaponName")
regToggle(Groups.ESPSettings, "Distance",      "espDistance",      "espDistance")
regToggle(Groups.ESPSettings, "Team Colors",   "espTeamColors",    "espTeamColors")
regToggle(Groups.ESPSettings, "Tracers",       "espTracers",       "espTracers")
Groups.ESPSettings:Slider("Max Distance", math.clamp(ENV.CONFIG.espMaxDistance or 500,100,2000), 100, 2000, function(v) ENV.CONFIG.espMaxDistance=v end, {Flag="espMaxDistance", Step=10})


Groups.LocalPlayer:Toggle("Hide Arms", ENV.CONFIG.noArms, function(v) ENV.CONFIG.noArms=v end, {Flag="noArms"})
    :OnEnabled(function() Window:Notify("Hide Arms enabled!", NS) end)
    :OnDisabled(function()
        Window:Notify("Hide Arms disabled!", NW)
        local char = API.getChar(Player.Local); if not char then return end
        local la=char:FindFirstChild("Left Arm"); local ra=char:FindFirstChild("Right Arm")
        if la then la.Transparency=0 end; if ra then ra.Transparency=0 end
    end)
    :OnRender(function()
        local char = API.getChar(Player.Local); if not char then return end
        local head = char:FindFirstChild("Head");     if not head then return end
        local la   = char:FindFirstChild("Left Arm"); local ra = char:FindFirstChild("Right Arm")
        if not la or not ra then return end
        local isFirstPerson = (Player.Camera.CFrame.Position - head.Position).Magnitude < 1
        la.Transparency = isFirstPerson and 1 or 0
        ra.Transparency = isFirstPerson and 1 or 0
    end)

Groups.LocalPlayer:Toggle("Trail", ENV.CONFIG.trailEnabled, function(v) ENV.CONFIG.trailEnabled=v end, {Flag="trailEnabled"})
    :OnEnabled(function() Window:Notify("Trail enabled!", NS); API.refreshTrail() end)
    :OnDisabled(function() Window:Notify("Trail disabled!", NW); API.removeTrail() end)
Groups.LocalPlayer:Dropdown("Trail Color Mode", {"Solid","Rainbow (Static)","Rainbow (Animated)"}, ENV.CONFIG.trailColorMode, function(v) ENV.CONFIG.trailColorMode=v; API.refreshTrail() end, {Flag="trailColorMode"})
Groups.LocalPlayer:Colorpicker("Trail Color", ENV.CONFIG.trailColor, function(v) ENV.CONFIG.trailColor=v; if ENV.CONFIG.trailEnabled and ENV.CONFIG.trailColorMode=="Solid" then API.refreshTrail() end end, {Flag="trailColor"})
Groups.LocalPlayer:Slider("Trail Width",    math.clamp(ENV.CONFIG.trailWidth,0.05,2),    0.05, 2, function(v) ENV.CONFIG.trailWidth=v; if ENV.CONFIG.trailEnabled then API.refreshTrail() end end,    {Flag="trailWidth", Step=0.05})
Groups.LocalPlayer:Slider("Trail Lifetime", math.clamp(ENV.CONFIG.trailLifetime,0.05,2), 0.05, 2, function(v)
    ENV.CONFIG.trailLifetime=v
    local char=API.getChar(Player.Local); local torso=char and API.getTorso(char)
    local trail=torso and torso:FindFirstChild(API.TRAIL_NAME)
    if trail then trail.Lifetime=v end
end, {Flag="trailLifetime", Step=0.05})

Groups.Gameplay:Toggle("Fullbright", ENV.CONFIG.fullBright, function(v) ENV.CONFIG.fullBright=v end, {Flag="fullBright"})
    :OnEnabled(function() Window:Notify("Fullbright enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Fullbright disabled!", NW) end)
    :OnRender(function()
        if not ENV.CONFIG.fullBright then return end
        Services.Lighting.ClockTime       = 14
        Services.Lighting.Brightness      = 2
        Services.Lighting.FogEnd          = 100000
        Services.Lighting.GlobalShadows   = false
        Services.Lighting.OutdoorAmbient  = Color3.fromRGB(128,128,128)
    end)

do
    local skyboxNames = {"None"}
    for name in pairs(SKYBOXES) do table.insert(skyboxNames, name) end
    table.sort(skyboxNames)
    local skyboxDropdown
    skyboxDropdown = Groups.Sky:Dropdown("Skybox", skyboxNames, "None", function(v)
        if v == "None" then API.restoreSkybox()
        else
            local preset = SKYBOXES[v]
            if preset then API.applySkybox(preset)
            else Window:Notify("Skybox not loaded yet: "..v, NW) end
        end
    end, {Flag="skybox"})
    task.spawn(function()
        local deadline = os.clock() + 10
        while next(SKYBOXES) == nil and os.clock() < deadline do task.wait(0.2) end
        if next(SKYBOXES) ~= nil and skyboxDropdown then
            local names = {"None"}
            for name in pairs(SKYBOXES) do table.insert(names, name) end
            table.sort(names)
            pcall(function() skyboxDropdown:SetOptions(names) end)
        end
    end)
end


Groups.Walkspeed:Toggle("Speed", ENV.CONFIG.speedEnabled, function(v) ENV.CONFIG.speedEnabled=v end, {Flag="speedEnabled"})
    :OnEnabled(function() Window:Notify("Speed enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Speed disabled!", NW) end)
    :OnLoop(function()
        if not ENV.CONFIG.speedEnabled then return end
        local hum = API.getHum(Player.Local); if not hum then return end
        if hum.WalkSpeed ~= ENV.CONFIG.speedSpeed then hum.WalkSpeed = ENV.CONFIG.speedSpeed end
    end, 1)
Groups.Walkspeed:Slider("Walk Speed", math.clamp(ENV.CONFIG.speedSpeed,5,34), 5, 34, function(v) ENV.CONFIG.speedSpeed=v end, {Flag="walkspeed", Step=1})

Groups.JumpPower:Toggle("Jump Power", ENV.CONFIG.jumpEnabled, function(v) ENV.CONFIG.jumpEnabled=v end, {Flag="jumpEnabled"})
    :OnEnabled(function() Window:Notify("Jump Power enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Jump Power disabled!", NW) end)
    :OnLoop(function()
        if not ENV.CONFIG.jumpEnabled then return end
        local hum = API.getHum(Player.Local); if not hum then return end
        if not hum.UseJumpPower then hum.UseJumpPower=true end
        if hum.JumpPower ~= ENV.CONFIG.jumpPower then hum.JumpPower=ENV.CONFIG.jumpPower end
    end, 1)
Groups.JumpPower:Slider("Jump Power", math.clamp(ENV.CONFIG.jumpPower,5,74), 5, 74, function(v) ENV.CONFIG.jumpPower=v end, {Flag="jumpPower", Step=1})

Groups.AntiAim:Toggle("Spin", ENV.CONFIG.spinEnabled, function(v) ENV.CONFIG.spinEnabled=v end, {Flag="spinEnabled"})
    :OnEnabled(function() API.setupSpin(); Window:Notify("Spin enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Spin disabled!", NW) end)
Groups.AntiAim:Slider("Spin Speed", math.clamp(ENV.CONFIG.spinSpeed,1,100), 1, 100, function(v) ENV.CONFIG.spinSpeed=v end, {Flag="spinSpeed", Step=1})

Groups.TpWalk:Toggle("TP Walk", ENV.CONFIG.tpWalkEnabled, function(v)
    ENV.CONFIG.tpWalkEnabled = v
    if v then API.startTpWalk() else API.stopTpWalk() end
end, { Flag="tpWalkEnabled" })
    :OnEnabled(function() Window:Notify("TP Walk enabled!", NS) end)
    :OnDisabled(function() Window:Notify("TP Walk disabled!", NW) end)

Groups.TpWalk:Slider("Speed", math.clamp(ENV.CONFIG.tpWalkSpeed, 16, 200), 16, 200, function(v)
    ENV.CONFIG.tpWalkSpeed = v
end, { Flag="tpWalkSpeed", Step=1 })

Groups.Bhop:Toggle("Bhop", ENV.CONFIG.bhopEnabled, function(v)
    ENV.CONFIG.bhopEnabled = v
    if v then API.startBhop() else API.stopBhop() end
end, { Flag="bhopEnabled" })
    :OnEnabled(function() Window:Notify("Bhop enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Bhop disabled!", NW) end)

Groups.Bhop:Slider("Interval (s)", math.clamp(ENV.CONFIG.bhopInterval, 0, 1), 0, 1, function(v)
    ENV.CONFIG.bhopInterval = v
end, { Flag="bhopInterval", Step=0.05 })


Groups.Server:Button("Rejoin", function()
    local players = Services.Players:GetPlayers()
    if #players <= 1 then
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player.Local)
    else
        local ok, err = pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player.Local)
        end)
        if not ok then Window:Notify("Rejoin failed: "..tostring(err), NE) end
    end
end)

Groups.Server:Button("Serverhop", function()
    local req  = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    local body = Services.HttpService:JSONDecode(req)
    local servers = {}
    for _, server in ipairs(body.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(servers, server.id)
        end
    end
    if #servers > 0 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], Player.Local)
    else
        Window:Notify("No other servers found!", NW)
    end
end)

Groups.Server:Button("Copy Join Link", function()
    local link = string.format("roblox://placeId=%s&gameInstanceId=%s", game.PlaceId, game.JobId)
    if typeof(setclipboard) == "function" then
        setclipboard(link); Window:Notify("Copied to clipboard!", NS)
    else
        print(link); Window:Notify("Check console for the link.", NS)
    end
end)

Groups.Discord:Button("Join Our Discord", function()
    local discordInviteCode = "Pee57xu9w4"

    API.joinDiscord(discordInviteCode)

    if typeof(setclipboard) == "function" then
        setclipboard("https://discord.gg/"..discordInviteCode)
        Window:Notify("Copied to clipboard!", NS)
    else
        print("https://discord.gg/"..discordInviteCode)
        Window:Notify("Check console for the link.", NS)
    end
end)

local _currentProfile = "default"

Groups.Profiles:Stat("Active Profile", function() return _currentProfile end, 1)
Groups.Profiles:Stat("Saved Profiles", function() return #ProfileList() end, 2)

Groups.Profiles:Button("Save Current", function()
    if not _currentProfile or _currentProfile=="" then return end
    local ok, err = ProfileSave(_currentProfile)
    if ok then Window:Notify("Saved profile: ".._currentProfile, NS)
    else      Window:Notify("Save failed: "..tostring(err), NE) end
end)

Groups.Profiles:Button("Save As...", function()
    Window:Prompt("Save profile as", "name", function(name)
        if not name or name=="" then return end
        _currentProfile = name
        local ok, err = ProfileSave(name)
        if ok then Window:Notify("Saved profile: "..name, NS)
        else      Window:Notify("Save failed: "..tostring(err), NE) end
    end)
end)

Groups.Profiles:Button("Load Current", function()
    if not _currentProfile or _currentProfile=="" then return end
    local ok, err = ProfileLoad(_currentProfile)
    if ok then Window:Notify("Loaded profile: ".._currentProfile, NS)
    else      Window:Notify("Load failed: "..tostring(err), NW) end
end)

Groups.Profiles:Button("Load Named...", function()
    Window:Prompt("Load profile", "name", function(name)
        if not name or name=="" then return end
        local ok, err = ProfileLoad(name)
        if ok then _currentProfile=name; Window:Notify("Loaded profile: "..name, NS)
        else Window:Notify("Load failed: "..tostring(err), NW) end
    end)
end)

Groups.Profiles:Button("List Profiles", function()
    local list = ProfileList()
    if #list==0 then Window:Notify("No saved profiles", NW)
    else Window:Notify(table.concat(list, ", "), { Title="Profiles", Type="info", Duration=6 }) end
end)

Groups.Profiles:Button("Delete Current", function()
    if not _currentProfile or _currentProfile=="" then return end
    if _currentProfile=="default" then Window:Notify("Cannot delete 'default' profile", NW); return end
    if ProfileDelete(_currentProfile) then
        Window:Notify("Deleted profile: ".._currentProfile, NW); _currentProfile="default"
    else
        Window:Notify("No such profile", NW)
    end
end)

Groups.Profiles:Button("Undo Last Change", function() Window:Undo() end)
Groups.Profiles:Button("Reset To Defaults", function()
    if not Window._defaults then Window:Notify("Defaults not ready yet", NW); return end
    Window:Snapshot("reset"); Window:LoadConfig(Window._defaults, true); Window:Notify("Values reset", NS)
end)

Groups.Client:Toggle("Mobile Mode", ENV.CONFIG.mobileMode, function(v) ENV.CONFIG.mobileMode=v end, {Flag="mobileMode"})
    :OnEnabled(function() Window:Notify("Mobile Mode on", NS) end)
    :OnDisabled(function() Window:Notify("Mobile Mode off", NW) end)

Groups.Client:Toggle("Re-execute on join", ENV.CONFIG.queueTeleport, function(v)
    ENV.CONFIG.queueTeleport = v
end, { Flag="queueTeleport" })
    :OnEnabled(function() Window:Notify("Re-execute enabled!", NS) end)
    :OnDisabled(function() Window:Notify("Re-execute disabled!", NW) end)


Services.RunService.RenderStepped:Connect(function()
    FOVState.hueOffset = (FOVState.hueOffset + 0.002) % 1
    ENV.__beamHue      = (ENV.__beamHue      + 0.008) % 1

    if ENV.CONFIG.trailEnabled and ENV.CONFIG.trailColorMode == "Rainbow (Animated)" then
        API.trailHue = ((API.trailHue or 0) + 0.008) % 1
        local char  = API.getChar(Player.Local)
        local torso = char and API.getTorso(char)
        local trail = torso and torso:FindFirstChild(API.TRAIL_NAME)
        if trail then trail.Color = API.buildRainbowSequence(true) end
    end

    if FOVState.circle then
        local shouldShow = ENV.CONFIG.showFOVCircle
        if FOVState.circle.Visible ~= shouldShow then FOVState.circle.Visible=shouldShow end
        if shouldShow then
            local ref      = API.getAimReferencePoint()
            local diameter = ENV.CONFIG.FOVRadius * 2
            FOVState.circle.Position             = UDim2.new(0,ref.X,0,ref.Y)
            FOVState.circle.Size                 = UDim2.new(0,diameter,0,diameter)
            FOVState.circle.BackgroundTransparency = 1 - ENV.CONFIG.fovCircleAlpha
            local stroke = FOVState.circle:FindFirstChildOfClass("UIStroke")
            if ENV.CONFIG.fovCircleRGB then
                local color = Color3.fromHSV(FOVState.hueOffset, 0.8, 1)
                FOVState.circle.BackgroundColor3=color; if stroke then stroke.Color=color end
            else
                FOVState.circle.BackgroundColor3=ENV.CONFIG.fovCircleColor
                if stroke then stroke.Color=ENV.CONFIG.fovCircleColor end
            end
        end
    end
end)

Player.Local.CharacterAdded:Connect(function(char)
    char:WaitForChild(HRP)
    char:WaitForChild("Humanoid"):WaitForChild("Animator")
    Player.Local:WaitForChild("Backpack")

    if ENV.CONFIG.trailEnabled then
        task.spawn(function() task.wait(0.1); API.refreshTrail() end)
    end

    if ENV.CONFIG.spinEnabled then
        task.spawn(function() task.wait(0.1); API.setupSpin() end)
    end

    if ENV.CONFIG.tpWalkEnabled then
        task.spawn(function() task.wait(0.1); API.startTpWalk() end)
    end

    if ENV.CONFIG.bhopEnabled then
        task.spawn(function() task.wait(0.1); API.startBhop() end)
    end
end)

Player.Local.CharacterRemoving:Connect(function()
    API.stopAutoClick()
    API.stopTpWalk()
    API.stopBhop()
    API._aimInit = false
end)

task.spawn(function()
    task.wait(2)
    if ENV.CONFIG.espEnabled then
        local myId = API.getMyUserId()
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player.UserId ~= myId then API.ESP(player) end
        end
    end
end)

Services.Players.PlayerAdded:Connect(function(player)
    repeat task.wait() until player
    API.invalidateCandidates()
    if ENV.CONFIG.espEnabled then API.ESP(player) end
    player.CharacterAdded:Connect(function() API.invalidateCandidates() end)
end)

Services.Players.PlayerRemoving:Connect(function(player)
    API.invalidateCandidates()
    local conn = ESPState.playerCharConns[player]
    if conn then pcall(function() conn:Disconnect() end); ESPState.playerCharConns[player]=nil end
end)

task.spawn(function()
    task.wait(0.5)
    Window:Notify("Universal Script Loaded!", { Type="success", Duration=5 })
end)

Window._defaults = Window:GetConfig()
