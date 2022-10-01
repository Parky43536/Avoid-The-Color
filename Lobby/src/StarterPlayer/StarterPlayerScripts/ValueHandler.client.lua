local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Values = ReplicatedStorage:WaitForChild("Values")

local DataBase = ReplicatedStorage.Database
local ColorData = require(DataBase.ColorData)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameUi = PlayerGui:WaitForChild("GameUi")

-------------------------

local function toHMS(s)
    return string.format("%01i:%02i", s/60%60, s%60)
end

local function updateGameLabel()
    if Values.GameStatus.Value == "Round" then
        GameUi.GameLabel.Text = 'Avoid the color <font color="rgb('.. ColorData[Values.CurrentColor.Value].ColorMap ..')"><b>' .. Values.CurrentColor.Value .. '</b></font> (' .. toHMS(Values.RoundTimer.Value) .. ')'
    elseif Values.GameStatus.Value == "Picked" then
        GameUi.GameLabel.Text = 'The color is <font color="rgb('.. ColorData[Values.CurrentColor.Value].ColorMap ..')"><b>' .. Values.CurrentColor.Value .. '</b></font> (' .. toHMS(Values.RoundTimer.Value) .. ')'
    elseif Values.GameStatus.Value == "Picking" then
        GameUi.GameLabel.Text = 'Picking a new color... (' .. toHMS(Values.RoundTimer.Value) .. ')'
    elseif Values.GameStatus.Value == "Intermission" then
        GameUi.GameLabel.Text = 'Intermission... (' .. toHMS(Values.RoundTimer.Value) .. ')'
    end
end

Values.RoundTimer.Changed:Connect(function()
	updateGameLabel()
end)

Values.CurrentColor.Changed:Connect(function()
	updateGameLabel()
end)

Values.GameStatus.Changed:Connect(function()
	updateGameLabel()
end)

updateGameLabel()




