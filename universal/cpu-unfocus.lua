local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local RobloxGui = CoreGui and CoreGui:FindFirstChild("RobloxGui")
local SettingsClippingShield = RobloxGui and RobloxGui:FindFirstChild("SettingsClippingShield")
local SettingsShield = SettingsClippingShield and SettingsClippingShield:FindFirstChild("SettingsShield")
local MenuContainer = SettingsShield and SettingsShield:FindFirstChild("MenuContainer")
local Page = MenuContainer and MenuContainer:FindFirstChild("Page")
local PageViewClipper = Page and Page:FindFirstChild("PageViewClipper")
local PageView = PageViewClipper and PageViewClipper:FindFirstChild("PageView")
local PageViewInnerFrame = PageView and PageView:FindFirstChild("PageViewInnerFrame")
local InnerPage = PageViewInnerFrame and PageViewInnerFrame:FindFirstChild("Page")
local MaxFrameRateFrame = InnerPage and InnerPage:FindFirstChild("Maximum Frame RateFrame")
local DropDownFrameButton = MaxFrameRateFrame and MaxFrameRateFrame:FindFirstChild("DropDownFrameButton")
local DropDownFrameTextLabel = DropDownFrameButton and DropDownFrameButton:FindFirstChild("DropDownFrameTextLabel")

-- i prefered to use gui to path script and write all of it myself instead of digging for another half an hour for properget local client get max framerate
local existingGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("UnfocusBlack")
if existingGui then existingGui:Destroy() end

local blackGui = Instance.new("ScreenGui")
blackGui.Name = "UnfocusBlack"
blackGui.DisplayOrder = math.huge
blackGui.IgnoreGuiInset = true
blackGui.ResetOnSpawn = false
blackGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = math.huge
blackFrame.Visible = false
blackFrame.Parent = blackGui

-- black gui because white is an eye sore even though set3drenderingenabled is already doing the job
UserInputService.WindowFocusReleased:Connect(function()
    RunService:Set3dRenderingEnabled(false)
    blackFrame.Visible = true
    setfpscap(1)
end)

UserInputService.WindowFocused:Connect(function()
	local MaxFrameRate = tonumber(DropDownFrameTextLabel.Text:match("%d+")) or 60

    RunService:Set3dRenderingEnabled(true)
    blackFrame.Visible = false
    setfpscap(MaxFrameRate)
end)
