--// =========================================================
--// GAKURAN - LOGGER
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")

local Logger = {}

--// Dependencies
local Config = nil
local AnimationDatabase = nil
local AnimationTracker = nil


--// =========================================================
--// STATE
--// =========================================================

Logger.State = {
    Running = false,
    Enabled = true
}

Logger.AnimationCache = {}
Logger.AnimationOrder = {}
Logger.DamageLog = {}

Logger.AnimationListener = nil


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function Logger:SetDependencies(
    config,
    animationDatabase,
    animationTracker
)

    Config = config
    AnimationDatabase = animationDatabase
    AnimationTracker = animationTracker

end


--// =========================================================
--// INITIALIZE
--// =========================================================

function Logger:Initialize(state)

    self.SharedState = state

    print("[Logger] Initialized.")

end


--// =========================================================
--// ENABLE / DISABLE
--// =========================================================

function Logger:SetEnabled(enabled)

    self.State.Enabled = enabled == true

end


function Logger:IsEnabled()

    return self.State.Enabled == true

end


--// =========================================================
--// CHECK ANIMATION
--// =========================================================

function Logger:IsAnimationLogged(animationId)

    if not animationId then
        return false
    end

    return self.AnimationCache[animationId] ~= nil

end


--// =========================================================
--// LOG ANIMATION
--// =========================================================

function Logger:LogAnimation(animationData)

    if not self.State.Enabled then
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


    if self:IsAnimationLogged(animationId) then
        return
    end


    self.AnimationCache[animationId] =
        animationData


    table.insert(
        self.AnimationOrder,
        animationId
    )


    local playerName = "Unknown"

    if animationData.Player then
        playerName =
            animationData.Player.Name
    end


    local displayName =
        animationData.DisplayName
        or "Unknown"


    local style =
        animationData.Style
        or "Unknown"


    print(
        string.format(
            "[Animation] %s | %s | %s | %s",
            playerName,
            displayName,
            style,
            animationId
        )
    )

end


--// =========================================================
--// FORCE LOG
--// =========================================================

function Logger:ForceLogAnimation(animationData)

    if not animationData then
        return
    end


    local animationId =
        animationData.AnimationId


    if not animationId then
        return
    end


    self.AnimationCache[animationId] =
        animationData


    local exists = false

    for _, id in ipairs(self.AnimationOrder) do

        if id == animationId then
            exists = true
            break
        end

    end


    if not exists then

        table.insert(
            self.AnimationOrder,
            animationId
        )

    end

end


--// =========================================================
--// GET LOGGED ANIMATIONS
--// =========================================================

function Logger:GetLoggedAnimations()

    return self.AnimationOrder

end


function Logger:GetAnimationCache()

    return self.AnimationCache

end


--// =========================================================
--// CLEAR ANIMATION CACHE
--// =========================================================

function Logger:ClearAnimationCache()

    table.clear(self.AnimationCache)
    table.clear(self.AnimationOrder)

end


--// =========================================================
--// COPY LOGGED ANIMATIONS
--// =========================================================

function Logger:CopyLoggedAnimations()

    local output = {}


    for _, animationId in ipairs(self.AnimationOrder) do

        table.insert(
            output,
            animationId
        )

    end


    if setclipboard then

        setclipboard(
            table.concat(
                output,
                "\n"
            )
        )

        print("[Logger] Animation IDs copied.")

    else

        print(
            "[Logger] Clipboard function unavailable."
        )

    end


    return output

end


--// =========================================================
--// COPY IGNORE LIST
--// =========================================================

function Logger:CopyIgnoreList()

    if not Config
        or not Config.IgnoreIds then

        return

    end


    local output =
        table.concat(
            Config.IgnoreIds,
            "\n"
        )


    if setclipboard then

        setclipboard(output)

        print("[Logger] Ignore list copied.")

    else

        print(
            "[Logger] Clipboard function unavailable."
        )

    end

end


--// =========================================================
--// ADD IGNORE ID
--// =========================================================

function Logger:AddIgnoreId(animationId)

    if not animationId then
        return false
    end


    if not Config then
        return false
    end


    Config.IgnoreIds =
        Config.IgnoreIds or {}


    for _, id in ipairs(Config.IgnoreIds) do

        if id == animationId then
            return false
        end

    end


    table.insert(
        Config.IgnoreIds,
        animationId
    )


    return true

end


--// =========================================================
--// REMOVE IGNORE ID
--// =========================================================

function Logger:RemoveIgnoreId(animationId)

    if not Config
        or not Config.IgnoreIds then

        return false

    end


    for index, id in ipairs(Config.IgnoreIds) do

        if id == animationId then

            table.remove(
                Config.IgnoreIds,
                index
            )

            return true

        end

    end


    return false

end


--// =========================================================
--// DAMAGE LOG
--// =========================================================

function Logger:LogDamage(data)

    if not self.State.Enabled then
        return
    end


    if type(data) ~= "table" then
        return
    end


    data.Timestamp =
        data.Timestamp
        or os.clock()


    table.insert(
        self.DamageLog,
        data
    )


    if #self.DamageLog > 1000 then

        table.remove(
            self.DamageLog,
            1
        )

    end

end


--// =========================================================
--// GET DAMAGE LOG
--// =========================================================

function Logger:GetDamageLog()

    return self.DamageLog

end


--// =========================================================
--// CLEAR DAMAGE LOG
--// =========================================================

function Logger:ClearDamageLog()

    table.clear(self.DamageLog)

end


--// =========================================================
--// LAST DAMAGE
--// =========================================================

function Logger:GetLastDamage()

    return self.DamageLog[
        #self.DamageLog
    ]

end


--// =========================================================
--// EXPORT DAMAGE LOG
--// =========================================================

function Logger:ExportDamageLog()

    local output = {}


    for _, data in ipairs(self.DamageLog) do

        local line = string.format(
            "[%.3f] %s",
            data.Timestamp or 0,
            data.Message
                or data.AnimationId
                or "Damage event"
        )


        table.insert(
            output,
            line
        )

    end


    local result =
        table.concat(
            output,
            "\n"
        )


    if setclipboard then

        setclipboard(result)

        print("[Logger] Damage log copied.")

    end


    return result

end


--// =========================================================
--// UNKNOWN ANIMATION
--// =========================================================

function Logger:LogUnknownAnimation(animationData)

    if not animationData then
        return
    end


    if animationData.AnimationId then

        print(
            "[Unknown Animation] " ..
            animationData.AnimationId
        )

    end

end


--// =========================================================
--// TRACKER CONNECTION
--// =========================================================

function Logger:ConnectAnimationTracker()

    if not AnimationTracker then

        warn(
            "[Logger] AnimationTracker missing."
        )

        return

    end


    if self.AnimationListener then
        return
    end


    self.AnimationListener =
        function(animationData)

            if not animationData then
                return
            end


            if animationData.DatabaseData then

                self:LogAnimation(
                    animationData
                )

            else

                self:LogUnknownAnimation(
                    animationData
                )

            end

        end


    AnimationTracker:AddListener(
        self.AnimationListener
    )

end


--// =========================================================
--// DISCONNECT TRACKER
--// =========================================================

function Logger:DisconnectAnimationTracker()

    if not AnimationTracker then
        return
    end


    if not self.AnimationListener then
        return
    end


    AnimationTracker:RemoveListener(
        self.AnimationListener
    )


    self.AnimationListener = nil

end


--// =========================================================
--// START
--// =========================================================

function Logger:Start()

    if self.State.Running then
        return
    end


    self.State.Running = true

    self:ConnectAnimationTracker()


    print("[Logger] Started.")

end


--// =========================================================
--// STOP
--// =========================================================

function Logger:Stop()

    if not self.State.Running then
        return
    end


    self.State.Running = false

    self:DisconnectAnimationTracker()


    print("[Logger] Stopped.")

end


--// =========================================================
--// RESET
--// =========================================================

function Logger:Reset()

    self:ClearAnimationCache()
    self:ClearDamageLog()

end


--// =========================================================
--// RETURN
--// =========================================================

return Logger
