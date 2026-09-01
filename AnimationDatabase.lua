--// =========================================================
--// GAKURAN - ANIMATION DATABASE
--// GitHub / Matcha Version
--// =========================================================

local AnimationDatabase = {}

local Config = nil

AnimationDatabase.Flattened = {}


--// =========================================================
--// SET CONFIG
--// =========================================================

function AnimationDatabase:SetConfig(config)

    Config = config

end


--// =========================================================
--// NORMALIZE ANIMATION ID
--// =========================================================

function AnimationDatabase:NormalizeId(animationId)

    if not animationId then
        return nil
    end

    animationId = tostring(animationId)

    if animationId == "" then
        return nil
    end

    --// Already formatted
    if string.find(animationId, "rbxassetid://", 1, true) then
        return animationId
    end

    --// Raw numeric ID
    if tonumber(animationId) then
        return "rbxassetid://" .. animationId
    end

    return animationId

end


--// =========================================================
--// ADD INTERNAL
--// =========================================================

function AnimationDatabase:AddInternal(animationId, data)

    local id = self:NormalizeId(animationId)

    if not id then
        return false
    end

    if type(data) ~= "table" then
        data = {}
    end

    local entry = {}

    for key, value in pairs(data) do
        entry[key] = value
    end

    entry.AnimationId = id

    self.Flattened[id] = entry

    return true

end


--// =========================================================
--// BUILD DATABASE
--// =========================================================

function AnimationDatabase:Build()

    if not Config then
        error("[AnimationDatabase] Config has not been loaded.")
    end

    self.Flattened = {}

    local GameConfig = Config.GameConfig or {}

    local count = 0


    --// =====================================================
    --// READ STYLE DATABASE
    --// =====================================================

    for styleName, assets in pairs(GameConfig) do

        if type(assets) == "table" then

            local m1Time = assets.M1Time


            for animationId, data in pairs(assets) do

                --// Ignore configuration values
                if animationId ~= "M1Time"
                    and type(data) == "table"
                then

                    local entry = {}

                    for key, value in pairs(data) do
                        entry[key] = value
                    end


                    entry.Style = styleName
                    entry.AnimationId =
                        self:NormalizeId(animationId)


                    --// Apply style M1 timing

                    if not entry.ReactionTime
                        and m1Time
                    then

                        entry.ReactionTime = m1Time

                    end


                    if not entry.ReactionTime
                        and not entry.DefaultReactionTime
                    then

                        entry.DefaultReactionTime =
                            Config.DefaultReactionTime or 0.1

                    end


                    local normalizedId =
                        self:NormalizeId(animationId)


                    if normalizedId then

                        self.Flattened[normalizedId] =
                            entry

                        count += 1

                    end

                end

            end

        end

    end


    --// =====================================================
    --// OPTIONAL DIRECT ANIMATION LIST
    --// =====================================================
    --// Allows Config to contain:
    --
    --// Config.Animations = {
    --//     {
    --//         AnimationId = "rbxassetid://123",
    --//         DisplayName = "M1",
    --//         Style = "Karate",
    --//         ReactionTime = 0.6
    --//     }
    --// }
    --
    --// =====================================================

    if type(Config.Animations) == "table" then

        for _, animation in pairs(Config.Animations) do

            if type(animation) == "table" then

                local animationId =
                    animation.AnimationId
                    or animation.Id
                    or animation.AssetId


                if animationId then

                    local id =
                        self:NormalizeId(animationId)


                    if id then

                        local entry = {}

                        for key, value in pairs(animation) do
                            entry[key] = value
                        end


                        entry.AnimationId = id


                        if not entry.ReactionTime
                            and not entry.DefaultReactionTime
                        then

                            entry.DefaultReactionTime =
                                Config.DefaultReactionTime or 0.1

                        end


                        if not self.Flattened[id] then
                            count += 1
                        end


                        self.Flattened[id] = entry

                    end

                end

            end

        end

    end


    print(
        "[AnimationDatabase] Built database with "
        .. tostring(count)
        .. " animations."
    )


    return self.Flattened

end


--// =========================================================
--// GET ANIMATION
--// =========================================================

function AnimationDatabase:Get(animationId)

    local id = self:NormalizeId(animationId)

    if not id then
        return nil
    end

    return self.Flattened[id]

end


--// =========================================================
--// CHECK ANIMATION
--// =========================================================

function AnimationDatabase:Exists(animationId)

    return self:Get(animationId) ~= nil

end


--// =========================================================
--// GET REACTION TIME
--// =========================================================

function AnimationDatabase:GetReactionTime(animationId)

    local data = self:Get(animationId)

    if not data then

        if Config then
            return Config.DefaultReactionTime or 0.1
        end

        return 0.1

    end


    return data.ReactionTime
        or data.DefaultReactionTime
        or (Config and Config.DefaultReactionTime)
        or 0.1

end


--// =========================================================
--// GET DISPLAY NAME
--// =========================================================

function AnimationDatabase:GetDisplayName(animationId)

    local data = self:Get(animationId)

    if not data then
        return nil
    end

    return data.DisplayName

end


--// =========================================================
--// GET STYLE
--// =========================================================

function AnimationDatabase:GetStyle(animationId)

    local data = self:Get(animationId)

    if not data then
        return nil
    end

    return data.Style

end


--// =========================================================
--// GET ALL
--// =========================================================

function AnimationDatabase:GetAll()

    return self.Flattened

end


--// =========================================================
--// GET COUNT
--// =========================================================

function AnimationDatabase:GetCount()

    local count = 0

    for _ in pairs(self.Flattened) do
        count += 1
    end

    return count

end


--// =========================================================
--// ADD ANIMATION
--// =========================================================

function AnimationDatabase:Add(animationId, data)

    return self:AddInternal(animationId, data)

end


--// =========================================================
--// REMOVE ANIMATION
--// =========================================================

function AnimationDatabase:Remove(animationId)

    local id = self:NormalizeId(animationId)

    if not id then
        return false
    end

    if not self.Flattened[id] then
        return false
    end

    self.Flattened[id] = nil

    return true

end


--// =========================================================
--// CLEAR
--// =========================================================

function AnimationDatabase:Clear()

    self.Flattened = {}

end


--// =========================================================
--// INITIALIZE
--// =========================================================

function AnimationDatabase:Initialize(config)

    if config then
        self:SetConfig(config)
    end

    self:Build()

    print(
        "[AnimationDatabase] Loaded "
        .. tostring(self:GetCount())
        .. " animations."
    )

end


--// =========================================================
--// MATCHA MODULE RESULT
--// =========================================================

_G.__GakuranModuleResult = AnimationDatabase
