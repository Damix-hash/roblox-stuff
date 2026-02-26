getgenv().cooldown = getgenv().cooldown or 0.35

local PointFolder = workspace:WaitForChild("PointFolder")
local StageChange = game.ReplicatedStorage:WaitForChild("StageChange")

local lastStage = #PointFolder:GetChildren()-1

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player.PlayerGui
local Stage = Player.PlayerGui.StageGui.Stage

local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local LastPart = PointFolder:FindFirstChild(lastStage)

if LastPart then
	Root.CFrame = CFrame.new(LastPart.Position)
	repeat task.wait() until tonumber(Stage.Text) == lastStage
end

while tonumber(Stage.Text) > 0 do
	task.wait(getgenv().cooldown)
	StageChange:FireServer("<")
end
