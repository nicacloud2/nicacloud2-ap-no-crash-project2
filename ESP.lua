--// ESP.lua
--// Gakuran Script - ESP System

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESP = {}

ESP.State = nil
ESP.Config = nil
ESP.Connections = {}
ESP.Objects = {}

--==================================================
-- Initialization
--==================================================

function ESP:Initialize(State, Config)
    self.State = State
    self.Config = Config

    table.clear(self.Connections)
    table.clear(self.Objects)

    if not self:IsEnabled() then
        return
    end

    self:CreateObjects()
    self:StartUpdate()
end

--==================================================
-- Configuration
--==================================================

function ESP:IsEnabled()
    return self.Config
        and self.Config.ESP
        and self.Config.ESP.Enabled
end

--==================================================
-- Character Validation
--==================================================

function ESP:IsValidCharacter(character)
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    return humanoid ~= nil and root ~= nil and humanoid.Health > 0
end

--==================================================
-- Create ESP Objects
--==================================================

function ESP:CreateObjects()
    if not self.State then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        self:AddPlayer(player)
    end

    local connection = Players.PlayerAdded:Connect(function(player)
        self:AddPlayer(player)
    end)

    table.insert(self.Connections, connection)

    local removingConnection = Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)

    table.insert(self.Connections, removingConnection)
end

--==================================================
-- Add Player
--==================================================

function ESP:AddPlayer(player)
    if not player or player == Players.LocalPlayer then
        return
    end

    if self.Objects[player] then
        return
    end

    self.Objects[player] = {
        Player = player,
        Character = nil,
        Highlight = nil,
    }

    local characterConnection = player.CharacterAdded:Connect(function(character)
        self:SetCharacter(player, character)
    end)

    self.Objects[player].CharacterConnection = characterConnection

    if player.Character then
        self:SetCharacter(player, player.Character)
    end
end

--==================================================
-- Set Character
--==================================================

function ESP:SetCharacter(player, character)
    local data = self.Objects[player]

    if not data then
        return
    end

    data.Character = character

    -- Remove previous highlight
    if data.Highlight then
        pcall(function()
            data.Highlight:Destroy()
        end)

        data.Highlight = nil
    end

    if not self:IsValidCharacter(character) then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "GakuranESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0

    highlight.Parent = character

    data.Highlight = highlight
end

--==================================================
-- Update
--==================================================

function ESP:Update()
    if not self.State or not self.State.Alive then
        return
    end

    if not self:IsEnabled() then
        return
    end

    for player, data in pairs(self.Objects) do
        local character = data.Character

        if character and self:IsValidCharacter(character) then
            local humanoid =
                character:FindFirstChildOfClass("Humanoid")

            if data.Highlight then
                data.Highlight.Enabled = true
            end

            -- Store ESP tracker data
            if self.State.EspTrackers then
                self.State.EspTrackers[player] = {
                    Character = character,
                    Health = humanoid.Health,
                    MaxHealth = humanoid.MaxHealth,
                }
            end
        else
            if data.Highlight then
                data.Highlight.Enabled = false
            end
        end
    end
end

--==================================================
-- Update Loop
--==================================================

function ESP:StartUpdate()
    local connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)

    table.insert(self.Connections, connection)
end

--==================================================
-- Remove Player
--==================================================

function ESP:RemovePlayer(player)
    local data = self.Objects[player]

    if not data then
        return
    end

    if data.CharacterConnection then
        pcall(function()
            data.CharacterConnection:Disconnect()
        end)
    end

    if data.Highlight then
        pcall(function()
            data.Highlight:Destroy()
        end)
    end

    self.Objects[player] = nil

    if self.State and self.State.EspTrackers then
        self.State.EspTrackers[player] = nil
    end
end

--==================================================
-- Cleanup
--==================================================

function ESP:Destroy()
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(self.Connections)

    for player in pairs(self.Objects) do
        self:RemovePlayer(player)
    end

    table.clear(self.Objects)

    if self.State and self.State.EspTrackers then
        table.clear(self.State.EspTrackers)
    end

    self.State = nil
    self.Config = nil
end

return ESP
