--// TargetManager.lua
--// Gakuran Script - Target Management

local Players = game:GetService("Players")

local TargetManager = {}

TargetManager.State = nil
TargetManager.Config = nil

--==================================================
-- Initialization
--==================================================

function TargetManager:Initialize(State, Config)
    self.State = State
    self.Config = Config

    self:Refresh()
end

--==================================================
-- Character Helpers
--==================================================

function TargetManager:IsValidCharacter(character)
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return false
    end

    if humanoid.Health <= 0 then
        return false
    end

    return true
end

function TargetManager:IsIgnored(player, character)
    if not player and not character then
        return true
    end

    local ignoreIds = self.Config.IgnoreIds or {}

    if player and table.find(ignoreIds, player.UserId) then
        return true
    end

    return false
end

--==================================================
-- Distance
--==================================================

function TargetManager:GetDistance(character)
    local localPlayer = Players.LocalPlayer

    if not localPlayer.Character then
        return math.huge
    end

    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = character and character:FindFirstChild("HumanoidRootPart")

    if not localRoot or not targetRoot then
        return math.huge
    end

    return (localRoot.Position - targetRoot.Position).Magnitude
end

--==================================================
-- Get Targets
--==================================================

function TargetManager:GetTargets()
    local targets = {}
    local localPlayer = Players.LocalPlayer

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character

            if self:IsValidCharacter(character)
                and not self:IsIgnored(player, character) then

                local distance = self:GetDistance(character)

                local maxDistance = self.Config.Targeting
                    and self.Config.Targeting.MaxDistance
                    or math.huge

                if distance <= maxDistance then
                    table.insert(targets, {
                        Player = player,
                        Character = character,
                        Distance = distance,
                    })
                end
            end
        end
    end

    table.sort(targets, function(a, b)
        return a.Distance < b.Distance
    end)

    return targets
end

--==================================================
-- Refresh
--==================================================

function TargetManager:Refresh()
    if not self.State then
        return
    end

    local targets = self:GetTargets()

    table.clear(self.State.TargetCharacters)

    for _, target in ipairs(targets) do
        table.insert(
            self.State.TargetCharacters,
            target.Character
        )
    end

    -- Keep index valid
    if #self.State.TargetCharacters == 0 then
        self.State.CurrentTargetIndex = 1
    elseif self.State.CurrentTargetIndex > #self.State.TargetCharacters then
        self.State.CurrentTargetIndex = 1
    end
end

--==================================================
-- Current Target
--==================================================

function TargetManager:GetCurrentTarget()
    if not self.State then
        return nil
    end

    local targets = self.State.TargetCharacters

    if #targets == 0 then
        return nil
    end

    local index = self.State.CurrentTargetIndex

    if index < 1 or index > #targets then
        index = 1
        self.State.CurrentTargetIndex = index
    end

    local character = targets[index]

    if not self:IsValidCharacter(character) then
        self:Refresh()
        return self:GetCurrentTarget()
    end

    return character
end

--==================================================
-- Cycle Target
--==================================================

function TargetManager:CycleNext()
    if not self.State then
        return nil
    end

    self:Refresh()

    local targets = self.State.TargetCharacters

    if #targets == 0 then
        return nil
    end

    self.State.CurrentTargetIndex =
        (self.State.CurrentTargetIndex % #targets) + 1

    return self:GetCurrentTarget()
end

function TargetManager:CyclePrevious()
    if not self.State then
        return nil
    end

    self:Refresh()

    local targets = self.State.TargetCharacters

    if #targets == 0 then
        return nil
    end

    self.State.CurrentTargetIndex =
        ((self.State.CurrentTargetIndex - 2) % #targets) + 1

    return self:GetCurrentTarget()
end

--==================================================
-- Find Specific Character
--==================================================

function TargetManager:FindPlayer(player)
    if not player then
        return nil
    end

    local character = player.Character

    if self:IsValidCharacter(character)
        and not self:IsIgnored(player, character) then

        return character
    end

    return nil
end

--==================================================
-- Get Target Root
--==================================================

function TargetManager:GetRoot(character)
    character = character or self:GetCurrentTarget()

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- Cleanup
--==================================================

function TargetManager:Destroy()
    if self.State then
        table.clear(self.State.TargetCharacters)
        self.State.CurrentTargetIndex = 1
    end

    self.State = nil
    self.Config = nil
end

return TargetManager
