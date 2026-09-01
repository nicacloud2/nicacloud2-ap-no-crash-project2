--// TargetManager.lua
--// Gakuran Target Management Module

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Config = require(script.Parent.Config)

local TargetManager = {}

--------------------------------------------------
--// State
--------------------------------------------------

TargetManager.State = nil
TargetManager.TargetCharacters = {}
TargetManager.CurrentTarget = nil
TargetManager.CurrentTargetIndex = 1

--------------------------------------------------
--// Initialize
--------------------------------------------------

function TargetManager:Initialize(State)
    self.State = State
end

--------------------------------------------------
--// Get All Folders
--------------------------------------------------

function TargetManager:GetAllFoldersInWorkspace()
    local folders = {}

    for _, object in ipairs(workspace:GetChildren()) do
        if object:IsA("Folder") then
            table.insert(folders, object)
        end
    end

    return folders
end

--------------------------------------------------
--// Get Characters From Folder
--------------------------------------------------

function TargetManager:GetAllCharactersInFolder(folder)
    local characters = {}

    if not folder then
        return characters
    end

    for _, object in ipairs(folder:GetChildren()) do
        if object:IsA("Model") then
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local root = object:FindFirstChild("HumanoidRootPart")

            if humanoid and root then
                table.insert(characters, object)
            end
        end
    end

    return characters
end

--------------------------------------------------
--// Is Valid Character
--------------------------------------------------

function TargetManager:IsValidCharacter(character)
    if not character then
        return false
    end

    if character == LocalPlayer.Character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return false
    end

    if humanoid.Health <= 0 then
        return false
    end

    return true
end

--------------------------------------------------
--// Get Root Part
--------------------------------------------------

function TargetManager:GetRoot(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
end

--------------------------------------------------
--// Get Distance
--------------------------------------------------

function TargetManager:GetDistance(character)
    local localCharacter = LocalPlayer.Character

    if not localCharacter then
        return math.huge
    end

    local localRoot = self:GetRoot(localCharacter)
    local targetRoot = self:GetRoot(character)

    if not localRoot or not targetRoot then
        return math.huge
    end

    return (localRoot.Position - targetRoot.Position).Magnitude
end

--------------------------------------------------
--// Check Range
--------------------------------------------------

function TargetManager:IsInRange(character, maxDistance)
    maxDistance = maxDistance
        or Config.Targeting.MaxDistance

    return self:GetDistance(character) <= maxDistance
end

--------------------------------------------------
--// Find Characters
--------------------------------------------------

function TargetManager:FindCharacters()
    local characters = {}

    --------------------------------------------------
    -- Search workspace
    --------------------------------------------------

    for _, object in ipairs(workspace:GetDescendants()) do

        if object:IsA("Model") and self:IsValidCharacter(object) then

            if not table.find(characters, object) then
                table.insert(characters, object)
            end

        end
    end

    --------------------------------------------------
    -- Filter by distance
    --------------------------------------------------

    local filtered = {}

    for _, character in ipairs(characters) do
        if self:IsInRange(character) then
            table.insert(filtered, character)
        end
    end

    return filtered
end

--------------------------------------------------
--// Refresh Targets
--------------------------------------------------

function TargetManager:Refresh()
    local previousTarget = self.CurrentTarget

    self.TargetCharacters = self:FindCharacters()

    --------------------------------------------------
    -- Sort by distance
    --------------------------------------------------

    table.sort(self.TargetCharacters, function(a, b)
        return self:GetDistance(a) < self:GetDistance(b)
    end)

    --------------------------------------------------
    -- Keep Current Target
    --------------------------------------------------

    if previousTarget
        and table.find(self.TargetCharacters, previousTarget)
    then
        self.CurrentTarget = previousTarget

        local index = table.find(
            self.TargetCharacters,
            previousTarget
        )

        if index then
            self.CurrentTargetIndex = index
        end

        return
    end

    --------------------------------------------------
    -- Select First Target
    --------------------------------------------------

    self.CurrentTargetIndex = 1

    if #self.TargetCharacters > 0 then
        self.CurrentTarget = self.TargetCharacters[1]
    else
        self.CurrentTarget = nil
    end
end

--------------------------------------------------
--// Get Current Target
--------------------------------------------------

function TargetManager:GetCurrentTarget()
    if self.CurrentTarget
        and self:IsValidCharacter(self.CurrentTarget)
        and self:IsInRange(self.CurrentTarget)
    then
        return self.CurrentTarget
    end

    self:Refresh()

    return self.CurrentTarget
end

--------------------------------------------------
--// Set Target
--------------------------------------------------

function TargetManager:SetTarget(character)
    if not self:IsValidCharacter(character) then
        return false
    end

    if not self:IsInRange(character) then
        return false
    end

    self.CurrentTarget = character

    local index = table.find(
        self.TargetCharacters,
        character
    )

    if index then
        self.CurrentTargetIndex = index
    end

    if self.OnTargetChanged then
        self.OnTargetChanged(character)
    end

    return true
end

--------------------------------------------------
--// Cycle Target
--------------------------------------------------

function TargetManager:CycleTarget(direction)
    direction = direction or 1

    self:Refresh()

    local count = #self.TargetCharacters

    if count == 0 then
        self.CurrentTarget = nil
        return nil
    end

    --------------------------------------------------
    -- Calculate New Index
    --------------------------------------------------

    local newIndex =
        self.CurrentTargetIndex + direction

    if newIndex > count then
        newIndex = 1
    elseif newIndex < 1 then
        newIndex = count
    end

    self.CurrentTargetIndex = newIndex

    local target = self.TargetCharacters[newIndex]

    self:SetTarget(target)

    return target
end

--------------------------------------------------
--// Get All Targets
--------------------------------------------------

function TargetManager:GetTargets()
    return self.TargetCharacters
end

--------------------------------------------------
--// Get Target Count
--------------------------------------------------

function TargetManager:GetTargetCount()
    return #self.TargetCharacters
end

--------------------------------------------------
--// Has Target
--------------------------------------------------

function TargetManager:HasTarget()
    return self:GetCurrentTarget() ~= nil
end

--------------------------------------------------
--// Remove Target
--------------------------------------------------

function TargetManager:RemoveTarget(character)
    local index = table.find(
        self.TargetCharacters,
        character
    )

    if not index then
        return
    end

    table.remove(
        self.TargetCharacters,
        index
    )

    if self.CurrentTarget == character then

        self.CurrentTarget = nil

        if #self.TargetCharacters > 0 then
            self.CurrentTargetIndex =
                math.clamp(
                    self.CurrentTargetIndex,
                    1,
                    #self.TargetCharacters
                )

            self.CurrentTarget =
                self.TargetCharacters[
                    self.CurrentTargetIndex
                ]
        else
            self.CurrentTargetIndex = 1
        end

        if self.OnTargetChanged then
            self.OnTargetChanged(
                self.CurrentTarget
            )
        end
    end
end

--------------------------------------------------
--// Clear Targets
--------------------------------------------------

function TargetManager:Clear()
    self.TargetCharacters = {}
    self.CurrentTarget = nil
    self.CurrentTargetIndex = 1

    if self.OnTargetChanged then
        self.OnTargetChanged(nil)
    end
end

--------------------------------------------------
--// Get Target Player
--------------------------------------------------

function TargetManager:GetTargetPlayer(character)
    character = character or self.CurrentTarget

    if not character then
        return nil
    end

    return Players:GetPlayerFromCharacter(character)
end

--------------------------------------------------
--// Get Target Humanoid
--------------------------------------------------

function TargetManager:GetHumanoid(character)
    character = character or self.CurrentTarget

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------
--// Get Target Health
--------------------------------------------------

function TargetManager:GetHealth(character)
    local humanoid = self:GetHumanoid(character)

    if not humanoid then
        return 0
    end

    return humanoid.Health
end

--------------------------------------------------
--// Get Target Health Percentage
--------------------------------------------------

function TargetManager:GetHealthPercentage(character)
    local humanoid = self:GetHumanoid(character)

    if not humanoid or humanoid.MaxHealth <= 0 then
        return 0
    end

    return humanoid.Health / humanoid.MaxHealth
end

--------------------------------------------------
--// Automatic Refresh Loop
--------------------------------------------------

function TargetManager:Start()
    if self.Running then
        return
    end

    self.Running = true

    task.spawn(function()
        while self.Running do

            if Config.Enabled then
                self:Refresh()
            end

            task.wait(0.25)
        end
    end)
end

--------------------------------------------------
--// Stop
--------------------------------------------------

function TargetManager:Stop()
    self.Running = false
end

return TargetManager
