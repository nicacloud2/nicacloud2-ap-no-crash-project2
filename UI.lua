--// =========================================================
--// GAKURAN - UI
--// GitHub / Matcha Version
--// MATCHA NATIVE UI
--// CALLBACK + POLLING SAFE EDITION
--// =========================================================

local UI = {}

--// =========================================================
--// DEPENDENCIES
--// =========================================================

local Config = nil
local TargetManager = nil
local ParryController = nil
local ESP = nil
local HealthOverlay = nil
local AutoPlay = nil
local Logger = nil


--// =========================================================
--// STATE
--// =========================================================

UI.State = {
    Running = false,
    Visible = true
}

UI.PollInterval = 0.1
UI.MatchaUI = nil

UI.LastEnabled = nil
UI.LastAutoPlay = nil
UI.LastESP = nil
UI.LastHealth = nil

--// Prevent initial UI creation from immediately
--// changing module states before the UI is ready.
UI.SettingsReady = false


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
            and type(candidate) == "table"
        then

            if type(candidate.AddTab) == "function" then

                print("[UI] Matcha UI API found.")

                return candidate
            end
        end
    end

    warn(
        "[UI] Matcha UI API was not found."
    )

    return nil
end


--// =========================================================
--// APPLY AUTOPLAY
--// =========================================================

function UI:SetAutoPlay(enabled)

    if not AutoPlay then
        return
    end

    enabled =
        enabled == true

    pcall(function()

        if type(AutoPlay.SetEnabled) == "function" then

            AutoPlay:SetEnabled(
                enabled
            )

        end

    end)

    pcall(function()

        if enabled then

            if type(AutoPlay.Start) == "function"
                and AutoPlay.State
                and not AutoPlay.State.Running
            then

                AutoPlay:Start()

            end

        else

            if type(AutoPlay.Stop) == "function"
                and AutoPlay.State
                and AutoPlay.State.Running
            then

                AutoPlay:Stop()

            end

        end

    end)
end


--// =========================================================
--// APPLY ESP
--// =========================================================

function UI:SetESP(enabled)

    if not ESP then
        return
    end

    enabled =
        enabled == true

    pcall(function()

        if enabled then

            if type(ESP.Start) == "function"
                and ESP.State
                and not ESP.State.Running
            then

                ESP:Start()

            end

        else

            if type(ESP.Stop) == "function"
                and ESP.State
                and ESP.State.Running
            then

                ESP:Stop()

            end

        end

    end)
end


--// =========================================================
--// APPLY HEALTH OVERLAY
--// =========================================================

function UI:SetHealthOverlay(enabled)

    if not HealthOverlay then
        return
    end

    enabled =
        enabled == true

    pcall(function()

        if enabled then

            if type(HealthOverlay.Start) == "function"
                and HealthOverlay.State
                and not HealthOverlay.State.Running
            then

                HealthOverlay:Start()

            end

        else

            if type(HealthOverlay.Stop) == "function"
                and HealthOverlay.State
                and HealthOverlay.State.Running
            then

                HealthOverlay:Stop()

            end

        end

    end)
end


--// =========================================================
--// CREATE INTERFACE
--// =========================================================

function UI:CreateInterface()

    local matchaUI =
        self:FindMatchaUI()

    if not matchaUI then

        warn(
            "[UI] Cannot create interface: " ..
            "Matcha UI Binding unavailable."
        )

        return false
    end

    self.MatchaUI =
        matchaUI

    print(
        "[UI] Creating Gakuran tab..."
    )


    local success, result =
        pcall(function()

            return matchaUI.AddTab(
                "Gakuran",
                function(tab)

                    --// =================================================
                    --// STATUS
                    --// =================================================

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


                    --// =================================================
                    --// CONTROLS
                    --// =================================================

                    local controls =
                        tab:Section(
                            "Controls",
                            "Left"
                        )

                    controls:Toggle(
                        "gakuran_enabled",
                        "Enabled",
                        function(value)

                            print(
                                "[UI] Enabled changed:",
                                value
                            )

                            self.State.Visible =
                                value == true

                            if not value then

                                self:SetAutoPlay(false)
                                self:SetESP(false)
                                self:SetHealthOverlay(false)

                            else

                                self:SetESP(true)
                                self:SetHealthOverlay(true)

                            end

                        end
                    )


                    --// =================================================
                    --// FEATURES
                    --// =================================================

                    local features =
                        tab:Section(
                            "Features",
                            "Right"
                        )


                    features:Toggle(
                        "gakuran_autoplay",
                        "AutoPlay",
                        function(value)

                            print(
                                "[UI] AutoPlay changed:",
                                value
                            )

                            if self.State.Visible then

                                self:SetAutoPlay(
                                    value == true
                                )

                            end

                        end
                    )


                    features:Toggle(
                        "gakuran_esp",
                        "ESP",
                        function(value)

                            print(
                                "[UI] ESP changed:",
                                value
                            )

                            if self.State.Visible then

                                self:SetESP(
                                    value == true
                                )

                            end

                        end
                    )


                    features:Toggle(
                        "gakuran_health",
                        "Health Overlay",
                        function(value)

                            print(
                                "[UI] Health Overlay changed:",
                                value
                            )

                            if self.State.Visible then

                                self:SetHealthOverlay(
                                    value == true
                                )

                            end

                        end
                    )


                    --// =================================================
                    --// INFORMATION
                    --// =================================================

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
            "[UI] Matcha UI creation failed: " ..
            tostring(result)
        )

        self.MatchaUI = nil

        return false
    end


    print(
        "[UI] Gakuran tab created."
    )

    return true
end


--// =========================================================
--// GET VALUE
--// =========================================================

function UI:GetSetting(
    id,
    default
)

    local matchaUI =
        self.MatchaUI

    if not matchaUI then
        return default
    end

    if type(matchaUI.GetValue)
        ~= "function"
    then

        return default
    end


    local success, value =
        pcall(function()

            return matchaUI.GetValue(id)

        end)


    if success
        and value ~= nil
    then

        return value
    end


    return default
end


--// =========================================================
--// POLLING FALLBACK
--// =========================================================

function UI:Update()

    if not self.State.Running then
        return
    end


    --// ---------------------------------------------------------
    --// Do not poll during the initial UI creation frame.
    --// This prevents GetValue() fallback values from overriding
    --// the module states immediately after startup.
    --// ---------------------------------------------------------

    if not self.SettingsReady then
        return
    end


    --// =========================================================
    --// MASTER ENABLE
    --// =========================================================

    local enabled =
        self:GetSetting(
            "gakuran_enabled",
            true
        )

    enabled =
        enabled == true

    self.State.Visible =
        enabled


    if self.LastEnabled ~= enabled then

        print(
            "[UI] System Enabled:",
            enabled
        )

        self.LastEnabled =
            enabled
    end


    --// =========================================================
    --// AUTOPLAY
    --// =========================================================

    local autoplay =
        self:GetSetting(
            "gakuran_autoplay",
            false
        )

    autoplay =
        autoplay == true


    if not enabled then
        autoplay = false
    end


    if self.LastAutoPlay ~= autoplay then

        print(
            "[UI] AutoPlay:",
            autoplay
        )

        self.LastAutoPlay =
            autoplay

        self:SetAutoPlay(
            autoplay
        )
    end


    --// =========================================================
    --// ESP
    --// =========================================================

    local esp =
        self:GetSetting(
            "gakuran_esp",
            true
        )

    esp =
        esp == true


    if not enabled then
        esp = false
    end


    if self.LastESP ~= esp then

        print(
            "[UI] ESP:",
            esp
        )

        self.LastESP =
            esp

        self:SetESP(
            esp
        )
    end


    --// =========================================================
    --// HEALTH
    --// =========================================================

    local health =
        self:GetSetting(
            "gakuran_health",
            true
        )

    health =
        health == true


    if not enabled then
        health = false
    end


    if self.LastHealth ~= health then

        print(
            "[UI] Health Overlay:",
            health
        )

        self.LastHealth =
            health

        self:SetHealthOverlay(
            health
        )
    end
end


--// =========================================================
--// START
--// =========================================================

function UI:Start()

    if self.State.Running then

        print(
            "[UI] Already running."
        )

        return
    end


    print(
        "[UI] Creating interface..."
    )


    local success, result =
        pcall(function()

            return self:CreateInterface()

        end)


    if not success then

        warn(
            "[UI] Interface error: " ..
            tostring(result)
        )

        return
    end


    if not result then

        warn(
            "[UI] Interface creation FAILED."
        )

        return
    end


    self.State.Running =
        true


    print(
        "[UI] Interface creation SUCCESS."
    )

    print(
        "[UI] Waiting for Matcha toggle states..."
    )


  --// Enable polling immediately.
  --// Avoid task.wait() during UI startup.

    self.SettingsReady =
        true


    print(
        "[UI] Toggle state polling enabled."
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


    print(
        "[UI] Started."
    )
end


--// =========================================================
--// STOP
--// =========================================================

function UI:Stop()

    if not self.State.Running then
        return
    end


    self.State.Running =
        false

    self.SettingsReady =
        false


    --// ---------------------------------------------------------
    --// Stop managed modules
    --// ---------------------------------------------------------

    if AutoPlay then

        pcall(function()

            if type(AutoPlay.SetEnabled) == "function" then

                AutoPlay:SetEnabled(
                    false
                )

            end

            if type(AutoPlay.Stop) == "function" then

                AutoPlay:Stop()

            end

        end)

    end


    if ESP then

        pcall(function()

            if type(ESP.Stop) == "function" then

                ESP:Stop()

            end

        end)

    end


    if HealthOverlay then

        pcall(function()

            if type(HealthOverlay.Stop) == "function" then

                HealthOverlay:Stop()

            end

        end)

    end


    --// ---------------------------------------------------------
    --// Remove Matcha tab
    --// ---------------------------------------------------------

    local matchaUI =
        self.MatchaUI


    if matchaUI
        and type(matchaUI.RemoveTab)
            == "function"
    then

        pcall(function()

            matchaUI.RemoveTab(
                "Gakuran"
            )

        end)

    end


    self.MatchaUI =
        nil


    print(
        "[UI] Stopped."
    )
end


--// =========================================================
--// MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult =
    UI

return UI
