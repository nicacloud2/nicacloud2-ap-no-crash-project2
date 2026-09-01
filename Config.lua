--// Config.lua
--// Gakuran Script Configuration

local Config = {}

--==================================================
-- General
--==================================================

Config.Debug = false
Config.Enabled = true

--==================================================
-- Targeting
--==================================================

Config.Targeting = {
    MaxDistance = 1000,
    MultipleTargets = true,
    CycleTargets = true,
}

--==================================================
-- Parry
--==================================================

Config.Parry = {
    Enabled = true,

    -- Default reaction time
    ReactionTime = 0.15,

    -- Parry timing
    ParryWindow = 0.20,

    -- Distance checks
    MaxDistance = 100,

    -- Projectile/orb detection
    DetectProjectiles = true,
}

--==================================================
-- ESP
--==================================================

Config.ESP = {
    Enabled = true,
    ShowHealth = true,
    ShowName = true,
    ShowDistance = true,
    ShowTarget = true,

    MaxDistance = 1000,
}

--==================================================
-- Animation Tracking
--==================================================

Config.AnimationTracker = {
    Enabled = true,
    LogAnimations = false,
    CacheAnimations = true,
}

--==================================================
-- Auto Play
--==================================================

Config.AutoPlay = {
    Enabled = false,

    -- Delay between inputs
    InputDelay = 0.05,
}

--==================================================
-- UI
--==================================================

Config.UI = {
    Enabled = true,
    SaveConfig = true,
    LoadConfig = true,
}

--==================================================
-- Ignore List
--==================================================

Config.IgnoreIds = {
    -- Add animation IDs that should be ignored here
}

--==================================================
-- Animation IDs
--==================================================

Config.Animations = {
    ParriedAnimation = nil,
    StunnedAnimation = nil,
    ParryingAnimation = nil,
    ParryFailed = nil,
}

--==================================================
-- Initialization
--==================================================

function Config:Initialize(State)
    self.State = State
end

return Config
