-- Handles jail system
--By Hassan El-Sheikha

local Records = {}
local PermittedGroups = { -- [GroupId] = MinGroupRank
	[6231460] = 254, --Rome
	[5625423] = 2, -- UC
	[5625402] = 12, -- Prae
	[5944155] = 248,
}

local immune = { 
	-- userid
	48612932,

	--90787711,
	--95451097
}

-- Constants
local DataStoreName = "PrisonRecords"
local DataStoreKey = "prisoner1"
local PrisonerTeam = "Prisoners"
local MainTeam = "Rome"
local MainID = 6231460

-- Services
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService:WaitForChild("Modules")
local GroupService = require(Modules:WaitForChild("GroupService"))
local DataStorez = require(game.ServerScriptService:WaitForChild("DataStore"))
local DataStore = DataStoreService:GetDataStore(DataStoreName)

local GUI = script:WaitForChild("GUI")

local webhook = "https://discordapp.com/api/webhooks/710994277513166861/UK14LX0uDtHM-CaXKZmyITNjaJUikJGSTy8EMvyRxwsTwSDeZhkElYJ3_Z6Uzcq_uBf7"
-- Update the webhook for new Discord server

-- Functions

-- Create a thing
function Create(Item, Parent, Name)
	if Parent:FindFirstChild(Name) then
		return Parent:FindFirstChild(Name)
	else
		local New = Instance.new(Item)
		New.Name = Name
		New.Parent = Parent
		return New
	end
end

-- Save player data
function SaveData(player)
	if game.JobId ~= "" then
		if player.Parent ~= nil and player.UserId then
			if Records[player.Name] then
				local JailedAt = Records[player.Name].JailedAt
				local Sentence = Records[player.Name].Sentence
				if JailedAt and Sentence then
					local TimePassed = tick() - JailedAt
					local RemaningSecondsOnSentence = Sentence - TimePassed
					DataStore:SetAsync(DataStoreKey .. "_" .. player.UserId, RemaningSecondsOnSentence)
				end
			end
		end
	end
end

-- Function used to determine if player should have cuffs
function Allowed(player)
	local Groups = {}
	for Id,MinRank in pairs(PermittedGroups) do
		print(Id, MinRank)
		if GroupService:GetRankInGroup(player, Id) >= PermittedGroups[Id] then
			return true
		end
	end
	
	if game.JobId == "" then return true end
	
--[[	local InGroup, GroupIdIsIn = GroupService:IsInGroup(player, Groups)
	if InGroup then
		local MinRank = PermittedGroups[GroupIdIsIn]
		if GroupService:GetRankInGroup(player, GroupIdIsIn) >= MinRank then
			return true
		end
	end
	
	return false
		--]]
end

function checkImmune(player)
	for i,v in pairs(immune) do
		if v == player.UserId then
			return true
		end
	end
	return false
end

-- Function that arrests a player
function Arrest(player, jailer, sentence, reason)
	if not jailer then
		local Criminal = Players:FindFirstChild(player.Name)
		if Criminal and Teams:FindFirstChild(PrisonerTeam) then
			Criminal.TeamColor = Teams[PrisonerTeam].TeamColor
			player.Neutral = false
		end
	else
		if not Allowed(jailer) then return end
		if sentence > 20 then return end
		local Criminal = type(player) == "string" and Players:FindFirstChild(player) or player
			
		-- In-game
		if Criminal and not checkImmune(Criminal) and jailer:DistanceFromCharacter(Criminal.Character.UpperTorso.Position) <= 40  --[==[and Teams:FindFirstChild(MainTeam) and (Criminal.Team == nil or (Criminal.Team.Name ~= "Hostiles" and Criminal.Team.Name ~= "Foreigners"))]==] then
			
			-- Update data
			if type(sentence) == "number" and Records[Criminal.Name] ~= nil then
				Records[Criminal.Name] = {
					["JailedAt"] = tick(),
					["Sentence"] = sentence * 60,
					["Reason"] = reason
				}
			end
			SaveData(player)
			-- Team
			if Teams:FindFirstChild(PrisonerTeam) then
				Criminal.TeamColor = Teams[PrisonerTeam].TeamColor
				--[==[
				local s = game.Workspace.Spawns:WaitForChild(PrisonerTeam):GetChildren()
				local rand = Random.new()
				local r = rand:NextInteger(1,#s)
				player.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(s[r].Position)]==]
			end
			
			-- Respawn
			Criminal:LoadCharacter()
			
			pcall(function()
				local data = {
					["content"] = Criminal.Name.. " was arrested by " .. jailer.Name .. " for " .. tostring(reason) .. " [" .. tostring(sentence) .. "]";
					["username"] = Criminal.Name;
					["avatar_url"] = game.Players:GetUserThumbnailAsync(Criminal.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100);
				}
				HttpService:PostAsync(webhook, HttpService:JSONEncode(data))
			end)
	
		end
	end
end

-- Function that unarrests a player
function Unarrest(player, personThatUnarrested)
	if personThatUnarrested ~= nil and not Allowed(personThatUnarrested) then return end

	local Prisoner = type(player) == "string" and Players:FindFirstChild(player) or player

	if Prisoner then

		-- Delete record in datastore
		if Records[Prisoner.Name] then
			DataStore:RemoveAsync(DataStoreKey .. "_" .. Prisoner.UserId)
		end
		
		-- Add back to team
		if Teams[PrisonerTeam] then
			if player:IsInGroup(6231460) then
				Prisoner.TeamColor = Teams.Rome.TeamColor
			else
				Prisoner.TeamColor = Teams.Outsiders.TeamColor
			end
--			
--			if Teams:FindFirstChild(MainTeam) and GroupService:IsInGroup(Prisoner, MainID) then
--				
--				Prisoner.TeamColor = Teams[MainTeam].TeamColor
--			else
--				Prisoner.TeamColor = BrickColor.new("Really black")
--				warn("JAILMANAGEMENT: No team could be found for " .. Prisoner.Name .. " when released.")
--			end
--		end
		
		if personThatUnarrested then
			pcall(function()
				local data = {	
					["content"] = personThatUnarrested.Name .. " unarrested " .. Prisoner.Name;
					["username"] = Prisoner.Name;
					["avatar_url"] = game.Players:GetUserThumbnailAsync(Prisoner.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100);
				}
				HttpService:PostAsync(webhook, HttpService:JSONEncode(data))
			end)
		end
		
		-- Reset data
		Records[Prisoner.Name] = {}
		
		-- Respawn
		Prisoner:LoadCharacter()
	end
  end
end

-- Player joins the game
function PlayerJoined(player)
	
	-- Retrieve
	local Success, Retrieved = pcall(function()
		return DataStore:GetAsync(DataStoreKey .. "_" .. player.UserId)
	end)
	
	Records[player.Name] = {}
	
	-- Add sentence
	if Success and Retrieved ~= nil and type(Retrieved) == "number" then
		Records[player.Name]["JailedAt"] = tick()
		Records[player.Name]["Sentence"] = Retrieved
		Arrest(player)
	else
		if Retrieved ~= nil and type(Retrieved) ~= "number" then
			DataStore:RemoveAsync(DataStoreKey .. "_" .. player.UserId)
		end
	end
		
	-- Respawned
	player.CharacterAdded:Connect(function(character)
		local t = tick()
		repeat wait() until character.Parent == workspace or tick() - t >= 5
		
		local Data = Records[player.Name]
		
		if Data and type(Data) == "table" then
			local JailedAt = Data.JailedAt
			local Sentence = Data.Sentence
						
			if JailedAt and Sentence then
				
				if Teams[PrisonerTeam] and player.Team ~= Teams[PrisonerTeam] then
					Arrest(player)
				end
				print("sentenceinfo")
				local SentenceInfo = GUI:Clone()
				SentenceInfo.Parent = character:WaitForChild("Head")
				SentenceInfo.Adornee = character:WaitForChild("Head")
			end
		end
	end)
end

-- Events
Players.PlayerAdded:Connect(PlayerJoined)

Players.PlayerRemoving:Connect(function(player)
	SaveData(player)
	Records[player.Name] = nil
end)

local Events = Create("Folder", ReplicatedStorage, "Events")

local JailEvent = Create("RemoteEvent", Events, "JailEvent")
JailEvent.OnServerEvent:Connect(function(sender, action, player, length, reason)
	if sender.Parent ~= nil and player.Parent ~= nil and Allowed(sender) then
		if action == "Arrest" and length then
			Arrest(player, sender, length, reason)
		elseif action == "Unarrest" then
			Unarrest(player, sender)
		end
	end
end)

-- Save data on server crash/shutdown
game:BindToClose(function()
	for _,Player in pairs(Players:GetPlayers()) do
		coroutine.wrap(function()
			SaveData(Player)
		end)
	end
end)

-- Parole
while wait(5) do
	for PlayerName,Data in pairs(Records) do
		
		local Player = Players:FindFirstChild(PlayerName)
		
		local success, err = pcall(function()
			
			if Player and Player.Parent ~= nil and Data ~= nil then
				
				local JailedAt = Data.JailedAt
				local Sentence = Data.Sentence
				
				if JailedAt and Sentence then

					local Success, Retrieved = pcall(function()
						return DataStore:GetAsync("prisoner1" .. "_" .. Player.UserId)
					end)
						
					if not Retrieved then
						Records[PlayerName] = nil
					end
															
					local RemainingSeconds = Sentence - (tick() - JailedAt)
                    print(RemainingSeconds)
					-- Ongoing sentence
					if RemainingSeconds > 0 then
						if Player.Character and Player.Character:FindFirstChild("Head") and Player.Character.Head:FindFirstChild("GUI") then
							local MinutesLeft = math.floor(RemainingSeconds/60) > 0 and math.floor(RemainingSeconds/60) or "<1"
							Player.Character.Head.GUI.TextDisplay.Text = MinutesLeft .. " mins"
						end
						
					-- Sentence finished
					else
						print("Unarresting person")
						Unarrest(Player)
					end
				elseif Player.Team and Player.Team.Name == PrisonerTeam then
					Unarrest(Player)
				end
			end
		end)
		if not success then
			warn(err)
		end
	end
end