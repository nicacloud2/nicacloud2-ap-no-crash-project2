--// Gakuran Modular Project
--// Main.lua

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
-- INITIALIZE MODULES
--==================================================

local function InitializeModules()

    Config:Initialize(State)

    AnimationTracker:Initialize(State)
    TargetManager:Initialize(State)

    ParryController:Initialize(State)

    ESP:Initialize(State)
    HealthOverlay:Initialize(State)

    AutoPlay:Initialize(State)
    Logger:Initialize(State)

    UI:Initialize(State)

end

--==================================================
-- START MODULES
--==================================================

local function StartModules()

    TargetManager:Start()

    AnimationTracker:TrackLocalPlayer()
    AnimationTracker:TrackCharacters()

    ParryController:Start()

    ESP:Start()
    HealthOverlay:Start()

    AutoPlay:Start()

    UI:Start()

end

--==================================================
-- STOP MODULES
--==================================================

local function StopModules()

    ParryController:Stop()

    AnimationTracker:StopAll()

    TargetManager:Stop()

    ESP:Stop()
    HealthOverlay:Stop()

    AutoPlay:Stop()

end

--==================================================
-- TARGET UPDATE
--==================================================

local function UpdateTarget()

    local target = TargetManager:GetCurrentTarget()

    State.CurrentTarget = target

end

--==================================================
-- INPUT
--==================================================

local function SetupInput()

    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.X then
            ParryController:Dodge()
        end

        if input.KeyCode == Enum.KeyCode.F then
            ParryController:BlockStart()
        end

    end)

    table.insert(State.Connections, connection)

end

--==================================================
-- MAIN LOOP
--==================================================

local function StartLoop()

    local connection = RunService.Heartbeat:Connect(function()

        if not State.Running then
            return
        end

        UpdateTarget()

    end)

    table.insert(State.Connections, connection)

end

--==================================================
-- CLEANUP
--==================================================

local function Cleanup()

    State.Running = false

    for _, connection in ipairs(State.Connections) do

        if connection then
            connection:Disconnect()
        end

    end

    table.clear(State.Connections)

    StopModules()

end

--==================================================
-- STARTUP
--==================================================

local function Start()

    if State.Running then
        return
    end

    State.Running = true

    InitializeModules()
    StartModules()
    SetupInput()
    StartLoop()

    print("[Gakuran] Main.lua started successfully.")

end

--==================================================
-- RUN
--==================================================

Start()
