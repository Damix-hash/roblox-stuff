local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function setupCharacter(character)
    local root = character:WaitForChild("HumanoidRootPart")
    local targetPos = Vector3.new(112, 570, 129)
    local stuckPos = Vector3.new(101, 1366, 192)
    
    repeat
        root.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
    until (root.Position - targetPos).Magnitude < 5 and (root.Position - stuckPos).Magnitude > 50
    
    local BodyForce = Instance.new("BodyForce")
    BodyForce.Force = Vector3.new(0, 2500, 50000)
    BodyForce.Parent = root
    
    while task.wait(0.5) do
        if root.Position.Z >= 60000 then
            character:BreakJoints()
            break
        end
    end 
end

if LocalPlayer.Character then
    task.spawn(setupCharacter, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
