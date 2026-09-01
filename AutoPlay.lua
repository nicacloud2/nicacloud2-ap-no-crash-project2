--// AutoPlay.lua
--// Gakuran Script - Auto Play Controller

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AutoPlay = {}

AutoPlay.State = nil
AutoPlay.Config = nil
AutoPlay.Connections = {}

AutoPlay.Enabled = false
AutoPlay.Running = false

--==================================================
-- Initialization
--==================================================

function AutoPlay:Initialize(State, Config)
    self.State = State
    self.Config = Config

    table.clear(self.Connections)

    self.Enabled =
        Config
        and Config.AutoPlay
        and Config.AutoPlay.Enabled
        or false

    self.Running = false
end

--==================================================
-- Enable / Disable
--==================================================

function AutoPlay:SetEnabled(enabled)
    self.Enabled = enabled == true
end

function AutoPlay:IsEnabled()
    return self.Enabled
end

function AutoPlay:Start()
    if self.Running then
        return
    end

    if not self.Enabled then
        return
    end

    self.Running = true
end

function AutoPlay:Stop()
    self.Running = false

    self:ReleaseKeys()
end

--==================================================
-- Key Handling
--==================================================

function AutoPlay:PressKey(keyCode)
    if not keyCode then
        return
    end

    -- Put your original keypress logic here.
    --
    -- Example:
    -- keypress(keyCode.Value)
    --
    -- The exact implementation depends on
    -- the executor/input API used by your script.
end

function AutoPlay:ReleaseKey(keyCode)
    if not keyCode then
        return
    end

    -- Put your original keyrelease logic here.
end

function AutoPlay:ReleaseKeys()
    if not self.State then
        return
    end

    for keyCode in pairs(self.State.HeldKeys) do
        self:ReleaseKey(keyCode)
        self.State.HeldKeys[keyCode] = nil
    end
end

--==================================================
-- Input Sequence
--==================================================

function AutoPlay:PlaySequence(sequence)
    if not self.Enabled or not self.State then
        return
    end

    if type(sequence) ~= "table" then
        return
    end

    for _, keyCode in ipairs(sequence) do
        if not self.Running then
            break
        end

        self:PressKey(keyCode)

        self.State.HeldKeys[keyCode] = true

        local delayTime =
            self.Config
            and self.Config.AutoPlay
            and self.Config.AutoPlay.InputDelay
            or 0.05

        task.wait(delayTime)

        self:ReleaseKey(keyCode)
        self.State.HeldKeys[keyCode] = nil
    end
end

--==================================================
-- Update
--==================================================

function AutoPlay:Update()
    if not self.State or not self.State.Alive then
        return
    end

    if not self.Enabled or not self.Running then
        return
    end

    -- Put the original Auto Play update logic here.
end

--==================================================
-- Update Loop
--==================================================

function AutoPlay:StartLoop()
    local connection = RunService.Heartbeat:Connect(function()
        self:Update()
    end)

    table.insert(self.Connections, connection)
end

--==================================================
-- Cleanup
--==================================================

function AutoPlay:Destroy()
    self:Stop()

    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(self.Connections)

    self.State = nil
    self.Config = nil
end

return AutoPlay
