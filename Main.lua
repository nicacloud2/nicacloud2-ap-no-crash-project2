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

    -- Download
    local success, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        warn("[Main] Failed to download " .. moduleName)
        warn(tostring(source))
        return nil
    end

    if not source or source == "" then
        warn("[Main] Empty source: " .. moduleName)
        return nil
    end

    print("[Main] Source length: " .. tostring(#source))

    print(
        "[Main] Source preview: " ..
        string.sub(source, 1, 120)
    )

    -- Detect GitHub errors
    if source == "404: Not Found"
        or source:find("^404")
        or source:find("Not Found")
    then
        warn("[Main] GitHub returned 404 for " .. moduleName)
        return nil
    end

    -- =====================================================
    -- MATCHA RETURN-VALUE FIX
    -- =====================================================
    --
    -- Matcha may execute:
    --
    --     return Config
    --
    -- but loadstring(source)() can still return nil.
    --
    -- So we replace the final return with a global result.
    --

    local returnPattern =
        "return%s+" .. moduleName .. "%s*$"

    local replacement =
        "_G.__GakuranModuleResult = " .. moduleName

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

        warn(
            "[Main] Expected: return " ..
            moduleName
        )

        return nil
    end

    -- Clear previous result
    _G.__GakuranModuleResult = nil

    -- Compile
    print("[Main] Compiling: " .. moduleName)

    local compileSuccess, chunk =
        pcall(loadstring, modifiedSource)

    if not compileSuccess or not chunk then
        warn("[Main] Compilation failed: " .. moduleName)
        warn(tostring(chunk))
        return nil
    end

    print("[Main] Compilation successful: " .. moduleName)

    -- Execute
    print("[Main] Executing: " .. moduleName)

    local executeSuccess, executeResult =
        pcall(chunk)

    if not executeSuccess then
        warn("[Main] Execution failed: " .. moduleName)
        warn(tostring(executeResult))

        _G.__GakuranModuleResult = nil

        return nil
    end

    -- =====================================================
    -- GET MODULE RESULT
    -- =====================================================

    local result = _G.__GakuranModuleResult

    -- Clear global immediately
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

        warn(
            "[Main] Expected module export: " ..
            moduleName
        )

        return nil
    end

    if type(result) ~= "table" then

        warn(
            "[Main] " ..
            moduleName ..
            " returned " ..
            tostring(type(result)) ..
            " instead of table."
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
--// LOAD CONFIG
--// =========================================================

local Config = LoadModule("Config")

if not Config then
    error(
        "[Main] Config failed to load. " ..
        "System cannot continue."
    )
end

print("[Main] Config check: " .. tostring(type(Config)))

--// =========================================================
--// LOAD ANIMATION DATABASE
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

--// =========================================================
--// INITIALIZE ANIMATION DATABASE
--// =========================================================

print("")
print("[Main] Initializing AnimationDatabase...")

local databaseSuccess, databaseError =
    pcall(function()

        AnimationDatabase:SetConfig(Config)

        AnimationDatabase:Initialize(Config)

    end)

if not databaseSuccess then
    error(
        "[Main] AnimationDatabase initialization failed: " ..
        tostring(databaseError)
    )
end

print("[Main] AnimationDatabase initialized.")

--// =========================================================
--// LOAD ANIMATION TRACKER
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

print("[Main] AnimationTracker dependencies set.")

--// =========================================================
--// LOAD TARGET MANAGER
--// =========================================================

local TargetManager =
    LoadModule("TargetManager")

if not TargetManager then
    error(
        "[Main] TargetManager failed to load."
    )
end

TargetManager:SetConfig(Config)

print("[Main] TargetManager config set.")

--// =========================================================
--// LOAD PARRY CONTROLLER
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

print("[Main] ParryController dependencies set.")

--// =========================================================
--// LOAD LOGGER
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

print("[Main] Logger dependencies set.")

--// =========================================================
--// LOAD ESP
--// =========================================================

local ESP =
    LoadModule("ESP")

if not ESP then
    error(
        "[Main] ESP failed to load."
    )
end

ESP:SetDependencies(
    Config,
    TargetManager
)

print("[Main] ESP dependencies set.")

--// =========================================================
--// LOAD HEALTH OVERLAY
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

print("[Main] HealthOverlay dependencies set.")

--// =========================================================
--// LOAD AUTOPLAY
--// =========================================================

local AutoPlay =
    LoadModule("AutoPlay")

if not AutoPlay then
    error(
        "[Main] AutoPlay failed to load."
    )
end

AutoPlay:SetDependencies(
    Config,
    TargetManager,
    ParryController
)

print("[Main] AutoPlay dependencies set.")

--// =========================================================
--// LOAD UI
--// =========================================================

local UI =
    LoadModule("UI")

if not UI then
    error(
        "[Main] UI failed to load."
    )
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

print("[Main] UI dependencies set.")

--// =========================================================
--// INITIALIZE MODULES
--// =========================================================

print("")
print("========================================")
print("        INITIALIZING GAKURAN")
print("========================================")

local function SafeInitialize(name, module)

    if not module then
        warn(
            "[Main] Cannot initialize " ..
            name ..
            ": module is nil."
        )

        return false
    end

    if type(module.Initialize) ~= "function" then
        print(
            "[Main] " ..
            name ..
            " has no Initialize()"
        )

        return true
    end

    local success, err =
        pcall(function()
            module:Initialize()
        end)

    if not success then

        warn(
            "[Main] " ..
            name ..
            " initialization failed:"
        )

        warn(tostring(err))

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
            " has no Start()"
        )

        return true
    end

    local success, err =
        pcall(function()
            module:Start()
        end)

    if not success then

        warn(
            "[Main] " ..
            name ..
            " failed to start:"
        )

        warn(tostring(err))

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

-- UI normally creates itself during Initialize,
-- so we don't need to start it separately.

--// =========================================================
--// INPUT
--// =========================================================

local UserInputService =
    game:GetService("UserInputService")

local InputConnection

InputConnection =
    UserInputService.InputBegan:Connect(
        function(input, gameProcessed)

            if gameProcessed then
                return
            end

            -- RightShift = Toggle UI
            if input.KeyCode == Enum.KeyCode.RightShift then

                if UI and
                    type(UI.Toggle) == "function"
                then

                    pcall(function()
                        UI:Toggle()
                    end)

                end

            end

            -- X = Dodge
            if input.KeyCode == Enum.KeyCode.X then

                if ParryController and
                    type(ParryController.Dodge) == "function"
                then

                    pcall(function()
                        ParryController:Dodge()
                    end)

                end

            end

            -- F = Block
            if input.KeyCode == Enum.KeyCode.F then

                if ParryController and
                    type(ParryController.BlockStart) == "function"
                then

                    pcall(function()
                        ParryController:BlockStart()
                    end)

                end

            end

        end
    )

--// =========================================================
--// INPUT RELEASE
--// =========================================================

local InputReleaseConnection

InputReleaseConnection =
    UserInputService.InputEnded:Connect(
        function(input)

            if input.KeyCode == Enum.KeyCode.F then

                if ParryController and
                    type(ParryController.BlockEnd) == "function"
                then

                    pcall(function()
                        ParryController:BlockEnd()
                    end)

                end

            end

        end
    )

--// =========================================================
--// CHARACTER RESPAWN
--// =========================================================

local Players =
    game:GetService("Players")

local LocalPlayer =
    Players.LocalPlayer

local CharacterConnection

if LocalPlayer then

    CharacterConnection =
        LocalPlayer.CharacterAdded:Connect(
            function(character)

                print(
                    "[Main] Character loaded: " ..
                    tostring(character.Name)
                )

                task.wait(0.5)

                if AnimationTracker and
                    type(AnimationTracker.RefreshLocalPlayer) == "function"
                then

                    pcall(function()
                        AnimationTracker:RefreshLocalPlayer()
                    end)

                end

                if TargetManager and
                    type(TargetManager.Refresh) == "function"
                then

                    pcall(function()
                        TargetManager:Refresh()
                    end)

                end

            end
        )

end

--// =========================================================
--// GLOBAL ACCESS
--// =========================================================

_G.Gakuran = {

    Config = Config,

    AnimationDatabase = AnimationDatabase,

    AnimationTracker = AnimationTracker,

    TargetManager = TargetManager,

    ParryController = ParryController,

    Logger = Logger,

    ESP = ESP,

    HealthOverlay = HealthOverlay,

    AutoPlay = AutoPlay,

    UI = UI,

    Modules = LoadedModules

}

--// =========================================================
--// FINAL STATUS
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
