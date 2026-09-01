--// =========================================================
--// GAKURAN - HEALTH OVERLAY
--// GitHub / Matcha Version
--// MATCHA DRAWING VERSION
--// =========================================================

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

    print("[HealthOverlay] Dependencies received.")
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

    if self.Objects[player] then
        self:Remove(player)
    end

    local healthBar = Drawing.new("Square")

    healthBar.Visible = false
    healthBar.Filled = true
    healthBar.Thickness = 1

    local healthText = Drawing.new("Text")

    healthText.Visible = false
    healthText.Center = true
    healthText.Outline = true
    healthText.Size = 13
    healthText.Text = "100 / 100"

    self.Objects[player] = {
        HealthBar = healthBar,
        Text = healthText
    }
end


function HealthOverlay:Remove(player)

    local object = self.Objects[player]

    if not object then
        return
    end

    if object.HealthBar then
        pcall(function()
            object.HealthBar:Remove()
        end)
    end

    if object.Text then
        pcall(function()
            object.Text:Remove()
        end)
    end

    self.Objects[player] = nil
end


function HealthOverlay:Hide(object)

    if not object then
        return
    end

    if object.HealthBar then
        object.HealthBar.Visible = false
    end

    if object.Text then
        object.Text.Visible = false
    end
end


--// =========================================================
--// MATCHA WORLD TO SCREEN
--// =========================================================

function HealthOverlay:GetScreenPosition(position)

    if type(WorldToScreen) ~= "function" then
        return nil, false
    end

    local success, screenPosition, onScreen =
        pcall(function()
            return WorldToScreen(position)
        end)

    if not success then
        return nil, false
    end

    if not screenPosition then
        return nil, false
    end

    return screenPosition, onScreen == true
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
        self:Hide(object)
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        self:Hide(object)
        return
    end

    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth

    if maxHealth <= 0 then
        maxHealth = 100
    end

    if health <= 0 then
        self:Hide(object)
        return
    end


    --// =====================================================
    --// MATCHA PROJECTION
    --// IMPORTANT:
    --// DO NOT USE Camera:WorldToViewportPoint()
    --// =====================================================

    local screenPosition, onScreen =
        self:GetScreenPosition(root.Position)

    if not screenPosition or not onScreen then
        self:Hide(object)
        return
    end


    --// =====================================================
    --// HEALTH PERCENTAGE
    --// =====================================================

    local percentage =
        math.clamp(
            health / maxHealth,
            0,
            1
        )


    --// =====================================================
    --// DISTANCE
    --// =====================================================

    local distance = 50

    local camera = workspace.CurrentCamera

    if camera then

        local success, calculatedDistance =
            pcall(function()

                return (
                    camera.Position -
                    root.Position
                ).Magnitude

            end)

        if success and calculatedDistance then
            distance = calculatedDistance
        end
    end


    --// =====================================================
    --// SIZE
    --// =====================================================

    local height =
        math.clamp(
            1800 / math.max(distance, 1),
            35,
            90
        )

    local barWidth = 4

    local x =
        screenPosition.X - 35

    local y =
        screenPosition.Y - (height / 2)

    local barHeight =
        height * percentage


    --// =====================================================
    --// HEALTH BAR
    --// =====================================================

    object.HealthBar.Position =
        Vector2.new(
            x,
            y + height - barHeight
        )

    object.HealthBar.Size =
        Vector2.new(
            barWidth,
            barHeight
        )

    object.HealthBar.Visible = true


    --// =====================================================
    --// HEALTH TEXT
    --// =====================================================

    object.Text.Position =
        Vector2.new(
            screenPosition.X,
            y - 15
        )

    object.Text.Text =
        string.format(
            "%.0f / %.0f",
            health,
            maxHealth
        )

    object.Text.Visible = true
end


--// =========================================================
--// REFRESH
--// =========================================================

function HealthOverlay:Refresh()

    if not self.State.Enabled then
        return
    end

    local currentPlayers = {}

    for _, player in ipairs(Players:GetPlayers()) do

        currentPlayers[player] = true

        if player ~= Players.LocalPlayer then

            if not self.Objects[player] then
                self:Create(player)
            end

            self:UpdatePlayer(player)
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


--// =========================================================
--// POLL
--// =========================================================

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


--// =========================================================
--// ENABLE / DISABLE
--// =========================================================

function HealthOverlay:SetEnabled(enabled)

    self.State.Enabled =
        enabled == true

    if not self.State.Enabled then

        for _, object in pairs(self.Objects) do
            self:Hide(object)
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

    if not Drawing
        or not Drawing.new
    then

        warn(
            "[HealthOverlay] Drawing API unavailable."
        )

        return
    end

    --// Matcha projection check

    if type(WorldToScreen) ~= "function" then

        warn(
            "[HealthOverlay] Matcha WorldToScreen unavailable."
        )

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

    print("[HealthOverlay] Drawing API detected.")
    print("[HealthOverlay] WorldToScreen detected.")
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
--// MATCHA MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult = HealthOverlay
