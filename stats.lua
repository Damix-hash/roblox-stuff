-- InfoHUD Loadstring Version - With Connect() Method
-- Usage: 
-- local InfoHUD = loadstring(game:HttpGet("your_url_here"))()
-- local gui = InfoHUD.new(config)
-- gui:connect("Player.Kills", function() return myKills end)

-- ==================== PREMADE COLOR THEMES ====================
local ColorThemes = {
    Purple = {
        Background = Color3.fromRGB(87, 44, 130),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(147, 51, 234)
    },
    Red = {
        Background = Color3.fromRGB(139, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(220, 20, 60)
    },
    Green = {
        Background = Color3.fromRGB(0, 100, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(50, 205, 50)
    },
    Blue = {
        Background = Color3.fromRGB(0, 0, 139),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(30, 144, 255)
    },
    Yellow = {
        Background = Color3.fromRGB(184, 134, 11),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(255, 215, 0)
    },
    Orange = {
        Background = Color3.fromRGB(255, 140, 0),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(255, 165, 0)
    },
    Pink = {
        Background = Color3.fromRGB(219, 112, 147),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 192, 203)
    },
    Cyan = {
        Background = Color3.fromRGB(0, 139, 139),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 255, 255)
    },
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(100, 100, 100)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(180, 180, 180)
    }
}

-- ==================== DEFAULT CONFIGURATION ====================
local DefaultConfig = {
    Theme = "Purple",
    
    GUI = {
        Name = "InfoHUD",
        Position = UDim2.new(0.62881, 0, 0.84932, 0),
        Size = UDim2.new(0, 390, 0, 88),
        BackgroundColor = Color3.fromRGB(87, 44, 130),
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Draggable = false,
    },
    
    Text = {
        Font = Enum.FontWeight.Regular,
        FontFamily = "rbxasset://fonts/families/SourceSansPro.json",
        LabelSize = 14,
        ValueSize = 14,
        LabelColor = Color3.fromRGB(255, 255, 255),
        ValueColor = Color3.fromRGB(255, 255, 255),
    },
    
    SSG = {
        Enabled = true,
        Labels = {
            Shots = {text = "SHOTS", position = UDim2.new(0, 0, -0.0092, 0), size = UDim2.new(0, 52, 0, 18)},
            Hits = {text = "HITS", position = UDim2.new(0, 0, 0.19534, 0), size = UDim2.new(0, 52, 0, 18)},
            Misses = {text = "MISSES", position = UDim2.new(0, 0, 0.39989, 0), size = UDim2.new(0, 52, 0, 18)},
            Desync = {text = "DESYNC", position = UDim2.new(0, 0, 0.60443, 0), size = UDim2.new(0, 52, 0, 18)},
            Accuracy = {text = "ACCURACY", position = UDim2.new(0, 0, 0.78625, 0), size = UDim2.new(0, 52, 0, 18)}
        },
        Values = {
            Shots = {default = "0", position = UDim2.new(0.13083, 0, -0.0092, 0), size = UDim2.new(0, 33, 0, 18)},
            Hits = {default = "0", position = UDim2.new(0.13083, 0, 0.19534, 0), size = UDim2.new(0, 33, 0, 18)},
            Misses = {default = "0", position = UDim2.new(0.13083, 0, 0.39989, 0), size = UDim2.new(0, 33, 0, 18)},
            Desync = {default = "0", position = UDim2.new(0.13083, 0, 0.58171, 0), size = UDim2.new(0, 33, 0, 18)},
            Acc = {default = "100%", position = UDim2.new(0.13083, 0, 0.78625, 0), size = UDim2.new(0, 33, 0, 18)}
        }
    },
    
    Player = {
        Enabled = true,
        Labels = {
            Kills = {text = "KILLS", position = UDim2.new(0.21429, 0, -0.0092, 0), size = UDim2.new(0, 70, 0, 18)},
            Streak = {text = "STREAK", position = UDim2.new(0.21429, 0, 0.19534, 0), size = UDim2.new(0, 70, 0, 18)},
            Best = {text = "BEST STREAK", position = UDim2.new(0.21429, 0, 0.39989, 0), size = UDim2.new(0, 70, 0, 18)},
            Alive = {text = "ALIVE", position = UDim2.new(0.21429, 0, 0.58171, 0), size = UDim2.new(0, 70, 0, 18)},
            Total = {text = "TOTAL KILLS", position = UDim2.new(0.21429, 0, 0.78625, 0), size = UDim2.new(0, 70, 0, 18)}
        },
        Values = {
            Kills = {default = "0", position = UDim2.new(0.39228, 0, -0.0092, 0), size = UDim2.new(0, 33, 0, 18)},
            Streak = {default = "0", position = UDim2.new(0.39228, 0, 0.19534, 0), size = UDim2.new(0, 33, 0, 18)},
            Best = {default = "0", position = UDim2.new(0.39228, 0, 0.39989, 0), size = UDim2.new(0, 33, 0, 18)},
            Alive = {default = "0:00", position = UDim2.new(0.39228, 0, 0.58171, 0), size = UDim2.new(0, 33, 0, 18)},
            Total = {default = "0", position = UDim2.new(0.39228, 0, 0.78625, 0), size = UDim2.new(0, 33, 0, 18)}
        }
    },
    
    Gameplay = {
        Enabled = true,
        Labels = {
            FPS = {text = "FPS", position = UDim2.new(0.47575, 0, -0.0092, 0), size = UDim2.new(0, 70, 0, 18)},
            PING = {text = "PING", position = UDim2.new(0.47575, 0, 0.19534, 0), size = UDim2.new(0, 70, 0, 18)},
            SSGCD = {text = "SGG8 CD", position = UDim2.new(0.47575, 0, 0.39989, 0), size = UDim2.new(0, 70, 0, 18)},
            M9CD = {text = "M9 CD", position = UDim2.new(0.47575, 0, 0.58171, 0), size = UDim2.new(0, 70, 0, 18)},
            SGG8RLD = {text = "SGG8 RELOAD", position = UDim2.new(0.47575, 0, 0.78625, 0), size = UDim2.new(0, 70, 0, 18)}
        },
        Values = {
            FPS = {default = "0", position = UDim2.new(0.65373, 0, -0.0092, 0), size = UDim2.new(0, 33, 0, 18)},
            PING = {default = "0ms", position = UDim2.new(0.65373, 0, 0.19534, 0), size = UDim2.new(0, 33, 0, 18)},
            SSGCD = {default = "0", position = UDim2.new(0.65373, 0, 0.39989, 0), size = UDim2.new(0, 33, 0, 18)},
            M9CD = {default = "0", position = UDim2.new(0.65373, 0, 0.58171, 0), size = UDim2.new(0, 33, 0, 18)},
            SGG8RLD = {default = "0", position = UDim2.new(0.65373, 0, 0.78625, 0), size = UDim2.new(0, 33, 0, 18)}
        }
    },
    
    Misc = {
        Enabled = true,
        Labels = {
            TOP = {text = "TOP", position = UDim2.new(0.7372, 0, -0.0092, 0), size = UDim2.new(0, 61, 0, 18)},
            PT = {text = "PLAYTIME", position = UDim2.new(0.7372, 0, 0.19534, 0), size = UDim2.new(0, 61, 0, 18)},
            SPEED = {text = "SPEED", position = UDim2.new(0.7372, 0, 0.37716, 0), size = UDim2.new(0, 61, 0, 18)},
            KD = {text = "K/D", position = UDim2.new(0.7372, 0, 0.58171, 0), size = UDim2.new(0, 61, 0, 18)},
            AVGDM = {text = "AVG DMG", position = UDim2.new(0.7372, 0, 0.78625, 0), size = UDim2.new(0, 61, 0, 18)}
        },
        Values = {
            TOP = {default = "0", position = UDim2.new(0.89365, 0, -0.0092, 0), size = UDim2.new(0, 41, 0, 18)},
            PT = {default = "0:00:00", position = UDim2.new(0.89365, 0, 0.19534, 0), size = UDim2.new(0, 41, 0, 18)},
            SPEED = {default = "0.0", position = UDim2.new(0.89365, 0, 0.37716, 0), size = UDim2.new(0, 41, 0, 18)},
            KD = {default = "0.0", position = UDim2.new(0.89365, 0, 0.58171, 0), size = UDim2.new(0, 41, 0, 18)},
            AVGDM = {default = "0.0", position = UDim2.new(0.89365, 0, 0.78625, 0), size = UDim2.new(0, 41, 0, 18)}
        }
    },
    
    UpdateRate = 0.1
}

-- ==================== HELPER FUNCTIONS ====================
local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function MergeTables(base, override)
    local result = DeepCopy(base)
    if not override then return result end
    
    for k, v in pairs(override) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = MergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- ==================== GUI CREATION FUNCTION ====================
local function CreateInfoHUD(customConfig)
    local Config = MergeTables(DefaultConfig, customConfig)
    local G2L = {}
    local ValueLabels = {}
    local Connections = {}
    local UpdateThread = nil
    
    -- Apply theme if selected
    if Config.Theme and ColorThemes[Config.Theme] then
        local selectedTheme = ColorThemes[Config.Theme]
        Config.GUI.BackgroundColor = selectedTheme.Background
        Config.Text.LabelColor = selectedTheme.Text
        Config.Text.ValueColor = selectedTheme.Text
    end
    
    -- Create ScreenGui
    G2L["ScreenGui"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    G2L["ScreenGui"]["Name"] = Config.GUI.Name
    G2L["ScreenGui"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
    G2L["ScreenGui"]["ResetOnSpawn"] = false
    
    -- Create Main Frame
    G2L["MainFrame"] = Instance.new("Frame", G2L["ScreenGui"])
    G2L["MainFrame"]["BorderSizePixel"] = Config.GUI.BorderSizePixel
    G2L["MainFrame"]["BackgroundColor3"] = Config.GUI.BackgroundColor
    G2L["MainFrame"]["Size"] = Config.GUI.Size
    G2L["MainFrame"]["Position"] = Config.GUI.Position
    G2L["MainFrame"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["MainFrame"]["Name"] = "StatsHUD"
    G2L["MainFrame"]["BackgroundTransparency"] = Config.GUI.BackgroundTransparency
    
    -- Make draggable if enabled
    if Config.GUI.Draggable then
        local dragging = false
        local dragInput, mousePos, framePos
        
        G2L["MainFrame"].InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = G2L["MainFrame"].Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        G2L["MainFrame"].InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                G2L["MainFrame"].Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Helper function to create labels
    local function CreateLabel(parent, text, position, size, textSize)
        local label = Instance.new("TextLabel", parent)
        label["BorderSizePixel"] = 0
        label["TextSize"] = textSize or Config.Text.LabelSize
        label["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
        label["FontFace"] = Font.new(Config.Text.FontFamily, Config.Text.Font, Enum.FontStyle.Normal)
        label["TextColor3"] = Config.Text.LabelColor
        label["Size"] = size
        label["BorderColor3"] = Color3.fromRGB(0, 0, 0)
        label["Text"] = text
        label["Position"] = position
        label["BackgroundTransparency"] = 1
        return label
    end
    
    -- Helper function to create value labels
    local function CreateValueLabel(parent, name, text, position, size, section, textSize)
        local label = Instance.new("TextLabel", parent)
        label["BorderSizePixel"] = 0
        label["TextSize"] = textSize or Config.Text.ValueSize
        label["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
        label["FontFace"] = Font.new(Config.Text.FontFamily, Config.Text.Font, Enum.FontStyle.Normal)
        label["TextColor3"] = Config.Text.ValueColor
        label["Size"] = size
        label["BorderColor3"] = Color3.fromRGB(0, 0, 0)
        label["Text"] = text
        label["Position"] = position
        label["BackgroundTransparency"] = 1
        label["Name"] = name
        
        -- Store reference with path
        local path = section .. "." .. name
        ValueLabels[path] = label
        
        return label
    end
    
    -- Create SSG Section
    if Config.SSG.Enabled then
        G2L["SSG"] = Instance.new("Folder", G2L["MainFrame"])
        G2L["SSG"]["Name"] = "SSG"
        
        G2L["SSG_VAL"] = Instance.new("Folder", G2L["SSG"])
        G2L["SSG_VAL"]["Name"] = "VAL"
        
        for name, data in pairs(Config.SSG.Labels) do
            CreateLabel(G2L["SSG"], data.text, data.position, data.size)
        end
        
        for name, data in pairs(Config.SSG.Values) do
            CreateValueLabel(G2L["SSG_VAL"], name, data.default, data.position, data.size, "SSG")
        end
    end
    
    -- Create Player Section
    if Config.Player.Enabled then
        G2L["PLAYER"] = Instance.new("Folder", G2L["MainFrame"])
        G2L["PLAYER"]["Name"] = "PLAYER"
        
        G2L["PLAYER_VAL"] = Instance.new("Folder", G2L["PLAYER"])
        G2L["PLAYER_VAL"]["Name"] = "VAL"
        
        for name, data in pairs(Config.Player.Labels) do
            CreateLabel(G2L["PLAYER"], data.text, data.position, data.size)
        end
        
        for name, data in pairs(Config.Player.Values) do
            CreateValueLabel(G2L["PLAYER_VAL"], name, data.default, data.position, data.size, "Player")
        end
    end
    
    -- Create Gameplay Section
    if Config.Gameplay.Enabled then
        G2L["GAMEPLAY"] = Instance.new("Folder", G2L["MainFrame"])
        G2L["GAMEPLAY"]["Name"] = "GAMEPLAY"
        
        G2L["GAMEPLAY_VAL"] = Instance.new("Folder", G2L["GAMEPLAY"])
        G2L["GAMEPLAY_VAL"]["Name"] = "VAL"
        
        for name, data in pairs(Config.Gameplay.Labels) do
            CreateLabel(G2L["GAMEPLAY"], data.text, data.position, data.size)
        end
        
        for name, data in pairs(Config.Gameplay.Values) do
            CreateValueLabel(G2L["GAMEPLAY_VAL"], name, data.default, data.position, data.size, "Gameplay")
        end
    end
    
    -- Create Misc Section
    if Config.Misc.Enabled then
        G2L["MISC"] = Instance.new("Folder", G2L["MainFrame"])
        G2L["MISC"]["Name"] = "MISC"
        
        G2L["MISC_VAL"] = Instance.new("Folder", G2L["MISC"])
        G2L["MISC_VAL"]["Name"] = "VAL"
        
        for name, data in pairs(Config.Misc.Labels) do
            CreateLabel(G2L["MISC"], data.text, data.position, data.size)
        end
        
        for name, data in pairs(Config.Misc.Values) do
            CreateValueLabel(G2L["MISC_VAL"], name, data.default, data.position, data.size, "Misc")
        end
    end
    
    -- Built-in connections for FPS and PING
    Connections["Gameplay.FPS"] = function()
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        return tostring(fps)
    end
    
    Connections["Gameplay.PING"] = function()
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        return math.floor(ping) .. "ms"
    end
    
    -- Update Loop
    UpdateThread = spawn(function()
        while G2L["ScreenGui"] and G2L["ScreenGui"].Parent do
            for path, updateFunc in pairs(Connections) do
                if ValueLabels[path] then
                    local success, result = pcall(updateFunc)
                    if success and result then
                        ValueLabels[path].Text = tostring(result)
                    end
                end
            end
            wait(Config.UpdateRate)
        end
    end)
    
    -- ==================== PUBLIC API ====================
    local HUD = {}
    
    -- Connect a value to an update function
    function HUD:connect(path, updateFunc)
        if ValueLabels[path] then
            Connections[path] = updateFunc
            return true
        else
            warn("InfoHUD: Invalid path '" .. path .. "'. Available paths:")
            for availablePath, _ in pairs(ValueLabels) do
                warn("  - " .. availablePath)
            end
            return false
        end
    end
    
    -- Set a value directly (one-time, not updated)
    function HUD:setValue(path, value)
        if ValueLabels[path] then
            ValueLabels[path].Text = tostring(value)
            -- Remove connection if exists
            Connections[path] = nil
            return true
        else
            warn("InfoHUD: Invalid path '" .. path .. "'")
            return false
        end
    end
    
    -- Get a value label reference
    function HUD:getLabel(path)
        return ValueLabels[path]
    end
    
    -- Disconnect a connection
    function HUD:disconnect(path)
        Connections[path] = nil
        return true
    end
    
    -- Get all available paths
    function HUD:getPaths()
        local paths = {}
        for path, _ in pairs(ValueLabels) do
            table.insert(paths, path)
        end
        return paths
    end
    
    -- Destroy the HUD
    function HUD:destroy()
        if G2L["ScreenGui"] then
            G2L["ScreenGui"]:Destroy()
        end
        Connections = {}
        ValueLabels = {}
    end
    
    -- Get the ScreenGui instance
    function HUD:getGui()
        return G2L["ScreenGui"]
    end
    
    -- Update rate control
    function HUD:setUpdateRate(rate)
        Config.UpdateRate = rate
    end
    
    return HUD
end

-- ==================== MODULE EXPORT ====================
local InfoHUD = {}
InfoHUD.new = CreateInfoHUD
InfoHUD.Themes = ColorThemes
InfoHUD.DefaultConfig = DefaultConfig

return InfoHUD
