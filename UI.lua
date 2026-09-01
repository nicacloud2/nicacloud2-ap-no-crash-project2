--// UI.lua
--// Gakuran Script - User Interface

local UI = {}

UI.State = nil
UI.Config = nil
UI.TargetManager = nil
UI.ParryController = nil
UI.AutoPlay = nil

UI.Library = nil
UI.Window = nil
UI.Connections = {}

--==================================================
-- Initialization
--==================================================

function UI:Initialize(
    State,
    Config,
    TargetManager,
    ParryController,
    AutoPlay
)
    self.State = State
    self.Config = Config
    self.TargetManager = TargetManager
    self.ParryController = ParryController
    self.AutoPlay = AutoPlay

    table.clear(self.Connections)

    if not Config.UI or not Config.UI.Enabled then
        return
    end

    self:Create()
end

--==================================================
-- Create UI
--==================================================

function UI:Create()
    -- Load your existing UI library here.
    --
    -- Example:
    --
    -- local Library = ...
    -- self.Library = Library
    --
    -- self.Window = Library:CreateWindow({
    --     Title = "Gakuran"
    -- })

    self:CreateTabs()
end

--==================================================
-- Create Tabs
--==================================================

function UI:CreateTabs()
    -- Create your UI tabs here.
    --
    -- Suggested layout:
    --
    -- Main
    -- ├── Enable / Disable
    -- ├── Reaction Time
    -- └── Parry Window
    --
    -- Target
    -- ├── Target Selection
    -- ├── Cycle Target
    -- └── Max Distance
    --
    -- ESP
    -- ├── ESP Enabled
    -- ├── Health
    -- ├── Name
    -- └── Distance
    --
    -- Auto Play
    -- ├── Enable
    -- └── Input Delay
    --
    -- Animations
    -- ├── Animation Logger
    -- └── Animation Cache
end

--==================================================
-- Parry Controls
--==================================================

function UI:SetParryEnabled(enabled)
    if not self.Config or not self.Config.Parry then
        return
    end

    self.Config.Parry.Enabled = enabled == true
end

function UI:SetReactionTime(value)
    if not self.Config or not self.Config.Parry then
        return
    end

    self.Config.Parry.ReactionTime = tonumber(value) or 0
end

--==================================================
-- Target Controls
--==================================================

function UI:RefreshTargets()
    if not self.TargetManager then
        return
    end

    self.TargetManager:Refresh()
end

function UI:NextTarget()
    if not self.TargetManager then
        return nil
    end

    return self.TargetManager:CycleNext()
end

function UI:PreviousTarget()
    if not self.TargetManager then
        return nil
    end

    return self.TargetManager:CyclePrevious()
end

--==================================================
-- Auto Play Controls
--==================================================

function UI:SetAutoPlayEnabled(enabled)
    if not self.AutoPlay then
        return
    end

    self.AutoPlay:SetEnabled(enabled)

    if enabled then
        self.AutoPlay:Start()
    else
        self.AutoPlay:Stop()
    end
end

--==================================================
-- Config Controls
--==================================================

function UI:SaveConfig()
    -- Connect this to your existing config
    -- save system.
end

function UI:LoadConfig()
    -- Connect this to your existing config
    -- load system.
end

--==================================================
-- Destroy
--==================================================

function UI:Destroy()
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(self.Connections)

    if self.Window then
        pcall(function()
            self.Window:Destroy()
        end)
    end

    self.Window = nil
    self.Library = nil

    self.State = nil
    self.Config = nil
    self.TargetManager = nil
    self.ParryController = nil
    self.AutoPlay = nil
end

return UI
