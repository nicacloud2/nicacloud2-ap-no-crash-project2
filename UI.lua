
--// =========================================================
--// GAKURAN - UI
--// GitHub / Matcha Version
--// MATCHA SAFE UI
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
--// SAFE INSTANCE CREATION
--// =========================================================

function UI:Create(className, properties, parent)

    local success, object = pcall(function()

        local creator = game

        if not creator then
            error("game unavailable")
        end

        local instanceService = game:GetService("CoreGui")

        if not instanceService then
            error("CoreGui unavailable")
        end

        -- Try Instance.new first through the global environment.
        if Instance and Instance.new then

            local obj = Instance.new(className)

            for property, value in pairs(properties or {}) do

                pcall(function()
                    obj[property] = value
                end)

            end

            obj.Parent = parent

            return obj

        end

        error("Instance.new unavailable")

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
--// FIND UI PARENT
--// =========================================================

function UI:GetUIParent()

    --// Try CoreGui
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if success and coreGui then
        print("[UI] CoreGui found.")
        return coreGui
    end


    --// Fallback PlayerGui
    local player = Players.LocalPlayer

    if not player then
        warn("[UI] LocalPlayer unavailable.")
        return nil
    end


    local playerGui

    local guiSuccess = pcall(function()

        playerGui = player:FindFirstChildOfClass(
            "PlayerGui"
        )

    end)


    if guiSuccess and playerGui then

        print("[UI] PlayerGui found.")

        return playerGui

    end


    warn("[UI] No valid UI parent found.")

    return nil

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


    print(
        "[UI] LocalPlayer found: "
        .. tostring(player.Name)
    )


    local parent = self:GetUIParent()

    if not parent then

        warn("[UI] UI parent unavailable.")

        return false

    end


    print("[UI] Creating ScreenGui...")


    self.ScreenGui = self:Create(
        "ScreenGui",
        {
            Name = "GakuranUI",
            ResetOnSpawn = false,
            Enabled = true,
            DisplayOrder = 999
        },
        parent
    )


    if not self.ScreenGui then

        warn("[UI] Failed to create ScreenGui.")

        return false

    end


    print("[UI] ScreenGui created.")


    --// =====================================================
    --// MAIN FRAME
    --// =====================================================

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


    --// =====================================================
    --// TITLE
    --// =====================================================

    self:Create(
        "TextLabel",
        {
            Name = "Title",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "GAKURAN",
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(
                255,
                255,
                255
            ),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        },
        self.MainFrame
    )


    --// =====================================================
    --// STATUS
    --// =====================================================

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
            TextColor3 = Color3.fromRGB(
                255,
                255,
                255
            ),
            TextXAlignment = Enum.TextXAlignment.Left
        },
        self.MainFrame
    )


    --// =====================================================
    --// TARGET
    --// =====================================================

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
            TextColor3 = Color3.fromRGB(
                255,
                255,
                255
            ),
            TextXAlignment = Enum.TextXAlignment.Left
        },
        self.MainFrame
    )


    --// =====================================================
    --// AUTOPLAY
    --// =====================================================

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
            TextColor3 = Color3.fromRGB(
                255,
                255,
                255
            ),
            AutoButtonColor = true
        },
        self.MainFrame
    )


    --// =====================================================
    --// ESP
    --// =====================================================

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
            TextColor3 = Color3.fromRGB(
                255,
                255,
                255
            ),
            AutoButtonColor = true
        },
        self.MainFrame
    )


    --// =====================================================
    --// HEALTH
    --// =====================================================

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
            TextColor3 = Color3.fromRGB(
                255,
                255,
                255
            ),
            AutoButtonColor = true
        },
        self.MainFrame
    )


    --// =====================================================
    --// FOOTER
    --// =====================================================

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
            TextColor3 = Color3.fromRGB(
                200,
                200,
                200
            ),
            TextXAlignment = Enum.TextXAlignment.Center
        },
        self.MainFrame
    )


    print("[UI] All interface objects created.")

    return true

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


    --// Target display

    if TargetManager
        and TargetManager.GetCurrentTarget then

        local success, target =
            pcall(function()

                return TargetManager:GetCurrentTarget()

            end)


        if success and target then

            local name = "UNKNOWN"

            if typeof(target) == "Instance" then

                name = target.Name

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


    --// Visibility

    if self.ScreenGui then

        pcall(function()
            self.ScreenGui.Enabled = true
        end)

    end


    if self.MainFrame then

        pcall(function()

            self.MainFrame.Visible =
                self.State.Visible

        end)

    end

end


--// =========================================================
--// KEYBOARD
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


    local created =
        self:CreateInterface()


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

