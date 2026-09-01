--// Gakuran Modular Project
--// AnimationTracker.lua

local Players = game:GetService("Players")

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)

local AnimationTracker = {}

--==================================================
-- STATE
--==================================================

AnimationTracker.State = nil
AnimationTracker.Trackers = {}
AnimationTracker.LocalTracker = nil

-- Multiple modules can listen to animation events
AnimationTracker.Listeners = {}

--==================================================
-- INITIALIZE
--==================================================

function AnimationTracker:Initialize(State)

    self.State = State

    self.Trackers = {}
    self.LocalTracker = nil
    self.Listeners = {}

end

--==================================================
-- EVENT SYSTEM
--==================================================

function AnimationTracker:AddListener(callback)

    if typeof(callback) ~= "function" then
        return nil
    end

    table.insert(self.Listeners, callback)

    return callback

end

function AnimationTracker:RemoveListener(callback)

    for i = #self.Listeners, 1, -1 do

        if self.Listeners[i] == callback then
            table.remove(self.Listeners, i)
        end

    end

end

function AnimationTracker:FireAnimation(animationData)

    for _, callback in ipairs(self.Listeners) do

        task.spawn(function()

            local success, err = pcall(function()
                callback(animationData)
            end)

            if not success then
                warn("[AnimationTracker] Listener error:", err)
            end

        end)

    end

end

--==================================================
-- ANIMATION ID
--==================================================

function AnimationTracker:GetAnimationId(track)

    if not track then
        return nil
    end

    local animation = track.Animation

    if not animation then
        return nil
    end

    return animation.AnimationId

end

--==================================================
-- IGNORE CHECK
--==================================================

function AnimationTracker:IsIgnored(animationId)

    if not animationId then
        return true
    end

    local numericId = tonumber(string.match(animationId, "%d+"))

    if not numericId then
        return false
    end

    for _, ignoredId in ipairs(Config.IgnoreIds) do

        if numericId == ignoredId then
            return true
        end

    end

    return false

end

--==================================================
-- DATABASE
--==================================================

function AnimationTracker:GetData(animationId)

    if not animationId then
        return nil
    end

    return AnimationDatabase:Get(animationId)

end

function AnimationTracker:IsKnown(animationId)

    return AnimationDatabase:Exists(animationId)

end

function AnimationTracker:GetDisplayName(animationId)

    return AnimationDatabase:GetDisplayName(animationId)

end

function AnimationTracker:GetReactionTime(animationId)

    return AnimationDatabase:GetReactionTime(animationId)

end

--==================================================
-- ANIMATOR
--==================================================

function AnimationTracker:GetAnimator(character)

    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return nil
    end

    return humanoid:FindFirstChildOfClass("Animator")

end

--==================================================
-- PLAYING ANIMATIONS
--==================================================

function AnimationTracker:GetPlayingAnimations(character)

    local animator = self:GetAnimator(character)

    if not animator then
        return {}
    end

    return animator:GetPlayingAnimationTracks()

end

--==================================================
-- PROCESS ANIMATION
--==================================================

function AnimationTracker:ProcessAnimation(character, track)

    if not character or not track then
        return
    end

    local animationId = self:GetAnimationId(track)

    if not animationId then
        return
    end

    if self:IsIgnored(animationId) then
        return
    end

    local databaseData = self:GetData(animationId)

    local animationData = {

        Character = character,

        Player = Players:GetPlayerFromCharacter(character),

        Track = track,

        AnimationId = animationId,

        DisplayName = databaseData and databaseData.DisplayName or nil,

        ReactionTime = databaseData and databaseData.ReactionTime or nil,

        DefaultReactionTime = databaseData and databaseData.DefaultReactionTime or Config.DefaultReactionTime,

        Style = databaseData and databaseData.Style or nil,

        RegistryData = {},

        DatabaseData = databaseData,

        Timestamp = os.clock(),

    }

    self:FireAnimation(animationData)

end

--==================================================
-- TRACK CHARACTER
--==================================================

function AnimationTracker:TrackCharacter(character)

    if not character then
        return nil
    end

    if self.Trackers[character] then
        return self.Trackers[character]
    end

    local animator = self:GetAnimator(character)

    if not animator then

        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then

            animator = humanoid:WaitForChild("Animator", 5)

        end

    end

    if not animator then
        return nil
    end

    local tracker = {

        Character = character,

        Animator = animator,

        Connection = nil,

    }

    tracker.Connection = animator.AnimationPlayed:Connect(function(track)

        self:ProcessAnimation(character, track)

    end)

    self.Trackers[character] = tracker

    return tracker

end

--==================================================
-- UNTRACK CHARACTER
--==================================================

function AnimationTracker:UntrackCharacter(character)

    local tracker = self.Trackers[character]

    if not tracker then
        return
    end

    if tracker.Connection then
        tracker.Connection:Disconnect()
    end

    self.Trackers[character] = nil

end

--==================================================
-- TRACK LOCAL PLAYER
--==================================================

function AnimationTracker:TrackLocalPlayer()

    if self.LocalTracker then
        return self.LocalTracker
    end

    local character = Players.LocalPlayer.Character

    if character then
        self.LocalTracker = self:TrackCharacter(character)
    end

    if self.LocalCharacterConnection then
        self.LocalCharacterConnection:Disconnect()
    end

    self.LocalCharacterConnection = Players.LocalPlayer.CharacterAdded:Connect(function(character)

        if self.LocalTracker then
            self:UntrackCharacter(self.LocalTracker.Character)
        end

        self.LocalTracker = self:TrackCharacter(character)

    end)

    return self.LocalTracker

end

--==================================================
-- REFRESH LOCAL PLAYER
--==================================================

function AnimationTracker:RefreshLocalPlayer()

    if self.LocalTracker then

        self:UntrackCharacter(self.LocalTracker.Character)

        self.LocalTracker = nil

    end

    return self:TrackLocalPlayer()

end

--==================================================
-- TRACK ALL CHARACTERS
--==================================================

function AnimationTracker:TrackCharacters()

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= Players.LocalPlayer then

            if player.Character then
                self:TrackCharacter(player.Character)
            end

            if not self.CharacterConnections then
                self.CharacterConnections = {}
            end

            if not self.CharacterConnections[player] then

                self.CharacterConnections[player] =
                    player.CharacterAdded:Connect(function(character)

                        self:TrackCharacter(character)

                    end)

            end

        end

    end

    if not self.PlayerAddedConnection then

        self.PlayerAddedConnection =
            Players.PlayerAdded:Connect(function(player)

                if not self.CharacterConnections then
                    self.CharacterConnections = {}
                end

                self.CharacterConnections[player] =
                    player.CharacterAdded:Connect(function(character)

                        self:TrackCharacter(character)

                    end)

                if player.Character then
                    self:TrackCharacter(player.Character)
                end

            end)

    end

end

--==================================================
-- WATCH CHARACTER
--==================================================

function AnimationTracker:WatchCharacter(character)

    return self:TrackCharacter(character)

end

--==================================================
-- STATE ANIMATION CHECKS
--==================================================

function AnimationTracker:IsParriedAnimation(animationId)

    if not animationId then
        return false
    end

    for _, id in ipairs(Config.Animations.ParriedAnimation) do

        if animationId == id then
            return true
        end

    end

    return false

end

function AnimationTracker:IsStunnedAnimation(animationId)

    if not animationId then
        return false
    end

    for _, id in ipairs(Config.Animations.StunnedAnimation) do

        if animationId == id then
            return true
        end

    end

    return false

end

function AnimationTracker:IsParryingAnimation(animationId)

    if not animationId then
        return false
    end

    for _, id in ipairs(Config.Animations.ParryingAnimation) do

        if animationId == id then
            return true
        end

    end

    return false

end

function AnimationTracker:IsParryFailedAnimation(animationId)

    if not animationId then
        return false
    end

    for _, id in ipairs(Config.Animations.ParryFailed) do

        if animationId == id then
            return true
        end

    end

    return false

end

--==================================================
-- STOP EVERYTHING
--==================================================

function AnimationTracker:StopAll()

    for character in pairs(self.Trackers) do

        self:UntrackCharacter(character)

    end

    if self.LocalCharacterConnection then

        self.LocalCharacterConnection:Disconnect()
        self.LocalCharacterConnection = nil

    end

    if self.PlayerAddedConnection then

        self.PlayerAddedConnection:Disconnect()
        self.PlayerAddedConnection = nil

    end

    if self.CharacterConnections then

        for player, connection in pairs(self.CharacterConnections) do

            if connection then
                connection:Disconnect()
            end

            self.CharacterConnections[player] = nil

        end

    end

    self.LocalTracker = nil
    self.Listeners = {}

end

return AnimationTracker
