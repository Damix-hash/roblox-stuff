-- UtilityModule by Claude

local Utils = {}

-- Get the local player's character
function Utils.GetChar(player)
    player = player or game.Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

-- Get the humanoid from a character or player
function Utils.GetHumanoid(target)
    local char
    if typeof(target) == "Instance" and target:IsA("Player") then
        char = Utils.GetChar(target)
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        char = target
    else
        char = Utils.GetChar()
    end
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Get HumanoidRootPart
function Utils.GetRoot(target)
    local char
    if typeof(target) == "Instance" and target:IsA("Player") then
        char = Utils.GetChar(target)
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        char = target
    else
        char = Utils.GetChar()
    end
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Get a player by name (partial match supported)
function Utils.GetPlayer(name)
    name = name:lower()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Name:lower():find(name) then
            return p
        end
    end
    return nil
end

-- Get all players except local player
function Utils.GetOtherPlayers()
    local lp = game.Players.LocalPlayer
    local result = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= lp then table.insert(result, p) end
    end
    return result
end

-- Check if a player is alive
function Utils.IsAlive(player)
    local hum = Utils.GetHumanoid(player)
    return hum and hum.Health > 0
end

-- Teleport to a Vector3, CFrame, or another Player
function Utils.TeleportTo(target)
    local root = Utils.GetRoot()
    if not root then return end
    if typeof(target) == "Instance" and target:IsA("Player") then
        local targetRoot = Utils.GetRoot(target)
        if targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
        end
    elseif typeof(target) == "Vector3" then
        root.CFrame = CFrame.new(target)
    elseif typeof(target) == "CFrame" then
        root.CFrame = target
    end
end

-- Teleport to a BasePart (sits on top of it by default)
-- offset: optional Vector3 to adjust position, e.g. Vector3.new(0, 5, 0)
function Utils.TeleportToPart(part, offset)
    local root = Utils.GetRoot()
    if not root then return end
    if not (typeof(part) == "Instance" and part:IsA("BasePart")) then
        warn("TeleportToPart: expected a BasePart, got " .. typeof(part))
        return
    end
    offset = offset or Vector3.new(0, (part.Size.Y / 2) + 3, 0)
    root.CFrame = part.CFrame + offset
end

-- Get character's position
function Utils.GetPos(player)
    local root = Utils.GetRoot(player)
    return root and root.Position
end

return Utils
