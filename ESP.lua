--// =========================================================
--// GAKURAN - ESP
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESP = {}

--// Dependencies
local Config = nil
local TargetManager = nil

--// State
ESP.State = {
    Running = false,
    Enabled = true
}

ESP.Objects = {}
ESP.Connections = {}


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function ESP:SetDependencies(config, targetManager)
    Config = config
    TargetManager = targetManager
end


--// =========================================================
--// INITIALIZE
--// =========================================================

function ESP:Initialize(state)
    self.SharedState = state

    print("[ESP] Initialized.")
end


--// =========================================================
--// CREATE HIGHLIGHT
--// =========================================================

function ESP:CreateHighlight(player)
    if not player then
        return
    end

    if player == Players.LocalPlayer then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    -- Remove old highlight
    self:RemoveHighlight(player)

    local highlight = Instance.new("Highlight")

    highlight.Name = "GakuranESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0

    highlight.Parent = character

    self.Objects[player] = highlight
end


--// =========================================================
--// REMOVE HIGHLIGHT
--// =========================================================

function ESP:RemoveHighlight(player)
    local highlight = self.Objects[player]

    if highlight then
        pcall(function()
            highlight:Destroy()
        end)

        self.Objects[player] = nil
    end
end


--// =========================================================
--// REFRESH
--// =========================================================

function ESP:Refresh()
    if not self.State.Enabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= Players.LocalPlayer then

            local character = player.Character

            if character then

                local humanoid =
                    character:FindFirstChildOfClass("Humanoid")

                if humanoid and humanoid.Health > 0 then

                    if not self.Objects[player] then
                        self:CreateHighlight(player)
                    end

                else
                    self:RemoveHighlight(player)
                end

            else
                self:RemoveHighlight(player)
            end
        end
    end

    -- Remove players that no longer exist
    for player in pairs(self.Objects) do

        if not player.Parent then
            self:RemoveHighlight(player)
        end

    end
end


--// =========================================================
--// TARGET HIGHLIGHT
--// =========================================================

function ESP:UpdateTarget()
    if not TargetManager then
        return
    end

    local target =
        TargetManager:GetCurrentTarget()

    for player, highlight in pairs(self.Objects) do

        if highlight and highlight.Parent then

            if player == target then
                highlight.FillTransparency = 0.55
                highlight.OutlineTransparency = 0
            else
                highlight.FillTransparency = 0.75
                highlight.OutlineTransparency = 0
            end

        end
    end
end


--// =========================================================
--// PLAYER EVENTS
--// =========================================================

function ESP:SetupPlayerEvents()

    local playerAdded =
        Players.PlayerAdded:Connect(function(player)

            player.CharacterAdded:Connect(function()

                task.wait(0.5)

                if self.State.Running then
                    self:CreateHighlight(player)
                end

            end)

        end)

    table.insert(
        self.Connections,
        playerAdded
    )


    local playerRemoving =
        Players.PlayerRemoving:Connect(function(player)

            self:RemoveHighlight(player)

        end)

    table.insert(
        self.Connections,
        playerRemoving
    )


    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= Players.LocalPlayer then

            player.CharacterAdded:Connect(function()

                task.wait(0.5)

                if self.State.Running then
                    self:CreateHighlight(player)
                end

            end)

        end
    end
end


--// =========================================================
--// ENABLE
--// =========================================================

function ESP:SetEnabled(enabled)

    self.State.Enabled = enabled == true

    if not self.State.Enabled then

        for player in pairs(self.Objects) do
            self:RemoveHighlight(player)
        end

    end
end


function ESP:IsEnabled()
    return self.State.Enabled
end


--// =========================================================
--// START
--// =========================================================

function ESP:Start()

    if self.State.Running then
        return
    end

    self.State.Running = true

    self:SetupPlayerEvents()
    self:Refresh()


    local connection =
        RunService.Heartbeat:Connect(function()

            if not self.State.Running then
                return
            end

            if not self.State.Enabled then
                return
            end

            self:Refresh()
            self:UpdateTarget()

        end)

    table.insert(
        self.Connections,
        connection
    )


    print("[ESP] Started.")
end


--// =========================================================
--// STOP
--// =========================================================

function ESP:Stop()

    if not self.State.Running then
        return
    end

    self.State.Running = false


    for _, connection in ipairs(self.Connections) do

        if connection then

            pcall(function()
                connection:Disconnect()
            end)

        end

    end

    table.clear(self.Connections)


    for player in pairs(self.Objects) do
        self:RemoveHighlight(player)
    end


    print("[ESP] Stopped.")
end


--// =========================================================
--// DESTROY
--// =========================================================

function ESP:Destroy()

    self:Stop()

end


--// =========================================================
--// RETURN
--// =========================================================

return ESP
