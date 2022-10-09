local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Values = ReplicatedStorage.Values
local Assets = ReplicatedStorage.Assets

local DataBase = ReplicatedStorage.Database
local ColorData = require(DataBase.ColorData)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))

--------------------------------------------

local Map = workspace.Map
local Corruption = game.Lighting.Corruption

local rng = Random.new()
local corruptedColorList = {}
local colorPartList = {}

--------------------------------------------

local function countdown(countdownTime)
    Values.RoundTimer.Value = countdownTime

    for i = 1 , countdownTime do
        task.wait(1)
        Values.RoundTimer.Value -= 1
    end
end

local colorList = {}
local function pickcolor()
    if not next(colorList) then
        for key, value in pairs(ColorData) do
            table.insert(colorList, {key = key, value = value})
        end
    end

    local pickedColor
    for _ = 1 , General.TotalColors do
        pickedColor = colorList[rng:NextInteger(1, #colorList)].key

        if corruptedColorList[pickedColor] then
            pickedColor = false
        else
            break
        end
    end

    if pickedColor then
        Values.PickedColor.Value = pickedColor
    end
    return pickedColor
end

local savedColors = {}
local function getClosestColor(undefinedColor)
    if savedColors[undefinedColor] then
        return savedColors[undefinedColor]
    end

    local closest

    local function compareToClosest(newColor)
        local function runColor(color)
            local colorVal = ColorData[color].Color
            local avg = math.abs(colorVal.r - undefinedColor.r) + math.abs(colorVal.g - undefinedColor.g) + math.abs(colorVal.b - undefinedColor.b)

            if ColorData[color].SubColors then
                for _, subColor in pairs(ColorData[color].SubColors) do
                    local subAvg = math.abs(subColor.r - undefinedColor.r) + math.abs(subColor.g - undefinedColor.g) + math.abs(subColor.b - undefinedColor.b)
                    if subAvg < avg then
                        avg = subAvg
                    end
                end
            end

            return avg
        end

        local avg1 = runColor(closest)
        local avg2 = runColor(newColor)

        if avg1 < avg2 then
            return closest
        else
            return newColor
        end
    end

    for color, value in pairs(ColorData) do
        if not closest then
            closest = color
        else
            closest = compareToClosest(color)
        end
    end

    savedColors[undefinedColor] = closest
    return closest
end

--------------------------------------------

local function corruptMap(color, toggle)
    if not colorPartList[color] then
        colorPartList[color] = {}

        for _, part in pairs(Map:GetDescendants()) do
            if part:IsA("BasePart") and getClosestColor(part.Color) == color then
                table.insert(colorPartList[color], part)
            end
        end
    end

    for _, part in pairs(colorPartList[color]) do
        if toggle then
            local corruptionParticles = Assets.Corruption:Clone()
            for _, particles in pairs(corruptionParticles:GetChildren()) do
                particles.Rate = part.Size.Magnitude / 10 + rng:NextNumber(-0.05, 0.05)
                particles.Parent = part
            end
            corruptionParticles:Destroy()
        else
            for _, particles in pairs(part:GetChildren()) do
                if particles:IsA("ParticleEmitter") then
                    particles:Destroy()
                end
            end
        end
    end

    if toggle then
        local x = Map:GetPivot().X + rng:NextInteger(-Map:GetExtentsSize().X/2, Map:GetExtentsSize().X/2)
        local z = Map:GetPivot().Z + rng:NextInteger(-Map:GetExtentsSize().Z/2, Map:GetExtentsSize().Z/2)
        local pos = Vector3.new(x, 10000, z)

        local RayOrigin = pos
        local RayDirection = Vector3.new(0, -10000, 0)

        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Blacklist
        --Params.FilterDescendantsInstances = {}

        local Result = workspace:Raycast(RayOrigin, RayDirection, Params)

        if Result then
            local corrupter = Assets.Corrupter:Clone()
            corrupter:PivotTo(CFrame.new(Result.Position))
            corrupter.Color1.Color = ColorData[color].Color
            corrupter.Color2.Color = ColorData[color].Color
            corrupter.Main.ProximityPrompt.ObjectText = "Cleanse " .. color
            corrupter.Parent = workspace
        end
    end
end

local function corruptLighting()
    local totalCorrupted = 0
    for _,_ in pairs(corruptedColorList) do
        totalCorrupted += 1
    end

    Corruption.Contrast = (General.MaxContrast/General.TotalColors) * totalCorrupted
    Corruption.Saturation = (General.MaxSaturation/General.TotalColors) * totalCorrupted
end

local function corrupt(color, toggle)
    if toggle then
        if not corruptedColorList[color] then
            corruptedColorList[color] = true

            corruptMap(color, toggle)
        end
    else
        if corruptedColorList[color] then
            corruptedColorList[color] = nil

            corruptMap(color, toggle)
        end
    end

    corruptLighting()
end

--------------------------------------------

task.spawn(function()
    while true do
        Values.GameStatus.Value = "Picking"
        countdown(General.PickingTimer)

        local pickedColor = pickcolor()
        if pickedColor then
            Values.GameStatus.Value = "Picked"
            countdown(General.PickedTimer)

            Values.GameStatus.Value = "Round"

            corrupt(pickedColor, true)
        else
            --display all colors are corrupted
        end

        countdown(General.RoundTimer)
    end

    --enemy spawner on corrupted parts
end)