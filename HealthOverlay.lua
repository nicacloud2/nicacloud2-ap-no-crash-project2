--// =========================================================
--// GAKURAN - HEALTH OVERLAY
--// GitHub / Matcha Version
--// DRAWING API VERSION
--// =========================================================

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local HealthOverlay = {}

local Config = nil
local TargetManager = nil

HealthOverlay.State = {
    Running = false,
    Enabled = true
}

HealthOverlay.Objects = {}
HealthOverlay.PollInterval = 0.15


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function HealthOverlay:SetDependencies(config, targetManager)
    Config = config
    TargetManager = targetManager

    print("[HealthOverlay] Dependencies received.")
end


--// =========================================================
--// INITIALIZE
--// =========================================================

function HealthOverlay:Initialize(state)
    self.SharedState = state

    print("[HealthOverlay] Initialized.")
end


--// =========================================================
--// CREATE DRAWINGS
--// =========================================================

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


    local box = Drawing.new("Square")
    box.Visible = false
    box.Filled = false
    box.Thickness = 1


    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Filled = true
    healthBar.Thickness = 1


    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Size = 13
    text.Text = "100 / 100"


    self.Objects[player] = {
        Box = box,
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


    if object.Box then
        pcall(function()
            object.Box:Remove()
        end)
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


    local position, onScreen =
        Camera:WorldToViewportPoint(root.Position)


    if not onScreen or position.Z <= 0 then
        self:Hide(object)
        return
    end


    local distance = position.Z

    local height =
        math.clamp(
            1800 / math.max(distance, 1),
            35,
            90
        )


    local width = height * 1.8


    local x =
        position.X - (width / 2)

    local y =
        position.Y - height


    local percentage =
        math.clamp(
            health / maxHealth,
            0,
            1
        )


    --// Box

    object.Box.Position =
        Vector2.new(
            x,
            y
        )

    object.Box.Size =
        Vector2.new(
            width,
            height
        )

    object.Box.Visible = true


    --// Health bar

    local barWidth = 4

    local barHeight =
        height * percentage


    object.HealthBar.Position =
        Vector2.new(
            x - barWidth - 3,
            y + height - barHeight
        )


    object.HealthBar.Size =
        Vector2.new(
            barWidth,
            barHeight
        )

    object.HealthBar.Visible = true


    --// Health text

    object.Text.Position =
        Vector2.new(
            position.X,
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
--// HIDE
--// =========================================================

function HealthOverlay:Hide(object)

    if object.Box then
        object.Box.Visible = false
    end

    if object.HealthBar then
        object.HealthBar.Visible = false
    end

    if object.Text then
        object.Text.Visible = false
    end
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


    --// Remove players that left

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
--// ENABLE
--// =========================================================

function HealthOverlay:SetEnabled(enabled)

    self.State.Enabled =
        enabled == true


    if not self.State.Enabled then

        for player in pairs(self.Objects) do
            self:Hide(self.Objects[player])
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


    --// Check Drawing API

    if not Drawing or not Drawing.new then

        warn(
            "[HealthOverlay] Drawing API unavailable."
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
