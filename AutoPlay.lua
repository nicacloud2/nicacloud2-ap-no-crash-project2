--// AutoPlay.lua
--// Gakuran AutoPlay / Input Scheduler

local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Config = require(script.Parent.Config)

local AutoPlay = {}

--------------------------------------------------
--// State
--------------------------------------------------

AutoPlay.State = nil
AutoPlay.Running = false

AutoPlay.HeldKeys = {}
AutoPlay.Receptors = {}

AutoPlay.InputQueue = {}
AutoPlay.Tasks = {}

--------------------------------------------------
--// Initialize
--------------------------------------------------

function AutoPlay:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Key Helpers
--------------------------------------------------

function AutoPlay:PressKey(key)
    if not key then
        return false
    end

    VirtualInputManager:SendKeyEvent(
        true,
        key,
        false,
        game
    )

    return true
end

function AutoPlay:ReleaseKey(key)
    if not key then
        return false
    end

    VirtualInputManager:SendKeyEvent(
        false,
        key,
        false,
        game
    )

    return true
end

--------------------------------------------------
--// Hold Key
--------------------------------------------------

function AutoPlay:HoldKey(key)
    if not key then
        return false
    end

    if self.HeldKeys[key] then
        return false
    end

    self.HeldKeys[key] = true

    self:PressKey(key)

    return true
end

--------------------------------------------------
--// Release Held Key
--------------------------------------------------

function AutoPlay:ReleaseHeldKey(key)
    if not key then
        return false
    end

    if not self.HeldKeys[key] then
        return false
    end

    self.HeldKeys[key] = nil

    self:ReleaseKey(key)

    return true
end

--------------------------------------------------
--// Release All Keys
--------------------------------------------------

function AutoPlay:ReleaseAllKeys()
    for key in pairs(self.HeldKeys) do
        self:ReleaseKey(key)
    end

    self.HeldKeys = {}
end

--------------------------------------------------
--// Tap Key
--------------------------------------------------

function AutoPlay:TapKey(key, duration)
    duration = duration
        or Config.AutoPlay.InputDelay

    self:PressKey(key)

    task.delay(duration, function()
        self:ReleaseKey(key)
    end)
end

--------------------------------------------------
--// Schedule Input
--------------------------------------------------

function AutoPlay:Schedule(
    delayTime,
    callback
)
    if type(callback) ~= "function" then
        return nil
    end

    delayTime = math.max(
        0,
        delayTime or 0
    )

    local taskData = {
        Cancelled = false,
    }

    table.insert(
        self.Tasks,
        taskData
    )

    task.delay(
        delayTime,
        function()

            if taskData.Cancelled then
                return
            end

            if callback then
                callback()
            end

            local index =
                table.find(
                    self.Tasks,
                    taskData
                )

            if index then
                table.remove(
                    self.Tasks,
                    index
                )
            end
        end
    )

    return taskData
end

--------------------------------------------------
--// Cancel Scheduled Task
--------------------------------------------------

function AutoPlay:Cancel(taskData)
    if not taskData then
        return
    end

    taskData.Cancelled = true

    local index =
        table.find(
            self.Tasks,
            taskData
        )

    if index then
        table.remove(
            self.Tasks,
            index
        )
    end
end

--------------------------------------------------
--// Cancel All Tasks
--------------------------------------------------

function AutoPlay:CancelAll()
    for _, taskData in ipairs(self.Tasks) do
        taskData.Cancelled = true
    end

    self.Tasks = {}
end

--------------------------------------------------
--// Add Receptor
--------------------------------------------------

function AutoPlay:AddReceptor(
    name,
    callback
)
    if not name then
        return false
    end

    if type(callback) ~= "function" then
        return false
    end

    self.Receptors[name] = callback

    return true
end

--------------------------------------------------
--// Remove Receptor
--------------------------------------------------

function AutoPlay:RemoveReceptor(name)
    if not name then
        return
    end

    self.Receptors[name] = nil
end

--------------------------------------------------
--// Trigger Receptor
--------------------------------------------------

function AutoPlay:TriggerReceptor(
    name,
    data
)
    local receptor =
        self.Receptors[name]

    if not receptor then
        return false
    end

    task.spawn(function()
        receptor(data)
    end)

    return true
end

--------------------------------------------------
--// Queue Input
--------------------------------------------------

function AutoPlay:QueueInput(
    key,
    delayTime,
    duration
)
    table.insert(
        self.InputQueue,
        {
            Key = key,
            Delay = delayTime or 0,
            Duration = duration,
        }
    )
end

--------------------------------------------------
--// Process Input Queue
--------------------------------------------------

function AutoPlay:ProcessQueue()
    if #self.InputQueue == 0 then
        return
    end

    local queue =
        self.InputQueue

    self.InputQueue = {}

    for _, inputData in ipairs(queue) do

        if inputData.Delay > 0 then
            task.wait(inputData.Delay)
        end

        if inputData.Duration then
            self:TapKey(
                inputData.Key,
                inputData.Duration
            )
        else
            self:TapKey(
                inputData.Key
            )
        end
    end
end

--------------------------------------------------
--// Clear Queue
--------------------------------------------------

function AutoPlay:ClearQueue()
    self.InputQueue = {}
end

--------------------------------------------------
--// Execute Input
--------------------------------------------------

function AutoPlay:Execute(
    key,
    delayTime,
    duration
)
    if not Config.AutoPlay.Enabled then
        return false
    end

    return self:Schedule(
        delayTime or 0,
        function()

            if duration then
                self:TapKey(
                    key,
                    duration
                )
            else
                self:TapKey(key)
            end

        end
    )
end

--------------------------------------------------
--// Start
--------------------------------------------------

function AutoPlay:Start()
    if self.Running then
        return
    end

    if not Config.AutoPlay.Enabled then
        return
    end

    self.Running = true

    task.spawn(function()

        while self.Running do

            if not Config.AutoPlay.Enabled then
                break
            end

            self:ProcessQueue()

            task.wait(
                Config.AutoPlay.InputDelay
                or 0.05
            )
        end

        self.Running = false
    end)
end

--------------------------------------------------
--// Stop
--------------------------------------------------

function AutoPlay:Stop()
    self.Running = false

    self:CancelAll()
    self:ClearQueue()
    self:ReleaseAllKeys()
end

--------------------------------------------------
--// Reset
--------------------------------------------------

function AutoPlay:Reset()
    self:CancelAll()
    self:ClearQueue()
    self:ReleaseAllKeys()

    self.Receptors = {}
end

return AutoPlay
