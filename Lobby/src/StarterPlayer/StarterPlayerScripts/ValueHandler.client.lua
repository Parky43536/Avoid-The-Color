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
    if Values.GameStatus.Value == "Picked" then
        GameUi.TopBar.Status.Text = '<font color="rgb('.. ColorData[Values.PickedColor.Value].ColorMap ..')"><b>' .. Values.PickedColor.Value .. '</b></font> is being corrupted'
    elseif Values.GameStatus.Value == "Picking" then
        GameUi.TopBar.Status.Text = 'Corrupting a color...'
    elseif Values.GameStatus.Value == "Round" then
        GameUi.TopBar.Status.Text = 'Survive the corruption'
    end

    GameUi.TopBar.Timer.Text = toHMS(Values.RoundTimer.Value)
end

Values.RoundTimer.Changed:Connect(function()
	updateGameLabel()
end)

Values.PickedColor.Changed:Connect(function()
	updateGameLabel()
end)

Values.GameStatus.Changed:Connect(function()
	updateGameLabel()
end)

updateGameLabel()




