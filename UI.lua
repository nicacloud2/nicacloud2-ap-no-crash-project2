--// =========================================================
--// GAKURAN - UI
--// GitHub / Matcha Version
--// MATCHA NATIVE UI
--// =========================================================

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
--// SAFE VALUE
--// =========================================================

function UI:GetValue(id, default)

    local success, value = pcall(function()

        return UI.GetValue(id)

    end)

    if success and value ~= nil then
        return value
    end

    return default

end

--// =========================================================
--// CREATE MATCHA UI
--// =========================================================

function UI:CreateInterface()

    if not UI then
        warn("[UI] UI library unavailable.")
        return false
    end

    if type(UI.AddTab) ~= "function" then
        warn("[UI] Matcha UI.AddTab unavailable.")
        return false
    end

    print("[UI] Creating Matcha UI...")

    UI.AddTab("Gakuran", function(tab)

        --// =================================================
        --// STATUS
        --// =================================================

        local status = tab:Section(
            "Status",
            "Left"
        )

        status:Label(
            "Gakuran Matcha Interface"
        )

        status:Label(
            "Status: Running"
        )

        status:Label(
            "Target information is shown here."
        )

        --// =================================================
        --// CONTROLS
        --// =================================================

        local controls = tab:Section(
            "Controls",
            "Left"
        )

        controls:Toggle(
            "gakuran_ui_enabled",
            "Enabled"
        )

        controls:Keybind(
            "gakuran_ui_enabled_kb",
            0x46,
            "hold"
        )

        --// =================================================
        --// FEATURES
        --// =================================================

        local features = tab:Section(
            "Features",
            "Right"
        )

        features:Toggle(
            "gakuran_autoplay",
            "AutoPlay"
        )

        features:Toggle(
            "gakuran_esp",
            "ESP"
        )

        features:Toggle(
            "gakuran_health",
            "Health Overlay"
        )

        --// =================================================
        --// INFORMATION
        --// =================================================

        local information = tab:Section(
            "Information",
            "Right"
        )

        information:Label(
            "Gakuran Project"
        )

        information:Label(
            "Matcha Native UI"
        )

        information:Label(
            "Modules loaded externally."
        )

    end)

    print("[UI] Matcha UI created.")

    return true

end

--// =========================================================
--// UPDATE
--// =========================================================

function UI:Update()

    if not self.State.Running then
        return
    end

    --// Read UI values safely

    local enabled =
        self:GetValue(
            "gakuran_ui_enabled",
            true
        )

    local autoplay =
        self:GetValue(
            "gakuran_autoplay",
            false
        )

    local esp =
        self:GetValue(
            "gakuran_esp",
            true
        )

    local health =
        self:GetValue(
            "gakuran_health",
            true
        )

    self.State.Visible = enabled

    --// AutoPlay state

    if AutoPlay then

        pcall(function()

            if autoplay then

                if not AutoPlay.State.Running then
                    AutoPlay:Start()
                end

            else

                if AutoPlay.State.Running then
                    AutoPlay:Stop()
                end

            end

        end)

    end

    --// ESP state

    if ESP then

        pcall(function()

            if esp then

                if not ESP.State.Running then
                    ESP:Start()
                end

            else

                if ESP.State.Running then
                    ESP:Stop()
                end

            end

        end)

    end

    --// Health state

    if HealthOverlay then

        pcall(function()

            if health then

                if not HealthOverlay.State.Running then
                    HealthOverlay:Start()
                end

            else

                if HealthOverlay.State.Running then
                    HealthOverlay:Stop()
                end

            end

        end)

    end

end

--// =========================================================
--// START
--// =========================================================

function UI:Start()

    if self.State.Running then
        print("[UI] Already running.")
        return
    end

    print("[UI] Starting...")

    local success, result = pcall(function()

        return self:CreateInterface()

    end)

    if not success then

        warn(
            "[UI] UI creation error:",
            tostring(result)
        )

        self.State.Running = false

        return

    end

    if not result then

        warn("[UI] Interface creation FAILED.")

        self.State.Running = false

        return

    end

    self.State.Running = true

    print("[UI] Interface creation SUCCESS.")

    task.spawn(function()

        while self.State.Running do

            pcall(function()

                self:Update()

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

    pcall(function()

        UI.RemoveTab(
            "Gakuran"
        )

    end)

    print("[UI] Stopped.")

end

--// =========================================================
--// FINAL MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult = UI

return UI
