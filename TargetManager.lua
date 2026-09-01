--// =========================================================
--// GAKURAN - TARGET MANAGER
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")

local TargetManager = {}

--// Dependencies
local Config = nil


--// =========================================================
--// STATE
--// =========================================================

TargetManager.State = {
    Running = false
}

TargetManager.CurrentTarget = nil
TargetManager.Targets = {}
TargetManager.CurrentIndex = 0


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function TargetManager:SetConfig(config)

    Config = config

end


--// =========================================================
--// GET LOCAL PLAYER
--// =========================================================

function TargetManager:GetLocalPlayer()

    return Players.LocalPlayer

end


--// =========================================================
--// GET CHARACTER
--// =========================================================

function TargetManager:GetCharacter(player)

    if not player then
        return nil
    end

    return player.Character

end


--// =========================================================
--// GET ROOT PART
--// =========================================================

function TargetManager:GetRootPart(character)

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")

end


--// =========================================================
--// GET HUMANOID
--// =========================================================

function TargetManager:GetHumanoid(character)

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")

end


--// =========================================================
--// IS ALIVE
--// =========================================================

function TargetManager:IsAlive(player)

    local character = self:GetCharacter(player)

    if not character then
        return false
    end

    local humanoid = self:GetHumanoid(character)

    if not humanoid then
        return false
    end

    return humanoid.Health > 0

end


--// =========================================================
--// GET DISTANCE
--// =========================================================

function TargetManager:GetDistance(player)

    local localPlayer = self:GetLocalPlayer()

    if not localPlayer then
        return math.huge
    end

    local localCharacter = self:GetCharacter(localPlayer)
    local targetCharacter = self:GetCharacter(player)

    local localRoot = self:GetRootPart(localCharacter)
    local targetRoot = self:GetRootPart(targetCharacter)

    if not localRoot or not targetRoot then
        return math.huge
    end

    return (localRoot.Position - targetRoot.Position).Magnitude

end


--// =========================================================
--// VALID TARGET
--// =========================================================

function TargetManager:IsValidTarget(player)

    if not player then
        return false
    end


    local localPlayer = self:GetLocalPlayer()

    if Config
        and Config.Targeting
        and Config.Targeting.IgnoreSelf
        and player == localPlayer then

        return false

    end


    if not self:IsAlive(player) then
        return false
    end


    local character = self:GetCharacter(player)

    if not character then
        return false
    end


    local root = self:GetRootPart(character)

    if not root then
        return false
    end


    local maxDistance = 20

    if Config
        and Config.Targeting
        and Config.Targeting.MaxDistance then

        maxDistance = Config.Targeting.MaxDistance

    end


    if self:GetDistance(player) > maxDistance then
        return false
    end


    return true

end


--// =========================================================
--// FIND TARGETS
--// =========================================================

function TargetManager:FindTargets()

    table.clear(self.Targets)


    for _, player in ipairs(Players:GetPlayers()) do

        if self:IsValidTarget(player) then

            table.insert(self.Targets, player)

        end

    end


    -- Sort nearest first

    table.sort(self.Targets, function(a, b)

        return self:GetDistance(a)
            < self:GetDistance(b)

    end)


    return self.Targets

end


--// =========================================================
--// REFRESH TARGETS
--// =========================================================

function TargetManager:Refresh()

    self:FindTargets()


    if self.CurrentTarget
        and self:IsValidTarget(self.CurrentTarget) then

        for index, player in ipairs(self.Targets) do

            if player == self.CurrentTarget then

                self.CurrentIndex = index

                return self.CurrentTarget

            end

        end

    end


    self.CurrentTarget = self.Targets[1]
    self.CurrentIndex = self.CurrentTarget and 1 or 0


    return self.CurrentTarget

end


--// =========================================================
--// GET CURRENT TARGET
--// =========================================================

function TargetManager:GetCurrentTarget()

    if self.CurrentTarget
        and self:IsValidTarget(self.CurrentTarget) then

        return self.CurrentTarget

    end


    return self:Refresh()

end


--// =========================================================
--// SET TARGET
--// =========================================================

function TargetManager:SetTarget(player)

    if player
        and self:IsValidTarget(player) then

        self.CurrentTarget = player

        for index, target in ipairs(self.Targets) do

            if target == player then

                self.CurrentIndex = index
                break

            end

        end

        return true

    end


    self.CurrentTarget = nil
    self.CurrentIndex = 0

    return false

end


--// =========================================================
--// CYCLE TARGET
--// =========================================================

function TargetManager:CycleTarget()

    self:FindTargets()


    local count = #self.Targets

    if count == 0 then

        self.CurrentTarget = nil
        self.CurrentIndex = 0

        return nil

    end


    self.CurrentIndex += 1


    if self.CurrentIndex > count then
        self.CurrentIndex = 1
    end


    self.CurrentTarget =
        self.Targets[self.CurrentIndex]


    return self.CurrentTarget

end


--// =========================================================
--// CLEAR TARGET
--// =========================================================

function TargetManager:ClearTarget()

    self.CurrentTarget = nil
    self.CurrentIndex = 0

end


--// =========================================================
--// GET TARGETS
--// =========================================================

function TargetManager:GetTargets()

    return self.Targets

end


--// =========================================================
--// GET TARGET COUNT
--// =========================================================

function TargetManager:GetTargetCount()

    return #self.Targets

end


--// =========================================================
--// GET NEAREST TARGET
--// =========================================================

function TargetManager:GetNearestTarget()

    self:FindTargets()

    return self.Targets[1]

end


--// =========================================================
--// GET TARGET BY INDEX
--// =========================================================

function TargetManager:GetTarget(index)

    return self.Targets[index]

end


--// =========================================================
--// PLAYER EVENTS
--// =========================================================

function TargetManager:SetupPlayerEvents()

    local connections = {}


    connections.PlayerRemoving =
        Players.PlayerRemoving:Connect(function(player)

            if player == self.CurrentTarget then

                self:ClearTarget()
                self:Refresh()

            end

        end)


    connections.PlayerAdded =
        Players.PlayerAdded:Connect(function()

            if self.State.Running then

                task.wait(0.5)

                self:Refresh()

            end

        end)


    self.Connections = connections

end


--// =========================================================
--// START
--// =========================================================

function TargetManager:Start()

    if self.State.Running then
        return
    end


    self.State.Running = true


    self:SetupPlayerEvents()
    self:Refresh()


    print("[TargetManager] Started.")

end


--// =========================================================
--// STOP
--// =========================================================

function TargetManager:Stop()

    if not self.State.Running then
        return
    end


    self.State.Running = false


    if self.Connections then

        for _, connection in pairs(self.Connections) do

            if connection then

                pcall(function()
                    connection:Disconnect()
                end)

            end

        end

    end


    self.Connections = {}
    self:ClearTarget()
    table.clear(self.Targets)


    print("[TargetManager] Stopped.")

end


--// =========================================================
--// INITIALIZE
--// =========================================================

function TargetManager:Initialize(state)

    self.SharedState = state

    print("[TargetManager] Initialized.")

end


--// =========================================================
--// RETURN
--// =========================================================

return TargetManager
