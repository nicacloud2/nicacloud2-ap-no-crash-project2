--// AnimationDatabase.lua
--// Gakuran Script - Animation Database

local AnimationDatabase = {}

--==================================================
-- Animation Definitions
--==================================================

AnimationDatabase.Animations = {

    -- Example:
    -- AttackName = {
    --     Id = "123456789",
    --     ReactionTime = 0.15,
    -- },

}

--==================================================
-- Special Animations
--==================================================

AnimationDatabase.Special = {
    ParriedAnimation = nil,
    StunnedAnimation = nil,
    ParryingAnimation = nil,
    ParryFailed = nil,
}

--==================================================
-- Lookup Cache
--==================================================

AnimationDatabase.ById = {}

--==================================================
-- Build Lookup
--==================================================

function AnimationDatabase:Initialize()
    table.clear(self.ById)

    for name, data in pairs(self.Animations) do
        if data.Id then
            self.ById[tostring(data.Id)] = {
                Name = name,
                Id = data.Id,
                ReactionTime = data.ReactionTime,
            }
        end
    end
end

--==================================================
-- Get Animation
--==================================================

function AnimationDatabase:Get(animationId)
    if not animationId then
        return nil
    end

    return self.ById[tostring(animationId)]
end

--==================================================
-- Get Reaction Time
--==================================================

function AnimationDatabase:GetReactionTime(animationId)
    local animation = self:Get(animationId)

    if not animation then
        return nil
    end

    return animation.ReactionTime
end

--==================================================
-- Check Animation
--==================================================

function AnimationDatabase:Has(animationId)
    return self:Get(animationId) ~= nil
end

return AnimationDatabase
