--// AnimationTracker.lua
--// Gakuran Animation Tracking Module

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Config = require(script.Parent.Config)
local AnimationDatabase = require(script.Parent.AnimationDatabase)

local AnimationTracker = {}

--------------------------------------------------
--// State
--------------------------------------------------

AnimationTracker.State = nil
AnimationTracker.Trackers = {}
AnimationTracker.LocalTracker = nil

--------------------------------------------------
--// Initialize
--------------------------------------------------

function AnimationTracker:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Animation ID Helper
--------------------------------------------------

function AnimationTracker:GetAnimationId(animation)
    if not animation then
        return nil
    end

    -- Animation object
    if animation.AnimationId then
        return animation.AnimationId
    end

    -- AnimationTrack
    if animation.Animation and animation.Animation.AnimationId then
        return animation.Animation.AnimationId
    end

    return nil
end

--------------------------------------------------
--// Check Ignore List
--------------------------------------------------

function AnimationTracker:IsIgnored(animationId)
    if not animationId then
        return false
    end

    local numericId = tonumber(
        tostring(animationId):match("%d+")
    )

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

--------------------------------------------------
--// Get Animation Data
--------------------------------------------------

function AnimationTracker:GetData(animationId)
    if not animationId then
        return nil
    end

    return AnimationDatabase:Get(animationId)
end

--------------------------------------------------
--// Check Known Animation
--------------------------------------------------

function AnimationTracker:IsKnown(animationId)
    return AnimationDatabase:Exists(animationId)
end

--------------------------------------------------
--// Get Display Name
--------------------------------------------------

function AnimationTracker:GetDisplayName(animationId)
    local data = self:GetData(animationId)

    if data then
        return data.DisplayName
    end

    return tostring(animationId)
end

--------------------------------------------------
--// Get Reaction Time
--------------------------------------------------

function AnimationTracker:GetReactionTime(animationId)
    return AnimationDatabase:GetReactionTime(animationId)
end

--------------------------------------------------
--// Get Animator
--------------------------------------------------

function AnimationTracker:GetAnimator(character)
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Animator")
        or character:FindFirstChildWhichIsA("Animator", true)
end

--------------------------------------------------
--// Get Playing Animations
--------------------------------------------------

function AnimationTracker:GetPlayingAnimations(character)
    local animator = self:GetAnimator(character)

    if not animator then
        return {}
    end

    return animator:GetPlayingAnimationTracks()
end

--------------------------------------------------
--// Process Animation
--------------------------------------------------

function AnimationTracker:ProcessAnimation(
    character,
    animationTrack
)
    if not character or not animationTrack then
        return nil
    end

    local animationId = self:GetAnimationId(animationTrack)

    if not animationId then
        return nil
    end

    if self:IsIgnored(animationId) then
        return nil
    end

    local data = self:GetData(animationId)

    return {
        Character = character,
        Player = Players:GetPlayerFromCharacter(character),

        AnimationTrack = animationTrack,
        AnimationId = animationId,

        DisplayName = data and data.DisplayName
            or tostring(animationId),

        Style = data and data.Style,

        ReactionTime = self:GetReactionTime(animationId),

        Known = data ~= nil,

        RegistryData = {},
    }
end

--------------------------------------------------
--// Track Character
--------------------------------------------------

function AnimationTracker:TrackCharacter(character)
    if not character then
        return nil
    end

    local animator = self:GetAnimator(character)

    if not animator then
        return nil
    end

    --------------------------------------------------
    -- Prevent duplicate trackers
    --------------------------------------------------

    if self.Trackers[character] then
        return self.Trackers[character]
    end

    local tracker = {
        Character = character,
        Animator = animator,
        Connections = {},
        Active = true,
    }

    self.Trackers[character] = tracker

    --------------------------------------------------
    -- Animation Played
    --------------------------------------------------

    tracker.Connections.AnimationPlayed =
        animator.AnimationPlayed:Connect(function(animationTrack)

            if not tracker.Active then
                return
            end

            local data = self:ProcessAnimation(
                character,
                animationTrack
            )

            if not data then
                return
            end

            --------------------------------------------------
            -- Callback for Main / ParryController
            --------------------------------------------------

            if self.OnAnimation then
                self.OnAnimation(data)
            end
        end)

    return tracker
end

--------------------------------------------------
--// Stop Tracking Character
--------------------------------------------------

function AnimationTracker:UntrackCharacter(character)
    local tracker = self.Trackers[character]

    if not tracker then
        return
    end

    tracker.Active = false

    for _, connection in pairs(tracker.Connections) do
        if connection then
            connection:Disconnect()
        end
    end

    tracker.Connections = {}

    self.Trackers[character] = nil
end

--------------------------------------------------
--// Track Local Player
--------------------------------------------------

function AnimationTracker:TrackLocalPlayer()
    local character = LocalPlayer.Character

    if not character then
        return nil
    end

    self.LocalTracker = self:TrackCharacter(character)

    return self.LocalTracker
end

--------------------------------------------------
--// Refresh Local Player
--------------------------------------------------

function AnimationTracker:RefreshLocalPlayer()
    if self.LocalTracker then
        self:UntrackCharacter(LocalPlayer.Character)
    end

    return self:TrackLocalPlayer()
end

--------------------------------------------------
--// Track Existing Characters
--------------------------------------------------

function AnimationTracker:TrackCharacters(characters)
    if not characters then
        return
    end

    for _, character in ipairs(characters) do
        if character ~= LocalPlayer.Character then
            self:TrackCharacter(character)
        end
    end
end

--------------------------------------------------
--// Untrack Everything
--------------------------------------------------

function AnimationTracker:StopAll()
    for character in pairs(self.Trackers) do
        self:UntrackCharacter(character)
    end

    self.LocalTracker = nil
end

--------------------------------------------------
--// Character Added
--------------------------------------------------

function AnimationTracker:WatchCharacter(character)
    if not character then
        return
    end

    task.spawn(function()
        local animator = character:FindFirstChildOfClass("Animator")

        if not animator then
            animator = character:WaitForChild(
                "Humanoid",
                5
            )

            if animator then
                animator = animator:FindFirstChildOfClass("Animator")
            end
        end

        if animator then
            self:TrackCharacter(character)
        end
    end)
end

--------------------------------------------------
--// Animation Lookup Helpers
--------------------------------------------------

function AnimationTracker:IsParriedAnimation(animationId)
    for _, id in ipairs(Config.Animations.ParriedAnimation or {}) do
        if id == animationId then
            return true
        end
    end

    return false
end

function AnimationTracker:IsStunnedAnimation(animationId)
    for _, id in ipairs(Config.Animations.StunnedAnimation or {}) do
        if id == animationId then
            return true
        end
    end

    return false
end

function AnimationTracker:IsParryingAnimation(animationId)
    for _, id in ipairs(Config.Animations.ParryingAnimation or {}) do
        if id == animationId then
            return true
        end
    end

    return false
end

function AnimationTracker:IsParryFailedAnimation(animationId)
    for _, id in ipairs(Config.Animations.ParryFailed or {}) do
        if id == animationId then
            return true
        end
    end

    return false
end

--------------------------------------------------
--// Initialize Local Character
--------------------------------------------------

if Config.AnimationTracker.Enabled then

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)

        AnimationTracker:TrackLocalPlayer()
    end)

end

return AnimationTracker
