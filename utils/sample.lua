-- SampleScript.lua
-- Replace the URL with your actual raw file URL

local Utils = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local char  = Utils.GetChar()
local hum   = Utils.GetHumanoid()   -- warns if char is in a folder/unexpected parent
local root  = Utils.GetRoot()
local myPos = Utils.GetPos()

print("Character:", char.Name)
print("Health:", hum.Health)
print("Position:", myPos)

-- SAFE GETSERVICE
local TweenService  = Utils.SafeGetService("TweenService")   -- returns nil if not found, no crash
local BadService    = Utils.SafeGetService("FakeService")    -- warns and returns nil

-- PLAYER LOOKUP
local target = Utils.GetPlayer("bob")
if target then
    print("Found:", target.Name, "| Alive:", Utils.IsAlive(target))
    print("Distance:", Utils.GetDistance(root, target))
end

Utils.PlayerInfo()  -- prints every player, their alive status, distance, AND where their char is parented

local closest, dist = Utils.GetClosestPlayer()
if closest then print("Closest:", closest.Name, dist, "studs") end

local nearby = Utils.GetPlayersInRadius(50)
for _, p in ipairs(nearby) do print("Nearby:", p.Name) end

-- TELEPORT
Utils.TeleportTo(Vector3.new(0, 10, 0))
if target then Utils.TeleportTo(target) end

local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then
    Utils.TeleportToPart(spawn)
    Utils.TeleportToPart(spawn, Vector3.new(0, 10, 0))
end

-- ANCHOR CHARACTER
Utils.AnchorChar()    -- freeze in place, no physics
task.wait(3)
Utils.UnanchorChar()  -- restore physics

-- BRING PART
local box = workspace:FindFirstChild("Box")
if box then
    Utils.BringPart(box)
    Utils.BringPart(box, Vector3.new(0, 5, -5))

    local stopBring = Utils.BringPartLoop(box, 0.05)
    task.wait(5)
    stopBring()
end

-- Default: skips characters and Baseplate automatically
Utils.BringPartsInRadius(30)

-- Only bring parts that are direct children of a specific folder
Utils.BringPartsInRadius(999, workspace, {
    onlyFromParent = workspace:FindFirstChild("Drops")  -- only stuff inside workspace.Drops
})

-- Skip anchored parts too (walls, floors, map geometry)
Utils.BringPartsInRadius(50, workspace, {
    excludeAnchored = true
})

-- Include characters if you actually want that
Utils.BringPartsInRadius(30, workspace, {
    excludeCharacters = false
})

-- Custom drop position relative to you
Utils.BringPartsInRadius(30, workspace, {
    offset = Vector3.new(0, 5, 0)   -- stack them above you
})

-- Combine options
Utils.BringPartsInRadius(100, workspace, {
    onlyFromParent  = workspace:FindFirstChild("ItemFolder"),
    excludeAnchored = true,
    offset          = Vector3.new(0, 3, -2)
})

-- TOOLS
Utils.EquipTool("sword")
Utils.EquipTool("gun", 1)          -- 1s delay before equipping
Utils.ActivateTool()
Utils.ActivateTool(0.5)            -- 0.5s delay before activating
Utils.DeactivateTool()
Utils.EquipAndActivate("sword", 0, 0.2)

-- Equip ALL tools at once by parenting them to character (no unequip issue)
Utils.EquipAllTools()
Utils.EquipAllTools(0.3)           -- 0.3s between each

local allTools = Utils.GetAllTools()
for _, t in ipairs(allTools) do print("Tool:", t.Name) end

Utils.DropTool()
Utils.UnequipTool()

-- GRIP POS
-- Useful for repositioning a tool in your hand (client-side visual, FE or not)
local grip = Utils.GetToolGrip()
if grip then
    print("GripPos:", grip.GripPos)
    print("GripCFrame:", grip.GripCFrame)
    -- move the tool up 2 studs in your hand
    Utils.SetToolGripPos(grip.GripPos + Vector3.new(0, 2, 0))
end

-- SAFE REMOTES
Utils.SafeFireServer("BuyItem", "Sword", 1)

local remote = game.ReplicatedStorage:FindFirstChild("PurchaseEvent")
if remote then Utils.SafeFireServer(remote, "Sword", 1) end

local result = Utils.SafeInvokeServer("GetPlayerData")
if result then print("Server returned:", result) end

Utils.SafeFireBindable("OnPlayerAction", "jumped")

-- WAIT UTILS
Utils.TimedWait(3, "CooldownWait")

local gui = Utils.WaitForChild(LP.PlayerGui, "MainGui", 10)

local firstTool = Utils.WaitForChildOfClass(LP.Backpack, "Tool", 10)
if firstTool then print("Got tool:", firstTool.Name) end

local anyRemote = Utils.WaitForDescendantOfClass(game.ReplicatedStorage, "RemoteEvent", 10)

Utils.WaitUntil(function()
    return hum.Health < 50
end, 30, "LowHealthWait")

-- LOOP & RETRY
local stopLoop = Utils.Loop(2, function()
    print("Health:", hum.Health)
end, 5, "HealthPrinter")

local stopForever = Utils.Loop(1, function()
    if target and Utils.IsAlive(target) then
        Utils.TeleportTo(target)
    end
end)
task.wait(10)
stopForever()

local success = Utils.Retry(function()
    return Utils.EquipTool("gun")
end, 3, 0.5, "EquipRetry")

-- SAFE GET / SET
local speed = Utils.SafeGet(hum, "WalkSpeed")
print("WalkSpeed:", speed)
Utils.SafeSet(hum, "WalkSpeed", 32)
Utils.SafeSet(hum, "JumpPower", 100)

-- LIST SCRIPTS (great for exploring a game before writing exploits)
Utils.ListLocalScripts()         -- all LocalScripts + whether they're active/disabled
Utils.ListModuleScripts()        -- all ModuleScripts (decompilable)
Utils.ListAllScripts()           -- everything at once with counts at the end

Utils.ListRemotes()              -- all RemoteEvents, RemoteFunctions, BindableEvents
