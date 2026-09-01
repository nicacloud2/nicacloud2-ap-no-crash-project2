--// =========================================================
--// GAKURAN - ESP
--// GitHub / Matcha Version
--// MATCHA DRAWING VERSION
--// =========================================================

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local ESP = {}

local Config = nil
local TargetManager = nil

ESP.State = {
    Running = false,
    Enabled = true
}

ESP.Objects = {}
ESP.PollInterval = 0.03

function ESP:SetDependencies(config, targetManager)
    Config = config
    TargetManager = targetManager

    print("[ESP] Dependencies received.")
end

function ESP:Initialize(state)
    self.SharedState = state
    print("[ESP] Initialized.")
end

function ESP:IsDrawingAvailable()
    return Drawing ~= nil
        and type(Drawing.new) == "function"
end

function ESP:CreateESP(player)
    if not player then
        return
    end

    if player == Players.LocalPlayer then
        return
    end

    if self.Objects[player] then
        return
    end

    if not self:IsDrawingAvailable() then
        return
    end

    local success, result = pcall(function()
        local box = Drawing.new("Square")

        box.Visible = false
        box.Filled = false
        box.Thickness = 1
        box.Transparency = 1

        local name = Drawing.new("Text")

        name.Visible = false
        name.Center = true
        name.Outline = true
        name.Size = 13
        name.Transparency = 1

        self.Objects[player] = {
            Box = box,
            Name = name
        }
    end)

    if not success then
        warn("[ESP] Failed to create drawing:", tostring(result))
    end
end

function ESP:RemoveESP(player)
    local object = self.Objects[player]

    if not object then
        return
    end

    pcall(function()
        if object.Box then
            object.Box.Visible = false
            object.Box:Remove()
        end
    end)

    pcall(function()
        if object.Name then
            object.Name.Visible = false
            object.Name:Remove()
        end
    end)

    self.Objects[player] = nil
end

function ESP:UpdatePlayer(player)
    if not player or player == Players.LocalPlayer then
        return
    end

    local object = self.Objects[player]

    if not object then
        self:CreateESP(player)
        object = self.Objects[player]
    end

    if not object then
        return
    end

    local character = player.Character

    if not character then
        object.Box.Visible = false
        object.Name.Visible = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        object.Box.Visible = false
        object.Name.Visible = false
        return
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")

    if not root then
        object.Box.Visible = false
        object.Name.Visible = false
        return
    end

    local success, screenPosition, visible = pcall(function()
        return Camera:WorldToViewportPoint(root.Position)
    end)

    if not success or not screenPosition then
        object.Box.Visible = false
        object.Name.Visible = false
        return
    end

    if not visible or screenPosition.Z <= 0 then
        object.Box.Visible = false
        object.Name.Visible = false
        return
    end

    local distance = screenPosition.Z

    local height = math.clamp(
        4000 / math.max(distance, 1),
        20,
        300
    )

    local width = height * 0.55

    local x = screenPosition.X - (width / 2)
    local y = screenPosition.Y - (height / 2)

    object.Box.Position = Vector2.new(x, y)
    object.Box.Size = Vector2.new(width, height)

    object.Name.Position =
        Vector2.new(screenPosition.X, y - 16)

    object.Name.Text = player.Name

    object.Box.Visible = true
    object.Name.Visible = true
end

function ESP:Refresh()
    if not self.State.Enabled then
        return
    end

    local currentPlayers = {}

    for _, player in ipairs(Players:GetPlayers()) do
        currentPlayers[player] = true

        if player ~= Players.LocalPlayer then
            self:UpdatePlayer(player)
        end
    end

    for player in pairs(self.Objects) do
        if not currentPlayers[player] or not player.Parent then
            self:RemoveESP(player)
        end
    end
end

function ESP:UpdateTarget()
    if not TargetManager then
        return
    end

    local target = nil

    pcall(function()
        target = TargetManager:GetCurrentTarget()
    end)

    for player, object in pairs(self.Objects) do
        if object and object.Box and object.Name then

            local isTarget = player == target

            pcall(function()
                if isTarget then
                    object.Box.Thickness = 2
                    object.Name.Size = 15
                else
                    object.Box.Thickness = 1
                    object.Name.Size = 13
                end
            end)

        end
    end
end

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

function ESP:SetEnabled(enabled)
    self.State.Enabled = enabled == true

    if not self.State.Enabled then
        for player in pairs(self.Objects) do
            self:RemoveESP(player)
        end
    end
end

function ESP:IsEnabled()
    return self.State.Enabled
end

function ESP:Start()
    if self.State.Running then
        return
    end

    if not self:IsDrawingAvailable() then
        warn("[ESP] Drawing API unavailable.")
        return
    end

    print("[ESP] Drawing API detected.")

    self.State.Running = true

    self:Refresh()
    self:UpdateTarget()

    task.spawn(function()
        while self.State.Running do
            self:Poll()
            task.wait(self.PollInterval)
        end
    end)

    print("[ESP] Started.")
end

function ESP:Stop()
    if not self.State.Running then
        return
    end

    self.State.Running = false

    for player in pairs(self.Objects) do
        self:RemoveESP(player)
    end

    print("[ESP] Stopped.")
end

function ESP:Destroy()
    self:Stop()
end

_G.__GakuranModuleResult = ESP
return ESP
