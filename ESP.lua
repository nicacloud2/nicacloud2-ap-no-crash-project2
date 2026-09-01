--// =========================================================
--// GAKURAN - ESP
--// GitHub / Matcha Version
--// Polling-Safe Edition
--// =========================================================

local Players = game:GetService("Players")

local ESP = {}

local Config = nil
local TargetManager = nil

ESP.State = {
    Running = false,
    Enabled = true
}

ESP.Objects = {}
ESP.PollInterval = 0.15

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

    if not highlight then
        return
    end

    pcall(function()
        highlight:Destroy()
    end)

    self.Objects[player] = nil
end

--// =========================================================
--// REFRESH PLAYERS
--// =========================================================

function ESP:Refresh()
    if not self.State.Enabled then
        return
    end

    local currentPlayers = {}

    for _, player in ipairs(Players:GetPlayers()) do
        currentPlayers[player] = true

        if player ~= Players.LocalPlayer then
            local character = player.Character

            if character then
                local humanoid =
                    character:FindFirstChildOfClass("Humanoid")

                if humanoid and humanoid.Health > 0 then
                    if not self.Objects[player] then
                        self:CreateHighlight(player)
                    else
                        local highlight = self.Objects[player]

                        if not highlight
                            or not highlight.Parent
                            or highlight.Adornee ~= character
                        then
                            self:CreateHighlight(player)
                        end
                    end
                else
                    self:RemoveHighlight(player)
                end
            else
                self:RemoveHighlight(player)
            end
        end
    end

    --// Remove players that no longer exist

    for player in pairs(self.Objects) do
        if not currentPlayers[player]
            or not player.Parent
        then
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

    local target

    pcall(function()
        target = TargetManager:GetCurrentTarget()
    end)

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
--// POLL
--// =========================================================

function ESP:Poll()
    if not self.State.Running then
        return
    end

    if not self.State.Enabled then
        return
    end

    pcall(function()
        self:Refresh()
    end)

    pcall(function()
        self:UpdateTarget()
    end)
end

--// =========================================================
--// ENABLE / DISABLE
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

    self:Refresh()
    self:UpdateTarget()

    task.spawn(function()
        while self.State.Running do
            pcall(function()
                self:Poll()
            end)

            task.wait(self.PollInterval)
        end
    end)

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
--// MATCHA MODULE RESULT
--// IMPORTANT: DO NOT CHANGE THIS TO "return ESP"
// =========================================================

_G.__GakuranModuleResult = ESP
