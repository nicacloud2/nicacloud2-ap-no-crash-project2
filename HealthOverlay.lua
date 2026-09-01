--// =========================================================
--// GAKURAN - HEALTH OVERLAY
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local HealthOverlay = {}

--// Dependencies
local Config = nil
local TargetManager = nil

--// State
HealthOverlay.State = {
    Running = false,
    Enabled = true
}

HealthOverlay.Objects = {}
HealthOverlay.Connections = {}


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function HealthOverlay:SetDependencies(config, targetManager)
    Config = config
    TargetManager = targetManager
end


--// =========================================================
--// INITIALIZE
--// =========================================================

function HealthOverlay:Initialize(state)
    self.SharedState = state

    print("[HealthOverlay] Initialized.")
end


--// =========================================================
--// CREATE GUI
--// =========================================================

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


    --// Background

    local background = Instance.new("Frame")

    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 0, 8)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BorderSizePixel = 0

    background.Parent = billboard


    --// Health bar

    local healthBar = Instance.new("Frame")

    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BorderSizePixel = 0

    healthBar.Parent = background


    --// Health text

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


--// =========================================================
--// REMOVE
--// =========================================================

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


--// =========================================================
--// UPDATE PLAYER
--// =========================================================

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


--// =========================================================
--// REFRESH
--// =========================================================

function HealthOverlay:Refresh()

    if not self.State.Enabled then
        return
    end


    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= Players.LocalPlayer then

            local character = player.Character

            if character then

                local humanoid =
                    character:FindFirstChildOfClass("Humanoid")

                local head =
                    character:FindFirstChild("Head")


                if humanoid
                    and head
                    and humanoid.Health > 0 then

                    if not self.Objects[player] then
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


    -- Remove players that left

    for player in pairs(self.Objects) do

        if not player.Parent then
            self:Remove(player)
        end

    end
end


--// =========================================================
--// PLAYER EVENTS
--// =========================================================

function HealthOverlay:SetupPlayerEvents()

    local playerAdded =
        Players.PlayerAdded:Connect(function(player)

            local connection =
                player.CharacterAdded:Connect(function()

                    task.wait(0.5)

                    if self.State.Running then
                        self:Create(player)
                    end

                end)

            table.insert(
                self.Connections,
                connection
            )

        end)


    table.insert(
        self.Connections,
        playerAdded
    )


    local playerRemoving =
        Players.PlayerRemoving:Connect(function(player)

            self:Remove(player)

        end)


    table.insert(
        self.Connections,
        playerRemoving
    )


    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= Players.LocalPlayer then

            local connection =
                player.CharacterAdded:Connect(function()

                    task.wait(0.5)

                    if self.State.Running then
                        self:Create(player)
                    end

                end)


            table.insert(
                self.Connections,
                connection
            )

        end

    end
end


--// =========================================================
--// ENABLE
--// =========================================================

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


--// =========================================================
--// START
--// =========================================================

function HealthOverlay:Start()

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

        end)


    table.insert(
        self.Connections,
        connection
    )


    print("[HealthOverlay] Started.")
end


--// =========================================================
--// STOP
--// =========================================================

function HealthOverlay:Stop()

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
        self:Remove(player)
    end


    print("[HealthOverlay] Stopped.")
end


--// =========================================================
--// DESTROY
--// =========================================================

function HealthOverlay:Destroy()

    self:Stop()

end


--// =========================================================
--// RETURN
--// =========================================================

return HealthOverlay
