--[[
    firecloseproximityprompt - Automated ProximityPrompt triggering for Roblox

    A lightweight utility for simulating keyboard input on the currently
    visible ProximityPrompt.

    Features:
    - Automatically tracks the currently visible ProximityPrompt
    - Waits for a prompt to become visible
    - Holds the correct keyboard key until the prompt disappears
    - Optional release delay for compatibility with certain games
    - Optional target prompt support
    - Configurable timeouts
    - Prevents concurrent execution
    - Safe repeated use across teleports/maps

    Usage:
        _G.firecloseproximityprompt(promptTimeout, holdTimeout, releaseDelay, targetPrompt)

    Parameters:
        promptTimeout (number) - Seconds to wait for a prompt to appear (default: 10)
        holdTimeout (number) - Seconds to wait for the prompt to complete (default: 30)
        releaseDelay (number) - Seconds to continue holding the key after completion (default: 0)
        targetPrompt (ProximityPrompt) - Specific prompt to target (default: nil = any visible prompt)

    Returns:
        (boolean) - true on success, false on failure
]]

if _G.firecloseproximityprompt then
    return
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")

local currentPrompt
local firePromptExecuting = false

--[[
    Track the currently visible ProximityPrompt.

    These listeners remain connected for the lifetime of the script,
    ensuring the current prompt is always known.
]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    currentPrompt = prompt
end)

ProximityPromptService.PromptHidden:Connect(function(prompt)
    if currentPrompt == prompt then
        currentPrompt = nil
    end
end)

--[[
    _G.firecloseproximityprompt(promptTimeout, holdTimeout, releaseDelay, targetPrompt)

    Simulates pressing the keyboard key of a visible ProximityPrompt.

    If targetPrompt is specified, waits for that exact prompt to become
    visible. Otherwise, waits for any visible prompt.

    Holds the prompt's keyboard key until that prompt disappears, with
    optional release delay support.

    Prevents concurrent executions.

    Parameters:
        promptTimeout (number) - Seconds to wait for a prompt (default: 10)
        holdTimeout (number) - Seconds to wait for completion (default: 30)
        releaseDelay (number) - Extra seconds to hold the key after completion (default: 0)
        targetPrompt (ProximityPrompt) - Specific prompt to target (default: nil)

    Returns:
        (boolean) - true if successful, false otherwise

    Examples:
        _G.firecloseproximityprompt()
        _G.firecloseproximityprompt(5)
        _G.firecloseproximityprompt(5, 15)
        _G.firecloseproximityprompt(nil, nil, 0.1)
        _G.firecloseproximityprompt(nil, nil, nil, workspace.Part.ProximityPrompt)
]]
_G.firecloseproximityprompt = function(promptTimeout, holdTimeout, releaseDelay, targetPrompt)
    if firePromptExecuting then
        warn("[firecloseproximityprompt] Already executing - call in progress")
        return false
    end

    firePromptExecuting = true

    promptTimeout = promptTimeout or 10
    holdTimeout = holdTimeout or 30
    releaseDelay = releaseDelay or 0

    if promptTimeout <= 0 then
        warn("[firecloseproximityprompt] promptTimeout must be greater than 0")
        firePromptExecuting = false
        return false
    end

    if holdTimeout <= 0 then
        warn("[firecloseproximityprompt] holdTimeout must be greater than 0")
        firePromptExecuting = false
        return false
    end

    if releaseDelay < 0 then
        warn("[firecloseproximityprompt] releaseDelay cannot be negative")
        firePromptExecuting = false
        return false
    end

    if targetPrompt and not targetPrompt:IsA("ProximityPrompt") then
        warn("[firecloseproximityprompt] targetPrompt must be a ProximityPrompt")
        firePromptExecuting = false
        return false
    end

    local success, err = pcall(function()

        local timeout = tick() + promptTimeout
        local prompt

        while true do
            if tick() >= timeout then
                error("[firecloseproximityprompt] Timed out waiting for a ProximityPrompt")
            end

            if targetPrompt then
                if currentPrompt == targetPrompt then
                    prompt = targetPrompt
                    break
                end
            elseif currentPrompt then
                prompt = currentPrompt
                break
            end

            task.wait(0.01)
        end

        if not prompt:IsDescendantOf(game) then
            error("[firecloseproximityprompt] Prompt no longer exists")
        end

        local key = prompt.KeyboardKeyCode

        if key == Enum.KeyCode.Unknown then
            error("[firecloseproximityprompt] Prompt has no valid KeyboardKeyCode")
        end

        VirtualInputManager:SendKeyEvent(true, key, false, game)

        timeout = tick() + holdTimeout

        while currentPrompt == prompt do
            if tick() >= timeout then
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                error("[firecloseproximityprompt] Timed out waiting for the prompt to complete")
            end

            task.wait(0.01)
        end

        if releaseDelay > 0 then
            task.wait(releaseDelay)
        end

        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)

    firePromptExecuting = false

    if not success then
        warn("[firecloseproximityprompt] Error:", err)
        return false
    end

    return true
end
