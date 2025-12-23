repeat task.wait() until game.Players.LocalPlayer
local bgm = workspace:WaitForChild("BackgroundMusic")

local p = game.Players.LocalPlayer
local ItemList = require(game.ReplicatedStorage.Information.Items)
local Main =  game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
local BattleRGui = Main:WaitForChild("BattleRequest")
local leaveevent 
local soundtable = {9852941207,9852959332,9243134044}
local gui = Main
local FightAction
local bagAction
local switchAction
local BackButton
local runAction
local didMega = false
local userMega = false
local turnGoingOn = false
local currentStatus = nil
local associateBattle = {}
local StatusCond = {
	["Burn"] = {"BRN",Color3.new(197/255,0,0)},
	["Poison"] = {"PSN",Color3.new(120/255,0,120/255)},
	["BadlyPoison"] = {"PSN",Color3.new(120/255,0,120/255)},
	["Paralysis"] = {"PAR",Color3.new(220/255,220/255,0)},
	["Freeze"] = {"FRZ",Color3.new(170/255,1,1)},
	["Sleep"] = {"SLP",Color3.new(144/255,144/255,144/255)},
	["Faint"] = {"FNT",Color3.new(136/255,0,0)}
}

local function playBackgroundMusic()
	if game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("MuteBGM").Text == "Mute BG Music" then
		bgm.Volume = 0.3
	end
end

function fadeytext(text)
	gui.MessageThing.Text = text
	--	script.Parent.Main.BlackScreen.Visible = true
	for i = 1, 0, -.05 do
		gui.MessageThing.TextTransparency = i
		gui.MessageThing.TextStrokeTransparency = i  
		task.wait(.05)
	end
	task.wait(.5)
	for i = 0, 1, .05 do
		gui.MessageThing.TextTransparency = i 
		gui.MessageThing.TextStrokeTransparency = i 
		task.wait(.05)
	end
	gui.MessageThing.TextTransparency = 1
	gui.MessageThing.TextStrokeTransparency = 1
end


--
--CancelEvent
--
game.ReplicatedStorage.REvents.PVP.AnswerRequest.OnClientEvent:connect(function(action1)
	if action1 == "Cancel" then
		BattleRGui.Visible = false
		Main.MessageThing.Text = "The other person canceled the battle."
		Main.MessageThing.Transparency = 0
		task.wait(1)
		Main.MessageThing.Transparency = 1
		Main.BlackScreen.Visible = false	
	end
end)


--
--InitialRequest
--
game.ReplicatedStorage.REvents.PVP.BattleRequest.OnClientEvent:connect(function(playerAgainst, argument2, gamemode)
	if argument2 ~= nil then
		BattleRGui.Visible = false
		Main.BlackScreen.Visible = false
		Main.Cancel.Visible = false
		Main.PVPCancel.Visible = false --just in case I guess
	end
	if Main.BlackScreen.Visible == false and p.PlayerGui.DialogTalk.TalkB.Talk.Visible == false then
		if argument2 == nil then
			if accept then accept:disconnect() end if decline then decline:disconnect() end
			Main.InteractBG.Visible = false
			Main.BlackScreen.Visible = true
			for i,v in ipairs(Main.BlackScreen:GetChildren()) do
				v.Visible = false
			end
			Main.Pokedex.Visible = false
			Main.Backpack.Visible = false
			Main.Party.Visible = false
			Main.PCSystem.Visible = false
			BattleRGui.Frame.ImageLabel.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username="..playerAgainst.Name
			BattleRGui.Message.Text = playerAgainst.Name.." wants to battle you! Game mode: "..gamemode
			BattleRGui.Visible = true
			accept = BattleRGui.Accept.MouseButton1Down:connect(function()
				BattleRGui.Visible = false
				if playerAgainst ~= nil and game.Players:FindFirstChild(playerAgainst.Name) then
					game.ReplicatedStorage.REvents.PVP.AnswerRequest:FireServer("Accept",playerAgainst,gamemode)
				else
					Main.BlackScreen.Visible = false
				end
			end)
			decline = BattleRGui.Decline.MouseButton1Down:connect(function()
				BattleRGui.Visible = false
				Main.BlackScreen.Visible = p.InBattle.Value
				if playerAgainst ~= nil then
					game.ReplicatedStorage.REvents.PVP.AnswerRequest:FireServer("Decline",playerAgainst)
				end
			end)
		end
	end
end)

local PvP = Main.PvPSelector
--ToggleStuff
function toggleall(bool) --just makes everything invisible
	for i,v in ipairs(PvP.OppFrame:GetChildren()) do
		v.Visible = bool
	end
	for i,v in ipairs(PvP.UserFrame:GetChildren()) do
		v.Visible = bool
	end
	PvP.Visible = bool
end


--
--Lead Selection
--


game.ReplicatedStorage.REvents.PVP.LeadSelection.OnClientEvent:connect(function(playerAgainst,Folder,ticket)
	toggleall(false)
	local deb = false
	didMega = false
	userMega = false
	Main.BlackScreen.Visible = true
	Main.Cancel.Visible = false
	--Main.Cancel.Visible = false	
	Main.MessageThing.TextTransparency = 1
	Main.MessageThing.TextStrokeTransparency = 1
	--if otherPlayer leaves
	--		leaveevent = game.Players.ChildRemoved:connect(function(playerAgainst)
	--			if leaveevent and 	playerAgainst then
	--					PvP.Visible = false
	--				leaveevent:disconnect()
	--			end
	--		
	--		end)

	PvP.OppFrame.User.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username="..playerAgainst.Name
	PvP.OppFrame.User.Visible = true
	PvP.UserFrame.User.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username="..p.Name 
	PvP.UserFrame.User.Visible = true	
	for i,v in ipairs(Folder[playerAgainst.Name]:GetChildren()) do
		if v.PartyPosition.Value <= 6 then
			local fr = PvP.OppFrame["Pokemon"..v.PartyPosition.Value]

			_G.getFrontSprite(fr,v)
			fr.BackgroundColor3 = _G.Tables.TypeColors[_G.Pokemon[v.Name]["Type"][1]]
			fr.Nickname.Text =  _G.nickname(v)
			fr.Visible = true
		end
	end	
	for i,v in ipairs(Folder[p.Name]:GetChildren()) do
		if v.PartyPosition.Value <= 6 then
			local fr = PvP.UserFrame["Pokemon"..v.PartyPosition.Value]
			_G.getFrontSprite(fr,v)
			fr.BackgroundColor3 = _G.Tables.TypeColors[_G.Pokemon[v.Name]["Type"][1]]
			fr.Nickname.Text =  _G.nickname(v)
			fr.Visible = true
			fr.Nickname.TextColor3 = Color3.new(1,1,1)
			if getfenv()[fr.Name] then getfenv()[fr.Name]:disconnect() end
			getfenv()[fr.Name] = fr.MouseButton1Down:connect(function()
				if deb == false then
					deb = true
					fr.BackgroundColor3 = Color3.new(
						math.max(0,fr.BackgroundColor3.r - .2),
						math.max(0,fr.BackgroundColor3.g - .2), 
						math.max(0,fr.BackgroundColor3.b - .2)
					)
					fr.Nickname.TextColor3 = Color3.new(1,0,0)
					fr.Nickname.Text = "SELECTED"
					game.ReplicatedStorage.REvents.PVP.ChangeLead:FireServer(ticket,v,playerAgainst)
				end
			end)
		end
	end	
	--Set Up Stuffz.
	PvP.Visible = true
	PvP.Cancel.Visible = true
	PvP.Cancel.MouseButton1Down:connect(function()
		game.ReplicatedStorage.REvents.PVP.Showdown:FireServer(ticket,p,"Cancel",playerAgainst)
	end)
end)


local showdown = gui.PvPPlayers
playerLeft = false

--what if Player leaves in midst of battle?



game.ReplicatedStorage.REvents.PVP.Showdown.OnClientEvent:connect(function(ticket,canceller,action,opp,folderO)
	playerLeft = false
	if action == "Begin" then
		PvP.Visible = false
		local	Sound = p.PlayerGui.BattleSound
		Sound.SoundId = "http://www.roblox.com/asset/?id="..soundtable[math.random(1,#soundtable)]
		bgm.Volume = 0	
		Sound:Play()
		--//setting up PvP beginning animation
		showdown.Player1.Position = UDim2.new(0,0,-2,0)
		showdown.Player1.PlayerName.Text = p.Name
		showdown.Player1.PlayerName.DropShadow.Text = p.Name
		showdown.Player1.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username="..p.Name	
		showdown.Player1.ImageColor3 = Color3.new(1,1,1)
		showdown.Player1.Winner.Visible = false	

		showdown.Player2.Position = UDim2.new(1,-250,4,0)
		showdown.Player2.PlayerName.Text = opp.Name
		showdown.Player2.PlayerName.DropShadow.Text = opp.Name
		showdown.Player2.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username="..opp.Name
		showdown.Player2.ImageColor3 = Color3.new(1,1,1)
		showdown.Player2.Winner.Visible = false	
		showdown.Versus.Visible = false	
		showdown.Visible = true	
		showdown.Player1:TweenPosition(UDim2.new(0,0,0,0),"Out","Bounce",1.5,false,function()

			showdown.Versus.Text = ""
			showdown.Versus.Visible = true
			task.wait(.5)
			showdown.Versus.Text = "V"
			task.wait(.5)
			showdown.Versus.Text = "Vs."
			showdown.Player2:TweenPosition(UDim2.new(1,-250,0,0),"Out","Bounce",1.5,false,function()
				task.wait(2)
				if playerLeft == true then
					PvP.Visible = false
					fadeytext("Other player left the server.")
					Main.Leaderboard.Visible = true
					Main.BlackScreen.Visible = false
					showdown.Visible = false

					p.PlayerGui.BattleSound:Stop()
					playBackgroundMusic()			
				else
					battleFunc(opp,folderO)
				end
			end)
		end)
	else	
		PvP.Visible = false
		PvP.Cancel.Visible = false
		if canceller then
			fadeytext("The battle was canceled by "..canceller.Name..".")
		end
		Main.BlackScreen.Visible = false

	end
end)


--//variables
local Scene = gui.PvPBattle
local TheirBox = Scene.TheirBox
local TheirParty = Scene.TheirParty
local YourBox = Scene.YourBox
local YourParty = Scene.YourParty

local TheirPokeball = Scene.TheirPokeball
local TheirPokemon = Scene.TheirPokemon
--local TheirAnim = Scene.TheirAnimation
local Trainer = Scene.Trainer
--local YourAnim = Scene.YourAnimation
local YourPokeball = Scene.YourPokeball
YourPokemon = Scene.YourPokemon
local TextBox = Scene.dialogbg
ActualText = TextBox.dialog
local Flash = Scene.Flash
local BH = Scene.ButtonHolder
Back = BH.Back
Fight = BH.Fight
Bag = BH.Bag
local Run = BH.Run
local Switch = BH.Pokemon
actionbuttons = {
	Fight,Bag,Run,Switch
}
MovesBG = TextBox.MovesBG

function scrolltext(gui,text,thing)
	for i = 1, #text, 2 do
		gui.Text = string.sub(text,1,i)
		if gui:FindFirstChild("dropshadow") then
			gui.dropshadow.Text = gui.Text
		end
		task.wait(.03)
	end

	gui.Text = text
	if gui:FindFirstChild("dropshadow") then
		gui.dropshadow.Text = gui.Text
	end
	task.wait(.55)
end
function togglebuttons(tab,bool)
	for i,v in ipairs(tab) do
		v.Visible = bool
	end
end
partyb = {
	["Empty"] = "http://www.roblox.com/asset/?id=125060330",
	["Status"] = "http://www.roblox.com/asset/?id=125060479",
	["Faint"] = "http://www.roblox.com/asset/?id=125060436",
	["Healthy"] = "http://www.roblox.com/asset/?id=125060370",
}

game.ReplicatedStorage.REvents.PVP.PlayerLeft.OnClientEvent:connect(function()
	local	Sound = p.PlayerGui.BattleSound
	if #p.OppPokemon:GetChildren() == 0 then
		Main.BlackScreen.Visible = false
		playerLeft = true
		showdown.Visible = false
		gui.PvPBattle.Visible = false
		PvP.Visible = false
		fadeytext("Other player left the server.")
		Main.Leaderboard.Visible = true
		Main.BlackScreen.Visible = false
		Main.PVPParty.Visible = false
		Sound:Stop()
		playBackgroundMusic()
	end
end)

function partyBars(folder,opp)

	for i,v in ipairs(folder:GetChildren()) do
		if v.Name == p.Name then
			local total = 0
			for _,img in ipairs(YourParty:GetChildren()) do
				img.Image = partyb["Empty"]
			end

			for poke, info in pairs(v:GetChildren()) do
				total = total + 1
				for ballz = 1, total do
					if ballz <= 6 then
						YourParty["Ball"..ballz].Image = partyb["Healthy"] 
					end
				end
				if total < 6 then --total is "4", 
					for ballz = 6, total+1,-1 do
						YourParty["Ball"..ballz].Image = partyb["Empty"]
					end 
				end
			end
		elseif v.Name == opp.Name then
			local total = 0
			for _,img in ipairs(TheirParty:GetChildren()) do
				img.Image = partyb["Empty"]
			end
			for poke, info in pairs(v:GetChildren()) do
				total = total + 1
			end
			for ballz = 1, total do
				if ballz <= 6 then
					TheirParty["Ball"..ballz].Image = partyb["Healthy"] 
				end
			end
			if total < 6 then --total is "4", 
				for ballz = 6, total+1,-1 do
					TheirParty["Ball"..ballz].Image = partyb["Empty"]
				end 
			end
		end

		TheirParty.Visible = true
		YourParty.Visible = true
	end

end


function findhealthbarsize(curhealth,maxhealth) --size is 202
	local multi = curhealth/maxhealth
	return multi
end


function findPokemon(folder)
	for i,v in ipairs(folder:GetChildren()) do
		--print(v.Parent.Name,v.Name, v:FindFirstChild("PartyPosition").Value )
		if v:FindFirstChild("PartyPosition") and  v:FindFirstChild("PartyPosition").Value == 1 then

			return v
		end
	end
end

function checkForStatus(turnTable,box,op)
	if turnTable ~= nil then

		local starfin =  op.Name.."&UpdateStatus"

		if box.Name == "YourBox" then
			starfin =  p.Name.."&UpdateStatus"
		end
		for i,v in ipairs(turnTable) do
			if v:find(starfin) then
				return false
			end
		end
	end
	return true
end

function BoxUpdate(pokemon,box,hp,turntable,op)
	local curHP = hp


	if curHP == nil then
		curHP = pokemon.CurrentHP.Value
	end
	box.Visible = false
	box.Status.Visible = false
	box.PokemonName.Text = nickname(pokemon)
	box.PokemonName.Shadow.Text = box.PokemonName.Text
	box.Level.Text = "Lv. "..pokemon.Lvl.Value
	box.Level.Shadow.Text = box.Level.Text
	box.Gender.Image = _G.Sprites["Symbols"][pokemon.Gender.Value]
	--print(pokemon.Status.Value)

	if pokemon.Status.Value ~= "Faint" and pokemon.Status.Value ~= "" and (hp == nil or checkForStatus(turntable,box,op)) then

		box.Status.Text = StatusCond[pokemon.Status.Value][1]
		box.Status.BackgroundColor3 = StatusCond[pokemon.Status.Value][2]
		box.Status.Visible = true
	end
	if box.Name == "YourBox" then
		box.HPLabel.Text = curHP.."   /   " ..pokemon.Stats.HPStat.Value
		box.HPLabel.Shadow.Text = box.HPLabel.Text

	end

	box.HealthBG.Health.Size = 	UDim2.new(findhealthbarsize(curHP,pokemon.Stats.HPStat.Value),-2,1,-2)
	box.Visible = true
end

function StatusUpdate(pokemon,box)
	--print(pokemon.Status.Value)
	if pokemon.Status.Value ~= "" then

		box.Status.Text = StatusCond[pokemon.Status.Value][1]
		box.Status.BackgroundColor3 =StatusCond[pokemon.Status.Value][2]
		box.Status.Visible = true
	elseif pokemon.Status.Value == "" then
		box.Status.Visible = false
	end
end

function animateHealth(pokemon,HP,box,flashPokemon,before)
	if before > HP then
		flashPokemon.Animation.Visible = true
		task.wait(.05)
		flashPokemon.Animation.Visible = false
		task.wait(.1)
		flashPokemon.Sprite.Visible = false
		task.wait(.1)
		flashPokemon.Sprite.Visible = true
		task.wait(.1)
		flashPokemon.Sprite.Visible = false
		task.wait(.1)
		flashPokemon.Sprite.Visible = true
		task.wait(.2)
	end
	if HP ~= before then

		box.HealthBG.Health:TweenSize(    UDim2.new(findhealthbarsize(HP,pokemon.Stats.HPStat.Value),-2,1,-2),"Out","Quad",1,true)
		if box.Name == "YourBox" then
			box.HPLabel.Text = HP.."   /   " ..pokemon.Stats.HPStat.Value
			box.HPLabel.Shadow.Text = box.HPLabel.Text
		end

		task.wait(1)
	end

end

function nickname(pokemon)
	local success, canLocalUserChat = pcall(function()
		return game:GetService("TextChatService"):CanUserChatAsync(game.Players.LocalPlayer.UserId)
	end)
	if pokemon:FindFirstChild("Nickname") and success and canLocalUserChat  then
		return pokemon:FindFirstChild("Nickname").Value
	else
		return pokemon.Name
	end
end

function battleFunc(opposingPlayer,folder)
	if opposingPlayer ~= nil then
		script.Parent.Main.Leaderboard.Visible = false
		--//variables
		battleassociate = {}
		showdown.Visible = false
		Scene.Visible = false
		--				folder[p.Name.."Time"].Changed:connect(function(val)
		--				Scene.UserTime.Text =  TimeChecker(val)
		--				end)
		--				folder[opposingPlayer.Name.."Time"].Changed:connect(function(val)
		--				Scene.OppTime.Text =  TimeChecker(val)
		--				end)
		--//Setting up teams above the Battle
		local oppFold = folder[opposingPlayer.Name]
		local pFold = folder[p.Name]
		Scene.OpponentHolder.Visible = false
		Scene.UserHolder.Visible = false
		for i,v in ipairs(Scene.UserHolder:GetChildren()) do
			v.Visible = false
		end
		for i,v in ipairs(Scene.OpponentHolder:GetChildren()) do
			v.Visible = false
		end
		for i,v in ipairs(pFold:GetChildren()) do		
			Scene.UserHolder["Pokemon"..v.PartyPosition.Value].Image = _G.Pokemon[v.Name]["Sprites"]["Mini"]
			Scene.UserHolder["Pokemon"..v.PartyPosition.Value].Visible = true
			battleassociate[v] =  Scene.UserHolder["Pokemon"..v.PartyPosition.Value]
		end
		for i,v in ipairs(oppFold:GetChildren()) do
			Scene.OpponentHolder["Pokemon"..v.PartyPosition.Value].Image = _G.Pokemon[v.Name]["Sprites"]["Mini"]
			Scene.OpponentHolder["Pokemon"..v.PartyPosition.Value].Visible = true
			battleassociate[v] = Scene.OpponentHolder["Pokemon"..v.PartyPosition.Value]
		end
		Scene.OpponentHolder.Visible = true
		Scene.UserHolder.Visible = true
		--//setting up battle
		Scene.Position = UDim2.new(0.15, 0,-.8, 0) --{0.5, -240},{0.4, -112}
		Scene.Visible = true
		Scene.Image = "rbxassetid://5673234306"
		TheirBox.Visible = false
		TheirParty.Visible = false
		YourBox.Visible = false
		YourParty.Visible = false
		--TheirAnim.Visible = false
		TheirPokeball.Visible = false
		TheirPokemon.Visible = false
		Trainer.Visible = true
		Trainer.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username="..opposingPlayer.Name
		--YourAnim.Visible = false
		YourPokemon.Visible = false
		YourPokeball.Visible = false
		ActualText.Text = opposingPlayer.Name.." wants to battle!"
		ActualText.dropshadow.Text = ActualText.Text
		TextBox.Visible = true
		MovesBG.Visible = false
		togglebuttons(actionbuttons,false)
		BH.MegaEvolve.Visible = false
		togglebuttons(MovesBG:GetChildren(),false)
		partyBars(folder,opposingPlayer)
		Scene:TweenPosition(UDim2.new(0.15, 0,0.139, 0),"Out","Quad",2,false)
		task.wait(2.7)
		--//opp sends out 1st Pokemon
		local opplead = findPokemon(oppFold)
		scrolltext(ActualText,opposingPlayer.Name.." sent out "..nickname(opplead).."!")
		TheirPokeball.Image = _G.Sprites["Pokeball"][opplead.Pokeball.Value]["Closed"]
		TheirPokeball.Visible = true
		task.wait(.3)
		TheirPokeball.Image = _G.Sprites["Pokeball"][opplead.Pokeball.Value]["Open"]
		task.wait(.3)
		Flash.Visible = true
		TheirPokeball.Visible = false

		_G.getFrontSprite(TheirPokemon.Sprite,opplead)

		TheirPokemon.Visible = true
		Trainer.Visible = false
		TheirParty.Visible = false
		BoxUpdate(opplead,TheirBox)
		task.wait(.1)
		Flash.Visible = false

		--//user sends out 1st Pokemon
		local yourlead = findPokemon(pFold)

		scrolltext(ActualText,"Go, "..nickname(yourlead).."!")
		YourPokeball.Image = _G.Sprites["Pokeball"][yourlead.Pokeball.Value]["Closed"] 
		YourPokeball.Visible = true
		task.wait(.3)
		YourPokeball.Image = _G.Sprites["Pokeball"][yourlead.Pokeball.Value]["Open"]
		task.wait(.3)
		Flash.Visible = true
		YourPokeball.Visible = false
		_G.getBackSprite(YourPokemon.Sprite,yourlead)

		YourPokemon.Visible = true
		YourParty.Visible = false
		BoxUpdate(yourlead,YourBox)
		task.wait(.1)
		Flash.Visible = false
		turn(opposingPlayer,folder,findPokemon(folder[p.Name]))
	end
end


game.ReplicatedStorage.REvents.PVP.RepeatTurn.OnClientEvent:connect(function(opposingPlayer,folder)
	repeat task.wait() until turnGoingOn == false 
	turn(opposingPlayer,folder,findPokemon(folder[p.Name]))

end)

function Mover(num,poke) 
	for i,v in ipairs(poke.Moves:GetChildren()) do
		if v.Value == num then
			return v
		end
	end
end


function getMoves(pokemon)
	for i,v in pairs(MovesBG:GetChildren()) do
		if v:IsA("TextButton") then
			v.Visible = false
		end
	end
	for i,v in ipairs(pokemon.Moves:GetChildren()) do
		MovesBG["Move"..v.Value].Visible = true	
	end	
end

function PPChecker(pokemon)
	for i,v in ipairs(pokemon.Moves:GetChildren()) do
		if v.PP.Value > 0 then
			return true
		end
	end
	return false
end

function TimeChecker(val)


	local part1 = math.floor(val/60)
	local part2
	if val - 60 == 60 or val - 60 == 0 then
		part2 = "00"
	elseif string.len(tostring(math.min(val%60))) == 1 then
		part2 = "0"..math.min(val%60)
	elseif math.min(val%60) then
		part2 = math.min(val%60)
	end
	local String = part1..":"..part2
	return String
end

local choosing 
--local t = 0
function turn(opposingPlayer,folder,currentPokemon)
	BH.MegaEvolve.Visible = false
	local GonnaMega = false
	local canMega = false
	--	print(t)
	--	t=t+1
	local pFold = folder[p.Name]
	local oppFold = folder[opposingPlayer.Name] 
	--	print(currentPokemon.Name)
	choosing = true
	local info
	Fight.PokemonSprite.Image = _G.Pokemon[currentPokemon.Name]["Sprites"]["Mini"]
	coroutine.resume(coroutine.create(function()
		while choosing do
			YourPokemon.Sprite.Position = UDim2.new(0, 0, 0.25, 0)
			task.wait(.2)
			YourPokemon.Sprite.Position = UDim2.new(0, 0, 0.25, -2)
			task.wait(.2)
		end
	end))
	scrolltext(ActualText, "What will "..nickname(currentPokemon).." do?")
	local MoveButtons = {}
	BH.MegaEvolve.Visible = false
	if MegaEvent then MegaEvent:disconnect() end

	if userMega ~= true and ItemList[currentPokemon.HeldItem.Value] and ItemList[currentPokemon.HeldItem.Value]["MegaEvolve"] and currentPokemon.Name == ItemList[currentPokemon.HeldItem.Value]["Requirement"] then
		canMega = true
		BH.MegaEvolve.Position = UDim2.new(0.25, 0,1, 0)
		BH.MegaEvolve.PokemonSprite.Image = _G.Pokemon[ItemList[currentPokemon.HeldItem.Value]["MegaEvolve"]]["Sprites"]["Mini"]								
		BH.MegaEvolve.BackgroundColor3 = Color3.new(0,170/255,0)
		BH.MegaEvolve.Title.Text = "Mega Evolve"
		BH.MegaEvolve.Title.Drop.Text = BH.MegaEvolve.Title.Text
		BH.MegaEvolve.Visible = true
		GonnaMega = false
		MegaEvent = BH.MegaEvolve.MouseButton1Click:connect(function()
			if userMega == false then
				GonnaMega = true
				BH.MegaEvolve.BackgroundColor3 = Color3.new(170/255, 1, 1)
				BH.MegaEvolve.Title.Text = "Mega Evolving This Turn"
				BH.MegaEvolve.Title.Drop.Text = BH.MegaEvolve.Title.Text

				while userMega == true and BH.MegaEvolve.Visible == true do
					BH.MegaEvolve.PokemonSprite.Position = UDim2.new(0,0,0,0)
					task.wait(.2)
					BH.MegaEvolve.PokemonSprite.Position = UDim2.new(0,0,0,2)	
					task.wait(.2)											
				end
			elseif userMega == true then
				GonnaMega = false

				BH.MegaEvolve.Title.Text = "Mega Evolve"
				BH.MegaEvolve.Title.Drop.Text = BH.MegaEvolve.Title.Text
				BH.MegaEvolve.BackgroundColor3 = Color3.new(0,170/255,0)
			end
		end)
	else
		BH.MegaEvolve.Visible = false
	end
	if FightAction then FightAction:disconnect() end
	FightAction = Fight.MouseButton1Down:connect(function()
		BH.MegaEvolve.Position = UDim2.new(0.25, 0,0, 0)
		ActualText.Text = ""
		ActualText.dropshadow.Text = ""
		togglebuttons(actionbuttons,false)
		if not PPChecker(currentPokemon) then
			MovesBG.Visible = false
			Back.Visible = false
			BH.MegaEvolve.Visible = false
			scrolltext(ActualText,"No PP left for any move! Using Struggle...")
			game.ReplicatedStorage.REvents.PVP.SendAction:FireServer("Move","Struggle",folder,opposingPlayer,GonnaMega)

			scrolltext(ActualText,"Waiting for your opponent...")
		else
			for i,v in ipairs(MovesBG:GetChildren()) do
				if getfenv()[v] then getfenv()[v]:disconnect() end --legacy code
				if getfenv()[v.Name] then getfenv()[v.Name]:disconnect() end
				if v:IsA("TextButton") then

					local num = tonumber(v.Name:sub(5,5))
					local actualMove = Mover(num,currentPokemon)
					if actualMove ~= nil then
						local moveName = actualMove.Name
						v.MoveName.Text = moveName
						local color =  _G.Tables["TypeColors"][_G.Moves[moveName]["Type"]]
						v.BackgroundColor3 = color
						v.Category.Text = _G.Moves[moveName]["AttackType"]

						v.PP.Text = actualMove.PP.Value.." / ".._G.Moves[moveName]["PP"]
						v.Type.BackgroundColor3 = Color3.new(color.r-.16,color.g-.16,color.b-.16)
						v.Type.Text = _G.Moves[moveName]["Type"]
						v.Type.Visible = true
					end
					getfenv()[v.Name] = v.MouseButton1Down:connect(function()
						if currentPokemon.Moves[v.MoveName.Text].PP.Value > 0 then
							MovesBG.Visible = false
							Back.Visible = false
							BH.MegaEvolve.Visible = false
							game.ReplicatedStorage.REvents.PVP.SendAction:FireServer("Move",v.MoveName.Text,folder,opposingPlayer,GonnaMega)
							scrolltext(ActualText,"Waiting for your opponent...")
						elseif currentPokemon.Moves[v.MoveName.Text].PP.Value == 0 then
							togglebuttons(actionbuttons,false)
							MovesBG.Visible = false
							Back.Visible = false
							scrolltext(ActualText,nickname(currentPokemon).." has no PP for that move!")
							task.wait(1)
							scrolltext(ActualText, "What will "..nickname(currentPokemon).." do?")
							togglebuttons(actionbuttons,true)

						end
					end)
				end
			end


			MovesBG.Visible = true
			Back.Visible = true
		end
	end)
	getMoves(currentPokemon)
	togglebuttons(actionbuttons,true)
	if bagAction then bagAction:disconnect() end
	bagAction = Bag.MouseButton1Down:connect(function()
		BH.MegaEvolve.Visible = false
		togglebuttons(actionbuttons,false)
		scrolltext(ActualText, "That isn't the time for that!")
		task.wait(1)

		scrolltext(ActualText, "What will "..nickname(currentPokemon).." do?")
		togglebuttons(actionbuttons,true)
		if canMega == true then
			BH.MegaEvolve.Visible = true
		end
	end)
	if BackButton then BackButton:disconnect()  end
	BackButton = Back.MouseButton1Down:connect(function()
		BH.MegaEvolve.Visible = false
		BH.MegaEvolve.Position = UDim2.new(0.25, 0,1, 0)
		Back.Visible = false
		MovesBG.Visible = false
		ActualText.Text = ""
		ActualText.dropshadow.Text = ""

		scrolltext(ActualText, "What will "..nickname(currentPokemon).." do?")
		togglebuttons(actionbuttons,true)

		if canMega == true then
			BH.MegaEvolve.Visible = true
		end
	end)
	if switchAction then switchAction:disconnect() end
	switchAction = Switch.MouseButton1Down:connect(function()
		local d = _G.PVPParty(currentPokemon,pFold)
		repeat task.wait() until d ~= nil or switchAction == nil
		if d ~= nil then
			game.ReplicatedStorage.REvents.PVP.SendAction:FireServer("Switch",d,folder,opposingPlayer)
			MovesBG.Visible = false
			Back.Visible = false
			togglebuttons(actionbuttons,false)

			BH.MegaEvolve.Visible = false

			scrolltext(ActualText,"Waiting for your opponent...")
		end
	end)
	if runAction then runAction:disconnect() end
	runAction = Run.MouseButton1Down:connect(function()

		BH.MegaEvolve.Visible = false

		togglebuttons(actionbuttons,false)
		game.ReplicatedStorage.REvents.PVP.SendAction:FireServer("Run",nil,folder,opposingPlayer)
		scrolltext(ActualText,"You forfeit!")
		task.wait(.2)
		p.PlayerGui.BattleSound:Stop()
		playBackgroundMusic()
		Scene.Visible = false
		Main.Leaderboard.Visible = true
		Main.BlackScreen.Visible = false
	end)
end

--showcase Turn localside
function condense(str)
	for i = 1, #str do
		if str:sub(i,i) == "&" then	
			return i-1
		end
	end
end

function gethp(str)
	local bfo, after
	for i = 1, #str do
		if str:sub(i,i) == "@" then
			bfo = tonumber(str:sub(1,i-1))
			after = tonumber(str:sub(i+1,#str))
		end
	end
	return bfo,after
end

function game.ReplicatedStorage.REvents.PVP.FaintAction.OnClientInvoke(op,party,pokeout)
	repeat task.wait() until turnGoingOn == false
	task.wait(1.5)
	local d = _G.PVPParty(pokeout,party,"Cancel")
	repeat task.wait() until d 
	return d
end

function FaintAnim(Pokemon)
	local pos = Pokemon.Sprite.Position
	if Pokemon.Name == "YourPokemon" then
		Pokemon.Sprite:TweenPosition(UDim2.new(0,0,1,0),"Out","Quad",.75)
		task.wait(1)
		YourBox.Visible = false
		Pokemon.Visible = false
		Pokemon.Sprite.Position = pos
	else
		Pokemon.Sprite:TweenPosition(UDim2.new(0, 0, 1, 0),"Out","Quad",.75)
		task.wait(1)
		TheirBox.Visible = false
		Pokemon.Visible = false
		Pokemon.Sprite.Position = pos
	end
end

function returnPokemon(Pokemon)
	if Pokemon.Name == "TheirPokemon" then
		Flash.Visible = true
		task.wait(.1)
		Pokemon.Visible = false
		TheirBox.Visible = false
		Flash.Visible = false
	else
		Flash.Visible = true
		task.wait(.1)
		Pokemon.Visible = false
		YourBox.Visible = false
		Flash.Visible = false

	end
end

function sendOutPokemon(Poke,opposingPlayer,folder,number,turnTable)
	--print(number)
	local oppFold = folder[opposingPlayer.Name]
	local pFold = folder[p.Name]
	if Poke.Name == "TheirPokemon" then
		local Pokemon = findPokemon(oppFold)
		TheirPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Closed"]
		TheirPokeball.Visible = true
		task.wait(.3)
		TheirPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Open"]
		task.wait(.3)
		Flash.Visible = true
		TheirPokeball.Visible = false

		_G.getFrontSprite(TheirPokemon.Sprite,Pokemon)

		TheirPokemon.Visible = true
		BoxUpdate(Pokemon,TheirBox,number,turnTable,opposingPlayer)
		task.wait(.15)
		Flash.Visible = false
	elseif Poke.Name == "YourPokemon" then
		local Pokemon = findPokemon(pFold)
		YourPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Closed"]
		YourPokeball.Visible = true
		task.wait(.3)
		YourPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Open"]
		task.wait(.3)

		Flash.Visible = true
		YourPokeball.Visible = false
		_G.getBackSprite(YourPokemon.Sprite,Pokemon)


		YourPokemon.Visible = true
		BoxUpdate(Pokemon,YourBox,number,turnTable,opposingPlayer)
		task.wait(.15)
		Flash.Visible = false
	end	
end
game.ReplicatedStorage.REvents.PVP.SwitchoutPokemon.OnClientEvent:connect(function(oppSend,youSend,oPoke,pPoke)
	turnGoingOn = true
	if oppSend == true and youSend == true then
		ActualText.Text = ""	
		ActualText.dropshadow.Text = ""
		local Pokemon = oPoke
		scrolltext(ActualText,Pokemon.Parent.Name.." sent out "..nickname(Pokemon)..".")
		TheirPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Closed"]
		TheirPokeball.Visible = true
		task.wait(.3)
		TheirPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Open"]
		task.wait(.3)

		Flash.Visible = true
		TheirPokeball.Visible = false
		_G.getFrontSprite(TheirPokemon.Sprite,Pokemon)

		TheirPokemon.Visible = true
		BoxUpdate(Pokemon,TheirBox)
		task.wait(.2)
		Flash.Visible = false

		local Pokemon = pPoke
		scrolltext(ActualText,"Go, "..nickname(Pokemon).."!")
		YourPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Closed"]
		YourPokeball.Visible = true
		task.wait(.3)
		YourPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Open"]
		task.wait(.3)

		Flash.Visible = true
		YourPokeball.Visible = false
		_G.getBackSprite(YourPokemon.Sprite,Pokemon)

		YourPokemon.Visible = true
		BoxUpdate(Pokemon,YourBox)
		task.wait(.2)
		Flash.Visible = false
	elseif oppSend == true and youSend == false then
		local Pokemon = oPoke
		scrolltext(ActualText,Pokemon.Parent.Name.." sent out "..nickname(Pokemon)..".")
		TheirPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Closed"]
		TheirPokeball.Visible = true
		task.wait(.3)
		TheirPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Open"]
		task.wait(.3)

		Flash.Visible = true
		TheirPokeball.Visible = false
		_G.getFrontSprite(TheirPokemon.Sprite,Pokemon)

		TheirPokemon.Visible = true
		BoxUpdate(Pokemon,TheirBox)
		task.wait(.2)
		Flash.Visible = false
	elseif oppSend == false and youSend == true then
		ActualText.Text = ""
		ActualText.dropshadow.Text = ""
		local Pokemon = pPoke
		scrolltext(ActualText,"Go, "..nickname(Pokemon).."!")

		YourPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Closed"]
		YourPokeball.Visible = true
		task.wait(.3)
		YourPokeball.Image = _G.Sprites["Pokeball"][Pokemon.Pokeball.Value]["Open"]
		task.wait(.3)

		Flash.Visible = true
		YourPokeball.Visible = false
		_G.getBackSprite(YourPokemon.Sprite,Pokemon)

		YourPokemon.Visible = true
		BoxUpdate(Pokemon,YourBox)
		task.wait(.2)
		Flash.Visible = false
	end

	turnGoingOn = false
end)
function negativeNumber()
	local number = math.random(-1,1)
	repeat number = math.random(-1,1) until number ~= 0
	return number
end
function sparkles(framez,box,Mega)
	local amountofSparklesCreated = math.random(1,4)
	local colors = {}
	for i,v in ipairs(_G.Pokemon[Mega]["Type"]) do
		table.insert(colors,_G.Tables.TypeColors[v])
	end
	for i = 1, amountofSparklesCreated do
		local negativeCalc = negativeNumber()
		local startBy = negativeCalc*(-20)
		local last = negativeCalc*20
		local UpBy = negativeCalc*.75
		local sparkleFrame = Instance.new("ImageLabel")
		sparkleFrame.BackgroundTransparency = 1
		sparkleFrame.ZIndex = 7
		sparkleFrame.Name = "Sparkles"
		sparkleFrame.Image = "rbxassetid://583229322"
		sparkleFrame.ImageColor3 = colors[math.random(#colors)]


		sparkleFrame.Size = UDim2.new(0,8,0,8)
		sparkleFrame.ImageRectSize = Vector2.new(8,8)
		sparkleFrame.ImageRectOffset = Vector2.new(8,0)


		local originalposition = sparkleFrame.Position
		sparkleFrame.Position = UDim2.new(framez,i*math.random(2,6)+originalposition.X.Scale,0,math.min(startBy+5,startBy)^2)
		sparkleFrame.Parent = box
		local oroabso = sparkleFrame.AbsolutePosition
		local start = math.random(math.min(startBy+5,startBy),math.max(startBy+5,startBy))
		spawn(function()
			for i = start,last,UpBy do

				sparkleFrame.Position = UDim2.new(framez,i*4+originalposition.X.Scale,0,i^2)--+originalposition.Y.Scale)
				sparkleFrame.ImageRectOffset = Vector2.new(0,0)
				task.wait()
			end
		end)
	end
end
function megaEvolve(box,megaEvolution,typ,pokemon)
	local sl = Instance.new("Sound",box)
	sl.SoundId = "rbxassetid://138724260"

	local lever = Instance.new("Sound",box)
	lever.SoundId = "rbxassetid://377026009"
	local frames = {}
	for i = 1, 9 do
		sparkles(i/10,box,megaEvolution)
	end
	sl:Play()
	task.wait(1.75)
	for i = 0,9 do
		local frameTrans = Instance.new("Frame")
		table.insert(frames,frameTrans)
		frameTrans.Name = "BoxFrame"
		frameTrans.BorderSizePixel = 1
		frameTrans.BorderColor3 = Color3.new(0,0,0)
		frameTrans.ZIndex = 9
		frameTrans.BackgroundColor3 = Color3.new(0,0,0)
		frameTrans.Size = UDim2.new(.1,0,0,0) --starts at 0,0,0,0 and transform into this
		frameTrans.Position = UDim2.new(i/10,0,i%2,0)
		frameTrans.Parent = box
		frameTrans:TweenSizeAndPosition(UDim2.new(.1,0,1,0),UDim2.new(i/10,0,0,0),"Out","Quad",1)
		lever:Play()
		task.wait(.2)
	end
	print(2.65)
	local s = Instance.new("Sound",box)
	s.SoundId = "rbxassetid://348316769"
	s:Play()
	if typ == "Front" then
		_G.getFrontSprite(box,pokemon)
	elseif typ == "Back" then
		_G.getBackSprite(box,pokemon)
	end
	task.wait(.5)

	for i,v in ipairs(frames) do
		sparkles(i/10,box,megaEvolution)
		v:TweenSizeAndPosition(UDim2.new(.1,0,0,0),UDim2.new((i/10)-.1,0,i%2,0),"Out","Quad",1,true,function() v:Destroy() end)
		lever:Play()
	end
	task.wait(2.2)
	for i,v in ipairs(box:GetChildren()) do
		if v.Name == "Sparkles" or v.Name == "BoxFrame" then
			v:Destroy()
		end
	end
end

function getRidOfNick(s)
	local one,two,three
	local firstpart,secondpart,thirdpart 
	for i = 1, #s do
		if s:sub(i,i) == "|" then
			if one == nil then
				one = i 
			elseif two == nil then
				two = i
			elseif three == nil then
				three = i
			end
		end
	end
	local firststring = s:sub(one+1,two-1)
	local secondstring = s:sub(two+1,three-1)
	local replaceString = secondstring
	local success, canLocalUserChat = pcall(function()
		return game:GetService("TextChatService"):CanUserChatAsync(game.Players.LocalPlayer.UserId)
	end)
	if success and canLocalUserChat  then
		replaceString = firststring
	end

	secondpart = replaceString
	if one == 1 then
		firstpart = ""
	else
		firstpart = s:sub(1,one-1)
	end
	if three == #s then
		thirdpart = ""
	else
		thirdpart = s:sub(three+1,#s)
	end
	local finalString = firstpart..secondpart..thirdpart
	return finalString
end
game.ReplicatedStorage.REvents.PVP.ShowTurn.OnClientEvent:connect(function(opposingPlayer,turnTable,folder)
	local oppFold = folder[opposingPlayer.Name]
	local pFold = folder[p.Name]
	BH.MegaEvolve.Visible = false
	local lengthofp = #p.Name
	local opposinum = #opposingPlayer.Name
	choosing = false
	local oppfaint = false
	local faint = false
	turnGoingOn = true
	task.wait(1.5)
	for _,str in ipairs(turnTable) do
		if str:find("&Update") then
			local newstring = str:sub(1,lengthofp)
			local newstring2 = str:sub(1,opposinum)
			if newstring:find(p.Name) or newstring2:find(opposingPlayer.Name) then
				--Pokemon got status'd
				if str:find("&UpdateStatus") then
					if newstring:find(p.Name) then
						local pokemon = findPokemon(pFold)
						StatusUpdate(pokemon,YourBox)
					elseif newstring2:find(opposingPlayer.Name) then
						local pokemon = findPokemon(oppFold)
						StatusUpdate(pokemon,TheirBox)
					end
					--Pokemon got faint'd
				elseif str:find("&UpdateFaint") then
					if newstring:find(p.Name) then
						local pokemon = findPokemon(pFold)

						faint = true
						battleassociate[pokemon].Visible = false
						FaintAnim(YourPokemon)
					elseif newstring2:find(opposingPlayer.Name) then
						local pokemon = findPokemon(oppFold)
						oppfaint = true
						battleassociate[pokemon].Visible = false
						FaintAnim(TheirPokemon)
					end
					--UpdateHealth
				elseif str:find("&UpdateHealthHP") then
					if newstring:find(p.Name) then
						local number = str:sub(lengthofp+1,condense(str))
						local before,after = gethp(number)
						local pokemon = findPokemon(pFold)
						animateHealth(pokemon,after,YourBox,YourPokemon,before)
					elseif newstring2:find(opposingPlayer.Name) then
						local number = str:sub(opposinum+1,condense(str))
						local before,after = gethp(number)
						local pokemon = findPokemon(oppFold)
						animateHealth(pokemon,after,TheirBox,TheirPokemon,before)
					end
				elseif str:find("&UpdateReturn") then
					if newstring:find(p.Name) then
						returnPokemon(YourPokemon)
					elseif newstring2:find(opposingPlayer.Name) then	
						returnPokemon(TheirPokemon)
					end
				elseif str:find("&UpdatePokeOut") then
					if newstring:find(p.Name) then
						local start,finish = str:find("&UpdatePokeOut")
						local number
						if finish ~= #str then
							number = tonumber(str:sub(finish+1,#str))
						end
						sendOutPokemon(YourPokemon,opposingPlayer,folder,number,turnTable)
					elseif newstring2:find(opposingPlayer.Name) then
						local start,finish = str:find("&UpdatePokeOut")
						local number
						if finish ~= #str then
							number = tonumber(str:sub(finish+1,#str))
						end
						sendOutPokemon(TheirPokemon,opposingPlayer,folder,number,turnTable)	
					end
				elseif str:find("&UpdateMegaForm") then
					if newstring:find(p.Name) then
						local start,finish = str:find("&UpdateMegaForm")
						userMega = true
						local pokemon = findPokemon(pFold)
						local newForm = str:sub(#newstring+1,start-1)
						megaEvolve(YourPokemon.Sprite,newForm,"Back",pokemon)
						battleassociate[pokemon].Image = _G.Pokemon[pokemon.Name]["Sprites"]["Mini"]
					elseif newstring2:find(opposingPlayer.Name) then 
						local start,finish = str:find("&UpdateMegaForm")
						local pokemon = findPokemon(oppFold)
						local newForm = str:sub(#newstring2+1,start-1)
						megaEvolve(TheirPokemon.Sprite,newForm,"Front",pokemon)
						battleassociate[pokemon].Image = _G.Pokemon[pokemon.Name]["Sprites"]["Mini"]
					end
				end

			end

		else
			if not str:find("|") then
				scrolltext(ActualText, str)
			else
				local newText = getRidOfNick(str)
				scrolltext(ActualText, newText)
			end
		end
	end
	if oppfaint == true and faint == false then
		scrolltext(ActualText,"Waiting for your opponent...")
	end
	turnGoingOn = false
end)

function wipeOpp()
	for i,v in ipairs(p.OppPokemon:GetChildren()) do
		v:Remove()
	end
	_G.InWild = false
end
game.ReplicatedStorage.REvents.PVP.BattleResult.OnClientEvent:connect(function(result,op)
	local	Sound = p.PlayerGui.BattleSound
	repeat task.wait() until turnGoingOn == false
	Sound:Stop()
	playBackgroundMusic()
	if result == "Tie" then
		Scene.Visible = false	
		showdown.Player1.Winner.Text = "TIE"
		showdown.Player2.Winner.Text = "TIE"
		showdown.Player1.ImageColor3 = Color3.new(0,0,0)
		showdown.Player2.ImageColor3 = Color3.new(0,0,0)
		showdown.Player1.Winner.Visible = true
		showdown.Player2.Winner.Visible = true

		showdown.Player1.Position = UDim2.new(0,0,-2,0)
		showdown.Player2.Position = UDim2.new(1,-250,4,0)
		showdown.Visible = true
		showdown.Player1:TweenPosition(UDim2.new(0,0,0,0),"Out","Bounce",1.5,false)
		task.wait(2)
		showdown.Player2:TweenPosition(UDim2.new(1,-250,0,0),"Out","Bounce",1.5,false)	
		task.wait(4)
		Sound:Stop()
		playBackgroundMusic()	
		showdown.Visible = false
		script.Parent.Main.BlackScreen.Visible = false
		showdown.Player1.Winner.Visible = false
		showdown.Player2.Winner.Visible = false
	elseif result == p.Name then
		Scene.Visible = false		
		showdown.Player1.Winner.Text = "WINNER"
		showdown.Player2.ImageColor3 = Color3.new(0,0,0)
		showdown.Player1.Winner.Visible = true

		showdown.Player1.Position = UDim2.new(0,0,-2,0)
		showdown.Player2.Position = UDim2.new(1,0,4,0)
		showdown.Visible = true
		showdown.Player1:TweenPosition(UDim2.new(0,0,0,0),"Out","Bounce",1.5,false)
		task.wait(2)
		showdown.Player2:TweenPosition(UDim2.new(1,-250,0,0),"Out","Bounce",1.5,false)	

		task.wait(4)
		Sound:Stop()
		playBackgroundMusic()
		showdown.Visible = false
		script.Parent.Main.BlackScreen.Visible = false
		showdown.Player1.Winner.Visible = false
	elseif result == op.Name then
		Scene.Visible = false		
		showdown.Player2.Winner.Text = "WINNER"
		showdown.Player1.ImageColor3 = Color3.new(0,0,0)
		showdown.Player2.Winner.Visible = true
		showdown.Player1.Position = UDim2.new(0,0,-2,0)
		showdown.Player2.Position = UDim2.new(1,0,4,0)
		showdown.Visible = true
		showdown.Player1:TweenPosition(UDim2.new(0,0,0,0),"Out","Bounce",1.5,false)
		task.wait(2)
		showdown.Player2:TweenPosition(UDim2.new(1,-250,0,0),"Out","Bounce",1.5,false)	

		task.wait(4)
		Sound:Stop()
		playBackgroundMusic()
		showdown.Visible = false
		Scene.Visible = false		
		showdown.Player2.Winner.Visible = false
		script.Parent.Main.BlackScreen.Visible = false
	end
	wipeOpp()
	script.Parent.Main.Leaderboard.Visible = true
end)
