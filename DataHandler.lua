--Name: DataHandler
-- Version: 2.0
-- Author: IgnaciioDX

-- Services --

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Instances --

local modules = ServerScriptService:FindFirstChild("Modules") :: Folder
local Remotes = ReplicatedStorage:FindFirstChild("Remotes") :: Folder

if not modules then
	modules = Instance.new("Folder", ServerScriptService)
	modules.Name = "Modules"
end

if not Remotes then
	Remotes = Instance.new("Folder", ReplicatedStorage)
	Remotes.Name = "Remotes"
end

local DataRequestFunction = Remotes:FindFirstChild("DataRequest")

if not DataRequestFunction then
	DataRequestFunction = Instance.new("RemoteFunction", Remotes)
	DataRequestFunction.Name = "DataRequest"
end
local DataWriteRemote = Remotes:FindFirstChild("DataOverwrite")
if not DataWriteRemote then
	DataWriteRemote = Instance.new("RemoteEvent", Remotes)
	DataWriteRemote.Name = "DataOverwrite"
end

-- Modules --
if not modules:FindFirstChild("Storage") then error(`Missing the Script Storage in the modules folder. Please create a ModuleScript in ServerScriptService.Modules named "Storage".`) end
local mStorage = require(modules.Storage)
local dataStorage = mStorage.PlayerData

if not dataStorage then
	mStorage.PlayerData = {}
	dataStorage = mStorage.PlayerData	
end
local Helper = require(script.DataHelper)
local AccessModule = require(modules.AccessChecker)

if not AccessModule then error(`[DataHandler]: FATAL ERROR! Missing the AccessModule from IgnaciioDX.`) end

-- Variables --

local sClock = os.clock()

local SavingCache = {}

-- Local Functions & Functions --

local function OnPlayerAdded(Player: Player)
	
	Player:SetAttribute("DataLoaded", false)
	
	local ID = Player.UserId
	local Username = Player.Name
	
	if script:GetAttribute("DataLoading") == true then
		
		local data
		
		local s,e = pcall(function()

			data = Helper.LoadData(ID)

		end)
		
		if s then
			
			dataStorage[ID] = data
			
		else
			
			Player:Kick(`There was an error loading your data, if you see this error again, please contact a developer. Error message {e}.`)
			
		end
		
	else
		
		dataStorage[ID] = Helper.DataSkeleton
		
	end
	
	Player:SetAttribute("DataLoaded", true)
end

local function OnPlayerLeft(Player: Player)
	
	local ID = Player.UserId
	local Username = Player.Name
	
	print(`Remaining players: {#Players:GetPlayers()}`)
	
	if script:GetAttribute("DataSaving") == true then
		
		SavingCache[ID] = true
		
		local s,e = pcall(function()
			
			Helper.SaveData(ID, dataStorage[ID])
			
		end)
		
	end
	
	SavingCache[ID] = nil
	dataStorage[ID] = nil
	
end

local function SaveServerData()
	

	if script:GetAttribute("DataSaving") == false then return end
	
	for id, data in dataStorage do
		
		if SavingCache[id] then continue end
		pcall(function()
		
			Helper.SaveData(id, data)
			
		end)
		task.wait(0.75)
		
	end
	
end

local function OnDataReadRequest(ID)
	
	if not ID then return end
	
	if dataStorage[ID] then
		
		return dataStorage[ID]
		
	end
	
	local data
	
	local s,e = pcall(function()
		
		data = Helper.LoadData(ID)
		
	end)
	
	return s and data or Helper.DataSkeleton
	
end

local function OnDataWriteRequest(WriterID: number, ID: number, data: {}, upload: boolean)
	
	if not tonumber(WriterID) then error(`[DataHandler] OnDataWriteRequest: Invalid WritedID given, expected UserID, got {typeof(WriterID)}, {WriterID}.`) end
	if not tonumber(ID) then error(`[DataHandler] OnDataWriteRequest: Invalid ID given, expected UserID, got {typeof(ID)}, {ID}.`) end
	if typeof(data) ~= "table" then error(`[DataHandler] OnDataWriteRequest: Invalid data given, expected table, got {typeof(ID)}, {ID}.`) end
	upload = typeof(upload) == "boolean" and upload or false
	if not AccessModule.HasDeveloperAccess(WriterID) then
		
		warn(`{Helper.GetNameFromUserID(ID)}:{ID} has attempted to do an unauthorized data overwrite.`)
		return
			
	end
	
	local s,e = pcall(function()
		
		Helper.OverwriteData(ID, dataStorage, upload)
		
	end)
	
	
	
end

-- Connections

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerLeft)
DataRequestFunction.OnServerInvoke = OnDataReadRequest()
DataWriteRemote.OnServerEvent:Connect(OnDataWriteRequest)
game:BindToClose(SaveServerData)

RunService.Heartbeat:Connect(function()
	
	if os.clock() - sClock < 180 then return end
	sClock = os.clock()
	
	SaveServerData()
	
end)
