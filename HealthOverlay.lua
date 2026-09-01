--// HealthOverlay.lua
--// Gakuran Script - Health Overlay

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local HealthOverlay = {}

HealthOverlay.State = nil
HealthOverlay.Config = nil
HealthOverlay.Connections = {}
HealthOverlay.Overlays = {}

--==================================================
-- Initialization
--==================================================

function HealthOverlay:Initialize(State, Config)
    self.State = State
    self.Config = Config

    table.clear(self.Connections)
    table.clear(self.Overlays)

    if not self:IsEnabled() then
        return
    end

    self:Start()
end

--==================================================
-- Configuration
--==================================================

function HealthOverlay:IsEnabled()
    return self.Config
        and self.Config.ESP
        and self.Config.ESP.Enabled
        and self.Config.ESP.ShowHealth
end

--==================================================
-- Create Overlay
--==================================================

function HealthOverlay:Create(player)
    if not player or player == Players.LocalPlayer then
        return
    end

    if self.Overlays[player] then
        return
    end

    self.Overlays[player] = {
        Player = player,
        Character = nil,
        Humanoid = nil,
        Health = 0,
        MaxHealth = 100,
    }

    if player.Character then
        self:SetCharacter(player, player.Character)
    end
end

--==================================================
-- Set Character
--==================================================

function HealthOverlay:SetCharacter(player, character)
    local data = self.Overlays[player]

    if not data then
        return
    end

    data.Character = character
    data.Humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if data.Humanoid then
        data.Health = data.Humanoid.Health
        data.MaxHealth = data.Humanoid.MaxHealth
    else
        data.Health = 0
        data.MaxHealth = 100
    end
end

--==================================================
-- Update Health
--==================================================

function HealthOverlay:UpdatePlayer(player, data)
    if not data.Character then
        return
    end

    local humanoid = data.Character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    data.Humanoid = humanoid
    data.Health = humanoid.Health
    data.MaxHealth = humanoid.MaxHealth
end

--==================================================
-- Update All
--==================================================

function HealthOverlay:Update()
    if not self.State or not self.State.Alive then
        return
    end

    if not self:IsEnabled() then
        return
    end

    for player, data in pairs(self.Overlays) do
        self:UpdatePlayer(player, data)

        if self.State.EspTrackers then
            local tracker = self.State.EspTrackers[player]

            if tracker then
                tracker.Health = data.Health
                tracker.MaxHealth = data.MaxHealth
            end
        end
    end
end

--==================================================
-- Start
--==================================================

function HealthOverlay:Start()
    for _, player in ipairs(Players:GetPlayers()) do
        self:Create(player)
    end

    local playerAdded = Players.PlayerAdded:Connect(function(player)
        self:Create(player)

        local characterAdded = player.CharacterAdded:Connect(
            function(character)
                self:SetCharacter(player, character)
            end
        )

        table.insert(self.Connections, characterAdded)
    end)

    table.insert(self.Connections, playerAdded)

    local renderConnection = RunService.RenderStepped:Connect(
        function()
            self:Update()
        end
    )

    table.insert(self.Connections, renderConnection)

    -- Character connections for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local connection = player.CharacterAdded:Connect(
                function(character)
                    self:SetCharacter(player, character)
                end
            )

            table.insert(self.Connections, connection)
        end
    end
end

--==================================================
-- Remove Player
--==================================================

function HealthOverlay:RemovePlayer(player)
    self.Overlays[player] = nil

    if self.State and self.State.EspTrackers then
        self.State.EspTrackers[player] = nil
    end
end

--==================================================
-- Cleanup
--==================================================

function HealthOverlay:Destroy()
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(self.Connections)
    table.clear(self.Overlays)

    self.State = nil
    self.Config = nil
end

return HealthOverlay
