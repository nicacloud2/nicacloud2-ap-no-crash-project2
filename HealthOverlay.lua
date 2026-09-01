local Players = game:GetService("Players")

local HealthOverlay = {}

local Config = nil
local TargetManager = nil

HealthOverlay.State = {
    Running = false,
    Enabled = true
}

HealthOverlay.Objects = {}
HealthOverlay.PollInterval = 0.15

function HealthOverlay:SetDependencies(config, targetManager)
    Config = config
    TargetManager = targetManager
end

function HealthOverlay:Initialize(state)
    self.SharedState = state
    print("[HealthOverlay] Initialized.")
end

function HealthOverlay:Create(player)
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

    local head = character:FindFirstChild("Head")

    if not head then
        return
    end

    self:Remove(player)

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "GakuranHealth"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 120, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.Parent = head

    local background = Instance.new("Frame")

    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 0, 8)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BorderSizePixel = 0
    background.Parent = billboard

    local healthBar = Instance.new("Frame")

    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = background

    local text = Instance.new("TextLabel")

    text.Name = "HealthText"
    text.Size = UDim2.new(1, 0, 0, 20)
    text.Position = UDim2.new(0, 0, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = "100 / 100"
    text.TextSize = 12
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.5
    text.Parent = billboard

    self.Objects[player] = {
        Billboard = billboard,
        Background = background,
        HealthBar = healthBar,
        Text = text
    }
end

function HealthOverlay:Remove(player)
    local object = self.Objects[player]

    if not object then
        return
    end

    if object.Billboard then
        pcall(function()
            object.Billboard:Destroy()
        end)
    end

    self.Objects[player] = nil
end

function HealthOverlay:UpdatePlayer(player)
    local object = self.Objects[player]

    if not object then
        return
    end

    local character = player.Character

    if not character then
        self:Remove(player)
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        self:Remove(player)
        return
    end

    local maxHealth = humanoid.MaxHealth
    local health = humanoid.Health

    if maxHealth <= 0 then
        maxHealth = 100
    end

    local percentage =
        math.clamp(
            health / maxHealth,
            0,
            1
        )

    object.HealthBar.Size =
        UDim2.new(
            percentage,
            0,
            1,
            0
        )

    object.Text.Text =
        string.format(
            "%.0f / %.0f",
            health,
            maxHealth
        )

    if health <= 0 then
        self:Remove(player)
    end
end

function HealthOverlay:Refresh()
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

                local head =
                    character:FindFirstChild("Head")

                if humanoid
                    and head
                    and humanoid.Health > 0
                then

                    local object =
                        self.Objects[player]

                    if not object then

                        self:Create(player)

                    elseif object.Billboard
                        and object.Billboard.Adornee ~= head
                    then

                        self:Create(player)

                    end

                    self:UpdatePlayer(player)

                else

                    self:Remove(player)

                end

            else

                self:Remove(player)

            end
        end
    end

    for player in pairs(self.Objects) do

        if not currentPlayers[player]
            or not player.Parent
        then

            self:Remove(player)

        end
    end
end

function HealthOverlay:Poll()
    if not self.State.Running then
        return
    end

    if not self.State.Enabled then
        return
    end

    pcall(function()
        self:Refresh()
    end)
end

function HealthOverlay:SetEnabled(enabled)

    self.State.Enabled = enabled == true

    if not self.State.Enabled then

        for player in pairs(self.Objects) do
            self:Remove(player)
        end

    end
end

function HealthOverlay:IsEnabled()
    return self.State.Enabled
end

function HealthOverlay:Start()

    if self.State.Running then
        return
    end

    self.State.Running = true

    self:Refresh()

    task.spawn(function()

        while self.State.Running do

            self:Poll()

            task.wait(
                self.PollInterval
            )

        end

    end)

    print("[HealthOverlay] Started.")
end

function HealthOverlay:Stop()

    if not self.State.Running then
        return
    end

    self.State.Running = false

    for player in pairs(self.Objects) do
        self:Remove(player)
    end

    print("[HealthOverlay] Stopped.")
end

function HealthOverlay:Destroy()
    self:Stop()
end

_G.__GakuranModuleResult = HealthOverlay
