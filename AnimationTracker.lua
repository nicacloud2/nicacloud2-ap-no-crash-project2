--// AnimationTracker.lua
--// Gakuran Script - Animation Tracking

local Players = game:GetService("Players")

local AnimationTracker = {}

AnimationTracker.State = nil
AnimationTracker.Config = nil
AnimationTracker.Connections = {}
AnimationTracker.Tracks = {}

--==================================================
-- Initialization
--==================================================

function AnimationTracker:Initialize(State, Config)
    self.State = State
    self.Config = Config

    table.clear(self.Connections)
    table.clear(self.Tracks)

    self:ConnectPlayers()
end

--==================================================
-- Track Character
--==================================================

function AnimationTracker:TrackCharacter(character)
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 5)
    end

    if not humanoid then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
    end

    if not animator then
        return
    end

    -- Avoid tracking the same animator twice
    if self.Tracks[animator] then
        return
    end

    self.Tracks[animator] = {}

    local connection = animator.AnimationPlayed:Connect(function(track)
        self:OnAnimationPlayed(character, track)
    end)

    table.insert(self.Connections, connection)
end

--==================================================
-- Animation Played
--==================================================

function AnimationTracker:OnAnimationPlayed(character, track)
    if not self.State or not self.State.Alive then
        return
    end

    if not track or not track.Animation then
        return
    end

    local animationId = track.Animation.AnimationId

    if not animationId then
        return
    end

    animationId = tostring(animationId)

    -- Remove the Roblox asset prefix
    animationId = animationId:gsub("rbxassetid://", "")

    -- Store animation
    self.State.AnimationRegistry[animationId] = {
        Character = character,
        Track = track,
        Time = os.clock(),
    }

    -- Optional logging
    if self.Config.AnimationTracker
        and self.Config.AnimationTracker.LogAnimations then

        print(
            "[AnimationTracker]",
            character.Name,
            animationId
        )
    end
end

--==================================================
-- Connect Players
--==================================================

function AnimationTracker:ConnectPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            self:TrackCharacter(player.Character)
        end

        local connection = player.CharacterAdded:Connect(function(character)
            self:TrackCharacter(character)
        end)

        table.insert(self.Connections, connection)
    end

    local playerConnection = Players.PlayerAdded:Connect(function(player)
        local connection = player.CharacterAdded:Connect(function(character)
            self:TrackCharacter(character)
        end)

        table.insert(self.Connections, connection)

        if player.Character then
            self:TrackCharacter(player.Character)
        end
    end)

    table.insert(self.Connections, playerConnection)
end

--==================================================
-- Get Last Animation
--==================================================

function AnimationTracker:Get(animationId)
    if not self.State then
        return nil
    end

    return self.State.AnimationRegistry[tostring(animationId)]
end

--==================================================
-- Clear Character
--==================================================

function AnimationTracker:ClearCharacter(character)
    if not self.State then
        return
    end

    for animationId, data in pairs(self.State.AnimationRegistry) do
        if data.Character == character then
            self.State.AnimationRegistry[animationId] = nil
        end
    end
end

--==================================================
-- Cleanup
--==================================================

function AnimationTracker:Destroy()
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(self.Connections)
    table.clear(self.Tracks)

    if self.State then
        table.clear(self.State.AnimationRegistry)
    end

    self.State = nil
    self.Config = nil
end

return AnimationTracker
