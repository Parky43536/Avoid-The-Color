local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Values = ReplicatedStorage.Values
local Assets = ReplicatedStorage.Assets

local DataBase = ReplicatedStorage.Database
local ColorData = require(DataBase.ColorData)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))

local Scripts = ServerScriptService:WaitForChild("Scripts")
local EnemyService = require(Scripts:WaitForChild("EnemyService"))

--Variables------------------------------------------

local Map = workspace.Map
local Corruption = game.Lighting.Corruption

local rng = Random.new()
local corruptedColorList = {}

--Corruption------------------------------------------

local corrupt

local colorList = {}
local function pickcolor()
    if not next(colorList) then
        for color, _ in pairs(ColorData) do
            table.insert(colorList, color)
        end
    end

    local pickedColor
    for _ = 1 , General.TotalColors do
        pickedColor = colorList[rng:NextInteger(1, #colorList)]

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

local function corruptMap(color, toggle)
    for _, part in pairs(CollectionService:GetTagged(color)) do
        if toggle then
            part.Color = part.Color:Lerp(Color3.fromRGB(0, 0, 0), 0.25)

            local corruptionEffects = Assets.Corruption:Clone()
            for _, corruptionEffect in pairs(corruptionEffects:GetChildren()) do
                if corruptionEffect:IsA("ParticleEmitter") then
                    corruptionEffect.Rate = part.Size.Magnitude / 10 + rng:NextNumber(-0.05, 0.05)
                    corruptionEffect.Parent = part
                elseif corruptionEffect:IsA("Texture") then
                    corruptionEffect.Parent = part
                end
            end

            CollectionService:AddTag(part, "Corrupted")
            corruptionEffects:Destroy()
        else
            for _, corruptionEffect in pairs(part:GetChildren()) do
                if corruptionEffect:IsA("ParticleEmitter") or corruptionEffect:IsA("Texture") then
                    corruptionEffect:Destroy()
                end

                CollectionService:RemoveTag(part, "Corrupted")
            end
        end
    end

    if toggle then
        local rmp = General:RandomMapPosition()
        if rmp then
            local corrupter = Assets.Corrupter:Clone()
            corrupter:PivotTo(CFrame.new(rmp.Position))
            corrupter.Color1.Color = ColorData[color].Color
            corrupter.Color2.Color = ColorData[color].Color
            corrupter.Main.ProximityPrompt.ActionText = "Free " .. color
            corrupter.Parent = workspace

            local proximityConnection
            proximityConnection = ProximityPromptService.PromptTriggered:Connect(function(promptObject, player)
                if promptObject == corrupter.Main.ProximityPrompt then
                    proximityConnection:Disconnect()
                    corrupter:Destroy()
                    corrupt(color, false)
                end
            end)
        end
    end
end

corrupt = function(color, toggle)
    if toggle then
        if not corruptedColorList[color] then
            corruptedColorList[color] = true
            Values.Corruption.Value += 1

            corruptMap(color, toggle)
        end
    else
        if corruptedColorList[color] then
            corruptedColorList[color] = nil
            Values.Corruption.Value -= 1

            corruptMap(color, toggle)
        end
    end

    Corruption.Contrast = (General.MaxContrast/General.TotalColors) * Values.Corruption.Value
    Corruption.Saturation = (General.MaxSaturation/General.TotalColors) * Values.Corruption.Value
end

--Main Loop------------------------------------------

while true do
    Values.GameStatus.Value = "Picking"
    General:Countdown(General.PickingTimer)

    local pickedColor = pickcolor()
    if pickedColor then
        Values.GameStatus.Value = "Picked"
        General:Countdown(General.PickedTimer)

        Values.GameStatus.Value = "Round"

        corrupt(pickedColor, true)
    else
        --kill everyone after some time if all the colors are still corrupted
    end

    General:Countdown(General.RoundTimer)
end

