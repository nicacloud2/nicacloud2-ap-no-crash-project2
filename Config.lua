--// =========================================================
--// GAKURAN - CONFIG
--// =========================================================

print("[Config] FILE EXECUTED")

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

Config.IgnoreIds = {}

--// =========================================================
--// ANIMATION DATABASE
--// =========================================================

Config.GameConfig = {


["KarateAnims"] = {
    ["rbxassetid://137837926745158"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://100981571094705"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://130865087635587"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://86495068205420"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://120393553812903"] = {
        DisplayName = "M2",
        ReactionTime = 0.3
    }
},

["AliAnims"] = {
    ["rbxassetid://137247073345979"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.12
    },
    ["rbxassetid://102632933427597"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://119814294807778"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.21
    },
    ["rbxassetid://74315946602284"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.11
    },
    ["rbxassetid://128315752013166"] = {
        DisplayName = "M2",
        ReactionTime = 0.34
    },
    ["rbxassetid://70642098724811"] = {
        DisplayName = "M2Right",
        ReactionTime = 0.34
    }
},

["BasicAnims"] = {
    ["rbxassetid://83491849294956"] = {
        DisplayName = "1stM1"
    },
    ["rbxassetid://89420531853362"] = {
        DisplayName = "2ndM1"
    },
    ["rbxassetid://83730275893449"] = {
        DisplayName = "3rdM1"
    },
    ["rbxassetid://106980660082799"] = {
        DisplayName = "4thM1"
    },
    ["rbxassetid://78888626472394"] = {
        DisplayName = "M2",
        ReactionTime = 0.3
    },
    ["M1Time"] = 0.14
},

["WrestlingAnims"] = {
    ["rbxassetid://91485623489753"] = {
        DisplayName = "4thM1"
    },
    ["rbxassetid://73748315742870"] = {
        DisplayName = "M2",
        ReactionTime = 0.3
    },
    ["rbxassetid://82903450925391"] = {
        DisplayName = "1stM1"
    },
    ["rbxassetid://119685134442395"] = {
        DisplayName = "2ndM1"
    },
    ["rbxassetid://107464726433388"] = {
        DisplayName = "3rdM1"
    },
    ["M1Time"] = 0.15
},

["MuayThaiAnims"] = {
    ["rbxassetid://137034747040618"] = {
        DisplayName = "M2",
        ReactionTime = 0.3
    },
    ["rbxassetid://74960202100098"] = {
        DisplayName = "4thM1",
        ParryTime = 0.08
    },
    ["rbxassetid://104515319350296"] = {
        DisplayName = "3rdM1",
        ParryTime = 0.08
    },
    ["rbxassetid://139911027872047"] = {
        DisplayName = "2ndM1",
        ParryTime = 0.08
    },
    ["rbxassetid://96726284968458"] = {
        DisplayName = "1stM1",
        ParryTime = 0.08
    },
    ["M1Time"] = 0.1
},

["BoxingAnims"] = {
    ["rbxassetid://137980914350618"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://100408082509740"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://94803478352691"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://78695517680318"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://132022052139564"] = {
        DisplayName = "M2"
    }
},

["HakariAnims"] = {
    ["rbxassetid://82855179231529"] = {
        DisplayName = "MomentumM2"
    },
    ["rbxassetid://92865171012109"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://103026596903060"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://86626533783115"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://103100834246116"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.21
    },
    ["rbxassetid://103359839046574"] = {
        DisplayName = "M2",
        ReactionTime = 0.19
    }
},

["CapoeiraAnims"] = {
    ["rbxassetid://125976167173936"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.15
    },
    ["rbxassetid://134945199381140"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.22
    },
    ["rbxassetid://117877243065533"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://106965238908791"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://131071815103338"] = {
        DisplayName = "Whirlwind",
        ReactionTime = 0.32
    }
},

["SluggerAnims"] = {
    ["rbxassetid://134829666925953"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.24
    },
    ["rbxassetid://104867156139010"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.22
    },
    ["rbxassetid://112759168172605"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.22
    },
    ["rbxassetid://114647502301740"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.19
    },
    ["rbxassetid://118943955490014"] = {
        DisplayName = "M2",
        ReactionTime = 0.65
    }
},

["StrikerAnims"] = {
    ["rbxassetid://127909081017342"] = {
        DisplayName = "1stM1"
    },
    ["rbxassetid://79563637573277"] = {
        DisplayName = "2ndM1"
    },
    ["rbxassetid://118070233153900"] = {
        DisplayName = "3rdM1"
    },
    ["rbxassetid://77710266587706"] = {
        DisplayName = "4thM1"
    },
    ["rbxassetid://114364673509520"] = {
        DisplayName = "M2"
    },
    ["rbxassetid://132840225082238"] = {
        DisplayName = "1stM1"
    },
    ["rbxassetid://88761422474765"] = {
        DisplayName = "2ndM1"
    },
    ["rbxassetid://98462236639320"] = {
        DisplayName = "3rdM1"
    },
    ["rbxassetid://122451562066756"] = {
        DisplayName = "4thM1"
    },
    ["rbxassetid://116642061934550"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.20
    },
    ["rbxassetid://115234849770695"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.18
    },
    ["rbxassetid://85554794950365"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.05
    },
    ["rbxassetid://73777821288331"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.05
    },
    ["rbxassetid://99309341097380"] = {
        DisplayName = "M2",
        ReactionTime = 0.30
    }
},

["KickboxingAnims"] = {
    ["rbxassetid://98742118383189"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.17
    },
    ["rbxassetid://110253681998213"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.18
    },
    ["rbxassetid://101589705199990"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.19
    },
    ["rbxassetid://117387938117515"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.242
    },
    ["rbxassetid://97063158605646"] = {
        DisplayName = "M2",
        ReactionTime = 0.287
    }
},

["KyokushinAnims"] = {
    ["rbxassetid://107487621377655"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.10
    },
    ["rbxassetid://109241234618849"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.10
    },
    ["rbxassetid://110289714004386"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.14
    },
    ["rbxassetid://91198472406870"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.24
    },
    ["rbxassetid://129982299748710"] = {
        DisplayName = "M2",
        ReactionTime = 0.25
    }
},

["CQCAnims"] = {
    ["rbxassetid://115957047639796"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.20
    },
    ["rbxassetid://139153666059747"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.20
    },
    ["rbxassetid://96433631480947"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.10
    },
    ["rbxassetid://119132409702905"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.24
    },
    ["rbxassetid://135110210666200"] = {
        DisplayName = "M2",
        ReactionTime = 0.30
    },
    ["rbxassetid://72310116631906"] = {
        DisplayName = "M2",
        ReactionTime = 0.30
    },
    ["rbxassetid://103319500580356"] = {
        DisplayName = "M2",
        ReactionTime = 0.30
    }
},

["KureAnims"] = {
    ["rbxassetid://71676634048602"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://88619229552579"] = {
        DisplayName = "Ook",
        ReactionTime = 0.10
    },
    ["rbxassetid://82904229252991"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://103732110215321"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://103964436023727"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.16
    }
},

["WingChun"] = {
    ["rbxassetid://81810173569294"] = {
        DisplayName = "4thM1",
        ReactionTime = 0.52
    },
    ["rbxassetid://82196924299426"] = {
        DisplayName = "M2",
        ReactionTime = 0.06
    },
    ["rbxassetid://71178147313608"] = {
        DisplayName = "1stM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://117898175201201"] = {
        DisplayName = "2ndM1",
        ReactionTime = 0.16
    },
    ["rbxassetid://121315597867666"] = {
        DisplayName = "3rdM1",
        ReactionTime = 0.16
    }
},

["HakariOtherAnims"] = {
    ["rbxassetid://126612786608030"] = {
        DisplayName = "1stM1"
    },
    ["rbxassetid://113719263885794"] = {
        DisplayName = "2ndM1"
    },
    ["rbxassetid://136305578634960"] = {
        DisplayName = "3rdM1"
    },
    ["rbxassetid://89039586375625"] = {
        DisplayName = "4thM1"
    },
    ["rbxassetid://82855179231529"] = {
        DisplayName = "MomentumM2"
    },
    ["rbxassetid://101619248052969"] = {
        DisplayName = "M2"
    }
},

["Debug"] = {
    ["http://www.roblox.com/asset/?id=125750702"] = {
        DisplayName = "M1",
        ReactionTime = 0.3
    }
}


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
--// FINAL TEST
--// =========================================================

print("[Config] About to return Config")
print("[Config] Config type:", type(Config))
print("[Config] Debug:", Config.Debug)
print("[Config] Parry range:", Config.Parry.MaxDistance)
print("[Config] Target range:", Config.Targeting.MaxDistance)

--// =========================================================
--// RETURN
--// =========================================================

_G.__GakuranModuleResult = Config
return Config
