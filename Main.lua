--// =========================================================
--// GAKURAN - MAIN LOADER
--// GitHub / Matcha Version
--// =========================================================

local BASE_URL = "https://raw.githubusercontent.com/nicacloud2/nicacloud2-ap-no-crash-project2/main/"

--// =========================================================
--// MODULE LOADER
--// =========================================================

local Modules = {}

local function LoadModule(moduleName)
    if Modules[moduleName] then
        return Modules[moduleName]
    end

    local url = BASE_URL .. moduleName .. ".lua"

    local success, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        error("[Main] Failed to download " .. moduleName .. "\n" .. tostring(source))
    end

    -- Detect GitHub 404 / error pages
    if source:match("^404") or source:match("404: Not Found") then
        error("[Main] 404 - File not found: " .. moduleName .. ".lua")
    end

    local compileSuccess, moduleFunction = pcall(function()
        return loadstring(source, "@" .. moduleName .. ".lua")
    end)

    if not compileSuccess or not moduleFunction then
        error(
            "[Main] Failed to compile " ..
            moduleName ..
            ".lua\n" ..
            tostring(moduleFunction)
        )
    end

    local runSuccess, result = pcall(moduleFunction)

    if not runSuccess then
        error(
            "[Main] Failed to run " ..
            moduleName ..
            ".lua\n" ..
            tostring(result)
        )
    end

    Modules[moduleName] = result

    print("[Main] Loaded: " .. moduleName)

    return result
end


--// =========================================================
--// LOAD MODULES
--// =========================================================

print("========================================")
print("       GAKURAN SYSTEM STARTING")
print("========================================")

local Config = LoadModule("Config")
local AnimationDatabase = LoadModule("AnimationDatabase")
local AnimationTracker = LoadModule("AnimationTracker")
local TargetManager = LoadModule("TargetManager")
local ParryController = LoadModule("ParryController")
local ESP = LoadModule("ESP")
local HealthOverlay = LoadModule("HealthOverlay")
local AutoPlay = LoadModule("AutoPlay")
local Logger = LoadModule("Logger")
local UI = LoadModule("UI")


--// =========================================================
--// GLOBAL STATE
--// =========================================================

local State = {
    Running = false,

    LocalPlayer = game:GetService("Players").LocalPlayer,

    CurrentTarget = nil,

    Connections = {},

    Debug = false
}


--// =========================================================
--// INITIALIZE MODULES
--// =========================================================

local function InitializeModules()

    print("[Main] Initializing modules...")

    local modules = {
        Config,
        AnimationDatabase,
        AnimationTracker,
        TargetManager,
        ParryController,
        ESP,
        HealthOverlay,
        AutoPlay,
        Logger,
        UI
    }

    for _, module in ipairs(modules) do

        if type(module) == "table" and module.Initialize then

            local success, err = pcall(function()
                module:Initialize(State)
            end)

            if not success then
                warn("[Main] Initialize error:", err)
            end

        end

    end

    print("[Main] Modules initialized.")
end


--// =========================================================
--// TARGET UPDATE
--// =========================================================

local function UpdateTarget()

    if not TargetManager then
        return
    end

    if not TargetManager.GetCurrentTarget then
        return
    end

    local success, target = pcall(function()
        return TargetManager:GetCurrentTarget()
    end)

    if success then
        State.CurrentTarget = target
    end
end


--// =========================================================
--// INPUT
--// =========================================================

local UserInputService = game:GetService("UserInputService")

local function SetupInput()

    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if gameProcessed then
            return
        end

        if not State.Running then
            return
        end


        --// DODGE
        if input.KeyCode == Enum.KeyCode.X then

            if ParryController and ParryController.Dodge then

                pcall(function()
                    ParryController:Dodge()
                end)

            end

        end


        --// BLOCK
        if input.KeyCode == Enum.KeyCode.F then

            if ParryController and ParryController.BlockStart then

                pcall(function()
                    ParryController:BlockStart(os.clock(), 0.27)
                end)

            end

        end


        --// TARGET CYCLE
        if input.KeyCode == Enum.KeyCode.Tab then

            if Config.Targeting
                and Config.Targeting.CycleTargets
                and TargetManager
                and TargetManager.CycleTarget then

                pcall(function()
                    TargetManager:CycleTarget()
                end)

            end

        end

    end)


    table.insert(State.Connections, connection)


    --// INPUT ENDED

    local endConnection = UserInputService.InputEnded:Connect(function(input)

        if not State.Running then
            return
        end

        if input.KeyCode == Enum.KeyCode.F then

            if ParryController and ParryController.BlockEnd then

                pcall(function()
                    ParryController:BlockEnd()
                end)

            end

        end

    end)


    table.insert(State.Connections, endConnection)

end


--// =========================================================
--// CHARACTER EVENTS
--// =========================================================

local Players = game:GetService("Players")

local function SetupCharacterEvents()

    local connection = Players.PlayerAdded:Connect(function(player)

        if AnimationTracker and AnimationTracker.TrackCharacter then

            task.wait(1)

            pcall(function()
                AnimationTracker:TrackCharacter(player.Character)
            end)

        end

    end)

    table.insert(State.Connections, connection)

end


--// =========================================================
--// MAIN LOOP
--// =========================================================

local RunService = game:GetService("RunService")

local function StartLoop()

    local connection = RunService.Heartbeat:Connect(function()

        if not State.Running then
            return
        end

        UpdateTarget()

    end)

    table.insert(State.Connections, connection)

end


--// =========================================================
--// START MODULES
--// =========================================================

local function StartModules()

    print("[Main] Starting modules...")

    local startList = {
        {"TargetManager", TargetManager},
        {"AnimationTracker", AnimationTracker},
        {"ParryController", ParryController},
        {"Logger", Logger},
        {"ESP", ESP},
        {"HealthOverlay", HealthOverlay},
        {"AutoPlay", AutoPlay},
        {"UI", UI}
    }


    for _, info in ipairs(startList) do

        local name = info[1]
        local module = info[2]

        if type(module) == "table" and module.Start then

            local success, err = pcall(function()
                module:Start()
            end)

            if success then
                print("[Main] Started: " .. name)
            else
                warn("[Main] Failed to start " .. name .. ":", err)
            end

        end

    end

end


--// =========================================================
--// STOP MODULES
--// =========================================================

local function StopModules()

    print("[Main] Stopping modules...")

    local stopList = {
        UI,
        AutoPlay,
        HealthOverlay,
        ESP,
        Logger,
        ParryController,
        AnimationTracker,
        TargetManager
    }


    for _, module in ipairs(stopList) do

        if type(module) == "table" and module.Stop then

            pcall(function()
                module:Stop()
            end)

        end

    end

end


--// =========================================================
--// CLEANUP
--// =========================================================

local function Cleanup()

    for _, connection in ipairs(State.Connections) do

        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end

    end

    table.clear(State.Connections)

end


--// =========================================================
--// START
--// =========================================================

local function Start()

    if State.Running then
        warn("[Main] Already running.")
        return
    end

    State.Running = true


    local success, err = pcall(function()

        InitializeModules()

        SetupInput()

        SetupCharacterEvents()

        StartModules()

        StartLoop()

    end)


    if not success then

        State.Running = false

        Cleanup()

        warn("========================================")
        warn("[Main] STARTUP FAILED")
        warn("========================================")
        warn(err)

        return

    end


    print("========================================")
    print("       GAKURAN SYSTEM STARTED")
    print("========================================")

end


--// =========================================================
--// STOP
--// =========================================================

local function Stop()

    if not State.Running then
        return
    end

    State.Running = false

    StopModules()

    Cleanup()

    print("[Main] System stopped.")

end


--// =========================================================
--// GLOBAL CONTROLS
--// =========================================================

_G.Gakuran = {
    Start = Start,
    Stop = Stop,

    State = State,

    Modules = Modules,

    Config = Config,
    AnimationDatabase = AnimationDatabase,
    AnimationTracker = AnimationTracker,
    TargetManager = TargetManager,
    ParryController = ParryController,
    ESP = ESP,
    HealthOverlay = HealthOverlay,
    AutoPlay = AutoPlay,
    Logger = Logger,
    UI = UI
}


--// =========================================================
--// START
--// =========================================================

Start()
