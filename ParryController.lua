--// =========================================================
--// GAKURAN - PARRY CONTROLLER
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local ParryController = {}

--// Dependencies are injected by Main.lua
local Config = nil
local AnimationDatabase = nil
local AnimationTracker = nil
local TargetManager = nil


--// =========================================================
--// STATE
--// =========================================================

ParryController.State = {
    Running = false
}

ParryController.IsBlocking = false
ParryController.IsDodging = false

ParryController.LastParryTime = 0
ParryController.LastBlockTime = 0

ParryController.ParryCount = 0
ParryController.FailedParries = 0

ParryController.AnimationListener = nil


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function ParryController:SetDependencies(
    config,
    animationDatabase,
    animationTracker,
    targetManager
)

    Config = config
    AnimationDatabase = animationDatabase
    AnimationTracker = animationTracker
    TargetManager = targetManager

end


--// =========================================================
--// INITIALIZE
--// =========================================================

function ParryController:Initialize(state)

    self.SharedState = state

    print("[ParryController] Initialized.")

end


--// =========================================================
--// CHARACTER
--// =========================================================

function ParryController:GetCharacter()

    local player = Players.LocalPlayer

    if not player then
        return nil
    end

    return player.Character

end


function ParryController:GetHumanoid()

    local character = self:GetCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")

end


--// =========================================================
--// BLOCK
--// =========================================================

function ParryController:BlockStart(timestamp, duration)

    if self.IsBlocking then
        return
    end

    if not self.State.Running then
        return
    end


    self.IsBlocking = true
    self.LastBlockTime = os.clock()


    --// Press F

    pcall(function()

        VirtualInputManager:SendKeyEvent(
            true,
            Enum.KeyCode.F,
            false,
            game
        )

    end)


    local holdTime =
        duration
        or (
            Config
            and Config.BlockHoldTime
        )
        or 0.27


    task.delay(holdTime, function()

        if self.IsBlocking then
            self:BlockEnd()
        end

    end)

end


function ParryController:BlockEnd()

    if not self.IsBlocking then
        return
    end


    self.IsBlocking = false


    pcall(function()

        VirtualInputManager:SendKeyEvent(
            false,
            Enum.KeyCode.F,
            false,
            game
        )

    end)

end


--// =========================================================
--// DODGE
--// =========================================================

function ParryController:Dodge()

    if self.IsDodging then
        return
    end

    if not self.State.Running then
        return
    end


    self.IsDodging = true


    pcall(function()

        VirtualInputManager:SendKeyEvent(
            true,
            Enum.KeyCode.X,
            false,
            game
        )

    end)


    task.wait(0.05)


    pcall(function()

        VirtualInputManager:SendKeyEvent(
            false,
            Enum.KeyCode.X,
            false,
            game
        )

    end)


    self.IsDodging = false

end


--// =========================================================
--// REACTION TIME
--// =========================================================

function ParryController:GetReactionTime(animationData)

    if not animationData then

        return (
            Config
            and Config.DefaultReactionTime
        )
        or 0.1

    end


    if animationData.ReactionTime then
        return animationData.ReactionTime
    end


    if animationData.DefaultReactionTime then
        return animationData.DefaultReactionTime
    end


    if AnimationDatabase
        and animationData.AnimationId then

        return AnimationDatabase:GetReactionTime(
            animationData.AnimationId
        )

    end


    return (
        Config
        and Config.DefaultReactionTime
    )
    or 0.1

end


--// =========================================================
--// PARRY WINDOW
--// =========================================================

function ParryController:GetParryWindow()

    return (
        Config
        and Config.Parry
        and Config.Parry.Window
    )
    or 0.2

end


function ParryController:GetParryOffset()

    return (
        Config
        and Config.Parry
        and Config.Parry.Offset
    )
    or 0

end


function ParryController:GetBlockHoldTime()

    return (
        Config
        and Config.Parry
        and Config.Parry.BlockHoldTime
    )
    or 0.27

end


--// =========================================================
--// PARRY TIME
--// =========================================================

function ParryController:GetParryTime(animationData)

    local reactionTime =
        self:GetReactionTime(animationData)

    local parryWindow =
        self:GetParryWindow()

    local offset =
        self:GetParryOffset()


    return reactionTime
        - (parryWindow / 2)
        + offset

end


--// =========================================================
--// DISTANCE
--// =========================================================

function ParryController:GetDistance(character)

    local localCharacter =
        self:GetCharacter()

    if not localCharacter or not character then
        return math.huge
    end


    local localRoot =
        localCharacter:FindFirstChild("HumanoidRootPart")

    local targetRoot =
        character:FindFirstChild("HumanoidRootPart")


    if not localRoot or not targetRoot then
        return math.huge
    end


    return (
        localRoot.Position
        - targetRoot.Position
    ).Magnitude

end


--// =========================================================
--// CAN PARRY
--// =========================================================

function ParryController:CanParry(animationData)

    if not self.State.Running then
        return false
    end


    if Config
        and Config.Parry
        and Config.Parry.Enabled == false then

        return false

    end


    if not animationData then
        return false
    end


    local localPlayer =
        Players.LocalPlayer


    if animationData.Player
        and animationData.Player == localPlayer then

        return false

    end


    local character =
        animationData.Character


    if not character then
        return false
    end


    local humanoid =
        character:FindFirstChildOfClass("Humanoid")


    if not humanoid
        or humanoid.Health <= 0 then

        return false

    end


    local localHumanoid =
        self:GetHumanoid()


    if not localHumanoid
        or localHumanoid.Health <= 0 then

        return false

    end


    local maxDistance =
        (
            Config
            and Config.Parry
            and Config.Parry.MaxDistance
        )
        or 10


    if self:GetDistance(character)
        > maxDistance then

        return false

    end


    return true

end


--// =========================================================
--// PARRY
--// =========================================================

function ParryController:Parry(animationData)

    if not self:CanParry(animationData) then
        return false
    end


    local now = os.clock()


    self.LastParryTime = now
    self.ParryCount += 1


    self:BlockStart(
        now,
        self:GetBlockHoldTime()
    )


    return true

end


--// =========================================================
--// PROCESS ANIMATION
--// =========================================================

function ParryController:ProcessAnimation(animationData)

    if not animationData then
        return
    end


    if not animationData.DatabaseData then
        return
    end


    if not self:CanParry(animationData) then
        return
    end


    local databaseData =
        animationData.DatabaseData


    --// Custom parry callback

    if databaseData.ParryFunction then

        local success, err =
            pcall(function()

                databaseData.ParryFunction(
                    animationData
                )

            end)


        if not success then

            warn(
                "[ParryController] " ..
                "ParryFunction error:",
                err
            )

        end


        return

    end


    local parryTime =
        self:GetParryTime(animationData)


    if parryTime < 0 then
        parryTime = 0
    end


    task.delay(parryTime, function()

        if not self.State.Running then
            return
        end


        self:Parry(animationData)

    end)

end


--// =========================================================
--// EVALUATE ATTACK
--// =========================================================

function ParryController:EvaluateAttack(animationData)

    if not animationData then
        return false
    end


    if not animationData.DatabaseData then
        return false
    end


    return self:CanParry(animationData)

end


--// =========================================================
--// CONNECT TRACKER
--// =========================================================

function ParryController:ConnectAnimationTracker()

    if not AnimationTracker then
        warn("[ParryController] AnimationTracker missing.")
        return
    end


    if self.AnimationListener then
        return
    end


    self.AnimationListener =
        function(animationData)

            self:ProcessAnimation(animationData)

        end


    AnimationTracker:AddListener(
        self.AnimationListener
    )

end


--// =========================================================
--// DISCONNECT TRACKER
--// =========================================================

function ParryController:DisconnectAnimationTracker()

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

function ParryController:Start()

    if self.State.Running then
        return
    end


    self.State.Running = true


    self:ConnectAnimationTracker()


    print("[ParryController] Started.")

end


--// =========================================================
--// STOP
--// =========================================================

function ParryController:Stop()

    if not self.State.Running then
        return
    end


    self.State.Running = false


    self:DisconnectAnimationTracker()

    self:BlockEnd()


    self.IsDodging = false


    print("[ParryController] Stopped.")

end


--// =========================================================
--// RESET
--// =========================================================

function ParryController:Reset()

    self.LastParryTime = 0
    self.LastBlockTime = 0

    self.ParryCount = 0
    self.FailedParries = 0

    self.IsBlocking = false
    self.IsDodging = false

end


--// =========================================================
--// RETURN
--// =========================================================

return ParryController
