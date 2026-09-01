--// ParryController.lua
--// Gakuran Script - Parry Controller

local ParryController = {}

ParryController.State = nil
ParryController.Config = nil
ParryController.AnimationTracker = nil
ParryController.TargetManager = nil

ParryController.Connections = {}

--==================================================
-- State
--==================================================

ParryController.CurrentState = "idle"
ParryController.LastParryTime = 0
ParryController.LastInputTime = 0
ParryController.PendingData = nil

--==================================================
-- Initialization
--==================================================

function ParryController:Initialize(
    State,
    Config,
    AnimationTracker,
    TargetManager
)
    self.State = State
    self.Config = Config
    self.AnimationTracker = AnimationTracker
    self.TargetManager = TargetManager

    table.clear(self.Connections)

    self.CurrentState = "idle"
    self.LastParryTime = 0
    self.LastInputTime = 0
    self.PendingData = nil
end

--==================================================
-- State Management
--==================================================

function ParryController:SetState(newState)
    self.CurrentState = newState

    if self.State then
        self.State.CurrentParryState = newState
    end
end

function ParryController:GetState()
    return self.CurrentState
end

--==================================================
-- Timing
--==================================================

function ParryController:GetReactionTime()
    if not self.Config then
        return 0
    end

    if self.Config.Parry then
        return self.Config.Parry.ReactionTime or 0
    end

    return 0
end

function ParryController:GetParryWindow()
    if not self.Config then
        return 0
    end

    if self.Config.Parry then
        return self.Config.Parry.ParryWindow or 0
    end

    return 0
end

--==================================================
-- Target
--==================================================

function ParryController:GetTarget()
    if not self.TargetManager then
        return nil
    end

    return self.TargetManager:GetCurrentTarget()
end

--==================================================
-- Animation Check
--==================================================

function ParryController:IsRelevantAnimation(animationId)
    if not animationId or not self.Config then
        return false
    end

    local animations = self.Config.Animations

    if not animations then
        return false
    end

    return animationId == animations.ParryingAnimation
        or animationId == animations.ParriedAnimation
        or animationId == animations.StunnedAnimation
        or animationId == animations.ParryFailed
end

--==================================================
-- Register Parry
--==================================================

function ParryController:RegisterParry(data)
    if not self.State or not self.State.Alive then
        return false
    end

    self.LastParryTime = os.clock()
    self.LastInputTime = os.clock()

    self.PendingData = data

    if self.State then
        self.State.ParryRegisteredTime = self.LastParryTime
        self.State.LastPendingRegData = data
    end

    self:SetState("parrying")

    return true
end

--==================================================
-- Reset
--==================================================

function ParryController:Reset()
    self.PendingData = nil
    self:SetState("idle")

    if self.State then
        self.State.LastPendingRegData = nil
    end
end

--==================================================
-- Update
--==================================================

function ParryController:Update()
    if not self.State or not self.State.Alive then
        return
    end

    if self.CurrentState == "parrying" then
        local elapsed = os.clock() - self.LastParryTime

        if elapsed >= self:GetParryWindow() then
            self:Reset()
        end
    end
end

--==================================================
-- Cleanup
--==================================================

function ParryController:Destroy()
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(self.Connections)

    self.PendingData = nil
    self.CurrentState = "idle"

    self.State = nil
    self.Config = nil
    self.AnimationTracker = nil
    self.TargetManager = nil
end

return ParryController
