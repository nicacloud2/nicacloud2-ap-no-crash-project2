--// AnimationDatabase.lua
--// Gakuran Animation Database Processor

local Config = require(script.Parent.Config)

local AnimationDatabase = {}

--------------------------------------------------
--// Flatten Game Config
--------------------------------------------------

function AnimationDatabase:Build()
    local FlattenedConfig = {}

    for styleName, assets in pairs(Config.GameConfig) do
        for assetId, data in pairs(assets) do

            -- Ignore special configuration values
            if assetId == "M1Time" then
                continue
            end

            local flatData = table.clone(data)

            -- Store the fighting style
            flatData.Style = styleName

            --------------------------------------------------
            --// Reaction Time
            --------------------------------------------------

            if data.DisplayName ~= "M2" and assets.M1Time then

                -- Use the style's M1Time
                flatData.ReactionTime = assets.M1Time

            elseif not data.ReactionTime then

                -- Use the global default
                flatData.DefaultReactionTime = Config.DefaultReactionTime

            else

                -- Use animation-specific reaction time
                flatData.ReactionTime = data.ReactionTime
            end

            --------------------------------------------------
            --// Save
            --------------------------------------------------

            FlattenedConfig[assetId] = flatData
        end
    end

    return FlattenedConfig
end

--------------------------------------------------
--// Build Database Immediately
--------------------------------------------------

AnimationDatabase.Flattened = AnimationDatabase:Build()

--------------------------------------------------
--// Lookup Animation
--------------------------------------------------

function AnimationDatabase:Get(animationId)
    if not animationId then
        return nil
    end

    return self.Flattened[animationId]
end

--------------------------------------------------
--// Check Animation
--------------------------------------------------

function AnimationDatabase:Exists(animationId)
    return self.Flattened[animationId] ~= nil
end

--------------------------------------------------
--// Get Reaction Time
--------------------------------------------------

function AnimationDatabase:GetReactionTime(animationId)
    local data = self:Get(animationId)

    if not data then
        return Config.DefaultReactionTime
    end

    return data.ReactionTime
        or data.DefaultReactionTime
        or Config.DefaultReactionTime
end

--------------------------------------------------
--// Get Display Name
--------------------------------------------------

function AnimationDatabase:GetDisplayName(animationId)
    local data = self:Get(animationId)

    if not data then
        return nil
    end

    return data.DisplayName
end

--------------------------------------------------
--// Get Fighting Style
--------------------------------------------------

function AnimationDatabase:GetStyle(animationId)
    local data = self:Get(animationId)

    if not data then
        return nil
    end

    return data.Style
end

--------------------------------------------------
--// Get All Animations
--------------------------------------------------

function AnimationDatabase:GetAll()
    return self.Flattened
end

return AnimationDatabase
