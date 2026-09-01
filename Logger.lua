--// Logger.lua
--// Gakuran Script - Logging Utility

local Logger = {}

Logger.Enabled = true
Logger.Prefix = "[Gakuran]"

--==================================================
-- Configuration
--==================================================

function Logger:Initialize(Config)
    self.Enabled = true

    if Config and Config.Debug ~= nil then
        self.Enabled = Config.Debug
    end
end

--==================================================
-- Format Message
--==================================================

function Logger:Format(...)
    local parts = {}

    for _, value in ipairs({ ... }) do
        table.insert(parts, tostring(value))
    end

    return self.Prefix .. " " .. table.concat(parts, " ")
end

--==================================================
-- Info
--==================================================

function Logger:Info(...)
    if not self.Enabled then
        return
    end

    print(self:Format(...))
end

--==================================================
-- Debug
--==================================================

function Logger:Debug(...)
    if not self.Enabled then
        return
    end

    print(self:Format("[DEBUG]", ...))
end

--==================================================
-- Warning
--==================================================

function Logger:Warn(...)
    warn(self:Format("[WARN]", ...))
end

--==================================================
-- Error
--==================================================

function Logger:Error(...)
    warn(self:Format("[ERROR]", ...))
end

--==================================================
-- Animation Logging
--==================================================

function Logger:Animation(playerName, animationId)
    if not self.Enabled then
        return
    end

    print(
        self:Format(
            "[ANIMATION]",
            tostring(playerName),
            "->",
            tostring(animationId)
        )
    )
end

--==================================================
-- Parry Logging
--==================================================

function Logger:Parry(...)
    if not self.Enabled then
        return
    end

    print(self:Format("[PARRY]", ...))
end

return Logger
