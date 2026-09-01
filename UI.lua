--// =========================================================
--// GAKURAN - UI
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local UI = {}

--// Dependencies
local Config = nil
local TargetManager = nil
local ParryController = nil
local ESP = nil
local HealthOverlay = nil
local AutoPlay = nil
local Logger = nil

--// State
UI.State = {
    Running = false,
    Visible = true
}

UI.ScreenGui = nil
UI.MainFrame = nil
UI.StatusLabel = nil
UI.TargetLabel = nil
UI.AutoPlayButton = nil
UI.ESPButton = nil
UI.HealthButton = nil
UI.Connections = {}


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function UI:SetDependencies(
    config,
    targetManager,
    parryController,
    esp,
    healthOverlay,
    autoPlay,
    logger
)
    Config = config
    TargetManager = targetManager
    ParryController = parryController
    ESP = esp
    HealthOverlay = healthOverlay
    AutoPlay = autoPlay
    Logger = logger
end


--// =========================================================
--// INITIALIZE
--// =========================================================

function UI:Initialize(state)

    self.SharedState = state

    print("[UI] Initialized.")

end


--// =========================================================
--// CREATE OBJECT
--// =========================================================

function UI:Create(className, properties, parent)

    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    object.Parent = parent

    return object

end


--// =========================================================
--// CREATE UI
--// =========================================================

function UI:CreateInterface()

    if self.ScreenGui then
        return
    end


    local player = Players.LocalPlayer

    if not player then
        return
    end


    local playerGui =
        player:WaitForChild("PlayerGui")


    --// ScreenGui

    self.ScreenGui = self:Create(
        "ScreenGui",
        {
            Name = "GakuranUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        },
        playerGui
    )


    --// Main Frame

    self.MainFrame = self:Create(
        "Frame",
        {
            Name = "Main",
            Size = UDim2.new(0, 300, 0, 250),
            Position = UDim2.new(
                0.5,
                -150,
                0.5,
                -125
            ),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Active = true,
            Draggable = true
        },
        self.ScreenGui
    )


    --// Corner

    local corner =
        self:Create(
            "UICorner",
            {
                CornerRadius =
                    UDim.new(0, 10)
            },
            self.MainFrame
        )


    --// Title

    self:Create(
        "TextLabel",
        {
            Name = "Title",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "GAKURAN",
            TextSize = 20,
            Font = Enum.Font.GothamBold
        },
        self.MainFrame
    )


    --// Status

    self.StatusLabel =
        self:Create(
            "TextLabel",
            {
                Name = "Status",
                Size = UDim2.new(
                    1,
                    -20,
                    0,
                    25
                ),
                Position = UDim2.new(
                    0,
                    10,
                    0,
                    42
                ),
                BackgroundTransparency = 1,
                Text = "STATUS: RUNNING",
                TextSize = 13,
                Font = Enum.Font.Gotham
            },
            self.MainFrame
        )


    --// Target

    self.TargetLabel =
        self:Create(
            "TextLabel",
            {
                Name = "Target",
                Size = UDim2.new(
                    1,
                    -20,
                    0,
                    25
                ),
                Position = UDim2.new(
                    0,
                    10,
                    0,
                    67
                ),
                BackgroundTransparency = 1,
                Text = "TARGET: NONE",
                TextSize = 13,
                Font = Enum.Font.Gotham
            },
            self.MainFrame
        )


    --// AutoPlay Button

    self.AutoPlayButton =
        self:Create(
            "TextButton",
            {
                Name = "AutoPlay",
                Size = UDim2.new(
                    1,
                    -20,
                    0,
                    35
                ),
                Position = UDim2.new(
                    0,
                    10,
                    0,
                    100
                ),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Text = "AUTOPLAY: OFF",
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = true
            },
            self.MainFrame
        )


    self:Create(
        "UICorner",
        {
            CornerRadius =
                UDim.new(0, 7)
        },
        self.AutoPlayButton
    )


    --// ESP Button

    self.ESPButton =
        self:Create(
            "TextButton",
            {
                Name = "ESP",
                Size = UDim2.new(
                    1,
                    -20,
                    0,
                    35
                ),
                Position = UDim2.new(
                    0,
                    10,
                    0,
                    140
                ),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Text = "ESP: ON",
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = true
            },
            self.MainFrame
        )


    self:Create(
        "UICorner",
        {
            CornerRadius =
                UDim.new(0, 7)
        },
        self.ESPButton
    )


    --// Health Overlay Button

    self.HealthButton =
        self:Create(
            "TextButton",
            {
                Name = "Health",
                Size = UDim2.new(
                    1,
                    -20,
                    0,
                    35
                ),
                Position = UDim2.new(
                    0,
                    10,
                    0,
                    180
                ),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Text = "HEALTH: ON",
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = true
            },
            self.MainFrame
        )


    self:Create(
        "UICorner",
        {
            CornerRadius =
                UDim.new(0, 7)
        },
        self.HealthButton
    )


    --// Footer

    self:Create(
        "TextLabel",
        {
            Name = "Footer",
            Size = UDim2.new(
                1,
                -20,
                0,
                20
            ),
            Position = UDim2.new(
                0,
                10,
                0,
                220
            ),
            BackgroundTransparency = 1,
            Text = "[ RightShift ] Toggle UI",
            TextSize = 11,
            Font = Enum.Font.Gotham
        },
        self.MainFrame
    )


    self:SetupButtons()

end


--// =========================================================
--// BUTTONS
--// =========================================================

function UI:SetupButtons()

    if self.AutoPlayButton then

        local connection =
            self.AutoPlayButton.MouseButton1Click:Connect(
                function()

                    if not AutoPlay then
                        return
                    end

                    local enabled =
                        not AutoPlay:IsEnabled()

                    AutoPlay:SetEnabled(enabled)

                    self.AutoPlayButton.Text =
                        enabled
                        and "AUTOPLAY: ON"
                        or "AUTOPLAY: OFF"

                end
            )

        table.insert(
            self.Connections,
            connection
        )

    end


    if self.ESPButton then

        local connection =
            self.ESPButton.MouseButton1Click:Connect(
                function()

                    if not ESP then
                        return
                    end

                    local enabled =
                        not ESP:IsEnabled()

                    ESP:SetEnabled(enabled)

                    self.ESPButton.Text =
                        enabled
                        and "ESP: ON"
                        or "ESP: OFF"

                end
            )

        table.insert(
            self.Connections,
            connection
        )

    end


    if self.HealthButton then

        local connection =
            self.HealthButton.MouseButton1Click:Connect(
                function()

                    if not HealthOverlay then
                        return
                    end

                    local enabled =
                        not HealthOverlay:IsEnabled()

                    HealthOverlay:SetEnabled(enabled)

                    self.HealthButton.Text =
                        enabled
                        and "HEALTH: ON"
                        or "HEALTH: OFF"

                end
            )

        table.insert(
            self.Connections,
            connection
        )

    end

end


--// =========================================================
--// UPDATE
--// =========================================================

function UI:Update()

    if not self.State.Running then
        return
    end

    if not self.MainFrame then
        return
    end


    --// Target

    if TargetManager
        and TargetManager.GetCurrentTarget then

        local success, target =
            pcall(function()
                return TargetManager:GetCurrentTarget()
            end)

        if success and target then

            local name = "UNKNOWN"

            if typeof(target) == "Instance" then

                if target:IsA("Player") then
                    name = target.Name

                elseif target:IsA("Model") then
                    name = target.Name
                end

            end

            self.TargetLabel.Text =
                "TARGET: " .. name

        else

            self.TargetLabel.Text =
                "TARGET: NONE"

        end

    end


    --// Status

    self.StatusLabel.Text =
        "STATUS: "
        .. (self.State.Running
            and "RUNNING"
            or "STOPPED")

end


--// =========================================================
--// TOGGLE
--// =========================================================

function UI:Toggle()

    self.State.Visible =
        not self.State.Visible

    if self.MainFrame then

        self.MainFrame.Visible =
            self.State.Visible

    end

end


--// =========================================================
--// START
--// =========================================================

function UI:Start()

    if self.State.Running then
        return
    end

    self.State.Running = true

    self:CreateInterface()


    local connection =
        UserInputService.InputBegan:Connect(
            function(input, gameProcessed)

                if gameProcessed then
                    return
                end

                if input.KeyCode ==
                    Enum.KeyCode.RightShift then

                    self:Toggle()

                end

            end
        )


    table.insert(
        self.Connections,
        connection
    )


    task.spawn(function()

        while self.State.Running do

            self:Update()

            task.wait(0.1)

        end

    end)


    print("[UI] Started.")

end


--// =========================================================
--// STOP
--// =========================================================

function UI:Stop()

    if not self.State.Running then
        return
    end

    self.State.Running = false


    for _, connection in
        ipairs(self.Connections) do

        if connection then

            pcall(function()
                connection:Disconnect()
            end)

        end

    end


    table.clear(self.Connections)


    if self.ScreenGui then

        pcall(function()
            self.ScreenGui:Destroy()
        end)

    end


    self.ScreenGui = nil
    self.MainFrame = nil


    print("[UI] Stopped.")

end


return UI
