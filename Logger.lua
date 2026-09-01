--// Gakuran Modular Project
--// Logger.lua

local Players = game:GetService("Players")

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)
local AnimationTracker = require(script.Parent.AnimationTracker)

local Logger = {}

--==================================================
-- STATE
--==================================================

Logger.State = nil
Logger.Enabled = true

Logger.AnimationListener = nil

Logger.AnimationsLoggedCache = {}
Logger.AnimationsLoggedOrder = {}

Logger.DamageLog = {}

--==================================================
-- INITIALIZE
--==================================================

function Logger:Initialize(State)

    self.State = State

    self.Enabled = true

    self.AnimationListener = nil

    self.AnimationsLoggedCache = {}
    self.AnimationsLoggedOrder = {}

    self.DamageLog = {}

end

--==================================================
-- ENABLE / DISABLE
--==================================================

function Logger:SetEnabled(enabled)

    self.Enabled = enabled == true

end

function Logger:IsEnabled()

    return self.Enabled

end

--==================================================
-- ANIMATION CACHE
--==================================================

function Logger:IsAnimationLogged(animationId)

    if not animationId then
        return false
    end

    return self.AnimationsLoggedCache[animationId] == true

end

--==================================================
-- LOG ANIMATION
--==================================================

function Logger:LogAnimation(animationData)

    if not self.Enabled then
        return
    end

    if not animationData then
        return
    end

    local animationId = animationData.AnimationId

    if not animationId then
        return
    end

    -- Prevent duplicate entries
    if self:IsAnimationLogged(animationId) then
        return
    end

    self.AnimationsLoggedCache[animationId] = true

    table.insert(
        self.AnimationsLoggedOrder,
        animationId
    )

    local displayName =
        animationData.DisplayName
        or AnimationDatabase:GetDisplayName(animationId)
        or "Unknown"

    local style =
        animationData.Style
        or AnimationDatabase:GetStyle(animationId)
        or "Unknown"

    print(
        string.format(
            "[AnimationLogger] %s | %s | %s",
            displayName,
            animationId,
            style
        )
    )

end

--==================================================
-- FORCE LOG
--==================================================

function Logger:ForceLogAnimation(animationData)

    if not animationData then
        return
    end

    local animationId = animationData.AnimationId

    if not animationId then
        return
    end

    self.AnimationsLoggedCache[animationId] = true

    table.insert(
        self.AnimationsLoggedOrder,
        animationId
    )

end

--==================================================
-- GET LOGGED ANIMATIONS
--==================================================

function Logger:GetLoggedAnimations()

    return self.AnimationsLoggedOrder

end

function Logger:GetAnimationCache()

    return self.AnimationsLoggedCache

end

--==================================================
-- CLEAR CACHE
--==================================================

function Logger:ClearAnimationCache()

    table.clear(self.AnimationsLoggedCache)
    table.clear(self.AnimationsLoggedOrder)

    print("[AnimationLogger] Animation cache cleared.")

end

--==================================================
-- COPY LOGGED ANIMATIONS
--==================================================

function Logger:CopyLoggedAnimations()

    local lines = {}

    for _, animationId in ipairs(self.AnimationsLoggedOrder) do

        local data =
            AnimationDatabase:Get(animationId)

        local displayName =
            data and data.DisplayName
            or "Unknown"

        local style =
            data and data.Style
            or "Unknown"

        table.insert(
            lines,
            string.format(
                '["%s"] = {DisplayName = "%s", Style = "%s"},',
                animationId,
                displayName,
                style
            )
        )

    end

    local output = table.concat(lines, "\n")

    if setclipboard then

        setclipboard(output)

        print("[AnimationLogger] Logged animations copied.")

    else

        warn(
            "[AnimationLogger] setclipboard is not available."
        )

    end

    return output

end

--==================================================
-- COPY IGNORE LIST
--==================================================

function Logger:CopyIgnoreList()

    local lines = {}

    for _, id in ipairs(Config.IgnoreIds) do

        table.insert(
            lines,
            tostring(id)
        )

    end

    local output =
        table.concat(lines, ",")

    if setclipboard then

        setclipboard(output)

        print("[AnimationLogger] Ignore list copied.")

    else

        warn(
            "[AnimationLogger] setclipboard is not available."
        )

    end

    return output

end

--==================================================
-- ADD IGNORE ID
--==================================================

function Logger:AddIgnoreId(animationId)

    local numericId =
        tonumber(
            string.match(
                tostring(animationId),
                "%d+"
            )
        )

    if not numericId then
        return false
    end

    for _, existingId in ipairs(Config.IgnoreIds) do

        if existingId == numericId then
            return false
        end

    end

    table.insert(
        Config.IgnoreIds,
        numericId
    )

    return true

end

--==================================================
-- REMOVE IGNORE ID
--==================================================

function Logger:RemoveIgnoreId(animationId)

    local numericId =
        tonumber(
            string.match(
                tostring(animationId),
                "%d+"
            )
        )

    if not numericId then
        return false
    end

    for i = #Config.IgnoreIds, 1, -1 do

        if Config.IgnoreIds[i] == numericId then

            table.remove(
                Config.IgnoreIds,
                i
            )

            return true

        end

    end

    return false

end

--==================================================
-- DAMAGE LOGGING
--==================================================

function Logger:LogDamage(data)

    if not data then
        return
    end

    local entry = {
        Timestamp = os.clock(),
        Damage = data.Damage,
        Target = data.Target,
        Source = data.Source,
        HealthBefore = data.HealthBefore,
        HealthAfter = data.HealthAfter,
    }

    table.insert(
        self.DamageLog,
        entry
    )

end

--==================================================
-- GET DAMAGE LOG
--==================================================

function Logger:GetDamageLog()

    return self.DamageLog

end

function Logger:GetLastDamage()

    return self.DamageLog[
        #self.DamageLog
    ]

end

--==================================================
-- CLEAR DAMAGE LOG
--==================================================

function Logger:ClearDamageLog()

    table.clear(self.DamageLog)

end

--==================================================
-- EXPORT DAMAGE LOG
--==================================================

function Logger:ExportDamageLog()

    local lines = {}

    for _, entry in ipairs(self.DamageLog) do

        local targetName = "Unknown"

        if typeof(entry.Target) == "Instance" then
            targetName = entry.Target.Name
        elseif entry.Target then
            targetName = tostring(entry.Target)
        end

        table.insert(
            lines,
            string.format(
                "[%.3f] %s | Damage: %s | HP: %s -> %s",
                entry.Timestamp,
                targetName,
                tostring(entry.Damage or "?"),
                tostring(entry.HealthBefore or "?"),
                tostring(entry.HealthAfter or "?")
            )
        )

    end

    local output =
        table.concat(lines, "\n")

    if setclipboard then

        setclipboard(output)

        print("[DamageLogger] Damage log copied.")

    else

        warn(
            "[DamageLogger] setclipboard is not available."
        )

    end

    return output

end

--==================================================
-- UNKNOWN ANIMATION
--==================================================

function Logger:LogUnknownAnimation(animationData)

    if not animationData then
        return
    end

    local animationId =
        animationData.AnimationId

    if not animationId then
        return
    end

    print(
        "[AnimationLogger] Unknown animation:",
        animationId
    )

end

--==================================================
-- ANIMATION TRACKER CONNECTION
--==================================================

function Logger:ConnectAnimationTracker()

    if self.AnimationListener then
        return
    end

    self.AnimationListener = function(animationData)

        if not self.Enabled then
            return
        end

        if not animationData then
            return
        end

        if animationData.DatabaseData then

            self:LogAnimation(animationData)

        else

            self:LogUnknownAnimation(animationData)

        end

    end

    AnimationTracker:AddListener(
        self.AnimationListener
    )

end

--==================================================
-- DISCONNECT
--==================================================

function Logger:DisconnectAnimationTracker()

    if not self.AnimationListener then
        return
    end

    AnimationTracker:RemoveListener(
        self.AnimationListener
    )

    self.AnimationListener = nil

end

--==================================================
-- RESET
--==================================================

function Logger:Reset()

    self:DisconnectAnimationTracker()

    self.AnimationsLoggedCache = {}
    self.AnimationsLoggedOrder = {}

    self.DamageLog = {}

end

return Logger
