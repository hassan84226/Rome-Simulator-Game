

--Variables--\/--
local jail = game.Workspace.Cells:GetChildren()--Model for teleportingbricks for jail
--local cuff = script.PrisonCuffs
	
--CORE--\/--
game.Players.PlayerAdded:connect(function(plr)
	--FOLDERS-\/-I have tidy issues (rip bray 2k15), this will put everything into a folder and I added currency for later reference. The jail will go into a file that is in workspace.
	local fol = Instance.new("Folder",plr)
	fol.Name = "Data"
	if game.Workspace.UserJailList:FindFirstChild(plr.Name) == nil then
	local ja = Instance.new("BoolValue",game.Workspace.UserJailList)
	ja.Name = plr.Name
	ja.Value = false
	local ti = Instance.new("NumberValue",ja)
	ti.Name = "Timer"
	ti.Value = 0
	end
plr.CharacterAdded:Connect(function(character)
if character then
wait(4)
if character:FindFirstChild("RealName") == nil then
local rl = Instance.new("StringValue",character)
rl.Name = "RealName"
rl.Value = plr.Name
end
end	
end)
end)


-----------------------------------------
game.Players.PlayerAdded:connect(function(p) 
p.CharacterAdded:connect(function(chr)
		repeat wait() until game.Workspace.UserJailList:FindFirstChild(p.Name)
	    if p:FindFirstChild("Jailed") ~= nil then return end
		--REAL NAME TAG-\/- As people are changing their names im under the impression their character model names change (but I realised at end it dont change woops)
		local rl = Instance.new("StringValue",chr)
		rl.Name = "RealName"
		rl.Value = p.Name
		--HANDING OUT WEAPONS-\/-There is a local script in this current core script that will hand out tools, like cuffs to people who need them.
		--if p:GetRankInGroup(5625423) >= 1 or p.userId == 111596425 then
		--local cu = cuff:Clone()
		--cu.Parent = p.Backpack
		--end
		--JAILING-\/-If a player is jailed then their tools from above must be removed, so we do this part last so they have tools to remove. 
		if game.workspace.UserJailList:FindFirstChild(p.Name).Value == true then
		chr.Humanoid:UnequipTools()
		for i,v in pairs(p.Backpack:GetChildren())do
		if v:IsA("Tool") then
			v:destroy()
		end
		end
			local new = Instance.new("StringValue")
			new.Parent = p
			new.Name = "Jailed"	
			chr.Humanoid.MaxHealth = 99e99
			chr.Humanoid.Health = 99e99
			tp(game.Workspace:FindFirstChild(p.Name).UpperTorso, jail[math.random(1,#jail)].Position)
			--TIMER-\/-Adding the visual timer they would have lost if they reset in jail.
			local tim = script.Timer:Clone()
			tim.Parent = game.Workspace:FindFirstChild(p.Name).Head
			tim.Txt.Text = game.Workspace.UserJailList:findFirstChild(p.Name).Timer.Value
			tim.Enabled = true
			tim.Txt.Script.Disabled = false
			return
		end

end)
end)

function jailplr(character,reason,timeforjail)
	if character:FindFirstChild("Humanoid")or character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and deb == false and script.Parent.Assets.TimeForJail.Value >= 10 then
		deb = true
local plr = game.Players:FindFirstChild(character.RealName.Value)
character.Humanoid:UnequipTools()
local chr = character
if plr:FindFirstChild("Jailed") == nil then
local new = Instance.new("StringValue")
new.Parent = plr
new.Name = "Jailed"
end
	local new = script.PlayerTemplate:Clone()
	new.Parent = game.Workspace.ReasonStorage
	new.Value = character.Name
	new.Reason.Value = reason
		for i,v in pairs(plr.Backpack:GetChildren())do
		if v:IsA("Tool") then
			v:destroy()
		end
		end
		local chr = game.Workspace:FindFirstChild(plr.Name)
		repeat wait() until chr
chr.Humanoid.MaxHealth = 99e99
wait(0.03)
chr.Humanoid.Health = 99e99
        if character:FindFirstChild("Humanoid") ~= nil then
		game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Value = true
		tp(character.UpperTorso, jail[math.random(1,#jail)].Position)
		local cd = script.CountDown
		local c = cd:Clone()
		c.Parent = game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Timer
		game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Timer.Value = timeforjail -- Change this to however long you want them to be in jail.
		c.Disabled = false
		local tim = script.Timer:Clone()
		tim.Parent = character.Head
		tim.Txt.Text = game.Workspace.UserJailList:findFirstChild(plr.Name).Timer.Value
		tim.Enabled = true
		tim.Txt.Script.Disabled = false
		--script.Parent.Assets.JailedSomeone.Value = true
		wait(0.03)
		--script.Parent.Assets.JailedSomeone.Value = false
		wait(3)
		deb = false
	    elseif character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and deb == false and character.RealName.Value ~= script.Parent.Parent.RealName.Value and game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Value == true then
		deb = true
		game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Value = false
		game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Timer.Value = 0
		game.Workspace.UserJailList:findFirstChild(character.RealName.Value).Timer.CountDown:Destroy()	
		wait(3)
		deb = false
		end
	end
end

game.ReplicatedStorage.JailAssets.RemoteFunction.OnServerInvoke = function(player, plr)
local new = Instance.new("StringValue")
new.Parent = plr
new.Name = "Jailed"	
end

game.ReplicatedStorage.JailAssets.Arrest.OnServerInvoke = function(user, victimscharacter, reason,Time)
	if victimscharacter and reason then
		jailplr(victimscharacter,reason,Time)
	end
end

game.ReplicatedStorage.JailAssets.NoMore.OnServerInvoke = function(user)
	if user.PlayerGui:FindFirstChild("Reason") then
		local UI = user.PlayerGui:FindFirstChild("Reason")
		UI:Destroy()
	end
end

--TELEPORTING-\/-This function is just so Arrendanes that are imprionsed will be teleported to a randomly selected cell.
function tp(torso, pos)
	local torso = torso
	local location = {pos}
	local i = 1

	local x = location[i].x
	local y = location[i].y
	local z = location[i].z
				
	x = x + math.random(-1, 1)
	z = z + math.random(-1, 1)
	y = y + math.random(2, 3)

	local cf = torso.CFrame
	local lx = 0
	local ly = y
	local lz = 0
					
	torso.CFrame = CFrame.new(Vector3.new(x,y,z), Vector3.new(lx,ly,lz))
end

--//FIN.