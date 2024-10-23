--Name: DataHelper
-- Version: 2.0
-- Author: IgnaciioDX

-- Services --

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Instances --

local modules = ServerScriptService.Modules

-- Modules --

-- Variables --

local module = {}

module.CurrentDataStore = DataStoreService:GetDataStore("Legacy_N1")
module.DataSkeleton = {
	
}

local mStorage = require(modules.Storage)
local dataStorage = mStorage.PlayerData
local TimeToSave = 180

-- Local Functions & Functions --

function module.GetCurrentDate()

	return os.date("!%Y-%m-%d %H:%M:%S")

end

function module.IsNumberAPlayerId(n: number)

	n = tonumber(n) or 0

	local attempts = 0

	local check = false

	local a = nil

	local function CheckID()

		local s, e = pcall(function()

			a = Players:GetNameFromUserIdAsync(n)


		end)

		if s then

			check = true

		elseif e then

			if attempts < 2 then

				attempts += 1

				task.wait(1)

				CheckID()

			end

		end

	end

	CheckID()

	return check



end

function module.GetNameFromUserID(ID: number)

	local name = "Unknown"

	local _t = nil
	local attemps = 0

	local function Rename()

		local s,e = pcall(function()

			_t = Players:GetNameFromUserIdAsync(ID)

		end)

		if s then

			name = _t

		else

			if attemps < 1 then

				attemps += 1

				task.wait(.5)

				Rename()

			end

		end

	end
	
	Rename()


	return name
end

function module.GetPlayer(ID: number)

	local name = nil

	local _t = nil
	local attemps = 0

	local function Rename()

		local s,e = pcall(function()

			_t = Players:GetPlayerByUserId(ID)

		end)

		if s then

			name = _t

		else

			if attemps < 1 then

				attemps += 1

				task.wait(.5)

				Rename()

			end

		end

	end
	
	Rename()


	return name
end

function module.UpdateData(currentTable: {}, reference: {})
	for key, value in reference do
		if typeof(value) == "table" and not value.RemoveFromData then

			if not currentTable[key] then

				currentTable[key] = {}

			end

			module.UpdateData(currentTable[key], value)

		elseif typeof(value) == "table" and value.RemoveFromData then		

			currentTable[key] = nil

		elseif typeof(currentTable[key]) ~= typeof(value) then

			currentTable[key] = value

		end

	end

end

function module.RetrieveData(ID : number)
	if not ID or typeof(ID) ~= "number" then 
		error(`Invalid user ID given, expected number, got {ID}.`) 
	end
	local data
	local playerName

	pcall(function()
		playerName = Players:GetNameFromUserIdAsync(ID)
	end)

	playerName = playerName  or `NoName:ID({ID})`

	local s, e = pcall(function()
		data = module.CurrentDataStore:GetAsync(ID) 
	end)

	if e then
		error(`Failed to load data for {playerName}. {e}`)
	elseif s then
		print(`Succesfully loaded {playerName}'s data.`, data)
		return data
	end
end

function module.StoreData(ID: number, data: {})
	if not ID or typeof(ID) ~= "number" then 
		error(`Invalid user ID given, expected number, got {ID}.`) 
	end
	if not data or typeof(data) ~= "table" then
		error(`Invalid data, expected table, got {typeof(data)}, {data}`)
	end

	local playerName 

	pcall(function()
		playerName = Players:GetNameFromUserIdAsync(ID)
	end)

	playerName = playerName  or `NoName:ID({ID})`

	local s,e = pcall(function()
		module.CurrentDataStore:SetAsync(ID, data)
	end)

	if e then
		error(`Failed to save data for {playerName}, {e}`)
	elseif s then
		print(`Succesfully saved {playerName}'s data. `, data)
	end
	
end

function module.CorrectData(data: {})
	
	
	
	return data
end

function module.LoadData(ID: number)
	

	local playerData = nil
	local tries = 1

	local function loadData()
		local s, e = pcall(function()
			playerData = module.RetrieveData(ID)
		end)

		if e then
			tries += 1
			task.wait(3)
			if tries <= 3 then
				warn(`Reattempting to load data for {module.GetNameFromUserID(ID)}. Attempt {tries}/3. Error message: `, e)
				loadData()
			else
				error(`3 failed attempts to load data for " .. player.Name .. ". Aborting process. Error message: {e}`)
			end
		end
	end

	loadData()

	if typeof(playerData) ~= "table" then
		playerData = module.DataSkeleton
	end

	module.UpdateData(playerData, module.DataSkeleton)

	playerData = module.CorrectData(playerData)

	return playerData
	
end

function module.SaveData(ID: number, data)

	local tries = 1

	local name = module.GetNameFromUserID(ID)

	local function saveData()
		local s, e = pcall(function()
			module.StoreData(ID, data)
		end)

		if e then
			tries += 1
			task.wait(3)
			if tries <= 3 then
				warn(`Reattempting to save data for {name}. Attempt {tries}/3. Error message: `, e)
				saveData()
			else
				error(`3 failed attempts to save data for {name}. Aborting process. Error message: {e} `)
			end
		end
	end

	saveData()
end

function module.OverwriteData(ID: number, data: {}, upload: boolean)

	if dataStorage[ID] then
		dataStorage[ID] = data
	end

	if upload then

		module.SaveData()
		
	end
end

-- Connections

return module
