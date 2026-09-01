--// ESP.lua
--// Gakuran ESP Module

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = require(script.Parent.Config)
local TargetManager = require(script.Parent.TargetManager)
local AnimationTracker = require(script.Parent.AnimationTracker)

local ESP = {}

--------------------------------------------------
--// State
--------------------------------------------------

ESP.State = nil
ESP.Running = false

ESP.Objects = {}
ESP.TargetHighlight = nil

--------------------------------------------------
--// Initialize
--------------------------------------------------

function ESP:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Create Highlight
--------------------------------------------------

function ESP:CreateHighlight(character)
    if not character then
        return nil
    end

    local existing = character:FindFirstChild(
        "GakuranESPHighlight"
    )

    if existing then
        return existing
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "GakuranESPHighlight"
    highlight.Adornee = character

    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0

    highlight.Enabled = Config.ESP.Enabled

    highlight.Parent = character

    return highlight
end

--------------------------------------------------
--// Remove Highlight
--------------------------------------------------

function ESP:RemoveHighlight(character)
    if not character then
        return
    end

    local highlight = character:FindFirstChild(
        "GakuranESPHighlight"
    )

    if highlight then
        highlight:Destroy()
    end
end

--------------------------------------------------
--// Update Target Highlight
--------------------------------------------------

function ESP:UpdateTargetHighlight()
    if not Config.ESP.ShowTarget then
        return
    end

    local target =
        TargetManager:GetCurrentTarget()

    --------------------------------------------------
    -- Remove old target highlight
    --------------------------------------------------

    if self.TargetHighlight
        and self.TargetHighlight ~= target
    then

        self:RemoveHighlight(
            self.TargetHighlight
        )

        self.TargetHighlight = nil
    end

    --------------------------------------------------
    -- Apply new highlight
    --------------------------------------------------

    if target then
        self:CreateHighlight(target)

        self.TargetHighlight = target
    end
end

--------------------------------------------------
--// Create Billboard
--------------------------------------------------

function ESP:CreateBillboard(character)
    if not character then
        return nil
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then
        return nil
    end

    local existing = root:FindFirstChild(
        "GakuranESP"
    )

    if existing then
        return existing
    end

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "GakuranESP"
    billboard.Adornee = root

    billboard.Size = UDim2.new(
        0,
        200,
        0,
        70
    )

    billboard.StudsOffset =
        Vector3.new(0, 3, 0)

    billboard.AlwaysOnTop = true

    billboard.Enabled =
        Config.ESP.Enabled

    billboard.Parent = root

    --------------------------------------------------
    -- Main Text
    --------------------------------------------------

    local text = Instance.new("TextLabel")

    text.Name = "Info"
    text.Size = UDim2.fromScale(1, 1)

    text.BackgroundTransparency = 1

    text.TextScaled = false
    text.TextSize = 14

    text.Font =
        Enum.Font.GothamBold

    text.Text = ""

    text.Parent = billboard

    return billboard
end

--------------------------------------------------
--// Update Billboard
--------------------------------------------------

function ESP:UpdateBillboard(character)
    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not humanoid or not root then
        return
    end

    local billboard =
        self:CreateBillboard(character)

    if not billboard then
        return
    end

    local text =
        billboard:FindFirstChild("Info")

    if not text then
        return
    end

    --------------------------------------------------
    -- Distance
    --------------------------------------------------

    local distance =
        TargetManager:GetDistance(character)

    --------------------------------------------------
    -- Player Name
    --------------------------------------------------

    local player =
        Players:GetPlayerFromCharacter(
            character
        )

    local name =
        player
        and player.DisplayName
        or character.Name

    --------------------------------------------------
    -- Animation
    --------------------------------------------------

    local animationText = ""

    local tracks =
        AnimationTracker:GetPlayingAnimations(
            character
        )

    for _, track in ipairs(tracks) do

        local animationId =
            AnimationTracker:GetAnimationId(
                track
            )

        if animationId
            and AnimationTracker:IsKnown(
                animationId
            )
        then

            animationText =
                AnimationTracker:GetDisplayName(
                    animationId
                )

            break
        end
    end

    --------------------------------------------------
    -- Build Text
    --------------------------------------------------

    local lines = {}

    if Config.ESP.ShowName then
        table.insert(
            lines,
            name
        )
    end

    if Config.ESP.ShowDistance then
        table.insert(
            lines,
            string.format(
                "%.1f studs",
                distance
            )
        )
    end

    if animationText ~= "" then
        table.insert(
            lines,
            animationText
        )
    end

    if Config.ESP.ShowHealth then
        table.insert(
            lines,
            string.format(
                "HP: %.0f / %.0f",
                humanoid.Health,
                humanoid.MaxHealth
            )
        )
    end

    text.Text =
        table.concat(lines, "\n")
end

--------------------------------------------------
--// Setup Character
--------------------------------------------------

function ESP:SetupCharacter(character)
    if not character then
        return
    end

    if character == LocalPlayer.Character then
        return
    end

    self.Objects[character] = true

    self:CreateHighlight(character)
    self:CreateBillboard(character)
end

--------------------------------------------------
--// Remove Character
--------------------------------------------------

function ESP:RemoveCharacter(character)
    if not character then
        return
    end

    self:RemoveHighlight(character)

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if root then
        local billboard =
            root:FindFirstChild(
                "GakuranESP"
            )

        if billboard then
            billboard:Destroy()
        end
    end

    self.Objects[character] = nil
end

--------------------------------------------------
--// Refresh
--------------------------------------------------

function ESP:Refresh()
    if not Config.ESP.Enabled then
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

            self:SetupCharacter(character)

            self:UpdateBillboard(character)
        end
    end

    --------------------------------------------------
    -- Remove old objects
    --------------------------------------------------

    for character in pairs(self.Objects) do

        if not active[character] then
            self:RemoveCharacter(character)
        end

    end

    self:UpdateTargetHighlight()
end

--------------------------------------------------
--// Hide All
--------------------------------------------------

function ESP:HideAll()
    for character in pairs(self.Objects) do

        local highlight =
            character:FindFirstChild(
                "GakuranESPHighlight"
            )

        if highlight then
            highlight.Enabled = false
        end

        local root =
            character:FindFirstChild(
                "HumanoidRootPart"
            )

        if root then
            local billboard =
                root:FindFirstChild(
                    "GakuranESP"
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

function ESP:ShowAll()
    for character in pairs(self.Objects) do

        local highlight =
            character:FindFirstChild(
                "GakuranESPHighlight"
            )

        if highlight then
            highlight.Enabled =
                Config.ESP.Enabled
        end

        local root =
            character:FindFirstChild(
                "HumanoidRootPart"
            )

        if root then
            local billboard =
                root:FindFirstChild(
                    "GakuranESP"
                )

            if billboard then
                billboard.Enabled =
                    Config.ESP.Enabled
            end
        end
    end
end

--------------------------------------------------
--// Start
--------------------------------------------------

function ESP:Start()
    if self.Running then
        return
    end

    self.Running = true

    task.spawn(function()

        while self.Running do

            if Config.ESP.Enabled then
                self:Refresh()
            else
                self:HideAll()
            end

            task.wait(0.1)
        end

    end)
end

--------------------------------------------------
--// Stop
--------------------------------------------------

function ESP:Stop()
    self.Running = false

    for character in pairs(self.Objects) do
        self:RemoveCharacter(character)
    end

    self.Objects = {}
    self.TargetHighlight = nil
end

return ESP
