--// =========================================================
--// GAKURAN - ANIMATION DATABASE
--// GitHub / Matcha Version
--// =========================================================

local AnimationDatabase = {}

--// =========================================================
--// CONFIG
--// =========================================================

local Config = nil


--// =========================================================
--// SET CONFIG
--// =========================================================

function AnimationDatabase:SetConfig(config)

    Config = config

end


--// =========================================================
--// BUILD DATABASE
--// =========================================================

function AnimationDatabase:Build()

    if not Config then
        error("[AnimationDatabase] Config has not been loaded.")
    end

    local FlattenedConfig = {}

    local GameConfig = Config.GameConfig or {}

    for styleName, assets in pairs(GameConfig) do

        if type(assets) ~= "table" then
            continue
        end

        for assetId, data in pairs(assets) do

            -- M1Time is configuration data, not an animation
            if assetId == "M1Time" then
                continue
            end

            if type(data) ~= "table" then
                continue
            end

            local flatData = table.clone(data)

            flatData.Style = styleName


            --// M1 animations inherit the style's M1Time

            if data.DisplayName ~= "M2" and assets.M1Time then

                flatData.ReactionTime = assets.M1Time

            elseif not data.ReactionTime then

                flatData.DefaultReactionTime =
                    Config.DefaultReactionTime

            else

                flatData.ReactionTime =
                    data.ReactionTime

            end


            FlattenedConfig[assetId] = flatData

        end

    end

    self.Flattened = FlattenedConfig

    return FlattenedConfig

end


--// =========================================================
--// DATABASE
--// =========================================================

AnimationDatabase.Flattened = {}


--// =========================================================
--// GET ANIMATION
--// =========================================================

function AnimationDatabase:Get(animationId)

    if not animationId then
        return nil
    end

    return self.Flattened[animationId]

end


--// =========================================================
--// CHECK ANIMATION
--// =========================================================

function AnimationDatabase:Exists(animationId)

    if not animationId then
        return false
    end

    return self.Flattened[animationId] ~= nil

end


--// =========================================================
--// GET REACTION TIME
--// =========================================================

function AnimationDatabase:GetReactionTime(animationId)

    local data = self:Get(animationId)

    if not data then

        if Config then
            return Config.DefaultReactionTime
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

    if not animationId or type(data) ~= "table" then
        return false
    end

    self.Flattened[animationId] = table.clone(data)

    return true

end


--// =========================================================
--// REMOVE ANIMATION
--// =========================================================

function AnimationDatabase:Remove(animationId)

    if not animationId then
        return false
    end

    if not self.Flattened[animationId] then
        return false
    end

    self.Flattened[animationId] = nil

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
        "[AnimationDatabase] Loaded " ..
        tostring(self:GetCount()) ..
        " animations."
    )

end


--// =========================================================
--// RETURN
--// =========================================================

return AnimationDatabase
