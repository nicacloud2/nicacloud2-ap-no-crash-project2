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

print("========================================")
print("          GAKURAN SYSTEM")
print("========================================")
print("[Main] Loading modules...")
print("")

math.randomseed(
    os.time() +
    math.floor((os.clock() or 0) * 100000)
)

local function LoadModule(moduleName)

    print("")
    print("----------------------------------------")
    print("[Main] Downloading: " .. moduleName)

    --// Strong cache buster
    local cacheBust =
        tostring(os.time()) ..
        "_" ..
        tostring(math.floor((os.clock() or 0) * 1000000)) ..
        "_" ..
        tostring(math.random(100000, 999999)) ..
        "_" ..
        moduleName

    local url =
        BASE_URL ..
        moduleName ..
        ".lua?cb=" ..
        cacheBust

    print("[Main] URL: " .. url)

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

    if type(source) ~= "string" then

        warn(
            "[Main] Invalid source type for " ..
            moduleName
        )

        return nil
    end

    if source == "" then

        warn(
            "[Main] Empty source for " ..
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

    --// GitHub error detection
    if source == "404: Not Found"
        or source:find("^404")
    then

        warn(
            "[Main] GitHub returned 404 for " ..
            moduleName
        )

        return nil
    end

    if source:find("^403")
        or source:find("403: Forbidden")
    then

        warn(
            "[Main] GitHub returned 403 for " ..
            moduleName
        )

        return nil
    end

    --// =====================================================
    --// SOURCE VERSION CHECK
    --// =====================================================

    if moduleName == "HealthOverlay" then

        print("[Main] HealthOverlay source inspection:")

        if source:find("Drawing%.new") then
            print(
                "[Main] ✓ Drawing.new FOUND"
            )
        else
            warn(
                "[Main] ✗ Drawing.new NOT FOUND"
            )
        end

        if source:find("Instance%.new") then
            warn(
                "[Main] ✗ Instance.new FOUND"
            )
        else
            print(
                "[Main] ✓ Instance.new NOT FOUND"
            )
        end

    end

    if moduleName == "ESP" then

        print("[Main] ESP source inspection:")

        if source:find("Drawing%.new") then
            print(
                "[Main] ✓ Drawing.new FOUND"
            )
        else
            warn(
                "[Main] ✗ Drawing.new NOT FOUND"
            )
        end

    end

    --// =====================================================
    --// CLEAR PREVIOUS MODULE RESULT
    --// =====================================================

    _G.__GakuranModuleResult = nil

    local modifiedSource = source

    --// Convert bare // comment lines to Lua comments
    modifiedSource =
        modifiedSource:gsub(
            "([^\r\n])\n%s*//",
            "%1\n--//"
        )

    modifiedSource =
        modifiedSource:gsub(
            "^%s*//",
            "--//"
        )

    --// =====================================================
    --// MODULE RESULT HANDLING
    --// =====================================================

    local hasGlobalResult =
        source:find(
            "_G%.__GakuranModuleResult%s*="
        ) ~= nil

    if hasGlobalResult then

        print(
            "[Main] Matcha result already present: " ..
            moduleName
        )

    else

        local returnPattern =
            "return%s+" ..
            moduleName ..
            "%s*;?%s*$"

        local convertedSource,
              replacementCount =
            modifiedSource:gsub(
                returnPattern,
                "_G.__GakuranModuleResult = " ..
                moduleName,
                1
            )

        if replacementCount > 0 then

            modifiedSource = convertedSource

            print(
                "[Main] Converted return statement: " ..
                moduleName
            )

        else

            warn(
                "[Main] No supported module result found: " ..
                moduleName
            )

            return nil
        end
    end

    --// =====================================================
    --// COMPILE
    --// =====================================================

    print(
        "[Main] Compiling: " ..
        moduleName
    )

    local compileSuccess,
          chunk =
        pcall(
            loadstring,
            modifiedSource
        )

    if not compileSuccess then

        warn(
            "[Main] Compilation failed: " ..
            moduleName
        )

        warn(tostring(chunk))

        return nil
    end

    if type(chunk) ~= "function" then

        warn(
            "[Main] Invalid compiler result: " ..
            moduleName
        )

        return nil
    end

    print(
        "[Main] Compilation successful: " ..
        moduleName
    )

    --// =====================================================
    --// EXECUTE
    --// =====================================================

    print(
        "[Main] Executing: " ..
        moduleName
    )

    local executeSuccess,
          executeResult =
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
            ".lua produced no module result."
        )

        return nil
    end

    if type(result) ~= "table" then

        warn(
            "[Main] Invalid result type for " ..
            moduleName ..
            ": " ..
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
--// LOAD CONFIG
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
--// LOAD ANIMATION DATABASE
--// =========================================================

local AnimationDatabase =
    LoadModule("AnimationDatabase")

if not AnimationDatabase then
    error("[Main] AnimationDatabase failed to load.")
end

print(
    "[Main] AnimationDatabase check: " ..
    tostring(type(AnimationDatabase))
)

print("")
print("[Main] Initializing AnimationDatabase...")

local databaseSuccess,
      databaseError =
    pcall(function()

        if type(AnimationDatabase.SetConfig) == "function" then
            AnimationDatabase:SetConfig(Config)
        end

        if type(AnimationDatabase.Initialize) == "function" then
            AnimationDatabase:Initialize(Config)
        end

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
    error("[Main] AnimationTracker failed to load.")
end

if type(AnimationTracker.SetDependencies) == "function" then

    AnimationTracker:SetDependencies(
        Config,
        AnimationDatabase
    )

end

print("[Main] AnimationTracker dependencies set.")


--// =========================================================
--// LOAD TARGET MANAGER
--// =========================================================

local TargetManager =
    LoadModule("TargetManager")

if not TargetManager then
    error("[Main] TargetManager failed to load.")
end

if type(TargetManager.SetConfig) == "function" then
    TargetManager:SetConfig(Config)
end

print("[Main] TargetManager config set.")


--// =========================================================
--// LOAD PARRY CONTROLLER
--// =========================================================

local ParryController =
    LoadModule("ParryController")

if not ParryController then
    error("[Main] ParryController failed to load.")
end

if type(ParryController.SetDependencies) == "function" then

    ParryController:SetDependencies(
        Config,
        AnimationDatabase,
        AnimationTracker,
        TargetManager
    )

end

print("[Main] ParryController dependencies set.")


--// =========================================================
--// LOAD LOGGER
--// =========================================================

local Logger =
    LoadModule("Logger")

if not Logger then
    error("[Main] Logger failed to load.")
end

if type(Logger.SetDependencies) == "function" then

    Logger:SetDependencies(
        Config,
        AnimationDatabase,
        AnimationTracker
    )

end

print("[Main] Logger dependencies set.")


--// =========================================================
--// LOAD ESP
--// =========================================================

local ESP =
    LoadModule("ESP")

if not ESP then
    error("[Main] ESP failed to load.")
end

if type(ESP.SetDependencies) == "function" then

    ESP:SetDependencies(
        Config,
        TargetManager
    )

end

print("[Main] ESP dependencies set.")


--// =========================================================
--// LOAD HEALTH OVERLAY
--// =========================================================

local HealthOverlay =
    LoadModule("HealthOverlay")

if not HealthOverlay then
    error("[Main] HealthOverlay failed to load.")
end

if type(HealthOverlay.SetDependencies) == "function" then

    HealthOverlay:SetDependencies(
        Config,
        TargetManager
    )

end

print("[Main] HealthOverlay dependencies set.")


--// =========================================================
--// LOAD AUTOPLAY
--// =========================================================

local AutoPlay =
    LoadModule("AutoPlay")

if not AutoPlay then
    error("[Main] AutoPlay failed to load.")
end

if type(AutoPlay.SetDependencies) == "function" then

    AutoPlay:SetDependencies(
        Config,
        TargetManager,
        ParryController
    )

end

print("[Main] AutoPlay dependencies set.")


--// =========================================================
--// LOAD UI
--// =========================================================

local UI =
    LoadModule("UI")

if not UI then
    error("[Main] UI failed to load.")
end

if type(UI.SetDependencies) == "function" then

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

print("[Main] UI dependencies set.")


--// =========================================================
--// INITIALIZE SYSTEMS
--// =========================================================

print("")
print("========================================")
print("        INITIALIZING GAKURAN")
print("========================================")

local function SafeInitialize(name, module)

    if not module then
        warn("[Main] " .. name .. " is nil.")
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

    local ok,
          initializeError =
        pcall(function()

            module:Initialize()

        end)

    if not ok then

        warn(
            "[Main] " ..
            name ..
            " initialization failed:"
        )

        warn(tostring(initializeError))

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

    local ok,
          startError =
        pcall(function()

            module:Start()

        end)

    if not ok then

        warn(
            "[Main] " ..
            name ..
            " failed to start:"
        )

        warn(tostring(startError))

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


--// UI START

print("[Main] >>> UI START BLOCK REACHED <<<")

SafeStart(
    "UI",
    UI
)


--// =========================================================
--// MATCHA COMPATIBILITY
--// =========================================================

print("[Main] Main-level input connections skipped.")
print("[Main] Main-level character connections skipped.")


--// =========================================================
--// GLOBAL SYSTEM
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
--// READY
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
