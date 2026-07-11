--[[
    fireclickdetector - Automated click detector triggering for Roblox
    
    A performance-optimized utility for simulating clicks on ClickDetectors
    with intelligent camera positioning and FPS-adaptive timing.
    
    Features:
    - Dynamic camera positioning based on part size
    - FPS detection with automatic delay adjustment
    - Mobile device optimization
    - Multi-click support with configurable delays
    - Prevents concurrent execution
    
    Usage:
        _G.fireclickdetector(part, clickCount, clickDelay, cameraTimeout, cameraBuffer)
        
    Parameters:
        part (BasePart) - The part containing the ClickDetector
        clickCount (number) - Number of times to click (default: 1)
        clickDelay (number) - Delay between clicks in seconds (default: 0.2 mobile, 0.1 PC)
        cameraTimeout (number) - Max time to move camera in seconds (default: 5 mobile, 3 PC)
        cameraBuffer (number) - Distance buffer from part in studs (default: 0.5)
    
    Returns:
        (boolean) - true on success, false on failure
]]

if _G.fireclickdetector then return end

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local fireClickExecuting = false

--[[
    getCurrentFPS()
    
    Detects the current FPS by sampling RenderStepped frames over 0.5 seconds.
    
    Returns:
        (number) - Current frames per second
]]
local function getCurrentFPS()
    local fps = 0
    local frameCount = 0
    local startTime = tick()
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local elapsed = tick() - startTime
        if elapsed >= 0.5 then
            fps = math.floor(frameCount / elapsed)
            frameCount = 0
            startTime = tick()
            connection:Disconnect()
        end
    end)
    
    RunService.RenderStepped:Wait()
    return fps
end

--[[
    getOptimalDelay(baseDelay, currentFPS)
    
    Scales click delay inversely with FPS for consistent behavior across devices.
    60 FPS = 1x (normal), 30 FPS = 2x (slower), 120 FPS = 0.5x (faster)
    
    Parameters:
        baseDelay (number) - Base delay in seconds
        currentFPS (number) - Current frames per second
    
    Returns:
        (number) - Optimized delay scaled to FPS
]]
local function getOptimalDelay(baseDelay, currentFPS)
    if not currentFPS or currentFPS == 0 then return baseDelay end
    local fpsRatio = 60 / currentFPS
    return baseDelay * fpsRatio
end

--[[
    getCameraPositionForPart(part, cameraBuffer)
    
    Calculates optimal camera position based on part dimensions.
    Positions camera along the widest axis to maximize visibility.
    
    Parameters:
        part (BasePart) - The target part
        cameraBuffer (number) - Safety distance from part in studs
    
    Returns:
        (CFrame) - Target camera position
]]
local function getCameraPositionForPart(part, cameraBuffer)
    cameraBuffer = cameraBuffer or 0.5
    local partCenter = part.CFrame.Position
    local partSize = part.Size
    
    local maxDimension = math.max(partSize.X, partSize.Y, partSize.Z)
    local offset = maxDimension / 2 + cameraBuffer
    
    local offsetAxis
    if partSize.X == maxDimension then
        offsetAxis = Vector3.new(offset, 0, 0)
    elseif partSize.Y == maxDimension then
        offsetAxis = Vector3.new(0, offset, 0)
    else
        offsetAxis = Vector3.new(0, 0, offset)
    end
    
    local cameraOffset = part.CFrame:VectorToWorldSpace(offsetAxis)
    local targetCFrame = CFrame.new(partCenter + cameraOffset, partCenter)
    
    return targetCFrame
end

--[[
    _G.fireclickdetector(object, clickCount, clickDelay, cameraTimeout, cameraBuffer)
    
    Simulates clicking a ClickDetector by moving the camera and sending input events.
    Automatically detects FPS and adjusts timing for consistent behavior.
    Prevents concurrent executions to avoid conflicts.
    
    Parameters:
        object (BasePart) - The part containing the ClickDetector
        clickCount (number) - Number of clicks to perform (default: 1)
        clickDelay (number) - Seconds between clicks (default: 0.2 mobile, 0.1 PC)
        cameraTimeout (number) - Max seconds to move camera (default: 5 mobile, 3 PC)
        cameraBuffer (number) - Studs from part to camera (default: 0.5)
    
    Returns:
        (boolean) - true if successful, false if failed
    
    Examples:
        _G.fireclickdetector(part)                              -- Click once with defaults
        _G.fireclickdetector(part, 5)                           -- Click 5 times
        _G.fireclickdetector(part, 3, 0.05, 3, 1.0)             -- 3 clicks, fast, larger buffer
]]
_G.fireclickdetector = function(object, clickCount, clickDelay, cameraTimeout, cameraBuffer, cameraRestoreDelay)
    if fireClickExecuting then
        warn("[fireclickdetector] Already executing - call in progress")
        return false
    end
    fireClickExecuting = true

    clickCount = clickCount or 1
    clickDelay = clickDelay or (isMobile and 0.2 or 0.1)
    cameraTimeout = cameraTimeout or (isMobile and 5 or 3)
    cameraBuffer = cameraBuffer or 0.5
    
    local currentFPS = getCurrentFPS()
    local optimizedClickDelay = getOptimalDelay(clickDelay, currentFPS)
    
    if clickCount < 1 then
        warn("[fireclickdetector] clickCount must be at least 1")
        fireClickExecuting = false
        return false
    end

    if not object or not object:IsA("BasePart") then
        warn("[fireclickdetector] Invalid object passed - must be a BasePart")
        fireClickExecuting = false
        return false
    end

    if not object:IsDescendantOf(game) then
        warn("[fireclickdetector] Object is not in the game (may have been destroyed)")
        fireClickExecuting = false
        return false
    end

    local Camera = workspace.CurrentCamera
    if not Camera then
        warn("[fireclickdetector] No CurrentCamera found")
        fireClickExecuting = false
        return false
    end

    local PreviousCameraType = Camera.CameraType
    local PreviousCameraCFrame = Camera.CFrame

    local success, err = pcall(function()
        Camera.CameraType = Enum.CameraType.Scriptable
        local targetCFrame = getCameraPositionForPart(object, cameraBuffer)
        Camera.CFrame = targetCFrame

        local timeout = tick() + cameraTimeout
        local cameraTolerance = isMobile and 0.5 or 0.1
        
        repeat
            task.wait()
            if tick() > timeout then
                error("[fireclickdetector] Camera move timed out after " .. cameraTimeout .. " seconds")
            end
        until (Camera.CFrame.Position - targetCFrame.Position).Magnitude < cameraTolerance

        local screenPos, onScreen = Camera:WorldToViewportPoint(object.CFrame.Position)

        if not onScreen then
            error("[fireclickdetector] Part is not on screen after camera move")
        end

        for i = 1, clickCount do
            if isMobile then
                VirtualInputManager:SendTouchEvent(0, 1, screenPos.X, screenPos.Y)
                VirtualInputManager:SendTouchEvent(0, 3, screenPos.X, screenPos.Y)
            else
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
            end

            if i < clickCount then
                task.wait(optimizedClickDelay)
            end
        end
    end)

    if cameraRestoreDelay then
        task.wait(cameraRestoreDelay)
    end
    RunService.RenderStepped:Wait()
    Camera.CameraType = PreviousCameraType
    Camera.CFrame = PreviousCameraCFrame
    fireClickExecuting = false

    if not success then
        warn("[fireclickdetector] Error:", err)
        return false
    end

    return true
end
