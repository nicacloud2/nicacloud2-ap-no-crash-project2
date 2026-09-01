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
UI.MatchaUI = nil

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
--// FIND MATCHA UI API
--// =========================================================

function UI:FindMatchaUI()

    print("[UI] Searching for Matcha UI API...")

    local candidates = {
        rawget(_G, "UI"),
        rawget(_G, "ui"),
        rawget(_G, "Menu"),
        rawget(_G, "menu"),
        rawget(_G, "Library"),
        rawget(_G, "library"),
        rawget(_G, "MatchaUI"),
        rawget(_G, "Matcha")
    }

    for _, candidate in ipairs(candidates) do

        if candidate
            and type(candidate) == "table" then

            if type(candidate.AddTab) == "function" then

                print("[UI] Matcha UI API found.")

                return candidate

            end

        end

    end

    warn("[UI] Matcha UI API was not found.")

    return nil

end

--// =========================================================
--// CREATE INTERFACE
--// =========================================================

function UI:CreateInterface()

    local matchaUI = self:FindMatchaUI()

    if not matchaUI then

        warn(
            "[UI] Cannot create interface:"
            .. " Matcha UI Binding unavailable."
        )

        return false

    end

    self.MatchaUI = matchaUI

    print("[UI] Creating Gakuran tab...")

    local success, result = pcall(function()

        return matchaUI.AddTab(
            "Gakuran",
            function(tab)

                --// STATUS
                local status =
                    tab:Section(
                        "Status",
                        "Left"
                    )

                status:Label(
                    "Gakuran Matcha Interface"
                )

                status:Label(
                    "System: Running"
                )

                status:Label(
                    "Target: Automatic"
                )

                --// CONTROLS
                local controls =
                    tab:Section(
                        "Controls",
                        "Left"
                    )

                controls:Toggle(
                    "gakuran_enabled",
                    "Enabled"
                )

                --// FEATURES
                local features =
                    tab:Section(
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

                --// INFORMATION
                local information =
                    tab:Section(
                        "Information",
                        "Right"
                    )

                information:Label(
                    "GAKURAN"
                )

                information:Label(
                    "Matcha Native Interface"
                )

                information:Label(
                    "Modules: Loaded"
                )

            end
        )

    end)

    if not success then

        warn(
            "[UI] Matcha UI creation failed:"
            .. tostring(result)
        )

        self.MatchaUI = nil

        return false

    end

    print("[UI] Gakuran tab created.")

    return true

end

--// =========================================================
--// GET VALUE
--// =========================================================

function UI:GetSetting(id, default)

    local matchaUI = self.MatchaUI

    if not matchaUI then
        return default
    end

    if type(matchaUI.GetValue) ~= "function" then
        return default
    end

    local success, value = pcall(function()

        return matchaUI.GetValue(id)

    end)

    if success and value ~= nil then
        return value
    end

    return default

end

--// =========================================================
--// UPDATE
--// =========================================================

function UI:Update()

    if not self.State.Running then
        return
    end

    --// Enabled
    local enabled =
        self:GetSetting(
            "gakuran_enabled",
            true
        )

    self.State.Visible = enabled

    --// AutoPlay
    local autoplay =
        self:GetSetting(
            "gakuran_autoplay",
            false
        )

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

    --// ESP
    local esp =
        self:GetSetting(
            "gakuran_esp",
            true
        )

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

    --// Health
    local health =
        self:GetSetting(
            "gakuran_health",
            true
        )

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

    print("[UI] Creating interface...")

    local success, result =
        pcall(function()

            return self:CreateInterface()

        end)

    if not success then

        warn(
            "[UI] Interface error:"
            .. tostring(result)
        )

        return

    end

    if not result then

        warn(
            "[UI] Interface creation FAILED."
        )

        return

    end

    self.State.Running = true

    print(
        "[UI] Interface creation SUCCESS."
    )

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

    local matchaUI = self.MatchaUI

    if matchaUI
        and type(matchaUI.RemoveTab) == "function" then

        pcall(function()

            matchaUI.RemoveTab(
                "Gakuran"
            )

        end)

    end

    self.MatchaUI = nil

    print("[UI] Stopped.")

end

--// =========================================================
--// MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult = UI

return UI
