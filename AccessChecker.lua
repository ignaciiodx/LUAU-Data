-- Name: AccessCheker
-- Version: 1.4
-- Scripted By: IgnaciioDX

-- Services --

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Teams = game:GetService("Teams")

--Instances --

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder", ReplicatedStorage)
	Remotes.Name = "Remotes"
end
local Modules = ServerScriptService:FindFirstChild("Modules")
if not Modules then
	Modules = Instance.new("Folder", ServerScriptService)
	Modules.Name = "Modules"
end
local ReplicatedModules = ReplicatedStorage:FindFirstChild("Modules")
if not ReplicatedModules then
	ReplicatedModules = Instance.new("Folder", ReplicatedStorage)
	ReplicatedModules.Name = "Modules"
end

-- Modules --

local sStorage = require(Modules.Storage)
local GamepassModule = require(script.GamepassModule)

-- Variables --

local GlobalPlayerData = sStorage.PlayerData

local module = {}

module.DeveloperBypass = {

	Ranks = {};
	Users = {1765324749};
}

module.AdminBypass = {

	Ranks = {};
	Users = {1765324749, 4746316933};
}


export type PlayerData = {
	
	Credits: number;
	Sabers: {GenericDataValue};
	Crystals: {GenericDataValue};
	ForcePowers: {GenericDataValue}
}

export type GenericDataValue = {
	
	Expiration: string;
	By: string;
	Date: string
}

export type loadout = {

	Price: number;
	Tools: {Tool};
	Gamepasses: {number};
	Groups: {
		[number]: {
			
			MinRank: number;
			ExemptedRanks: {number};
			TeamExclusive: {Team};
			BypassRank: number;
			BypassExemptions: {number}
			
		}
	};
	Role: string
}

local Codes = {
	
	[1] = "Group Access";
	[2] = "Data Access";
	[3] = "Developer Access";
	[4] = "Elevated Group Access";
	[5] = "Free";
	[6] = "Gamepass Access";
	[7] = "Administrator Access";
}

-- Local Functions & Functions--


function module.isValidDateFormat(dateStr)

	return type(dateStr) == "string" and dateStr:match("^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d$") ~= nil
end


function module.ReturnHighestDate(Date1, Date2)
	
	if (not module.isValidDateFormat(Date1) and Date1 ~= "Never") or (not module.isValidDateFormat(Date2) and Date2 ~= "Never") then error(`[AccessChecker] ReturnHighestDate: Cannot compare dates, expected dates, got {Date1}, {Date2}.`) end
	
	if Date1 == "Never" then
		return Date1
	elseif Date2 == "Never" then
		return Date2
	elseif Date1 > Date2 then
		return Date1
	else
		return Date2
	end
end

function module.IsHigherDate(Date1, Date2)
	if (not module.isValidDateFormat(Date1) and Date1 ~= "Never") or (not module.isValidDateFormat(Date2) and Date2 ~= "Never") then error(`[AccessChecker] IsHigherDate: Cannot compare dates, expected dates, got {Date1}, {Date2}.`) end
	
	return Date1 == module.ReturnHighestDate(Date1, Date2)
	
end

function module.IsLowerDate(Date1, Date2)
	if (not module.isValidDateFormat(Date1) and Date1 ~= "Never") or (not module.isValidDateFormat(Date2) and Date2 ~= "Never") then error(`[AccessChecker] IsLowerDate: Cannot compare dates, expected dates, got {Date1}, {Date2}.`) end
	
	
	
	return Date2 == module.ReturnHighestDate(Date1, Date2)

end

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

function module.GetIDFromName(Name: string)

	local id = 0

	local _t = nil
	local attemps = 0

	local function Rename()

		local s,e = pcall(function()

			_t = Players:GetUserIdFromNameAsync(Name)

		end)

		if s then

			id = _t

		else

			if attemps < 1 then

				attemps += 1

				task.wait(.5)

				Rename()

			end

		end

	end

	Rename()


	return id
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

function module.PlayerHasTeamAccess(Player: Player, TeamName: string)
	
	if typeof(Player) ~= "Instance" or Player.ClassName ~= "Player" then error(`[AccessChecker] PlayerHasTeamAccess: Expected Player, got {Player}.`) end

	if not Teams:FindFirstChild(TeamName) then error(`[AccessChecker] PlayerHasTeamAccess: {Player.Name}:{Player.UserId} has attempted to summon an unexistent team: {TeamName}.`) end
	
	local TeamObjectime = Teams:FindFirstChild(TeamName)
	
	local group = TeamObjectime:FindFirstChild("Group") :: IntValue
	local rank = group and group:FindFirstChild("Rank") :: IntValue
	
	local IsInGroup = group and Player:IsInGroup(group.Value)
	local PlayerRank = group and Player:GetRankInGroup(group.Value)
	
	if group then
		
		if rank then
			
			return PlayerRank >= rank.Value and Codes[1]
			
		else
			
			return IsInGroup and Codes[1] or false
			
		end
		
	end
	
	if module.HasDeveloperAccess(Player.UserId) then return Codes[3] end
	
	return false
	
	
end

function module.UserOwnsGamepass(PlayerID: number, GamepassID: number)
	
	local HasGamepass = false
	
	local attemps = 0
	
	local v: boolean = nil
	
	local function CheckGamepass()
		
		local s,e = pcall(function()
			
			v = MarketplaceService:UserOwnsGamePassAsync(PlayerID, GamepassID)
			
		end)
		
		if s then
			
			HasGamepass = v
			
		else
			attemps += 1
			
			if attemps < 5 then
				
				task.wait(.5)
				
				CheckGamepass()
				
			end
			
			
		end
		
	end
	
	CheckGamepass()
	
	return HasGamepass
	
end

function module.HasDeveloperAccess(PlayerID: number)
	if not module.IsNumberAPlayerId(PlayerID) then error(`[AccessChecker] HasDeveloperAccess: Expected UserID, got {PlayerID}.`) end
	
	local player = module.GetPlayer(PlayerID)
	
	if player then
		
		for _, v in module.DeveloperBypass.Ranks do

			local group, rank = table.unpack(v:split(":"))
			
			group = tonumber(group)
			rank = tonumber(rank)

			if not player:IsInGroup(group) then continue end

			local _rank = player:GetRankInGroup(group)

			if rank == _rank then return Codes[3] end		
		end
		
	end
	
	if table.find(module.DeveloperBypass.Users, PlayerID) then return Codes[3] end


	return false
	
end

function module.HasAdminAccess(PlayerID: number)
	if not module.IsNumberAPlayerId(PlayerID) then error(`[AccessChecker] HasDeveloperAccess: Expected UserID, got {PlayerID}.`) end

	local player = module.GetPlayer(PlayerID)

	if player then

		for _, v in module.AdminBypass.Ranks do

			local group, rank = table.unpack(v:split(":"))

			group = tonumber(group)
			rank = tonumber(rank)

			if not player:IsInGroup(group) then continue end

			local _rank = player:GetRankInGroup(group)

			if rank == _rank then return Codes[3] end		
		end

	end

	if table.find(module.AdminBypass.Users, PlayerID) then return Codes[7] end


	return false

end


-- Connections --

return module
