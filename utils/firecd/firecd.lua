-- why did i even obfuscate it? hold this skids!

if _G.fireclickdetector then return end

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

_G.fireclickdetector = function(object)
    if not object or not object:IsA("BasePart") then
        warn("[fireclickdetector] Invalid object passed — must be a BasePart")
        return
    end

    if not object:IsDescendantOf(game) then
        warn("[fireclickdetector] Object is not in the game (may have been destroyed)")
        return
    end

    local Camera = workspace.CurrentCamera
    if not Camera then
        warn("[fireclickdetector] No CurrentCamera found")
        return
    end

    local PreviousCameraType = Camera.CameraType
    local PreviousCameraCFrame = Camera.CFrame
    local partCenter = object.CFrame.Position

    local success, err = pcall(function()
        Camera.CameraType = Enum.CameraType.Scriptable
        local targetCFrame = CFrame.new(partCenter + Vector3.new(0, 0, 0.5), partCenter)
        Camera.CFrame = targetCFrame

        local timeout = tick() + 3
        repeat
            task.wait()
            if tick() > timeout then
                warn("[fireclickdetector] Camera move timed out")
                break
            end
        until (Camera.CFrame.Position - targetCFrame.Position).Magnitude < 0.1

        local screenPos, onScreen = Camera:WorldToViewportPoint(partCenter)

        if not onScreen then
            warn("[fireclickdetector] Part is not on screen after camera move")
        else
            if isMobile then
                VirtualInputManager:SendTouchEvent(0, 1, screenPos.X, screenPos.Y) -- Begin
                VirtualInputManager:SendTouchEvent(0, 3, screenPos.X, screenPos.Y) -- End
            else
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
            end
        end
    end)

    RunService.RenderStepped:Wait()
    Camera.CameraType = PreviousCameraType
    Camera.CFrame = PreviousCameraCFrame

    if not success then
        warn("[fireclickdetector] Error during execution:", err)
    end
end
