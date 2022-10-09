local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataBase = ReplicatedStorage.Database
local ColorData = require(DataBase.ColorData)

local General = {}

General.RoundTimer = 5
General.PickingTimer = 5
General.PickedTimer = 5

General.MaxContrast = 1
General.MaxSaturation = -1

General.TotalColors = 0
for _,_ in pairs(ColorData) do
    General.TotalColors += 1
end

return General