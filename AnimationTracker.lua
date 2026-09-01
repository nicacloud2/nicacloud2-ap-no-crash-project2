--// =========================================================
--// GAKURAN - ANIMATION TRACKER
--// GitHub / Matcha Version
--// =========================================================

local Players = game:GetService("Players")

local AnimationTracker = {}

--// Dependencies are injected by Main.lua
local Config = nil
local AnimationDatabase = nil


--// =========================================================
--// STATE
--// =========================================================

AnimationTracker.State = {
    Running = false
}

AnimationTracker.Trackers = {}
AnimationTracker.LocalTracker = nil
AnimationTracker.Listeners = {}


--// =========================================================
--// DEPENDENCIES
--// =========================================================

function AnimationTracker:SetDependencies(config, animationDatabase)

    Config = config
    AnimationDatabase = animationDatabase

end


--// =========================================================
--// LISTENERS
--// =========================================================

function AnimationTracker:AddListener(callback)

    if type(callback) ~= "function" then
        return false
    end

    for _, listener in ipairs(self.Listeners) do
        if listener == callback then
            return false
        end
    end

    table.insert(self.Listeners, callback)

    return true

end


function AnimationTracker:RemoveListener(callback)

    for i, listener in ipairs(self.Listeners) do

        if listener == callback then

            table.remove(self.Listeners, i)

            return true

        end

    end

    return false

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


--// =========================================================
--// GET ANIMATION ID
--// =========================================================

local function GetAnimationId(track)

    if not track then
        return nil
    end

    local animation = track.Animation

    if not animation then
        return nil
    end

    return animation.AnimationId

end


--// =========================================================
--// PROCESS ANIMATION
--// =========================================================

function AnimationTracker:ProcessAnimation(character, track)

    if not self.State.Running then
        return
    end

    if not character or not track then
        return
    end


    local animationId = GetAnimationId(track)

    if not animationId then
        return
    end


    --// Ignore configured IDs

    if Config and Config.IgnoreIds then

        for _, ignoredId in ipairs(Config.IgnoreIds) do

            if animationId == ignoredId then
                return
            end

        end

    end


    local databaseData = nil

    if AnimationDatabase then
        databaseData = AnimationDatabase:Get(animationId)
    end


    local animationData = {

        Character = character,

        Player = Players:GetPlayerFromCharacter(character),

        Track = track,

        AnimationId = animationId,

        DisplayName = databaseData
            and databaseData.DisplayName
            or nil,

        ReactionTime = databaseData
            and databaseData.ReactionTime
            or nil,

        DefaultReactionTime = databaseData
            and databaseData.DefaultReactionTime
            or (Config and Config.DefaultReactionTime)
            or 0.1,

        Style = databaseData
            and databaseData.Style
            or nil,

        RegistryData = {},

        DatabaseData = databaseData,

        Timestamp = os.clock()

    }


    self:FireAnimation(animationData)

end


--// =========================================================
--// TRACK CHARACTER
--// =========================================================

function AnimationTracker:TrackCharacter(character)

    if not character then
        return nil
    end


    --// Don't duplicate trackers

    if self.Trackers[character] then
        return self.Trackers[character]
    end


    local humanoid =
        character:FindFirstChildOfClass("Humanoid")


    if not humanoid then

        humanoid =
            character:WaitForChild("Humanoid", 5)

    end


    if not humanoid then
        warn(
            "[AnimationTracker] No Humanoid found for " ..
            character.Name
        )

        return nil
    end


    local animator =
        humanoid:FindFirstChildOfClass("Animator")


    if not animator then

        animator =
            humanoid:WaitForChild("Animator", 5)

    end


    if not animator then
        warn(
            "[AnimationTracker] No Animator found for " ..
            character.Name
        )

        return nil
    end


    local tracker = {

        Character = character,

        Humanoid = humanoid,

        Animator = animator,

        Connections = {}

    }


    self.Trackers[character] = tracker


    --// Listen for new animations

    tracker.Connections.AnimationPlayed =
        animator.AnimationPlayed:Connect(function(track)

            self:ProcessAnimation(character, track)

        end)


    --// Process animations that are already playing

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do

        task.spawn(function()

            self:ProcessAnimation(character, track)

        end)

    end


    return tracker

end


--// =========================================================
--// UNTRACK CHARACTER
--// =========================================================

function AnimationTracker:UntrackCharacter(character)

    local tracker = self.Trackers[character]

    if not tracker then
        return
    end


    for _, connection in pairs(tracker.Connections) do

        if connection then

            pcall(function()
                connection:Disconnect()
            end)

        end

    end


    self.Trackers[character] = nil

end


--// =========================================================
--// TRACK LOCAL PLAYER
--// =========================================================

function AnimationTracker:TrackLocalPlayer()

    local player = Players.LocalPlayer

    if not player then
        return nil
    end


    local character = player.Character

    if not character then

        character =
            player.CharacterAdded:Wait()

    end


    self.LocalTracker =
        self:TrackCharacter(character)


    return self.LocalTracker

end


--// =========================================================
--// REFRESH LOCAL PLAYER
--// =========================================================

function AnimationTracker:RefreshLocalPlayer()

    local player = Players.LocalPlayer

    if not player then
        return
    end


    if self.LocalTracker
        and self.LocalTracker.Character then

        self:UntrackCharacter(
            self.LocalTracker.Character
        )

    end


    self.LocalTracker =
        self:TrackCharacter(player.Character)

end


--// =========================================================
--// TRACK ALL CHARACTERS
--// =========================================================

function AnimationTracker:TrackCharacters()

    for _, player in ipairs(Players:GetPlayers()) do

        if player.Character then

            self:TrackCharacter(player.Character)

        end

    end

end


--// =========================================================
--// WATCH CHARACTER
--// =========================================================

function AnimationTracker:WatchCharacter(player)

    if not player then
        return
    end


    if player.Character then
        self:TrackCharacter(player.Character)
    end


    local connection =
        player.CharacterAdded:Connect(function(character)

            task.wait(0.25)

            if self.State.Running then
                self:TrackCharacter(character)
            end

        end)


    return connection

end


--// =========================================================
--// CHECK ANIMATION STATE
--// =========================================================

local function ContainsAnimation(animationList, animationId)

    if not animationList then
        return false
    end


    for _, id in ipairs(animationList) do

        if id == animationId then
            return true
        end

    end


    return false

end


function AnimationTracker:IsParriedAnimation(animationId)

    return Config
        and ContainsAnimation(
            Config.ParriedAnimation,
            animationId
        )
        or false

end


function AnimationTracker:IsStunnedAnimation(animationId)

    return Config
        and ContainsAnimation(
            Config.StunnedAnimation,
            animationId
        )
        or false

end


function AnimationTracker:IsParryingAnimation(animationId)

    return Config
        and ContainsAnimation(
            Config.ParryingAnimation,
            animationId
        )
        or false

end


function AnimationTracker:IsParryFailed(animationId)

    return Config
        and ContainsAnimation(
            Config.ParryFailed,
            animationId
        )
        or false

end


--// =========================================================
--// GET TRACKER
--// =========================================================

function AnimationTracker:GetTracker(character)

    return self.Trackers[character]

end


--// =========================================================
--// GET ALL TRACKERS
--// =========================================================

function AnimationTracker:GetTrackers()

    return self.Trackers

end


--// =========================================================
--// STOP ALL
--// =========================================================

function AnimationTracker:StopAll()

    for character in pairs(self.Trackers) do

        self:UntrackCharacter(character)

    end


    self.LocalTracker = nil

end


--// =========================================================
--// START
--// =========================================================

function AnimationTracker:Start()

    if self.State.Running then
        return
    end


    self.State.Running = true


    self:TrackLocalPlayer()
    self:TrackCharacters()


    print("[AnimationTracker] Started.")

end


--// =========================================================
--// STOP
--// =========================================================

function AnimationTracker:Stop()

    if not self.State.Running then
        return
    end


    self.State.Running = false

    self:StopAll()


    print("[AnimationTracker] Stopped.")

end


--// =========================================================
--// INITIALIZE
--// =========================================================

function AnimationTracker:Initialize(state)

    self.State.Shared = state

    print("[AnimationTracker] Initialized.")

end


--// =========================================================
--// RETURN
--// =========================================================

return AnimationTracker
