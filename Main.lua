```lua
--// =========================================================
--// GAKURAN SYSTEM - MAIN LOADER
--// GitHub + Matcha Compatible
--// Safe Module Return Handling
--// Polling-Safe Edition
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
--// SAFE MODULE RESULT STORAGE
--// =========================================================

_G.__GakuranModuleResult = nil

--// =========================================================
--// LOAD MODULE
--// =========================================================

local function LoadModule(moduleName)

    print("")
    print("----------------------------------------")
    print("[Main] Downloading: " .. moduleName)

    local url =
        BASE_URL .. moduleName .. ".lua"

    print("[Main] URL: " .. url)

    --// -----------------------------------------------------
    --// DOWNLOAD
    --// -----------------------------------------------------

    local downloadSuccess, source =
        pcall(function()
            return game:HttpGet(url)
        end)

    if not downloadSuccess then

        warn(
            "[Main] Failed to download " ..
            moduleName
        )

        warn(tostring(source))

        return nil
    end

    if type(source) ~= "string" or source == "" then

        warn(
            "[Main] Empty or invalid source: " ..
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

    --// -----------------------------------------------------
    --// GITHUB ERROR DETECTION
    --// -----------------------------------------------------

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

    --// -----------------------------------------------------
    --// CLEAR PREVIOUS RESULT
    --// -----------------------------------------------------

    _G.__GakuranModuleResult = nil

    --// -----------------------------------------------------
    --// RETURN HANDLING
    --// -----------------------------------------------------
    --
    --// Supported module endings:
    --
    --// 1:
    --// return ModuleName
    --
    --// 2:
    --// _G.__GakuranModuleResult = ModuleName
    --
    --// The source is converted to global-result form
    --// before execution because Matcha does not reliably
    --// expose the value returned by loadstring().
    --// -----------------------------------------------------

    local modifiedSource = source

    --// -----------------------------------------------------
    --// CHECK FOR EXISTING MATCHA RESULT
    --// -----------------------------------------------------

    local hasGlobalResult =
        source:find(
            "_G%.__GakuranModuleResult%s*="
        ) ~= nil

    --// -----------------------------------------------------
    --// CHECK FOR FINAL RETURN
    --// -----------------------------------------------------

    local finalReturnPattern =
        "return%s+" ..
        moduleName ..
        "%s*;?%s*$"

    local returnStart =
        source:match(
            "()%s*return%s+" ..
            moduleName ..
            "%s*;?%s*$"
        )

    if returnStart then

        --// Replace only the final return statement.
        modifiedSource =
            source:gsub(
                "return%s+" ..
                moduleName ..
                "%s*;?%s*$",
                "_G.__GakuranModuleResult = " ..
                moduleName,
                1
            )

        print(
            "[Main] Converted final return for " ..
            moduleName
        )

    elseif hasGlobalResult then

        --// Module already handles its own result.

        print(
            "[Main] Module already uses Matcha result: " ..
            moduleName
        )

    else

        --// -------------------------------------------------
        --// FALLBACK
        --// -------------------------------------------------
        --
        --// Some modules may have:
        --
        --// local ModuleName = {}
        --
        --// but no return statement.
        --
        --// We do not guess blindly.
        --// Instead, try to append a result assignment
        --// only when the expected module variable exists.
        --
        --// This check is performed after compilation,
        --// so syntax remains untouched here.

        print(
            "[Main] No explicit module return found for " ..
            moduleName
        )

        --// Safely append the expected result assignment.
        modifiedSource =
            source ..
            "\n\n" ..
            "--// Gakuran Matcha fallback result\n" ..
            "if type(" ..
            moduleName ..
            ") == \"table\" then\n" ..
            "    _G.__GakuranModuleResult = " ..
            moduleName ..
            "\n" ..
            "end\n"

        print(
            "[Main] Added safe result fallback for " ..
            moduleName
        )
    end

    --// -----------------------------------------------------
    --// COMPILE
    --// -----------------------------------------------------

    print(
        "[Main] Compiling: " ..
        moduleName
    )

    local compileSuccess, chunk =
        pcall(
            loadstring,
            modifiedSource
        )

    if not compileSuccess then

        warn(
            "[Main] Compilation call failed: " ..
            moduleName
        )

        warn(tostring(chunk))

        return nil
    end

    if type(chunk) ~= "function" then

        warn(
            "[Main] Compiler returned invalid chunk: " ..
            moduleName
        )

        warn(
            "[Main] Compiler result type: " ..
            tostring(type(chunk))
        )

        return nil
    end

    print(
        "[Main] Compilation successful: " ..
        moduleName
    )

    --// -----------------------------------------------------
    --// EXECUTE
    --// -----------------------------------------------------

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

        warn(
            tostring(executeResult)
        )

        _G.__GakuranModuleResult = nil

        return nil
    end

    --// -----------------------------------------------------
    --// READ MODULE RESULT
    --// -----------------------------------------------------

    local result =
        _G.__GakuranModuleResult

    --// Clear global immediately after reading.
    _G.__GakuranModuleResult = nil

    print(
        "[Main] Chunk return type: " ..
        tostring(type(executeResult))
    )

    print(
        "[Main] Module result type: " ..
        tostring(type(result))
    )

    --// -----------------------------------------------------
    --// VALIDATE RESULT
    --// -----------------------------------------------------

    if result == nil then

        warn(
            "[Main] " ..
            moduleName ..
            ".lua produced no module result."
        )

        warn(
            "[Main] Expected a table named " ..
            moduleName
        )

        return nil
    end

    if type(result) ~= "table" then

        warn(
            "[Main] " ..
            moduleName ..
            " produced invalid result type: " ..
            tostring(type(result))
        )

        return nil
    end

    --// -----------------------------------------------------
    --// CACHE
    --// -----------------------------------------------------

    LoadedModules[moduleName] =
        result

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

    error(
        "[Main] Config failed to load."
    )
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

        if type(AnimationDatabase.SetConfig) ==
            "function"
        then

            AnimationDatabase:SetConfig(
                Config
            )
        end

        if type(AnimationDatabase.Initialize) ==
            "function"
        then

            AnimationDatabase:Initialize(
                Config
            )
        end
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

if type(AnimationTracker.SetDependencies) ==
    "function"
then

    AnimationTracker:SetDependencies(
        Config,
        AnimationDatabase
    )
end

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

if type(TargetManager.SetConfig) ==
    "function"
then

    TargetManager:SetConfig(
        Config
    )
end

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

if type(ParryController.SetDependencies) ==
    "function"
then

    ParryController:SetDependencies(
        Config,
        AnimationDatabase,
        AnimationTracker,
        TargetManager
    )
end

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

if type(Logger.SetDependencies) ==
    "function"
then

    Logger:SetDependencies(
        Config,
        AnimationDatabase,
        AnimationTracker
    )
end

print(
    "[Main] Logger dependencies set."
)

--// =========================================================
--// ESP
--// =========================================================

local ESP =
    LoadModule("ESP")

if not ESP then

    error(
        "[Main] ESP failed to load."
    )
end

if type(ESP.SetDependencies) ==
    "function"
then

    ESP:SetDependencies(
        Config,
        TargetManager
    )
end

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

if type(HealthOverlay.SetDependencies) ==
    "function"
then

    HealthOverlay:SetDependencies(
        Config,
        TargetManager
    )
end

print(
    "[Main] HealthOverlay dependencies set."
)

--// =========================================================
--// AUTOPLAY
--// =========================================================

local AutoPlay =
    LoadModule("AutoPlay")

if not AutoPlay then

    error(
        "[Main] AutoPlay failed to load."
    )
end

if type(AutoPlay.SetDependencies) ==
    "function"
then

    AutoPlay:SetDependencies(
        Config,
        TargetManager,
        ParryController
    )
end

print(
    "[Main] AutoPlay dependencies set."
)

--// =========================================================
--// UI
--// =========================================================

local UI =
    LoadModule("UI")

if not UI then

    error(
        "[Main] UI failed to load."
    )
end

if type(UI.SetDependencies) ==
    "function"
then

    UI:SetDependencies(
        Config,
        TargetManager,
        ParryController,
        ESP,
        HealthOverlay,
        AutoPlay,
        Logger
    )
end

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

local function SafeInitialize(
    name,
    module
)

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

local function SafeStart(
    name,
    module
)

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

print(
    "[Main] Input event connections skipped for Matcha compatibility."
)

--// =========================================================
--// CHARACTER
--// =========================================================

print(
    "[Main] Character event connections skipped."
)

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
```
