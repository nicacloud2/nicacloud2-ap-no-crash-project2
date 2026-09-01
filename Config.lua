--// =========================================================
--// GAKURAN - CONFIG
--// =========================================================

local Config = {}

--// =========================================================
--// GENERAL
--// =========================================================

Config.Debug = false

Config.DefaultReactionTime = 0.1

Config.AutoParryRange = 10

Config.MaxCycleRange = 20

Config.ParryWindow = 0.2

Config.ProbabilityToParry = 100

Config.ParryOffset = 0

Config.BlockHoldTime = 0.27


--// =========================================================
--// PARRY SETTINGS
--// =========================================================

Config.Parry = {

    Enabled = true,

    MaxDistance = Config.AutoParryRange,

    Probability = Config.ProbabilityToParry,

    Window = Config.ParryWindow,

    Offset = Config.ParryOffset,

    BlockHoldTime = Config.BlockHoldTime,

    DefaultReactionTime = Config.DefaultReactionTime

}


--// =========================================================
--// TARGET SETTINGS
--// =========================================================

Config.Targeting = {

    Enabled = true,

    MaxDistance = Config.MaxCycleRange,

    CycleTargets = true,

    IgnoreSelf = true

}


--// =========================================================
--// ANIMATION STATES
--// =========================================================

Config.ParriedAnimation = {

    "rbxassetid://100773926241456",
    "rbxassetid://102823909334302",
    "rbxassetid://96304721384743",
    "rbxassetid://82979105739696",
    "rbxassetid://96600699015093",
    "rbxassetid://138519505081692"

}


Config.StunnedAnimation = {

    "rbxassetid://122541287927198",
    "rbxassetid://83600639547203",
    "rbxassetid://80309578200579",
    "rbxassetid://92787945841620",
    "rbxassetid://108045962864902",
    "rbxassetid://104407197874289"

}


Config.ParryingAnimation = {

    "rbxassetid://118147060185189",
    "rbxassetid://80135556847061",
    "rbxassetid://88718564310179"

}


Config.ParryFailed = {

    "rbxassetid://4210597123"

}


--// =========================================================
--// IGNORE IDS
--// =========================================================

Config.IgnoreIds = {

    -- Put animation IDs here that should be ignored.
    -- Example:
    -- "rbxassetid://123456789"

}


--// =========================================================
--// ANIMATION DATABASE
--// =========================================================
--// Add your animation data below.
--
--// Structure:
--
--// StyleName = {
--//
--//     M1Time = 0.6,
--//
--//     ["rbxassetid://123"] = {
--//         DisplayName = "M1",
--//         ReactionTime = 0.1
--//     }
--//
--// }
--
--// If ReactionTime is missing, the default reaction time
--// will be used.
--// =========================================================

Config.GameConfig = {

    KarateAnims = {
        M1Time = 0.6
    },

    AliAnims = {
        M1Time = 0.6
    },

    BasicAnims = {
        M1Time = 0.6
    },

    WrestlingAnims = {
        M1Time = 0.6
    },

    MuayThaiAnims = {
        M1Time = 0.6
    },

    BoxingAnims = {
        M1Time = 0.6
    },

    HakariAnims = {
        M1Time = 0.6,

        -- Correct Hakari animation ID
        -- rbX asset: 82855179231529
    },

    CapoeiraAnims = {
        M1Time = 0.6
    },

    SluggerAnims = {
        M1Time = 0.6
    },

    StrikerAnims = {
        M1Time = 0.6
    },

    KickboxingAnims = {
        M1Time = 0.6
    },

    KyokushinAnims = {
        M1Time = 0.6
    },

    CQCAnims = {
        M1Time = 0.6
    },

    KureAnims = {
        M1Time = 0.6
    },

    WingChun = {
        M1Time = 0.6
    },

    HakariOtherAnims = {
        M1Time = 0.6
    },

    Debug = {}

}


--// =========================================================
--// HELPER FUNCTIONS
--// =========================================================

function Config:IsDebug()

    return self.Debug == true

end


function Config:GetReactionTime()

    return self.DefaultReactionTime

end


function Config:GetParryRange()

    return self.Parry.MaxDistance

end


function Config:GetTargetRange()

    return self.Targeting.MaxDistance

end


--// =========================================================
--// RETURN
--// =========================================================

return Config
