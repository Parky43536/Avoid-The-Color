local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Values = ReplicatedStorage.Values

local DataBase = ReplicatedStorage.Database
local ColorData = require(DataBase.ColorData)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))

local function countdown(value)
    Values.RoundTimer.Value = value

    while Values.RoundTimer.Value > 0 do
        task.wait(1)
        Values.RoundTimer.Value -= 1
    end
end

task.spawn(function()
    while true do
        Values.GameStatus.Value = "Intermission"
        countdown(General.IntermissionTimer)

        Values.GameStatus.Value = "Picking"
        --randomize the color of the map every very fast
        countdown(General.PickingTimer)

        --pick color
        Values.GameStatus.Value = "Picked"
        countdown(General.PickedTimer)
        task.wait(1)

        --initalize survivors
        Values.GameStatus.Value = "Round"

        --turn the bricks of the picked color into kill bricks
        --spawn coins?

        countdown(General.RoundTimer)

        --reward survivors
    end
end)