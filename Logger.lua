--// Logger.lua
--// Gakuran Logging / Cache Module

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)
local AnimationTracker = require(script.Parent.AnimationTracker)

local Logger = {}

--------------------------------------------------
--// State
--------------------------------------------------

Logger.State = nil

Logger.AnimationsLoggedCache = {}
Logger.AnimationsLoggedOrder = {}

Logger.DamageLog = {}
Logger.Enabled = true

--------------------------------------------------
--// Initialize
--------------------------------------------------

function Logger:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Enable / Disable
--------------------------------------------------

function Logger:SetEnabled(enabled)
    self.Enabled = enabled == true
end

function Logger:IsEnabled()
    return self.Enabled
end

--------------------------------------------------
--// Animation Cache
--------------------------------------------------

function Logger:IsAnimationLogged(animationId)
    return self.AnimationsLoggedCache[animationId] == true
end

--------------------------------------------------
--// Log Animation
--------------------------------------------------

function Logger:LogAnimation(animationData)
    if not self.Enabled then
        return
    end

    if not animationData then
        return
    end

    local animationId =
        animationData.AnimationId

    if not animationId then
        return
    end

    --------------------------------------------------
    -- Prevent duplicate logs
    --------------------------------------------------

    if self:IsAnimationLogged(animationId) then
        return
    end

    self.AnimationsLoggedCache[animationId] = true

    table.insert(
        self.AnimationsLoggedOrder,
        animationId
    )

    --------------------------------------------------
    -- Console Output
    --------------------------------------------------

    local displayName =
        animationData.DisplayName
        or AnimationTracker:GetDisplayName(
            animationId
        )

    local style =
        animationData.Style
        or "Unknown"

    print(
        string.format(
            "[Animation] %s | %s | %s",
            displayName,
            animationId,
            style
        )
    )

    --------------------------------------------------
    -- Callback
    --------------------------------------------------

    if self.OnAnimationLogged then
        self.OnAnimationLogged(
            animationData
        )
    end
end

--------------------------------------------------
--// Force Log Animation
--------------------------------------------------

function Logger:ForceLogAnimation(animationData)
    if not animationData then
        return
    end

    local animationId =
        animationData.AnimationId

    if not animationId then
        return
    end

    self.AnimationsLoggedCache[animationId] = true

    table.insert(
        self.AnimationsLoggedOrder,
        animationId
    )

    print(
        "[Animation]",
        animationData.DisplayName
            or animationId
    )
end

--------------------------------------------------
--// Get Logged Animations
--------------------------------------------------

function Logger:GetLoggedAnimations()
    return self.AnimationsLoggedOrder
end

--------------------------------------------------
--// Get Animation Cache
--------------------------------------------------

function Logger:GetAnimationCache()
    return self.AnimationsLoggedCache
end

--------------------------------------------------
--// Clear Animation Cache
--------------------------------------------------

function Logger:ClearAnimationCache()
    self.AnimationsLoggedCache = {}
    self.AnimationsLoggedOrder = {}
end

--------------------------------------------------
--// Copy Logged Animations
--------------------------------------------------

function Logger:CopyLoggedAnimations()
    local output = {}

    for _, animationId in ipairs(
        self.AnimationsLoggedOrder
    ) do

        table.insert(
            output,
            tostring(animationId)
        )
    end

    local text =
        table.concat(
            output,
            "\n"
        )

    if setclipboard then
        setclipboard(text)
    end

    return text
end

--------------------------------------------------
--// Copy Ignore List
--------------------------------------------------

function Logger:CopyIgnoreList()
    local output = {}

    for _, animationId in ipairs(
        Config.IgnoreIds
    ) do

        table.insert(
            output,
            tostring(animationId)
        )
    end

    local text =
        table.concat(
            output,
            ","
        )

    if setclipboard then
        setclipboard(text)
    end

    return text
end

--------------------------------------------------
--// Add Ignore ID
--------------------------------------------------

function Logger:AddIgnoreId(animationId)
    if not animationId then
        return false
    end

    local numericId =
        tonumber(
            tostring(animationId):match("%d+")
        )

    if not numericId then
        return false
    end

    if table.find(
        Config.IgnoreIds,
        numericId
    ) then
        return false
    end

    table.insert(
        Config.IgnoreIds,
        numericId
    )

    return true
end

--------------------------------------------------
--// Remove Ignore ID
--------------------------------------------------

function Logger:RemoveIgnoreId(animationId)
    local numericId =
        tonumber(
            tostring(animationId):match("%d+")
        )

    if not numericId then
        return false
    end

    local index =
        table.find(
            Config.IgnoreIds,
            numericId
        )

    if not index then
        return false
    end

    table.remove(
        Config.IgnoreIds,
        index
    )

    return true
end

--------------------------------------------------
--// Damage Logging
--------------------------------------------------

function Logger:LogDamage(
    source,
    target,
    damage,
    extraData
)
    if not self.Enabled then
        return
    end

    local entry = {
        Time = os.clock(),

        Source = source,
        Target = target,

        Damage = damage,

        Data = extraData,
    }

    table.insert(
        self.DamageLog,
        entry
    )

    --------------------------------------------------
    -- Console
    --------------------------------------------------

    local sourceName =
        source
        and source.Name
        or "Unknown"

    local targetName =
        target
        and target.Name
        or "Unknown"

    print(
        string.format(
            "[Damage] %s -> %s : %s",
            sourceName,
            targetName,
            tostring(damage)
        )
    )

    --------------------------------------------------
    -- Callback
    --------------------------------------------------

    if self.OnDamageLogged then
        self.OnDamageLogged(entry)
    end

    return entry
end

--------------------------------------------------
--// Get Damage Log
--------------------------------------------------

function Logger:GetDamageLog()
    return self.DamageLog
end

--------------------------------------------------
--// Clear Damage Log
--------------------------------------------------

function Logger:ClearDamageLog()
    self.DamageLog = {}
end

--------------------------------------------------
--// Get Last Damage
--------------------------------------------------

function Logger:GetLastDamage()
    return self.DamageLog[
        #self.DamageLog
    ]
end

--------------------------------------------------
--// Export Damage Log
--------------------------------------------------

function Logger:ExportDamageLog()
    local output = {}

    for _, entry in ipairs(
        self.DamageLog
    ) do

        table.insert(
            output,
            string.format(
                "[%.3f] %s -> %s : %s",
                entry.Time,

                entry.Source
                    and entry.Source.Name
                    or "Unknown",

                entry.Target
                    and entry.Target.Name
                    or "Unknown",

                tostring(entry.Damage)
            )
        )
    end

    local text =
        table.concat(
            output,
            "\n"
        )

    if setclipboard then
        setclipboard(text)
    end

    return text
end

--------------------------------------------------
--// Log Unknown Animation
--------------------------------------------------

function Logger:LogUnknownAnimation(
    animationId,
    character
)
    if not self.Enabled then
        return
    end

    print(
        string.format(
            "[Unknown Animation] %s | Character: %s",
            tostring(animationId),
            character
                and character.Name
                or "Unknown"
        )
    )
end

--------------------------------------------------
--// Connect Animation Tracker
--------------------------------------------------

function Logger:ConnectAnimationTracker()
    AnimationTracker.OnAnimation =
        function(animationData)

            if not animationData.Known then
                self:LogUnknownAnimation(
                    animationData.AnimationId,
                    animationData.Character
                )
            end

            if Config.AnimationTracker.LogAnimations then
                self:LogAnimation(
                    animationData
                )
            end

        end
end

--------------------------------------------------
--// Reset
--------------------------------------------------

function Logger:Reset()
    self:ClearAnimationCache()
    self:ClearDamageLog()
end

return Logger
