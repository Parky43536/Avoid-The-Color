local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))

local rng = Random.new()

local EnemyService = {}

EnemyService.Enemies = {} 

function EnemyService:NewEnemy()
    local rmp = General:RandomCorruptedPosition()
    if rmp then
        local enemy = Assets.Enemy:Clone()
        enemy:PivotTo(CFrame.new(rmp.Position))
        enemy.Parent = workspace
        table.insert(EnemyService.Enemies, enemy)
    end
end

function EnemyService:MoveEnemies()
    for _, enemy in pairs(EnemyService.Enemies) do
        local target = General:GetClosestCharacter(enemy.PrimaryPart.Position)
        enemy.Humanoid:MoveTo(target.PrimaryPart.Position, target.PrimaryPart)

        if target.PrimaryPart.Position.Y > enemy.PrimaryPart.Position.Y then
            enemy.Humanoid.Jump = true
        end
    end
end

--enemy spawner
task.spawn(function()
    while true do
        task.wait(rng:NextInteger(General.NextEnemyMin, General.NextEnemyMax))
        EnemyService:NewEnemy()
    end
end)

--enemy positioner
task.spawn(function()
    while true do
        task.wait(2)
        EnemyService:MoveEnemies()
    end
end)

return EnemyService