--// UI.lua
--// Gakuran UI Module

local Config = require(script.Parent.Config)

local UI = {}

--------------------------------------------------
--// State
--------------------------------------------------

UI.State = nil
UI.Library = nil
UI.Window = nil

UI.Controls = {}

--------------------------------------------------
--// Initialize
--------------------------------------------------

function UI:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Load UI Library
--------------------------------------------------

function UI:LoadLibrary()
    if self.Library then
        return self.Library
    end

    local success, result = pcall(function()
        return loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/artxficial/INS-ui/main/uilib.min.lua"
            )
        )()
    end)

    if not success then
        warn(
            "[UI] Failed to load UI library:",
            result
        )

        return nil
    end

    self.Library = result

    return self.Library
end

--------------------------------------------------
--// Create Window
--------------------------------------------------

function UI:CreateWindow()
    local Library = self:LoadLibrary()

    if not Library then
        return nil
    end

    --------------------------------------------------
    -- IMPORTANT
    -- The exact constructor depends on the UI library.
    -- Keep the library-specific code here.
    --------------------------------------------------

    local success, window = pcall(function()

        return Library:CreateWindow({
            Title = "Gakuran",
            Subtitle = "Combat Assistant",
        })

    end)

    if not success then

        warn(
            "[UI] Failed to create window:",
            window
        )

        return nil
    end

    self.Window = window

    return window
end

--------------------------------------------------
--// Add Toggle
--------------------------------------------------

function UI:AddToggle(
    name,
    defaultValue,
    callback
)
    if not self.Window then
        return nil
    end

    local success, control = pcall(function()

        return self.Window:AddToggle(
            name,
            {
                Default = defaultValue,
                Callback = callback,
            }
        )

    end)

    if not success then

        warn(
            "[UI] Failed to create toggle:",
            name,
            control
        )

        return nil
    end

    self.Controls[name] = control

    return control
end

--------------------------------------------------
--// Add Slider
--------------------------------------------------

function UI:AddSlider(
    name,
    min,
    max,
    defaultValue,
    callback
)
    if not self.Window then
        return nil
    end

    local success, control = pcall(function()

        return self.Window:AddSlider(
            name,
            {
                Min = min,
                Max = max,
                Default = defaultValue,
                Callback = callback,
            }
        )

    end)

    if not success then

        warn(
            "[UI] Failed to create slider:",
            name,
            control
        )

        return nil
    end

    self.Controls[name] = control

    return control
end

--------------------------------------------------
--// Add Button
--------------------------------------------------

function UI:AddButton(
    name,
    callback
)
    if not self.Window then
        return nil
    end

    local success, control = pcall(function()

        return self.Window:AddButton(
            name,
            callback
        )

    end)

    if not success then

        warn(
            "[UI] Failed to create button:",
            name,
            control
        )

        return nil
    end

    self.Controls[name] = control

    return control
end

--------------------------------------------------
--// Build Main Controls
--------------------------------------------------

function UI:Build()
    if not Config.UI.Enabled then
        return
    end

    if not self.Window then
        self:CreateWindow()
    end

    if not self.Window then
        return
    end

    --------------------------------------------------
    -- Parry
    --------------------------------------------------

    self:AddToggle(
        "Parry",
        Config.Parry.Enabled,
        function(value)

            Config.Parry.Enabled = value

            if self.OnParryToggle then
                self.OnParryToggle(value)
            end

        end
    )

    self:AddSlider(
        "Reaction Time",
        0,
        1,
        Config.Parry.ReactionTime,
        function(value)

            Config.Parry.ReactionTime =
                value

        end
    )

    self:AddSlider(
        "Parry Window",
        0,
        1,
        Config.Parry.ParryWindow,
        function(value)

            Config.Parry.ParryWindow =
                value

        end
    )

    --------------------------------------------------
    -- Targeting
    --------------------------------------------------

    self:AddToggle(
        "Multiple Targets",
        Config.Targeting.MultipleTargets,
        function(value)

            Config.Targeting.MultipleTargets =
                value

        end
    )

    self:AddToggle(
        "Cycle Targets",
        Config.Targeting.CycleTargets,
        function(value)

            Config.Targeting.CycleTargets =
                value

        end
    )

    self:AddSlider(
        "Target Distance",
        1,
        1000,
        Config.Targeting.MaxDistance,
        function(value)

            Config.Targeting.MaxDistance =
                value

        end
    )

    --------------------------------------------------
    -- ESP
    --------------------------------------------------

    self:AddToggle(
        "ESP",
        Config.ESP.Enabled,
        function(value)

            Config.ESP.Enabled =
                value

        end
    )

    self:AddToggle(
        "Health ESP",
        Config.ESP.ShowHealth,
        function(value)

            Config.ESP.ShowHealth =
                value

        end
    )

    self:AddToggle(
        "Name ESP",
        Config.ESP.ShowName,
        function(value)

            Config.ESP.ShowName =
                value

        end
    )

    self:AddToggle(
        "Distance ESP",
        Config.ESP.ShowDistance,
        function(value)

            Config.ESP.ShowDistance =
                value

        end
    )

    self:AddToggle(
        "Target ESP",
        Config.ESP.ShowTarget,
        function(value)

            Config.ESP.ShowTarget =
                value

        end
    )

    --------------------------------------------------
    -- Animation Tracker
    --------------------------------------------------

    self:AddToggle(
        "Animation Tracker",
        Config.AnimationTracker.Enabled,
        function(value)

            Config.AnimationTracker.Enabled =
                value

        end
    )

    self:AddToggle(
        "Log Animations",
        Config.AnimationTracker.LogAnimations,
        function(value)

            Config.AnimationTracker.LogAnimations =
                value

        end
    )

    --------------------------------------------------
    -- AutoPlay
    --------------------------------------------------

    self:AddToggle(
        "AutoPlay",
        Config.AutoPlay.Enabled,
        function(value)

            Config.AutoPlay.Enabled =
                value

            if self.OnAutoPlayToggle then
                self.OnAutoPlayToggle(value)
            end

        end
    )

    --------------------------------------------------
    -- Logging Buttons
    --------------------------------------------------

    self:AddButton(
        "Clear Animation Cache",
        function()

            if self.OnClearAnimationCache then
                self.OnClearAnimationCache()
            end

        end
    )

    self:AddButton(
        "Clear Damage Log",
        function()

            if self.OnClearDamageLog then
                self.OnClearDamageLog()
            end

        end
    )
end

--------------------------------------------------
--// Start
--------------------------------------------------

function UI:Start()
    if not Config.UI.Enabled then
        return
    end

    self:CreateWindow()
    self:Build()
end

--------------------------------------------------
--// Destroy
--------------------------------------------------

function UI:Destroy()
    self.Controls = {}

    if self.Window then

        pcall(function()

            if self.Window.Destroy then
                self.Window:Destroy()
            end

        end)

    end

    self.Window = nil
end

return UI
