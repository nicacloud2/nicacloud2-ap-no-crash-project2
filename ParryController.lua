--// ParryController.lua
--// Gakuran Parry Controller

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)
local AnimationTracker = require(script.Parent.AnimationTracker)
local TargetManager = require(script.Parent.TargetManager)

local ParryController = {}

--------------------------------------------------
--// State
--------------------------------------------------

ParryController.State = nil

ParryController.IsBlocking = false
ParryController.IsDodging = false
ParryController.LastParryTime = 0
ParryController.LastBlockTime = 0

ParryController.ParryCount = 0
ParryController.FailedParries = 0

--------------------------------------------------
--// Initialize
--------------------------------------------------

function ParryController:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Get Local Character
--------------------------------------------------

function ParryController:GetCharacter()
    return LocalPlayer.Character
end

--------------------------------------------------
--// Get Humanoid
--------------------------------------------------

function ParryController:GetHumanoid()
    local character = self:GetCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------
--// Block Start
--------------------------------------------------

function ParryController:BlockStart(timestamp, duration)
    if not Config.Parry.Enabled then
        return false
    end

    if self.IsBlocking then
        return false
    end

    self.IsBlocking = true
    self.LastBlockTime = timestamp or os.clock()

    --------------------------------------------------
    -- Hold F
    --------------------------------------------------

    VirtualInputManager:SendKeyEvent(
        true,
        Enum.KeyCode.F,
        false,
        game
    )

    --------------------------------------------------
    -- Optional automatic release
    --------------------------------------------------

    if duration then
        task.delay(duration, function()
            if self.IsBlocking then
                self:BlockEnd()
            end
        end)
    end

    return true
end

--------------------------------------------------
--// Block End
--------------------------------------------------

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

--------------------------------------------------
--// Dodge
--------------------------------------------------

function ParryController:Dodge()
    if self.IsDodging then
        return false
    end

    self.IsDodging = true

    --------------------------------------------------
    -- Press X
    --------------------------------------------------

    VirtualInputManager:SendKeyEvent(
        true,
        Enum.KeyCode.X,
        false,
        game
    )

    VirtualInputManager:SendKeyEvent(
        false,
        Enum.KeyCode.X,
        false,
        game
    )

    task.delay(0.15, function()
        self.IsDodging = false
    end)

    return true
end

--------------------------------------------------
--// Get Reaction Time
--------------------------------------------------

function ParryController:GetReactionTime(animationId)
    return AnimationDatabase:GetReactionTime(animationId)
end

--------------------------------------------------
--// Get Parry Window
--------------------------------------------------

function ParryController:GetParryWindow()
    return Config.Parry.ParryWindow
        or Config.ParryWindow
        or 0.2
end

--------------------------------------------------
--// Get Parry Offset
--------------------------------------------------

function ParryController:GetParryOffset()
    return Config.ParryOffset or 0
end

--------------------------------------------------
--// Calculate Parry Time
--------------------------------------------------

function ParryController:GetParryTime(animationId)
    local reactionTime =
        self:GetReactionTime(animationId)

    local parryWindow =
        self:GetParryWindow()

    local offset =
        self:GetParryOffset()

    return reactionTime
        - parryWindow
        + offset
end

--------------------------------------------------
--// Can Parry
--------------------------------------------------

function ParryController:CanParry(character)
    if not Config.Parry.Enabled then
        return false
    end

    if not character then
        return false
    end

    if not TargetManager:IsValidCharacter(character) then
        return false
    end

    if not TargetManager:IsInRange(
        character,
        Config.Parry.MaxDistance
    ) then
        return false
    end

    return true
end

--------------------------------------------------
--// Execute Parry
--------------------------------------------------

function ParryController:Parry(animationData)
    if not animationData then
        return false
    end

    local character = animationData.Character

    if not self:CanParry(character) then
        return false
    end

    --------------------------------------------------
    -- Prevent excessive parries
    --------------------------------------------------

    local now = os.clock()

    if now - self.LastParryTime < 0.05 then
        return false
    end

    self.LastParryTime = now
    self.ParryCount += 1

    --------------------------------------------------
    -- Start Block
    --------------------------------------------------

    self:BlockStart(
        now,
        Config.BlockHoldTime
    )

    return true
end

--------------------------------------------------
--// Process Animation
--------------------------------------------------

function ParryController:ProcessAnimation(animationData)
    if not animationData then
        return
    end

    local animationId =
        animationData.AnimationId

    --------------------------------------------------
    -- Ignore unknown animations
    --------------------------------------------------

    if not animationData.Known then
        return
    end

    --------------------------------------------------
    -- Parry Failed Animation
    --------------------------------------------------

    if AnimationTracker:IsParryFailedAnimation(
        animationId
    ) then

        self.FailedParries += 1

        if self.OnParryFailed then
            self.OnParryFailed(animationData)
        end

        return
    end

    --------------------------------------------------
    -- Parried Animation
    --------------------------------------------------

    if AnimationTracker:IsParriedAnimation(
        animationId
    ) then

        if self.OnParried then
            self.OnParried(animationData)
        end

        return
    end

    --------------------------------------------------
    -- Stunned Animation
    --------------------------------------------------

    if AnimationTracker:IsStunnedAnimation(
        animationId
    ) then

        if self.OnStunned then
            self.OnStunned(animationData)
        end

        return
    end

    --------------------------------------------------
    -- Parrying Animation
    --------------------------------------------------

    if AnimationTracker:IsParryingAnimation(
        animationId
    ) then

        if self.OnEnemyParrying then
            self.OnEnemyParrying(animationData)
        end

        return
    end

    --------------------------------------------------
    -- Normal Attack
    --------------------------------------------------

    self:EvaluateAttack(animationData)
end

--------------------------------------------------
--// Evaluate Attack
--------------------------------------------------

function ParryController:EvaluateAttack(animationData)
    if not animationData then
        return
    end

    local character =
        animationData.Character

    if not self:CanParry(character) then
        return
    end

    local reactionTime =
        animationData.ReactionTime
        or Config.DefaultReactionTime

    --------------------------------------------------
    -- Delay before parry
    --------------------------------------------------

    task.delay(
        math.max(0, reactionTime),
        function()

            if not Config.Parry.Enabled then
                return
            end

            if not self:CanParry(character) then
                return
            end

            self:Parry(animationData)
        end
    )
end

--------------------------------------------------
--// Animation Callback
--------------------------------------------------

function ParryController:ConnectAnimationTracker()
    AnimationTracker.OnAnimation =
        function(animationData)

            self:ProcessAnimation(
                animationData
            )
        end
end

--------------------------------------------------
--// Start
--------------------------------------------------

function ParryController:Start()
    if self.Running then
        return
    end

    self.Running = true

    self:ConnectAnimationTracker()
end

--------------------------------------------------
--// Stop
--------------------------------------------------

function ParryController:Stop()
    self.Running = false

    self:BlockEnd()
end

--------------------------------------------------
--// Reset
--------------------------------------------------

function ParryController:Reset()
    self:BlockEnd()

    self.IsDodging = false
    self.LastParryTime = 0
    self.LastBlockTime = 0

    self.ParryCount = 0
    self.FailedParries = 0
end

return ParryController
