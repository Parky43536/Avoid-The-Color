local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Values = ReplicatedStorage.Values

local DataBase = ReplicatedStorage.Database
local ColorData = require(DataBase.ColorData)

local Map = workspace.Map
local rng = Random.new()

local General = {}

General.RoundTimer = 5
General.PickingTimer = 5
General.PickedTimer = 5

General.MaxContrast = 1
General.MaxSaturation = -1

General.NextEnemyMin = 5
General.NextEnemyMax = 10

General.TotalColors = 0
for _,_ in pairs(ColorData) do
    General.TotalColors += 1
end


--Variables------------------------------------------

function General:Countdown(countdownTime)
    Values.RoundTimer.Value = countdownTime

    for i = 1 , countdownTime do
        task.wait(1)
        Values.RoundTimer.Value -= 1
    end
end

local savedColors = {}
function General:GetClosestColor(undefinedColor)
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

function General:GetBoundingBox(model, orientation)
	if typeof(model) == "Instance" then
		model = model:GetDescendants()
	end
	if not orientation then
		orientation = CFrame.new()
	end
	local abs = math.abs
	local inf = math.huge

	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf

	for _, obj in pairs(model) do
		if obj:IsA("BasePart") then
			local cf = obj.CFrame
			cf = orientation:toObjectSpace(cf)
			local size = obj.Size
			local sx, sy, sz = size.X, size.Y, size.Z

			local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components()

			local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz)
			local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz)
			local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz)

			if minx > x - wsx then
				minx = x - wsx
			end
			if miny > y - wsy then
				miny = y - wsy
			end
			if minz > z - wsz then
				minz = z - wsz
			end

			if maxx < x + wsx then
				maxx = x + wsx
			end
			if maxy < y + wsy then
				maxy = y + wsy
			end
			if maxz < z + wsz then
				maxz = z + wsz
			end
		end
	end

	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	local omiddle = (omax+omin)/2
	local wCf = orientation - orientation.p + orientation:pointToWorldSpace(omiddle)
	local size = (omax-omin)

    --[[local part = Instance.new("Part")
    part.CanCollide = false
    part.Transparency = 0.5
    part.Size = size
    part.CFrame = wCf
    part.Anchored = true
    part.Parent = workspace]]

	return wCf, size
end

function General:GetClosestCharacter(pos)
    local players = Players:GetPlayers()
    local nearesttarget
    local maxDistance = 5000

    for _, player in pairs(players) do
        if player.Character then
            local target = player.Character
            local distance = (pos - target.PrimaryPart.Position).Magnitude

            if distance < maxDistance then
                nearesttarget = target
                maxDistance = distance
            end
        end
    end

    return nearesttarget
end

function General:RandomMapPosition()
    local x = Map:GetPivot().X + rng:NextInteger(-Map:GetExtentsSize().X/2, Map:GetExtentsSize().X/2)
    local z = Map:GetPivot().Z + rng:NextInteger(-Map:GetExtentsSize().Z/2, Map:GetExtentsSize().Z/2)
    local pos = Vector3.new(x, 10000, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -10000, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = {}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

function General:RandomCorruptedPosition()
    local corruptedList = {}
    for _, part in pairs(CollectionService:GetTagged("Corrupted")) do
        table.insert(corruptedList, part)
    end

    local randomPart = corruptedList[rng:NextInteger(1, #corruptedList)]
    local bbCFrame, bbSize = General:GetBoundingBox({randomPart})

    local x = bbCFrame.Position.X + rng:NextInteger(-bbSize.X/2, bbSize.X/2)
    local z = bbCFrame.Position.Z + rng:NextInteger(-bbSize.Z/2, bbSize.Z/2)
    local pos = Vector3.new(x, bbCFrame.Position.Y + bbSize.Y/2 + 2, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -10000, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = {}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    if Result and CollectionService:HasTag(Result.Instance, "Corrupted") then
        return Result
    end

    return false
end

for _, part in pairs(Map:GetDescendants()) do
    if part:IsA("BasePart") then
        CollectionService:AddTag(part, General:GetClosestColor(part.Color))
    end
end

return General