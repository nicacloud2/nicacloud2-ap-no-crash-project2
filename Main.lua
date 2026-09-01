--// Gakuran Script - Main
--// Entry point

--==================================================
-- Services
--==================================================

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- Modules
--==================================================

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)
local AnimationTracker = require(script.Parent.AnimationTracker)
local ParryController = require(script.Parent.ParryController)
local TargetManager = require(script.Parent.TargetManager)
local ESP = require(script.Parent.ESP)
local HealthOverlay = require(script.Parent.HealthOverlay)
local AutoPlay = require(script.Parent.AutoPlay)
local Logger = require(script.Parent.Logger)
local UI = require(script.Parent.UI)

--==================================================
-- Shared State
--==================================================

local State = {
    Alive = true,

    Connections = {},
    Drawings = {},

    TargetCharacters = {},
    EspTrackers = {},

    AnimationRegistry = {},
    AnimationIdSliders = {},

    AnimationsLoggedCache = {},
    AnimationsLoggedOrder = {},

    HeldKeys = {},

    CurrentTargetIndex = 1,

    CurrentParryState = "idle",

    LastPendingRegData = nil,

    InputRegisteredTime = nil,
    ParryRegisteredTime = nil,

    LastOverlayUpdate = 0,
    LastCycleCheck = 0,
}

--==================================================
-- Initialization
--==================================================

local function Initialize()
    Logger:Info("Starting Gakuran Script...")

    -- Load configuration
    Config:Initialize(State)

    -- Load animation database
    AnimationDatabase:Initialize(State)

    -- Start animation tracking
    AnimationTracker:Initialize(State, Config)

    -- Start target management
    TargetManager:Initialize(State, Config)

    -- Start ESP
    ESP:Initialize(State, Config)

    -- Start health overlay
    HealthOverlay:Initialize(State, Config)

    -- Start parry system
    ParryController:Initialize(
        State,
        Config,
        AnimationTracker,
        TargetManager
    )

    -- Start autoplay
    AutoPlay:Initialize(State, Config)

    -- Start UI
    UI:Initialize(
        State,
        Config,
        TargetManager,
        ParryController,
        AutoPlay
    )

    Logger:Info("Gakuran Script loaded successfully.")
end

--==================================================
-- Cleanup
--==================================================

local function Cleanup()
    if not State.Alive then
        return
    end

    State.Alive = false

    Logger:Info("Cleaning up...")

    for _, connection in pairs(State.Connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    table.clear(State.Connections)

    if ESP.Destroy then
        ESP:Destroy(State)
    end

    if HealthOverlay.Destroy then
        HealthOverlay:Destroy(State)
    end

    if AnimationTracker.Destroy then
        AnimationTracker:Destroy(State)
    end

    if ParryController.Destroy then
        ParryController:Destroy(State)
    end

    if AutoPlay.Destroy then
        AutoPlay:Destroy(State)
    end

    if UI.Destroy then
        UI:Destroy(State)
    end

    Logger:Info("Cleanup complete.")
end

--==================================================
-- Player Lifecycle
--==================================================

LocalPlayer.CharacterRemoving:Connect(function()
    State.Alive = false
end)

--==================================================
-- Start
--==================================================

local success, err = pcall(Initialize)

if not success then
    warn("[Gakuran] Initialization failed:", err)
    Cleanup()
end
