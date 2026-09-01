--// HealthOverlay.lua
--// Gakuran Health Overlay Module

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = require(script.Parent.Config)
local TargetManager = require(script.Parent.TargetManager)

local HealthOverlay = {}

--------------------------------------------------
--// State
--------------------------------------------------

HealthOverlay.State = nil
HealthOverlay.Running = false
HealthOverlay.Entries = {}

--------------------------------------------------
--// Initialize
--------------------------------------------------

function HealthOverlay:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Get Root
--------------------------------------------------

function HealthOverlay:GetRoot(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
--// Get Humanoid
--------------------------------------------------

function HealthOverlay:GetHumanoid(character)
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------
--// Create Health Billboard
--------------------------------------------------

function HealthOverlay:Create(character)
    if not character then
        return nil
    end

    local root = self:GetRoot(character)

    if not root then
        return nil
    end

    local existing = root:FindFirstChild(
        "GakuranHealthOverlay"
    )

    if existing then
        return existing
    end

    --------------------------------------------------
    -- Billboard
    --------------------------------------------------

    local billboard = Instance.new("BillboardGui")

    billboard.Name =
        "GakuranHealthOverlay"

    billboard.Adornee = root

    billboard.Size = UDim2.new(
        0,
        12,
        0,
        100
    )

    billboard.StudsOffset =
        Vector3.new(-3, 0, 0)

    billboard.AlwaysOnTop = true

    billboard.Enabled =
        Config.ESP.Enabled
        and Config.ESP.ShowHealth

    billboard.Parent = root

    --------------------------------------------------
    -- Background
    --------------------------------------------------

    local background = Instance.new("Frame")

    background.Name = "Background"

    background.Size =
        UDim2.fromScale(1, 1)

    background.BackgroundTransparency = 0.3

    background.BorderSizePixel = 0

    background.Parent = billboard

    --------------------------------------------------
    -- Health Bar
    --------------------------------------------------

    local bar = Instance.new("Frame")

    bar.Name = "Health"

    bar.AnchorPoint =
        Vector2.new(0, 1)

    bar.Position =
        UDim2.fromScale(0, 1)

    bar.Size =
        UDim2.fromScale(1, 1)

    bar.BorderSizePixel = 0

    bar.Parent = background

    --------------------------------------------------
    -- HP Text
    --------------------------------------------------

    local text = Instance.new("TextLabel")

    text.Name = "Text"

    text.AnchorPoint =
        Vector2.new(0.5, 0.5)

    text.Position =
        UDim2.fromScale(0.5, 0.5)

    text.Size =
        UDim2.new(0, 80, 0, 20)

    text.BackgroundTransparency = 1

    text.TextScaled = false
    text.TextSize = 12

    text.Font =
        Enum.Font.GothamBold

    text.Parent = billboard

    return billboard
end

--------------------------------------------------
--// Update Health
--------------------------------------------------

function HealthOverlay:Update(character)
    if not character then
        return
    end

    local humanoid =
        self:GetHumanoid(character)

    if not humanoid then
        return
    end

    local billboard =
        self:Create(character)

    if not billboard then
        return
    end

    local background =
        billboard:FindFirstChild(
            "Background"
        )

    if not background then
        return
    end

    local bar =
        background:FindFirstChild(
            "Health"
        )

    local text =
        billboard:FindFirstChild(
            "Text"
        )

    if not bar then
        return
    end

    --------------------------------------------------
    -- Health Percentage
    --------------------------------------------------

    local maxHealth =
        humanoid.MaxHealth

    if maxHealth <= 0 then
        maxHealth = 1
    end

    local health =
        math.clamp(
            humanoid.Health / maxHealth,
            0,
            1
        )

    --------------------------------------------------
    -- Update Bar
    --------------------------------------------------

    bar.Size =
        UDim2.fromScale(
            1,
            health
        )

    --------------------------------------------------
    -- Update Text
    --------------------------------------------------

    if text then
        text.Text = string.format(
            "%.0f / %.0f",
            humanoid.Health,
            humanoid.MaxHealth
        )
    end

    --------------------------------------------------
    -- Visibility
    --------------------------------------------------

    billboard.Enabled =
        Config.ESP.Enabled
        and Config.ESP.ShowHealth
end

--------------------------------------------------
--// Setup Character
--------------------------------------------------

function HealthOverlay:Setup(character)
    if not character then
        return
    end

    if character == LocalPlayer.Character then
        return
    end

    if not TargetManager:IsValidCharacter(
        character
    ) then
        return
    end

    self.Entries[character] = true

    self:Create(character)
end

--------------------------------------------------
--// Remove Character
--------------------------------------------------

function HealthOverlay:Remove(character)
    if not character then
        return
    end

    local root =
        self:GetRoot(character)

    if root then
        local billboard =
            root:FindFirstChild(
                "GakuranHealthOverlay"
            )

        if billboard then
            billboard:Destroy()
        end
    end

    self.Entries[character] = nil
end

--------------------------------------------------
--// Refresh
--------------------------------------------------

function HealthOverlay:Refresh()
    if not Config.ESP.Enabled
        or not Config.ESP.ShowHealth
    then

        self:HideAll()

        return
    end

    local targets =
        TargetManager:GetTargets()

    local active = {}

    for _, character in ipairs(targets) do

        if TargetManager:IsValidCharacter(
            character
        ) then

            active[character] = true

            self:Setup(character)
            self:Update(character)
        end
    end

    --------------------------------------------------
    -- Remove old entries
    --------------------------------------------------

    for character in pairs(self.Entries) do

        if not active[character] then
            self:Remove(character)
        end

    end
end

--------------------------------------------------
--// Hide All
--------------------------------------------------

function HealthOverlay:HideAll()
    for character in pairs(self.Entries) do

        local root =
            self:GetRoot(character)

        if root then

            local billboard =
                root:FindFirstChild(
                    "GakuranHealthOverlay"
                )

            if billboard then
                billboard.Enabled = false
            end
        end
    end
end

--------------------------------------------------
--// Show All
--------------------------------------------------

function HealthOverlay:ShowAll()
    for character in pairs(self.Entries) do

        local root =
            self:GetRoot(character)

        if root then

            local billboard =
                root:FindFirstChild(
                    "GakuranHealthOverlay"
                )

            if billboard then
                billboard.Enabled =
                    Config.ESP.Enabled
                    and Config.ESP.ShowHealth
            end
        end
    end
end

--------------------------------------------------
--// Start
--------------------------------------------------

function HealthOverlay:Start()
    if self.Running then
        return
    end

    self.Running = true

    task.spawn(function()

        while self.Running do

            self:Refresh()

            task.wait(0.1)
        end

    end)
end

--------------------------------------------------
--// Stop
--------------------------------------------------

function HealthOverlay:Stop()
    self.Running = false

    for character in pairs(self.Entries) do
        self:Remove(character)
    end

    self.Entries = {}
end

return HealthOverlay
