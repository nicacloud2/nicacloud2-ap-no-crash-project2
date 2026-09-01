--// Gakuran Modular Project
--// Main.lua

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- MODULES
--==================================================

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)
local AnimationTracker = require(script.Parent.AnimationTracker)
local TargetManager = require(script.Parent.TargetManager)
local ParryController = require(script.Parent.ParryController)
local ESP = require(script.Parent.ESP)
local HealthOverlay = require(script.Parent.HealthOverlay)
local AutoPlay = require(script.Parent.AutoPlay)
local Logger = require(script.Parent.Logger)
local UI = require(script.Parent.UI)

--==================================================
-- SHARED STATE
--==================================================

local State = {
    Running = false,

    LocalPlayer = LocalPlayer,

    CurrentTarget = nil,

    Connections = {},

    Debug = false,
}

--==================================================
-- DEBUG
--==================================================

local function DebugPrint(...)

    if State.Debug then
        print("[Gakuran Debug]", ...)
    end

end

--==================================================
-- INITIALIZE
--==================================================

local function InitializeModules()

    DebugPrint("Initializing modules...")

    Config:Initialize(State)

    AnimationTracker:Initialize(State)

    TargetManager:Initialize(State)

    ParryController:Initialize(State)

    ESP:Initialize(State)

    HealthOverlay:Initialize(State)

    AutoPlay:Initialize(State)

    Logger:Initialize(State)

    UI:Initialize(State)

    DebugPrint("Modules initialized.")

end

--==================================================
-- TARGET
--==================================================

local function UpdateTarget()

    local target =
        TargetManager:GetCurrentTarget()

    State.CurrentTarget = target

end

--==================================================
-- INPUT
--==================================================

local function SetupInput()

    local connection

    connection = UserInputService.InputBegan:Connect(
        function(input, gameProcessed)

            if gameProcessed then
                return
            end

            --======================================
            -- DODGE
            --======================================

            if input.KeyCode == Enum.KeyCode.X then

                if Config.Parry.Enabled then
                    ParryController:Dodge()
                end

            end

            --======================================
            -- MANUAL BLOCK
            --======================================

            if input.KeyCode == Enum.KeyCode.F then

                if Config.Parry.Enabled then
                    ParryController:BlockStart()
                end

            end

            --======================================
            -- TARGET CYCLE
            --======================================

            if input.KeyCode == Enum.KeyCode.Tab then

                if Config.Targeting.CycleTargets then

                    TargetManager:CycleTarget()

                    UpdateTarget()

                end

            end

        end
    )

    table.insert(
        State.Connections,
        connection
    )

    --==============================================
    -- BLOCK RELEASE
    --==============================================

    local releaseConnection

    releaseConnection =
        UserInputService.InputEnded:Connect(
            function(input)

                if input.KeyCode == Enum.KeyCode.F then

                    ParryController:BlockEnd()

                end

            end
        )

    table.insert(
        State.Connections,
        releaseConnection
    )

end

--==================================================
-- CHARACTER EVENTS
--==================================================

local function SetupCharacterEvents()

    local connection

    connection =
        LocalPlayer.CharacterAdded:Connect(
            function(character)

                DebugPrint(
                    "Local character loaded:",
                    character.Name
                )

                task.wait(0.5)

                AnimationTracker:RefreshLocalPlayer()

                TargetManager:Refresh()

            end
        )

    table.insert(
        State.Connections,
        connection
    )

end

--==================================================
-- MAIN LOOP
--==================================================

local function StartLoop()

    local connection

    connection =
        RunService.Heartbeat:Connect(
            function()

                if not State.Running then
                    return
                end

                UpdateTarget()

            end
        )

    table.insert(
        State.Connections,
        connection
    )

end

--==================================================
-- START MODULES
--==================================================

local function StartModules()

    DebugPrint("Starting modules...")

    -- Target system
    TargetManager:Start()

    -- Animation tracking
    AnimationTracker:TrackLocalPlayer()
    AnimationTracker:TrackCharacters()

    -- Parry
    ParryController:Start()

    -- Logger
    Logger:ConnectAnimationTracker()

    -- ESP
    ESP:Start()

    -- Health
    HealthOverlay:Start()

    -- AutoPlay
    AutoPlay:Start()

    -- UI
    UI:Start()

    DebugPrint("Modules started.")

end

--==================================================
-- STOP MODULES
--==================================================

local function StopModules()

    DebugPrint("Stopping modules...")

    -- Stop parry first
    ParryController:Stop()

    -- Stop animation tracking
    AnimationTracker:StopAll()

    -- Stop targeting
    TargetManager:Stop()

    -- Stop ESP
    ESP:Stop()

    -- Stop health overlay
    HealthOverlay:Stop()

    -- Stop AutoPlay
    AutoPlay:Stop()

    -- Disconnect Logger
    Logger:DisconnectAnimationTracker()

    DebugPrint("Modules stopped.")

end

--==================================================
-- CLEANUP
--==================================================

local function Cleanup()

    if not State.Running then
        return
    end

    DebugPrint("Cleaning up...")

    State.Running = false

    -- Disconnect Main connections
    for _, connection in ipairs(
        State.Connections
    ) do

        if connection then

            pcall(function()
                connection:Disconnect()
            end)

        end

    end

    table.clear(
        State.Connections
    )

    StopModules()

    State.CurrentTarget = nil

    DebugPrint("Cleanup complete.")

end

--==================================================
-- START
--==================================================

local function Start()

    if State.Running then
        warn("[Gakuran] Already running.")
        return
    end

    print("======================================")
    print("       GAKURAN MODULAR PROJECT")
    print("======================================")

    State.Running = true

    local success, err = pcall(function()

        InitializeModules()

        StartModules()

        SetupInput()

        SetupCharacterEvents()

        StartLoop()

    end)

    if not success then

        warn(
            "[Gakuran] Startup error:",
            err
        )

        Cleanup()

        return

    end

    print("[Gakuran] Successfully started.")

end

--==================================================
-- START PROJECT
--==================================================

Start()
