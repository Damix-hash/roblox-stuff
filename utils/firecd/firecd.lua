--[[
    fireclickdetector - Automated click detector triggering for Roblox

    Usage:
        _G.fireclickdetector(part, clickCount, clickDelay, cameraTimeout, cameraBuffer, cameraRestoreDelay)

    Parameters:
        part (BasePart)             - The part containing the ClickDetector
        clickCount (number)         - Number of times to click (default: 1)
        clickDelay (number)         - Delay between clicks in seconds (default: 0.2 mobile / 0.1 PC)
        cameraTimeout (number)      - Max time to wait for camera in seconds (default: 5 mobile / 3 PC)
        cameraBuffer (number)       - Distance buffer from part surface in studs (default: 0.5)
        cameraRestoreDelay (number) - Seconds before restoring camera after clicks (default: 1)

    Returns:
        (boolean) - true on success, false on failure
]]

if _G.fireclickdetector then return end

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local isExecuting = false

-- Measures average FPS over a fixed sample window.
-- Yields for `sampleDuration` seconds before returning.
local function measureFPS(sampleDuration)
    sampleDuration = sampleDuration or 0.5
    local frameCount = 0
    local startTime = tick()

    local connection
    connection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
    end)

    task.wait(sampleDuration)
    connection:Disconnect()

    local elapsed = tick() - startTime
    if elapsed <= 0 then return 60 end
    return math.floor(frameCount / elapsed)
end

-- Scales a base delay proportionally to current FPS relative to 60.
-- At 60 FPS returns baseDelay unchanged; at 30 FPS doubles it, etc.
local function scaledDelay(baseDelay, fps)
    if not fps or fps <= 0 then return baseDelay end
    return baseDelay * (60 / fps)
end

-- Computes a CFrame just outside the largest face of a part,
-- looking inward toward its center.
local function cameraFrameForPart(part, buffer)
    buffer = buffer or 0.5
    local size = part.Size
    local halfExtent = math.max(size.X, size.Y, size.Z) / 2 + buffer

    -- Pick the local axis of the largest dimension so the camera
    -- is never obscured by the part itself
    local localOffset
    if size.X >= size.Y and size.X >= size.Z then
        localOffset = Vector3.new(halfExtent, 0, 0)
    elseif size.Y >= size.Z then
        localOffset = Vector3.new(0, halfExtent, 0)
    else
        localOffset = Vector3.new(0, 0, halfExtent)
    end

    local worldOffset = part.CFrame:VectorToWorldSpace(localOffset)
    local center = part.CFrame.Position
    return CFrame.new(center + worldOffset, center)
end

_G.fireclickdetector = function(part, clickCount, clickDelay, cameraTimeout, cameraBuffer, cameraRestoreDelay)
    -- Guard against concurrent calls
    if isExecuting then
        warn("[fireclickdetector] Already executing — skipping concurrent call")
        return false
    end

    -- Validate part up front before touching anything else
    if not part or not part:IsA("BasePart") then
        warn("[fireclickdetector] 'part' must be a BasePart")
        return false
    end
    if not part:IsDescendantOf(game) then
        warn("[fireclickdetector] Part is not in the game (may have been destroyed)")
        return false
    end

    local camera = workspace.CurrentCamera
    if not camera then
        warn("[fireclickdetector] No CurrentCamera found")
        return false
    end

    -- Defaults
    clickCount          = math.max(1, clickCount or 1)
    clickDelay          = clickDelay          or (isMobile and 0.2 or 0.1)
    cameraTimeout       = cameraTimeout       or (isMobile and 5   or 3)
    cameraBuffer        = cameraBuffer        or 0.5
    cameraRestoreDelay  = cameraRestoreDelay  or 1

    isExecuting = true

    -- Sample FPS and scale the click delay accordingly
    local fps = measureFPS(0.5)
    local delay = scaledDelay(clickDelay, fps)

    -- Snapshot camera state so we can restore it afterward
    local savedCameraType  = camera.CameraType
    local savedCameraCFrame = camera.CFrame

    local success, err = pcall(function()
        -- Move camera to look directly at the part
        camera.CameraType = Enum.CameraType.Scriptable
        local targetCFrame = cameraFrameForPart(part, cameraBuffer)
        camera.CFrame = targetCFrame

        -- On a Scriptable camera the move is instant, but we still give
        -- the engine one frame to settle before sampling the viewport.
        RunService.RenderStepped:Wait()

        -- Confirm the part center actually landed on screen
        local screenPos, onScreen = camera:WorldToViewportPoint(part.CFrame.Position)
        if not onScreen then
            error("Part is not visible on screen after camera move")
        end

        -- Fire clicks
        for i = 1, clickCount do
            if isMobile then
                -- TouchState: 1 = Begin, 3 = End
                VirtualInputManager:SendTouchEvent(0, 1, screenPos.X, screenPos.Y)
                VirtualInputManager:SendTouchEvent(0, 3, screenPos.X, screenPos.Y)
            else
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true,  game, 0)
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
            end

            if i < clickCount then
                task.wait(delay)
            end
        end
    end)

    -- Only delay before restoring on success — on failure restore immediately
    if success then
        task.wait(cameraRestoreDelay)
    end

    RunService.RenderStepped:Wait()
    camera.CameraType  = savedCameraType
    camera.CFrame      = savedCameraCFrame
    isExecuting        = false

    if not success then
        warn("[fireclickdetector] Failed:", err)
        return false
    end

    return true
end
