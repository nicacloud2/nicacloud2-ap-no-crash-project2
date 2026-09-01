--// =========================================================
--// GAKURAN - MAIN LOADER
--// GitHub / Matcha Version
--// =========================================================

local BASE_URL =
    "https://raw.githubusercontent.com/nicacloud2/nicacloud2-ap-no-crash-project2/main/"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Modules = {}

local State = {
    Running = false,
    LocalPlayer = Players.LocalPlayer,
    CurrentTarget = nil,
    Connections = {},
    Debug = false
}


--// =========================================================
--// SAFE MODULE LOADER
--// =========================================================

local function LoadModule(moduleName)

    -- Already loaded
    if Modules[moduleName] ~= nil then
        return Modules[moduleName]
    end

    local url =
        BASE_URL .. moduleName .. ".lua"

    print("")
    print("----------------------------------------")
    print("[Main] Downloading:", moduleName)
    print("[Main] URL:", url)

    --// -----------------------------------------------------
    --// DOWNLOAD
    --// -----------------------------------------------------

    local success, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then

        error(
            "[Main] Failed to download "
            .. moduleName
            .. ".lua\n"
            .. tostring(source)
        )

    end

    --// -----------------------------------------------------
    --// RESPONSE VALIDATION
    --// -----------------------------------------------------

    if type(source) ~= "string" then

        error(
            "[Main] Invalid HTTP response for "
            .. moduleName
            .. ".lua\n"
            .. "Type: "
            .. type(source)
        )

    end

    print(
        "[Main] Source length:",
        #source
    )

    -- Show beginning of downloaded file
    print(
        "[Main] Source preview:",
        source:sub(1, 120)
    )

    --// -----------------------------------------------------
    --// GITHUB ERROR DETECTION
    --// -----------------------------------------------------

    local trimmedSource =
        source:gsub("^%s+", "")

    if trimmedSource:match("^404")
        or trimmedSource:match("^404:%s*Not Found")
        or trimmedSource:match("404: Not Found") then

        error(
            "[Main] GitHub returned 404 for "
            .. moduleName
            .. ".lua\n"
            .. url
        )

    end

    if trimmedSource:match("^<!DOCTYPE")
        or trimmedSource:match("^<html") then

        error(
            "[Main] GitHub returned HTML instead of Lua for "
            .. moduleName
            .. ".lua\n"
            .. "Check the repository/file URL."
        )

    end

    --// -----------------------------------------------------
    --// COMPILE
    --// -----------------------------------------------------

    print(
        "[Main] Compiling:",
        moduleName
    )

    local compileSuccess, moduleFunction =
        pcall(function()

            return loadstring(
                source,
                "@" .. moduleName .. ".lua"
            )

        end)

    if not compileSuccess then

        error(
            "[Main] Compile error in "
            .. moduleName
            .. ".lua\n"
            .. tostring(moduleFunction)
        )

    end

    if type(moduleFunction) ~= "function" then

        error(
            "[Main] loadstring did not return a function for "
            .. moduleName
            .. ".lua\n"
            .. "Returned type: "
            .. type(moduleFunction)
        )

    end

    print(
        "[Main] Compilation successful:",
        moduleName
    )

    --// -----------------------------------------------------
    --// EXECUTE
    --// -----------------------------------------------------

    print(
        "[Main] Executing:",
        moduleName
    )

    local runSuccess, result =
        pcall(function()

            return moduleFunction()

        end)

    if not runSuccess then

        error(
            "[Main] Runtime error in "
            .. moduleName
            .. ".lua\n"
            .. tostring(result)
        )

    end

    --// -----------------------------------------------------
    --// RETURN VALIDATION
    --// -----------------------------------------------------

    print(
        "[Main] Return type:",
        type(result)
    )

    if result == nil then

        error(
            "[Main] "
            .. moduleName
            .. ".lua returned NIL.\n"
            .. "Make sure the file ends with:\n"
            .. "return "
            .. moduleName
        )

    end

    if type(result) ~= "table" then

        warn(
            "[Main] Warning:",
            moduleName,
            "returned",
            type(result),
            "instead of table."
        )

    end

    Modules[moduleName] = result

    print(
        "[Main] Loaded successfully:",
        moduleName
    )

    print("----------------------------------------")

    return result
end


--// =========================================================
--// STARTUP
--// =========================================================

print("========================================")
print("          GAKURAN SYSTEM")
print("========================================")
print("[Main] Loading modules...")
print("")


--// =========================================================
--// CONFIG
--// =========================================================

local Config =
    LoadModule("Config")

print(
    "[Main] Config check:",
    type(Config)
)


--// =========================================================
--// ANIMATION DATABASE
--// =========================================================

local AnimationDatabase =
    LoadModule("AnimationDatabase")

print(
    "[Main] AnimationDatabase check:",
    type(AnimationDatabase)
)

AnimationDatabase:SetConfig(
    Config
)

AnimationDatabase:Build()

print(
    "[Main] AnimationDatabase animations:",
    AnimationDatabase:GetCount()
)


--// =========================================================
--// ANIMATION TRACKER
--// =========================================================

local AnimationTracker =
    LoadModule("AnimationTracker")

AnimationTracker:SetDependencies(
    Config,
    AnimationDatabase
)


--// =========================================================
--// TARGET MANAGER
--// =========================================================

local TargetManager =
    LoadModule("TargetManager")

TargetManager:SetConfig(
    Config
)


--// =========================================================
--// PARRY CONTROLLER
--// =========================================================

local ParryController =
    LoadModule("ParryController")

ParryController:SetDependencies(
    Config,
    AnimationDatabase,
    AnimationTracker,
    TargetManager
)


--// =========================================================
--// LOGGER
--// =========================================================

local Logger =
    LoadModule("Logger")

Logger:SetDependencies(
    Config,
    AnimationDatabase,
    AnimationTracker
)


--// =========================================================
--// ESP
--// =========================================================

local ESP =
    LoadModule("ESP")

ESP:SetDependencies(
    Config,
    TargetManager
)


--// =========================================================
--// HEALTH OVERLAY
--// =========================================================

local HealthOverlay =
    LoadModule("HealthOverlay")

HealthOverlay:SetDependencies(
    Config,
    TargetManager
)


--// =========================================================
--// AUTOPLAY
--// =========================================================

local AutoPlay =
    LoadModule("AutoPlay")

AutoPlay:SetDependencies(
    Config,
    TargetManager,
    ParryController
)


--// =========================================================
--// UI
--// =========================================================

local UI =
    LoadModule("UI")

UI:SetDependencies(
    Config,
    TargetManager,
    ParryController,
    ESP,
    HealthOverlay,
    AutoPlay,
    Logger
)


print("")
print("[Main] All modules loaded successfully.")


--// =========================================================
--// INITIALIZE
--// =========================================================

local function InitializeModules()

    print("[Main] Initializing modules...")

    local modules = {

        Config,
        AnimationDatabase,
        AnimationTracker,
        TargetManager,
        ParryController,
        Logger,
        ESP,
        HealthOverlay,
        AutoPlay,
        UI

    }

    for _, module in ipairs(modules) do

        if type(module) == "table"
            and type(module.Initialize) == "function" then

            local success, err =
                pcall(function()

                    module:Initialize(
                        State
                    )

                end)

            if not success then

                warn(
                    "[Main] Initialize error:",
                    err
                )

            end

        end

    end

    print(
        "[Main] Initialization complete."
    )

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

    local success, target =
        pcall(function()

            return TargetManager:
                GetCurrentTarget()

        end)

    if success then

        State.CurrentTarget =
            target

    end

end


--// =========================================================
--// INPUT
--// =========================================================

local function SetupInput()

    local inputConnection =
        UserInputService.InputBegan:Connect(
            function(input, gameProcessed)

                if gameProcessed then
                    return
                end

                if not State.Running then
                    return
                end

                --// X = Dodge

                if input.KeyCode ==
                    Enum.KeyCode.X then

                    if ParryController
                        and ParryController.Dodge then

                        pcall(function()

                            ParryController:
                                Dodge()

                        end)

                    end

                end

                --// F = Block

                if input.KeyCode ==
                    Enum.KeyCode.F then

                    if ParryController
                        and ParryController.BlockStart then

                        pcall(function()

                            ParryController:
                                BlockStart(
                                    os.clock(),
                                    Config.BlockHoldTime
                                )

                        end)

                    end

                end

                --// TAB = Cycle Target

                if input.KeyCode ==
                    Enum.KeyCode.Tab then

                    if TargetManager
                        and TargetManager.CycleTarget then

                        pcall(function()

                            TargetManager:
                                CycleTarget()

                        end)

                    end

                end

            end
        )

    table.insert(
        State.Connections,
        inputConnection
    )


    local releaseConnection =
        UserInputService.InputEnded:Connect(
            function(input)

                if not State.Running then
                    return
                end

                if input.KeyCode ==
                    Enum.KeyCode.F then

                    if ParryController
                        and ParryController.BlockEnd then

                        pcall(function()

                            ParryController:
                                BlockEnd()

                        end)

                    end

                end

            end
        )

    table.insert(
        State.Connections,
        releaseConnection
    )

end


--// =========================================================
--// CHARACTER EVENTS
--// =========================================================

local function SetupCharacterEvents()

    local playerAddedConnection =
        Players.PlayerAdded:Connect(
            function(player)

                task.wait(1)

                if not State.Running then
                    return
                end

                if AnimationTracker
                    and AnimationTracker.TrackCharacter then

                    pcall(function()

                        if player.Character then

                            AnimationTracker:
                                TrackCharacter(
                                    player.Character
                                )

                        end

                    end)

                end

            end
        )

    table.insert(
        State.Connections,
        playerAddedConnection
    )

end


--// =========================================================
--// MAIN LOOP
--// =========================================================

local function StartLoop()

    local heartbeatConnection =
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
        heartbeatConnection
    )

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

        if type(module) == "table"
            and type(module.Start) == "function" then

            local success, err =
                pcall(function()

                    module:Start()

                end)

            if success then

                print(
                    "[Main] Started: "
                    .. name
                )

            else

                warn(
                    "[Main] Failed to start "
                    .. name
                    .. ":",
                    err
                )

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

        if type(module) == "table"
            and type(module.Stop) == "function" then

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

    for _, connection in
        ipairs(State.Connections) do

        if connection then

            pcall(function()

                connection:Disconnect()

            end)

        end

    end

    table.clear(
        State.Connections
    )

end


--// =========================================================
--// START
--// =========================================================

local function Start()

    if State.Running then

        warn(
            "[Main] Already running."
        )

        return

    end

    local success, err =
        pcall(function()

            InitializeModules()

            State.Running = true

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

    print("")
    print("========================================")
    print("       GAKURAN SYSTEM STARTED")
    print("========================================")
    print("")
    print("[Main] RightShift = Toggle UI")
    print("[Main] Tab        = Cycle Target")
    print("[Main] F          = Block")
    print("[Main] X          = Dodge")
    print("")

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

    print(
        "[Main] System stopped."
    )

end


--// =========================================================
--// GLOBAL ACCESS
--// =========================================================

_G.Gakuran = {

    Start = Start,
    Stop = Stop,

    State = State,

    Modules = Modules,

    Config = Config,

    AnimationDatabase =
        AnimationDatabase,

    AnimationTracker =
        AnimationTracker,

    TargetManager =
        TargetManager,

    ParryController =
        ParryController,

    Logger =
        Logger,

    ESP =
        ESP,

    HealthOverlay =
        HealthOverlay,

    AutoPlay =
        AutoPlay,

    UI =
        UI

}


--// =========================================================
--// START
--// =========================================================

Start()
