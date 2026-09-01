```lua
--// =========================================================
--// GAKURAN - UI
--// GitHub / Matcha Version
--// POLLING SAFE
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

UI.PollInterval = 0.1
UI.InputPollInterval = 0.05


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

    print("[UI] Dependencies received.")
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

    local success, object = pcall(function()

        local instance = Instance.new(className)

        for property, value in pairs(properties or {}) do

            pcall(function()
                instance[property] = value
            end)

        end

        instance.Parent = parent

        return instance

    end)

    if not success then

        warn(
            "[UI] Failed to create "
            .. tostring(className)
            .. ": "
            .. tostring(object)
        )

        return nil

    end

    return object

end


--// =========================================================
--// CREATE UI
--// =========================================================

function UI:CreateInterface()

    if self.ScreenGui then

        print("[UI] Interface already exists.")

        return true

    end


    local player = Players.LocalPlayer

    if not player then

        warn("[UI] LocalPlayer not available.")

        return false

    end


    print("[UI] LocalPlayer found: " .. tostring(player.Name))


    local playerGui = nil

    local success = pcall(function()

        playerGui = player:WaitForChild(
            "PlayerGui",
            10
        )

    end)


    if not success or not playerGui then

        warn("[UI] PlayerGui not available.")

        return false

    end


    print("[UI] PlayerGui found.")


    --// ScreenGui

    self.ScreenGui = self:Create(
        "ScreenGui",
        {
            Name = "GakuranUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Enabled = true,
            DisplayOrder = 999
        },
        playerGui
    )


    if not self.ScreenGui then

        warn("[UI] Failed to create ScreenGui.")

        return false

    end


    print("[UI] ScreenGui created.")


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
            Visible = true
        },
        self.ScreenGui
    )


    if not self.MainFrame then

        warn("[UI] Failed to create MainFrame.")

        return false

    end


    --// Make frame draggable manually through polling
    self.Dragging = false
    self.DragStart = nil
    self.DragPosition = nil


    --// Corner

    self:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 10)
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
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        },
        self.MainFrame
    )


    --// Status

    self.StatusLabel = self:Create(
        "TextLabel",
        {
            Name = "Status",
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 42),
            BackgroundTransparency = 1,
            Text = "STATUS: RUNNING",
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left
        },
        self.MainFrame
    )


    --// Target

    self.TargetLabel = self:Create(
        "TextLabel",
        {
            Name = "Target",
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 67),
            BackgroundTransparency = 1,
            Text = "TARGET: NONE",
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left
        },
        self.MainFrame
    )


    --// AutoPlay Button

    self.AutoPlayButton = self:Create(
        "TextButton",
        {
            Name = "AutoPlay",
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, 100),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = "AUTOPLAY: OFF",
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            AutoButtonColor = true
        },
        self.MainFrame
    )


    self:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 7)
        },
        self.AutoPlayButton
    )


    --// ESP Button

    self.ESPButton = self:Create(
        "TextButton",
        {
            Name = "ESP",
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, 140),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = "ESP: ON",
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            AutoButtonColor = true
        },
        self.MainFrame
    )


    self:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 7)
        },
        self.ESPButton
    )


    --// Health Button

    self.HealthButton = self:Create(
        "TextButton",
        {
            Name = "Health",
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, 180),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = "HEALTH: ON",
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            AutoButtonColor = true
        },
        self.MainFrame
    )


    self:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 7)
        },
        self.HealthButton
    )


    --// Footer

    self:Create(
        "TextLabel",
        {
            Name = "Footer",
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 0, 220),
            BackgroundTransparency = 1,
            Text = "[ RightShift ] Toggle UI",
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextXAlignment = Enum.TextXAlignment.Center
        },
        self.MainFrame
    )


    print("[UI] All interface objects created.")

    return true

end


--// =========================================================
--// BUTTON POLLING
--// =========================================================

function UI:ProcessButtons()

    if not self.MainFrame then
        return
    end

    --// AutoPlay
    if self.AutoPlayButton then

        local mouse = Players.LocalPlayer:GetMouse()

        if mouse and mouse.Button1Down then
            --// Button state is handled by MouseButton polling below.
        end

    end

end


--// =========================================================
--// MOUSE BUTTON HANDLING
--// =========================================================

function UI:CheckButton(button, callback)

    if not button then
        return
    end

    local mouse = Players.LocalPlayer:GetMouse()

    if not mouse then
        return
    end

    local position = UserInputService:GetMouseLocation()

    local absolutePosition = button.AbsolutePosition
    local absoluteSize = button.AbsoluteSize

    local inside =
        position.X >= absolutePosition.X
        and position.X <= absolutePosition.X + absoluteSize.X
        and position.Y >= absolutePosition.Y
        and position.Y <= absolutePosition.Y + absoluteSize.Y

    if inside and UserInputService:IsMouseButtonPressed(
        Enum.UserInputType.MouseButton1
    ) then

        if not self.ButtonDebounce then

            self.ButtonDebounce = true

            pcall(callback)

        end

    end

end


--// =========================================================
--// BUTTON UPDATE
--// =========================================================

function UI:UpdateButtons()

    local mouseDown =
        UserInputService:IsMouseButtonPressed(
            Enum.UserInputType.MouseButton1
        )

    if not mouseDown then

        self.ButtonDebounce = false

        return

    end


    local position =
        UserInputService:GetMouseLocation()


    --// AutoPlay

    if self.AutoPlayButton then

        local button = self.AutoPlayButton

        local inside =
            position.X >= button.AbsolutePosition.X
            and position.X <=
                button.AbsolutePosition.X + button.AbsoluteSize.X
            and position.Y >= button.AbsolutePosition.Y
            and position.Y <=
                button.AbsolutePosition.Y + button.AbsoluteSize.Y


        if inside and not self.ButtonDebounce then

            self.ButtonDebounce = true

            if AutoPlay and AutoPlay.IsEnabled then

                local enabled =
                    not AutoPlay:IsEnabled()

                AutoPlay:SetEnabled(enabled)

                button.Text =
                    enabled
                    and "AUTOPLAY: ON"
                    or "AUTOPLAY: OFF"

                print(
                    "[UI] AutoPlay:",
                    enabled
                )

            end

        end

    end


    --// ESP

    if self.ESPButton then

        local button = self.ESPButton

        local inside =
            position.X >= button.AbsolutePosition.X
            and position.X <=
                button.AbsolutePosition.X + button.AbsoluteSize.X
            and position.Y >= button.AbsolutePosition.Y
            and position.Y <=
                button.AbsolutePosition.Y + button.AbsoluteSize.Y


        if inside and not self.ButtonDebounce then

            self.ButtonDebounce = true

            if ESP and ESP.IsEnabled then

                local enabled =
                    not ESP:IsEnabled()

                ESP:SetEnabled(enabled)

                button.Text =
                    enabled
                    and "ESP: ON"
                    or "ESP: OFF"

                print(
                    "[UI] ESP:",
                    enabled
                )

            end

        end

    end


    --// Health

    if self.HealthButton then

        local button = self.HealthButton

        local inside =
            position.X >= button.AbsolutePosition.X
            and position.X <=
                button.AbsolutePosition.X + button.AbsoluteSize.X
            and position.Y >= button.AbsolutePosition.Y
            and position.Y <=
                button.AbsolutePosition.Y + button.AbsoluteSize.Y


        if inside and not self.ButtonDebounce then

            self.ButtonDebounce = true

            if HealthOverlay
                and HealthOverlay.IsEnabled then

                local enabled =
                    not HealthOverlay:IsEnabled()

                HealthOverlay:SetEnabled(enabled)

                button.Text =
                    enabled
                    and "HEALTH: ON"
                    or "HEALTH: OFF"

                print(
                    "[UI] HealthOverlay:",
                    enabled
                )

            end

        end

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

            if self.TargetLabel then
                self.TargetLabel.Text =
                    "TARGET: " .. name
            end

        else

            if self.TargetLabel then
                self.TargetLabel.Text =
                    "TARGET: NONE"
            end

        end

    end


    --// Status

    if self.StatusLabel then

        self.StatusLabel.Text =
            "STATUS: "
            .. (
                self.State.Running
                and "RUNNING"
                or "STOPPED"
            )

    end


    --// Make sure UI remains visible

    if self.ScreenGui then
        self.ScreenGui.Enabled = true
    end

    if self.MainFrame then
        self.MainFrame.Visible =
            self.State.Visible
    end

end


--// =========================================================
--// KEYBOARD POLLING
--// =========================================================

function UI:CheckKeyboard()

    local success, pressed =
        pcall(function()

            return UserInputService:IsKeyDown(
                Enum.KeyCode.RightShift
            )

        end)


    if not success then
        return
    end


    if pressed and not self.RightShiftDown then

        self.RightShiftDown = true

        self:Toggle()

        print(
            "[UI] RightShift:",
            self.State.Visible
        )

    elseif not pressed then

        self.RightShiftDown = false

    end

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


    print("[UI] Creating interface...")


    local created = self:CreateInterface()


    if not created then

        self.State.Running = false

        warn(
            "[UI] Interface creation FAILED."
        )

        return

    end


    print(
        "[UI] Interface creation SUCCESS."
    )


    task.spawn(function()

        while self.State.Running do

            pcall(function()

                self:Update()
                self:UpdateButtons()
                self:CheckKeyboard()

            end)

            task.wait(
                self.PollInterval
            )

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


    if self.ScreenGui then

        pcall(function()
            self.ScreenGui:Destroy()
        end)

    end


    self.ScreenGui = nil
    self.MainFrame = nil
    self.StatusLabel = nil
    self.TargetLabel = nil
    self.AutoPlayButton = nil
    self.ESPButton = nil
    self.HealthButton = nil


    print("[UI] Stopped.")

end


--// =========================================================
--// FINAL MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult = UI
return UI
```
