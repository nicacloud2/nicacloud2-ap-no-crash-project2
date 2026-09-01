--// Gakuran Modular Project
--// ParryController.lua

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)
local AnimationTracker = require(script.Parent.AnimationTracker)
local TargetManager = require(script.Parent.TargetManager)

local ParryController = {}

--==================================================
-- STATE
--==================================================

ParryController.State = nil

ParryController.IsBlocking = false
ParryController.IsDodging = false

ParryController.LastParryTime = 0
ParryController.LastBlockTime = 0

ParryController.ParryCount = 0
ParryController.FailedParries = 0

ParryController.AnimationListener = nil

--==================================================
-- INITIALIZE
--==================================================

function ParryController:Initialize(State)

    self.State = State

    self.IsBlocking = false
    self.IsDodging = false

    self.LastParryTime = 0
    self.LastBlockTime = 0

    self.ParryCount = 0
    self.FailedParries = 0

    self.AnimationListener = nil

end

--==================================================
-- CHARACTER
--==================================================

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

--==================================================
-- BLOCK
--==================================================

function ParryController:BlockStart(timestamp, duration)

    if self.IsBlocking then
        return
    end

    local humanoid = self:GetHumanoid()

    if not humanoid or humanoid.Health <= 0 then
        return
    end

    self.IsBlocking = true
    self.LastBlockTime = timestamp or os.clock()

    VirtualInputManager:SendKeyEvent(
        true,
        Enum.KeyCode.F,
        false,
        game
    )

    if duration then

        task.delay(duration, function()

            if self.IsBlocking then
                self:BlockEnd()
            end

        end)

    end

end

--==================================================
-- BLOCK END
--==================================================

function ParryController:BlockEnd()

    if not self.IsBlocking then
        return
    end

    self.IsBlocking = false

    VirtualInputManager:SendKeyEvent(
        false,
        Enum.KeyCode.F,
        false,
        game
    )

end

--==================================================
-- DODGE
--==================================================

function ParryController:Dodge()

    if self.IsDodging then
        return
    end

    local humanoid = self:GetHumanoid()

    if not humanoid or humanoid.Health <= 0 then
        return
    end

    self.IsDodging = true

    VirtualInputManager:SendKeyEvent(
        true,
        Enum.KeyCode.X,
        false,
        game
    )

    task.wait(0.05)

    VirtualInputManager:SendKeyEvent(
        false,
        Enum.KeyCode.X,
        false,
        game
    )

    self.IsDodging = false

end

--==================================================
-- SETTINGS
--==================================================

function ParryController:GetReactionTime(animationData)

    if not animationData then
        return Config.DefaultReactionTime
    end

    return animationData.ReactionTime
        or animationData.DefaultReactionTime
        or Config.DefaultReactionTime

end

function ParryController:GetParryWindow()

    return Config.ParryWindow

end

function ParryController:GetParryOffset()

    return Config.ParryOffset

end

function ParryController:GetBlockHoldTime()

    return Config.BlockHoldTime

end

--==================================================
-- PARry TIME
--==================================================

function ParryController:GetParryTime(animationData)

    local reactionTime = self:GetReactionTime(animationData)

    local offset = self:GetParryOffset()

    return math.max(
        0,
        reactionTime + offset
    )

end

--==================================================
-- CAN PARRY
--==================================================

function ParryController:CanParry(animationData)

    if not animationData then
        return false
    end

    if not Config.Parry.Enabled then
        return false
    end

    local character = animationData.Character

    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    local localHumanoid = self:GetHumanoid()

    if not localHumanoid or localHumanoid.Health <= 0 then
        return false
    end

    -- Don't react to our own animations
    if character == self:GetCharacter() then
        return false
    end

    -- Target distance check
    local distance = TargetManager:GetDistance(character)

    if distance and distance > Config.Parry.MaxDistance then
        return false
    end

    return true

end

--==================================================
-- PARry
--==================================================

function ParryController:Parry(animationData)

    if not self:CanParry(animationData) then
        return false
    end

    local now = os.clock()

    if now - self.LastParryTime < self:GetParryWindow() then
        return false
    end

    self.LastParryTime = now
    self.ParryCount += 1

    self:BlockStart(now, self:GetBlockHoldTime())

    return true

end

--==================================================
-- PROCESS ANIMATION
--==================================================

function ParryController:ProcessAnimation(animationData)

    if not animationData then
        return
    end

    local animationId = animationData.AnimationId

    if not animationId then
        return
    end

    --==============================================
    -- OUR CHARACTER
    --==============================================

    if animationData.Character == self:GetCharacter() then
        return
    end

    --==============================================
    -- PARRIED / STUNNED / FAILED STATES
    --==============================================

    if AnimationTracker:IsParriedAnimation(animationId) then
        return
    end

    if AnimationTracker:IsStunnedAnimation(animationId) then
        return
    end

    if AnimationTracker:IsParryFailedAnimation(animationId) then

        self.FailedParries += 1

        return

    end

    --==============================================
    -- ENEMY PARRYING
    --==============================================

    if AnimationTracker:IsParryingAnimation(animationId) then
        return
    end

    --==============================================
    -- ATTACK
    --==============================================

    self:EvaluateAttack(animationData)

end

--==================================================
-- EVALUATE ATTACK
--==================================================

function ParryController:EvaluateAttack(animationData)

    if not self:CanParry(animationData) then
        return
    end

    local databaseData =
        AnimationDatabase:Get(animationData.AnimationId)

    if not databaseData then
        return
    end

    --==============================================
    -- SPECIAL PARRY FUNCTION
    --==============================================

    if databaseData.ParryFunction then

        local success, err = pcall(function()

            databaseData.ParryFunction(animationData)

        end)

        if not success then

            warn(
                "[ParryController] ParryFunction error:",
                err
            )

        end

        return

    end

    --==============================================
    -- NORMAL PARRY
    --==============================================

    local parryDelay =
        self:GetParryTime(animationData)

    task.delay(parryDelay, function()

        if not self.State or not self.State.Running then
            return
        end

        self:Parry(animationData)

    end)

end

--==================================================
-- ANIMATION TRACKER CONNECTION
--==================================================

function ParryController:ConnectAnimationTracker()

    if self.AnimationListener then
        return
    end

    self.AnimationListener = function(animationData)

        self:ProcessAnimation(animationData)

    end

    AnimationTracker:AddListener(
        self.AnimationListener
    )

end

--==================================================
-- DISCONNECT
--==================================================

function ParryController:DisconnectAnimationTracker()

    if not self.AnimationListener then
        return
    end

    AnimationTracker:RemoveListener(
        self.AnimationListener
    )

    self.AnimationListener = nil

end

--==================================================
-- START
--==================================================

function ParryController:Start()

    if not Config.Parry.Enabled then
        return
    end

    self:ConnectAnimationTracker()

end

--==================================================
-- STOP
--==================================================

function ParryController:Stop()

    self:DisconnectAnimationTracker()

    self:BlockEnd()

    self.IsDodging = false

end

--==================================================
-- RESET
--==================================================

function ParryController:Reset()

    self:Stop()

    self.LastParryTime = 0
    self.LastBlockTime = 0

    self.ParryCount = 0
    self.FailedParries = 0

    self.IsBlocking = false
    self.IsDodging = false

end

return ParryController
