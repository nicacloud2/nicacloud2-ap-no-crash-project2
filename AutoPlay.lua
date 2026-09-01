--// =========================================================
--// GAKURAN - AUTOPLAY
--// GitHub / Matcha Version
--// MATCHA SAFE VERSION
--// =========================================================

local Players = game:GetService("Players")

local AutoPlay = {}

--// =========================================================
--// DEPENDENCIES
--// =========================================================

local Config = nil
local TargetManager = nil
local ParryController = nil


--// =========================================================
--// STATE
--// =========================================================

AutoPlay.State = {
    Running = false,
    Enabled = false
}

AutoPlay.LastAction = 0
AutoPlay.ActionCooldown = 0.1
AutoPlay.ProcessInterval = 0.03


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function AutoPlay:SetDependencies(
    config,
    targetManager,
    parryController
)

    Config = config
    TargetManager = targetManager
    ParryController = parryController

    print("[AutoPlay] Dependencies received.")
end


--// =========================================================
--// INITIALIZE
--// =========================================================

function AutoPlay:Initialize(state)

    self.SharedState = state

    print("[AutoPlay] Initialized.")
end


--// =========================================================
--// LOCAL CHARACTER
--// =========================================================

function AutoPlay:GetCharacter()

    local player =
        Players.LocalPlayer

    if not player then
        return nil
    end

    return player.Character
end


function AutoPlay:GetHumanoid()

    local character =
        self:GetCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end


--// =========================================================
--// TARGET
--// =========================================================

function AutoPlay:GetTarget()

    if not TargetManager then
        return nil
    end

    if type(TargetManager.GetCurrentTarget) ~= "function" then
        return nil
    end

    local success, target =
        pcall(function()

            return TargetManager:GetCurrentTarget()

        end)

    if success then
        return target
    end

    return nil
end


--// =========================================================
--// TARGET CHARACTER
--// =========================================================

function AutoPlay:GetTargetCharacter()

    local target =
        self:GetTarget()

    if not target then
        return nil
    end


    --// Player target

    if typeof(target) == "Instance" then

        if target:IsA("Player") then
            return target.Character
        end

        if target:IsA("Model") then
            return target
        end

    end

    return nil
end


--// =========================================================
--// CHECK TARGET
--// =========================================================

function AutoPlay:HasTarget()

    local character =
        self:GetTargetCharacter()

    if not character then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return false
    end

    return humanoid.Health > 0
end


--// =========================================================
--// ATTACK
--// =========================================================

function AutoPlay:Attack()

    if not self.State.Running then
        return false
    end

    if not self.State.Enabled then
        return false
    end


    local now =
        os.clock()

    if now - self.LastAction
        < self.ActionCooldown
    then

        return false

    end


    self.LastAction = now


    --// =====================================================
    --// MATCHA INPUT
    --// =====================================================

    local VirtualInputManager = nil

    pcall(function()

        VirtualInputManager =
            game:GetService(
                "VirtualInputManager"
            )

    end)


    if not VirtualInputManager then

        warn(
            "[AutoPlay] VirtualInputManager unavailable."
        )

        return false
    end


    local success =
        pcall(function()

            VirtualInputManager:SendMouseButtonEvent(
                0,
                0,
                0,
                true,
                game,
                0
            )

            task.wait(0.03)

            VirtualInputManager:SendMouseButtonEvent(
                0,
                0,
                0,
                false,
                game,
                0
            )

        end)


    return success
end


--// =========================================================
--// BLOCK
--// =========================================================

function AutoPlay:Block()

    if not self.State.Running then
        return false
    end

    if not self.State.Enabled then
        return false
    end


    if ParryController
        and type(ParryController.BlockStart)
            == "function"
    then

        local success =
            pcall(function()

                ParryController:BlockStart(
                    os.clock(),
                    0.27
                )

            end)

        return success
    end

    return false
end


--// =========================================================
--// DODGE
--// =========================================================

function AutoPlay:Dodge()

    if not self.State.Running then
        return false
    end

    if not self.State.Enabled then
        return false
    end


    if ParryController
        and type(ParryController.Dodge)
            == "function"
    then

        local success =
            pcall(function()

                ParryController:Dodge()

            end)

        return success
    end

    return false
end


--// =========================================================
--// TOGGLE
--// =========================================================

function AutoPlay:SetEnabled(enabled)

    self.State.Enabled =
        enabled == true

    print(
        "[AutoPlay] Enabled:",
        self.State.Enabled
    )
end


function AutoPlay:IsEnabled()

    return self.State.Enabled
end


--// =========================================================
--// PROCESS
--// =========================================================

function AutoPlay:Process()

    if not self.State.Running then
        return
    end

    if not self.State.Enabled then
        return
    end


    if not self:HasTarget() then
        return
    end


    --// Attack

    self:Attack()
end


--// =========================================================
--// PROCESS LOOP
--// =========================================================

function AutoPlay:StartProcessLoop()

    if self.ProcessLoopRunning then
        return
    end

    self.ProcessLoopRunning = true


    task.spawn(function()

        while self.State.Running do

            if self.State.Enabled then

                pcall(function()

                    self:Process()

                end)

            end

            task.wait(
                self.ProcessInterval
            )
        end


        self.ProcessLoopRunning = false

    end)

end


--// =========================================================
--// START
--// =========================================================

function AutoPlay:Start()

    if self.State.Running then
        return
    end


    self.State.Running = true


    self:StartProcessLoop()


    print("[AutoPlay] Started.")
    print("[AutoPlay] Process loop started.")
end


--// =========================================================
--// STOP
--// =========================================================

function AutoPlay:Stop()

    if not self.State.Running then
        return
    end


    self.State.Running = false


    print("[AutoPlay] Stopped.")
end


--// =========================================================
--// RESET
--// =========================================================

function AutoPlay:Reset()

    self.LastAction = 0
    self.State.Enabled = false

end


--// =========================================================
--// MATCHA MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult = AutoPlay

return AutoPlay
