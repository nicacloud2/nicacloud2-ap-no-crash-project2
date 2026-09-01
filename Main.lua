--// =========================================================
--// GAKURAN SYSTEM - MAIN LOADER
--// GitHub + Matcha Compatible
--// =========================================================

local BASE_URL =
    "https://raw.githubusercontent.com/nicacloud2/nicacloud2-ap-no-crash-project2/main/"

local MODULES = {
    "Config",
    "AnimationDatabase",
    "AnimationTracker",
    "TargetManager",
    "ParryController",
    "Logger",
    "ESP",
    "HealthOverlay",
    "AutoPlay",
    "UI"
}

local LoadedModules = {}

--// =========================================================
--// SAFE CONNECT
--// =========================================================

local function SafeConnect(signal, callback, name)

    if not signal then
        warn(
            "[Main] " ..
            tostring(name) ..
            " is unavailable."
        )

        return nil
    end

    if type(signal.Connect) ~= "function" then
        warn(
            "[Main] " ..
            tostring(name) ..
            " does not support :Connect()."
        )

        return nil
    end

    local success, connection =
        pcall(function()
            return signal:Connect(callback)
        end)

    if not success then
        warn(
            "[Main] Failed to connect " ..
            tostring(name) ..
            ": " ..
            tostring(connection)
        )

        return nil
    end

    return connection
end

--// =========================================================
--// HEADER
--// =========================================================

print("========================================")
print("          GAKURAN SYSTEM")
print("========================================")
print("[Main] Loading modules...")
print("")

--// =========================================================
--// LOAD MODULE
--// =========================================================

local function LoadModule(moduleName)

    print("")
    print("----------------------------------------")
    print("[Main] Downloading: " .. moduleName)

    local url = BASE_URL .. moduleName .. ".lua"

    print("[Main] URL: " .. url)

    local success, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        warn(
            "[Main] Failed to download " ..
            moduleName
        )

        warn(tostring(source))

        return nil
    end

    if not source or source == "" then
        warn(
            "[Main] Empty source: " ..
            moduleName
        )

        return nil
    end

    print(
        "[Main] Source length: " ..
        tostring(#source)
    )

    print(
        "[Main] Source preview: " ..
        string.sub(source, 1, 120)
    )

    -- GitHub error detection
    if source == "404: Not Found"
        or source:find("^404")
        or source:find("Not Found")
    then

        warn(
            "[Main] GitHub returned 404 for " ..
            moduleName
        )

        return nil
    end

    --// =====================================================
    --// MATCHA RETURN FIX
    --// =====================================================

    local returnPattern =
        "return%s+" .. moduleName .. "%s*$"

    local replacement =
        "_G.__GakuranModuleResult = " ..
        moduleName

    local modifiedSource, replacementCount =
        source:gsub(
            returnPattern,
            replacement,
            1
        )

    if replacementCount == 0 then

        warn(
            "[Main] Could not find final return statement for " ..
            moduleName
        )

        return nil
    end

    _G.__GakuranModuleResult = nil

    -- Compile
    print(
        "[Main] Compiling: " ..
        moduleName
    )

    local compileSuccess, chunk =
        pcall(loadstring, modifiedSource)

    if not compileSuccess or not chunk then

        warn(
            "[Main] Compilation failed: " ..
            moduleName
        )

        warn(tostring(chunk))

        return nil
    end

    print(
        "[Main] Compilation successful: " ..
        moduleName
    )

    -- Execute
    print(
        "[Main] Executing: " ..
        moduleName
    )

    local executeSuccess, executeResult =
        pcall(chunk)

    if not executeSuccess then

        warn(
            "[Main] Execution failed: " ..
            moduleName
        )

        warn(tostring(executeResult))

        _G.__GakuranModuleResult = nil

        return nil
    end

    local result =
        _G.__GakuranModuleResult

    _G.__GakuranModuleResult = nil

    print(
        "[Main] Chunk return type: " ..
        tostring(type(executeResult))
    )

    print(
        "[Main] Module result type: " ..
        tostring(type(result))
    )

    if result == nil then

        warn(
            "[Main] " ..
            moduleName ..
            ".lua returned NIL."
        )

        return nil
    end

    if type(result) ~= "table" then

        warn(
            "[Main] " ..
            moduleName ..
            " returned " ..
            tostring(type(result))
        )

        return nil
    end

    LoadedModules[moduleName] = result

    print(
        "[Main] Loaded successfully: " ..
        moduleName
    )

    print("----------------------------------------")

    return result
end

--// =========================================================
--// CONFIG
--// =========================================================

local Config =
    LoadModule("Config")

if not Config then
    error("[Main] Config failed to load.")
end

print(
    "[Main] Config check: " ..
    tostring(type(Config))
)

--// =========================================================
--// ANIMATION DATABASE
--// =========================================================

local AnimationDatabase =
    LoadModule("AnimationDatabase")

if not AnimationDatabase then
    error(
        "[Main] AnimationDatabase failed to load."
    )
end

print(
    "[Main] AnimationDatabase check: " ..
    tostring(type(AnimationDatabase))
)

print("")
print("[Main] Initializing AnimationDatabase...")

local success, err =
    pcall(function()

        AnimationDatabase:SetConfig(Config)

        AnimationDatabase:Initialize(Config)

    end)

if not success then
    error(
        "[Main] AnimationDatabase initialization failed: " ..
        tostring(err)
    )
end

print(
    "[Main] AnimationDatabase initialized."
)

--// =========================================================
--// ANIMATION TRACKER
--// =========================================================

local AnimationTracker =
    LoadModule("AnimationTracker")

if not AnimationTracker then
    error(
        "[Main] AnimationTracker failed to load."
    )
end

AnimationTracker:SetDependencies(
    Config,
    AnimationDatabase
)

print(
    "[Main] AnimationTracker dependencies set."
)

--// =========================================================
--// TARGET MANAGER
--// =========================================================

local TargetManager =
    LoadModule("TargetManager")

if not TargetManager then
    error(
        "[Main] TargetManager failed to load."
    )
end

TargetManager:SetConfig(Config)

print(
    "[Main] TargetManager config set."
)

--// =========================================================
--// PARRY CONTROLLER
--// =========================================================

local ParryController =
    LoadModule("ParryController")

if not ParryController then
    error(
        "[Main] ParryController failed to load."
    )
end

ParryController:SetDependencies(
    Config,
    AnimationDatabase,
    AnimationTracker,
    TargetManager
)

print(
    "[Main] ParryController dependencies set."
)

--// =========================================================
--// LOGGER
--// =========================================================

local Logger =
    LoadModule("Logger")

if not Logger then
    error(
        "[Main] Logger failed to load."
    )
end

Logger:SetDependencies(
    Config,
    AnimationDatabase,
    AnimationTracker
)

print(
    "[Main] Logger dependencies set."
)

--// =========================================================
--// ESP
--// =========================================================

local ESP =
    LoadModule("ESP")

if not ESP then
    error("[Main] ESP failed to load.")
end

ESP:SetDependencies(
    Config,
    TargetManager
)

print(
    "[Main] ESP dependencies set."
)

--// =========================================================
--// HEALTH OVERLAY
--// =========================================================

local HealthOverlay =
    LoadModule("HealthOverlay")

if not HealthOverlay then
    error(
        "[Main] HealthOverlay failed to load."
    )
end

HealthOverlay:SetDependencies(
    Config,
    TargetManager
)

print(
    "[Main] HealthOverlay dependencies set."
)

--// =========================================================
--// AUTOPLAY
--// =========================================================

local AutoPlay =
    LoadModule("AutoPlay")

if not AutoPlay then
    error("[Main] AutoPlay failed to load.")
end

AutoPlay:SetDependencies(
    Config,
    TargetManager,
    ParryController
)

print(
    "[Main] AutoPlay dependencies set."
)

--// =========================================================
--// UI
--// =========================================================

local UI =
    LoadModule("UI")

if not UI then
    error("[Main] UI failed to load.")
end

UI:SetDependencies(
    Config,
    TargetManager,
    ParryController,
    ESP,
    HealthOverlay,
    AutoPlay,
    Logger
)

print(
    "[Main] UI dependencies set."
)

--// =========================================================
--// INITIALIZATION
--// =========================================================

print("")
print("========================================")
print("        INITIALIZING GAKURAN")
print("========================================")

local function SafeInitialize(name, module)

    if not module then
        warn(
            "[Main] " ..
            name ..
            " is nil."
        )

        return false
    end

    if type(module.Initialize) ~= "function" then

        print(
            "[Main] " ..
            name ..
            " has no Initialize()."
        )

        return true
    end

    local ok, initializeError =
        pcall(function()
            module:Initialize()
        end)

    if not ok then

        warn(
            "[Main] " ..
            name ..
            " initialization failed:"
        )

        warn(
            tostring(initializeError)
        )

        return false
    end

    print(
        "[Main] Initialized: " ..
        name
    )

    return true
end

SafeInitialize(
    "AnimationTracker",
    AnimationTracker
)

SafeInitialize(
    "TargetManager",
    TargetManager
)

SafeInitialize(
    "ParryController",
    ParryController
)

SafeInitialize(
    "Logger",
    Logger
)

SafeInitialize(
    "ESP",
    ESP
)

SafeInitialize(
    "HealthOverlay",
    HealthOverlay
)

SafeInitialize(
    "AutoPlay",
    AutoPlay
)

SafeInitialize(
    "UI",
    UI
)

--// =========================================================
--// START SYSTEMS
--// =========================================================

print("")
print("========================================")
print("          STARTING SYSTEMS")
print("========================================")

local function SafeStart(name, module)

    if not module then
        return false
    end

    if type(module.Start) ~= "function" then

        print(
            "[Main] " ..
            name ..
            " has no Start()."
        )

        return true
    end

    local ok, startError =
        pcall(function()
            module:Start()
        end)

    if not ok then

        warn(
            "[Main] " ..
            name ..
            " failed to start:"
        )

        warn(
            tostring(startError)
        )

        return false
    end

    print(
        "[Main] Started: " ..
        name
    )

    return true
end

SafeStart(
    "AnimationTracker",
    AnimationTracker
)

SafeStart(
    "TargetManager",
    TargetManager
)

SafeStart(
    "ParryController",
    ParryController
)

SafeStart(
    "Logger",
    Logger
)

SafeStart(
    "ESP",
    ESP
)

SafeStart(
    "HealthOverlay",
    HealthOverlay
)

SafeStart(
    "AutoPlay",
    AutoPlay
)

--// =========================================================
--// INPUT
--// =========================================================

local UserInputService

local inputServiceSuccess, inputService =
    pcall(function()
        return game:GetService(
            "UserInputService"
        )
    end)

if inputServiceSuccess then
    UserInputService = inputService
end

local InputConnection
local InputReleaseConnection

if UserInputService then

    InputConnection = SafeConnect(
        UserInputService.InputBegan,
        function(input, gameProcessed)

            if gameProcessed then
                return
            end

            -- RightShift = UI
            if input.KeyCode ==
                Enum.KeyCode.RightShift
            then

                if UI and
                    type(UI.Toggle) == "function"
                then

                    pcall(function()
                        UI:Toggle()
                    end)

                end

            end

            -- X = Dodge
            if input.KeyCode ==
                Enum.KeyCode.X
            then

                if ParryController and
                    type(ParryController.Dodge) == "function"
                then

                    pcall(function()
                        ParryController:Dodge()
                    end)

                end

            end

            -- F = Block
            if input.KeyCode ==
                Enum.KeyCode.F
            then

                if ParryController and
                    type(ParryController.BlockStart) == "function"
                then

                    pcall(function()
                        ParryController:BlockStart()
                    end)

                end

            end

        end,
        "UserInputService.InputBegan"
    )

    InputReleaseConnection = SafeConnect(
        UserInputService.InputEnded,
        function(input)

            if input.KeyCode ==
                Enum.KeyCode.F
            then

                if ParryController and
                    type(ParryController.BlockEnd) == "function"
                then

                    pcall(function()
                        ParryController:BlockEnd()
                    end)

                end

            end

        end,
        "UserInputService.InputEnded"
    )

else

    warn(
        "[Main] UserInputService unavailable."
    )

end

--// =========================================================
--// CHARACTER
--// =========================================================

local Players

local playersSuccess, playersService =
    pcall(function()
        return game:GetService("Players")
    end)

if playersSuccess then
    Players = playersService
end

local LocalPlayer

if Players then
    LocalPlayer = Players.LocalPlayer
end

local CharacterConnection

if LocalPlayer then

    CharacterConnection = SafeConnect(
        LocalPlayer.CharacterAdded,
        function(character)

            print(
                "[Main] Character loaded: " ..
                tostring(character.Name)
            )

            task.wait(0.5)

            if AnimationTracker and
                type(AnimationTracker.RefreshLocalPlayer) ==
                "function"
            then

                pcall(function()
                    AnimationTracker:RefreshLocalPlayer()
                end)

            end

            if TargetManager and
                type(TargetManager.Refresh) ==
                "function"
            then

                pcall(function()
                    TargetManager:Refresh()
                end)

            end

        end,
        "LocalPlayer.CharacterAdded"
    )

end

--// =========================================================
--// GLOBAL
--// =========================================================

_G.Gakuran = {

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
        UI,

    Modules =
        LoadedModules

}

--// =========================================================
--// FINAL
--// =========================================================

print("")
print("========================================")
print("       GAKURAN SYSTEM READY")
print("========================================")

print(
    "[Main] Config: " ..
    tostring(type(Config))
)

print(
    "[Main] AnimationDatabase: " ..
    tostring(type(AnimationDatabase))
)

print(
    "[Main] AnimationTracker: " ..
    tostring(type(AnimationTracker))
)

print(
    "[Main] TargetManager: " ..
    tostring(type(TargetManager))
)

print(
    "[Main] ParryController: " ..
    tostring(type(ParryController))
)

print(
    "[Main] Logger: " ..
    tostring(type(Logger))
)

print(
    "[Main] ESP: " ..
    tostring(type(ESP))
)

print(
    "[Main] HealthOverlay: " ..
    tostring(type(HealthOverlay))
)

print(
    "[Main] AutoPlay: " ..
    tostring(type(AutoPlay))
)

print(
    "[Main] UI: " ..
    tostring(type(UI))
)

print("========================================")
