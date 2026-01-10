local ticket = 0
local tableo = {}
local Pokemon = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("Pokemon"))
local Moves = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("Moves"))
local ItemList = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("Items"))
local natureStats = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("NatureStats"))
local Types = require(game.ReplicatedStorage:WaitForChild("Types"))
_G.ExpTables = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("ExpTables"))

local Remotes = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Remotes"))

local randomPokemon = {}
local banlist = {
	["Mewtwo"] = true,
	["Ho-Oh"] = true,
	["Lugia"] = true,
	["Slaking"] = true,
	["Kyogre"] = true,
	["Groudon"] = true,
	["Rayquaza"] = true,
	["Palkia"] = true,
	["Dialga"] = true,
	["Regigigas"] = true,
	["Giratina"] = true,
	["Giratina-O"]  = true,
	["Darkrai"] = true,
	["Arceus"] = true,
	["Volcarona"] = true,
	["Kyurem"] = true,
	["Mewthree, Swag Prince"] = true,
	["Deoxys"] = true,
	["Deoxys-A"] = true,
	["Deoxys-D"] = true,
	["Deoxys-S"] = true,
	["Zekrom"] = true,
	["Reshiram"] = true,
}
local banmoves = {"Double Team","Minimize"}

local HiddenPowerTypes = {
	[0] = "Fighting",
	[1] = "Flying",
	[2] = "Poison",
	[3] = "Ground",
	[4] = "Rock",
	[5] = "Bug",
	[6] = "Ghost",
	[7] = "Steel",
	[8] = "Fire",
	[9] = "Water",
	[10] = "Grass",
	[11] = "Electric",
	[12] = "Psychic",
	[13] = "Ice",
	[14] = "Dragon",
	[15] = "Dark",
}

function getHiddenPower(poke)
	local val = poke.IV
	local Hp = val["HPIV"].Value%2==1 and 1 or 0
	local Atk = val["AtkIV"].Value%2==1 and 2 or 0
	local Def = val["DefIV"].Value%2==1 and 4 or 0
	local Speed = val["SpeedIV"].Value%2==1 and 8 or 0
	local SpA = val["SpAIV"].Value%2==1 and 16 or 0
	local SpD = val["SpDIV"].Value%2==1 and 32 or 0
	local Num = math.floor((Hp+Atk+Def+SpA+SpD+Speed)*15/63)
	return (HiddenPowerTypes[Num]) or "Dark"
end

for i,v in pairs(Pokemon) do
	if v["Mega"] == nil and i ~= "Mewthree, Swag Prince" and i ~= "Ditto" and i ~= "Aegis MKII" then
		table.insert(randomPokemon,i)
	end
end

local battleO = {}
game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleRequest.OnServerEvent:Connect(function(client,challenger,gamemode)
	if challenger then
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleRequest:FireClient(challenger,client,nil,gamemode)
	end
end)

--Let's Calculate the Elo Stats:

--Rnew = Result old + C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
--C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))

--W = 1
--ROld = 1000 (Elo start)
--C1 = 50 
--R = Elo stat
--Rother = Opp Elo Stat
--C2 = 400
--Round up

game.ReplicatedStorage:WaitForChild("REvents").PVP.RatedRequest.OnServerInvoke = function(client,challenger,gamemode)
	if challenger and (gamemode== "Rated" or gamemode == "Unrated") then
		--print("Running")
		local msg = nil
		local tcheck = {}
		local pcheck = {}

		for i,v in ipairs(challenger.PokemonParty:GetChildren()) do
			if not pcheck[Pokemon[v.Name]["Pokedex"]] then
				pcheck[Pokemon[v.Name]["Pokedex"]] = true
			else
				msg = "Your opponent's team is breaking Species Clause! You cannot have 2+ of the same species of Pokemon!"
				break
			end
			if banlist[v.Name] then
				msg = "Your opponent's "..v.Name.." is banned in this "..gamemode.."!"
				break
			end
			for _,Move in ipairs(v.Moves:GetChildren()) do
				if Move.Name == "Double Team" or Move.Name == "Minimize" then
					msg = "Your opponent has a Pokemon with the move "..Move.Name..", which is banned."
					break
				end 
			end
		end
		for i,v in ipairs(client.PokemonParty:GetChildren()) do
			if not tcheck[Pokemon[v.Name]["Pokedex"]] then
				tcheck[Pokemon[v.Name]["Pokedex"]] = true
			else
				msg = "Your team is breaking Species Clause! You cannot have 2+ of the same species of Pokemon!"
				break
			end
			if banlist[v.Name] then
				msg = "You cannot use "..v.Name.." in Rated mode!"
				break
			end
			for _,Move in ipairs(v.Moves:GetChildren()) do
				if Move.Name == "Double Team" or Move.Name == "Minimize" then
					msg = "One of your Pokemon has the move "..Move.Name..", which is banned!"
					break
				end 
			end
		end
		if gamemode == "Rated" and not client.Badges:FindFirstChild("8") then
			msg = "You need 8 badges to battle Rated"
		end
		if gamemode == "Rated" and not challenger.Badges:FindFirstChild("8") then
			msg = "Your opponent needs 8 badges to battle Rated"
		end
		if client.UserId < 1 or challenger.UserId < 1 then
			msg = "Guests can't do Rated battles!"
		end
		if msg == nil then				
			game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleRequest:FireClient(challenger,client,nil,gamemode)
			return true
		else
			return msg
		end
	end
end


game.ReplicatedStorage:WaitForChild("REvents").PVP.PPChecker.OnServerInvoke = function(client,pokemon)
	local t = {}
	for i,v in ipairs(pokemon.Moves:GetChildren()) do
		if v.PP.Value > 0 then
			table.insert(t,v.Name)
		end
	end

	return t
end
function HPcalc(lvl,iv,ev,poke) 
	local ivstat = iv
	local evstat = ev
	if ivstat > 31 then
		ivstat = 0
	end
	if evstat > 255 then
		evstat = 0
	end
	return ((ivstat+2* Pokemon[poke.Name]["Stats"]["HP"] +(evstat/4))*lvl/100)+10+lvl
end



function otherstatcalc(basestat,lvl,iv,ev,nature,poke)
	local ivstat = iv
	local evstat = ev
	if ivstat > 31 then
		ivstat = 0
	end
	if evstat > 255 then
		evstat = 0
	end
	return (((ivstat+2*Pokemon[poke.Name]["Stats"][basestat]+(evstat/4))*lvl/100)+5) * nature
end

function getEVs(Pokemon)
	local EVs = 0
	for i,v in ipairs(Pokemon.EV:GetChildren()) do
		EVs = EVs + v.Value
	end	
	if EVs > 520 then
		for i,v in ipairs(Pokemon.EV:GetChildren()) do
			v.Value = 84
		end	
	end
end

function determinenature(stat,nature)
	if natureStats[stat.." Boost"][nature] then
		return 1.1
	elseif natureStats[stat.." Down"][nature] then
		return .9
	else return 1
	end
end	

local regStats = {"Atk","Def","SpA","SpD","Speed"}

function getranPokemon(folder)
	local Pokemon3 = nil
	repeat Pokemon3 = randomPokemon[math.random(1,#randomPokemon)] task.wait() until not folder:FindFirstChild(Pokemon3)
	return Pokemon3
end

function convertPokemonToLv50(PokemonParty,Destination)
	local alreadycovered = {}
	for i,v in ipairs(PokemonParty:GetChildren()) do
		if v.PartyPosition.Value <= 6 and alreadycovered[v.PartyPosition.Value] == nil then
			getEVs(v)
			alreadycovered[v.PartyPosition.Value] = true
			local lvl50 = v:Clone()
			for _,moves in ipairs(lvl50.Moves:GetChildren()) do
				moves.PP.Value = Moves[moves.Name]["PP"]
			end
			--convert Stats to level 50 (also antihack!!!! not really needed tho)
			for _,prefix in ipairs(regStats) do
				lvl50.Stats[prefix.."Stat"].Value = otherstatcalc(prefix,50,lvl50.IV[prefix.."IV"].Value,lvl50.EV[prefix.."EV"].Value,determinenature(prefix,lvl50.Nature.Value),lvl50)
			end
			lvl50.Experience.Value = _G.ExpTables[Pokemon[lvl50.Name]["ExpType"].."Exp"](50)
			local prefix = "HP"
			lvl50.Stats.HPStat.Value = HPcalc(50,lvl50.IV[prefix.."IV"].Value,lvl50.EV[prefix.."EV"].Value,lvl50)
			lvl50.Lvl.Value = 50
			lvl50.CurrentHP.Value = lvl50.Stats.HPStat.Value
			lvl50.Parent = Destination
		end
	end
end

function convertMega(pokemon)
	for _,prefix in ipairs(regStats) do
		pokemon.Stats[prefix.."Stat"].Value = otherstatcalc(prefix,50,pokemon.IV[prefix.."IV"].Value,pokemon.EV[prefix.."EV"].Value,determinenature(prefix,pokemon.Nature.Value),pokemon)
	end
end
function findLevel(poke)
	local curlv = 100
	local stats = 0
	for i,v in pairs(Pokemon[poke]["Stats"]) do
		stats = stats + v
	end
	local newval = math.floor(stats/100*4.5)
	curlv = curlv - newval
	return curlv
end
--CountDown(Player1,Player2,Folder,scales)
function CountDown(Player1,Player2,Folder,scales) --tableo[tonumber(Folder.Name)][Player1]
	--	Folder[Player1.Name.."Time"].Value = 120
	--	Folder[Player2.Name.."Time"].Value = 120
	--	
	--	spawn(function() 
	--	while Folder[Player1.Name.."Time"].Value <= 120  do
	--	Folder[Player1.Name.."Time"].Value = Folder[Player1.Name.."Time"].Value - 1 
	--	task.wait(1)
	--	if Folder[Player1.Name.."Time"].Value  == 0 then
	--		for i,v in ipairs(Folder[Player1.Name]:GetChildren()) do
	--			v.CurrentHP.Value = 0
	--			v.Status.Value = "Faint"
	--		end
	--		WinCheck(Folder,Folder[Player1.Name],Folder[Player2.Name],Player1,Player2)
	--	end
	--	end
	--	end)
	--	spawn(function() 
	--	while Folder[Player1.Name.."Time"].Value <= 120  do
	--	Folder[Player2.Name.."Time"].Value = Folder[Player2.Name.."Time"].Value - 1 
	--	task.wait(1)
	--	if Folder[Player2.Name.."Time"].Value  == 0 then
	--		for i,v in ipairs(Folder[Player2.Name]:GetChildren()) do
	--			v.CurrentHP.Value = 0
	--			v.Status.Value = "Faint"
	--		end
	--		WinCheck(Folder,Folder[Player1.Name],Folder[Player2.Name],Player1,Player2)
	--	end
	--	end
	--	end)
end

function megaRandom(poke)
	for i,v in pairs(ItemList) do
		if v["Requirement"] and v["Requirement"] == poke.Name then
			poke.HeldItem.Value = i
		end
	end
end

game.ReplicatedStorage:WaitForChild("REvents").PVP.AnswerRequest.OnServerEvent:Connect(function(client,Answer,playerAgainst,gamemode)
	if Answer ~= "Accept" then
		--print("RUNNING THIS")
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleRequest:FireClient(playerAgainst,client,Answer)
	elseif Answer == "Accept" then
		ticket = ticket + 1
		tableo[ticket] = {}
		tableo[ticket][playerAgainst] = false
		tableo[ticket][client] = false
		local Folder = Instance.new("Folder",game.ReplicatedStorage:WaitForChild("BattleStorage"))
		Folder.Name = ticket
		local Player1 = Instance.new("Folder",Folder)
		Player1.Name = client.Name
		local Player2 = Instance.new("Folder",Folder)
		Player2.Name = playerAgainst.Name
		local StringValue = Instance.new("StringValue",Folder)
		StringValue.Name = "Type"
		StringValue.Value = gamemode
		if gamemode == "Anything Goes" or gamemode == "Rated" or gamemode == "Unrated" then
			convertPokemonToLv50(client.PokemonParty,Player1)
			convertPokemonToLv50(playerAgainst.PokemonParty,Player2)
		else

			for i = 1, 6 do 
				local d = getranPokemon(Player1)
				local poke = _G.pokiemanz(workspace,d,Player1,findLevel(d),true,true,"PvpHandler")
				local allowedItems = {"Focus Sash","Wise Glasses","Wide Lens","Expert Belt","Leftovers","Life Orb","Novice Belt","Eviolite"}
				if canEvolve(poke) == false then
					allowedItems = {"Focus Sash","Wise Glasses","Wide Lens","Expert Belt","Leftovers","Life Orb","Novice Belt"}
				end
				poke.HeldItem.Value = allowedItems[math.random(1,#allowedItems)]
				megaRandom(poke)
				poke.PartyPosition.Value = i
			end
			for i = 1, 6 do
				local d = getranPokemon(Player2)
				local poke = _G.pokiemanz(workspace,d,Player2,findLevel(d),true,true,"PvpHandler")
				local allowedItems = {"Expert Belt","Leftovers","Life Orb","Novice Belt","Eviolite"}
				if canEvolve(poke) == false then
					allowedItems = {"Expert Belt","Leftovers","Life Orb","Novice Belt"}
				end
				poke.HeldItem.Value = allowedItems[math.random(1,#allowedItems)]
				megaRandom(poke)
				poke.PartyPosition.Value = i
			end
		end
		local clientTime = Instance.new("IntValue",Folder)
		local paTime = Instance.new("IntValue",Folder)
		paTime.Value = 120
		paTime.Name = playerAgainst.Name.."Time"
		clientTime.Value = 120
		clientTime.Name = client.Name.."Time"
		game.ReplicatedStorage:WaitForChild("REvents").PVP.LeadSelection:FireClient(client,playerAgainst,Folder,ticket)
		game.ReplicatedStorage:WaitForChild("REvents").PVP.LeadSelection:FireClient(playerAgainst,client,Folder,ticket)

	end
end)


function findPokemon(NewLead,Folder)
	local currentLead
	local newLeadSlot = NewLead.PartyPosition.Value
	for i,v in ipairs(Folder:GetChildren()) do
		if v.PartyPosition.Value == 1 then
			currentLead = v
		end
	end
	currentLead.PartyPosition.Value = newLeadSlot
	NewLead.PartyPosition.Value = 1
end

function doubleCheck(table,client,op)
	if table[client] ~= nil and table[client] ~= false and  table[op] ~= nil and table[op] ~= false  then
		return true
	end
	--	for i,v in pairs(table) do
	--		if v == false or v == nil then
	--			return false
	--		end
	--	end
	return false
	--    return true
end

function restartTurn(table,op,t)
	for i,v in pairs(table) do
		--print(i.Name,v)
		tableo[i] = false 
	end

end

local modifierstat = {
	[-7] = .25,
	[-6] = .25,
	[-5] = .285,
	[-4] = .33,
	[-3] = .4,
	[-2] = .5,
	[-1] = .66,
	[0] = 1,
	[1] = 1.5,
	[2] = 2,
	[3] = 2.5,
	[4] = 3,
	[5] = 3.5,
	[6] = 4,
	[7] = 4
}

local accstat = {
	[-7] = .33,
	[-6] = .33,
	[-5] = .375,
	[-4] = .428,
	[-3] = .5,
	[-2] = .6,
	[-1] = .75,
	[0] = 1,
	[1] = 1.33,
	[2] = 1.66,
	[3] = 2,
	[4] = 2.33,
	[5] = 2.66,
	[6] = 3,
	[7] = 3
}
local evadestat = {
	[-7] = 3,
	[-6] = 3,
	[-5] = 2.66,
	[-4] = 2.33,
	[-3] = 2,
	[-2] = 1.66,
	[-1] = 1.33,
	[0] = 1,
	[1] = .75,
	[2] = .6,
	[3] = .5,
	[4] = .428,
	[5] = .375,
	[6] = .33,
	[7] = .33
}

fullnamestats = {
	["Atk"] = "Attack",
	["Def"] = "Defense",
	["SpA"] = "Special Attack",
	["SpD"] = "Special Defense",
	["Speed"] = "Speed",
	["Acc"] = "Accuracy",
	["Evade"] = "Evasion" 
}
buffstrings = {
	[-2] = " harshly fell!",
	[-1] = " fell!",
	[1] = " rose!",
	[2] = " sharply rose!"
}
statusstrings = {
	["Paralysis"] = " was paralyzed!",
	["Sleep"]  = " fell asleep!",
	["Burn"] =  " was burned!",
	["Faint"] = " fainted!",
	["Poison"] = " was poisoned!",
	["BadlyPoison"] = " was badly poisoned!",
	["Freeze"] = " was frozen!"
}
immunestatus = {
	["Burn"] = "Fire",
	["Poison"] = "Poison",
	["BadlyPoison"] = "Poison",
	["Freeze"] = "Ice",
	["Paralysis"] = "Electric",
}

function checkWin(folder)
	for i,v in ipairs(folder:GetChildren()) do
		if v.Status.Value ~= "Faint" then
			return false
		end
	end
	return true
end

Remotes.Server:Get("ChangeLead"):Connect(function(client,ticket,newPoke,playerAgainst)
	battleO[client] = {
		["Modifier"] = {
			["Atk"] = 0,
			["Def"] = 0,
			["SpA"] = 0,
			["SpD"] = 0,
			["Speed"] = 0,
			["Acc"] = 0,
			["Evade"] = 0 
		},
		["Confusion"] = 0,
		["StatusTurns"] = 0,
		["ProtectCounter"] = {1,false},
		["Roosting"] = false,
		["DestinyBond"] = false,
		["ToxicSpikes"] = 0,
		["LeechSeed"] = false,
		["Screens"] = {
			["Reflect"] = 0,
			["LightScreen"] = 0
		},
		["BadlyPoison"] = .0625,
		["MegaEvolve"] = false,
		["BerserkTriggered"] = false,
		["Weather"] = {
			["Type"] = "None",
			["Turns"] = 0
		}
	}
	if tableo[ticket] then
		tableo[ticket][client] = true
	else
		tableo[ticket] = {}
		tableo[ticket][client] = true

	end
	findPokemon(newPoke,game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket):FindFirstChild(client.Name))
	if doubleCheck(tableo[ticket],client,playerAgainst) then
		tableo[tonumber(ticket)][client] = false
		tableo[tonumber(ticket)][playerAgainst] = false
		game.ReplicatedStorage:WaitForChild("REvents").PVP.Showdown:FireClient(client,ticket,nil,"Begin",playerAgainst,game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket))
		game.ReplicatedStorage:WaitForChild("REvents").PVP.Showdown:FireClient(playerAgainst,ticket,nil,"Begin",client,game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket))
		CountDown(client,playerAgainst,game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket),battleO)
	end
end)


game.ReplicatedStorage:WaitForChild("REvents").PVP.Showdown.OnServerEvent:Connect(function(client,ticket,canceller,action,playerAgainst)
	tableo[ticket] = nil
	if game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket) then
		game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket):Destroy()
	end
	game.ReplicatedStorage:WaitForChild("REvents").PVP.Showdown:FireClient(client,ticket,client,"Cancel",playerAgainst)
	game.ReplicatedStorage:WaitForChild("REvents").PVP.Showdown:FireClient(playerAgainst,ticket,client,"Cancel",client)
end)


function getPokeOut(folder)
	for i,v in ipairs(folder:GetChildren()) do
		if v:FindFirstChild("PartyPosition") and v.PartyPosition.Value == 1 then
			return v
		end
	end
end


function moveFirst(poke1, poke2, poke1Mod, poke2Mod, Move1, Move2)

	local para1 = 1
	local para2 = 1 -- if Pokemon is paralyzed, their speed will be cut to 25%

	if poke1.Status.Value == "Paralysis" then
		para1 = .5
	end
	if poke2.Status.Value == "Paralysis" then
		para2 = .5
	end
	local poke1Speed = poke1.Stats.SpeedStat.Value * modifierstat[poke1Mod] * para1
	local poke2Speed = poke2.Stats.SpeedStat.Value * modifierstat[poke2Mod] * para2

	local speedT = {
		[poke1Speed] = poke1,
		[poke2Speed] = poke2,
	}

	local Prior1 = (Moves[Move1]["Priority"] ~= nil and Moves[Move1]["Priority"]) or 0
	local Prior2 = (Moves[Move2]["Priority"] ~= nil and Moves[Move2]["Priority"]) or 0
	
	-- Gale Wings Check
	if _G.Pokemon[poke1.Name]["Ability"] and _G.Pokemon[poke1.Name]["Ability"]  == "Gale Wings" then
		if Moves[Move1]["Type"] == "Flying" and
			Moves[Move1] ~= "Hidden Power" then
			Prior1 = Prior1 + 1
		end
	end
	if _G.Pokemon[poke2.Name]["Ability"] and _G.Pokemon[poke2.Name]["Ability"]  == "Gale Wings" then
		if Moves[Move2]["Type"] == "Flying" and
			Moves[Move2] ~= "Hidden Power" then
			Prior2 = Prior2 + 1
		end
	end
	
	if _G.Pokemon[poke1.Name]["Ability"] and _G.Pokemon[poke1.Name]["Ability"]  == "Prankster" and Moves[Move1]["AttackType"] == "Status" then
		Prior1 = Prior1 + 1
	end
	if _G.Pokemon[poke2.Name]["Ability"] and _G.Pokemon[poke2.Name]["Ability"]  == "Prankster" and Moves[Move2]["AttackType"] == "Status" then
		Prior2 = Prior2 + 1
	end
	local priorT = {
		[Prior1] = poke1,
		[Prior2] = poke2,
	}
	if (Prior1 ~= 0 or Prior2 ~= 0) and (Prior1 ~= Prior2) then
		return  priorT[math.max(Prior1,Prior2)], priorT[math.min(Prior1,Prior2)]
	end
	if Prior1 == Prior2 and  poke1Speed == poke2Speed then 
		print("Speed tie!")
		local t = {poke1,poke2}
		local first = math.random(1,#t)
		local second = (first == 1 and 2) or 1
		return t[first],t[second]
	else return speedT[math.max(poke1Speed,poke2Speed)],speedT[math.min(poke1Speed,poke2Speed)]
	end
end



function nickname(pokemon)
	if pokemon:FindFirstChild("Nickname") and pokemon.Nickname.Value ~= "" then
		return pokemon.Nickname.Value
	end
	return pokemon.Name
end

local abilitydenier = {
	["Teravolt"] = true,
	["Turboblaze"] = true,
	["Mold Breaker"] = true,
	["Bad Dreams"] = true,
}
function critfunc(critchance,attacker,defender)
	local critblah = math.random(0,1000)
	local actualcrit = critchance
	if abilitydenier[_G.Pokemon[attacker.Name]["Ability"]] == nil then
		if _G.Pokemon[defender.Name]["Ability"] and  _G.Pokemon[defender.Name]["Ability"] == "Shell Armor" then
			return 1
		end
		if _G.Pokemon[defender.Name]["Ability"] and  _G.Pokemon[defender.Name]["Ability"] == "Shell Armor" then
			return 1
		end
	end
	if _G.Pokemon[attacker.Name]["Ability"] and  _G.Pokemon[attacker.Name]["Ability"] == "Super Luck" then
		actualcrit = actualcrit * 2
	end
	if critblah <= actualcrit then
		return 2
	else return 1
	end
end
function sleepClauseCheck(team)
	for i,v in ipairs(team:GetChildren()) do
		if v.Status.Value == "Sleep" then
			return false
		end
	end
	return true
end
function weak(w,pokecfg,ability)
	if ability == "Immune" then
		return false
	elseif w > 1 then
		task.wait(.3)
		return "It's super effective!"
	elseif w < 1 and w ~= 0 then
		task.wait(.3)
		return "It's not very effective..."
	elseif w == 0  and ability == nil then
		task.wait(.3)
		return "It doesn't affect "..nickname(pokecfg).."."

	elseif ability == "Levitate" then
		return pokecfg.Name.." has Levitate!"

	elseif w==1 then
		return false
	end


end
local lowkicktable = {
	[1] = {20,.1,21.8},
	[2] = {40,21.9,55},
	[3] = {60,55.1,110},
	[4] = {80,110.1,220.2},
	[5] = {100,220.3,440.7},
}
		--[[===============
		Weight function
			===============
			--]]
function weightdmg(pokemon)
	for _,dmg in ipairs(lowkicktable) do	
		if Pokemon[pokemon.Name]["Weight"] >= dmg[2] and Pokemon[pokemon.Name]["Weight"] <= dmg[3] then
			return dmg[1]
		end
	end
	return 120
end
function canEvolveName(poke)
	if #_G.Pokemon[poke]["Evolution"] > 0 then
		return true
	end
	if _G.Pokemon[poke]["EvolutionStone"] then
		return true
	end
	return false
end

function canEvolve(poke)
	if #_G.Pokemon[poke.Name]["Evolution"] > 0 then
		return true
	end
	if _G.Pokemon[poke.Name]["EvolutionStone"] then
		return true
	end
	return false
end
local boostedtypes = {
	["Aerilate"] = "Flying",
	["Pixilate"] = "Fairy",
	["Refrigerate"] = "Ice",
}
local pinchAbilities = {
	["Swarm"] = "Bug",
	["Overgrow"] = "Grass",
	["Blaze"] = "Fire",
	["Torrent"] = "Water"
}
local weatherAbilities = {
	["Sand Stream"] = "Sandstorm",
	["Drizzle"] = "Rain",
	["Drought"] = "Sun"
}

function isInPinch(pokemon)
	if pokemon.CurrentHP.Value < math.ceil(pokemon.Stats.HPStat.Value) then
		return true
	else
		return false
	end
end

function SheerForceCheck(move)
	for i,v in pairs(_G.Moves[move]["Effects"]) do
		if i == "Status" then
			return true
		elseif i == "Stats" then
			for _,derp in pairs(v) do
				if derp[1] == "User" and derp[2] > 0 then
					return true
				elseif derp[1] == "Target" and derp[2] < 0 then
					return true
				end 
			end
		elseif i == "Confusion" then
			return true
		elseif i == "Flinch" then
			return true
		end
	end
	return false
end
function megaStone(item)
	if ItemList[item]["Requirement"] then
		return true
	end
	return false
end
function dmgCalc(Attacker, Defender, usedMove, AtkTable, DefTable,turnTable)
	local Burn = 1 
	if Attacker.Status.Value == "Burn" then
		Burn = .5
	end		
	--print(Defender.Name,canEvolve(Defender))
	local crithit = critfunc(Moves[usedMove]["CritChance"],Attacker,Defender)
	local weakness = 1
	local immune = nil
	local AtkMod = AtkTable["Mod"]
	local DefMod = DefTable["Mod"]
	local typeMove = Moves[usedMove]["Type"]

	local power =  Moves[usedMove]["Power"]
	if usedMove == "Knock Off" and Defender.HeldItem.Value ~= "" and not megaStone(Defender.HeldItem.Value) then
		power = power * 2
	end
	if usedMove == "Hidden Power" then
		typeMove = getHiddenPower(Attacker)
	elseif _G.Moves[usedMove]["RandomType"] ~= nil then --For the move Present
		local types = {"Fairy","Flying","Electric","Steel","Ice","Fire","Grass","Dragon","Psychic","Dark","Bug","Ground","Ghost","Poison","Fighting","Water","Normal"}
		typeMove = types[math.random(#types)]
	end
	if type(power) == "number"  then
		if _G.Pokemon[Attacker.Name]["Ability"] == "Sheer Force" and SheerForceCheck(usedMove) then
			power = power * 1.3
		end
		if _G.Pokemon[Attacker.Name]["Ability"] and boostedtypes[_G.Pokemon[Attacker.Name]["Ability"]] then
			if usedMove == "Facade" and Attacker.Status.Value ~= "" then
				power = power * 2
			end
			if _G.Moves[usedMove]["Type"] == "Normal" then

				power = power * 1.2
				typeMove =  boostedtypes[_G.Pokemon[Attacker.Name]["Ability"]]
			end
		elseif _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"] == "Tough Claws" and _G.Moves[usedMove]["Contact"] then
			power = power * 1.33
			print("tough claws boost")
		elseif _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"] == "Iron Fist" and _G.Moves[usedMove]["Punching"] then
			power = power * 1.2
			print("iron fist boost")
		elseif _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"] == "Mega Launcher" and _G.Moves[usedMove]["Pulse"] then
			power = power * 1.5
			print("mega launcher boost")
		elseif _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"] == "Strong Jaw" and _G.Moves[usedMove]["Biting"] then
			power = power * 1.5
			print("strong jaw boost")
		elseif _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"] == "Steelworker" and _G.Moves[usedMove]["Type"] == "Steel" then
			power = power * 1.5
			print("steelworker boost")
		elseif _G.Pokemon[Attacker.Name]["Ability"] and pinchAbilities[_G.Pokemon[Attacker.Name]["Ability"]] and typeMove == pinchAbilities[_G.Pokemon[Attacker.Name]["Ability"]] and isInPinch(Attacker) then
			power = power * 1.5
			print("pinch ability")
		end
	end
	if type(power) == "number" then
		if _G.Moves[usedMove]["AttackType"] == "Special" and Attacker.HeldItem.Value == "Wise Glasses" then
			power = power * 1.1
		end
	end
	local dmgcalc
	local typetable = Types[typeMove]
	local types = Pokemon[Defender.Name]["Type"]

	for i,v in pairs(types) do
		--Immune
		if v == "Flying" and DefTable["Table"]["Roosting"] == true then

		else
			for _,weak in ipairs(typetable["0x"]) do
				if v == weak then
					weakness = weakness * 0
				end
			end
			if Moves[usedMove]["HitsEverything"] ~= nil and weakness == 0 then
				weakness = 1
			end
			--Resistant
			for _,weak in ipairs(typetable[".5x"]) do
				if v == weak then
					weakness = weakness * .5
				end
			end
			--SuperEffective
			for _,weak in ipairs(typetable["2x"]) do
				if v == weak then
					weakness = weakness * 2
				end
			end
		end
	end
	local immunities = {
		["Flame Absorb"] = {"Fire"," absorbed the Fire move with Flame Absorb!"},
		["Water Absorb"] = {"Water", " absorbed the Water move with Water Absorb!"},
		["Volt Absorb"] = {"Electric", " absorbed the Electric move with Volt Absorb!"},
		["Sap Sipper"] = {"Grass", " ate the Grass move with Sap Sipper"},
	}
	local reduceDamage = {
		["Filter"] = true,
		["Solid Rock"] = true
	}
	if abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil and _G.Pokemon[Defender.Name]["Ability"] and immunities[_G.Pokemon[Defender.Name]["Ability"]] and Moves[usedMove]["Type"] ==  immunities[_G.Pokemon[Defender.Name]["Ability"]][1]then
		weakness = 0

		immune = "Immune"

		local hpbefore = Defender.CurrentHP.Value
		local maxHP = Defender.Stats.HPStat.Value
		table.insert(turnTable,nickname(Defender)..immunities[_G.Pokemon[Defender.Name]["Ability"]][2])
		if hpbefore ~= maxHP then
			Defender.CurrentHP.Value = math.min(hpbefore+math.floor(maxHP/4),maxHP)
			table.insert(turnTable,Defender.Parent.Name..hpbefore.."@"..Defender.CurrentHP.Value.."&UpdateHealthHP") 
		end		
	elseif weakness > 1 and  _G.Pokemon[Defender.Name]["Ability"] and reduceDamage[ _G.Pokemon[Defender.Name]["Ability"]] then
		weakness = weakness * .75

	end				
	if  abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil and _G.Pokemon[Defender.Name]["Ability"] and Pokemon[Defender.Name]["Ability"] == "Levitate" and Moves[usedMove]["Type"] == "Ground" then
		weakness = 0
		immune = "Levitate"
	end
	local STAB = 1
	for i,v in pairs(Pokemon[Attacker.Name]["Type"]) do
		if  typeMove == v then
			STAB = 1.5
		end
	end



	if power == false then
		if Moves[usedMove]["Effects"]["PowerWeight"] ~= nil then
			power = weightdmg(Defender)
		end
	end
	if power <= 60 and Pokemon[Attacker.Name]["Ability"] and Pokemon[Attacker.Name]["Ability"] == "Technician" then
		power = power * 1.5
	elseif STAB == 1.5  and Pokemon[Attacker.Name]["Ability"] and Pokemon[Attacker.Name]["Ability"] == "Adaptability" then
		STAB = 2
	end

	local AtkerMod,DeferMod,AtkStat,DefStat  = nil

	if Moves[usedMove]["AttackType"] == "Physical" then
		AtkerMod = AtkMod["Atk"]
		DeferMod = DefMod["Def"]
		AtkStat = Attacker.Stats.AtkStat.Value
		DefStat = Defender.Stats.DefStat.Value
		if  _G.Pokemon[Attacker.Name]["Ability"] and (_G.Pokemon[Attacker.Name]["Ability"] == "Huge Power" or _G.Pokemon[Attacker.Name]["Ability"] == "Pure Power") then

			AtkStat = AtkStat * 2
		elseif Attacker.Status.Value ~= "" and  _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"] == "Guts" then
			AtkStat = AtkStat * 1.5
			Burn = 1
		end
		if  Defender.Status.Value ~= "" and (_G.Pokemon[Defender.Name]["Ability"] == "Marvel Scale") then
			DefStat = DefStat * 1.5
		end
	else
		Burn = 1
		AtkerMod = AtkMod["SpA"]
		DeferMod = DefMod["SpD"]
		AtkStat = Attacker.Stats.SpAStat.Value
		DefStat = Defender.Stats.SpDStat.Value
	end
	if usedMove == "Foul Play" then
		AtkStat = Defender.Stats.AtkStat.Value
		AtkerMod = DefMod["Atk"]
	end
	if Moves[usedMove]["AffectDefense"] ~= nil then
		DefStat = Defender.Stats.DefStat.Value
		if  Defender.Status.Value ~= "" and (_G.Pokemon[Defender.Name]["Ability"] == "Marvel Scale") then
			DefStat = DefStat * 1.5
		end
		DeferMod = DefMod["Def"]
	end
	if Defender.HeldItem.Active.Value == true then

		if Defender.HeldItem.Value == "Eviolite" and canEvolve(Defender) then
			DefStat = DefStat * 1.5
		end
	end
	if crithit == 1 then
		dmgcalc= math.ceil((((2 *  Attacker.Lvl.Value + 10)/250 *( AtkStat*modifierstat[AtkerMod]*Burn / (DefStat*modifierstat[DeferMod])) * power + 2) * crithit * STAB * weakness * math.random(85,100) / 100) )
	elseif crithit == 2 then
		--print("Critical hit! SWEET!")
		if AtkerMod < 0 then
			AtkerMod = 0
		end
		if DeferMod < 0 then
			DeferMod = 0
		end
		dmgcalc= math.ceil((((2 *  Attacker.Lvl.Value + 10)/250 * ( AtkStat*modifierstat[AtkerMod]*Burn / (DefStat*modifierstat[DeferMod])) * power + 2) * crithit * STAB * weakness * math.random(85,100) / 100) )
	end
	
	-- Cotton Down Check - stat modification only
	if dmgcalc > 0 and Defender.CurrentHP.Value > 0 then
		if _G.Pokemon[Defender.Name]["Ability"] == "Cotton Down" and abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil then
			local opponentTable = (Defender.Parent.Name == Attacker.Parent.Name) and DefTable or AtkTable
			if opponentTable["Mod"]["Speed"] > -6 then
				opponentTable["Mod"]["Speed"] = opponentTable["Mod"]["Speed"] - 1
			end
		end
	end
	
	if Pokemon[Defender.Name]["Ability"] and Pokemon[Defender.Name]["Ability"] == "Thick Fat" and (Moves[usedMove]["Type"] == "Fire" or Moves[usedMove]["Type"] == "Ice") then
		dmgcalc = math.floor(dmgcalc/2)
	end
	if crithit ~= 2 and Moves[usedMove]["AttackType"] == "Physical" and DefTable["Table"]["Screens"]["Reflect"] > 0  then

		dmgcalc = math.ceil(dmgcalc/2)
	end
	if crithit ~= 2 and Moves[usedMove]["AttackType"] == "Special" and DefTable["Table"]["Screens"]["LightScreen"] > 0  then
		dmgcalc = math.ceil(dmgcalc/2)
	end

	-- Weather modifiers
	local weather = AtkTable["Table"]["Weather"]["Type"]
	local moveType = Moves[usedMove]["Type"]

	if weather == "Sandstorm" and moveType == "Rock" then
		dmgcalc = math.ceil(dmgcalc * 1.3)
	elseif weather == "Rain" then
		-- Water moves get 1.5x boost in rain
		if moveType == "Water" then
			dmgcalc = math.ceil(dmgcalc * 1.5)
			-- Fire moves get halved in rain
		elseif moveType == "Fire" then
			dmgcalc = math.ceil(dmgcalc * 0.5)
		end
	elseif weather == "Sun" then
		-- Fire moves get 1.5x boost in sun
		if moveType == "Fire" then
			dmgcalc = math.ceil(dmgcalc * 1.5)
			-- Water moves get halved in sun
		elseif moveType == "Water" then
			dmgcalc = math.ceil(dmgcalc * 0.5)
		end
	end
	
	
	return dmgcalc, weakness, crithit, immune
end

function recoil(pokecfg,move, dmg,turnTable)
	local dmgtaken = 0
	if _G.Pokemon[pokecfg.Name]["Ability"] ~= "Rock Head" then
		if Moves[move]["Effects"]["Recoil"] == "dmgdone" then
			dmgtaken = math.ceil(dmg/Moves[move]["Effects"]["Rate"])
		else
			dmgtaken = math.ceil(pokecfg.Stats.HPStat.Value/Moves[move]["Effects"]["Recoil"])
		end
		local curhp = pokecfg.CurrentHP.Value
		pokecfg.CurrentHP.Value = math.max(0,pokecfg.CurrentHP.Value - dmgtaken)
		table.insert(turnTable,nickname(pokecfg).." is hit with recoil!")
		table.insert(turnTable,pokecfg.Parent.Name..curhp.."@"..pokecfg.CurrentHP.Value.."&UpdateHealthHP")
		checkFaint(pokecfg,turnTable)
	end
end

function gainhealth(Attacker, usedmove, dmg,turnTable)
	local hpbefore = Attacker.CurrentHP.Value
	local maxHP = Attacker.Stats.HPStat.Value
	local hpm = dmg*Moves[usedmove]["Effects"]["Absorb"]
	if hpbefore ~= maxHP then
		Attacker.CurrentHP.Value = math.min(hpbefore+hpm,maxHP)
		table.insert(turnTable,nickname(Attacker).." regained health!")
		table.insert(turnTable,Attacker.Parent.Name..hpbefore.."@"..Attacker.CurrentHP.Value.."&UpdateHealthHP") 
	end
end

function isType(poke,type)
	for i,v in pairs(_G.Pokemon[poke.Name]["Type"]) do
		if v == type then
			return true
		end
	end
	return false
end

function isLevitating(pokemon)
	if isType(pokemon,"Flying") then
		return true
	end
	if _G.Pokemon[pokemon.Name]["Ability"] and _G.Pokemon[pokemon.Name]["Ability"] == "Levitate" then
		return true
	end 
	return false
end

function gainleechhealth(Attacker,value,turnTable)
	local oldHP = Attacker.CurrentHP.Value

	if oldHP ~= Attacker.Stats.HPStat.Value then

		Attacker.CurrentHP.Value = math.min(Attacker.Stats.HPStat.Value,value+Attacker.CurrentHP.Value)
		table.insert(turnTable,nickname(Attacker).." regained health!")
		table.insert(turnTable,Attacker.Parent.Name..oldHP.."@"..Attacker.CurrentHP.Value.."&UpdateHealthHP") 

	end
end

function leechdamage(Defender,Attacker,turnTable)

	local oldHP = Defender.CurrentHP.Value
	if Attacker.Status.Value ~= "Faint" and Defender.Status.Value ~= "Faint" and Defender.Stats.HPStat.Value > 0 then
		local amountlost = math.floor(math.min(Defender.CurrentHP.Value,Defender.Stats.HPStat.Value / 8))
		Defender.CurrentHP.Value = math.max(Defender.CurrentHP.Value-amountlost,0)
		table.insert(turnTable,Defender.Parent.Name..oldHP.."@"..Defender.CurrentHP.Value.."&UpdateHealthHP") 
		table.insert(turnTable,nickname(Defender).." had its energy sapped!")
		gainleechhealth(Attacker,amountlost,turnTable)
		checkFaint(Defender,turnTable)
	end
end
function specialEffect(Attacker, Defender, usedMove, AtkTable, DefTable, turnTable,position,dmg) --wass a Special Effect (i.e. status inducing, confusion inducing, etc.) used?	
	local flinch = false
	local weakness = 1
	local types = Pokemon[Defender.Name]["Type"]
	local typetable = Types[Moves[usedMove]["Type"]]
	if _G.Moves[usedMove]["RandomType"] ~= nil then --For the move Present
		local types = {"Fairy","Flying","Electric","Steel","Ice","Fire","Grass","Dragon","Psychic","Dark","Bug","Ground","Ghost","Poison","Fighting","Water","Normal"}
		typetable = Types[types[math.random(#types)]]
	end
	for i,v in pairs(types) do
		--Immune
		for _,weak in ipairs(typetable["0x"]) do
			if v == weak then
				weakness = weakness * 0
			end
		end
		if Moves[usedMove]["HitsEverything"] ~= nil and weakness == 0 then
			weakness = 1
		end
		--Resistant
		for _,weak in ipairs(typetable[".5x"]) do
			if v == weak then
				weakness = weakness * .5
			end
		end
		--SuperEffective
		for _,weak in ipairs(typetable["2x"]) do
			if v == weak then
				weakness = weakness * 2
			end
		end
	end
	--	if weakness > 0 then
	for effect,info in pairs(Moves[usedMove]["Effects"]) do
		local moveTable = {
			["User"] = {AtkTable,Attacker},
			["Target"] = {DefTable,Defender}
		}
		if effect == "DB" then
			AtkTable["Table"]["DestinyBond"] = true
			table.insert(turnTable, nickname(Attacker).." is trying to take the foe with it!")
		elseif effect == "Protect" then
			local ProtectChance = AtkTable["Table"]["ProtectCounter"][1]
			local succeed = math.random(1,ProtectChance)
			if succeed == 1 then
				AtkTable["Table"]["ProtectCounter"] = {AtkTable["Table"]["ProtectCounter"][1]*2,true}
				table.insert(turnTable,nickname(Attacker).." is protecting itself!")
			else
				table.insert(turnTable,"But it failed!")
				AtkTable["Table"]["ProtectCounter"] = {1,false}
			end

		elseif effect == "LoseFlying" then
			AtkTable["Table"]["Roosting"] = true
		elseif effect == "ToxicSpikes" then
			local TSpikes = DefTable["Table"]["ToxicSpikes"]
			if TSpikes < 2 then
				DefTable["Table"]["ToxicSpikes"] = DefTable["Table"]["ToxicSpikes"] + 1
				table.insert(turnTable,nickname(Attacker).." scattered poison spikes!")
			else
				table.insert(turnTable,"But it failed!")
			end
		elseif effect == "BreakScreen" and (DefTable["Table"]["Screens"]["Reflect"] > 0 or DefTable["Table"]["Screens"]["LightScreen"] > 0) then
			DefTable["Table"]["Screens"]["Reflect"] = 0
			DefTable["Table"]["Screens"]["LightScreen"] = 0
			table.insert(turnTable,nickname(Attacker).." shattered the barrier!")
		elseif effect == "Reflect" then
			local raise = 5
			if Attacker.HeldItem.Value == "Light Clay" then
				raise = 8
			end 
			table.insert(turnTable,"Reflect raised the team of "..nickname(Attacker).."'s Defense!")
			AtkTable["Table"]["Screens"]["Reflect"] = raise
		elseif effect == "LightScreen" then
			local raise = 5
			if Attacker.HeldItem.Value == "Light Clay" then
				raise = 8
			end 
			table.insert(turnTable,"Light Screen raised the team of "..nickname(Attacker).."'s Sp. Defense!")
			AtkTable["Table"]["Screens"]["LightScreen"] = raise

		elseif effect == "Leech" then
			if not isType(Defender,"Grass") then
				if DefTable["Table"]["LeechSeed"] == false then
					DefTable["Table"]["LeechSeed"] = true
					table.insert(turnTable,nickname(Defender).." was seeded!")

				elseif  DefTable["Table"]["LeechSeed"] ==  true then

					table.insert(turnTable,nickname(Defender).." is already seeded!")
				end
			else
				table.insert(turnTable,"But it failed...")
			end
		elseif effect == "Stats" then 


			for stat,tableInfo in pairs(info) do
				local chance = math.random(1,100)
				--if chance == 50
				--if table
				local comparechance =tableInfo[3]
				if _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"]  == "Serene Grace" then
					comparechance = comparechance * 2
				end 
				if _G.Pokemon[Attacker.Name]["Ability"] == "Sheer Force" and _G.Moves[usedMove]["AttackType"] ~= "Status" then
					if tableInfo[1] == "Target" and tableInfo[2] < 0 then
						comparechance = 0
					elseif tableInfo[1] == "User" and tableInfo[2] > 0 then
						comparechance = 0
					end
				end
				if chance <= comparechance then
					if tableInfo[1] == "Target" and tableInfo[2] < 0 and  _G.Pokemon[Defender.Name]["Ability"] == "Clear Body" then
						table.insert(turnTable,nickname(Defender).."'s Clear Body prevents stat changes!")
					else	
						
						-- Contrary Check
						local invertChange = false
						if tableInfo[1] == "Target" and _G.Pokemon[Defender.Name]["Ability"] == "Contrary" and 
							abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil then
							invertChange = true
						elseif tableInfo[1] == "User" and _G.Pokemon[Attacker.Name]["Ability"] == "Contrary" and 
							abilitydenier[_G.Pokemon[Defender.Name]["Ability"]] == nil then
							invertChange = true
						end

						local actualChange = tableInfo[2]
						if invertChange then
							actualChange = -actualChange
						end
						
						-- Defiant and Competitive Check
						if tableInfo[1] == "Target" and tableInfo[2] < 0 and 
							(_G.Pokemon[Defender.Name]["Ability"] == "Defiant" or _G.Pokemon[Defender.Name]["Ability"] == "Competitive") and
							abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil then
							
							if _G.Pokemon[Defender.Name]["Ability"] == "Defiant" then
								
								-- Check if Attack can be raised
								local atkMod = moveTable["Target"][1]["Mod"]["Atk"]
								if atkMod < 6 then
									-- Increase Attack by 2 stages
									local newAtkMod = math.min(6, atkMod + 2)
									moveTable["Target"][1]["Mod"]["Atk"] = newAtkMod
									table.insert(turnTable,nickname(Defender).."'s Defiant sharply raised its Attack!")
								end
							elseif _G.Pokemon[Defender.Name]["Ability"] == "Competitive" then
								
								-- Check if Special Attack can be raised
								local specialAtkMod = moveTable["Target"][1]["Mod"]["SpA"]
								if specialAtkMod < 6 then
									-- Increase Special Attack by 2 stages
									local newSpecialAtkMod = math.min(6, specialAtkMod + 2)
									moveTable["Target"][1]["Mod"]["SpA"] = newSpecialAtkMod
									table.insert(turnTable,nickname(Defender).."'s Competitive sharply raised its Special Attack!")
								end
							end
						end
						
						--print(tableInfo[1],stat)
						--if (weakness > 0 and tableinfo[1] == "Target") or  
						local buff = moveTable[tableInfo[1]][1]["Mod"][stat]
						if moveTable[tableInfo[1]][2].CurrentHP.Value > 0 then
							if buff+actualChange > 6 then
								moveTable[tableInfo[1]][1]["Mod"][stat] = 6 
								table.insert(turnTable,nickname(moveTable[tableInfo[1]][2]).."'s "..fullnamestats[stat].." can't go any higher!")
							elseif buff+actualChange < -6 then
								moveTable[tableInfo[1]][1]["Mod"][stat] = -6
								table.insert(turnTable,nickname(moveTable[tableInfo[1]][2]).."'s "..fullnamestats[stat].." can't go any lower!")
							else
								local sInfo = actualChange
								moveTable[tableInfo[1]][1]["Mod"][stat] = buff+sInfo
								print(buff+sInfo)
								table.insert(turnTable,nickname(moveTable[tableInfo[1]][2]).."'s "..fullnamestats[stat]..buffstrings[sInfo])                            
							end    
						end
					end
				end
			end
		elseif effect == "Status" then
			local immuneStatusAbilities = {
				["Insomnia"] = "Sleep",
				["Immunity"] = "Poison",
				["Limber"] = "Paralysis",
				["Magma Armor"] = "Freeze",
				["Shield Dust"] = "Freeze",
				["Vital Spirit"] = "Sleep",
				["Water Veil"] = "Burn",
			}

			--["Paralysis"] = 10,
			if Defender.CurrentHP.Value > 0 then
				if Defender.Status.Value ~= "" and Moves[usedMove]["AttackType"] == "Status" then
					table.insert(turnTable,nickname(Defender).." is already afflicted with a status.")

				elseif Defender.Status.Value == "" then
					for status,inflict in pairs(info) do

						local immune
						local chance = math.random(1,100)
						local comparechance = inflict
						if _G.Pokemon[Attacker.Name]["Ability"] and _G.Pokemon[Attacker.Name]["Ability"]  == "Serene Grace" then
							comparechance = comparechance * 2
						end 
						if _G.Pokemon[Attacker.Name]["Ability"] == "Sheer Force" and _G.Moves[usedMove]["AttackType"] ~= "Status" then
							comparechance = 0
						end
						if chance <= comparechance then
							for _,blah in pairs(Pokemon[Defender.Name]["Type"]) do

								if blah == immunestatus[status] or (status == "BadlyPoison" and blah == "Steel") or (status == "Poison" and blah == "Steel") or (usedMove == "Thunder Wave" and blah == "Ground")  then

									immune = true
								end
							end
							if  _G.Pokemon[Defender.Name]["Ability"] and immuneStatusAbilities[_G.Pokemon[Defender.Name]["Ability"]] then
								if immuneStatusAbilities[_G.Pokemon[Defender.Name]["Ability"]]:find(status) then
									immune = true
								end
							end
							if immune == true and Moves[usedMove]["AttackType"] == "Status" then
								table.insert(turnTable,"It didn't affect "..nickname(Defender).."!")
							else
								if immune ~= true then
									if status ~= "Sleep"  then
										Defender.Status.Value = status
										table.insert(turnTable,nickname(Defender)..statusstrings[status])
									elseif status == "Sleep" and (Defender.Parent.Parent.Type.Value == "Rated" or Defender.Parent.Parent.Type.Value == "Unrated") and sleepClauseCheck(Defender.Parent) then
										Defender.Status.Value = status
										table.insert(turnTable,nickname(Defender)..statusstrings[status])
										DefTable["Table"]["StatusTurns"] = math.random(2,4)
									elseif status == "Sleep" and (Defender.Parent.Parent.Type.Value == "Rated" or Defender.Parent.Parent.Type.Value == "Unrated") and not sleepClauseCheck(Defender.Parent) then
										if Moves[usedMove]["AttackType"] == "Status" then
											table.insert(turnTable,"The move had no effect because of Sleep Clause.")
										end

									elseif status == "Sleep" then
										Defender.Status.Value = status
										table.insert(turnTable,nickname(Defender)..statusstrings[status])

										DefTable["Table"]["StatusTurns"] = math.random(2,4)
									end
									table.insert(turnTable,Defender.Parent.Name.."&UpdateStatus")
								end	
							end
						end	
					end		
				end	
			end
		elseif effect == "Flinch" then
			if position == "First" and Defender.CurrentHP.Value > 0 then
				local flichance = math.random(1,100)
				local comparechance = Moves[usedMove]["Effects"]["Flinch"]
				if _G.Pokemon[Defender.Name]["Ability"] and _G.Pokemon[Defender.Name]["Ability"]  == "Serene Grace" then
					comparechance = comparechance * 2
				end 
				if _G.Pokemon[Attacker.Name]["Ability"] == "Sheer Force" then
					comparechance = 0
				end
				if Pokemon[Defender.Name]["Ability"] and  (Pokemon[Defender.Name]["Ability"] == "Inner Focus" or Pokemon[Defender.Name]["Ability"] == "Own Tempo" or Pokemon[Defender.Name]["Ability"] == "Shield Dust") then
					flinch = false
				elseif flichance <= comparechance then
					flinch = true	
				else 
					flinch = false
				end	
			end
		elseif effect == "Recoil" then
			if dmg ~= nil then
				recoil(Attacker,usedMove, dmg,turnTable)
			end
		elseif effect == "Heal" then
			if Attacker.CurrentHP.Value == Attacker.Stats.HPStat.Value then
				table.insert(turnTable, "It had no effect!")
			else
				local valheal =  math.ceil(Attacker.Stats.HPStat.Value*Moves[usedMove]["Effects"]["Heal"])
				local curHP = Attacker.CurrentHP.Value
				Attacker.CurrentHP.Value = math.min(Attacker.CurrentHP.Value+valheal,Attacker.Stats.HPStat.Value)
				table.insert(turnTable,nickname(Attacker).." regained health!")
				table.insert(turnTable,Attacker.Parent.Name..curHP.."@"..Attacker.CurrentHP.Value.."&UpdateHealthHP") 

			end
		elseif effect == "PainSplit" then
			local curhp = Attacker.CurrentHP.Value
			local otherhp = Defender.CurrentHP.Value
			local hpsplit = math.floor((curhp+otherhp)/2)
			table.insert(turnTable,"The battlers shared their pain!")
			Attacker.CurrentHP.Value = math.min(hpsplit,Attacker.Stats.HPStat.Value)
			Defender.CurrentHP.Value = math.min(hpsplit,Defender.Stats.HPStat.Value)
			table.insert(turnTable,Attacker.Parent.Name..curhp.."@"..Attacker.CurrentHP.Value.."&UpdateHealthHP")
			table.insert(turnTable,Defender.Parent.Name..otherhp.."@"..Defender.CurrentHP.Value.."&UpdateHealthHP")
		elseif effect == "Rest" then
			local chump = nil
			local curhp = Attacker.CurrentHP
			local hpstat = Attacker.Stats.HPStat
			local cHP = Attacker.CurrentHP.Value
			if hpstat.Value == curhp.Value then
				table.insert(turnTable,"It had no effect!")
			else
				curhp.Value = hpstat.Value
				Attacker.Status.Value = "Sleep"
				chump = true
			end
			if chump ~= nil then
				AtkTable["Table"]["StatusTurns"] = 2
				AtkTable["Table"]["BadlyPoison"] = .0625
				table.insert(turnTable,nickname(Attacker).." started sleeping!")
				table.insert(turnTable,Attacker.Parent.Name..cHP.."@"..hpstat.Value.."&UpdateHealthHP")
				table.insert(turnTable,Attacker.Parent.Name.."&UpdateStatus")
			end
		elseif effect == "Volatile" then
			for i,v in pairs(Moves[usedMove]["Effects"]["Volatile"]) do
				if Defender.CurrentHP.Value > 0 then
					if i == "Confusion" then
						local volatilecheck = math.random(1,100)
						local comparechance = v
						if _G.Pokemon[Attacker.Name]["Ability"] == "Sheer Force" and  _G.Moves[usedMove]["AttackType"] ~= "Status" then
							comparechance = 0
						end
						if volatilecheck <= comparechance then
							if DefTable["Table"]["Confusion"] ~= 0 then
								table.insert(turnTable,nickname(Defender).." was already confused!")
							else
								DefTable["Table"]["Confusion"] = math.random(2,4)
								table.insert(turnTable,nickname(Defender).." became confused!")
							end
						end
					end
				end
			end
		elseif effect == "ClearStats" then
			table.insert(turnTable,"All stat changes were reset!")

			battleO[game.Players:FindFirstChild(Attacker.Parent.Name)]["Modifier"] = {	["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			battleO[game.Players:FindFirstChild(Defender.Parent.Name)]["Modifier"] = {	["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			--										moveTable["User"][1]["Mod"] = {
			--										
			--										["Atk"] = 0,
			--										["Def"] = 0,
			--										["SpA"] = 0,
			--										["SpD"] = 0,
			--										["Speed"] = 0,
			--										["Acc"] = 0,
			--										["Evade"] = 0 
			--										}
			--										moveTable["Target"][1]["Mod"] = {
			--										["Atk"] = 0,
			--										["Def"] = 0,
			--										["SpA"] = 0,
			--										["SpD"] = 0,
			--										["Speed"] = 0,
			--										["Acc"] = 0,
			--										["Evade"] = 0 
			--										}

		elseif effect == "Absorb" then
			gainhealth(Attacker, usedMove, dmg,turnTable)
		end
	end
	--end
	return flinch
end

function checkFaint(pokemon,turnTable)
	if pokemon.CurrentHP.Value <= 0 then
		pokemon.Status.Value = "Faint"
		table.insert(turnTable,nickname(pokemon).." fainted!")
		table.insert(turnTable,pokemon.Parent.Name.."&UpdateFaint")
	end
end


function confuseCheck(pokemon,turnTable,tab)
	if tab["Table"]["Confusion"] > 0  then
		--	print(tab["Table"]["Confusion"])
		tab["Table"]["Confusion"] = tab["Table"]["Confusion"] - 1	
		if tab["Table"]["Confusion"] > 0 then
			table.insert(turnTable,nickname(pokemon).." is confused!")
			local chance = math.random(1,2)
			if chance == 1 then
				table.insert(turnTable,nickname(pokemon).." hits itself in confusion!")

				local dmg,weakness,crit,immune = dmgCalc(pokemon,pokemon, "ConfusedAttack", tab, tab,turnTable)
				local curhp = pokemon.CurrentHP.Value
				pokemon.CurrentHP.Value = math.max(0,pokemon.CurrentHP.Value-dmg)
				table.insert(turnTable,pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
				checkFaint(pokemon,turnTable)
				return true
			else
				return false
			end
		else
			table.insert(turnTable,nickname(pokemon).." snapped out of confusion!")
			tab["Table"]["Confusion"] = 0
			return false
		end
	else
		return false
	end
end



function paraCheck(pokemon,turnTable)
	if pokemon.Status.Value == "Paralysis" then
		local isparalyzed = math.random(1,4)
		if isparalyzed == 4 then
			table.insert(turnTable,nickname(pokemon).." is fully paralyzed!")
			return true
		else
			return false
		end
	else
		return false
	end

end

function sleepCheck(pokemon,turnTable,tab)
	if pokemon.Status.Value == "Sleep" then
		--	print(tab["Table"]["StatusTurns"])
		table.insert(turnTable,nickname(pokemon).." is fast asleep!")	
		if tab["Table"]["StatusTurns"] > 0 then
			tab["Table"]["StatusTurns"] = tab["StatusTurns"] - 1
			return true
		else
			table.insert(turnTable,nickname(pokemon).." woke up!")
			pokemon.Status.Value = ""
			table.insert(turnTable,pokemon.Parent.Name.."&UpdateStatus")
			tab["StatusTurns"] = 0 
			return false
		end
	else
		return false
	end

end

function freezeCheck(pokemon,turnTable)
	if pokemon.Status.Value == "Freeze" then
		table.insert(turnTable,nickname(pokemon).." is frozen!")
		local isfrozen = math.random(1,5)

		if isfrozen == 1 then
			table.insert(turnTable,nickname(pokemon).." thawed out!")
			pokemon.Status.Value = ""
			table.insert(turnTable,pokemon.Parent.Name.."&UpdateStatus")
			return false
		else
			return true
		end

	else
		return false
	end
end

function moveHit(move,AtkTable,DefTable,Attacker,turnTable,Defender)

	local accrandom = math.random(1,100)
	local moveacc = Moves[move]["Accuracy"]
	if moveacc == true then --Always accurate moves such as Aerial Ace
		return true
	end
	if Attacker.HeldItem.Value == "Wide Lens" then
		moveacc = moveacc+math.floor(moveacc/10)
	end
	if _G.Pokemon[Attacker.Name]["Ability"] == "Compound Eyes" then
		moveacc = moveacc*1.3
	end
	local chance = math.ceil((moveacc) * (accstat[AtkTable["Mod"]["Acc"]]*(evadestat[DefTable["Mod"]["Evade"]])))
	if accrandom <= chance then
		return true
	else 
		table.insert(turnTable,nickname(Attacker).."'s attack missed!")
		if Attacker.Moves:FindFirstChild(move) then
			--Attacker.Moves[move].PP.Value = Attacker.Moves[move].PP.Value - 1
		end
		return false
	end

end

function poisonEntryHazard(pokemon,turnTable,battleTable)
	local TSpikes = battleTable["Table"]["ToxicSpikes"] 
	if TSpikes > 0 then
		if not isLevitating(pokemon) then
			if not isType(pokemon,"Poison") and not isType(pokemon,"Steel") and pokemon.Status.Value == "" then
				if TSpikes == 1 then
					table.insert(turnTable,nickname(pokemon).." was poisoned by Toxic Spikes!")
					pokemon.Status.Value = "Poison"
				elseif TSpikes == 2 then
					table.insert(turnTable,nickname(pokemon).." was badly poisoned by Toxic Spikes!")
					pokemon.Status.Value = "BadlyPoison"
				end
				table.insert(turnTable,pokemon.Parent.Name.."&UpdateStatus")
			elseif isType(pokemon,"Poison") then
				table.insert(turnTable,nickname(pokemon).." absorbed the Toxic Spikes!")
				battleTable["Table"]["ToxicSpikes"] = 0 
			end
		else
		end
	end
	--nothing...
end
--Let's Calculate the Elo Stats:

--Rnew = Result old + C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
--C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))

--W = 1
--ROld = 1000 (Elo start)
--C1 = 50 
--R = Elo stat
--Rother = Opp Elo Stat
--C2 = 400
--Round up
function findWeakness(Move,Poke2)
	local weakness = 1
	local typetable = Types[Moves[Move]["Type"]]
	local types = Pokemon[Poke2.Name]["Type"]
	for i,v in pairs(types) do
		--Immune
		for _,weak in ipairs(typetable["0x"]) do
			if v == weak then
				weakness = weakness * 0
			end
		end
	end
	return weakness
end

local ps = game:GetService("PointsService")
function WinCheck(folder,opFolder,clientFolder,client,op)
	local cid = client.UserId
	local oid = op.UserId
	local W = 1
	local C1 = 50
	local C2 = 400
	if checkWin(opFolder) and checkWin(clientFolder) then
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(client,"Tie",op)
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(op,"Tie",client)
		folder:Remove()
	elseif checkWin(opFolder) then
		if folder.Type.Value == "Rated" then
			local R = ps:GetGamePointBalance(cid)
			local Rother =  ps:GetGamePointBalance(oid)
			local Change = C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
			local BPGain = math.max(1,math.ceil(Change/3))
			local messageText = client.Name.." beat "..op.Name.." in a Rated Battle and gained "..BPGain.." BP!"
			local color = Color3.new(1,1,1)
			game.ReplicatedStorage:WaitForChild("ChatEvent"):FireAllClients(messageText, "text", "server", color)
			client.BP.Value = client.BP.Value + BPGain
			ps:AwardPoints(cid, math.ceil(Change))
			ps:AwardPoints(oid, -math.ceil(Change))
		end
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(client,client.Name,op)
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(op,client.Name,client)
		folder:Remove()
	elseif checkWin(clientFolder) then
		if folder.Type.Value == "Rated" then
			local R = ps:GetGamePointBalance(oid)
			local Rother =  ps:GetGamePointBalance(cid)
			local Change = C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
			ps:AwardPoints(cid, -math.ceil(Change))
			ps:AwardPoints(oid, math.ceil(Change))
			local BPGain = math.max(1,math.ceil(Change/3))
			local messageText = op.Name.." beat "..client.Name.." in a Rated Battle and gained "..BPGain.." BP!"
			local color = Color3.new(1,1,1)
			game.ReplicatedStorage:WaitForChild("ChatEvent"):FireAllClients(messageText, "text", "server", color)
			op.BP.Value = op.BP.Value + BPGain
			ps:AwardPoints(oid, math.ceil(Change))
			ps:AwardPoints(cid, -math.ceil(Change))
		end
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(client,op.Name,op)
		game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(op,op.Name,client)
		folder:Remove()
	end
end

function protectCheck(Attacker,turnTable,DefTable,usedMove,Defender)
	if (DefTable["Table"]["ProtectCounter"][2] == true and (type(_G.Moves[usedMove]["Accuracy"]) == "number" or _G.Moves[usedMove]["AttackType"] ~= "Status")) then
		table.insert(turnTable,nickname(Defender).." protected itself!")
		return false	
	end
	return true					
end

local contactStatus = {
	["Static"] = {"Paralysis"},
	["Effect Spore"] = {"Paralysis","Sleep","Poison"},
	["Flame Body"] = {"Burn"},
	["Poison Point"] = {"Poison"},
}

function contactMoveDefender(attacker,defender,move,turnTable)

	local ability
	if _G.Pokemon[defender.Name]["Ability"] then
		ability = _G.Pokemon[defender.Name]["Ability"]
	end
	if contactStatus[ability] then
		local chance = math.random(1,100)
		if chance <= 30 then
			local newStatus = contactStatus[ability][math.random(1,#contactStatus[ability])] 
			if (immunestatus[newStatus] and not isType(attacker,immunestatus[newStatus])) then
				if (newStatus == "Poison" and not isType(attacker,"Steel")) or newStatus ~= "Poison" then	
					attacker.Status.Value = newStatus
					table.insert(turnTable,nickname(attacker)..statusstrings[newStatus])
					table.insert(turnTable,attacker.Parent.Name.."&UpdateStatus")
				end
			end
		end
	end

end
--Mod, not Modifier
function moveBeingUsed(Attacker, Defender, usedMove, AtkTable, DefTable,turnTable,position) --Attacker = Pokemon using move, Defender = Pokemon getting attacked, Move = Move being used)
	--is the move physical, special, or status?
	local typeOfMove = Moves[usedMove]["AttackType"]
	local timesused = 1
	local atimes
	local dmg 
	local damage 
	local wook
	local weakness
	local immune
	local crit
	local faintpass
	if not confuseCheck(Attacker,turnTable,AtkTable) then
		if not paraCheck(Attacker,turnTable) and  not freezeCheck(Attacker,turnTable) and not sleepCheck(Attacker,turnTable,AtkTable) then
			if (usedMove ~= "Struggle" and usedMove ~= "ConfusedAttack") then
				Attacker.Moves[usedMove].PP.Value = Attacker.Moves[usedMove].PP.Value - 1
			end
			AtkTable["Table"]["DestinyBond"] = false
			if Attacker.HeldItem.Value == "Toxic Orb" and Attacker.Status.Value == "" and not isType(Attacker,"Poison") and not isType(Attacker,"Steel") then
				AtkTable["Table"]["BadlyPoison"] = .0625
				Attacker.Status.Value = "BadlyPoison"
				table.insert(turnTable,nickname(Attacker).." was badly poisoned by Toxic Orb!")
				table.insert(turnTable,Attacker.Parent.Name.."&UpdateStatus")										
			end
			if Attacker.HeldItem.Value == "Flame Orb" and Attacker.Status.Value == "" and not isType(Attacker,"Fire")  then
				Attacker.Status.Value = "Burn"
				table.insert(turnTable,nickname(Attacker).." was burnt by Flame Orb!")
				table.insert(turnTable,Attacker.Parent.Name.."&UpdateStatus")										
			end
			table.insert(turnTable,nickname(Attacker).." used "..usedMove.."!")
			if protectCheck(Attacker,turnTable,DefTable,usedMove,Defender) then
				if usedMove == "Splash" or usedMove == "Transform"  then
					table.insert(turnTable,"But it did nothing at all...")
				elseif (usedMove == "Dream Eater" and Defender.Status.Value ~= "Sleep") then
					table.insert(turnTable,"But "..nickname(Defender).." is awake!")
				elseif moveHit(usedMove,AtkTable,DefTable,Attacker,turnTable,Defender) then
					if typeOfMove == "Status" then

						specialEffect(Attacker, Defender, usedMove, AtkTable, DefTable, turnTable)

					else
						if Moves[usedMove]["Effects"]["MultiHit"] ~= nil then
							timesused = math.random(2,Moves[usedMove]["Effects"]["MultiHit"])
							if Pokemon[Attacker.Name]["Ability"] and  _G.Pokemon[Attacker.Name]["Ability"] == "Skill Link"  then
								timesused = Moves[usedMove]["Effects"]["MultiHit"]
							end
						end
						for i = 1, timesused do
							if Moves[usedMove]["SetDamage"] ~= nil then
								if _G.Moves[usedMove]["SetDamage"] == "Level" then
									dmg = Attacker.Lvl.Value
								elseif _G.Moves[usedMove]["SetDamage"] == "UserHP" then
									dmg = Attacker.CurrentHP.Value
								else
									dmg = _G.Moves[usedMove]["SetDamage"]
								end

								crit = 1

								local weakness = findWeakness(usedMove, Defender)
								if weakness == 0 then
									dmg = 0
								else
									dmg = math.ceil(dmg * weakness)
								end
							else
								dmg,weakness,crit,immune = dmgCalc(Attacker, Defender, usedMove, AtkTable, DefTable,turnTable)
								if dmg > 0 then
									if Attacker.HeldItem.Active.Value == true then
										if Attacker.HeldItem.Value == "Life Orb" and type(Moves[usedMove]["Power"]) == "number" then


											dmg = dmg * 1.3
										elseif Attacker.HeldItem.Value == "Expert Belt" and weakness >= 2 and type(Moves[usedMove]["Power"]) == "number" then

											dmg = dmg * 1.2
										elseif Attacker.HeldItem.Value == "Novice Belt" and weakness < 1 and type(Moves[usedMove]["Power"]) == "number" then

											dmg = dmg * 1.5

										end
									end
								end
							end
							damage = dmg
							wook = weakness
							local curhp = Defender.CurrentHP.Value
							if curhp <= 0 then
								faintpass = true
							end
							local sturdy 
							local sash
							if dmg > 0 and curhp == Defender.Stats.HPStat.Value and _G.Pokemon[Defender.Name]["Ability"] == "Multiscale" and abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil then
								dmg = math.ceil(dmg/2)
							end
							if dmg > 0 and dmg >= curhp and curhp == Defender.Stats.HPStat.Value then

								if abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil and _G.Pokemon[Defender.Name]["Ability"] == "Sturdy" then
									sturdy = true
								elseif Defender.HeldItem.Value == "Focus Sash" then
									sash = true
								end

							end
							if  usedMove == "False Swipe" or sturdy == true or sash == true then
								Defender.CurrentHP.Value = math.max(1,Defender.CurrentHP.Value-dmg)
							else
								Defender.CurrentHP.Value = math.max(0,Defender.CurrentHP.Value-dmg)
							end

							table.insert(turnTable,Defender.Parent.Name..curhp.."@"..Defender.CurrentHP.Value.."&UpdateHealthHP")
							if sash == true then
								Defender.HeldItem.Value = ""
								table.insert(turnTable,nickname(Defender).." held on with its Focus Sash!")
							end
							if sturdy == true then
								table.insert(turnTable,nickname(Defender).." held on with its sturdiness!")
							end
							if crit == 2 then
								table.insert(turnTable,"It was a critical hit!")
							end
							if i == timesused then
								local weakstring = weak(weakness,Defender,immune)
								if weakstring ~= false then
									table.insert(turnTable,weakstring)
								end
							end
							if usedMove == "Knock Off" and Defender.HeldItem.Value ~= "" and not megaStone(Defender.HeldItem.Value) then
								table.insert(turnTable,nickname(Defender).."'s item was knocked off!")
								Defender.HeldItem.Value = ""
							end 
							if Defender.CurrentHP.Value <= 0 then
								-- Moxie check
								if _G.Pokemon[Attacker.Name]["Ability"] == "Moxie" then
									local pokemonAtkMod = AtkTable["Mod"]["Atk"]
									if pokemonAtkMod < 6 then
										AtkTable["Mod"]["Atk"] = pokemonAtkMod + 1
										table.insert(turnTable, nickname(Attacker) .. "'s Moxie boosted its Attack!")
									end
								elseif _G.Pokemon[Attacker.Name]["Ability"] == "Beast Boost" then
									-- Beast Boost
									local stats = {"Atk", "Def", "SpA", "SpD", "Speed"}
									local highestStat = "Atk"
									local highestValue = Attacker.Stats.AtkStat.Value

									-- Find highest stat (excluding HP)
									for _, stat in ipairs(stats) do
										local statValue = Attacker.Stats[stat.."Stat"].Value
										if statValue > highestValue then
											highestStat = stat
											highestValue = statValue
										end
									end

									-- Apply boost if not maxed
									if AtkTable["Mod"][highestStat] < 6 then
										AtkTable["Mod"][highestStat] = AtkTable["Mod"][highestStat] + 1
										table.insert(turnTable, nickname(Attacker).."'s Beast Boost raised its "..fullnamestats[highestStat].."!")
									end
								end

								atimes = i
								break
							end
							atimes = timesused
						end
						if atimes ~= 1 then
							table.insert(turnTable,"Hit "..atimes.." times!")
						end
						
						-- Cotton Down message display
						if dmg > 0 and Defender.CurrentHP.Value > 0 and _G.Pokemon[Defender.Name]["Ability"] == "Cotton Down" and abilitydenier[_G.Pokemon[Attacker.Name]["Ability"]] == nil then
							local opponentTable = (Defender.Parent.Name == Attacker.Parent.Name) and DefTable or AtkTable
							if opponentTable["Mod"]["Speed"] > -6 then
								table.insert(turnTable, nickname(Defender).."'s Cotton Down lowered "..nickname(Attacker).."'s Speed!")
							end
						end
						
						if faintpass == true then
							table.insert(turnTable,"But there's nothing there!")
						elseif Moves[usedMove]["UserFaint"] ~= nil or (Defender.CurrentHP.Value == 0 and DefTable["Table"]["DestinyBond"] == true)  then
							local attackHP = Attacker.CurrentHP.Value
							Attacker.CurrentHP.Value = 0
							Attacker.Status.Value = "Faint"
							table.insert(turnTable,Attacker.Parent.Name..attackHP.."@"..Attacker.CurrentHP.Value.."&UpdateHealthHP")
							if Defender.CurrentHP.Value == 0 then
								table.insert(turnTable,nickname(Defender).." took its foe with it!")
							end
							checkFaint(Attacker,turnTable)
						end	
						checkFaint(Defender,turnTable)
						local sheerWorkAround
						if  _G.Pokemon[Attacker.Name]["Ability"] == "Sheer Force" and SheerForceCheck(usedMove) then
							sheerWorkAround = true
						end
						if Attacker.HeldItem.Value == "Life Orb" and dmg > 0 and sheerWorkAround ~= true then
							local curhp = Attacker.CurrentHP.Value
							table.insert(turnTable,nickname(Attacker).."  lost some of its HP!")
							Attacker.CurrentHP.Value = math.max(0,Attacker.CurrentHP.Value-math.floor((Attacker.Stats.HPStat.Value/10)))
							table.insert(turnTable,Attacker.Parent.Name..curhp.."@"..Attacker.CurrentHP.Value.."&UpdateHealthHP")
							checkFaint(Attacker,turnTable)

						end
						if dmg > 0 and Attacker.Status.Value == "" and Attacker.CurrentHP.Value > 0 and _G.Moves[usedMove]["Contact"] then
							contactMoveDefender(Attacker,Defender,usedMove,turnTable)
						end
						if wook > 0 and faintpass ~= true then
							return specialEffect(Attacker, Defender, usedMove, AtkTable, DefTable, turnTable, position, damage)
						end										
					end	
				end
			end

		end

	end
end

function applyWeatherEffects(pokemon, turnTable, battleTable)
	local weather = battleTable["Table"]["Weather"]
	if weather["Type"] == "Sandstorm" then
		-- Sandstorm damage to non-Rock, Ground, or Steel types
		if pokemon.CurrentHP.Value > 0 and not (isType(pokemon, "Rock")) and not (isType(pokemon, "Ground")) and not (isType(pokemon, "Steel")) then
			local curhp = pokemon.CurrentHP.Value
			local damage = math.ceil(pokemon.Stats.HPStat.Value / 16)
			pokemon.CurrentHP.Value = math.max(0, curhp - damage)
			table.insert(turnTable, nickname(pokemon).." is buffeted by the sandstorm!")
			table.insert(turnTable, pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
			checkFaint(pokemon, turnTable)
		end

		-- Special Defense boost for Rock types in sand
		if isType(pokemon, "Rock") then
			battleTable["Mod"]["SpD"] = math.min(6, battleTable["Mod"]["SpD"] + 1)
		end
	elseif weather["Type"] == "Rain" then
		-- Rain boosts Water moves and weakens Fire moves (handled in damage calculation)
		-- No direct damage from rain
	elseif weather["Type"] == "Sun" then
		-- Sun boosts Fire moves and weakens Water moves (handled in damage calculation)
		-- No direct damage from sun
	end

	-- Count down weather turns
	if weather["Type"] ~= "None" then
		weather["Turns"] = weather["Turns"] - 1
		if weather["Turns"] <= 0 then
			table.insert(turnTable, "The "..weather["Type"].." has subsided!")
			weather["Type"] = "None"
			weather["Turns"] = 0
		end
	end
end

function activateEntryAbilities(pokemon, turnTable, battleTable)
	if _G.Pokemon[pokemon.Name]["Ability"] and weatherAbilities[_G.Pokemon[pokemon.Name]["Ability"]] then
		local weatherType = weatherAbilities[_G.Pokemon[pokemon.Name]["Ability"]]
		battleTable["Table"]["Weather"]["Type"] = weatherType
		battleTable["Table"]["Weather"]["Turns"] = 5
		table.insert(turnTable, nickname(pokemon).."'s ".._G.Pokemon[pokemon.Name]["Ability"].." whipped up a "..weatherType.."!")
	end
end

function endOfTurn(pokemon,turnTable,battleTable)
	local hp = pokemon.Stats.HPStat
	local curhp = pokemon.CurrentHP.Value
	local losehp = math.ceil(hp.Value/8)
	local loseburn = math.ceil(hp.Value/16)

	-- Bad Dreams check
	local opponent = battleTable["Opponent"]
	if opponent and opponent.Parent and opponent.Parent:FindFirstChild(opponent.Name) then
		local opponentPokemon = opponent.Parent:FindFirstChild(opponent.Name)
		if opponentPokemon and opponentPokemon.CurrentHP.Value > 0 then
			local opponentAbility = _G.Pokemon[opponentPokemon.Name]["Ability"]
			if opponentAbility == "Bad Dreams" and pokemon.Status.Value == "Sleep" then
				local badDreamsDmg = math.ceil(hp.Value/8)
				table.insert(turnTable, nickname(pokemon).." is tormented by Bad Dreams!")
				pokemon.CurrentHP.Value = math.max(0, pokemon.CurrentHP.Value - badDreamsDmg)
				table.insert(turnTable, pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
				checkFaint(pokemon,turnTable)
				curhp = pokemon.CurrentHP.Value -- Updates current HP after Bad Dreams damage
			end
		end
	end

	-- Berserk check
	if pokemon.CurrentHP.Value > 0 and _G.Pokemon[pokemon.Name]["Ability"] == "Berserk" then
		local halfHP = math.ceil(hp.Value / 2)
		if pokemon.CurrentHP.Value <= halfHP and battleTable["Mod"]["SpA"] < 6 then
			if not battleTable["Table"]["BerserkTriggered"] then
				battleTable["Mod"]["SpA"] = battleTable["Mod"]["SpA"] + 1
				table.insert(turnTable, nickname(pokemon).."'s Berserk increased its Special Attack!")
				battleTable["Table"]["BerserkTriggered"] = true
			end
		elseif pokemon.CurrentHP.Value > halfHP then
			battleTable["Table"]["BerserkTriggered"] = false
		end
	end

	--print(battleTable["Opponent"].Parent.Name)
	battleTable["Table"]["Screens"]["Reflect"] = battleTable["Table"]["Screens"]["Reflect"] - 1
	battleTable["Table"]["Screens"]["LightScreen"] = battleTable["Table"]["Screens"]["LightScreen"] - 1
	if battleTable["Table"]["Screens"]["Reflect"] == 0 then
		table.insert(turnTable,nickname(pokemon).."'s Reflect wore off!")	
	end
	if battleTable["Table"]["Screens"]["LightScreen"] == 0 then
		table.insert(turnTable,nickname(pokemon).."'s Light Screen wore off!")	
	end

	if pokemon.CurrentHP.Value > 0 and _G.Pokemon[pokemon.Name]["Ability"] == "Speed Boost" then
		local speedMod = battleTable["Mod"]["Speed"]
		if speedMod < 6 then
			battleTable["Mod"]["Speed"] = speedMod + 1
			table.insert(turnTable,nickname(pokemon).."'s Speed Boost increased its speed!")
		end
	end

	if battleTable["Table"]["LeechSeed"] == true then
		leechdamage(pokemon,battleTable["Opponent"],turnTable)
	end
	if pokemon.CurrentHP.Value > 0 then

		if pokemon.Status.Value == "Burn" then
			table.insert(turnTable,nickname(pokemon).." was hurt by its burn!")
			pokemon.CurrentHP.Value = math.max(0,pokemon.CurrentHP.Value-loseburn)
			table.insert(turnTable,pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
			checkFaint(pokemon,turnTable)
		elseif pokemon.Status.Value == "Poison" then
			table.insert(turnTable,nickname(pokemon).." was hurt by poison!")
			pokemon.CurrentHP.Value = math.max(0,pokemon.CurrentHP.Value-losehp)
			table.insert(turnTable,pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
			checkFaint(pokemon,turnTable)
		elseif pokemon.Status.Value == "BadlyPoison" then
			table.insert(turnTable,nickname(pokemon).." was badly hurt by poison!")
			local losehp = hp.Value*battleTable["Table"]["BadlyPoison"]
			battleTable["Table"]["BadlyPoison"] = battleTable["Table"]["BadlyPoison"]+.0625
			pokemon.CurrentHP.Value = math.max(0,pokemon.CurrentHP.Value-losehp)
			table.insert(turnTable,pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
			checkFaint(pokemon,turnTable)
		end
		local curhp = pokemon.CurrentHP.Value
		if pokemon.CurrentHP.Value > 0 and pokemon.HeldItem.Active.Value == true then
			if pokemon.HeldItem.Value == "Leftovers" and pokemon.CurrentHP.Value ~= hp.Value then

				table.insert(turnTable,nickname(pokemon).." healed itself with its Leftovers!")
				pokemon.CurrentHP.Value = math.min(pokemon.Stats.HPStat.Value,pokemon.CurrentHP.Value+math.ceil((hp.Value/16)))
				table.insert(turnTable,pokemon.Parent.Name..curhp.."@"..pokemon.CurrentHP.Value.."&UpdateHealthHP")
			end
		end
	end
	applyWeatherEffects(pokemon, turnTable, battleTable)
end

function checkForFaint(first,second,client,op,folder,opFolder,clientFolder)
	if first.Status.Value ~= "Faint" and second.Status.Value ~= "Faint" then
		game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(client,op,folder)
		game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(op,client,folder)
		CountDown(client,op,folder,battleO)
	else 
		local f,s = true,true
		if first.Status.Value == "Faint" then
			f = nil
			spawn(function()
				f = game.ReplicatedStorage:WaitForChild("REvents").PVP.FaintAction:InvokeClient(game.Players:FindFirstChild(first.Parent.Name),op,folder[first.Parent.Name],getPokeOut(folder[first.Parent.Name]))
			end)
		end
		if second.Status.Value == "Faint" then
			s = nil
			spawn(function()

				s =	game.ReplicatedStorage:WaitForChild("REvents").PVP.FaintAction:InvokeClient(game.Players:FindFirstChild(second.Parent.Name),op,folder[second.Parent.Name],getPokeOut(folder[second.Parent.Name]))
			end)
		end
		repeat task.wait()   until f ~= nil and s ~= nil 
		--oppSend,youSend,oPoke,pPoke)
		if type(f) == "userdata" and type(s) == "userdata" then	
			first.PartyPosition.Value = f.PartyPosition.Value
			f.PartyPosition.Value = 1
			second.PartyPosition.Value = s.PartyPosition.Value
			s.PartyPosition.Value = 1
			battleO[game.Players:FindFirstChild(first.Parent.Name)]["Modifier"] = {["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0}

			local shortcut1 = game.Players:FindFirstChild(first.Parent.Name)
			if getPokeOut(folder[first.Parent.Name]).Status.Value == "Sleep" then
				battleO[game.Players:FindFirstChild(first.Parent.Name)]["StatusTurns"] = 2
			else
				battleO[game.Players:FindFirstChild(first.Parent.Name)]["StatusTurns"] = 0 
			end
			battleO[game.Players:FindFirstChild(first.Parent.Name)]["Confusion"] = 0
			battleO[shortcut1]["ProtectCounter"] = {1,false}
			battleO[shortcut1]["Roosting"] = false
			battleO[shortcut1]["DestinyBond"] = false
			battleO[shortcut1]["BadlyPoison"] = .0625		
			battleO[shortcut1]["LeechSeed"] = false








			local shortcut2 = game.Players:FindFirstChild(second.Parent.Name)
			battleO[game.Players:FindFirstChild(second.Parent.Name)]["Modifier"] = {["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			if getPokeOut(folder[second.Parent.Name]).Status.Value == "Sleep" then
				battleO[game.Players:FindFirstChild(second.Parent.Name)]["StatusTurns"] = 2
			else
				battleO[game.Players:FindFirstChild(second.Parent.Name)]["StatusTurns"] = 0
			end
			battleO[game.Players:FindFirstChild(second.Parent.Name)]["Confusion"] = 0
			battleO[shortcut2]["ProtectCounter"] = {1,false}
			battleO[shortcut2]["Roosting"] = false
			battleO[shortcut2]["DestinyBond"] = false
			battleO[shortcut2]["BadlyPoison"] = .0625	
			battleO[shortcut2]["LeechSeed"] = false










			game.ReplicatedStorage:WaitForChild("REvents").PVP.SwitchoutPokemon:FireClient(client,true,true,getPokeOut(opFolder),getPokeOut(clientFolder))
			game.ReplicatedStorage:WaitForChild("REvents").PVP.SwitchoutPokemon:FireClient(op,true,true,getPokeOut(clientFolder),getPokeOut(opFolder))
			task.wait(3)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(client,op,folder)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(op,client,folder)


		elseif type(f) == "userdata" then
			first.PartyPosition.Value = f.PartyPosition.Value
			f.PartyPosition.Value = 1

			battleO[game.Players:FindFirstChild(first.Parent.Name)]["Modifier"] = {["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			local shortcut1 = game.Players:FindFirstChild(first.Parent.Name)
			if getPokeOut(folder[first.Parent.Name]).Status.Value == "Sleep" then
				battleO[game.Players:FindFirstChild(first.Parent.Name)]["StatusTurns"] = 2
			else
				battleO[game.Players:FindFirstChild(first.Parent.Name)]["StatusTurns"] = 0
			end
			battleO[game.Players:FindFirstChild(first.Parent.Name)]["BerserkTriggered"] = false
			battleO[game.Players:FindFirstChild(first.Parent.Name)]["Confusion"] =0
			battleO[shortcut1]["ProtectCounter"] = {1,false}
			battleO[shortcut1]["Roosting"] = false
			battleO[shortcut1]["DestinyBond"] = false
			battleO[shortcut1]["BadlyPoison"] = .0625		
			battleO[shortcut1]["LeechSeed"] = false
			game.ReplicatedStorage:WaitForChild("REvents").PVP.SwitchoutPokemon:FireClient(game.Players:FindFirstChild(first.Parent.Name),false,true,nil,f)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.SwitchoutPokemon:FireClient(game.Players:FindFirstChild(second.Parent.Name),true,false,f)
			task.wait(2)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(client,op,folder)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(op,client,folder)
		elseif type(s) == "userdata" then											
			second.PartyPosition.Value = s.PartyPosition.Value
			s.PartyPosition.Value = 1
			battleO[game.Players:FindFirstChild(second.Parent.Name)]["Modifier"] = {["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			local shortcut2 = game.Players:FindFirstChild(second.Parent.Name)
			if getPokeOut(folder[second.Parent.Name]).Status.Value == "Sleep" then
				battleO[game.Players:FindFirstChild(second.Parent.Name)]["StatusTurns"] = 2
			else
				battleO[game.Players:FindFirstChild(second.Parent.Name)]["StatusTurns"] = 0
			end
			battleO[game.Players:FindFirstChild(second.Parent.Name)]["BerserkTriggered"] = false
			battleO[game.Players:FindFirstChild(second.Parent.Name)]["Confusion"] = 0
			battleO[shortcut2]["ProtectCounter"] = {1,false}
			battleO[shortcut2]["Roosting"] = false
			battleO[shortcut2]["DestinyBond"] = false
			battleO[shortcut2]["BadlyPoison"] = .0625
			battleO[shortcut2]["LeechSeed"] = false
			game.ReplicatedStorage:WaitForChild("REvents").PVP.SwitchoutPokemon:FireClient(game.Players:FindFirstChild(first.Parent.Name),true,false,s,nil)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.SwitchoutPokemon:FireClient(game.Players:FindFirstChild(second.Parent.Name),false,true,nil,s)
			task.wait(2)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(client,op,folder)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.RepeatTurn:FireClient(op,client,folder)
		end

	end	
end	
function whichOneSwitch(t1,t2)
	if battleO[t1]["Action"] == "Switch" then
		return t1,t2
	elseif battleO[t2]["Action"]  == "Switch" then
		return t2,t1
	end
end
Remotes.Server:Get("SendAction"):Connect(function(client,action,Type,folder,op,gonnaMega)
	local ticket = folder.Name
	--print(battleO[client]["Action"])
	battleO[client]["Action"] = action
	battleO[client]["Type"] = Type
	battleO[client]["GonnaMega"] = gonnaMega
	battleO[client]["Folder"] = folder 
	tableo[tonumber(ticket)][client] = true
	folder[client.Name.."Time"].Value = 121 
	--print(tableo[tonumber(ticket)][client],tableo[tonumber(ticket)][op])
	if doubleCheck(tableo[tonumber(ticket)],client,op) then
		local clientFolder = folder[client.Name]
		local opFolder = folder[op.Name]
		local turnTable = {} 
		if battleO[client]["Weather"]["Type"] ~= "None" then
			table.insert(turnTable, "The "..battleO[client]["Weather"]["Type"].." is raging!")
		end
		if battleO[client]["Action"] == "Move" and battleO[op]["Action"] == "Move" then	
			battleO[client]["Roosting"] = false
			battleO[op]["Roosting"] = false
			battleO[client]["ProtectCounter"][2] = false
			battleO[op]["ProtectCounter"][2] = false
			local moves =  {
				[getPokeOut(clientFolder)] = {
					["Table"] = battleO[client],
					["Move"] = battleO[client]["Type"],
					["Mod"] = battleO[client]["Modifier"],
					["Confusion"] = battleO[client]["Confusion"],
					["StatusTurns"] = battleO[client]["StatusTurns"],
					["ProtectCounter"] = battleO[client]["ProtectCounter"],
					["DestinyBond"] = battleO[client]["DestinyBond"],
					["ToxicSpikes"] = battleO[client]["ToxicSpikes"],
					["LeechSeed"] = battleO[client]["LeechSeed"],
					["Screens"] = battleO[client]["Screens"],
					["Roosting"] = battleO[client]["Roosting"],
					["BadlyPoison"] = battleO[client]["BadlyPoison"],
					["Opponent"] = getPokeOut(opFolder),
					["MegaEvolve"] = battleO[client]["MegaEvolve"],
					["GonnaMega"] = battleO[client]["GonnaMega"],
				},
				[getPokeOut(opFolder)] = {
					["Table"] = battleO[op],
					["Move"] = battleO[op]["Type"],
					["Mod"] = battleO[op]["Modifier"],
					["Confusion"] = battleO[op]["Confusion"],
					["StatusTurns"] = battleO[op]["StatusTurns"],
					["ProtectCounter"] = battleO[op]["ProtectCounter"],
					["DestinyBond"] = battleO[op]["DestinyBond"],
					["ToxicSpikes"] = battleO[op]["ToxicSpikes"],
					["LeechSeed"] = battleO[op]["LeechSeed"],
					["Screens"] = battleO[op]["Screens"],
					["Roosting"] = battleO[op]["Roosting"],
					["BadlyPoison"] = battleO[op]["BadlyPoison"],
					["Opponent"] = getPokeOut(clientFolder),
					["MegaEvolve"] = battleO[op]["MegaEvolve"],
					["GonnaMega"] = battleO[op]["GonnaMega"],
				}
			}
			if moves[getPokeOut(clientFolder)]["GonnaMega"] and battleO[client]["MegaEvolve"] == false then

				local pokeMega = getPokeOut(clientFolder)
				if ItemList[pokeMega.HeldItem.Value] and ItemList[pokeMega.HeldItem.Value]["MegaEvolve"] and pokeMega.Name == ItemList[pokeMega.HeldItem.Value]["Requirement"] then

					battleO[client]["MegaEvolve"] = true
					local oldname = nickname(pokeMega)
					table.insert(turnTable,nickname(pokeMega).." is awakening its true power!")
					pokeMega.Name = ItemList[pokeMega.HeldItem.Value]["MegaEvolve"]
					pokeMega.Reverse.Value = pokeMega.Name:reverse()
					convertMega(pokeMega)
					table.insert(turnTable,pokeMega.Parent.Name..pokeMega.Name.."&UpdateMegaForm") 
					table.insert(turnTable,oldname.." transformed into "..pokeMega.Name.."!")
				end
			end
			if moves[getPokeOut(opFolder)]["GonnaMega"] and battleO[op]["MegaEvolve"] == false then

				local pokeMega = getPokeOut(opFolder)
				if ItemList[pokeMega.HeldItem.Value] and ItemList[pokeMega.HeldItem.Value]["MegaEvolve"] and pokeMega.Name == ItemList[pokeMega.HeldItem.Value]["Requirement"] then

					battleO[op]["MegaEvolve"] = true
					local oldname = nickname(pokeMega)
					table.insert(turnTable,nickname(pokeMega).." is awakening its true power!")
					pokeMega.Name = ItemList[pokeMega.HeldItem.Value]["MegaEvolve"]
					pokeMega.Reverse.Value = pokeMega.Name:reverse()
					convertMega(pokeMega)
					table.insert(turnTable,pokeMega.Parent.Name..pokeMega.Name.."&UpdateMegaForm") 
					table.insert(turnTable,oldname.." transformed into "..pokeMega.Name.."!")
				end
			end
			local first, second = moveFirst(getPokeOut(clientFolder),getPokeOut(opFolder),battleO[client]["Modifier"]["Speed"], battleO[op]["Modifier"]["Speed"],battleO[client]["Type"],battleO[op]["Type"])

			local flinch = moveBeingUsed(first,second,moves[first]["Move"],moves[first],moves[second],turnTable,"First")
			if second.Status.Value ~= "Faint" and flinch ~= true then
				moveBeingUsed(second,first,moves[second]["Move"],moves[second],moves[first],turnTable,"Second")
			elseif flinch == true and second.Status.Value ~= "Faint" then
				table.insert(turnTable,nickname(second).." flinched!")
			end			
			if first.Status.Value ~= "Faint" then
				endOfTurn(first,turnTable,moves[getPokeOut(folder[first.Parent.Name])])
			end			
			if second.Status.Value ~= "Faint" then
				endOfTurn(second,turnTable,moves[getPokeOut(folder[second.Parent.Name])])
			end
			game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(client,op,turnTable,folder)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(op,client,turnTable,folder)
			--									for i,v in pairs(turnTable) do
			--									print(v)
			--								end
			--Maybe?
			tableo[tonumber(ticket)][client] = false
			tableo[tonumber(ticket)][op] = false

			if not checkWin(clientFolder) and not checkWin(opFolder) then
				checkForFaint(first,second,client,op,folder,opFolder,clientFolder)
			else
				WinCheck(folder,opFolder,clientFolder,client,op)
			end	

		elseif battleO[client]["Action"] == "Switch" and battleO[op]["Action"] == "Switch" then
			battleO[client]["Roosting"] = false
			battleO[op]["Roosting"] = false
			battleO[client]["ProtectCounter"][2] = false
			battleO[op]["ProtectCounter"][2] = false
			battleO[op]["DestinyBond"] = false
			battleO[client]["DestinyBond"] = false
			battleO[client]["Modifier"] = {["Atk"] = 0,

				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			battleO[client]["Confusion"] = 0
			battleO[client]["ProtectCounter"] = {1,false}
			battleO[client]["Roosting"] = false
			battleO[client]["DestinyBond"] = false
			battleO[client]["LeechSeed"] = false
			battleO[client]["BadlyPoison"] = .0625
			battleO[client]["Table"] = battleO[client]
			battleO[op]["Modifier"] = {["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0,
			}
			battleO[op]["Confusion"] = 0
			battleO[op]["ProtectCounter"] = {1,false}
			battleO[op]["Roosting"] = false
			battleO[op]["DestinyBond"] = false
			battleO[op]["LeechSeed"] = false
			battleO[op]["BadlyPoison"] = .0625
			battleO[op]["Table"] = battleO[op]
			table.insert(turnTable,client.Name.. " returned "..nickname(getPokeOut(clientFolder)).."!")
			table.insert(turnTable,client.Name.."&UpdateReturn")
			getPokeOut(clientFolder).PartyPosition.Value = battleO[client]["Type"].PartyPosition.Value
			battleO[client]["Type"].PartyPosition.Value = 1
			table.insert(turnTable,client.Name.. " sent out "..nickname(battleO[client]["Type"]).."!")
			table.insert(turnTable,client.Name.."&UpdatePokeOut")
			if getPokeOut(folder[client.Name]).Status.Value == "Sleep" then
				battleO[client]["StatusTurns"] = 2
			else
				battleO[client]["StatusTurns"] = 0
			end
			poisonEntryHazard(battleO[client]["Type"],turnTable,battleO[client])
			table.insert(turnTable,op.Name.. " returned "..nickname(getPokeOut(opFolder)).."!")
			table.insert(turnTable,op.Name.."&UpdateReturn")
			getPokeOut(opFolder).PartyPosition.Value = battleO[op]["Type"].PartyPosition.Value
			battleO[op]["Type"].PartyPosition.Value = 1
			table.insert(turnTable,op.Name.. " sent out "..nickname(battleO[op]["Type"]).."!")
			activateEntryAbilities(battleO[op]["Type"], turnTable, battleO[op])
			table.insert(turnTable,op.Name.."&UpdatePokeOut")
			if getPokeOut(folder[op.Name]).Status.Value == "Sleep" then
				battleO[op]["StatusTurns"] = 2
			else
				battleO[op]["StatusTurns"] = 0
			end
			poisonEntryHazard(battleO[op]["Type"],turnTable,battleO[op])
			if battleO[client]["Type"].Status.Value ~= "Faint" then
				endOfTurn(battleO[client]["Type"],turnTable,battleO[client])
			end			
			if battleO[op]["Type"].Status.Value ~= "Faint" then
				endOfTurn(battleO[op]["Type"],turnTable,battleO[op])
			end
			game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(client,op,turnTable,folder)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(op,client,turnTable,folder)
			tableo[tonumber(ticket)][client] = false
			tableo[tonumber(ticket)][op] = false
			--								for i,v in pairs(turnTable) do
			--									print(v)
			--								end
			if not checkWin(clientFolder) and not checkWin(opFolder) then
				checkForFaint(battleO[client]["Type"],battleO[op]["Type"],client,op,folder,opFolder,clientFolder)
			else
				WinCheck(folder,opFolder,clientFolder,client,op)
			end	
		elseif (battleO[client]["Action"] == "Switch" and battleO[op]["Action"] == "Move") or (battleO[client]["Action"] == "Move" and battleO[op]["Action"] == "Switch") then
			battleO[client]["Roosting"] = false
			battleO[op]["Roosting"] = false
			battleO[client]["ProtectCounter"][2] = false
			battleO[op]["ProtectCounter"][2] = false

			local first,second = whichOneSwitch(client,op)
			battleO[first]["Modifier"] = {["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 }
			battleO[first]["Confusion"] = 0
			battleO[first]["ProtectCounter"] = {1,false}
			battleO[first]["DestinyBond"] = false
			battleO[first]["LeechSeed"] = false
			battleO[first]["BadlyPoison"] = .0625
			battleO[first]["Table"] = battleO[first]

			table.insert(turnTable,first.Name.. " returned "..nickname(getPokeOut(folder[first.Name])).."!")
			table.insert(turnTable,first.Name.."&UpdateReturn")
			getPokeOut(folder[first.Name]).PartyPosition.Value = battleO[first]["Type"].PartyPosition.Value
			battleO[first]["Type"].PartyPosition.Value = 1
			if getPokeOut(folder[first.Name]).Status.Value == "Sleep" then
				battleO[first]["StatusTurns"] = 2

			else
				battleO[first]["StatusTurns"] = 0
			end




			--ttt

			table.insert(turnTable,first.Name.. " sent out "..nickname(battleO[first]["Type"]).."!")
			activateEntryAbilities(battleO[first]["Type"], turnTable, battleO[first])
			local curHP = battleO[first]["Type"].CurrentHP.Value
			table.insert(turnTable,first.Name.."&UpdatePokeOut"..curHP)
			poisonEntryHazard(battleO[first]["Type"],turnTable,battleO[first])
			if battleO[second]["GonnaMega"] and battleO[second]["MegaEvolve"] == false then
				local pokeMega =  getPokeOut(folder[second.Name])
				if ItemList[pokeMega.HeldItem.Value] and ItemList[pokeMega.HeldItem.Value]["MegaEvolve"] and pokeMega.Name == ItemList[pokeMega.HeldItem.Value]["Requirement"] then

					battleO[second]["MegaEvolve"] = true
					local oldname = nickname(pokeMega)
					table.insert(turnTable,nickname(pokeMega).." is awakening its true power!")
					pokeMega.Name = ItemList[pokeMega.HeldItem.Value]["MegaEvolve"]
					pokeMega.Reverse.Value = pokeMega.Name:reverse()
					convertMega(pokeMega)
					table.insert(turnTable,pokeMega.Parent.Name..pokeMega.Name.."&UpdateMegaForm") 
					table.insert(turnTable,oldname.." transformed into "..pokeMega.Name.."!")
				end
			end
			local moves =  {
				[getPokeOut(clientFolder)] = {
					["Table"] = battleO[client],
					["Move"] = battleO[client]["Type"],
					["Mod"] = battleO[client]["Modifier"],
					["Confusion"] = battleO[client]["Confusion"],
					["StatusTurns"] = battleO[client]["StatusTurns"],
					["ProtectCounter"] = battleO[client]["ProtectCounter"],
					["Roosting"] = false,
					["DestinyBond"] = battleO[client]["DestinyBond"],
					["ToxicSpikes"] = battleO[client]["ToxicSpikes"],
					["LeechSeed"] = battleO[client]["LeechSeed"],
					["Screens"] = battleO[client]["Screens"],
					["BadlyPoison"] = battleO[client]["BadlyPoison"],
					["Opponent"] = getPokeOut(opFolder)
				},

				[getPokeOut(opFolder)] = {
					["Table"] = battleO[op],
					["Move"] = battleO[op]["Type"],
					["Mod"] = battleO[op]["Modifier"],
					["Confusion"] = battleO[op]["Confusion"],
					["StatusTurns"] = battleO[op]["StatusTurns"],
					["ProtectCounter"] = battleO[op]["ProtectCounter"],
					["Roosting"] = false,
					["DestinyBond"] = battleO[op]["DestinyBond"],
					["ToxicSpikes"] = battleO[op]["ToxicSpikes"],
					["LeechSeed"] = battleO[op]["LeechSeed"],
					["Screens"] = battleO[op]["Screens"],
					["BadlyPoison"] = battleO[op]["BadlyPoison"],
					["Opponent"] = getPokeOut(clientFolder)
				}
			}			

			moveBeingUsed(getPokeOut(folder[second.Name]),getPokeOut(folder[first.Name]),moves[getPokeOut(folder[second.Name])]["Move"],moves[getPokeOut(folder[second.Name])],moves[getPokeOut(folder[first.Name])],turnTable,"Second")
			battleO[second]["ProtectCounter"] = {1,false}									
			if getPokeOut(folder[first.Name]).Status.Value ~= "Faint" then
				endOfTurn(getPokeOut(folder[first.Name]),turnTable,moves[getPokeOut(folder[first.Name])])
			end			
			if getPokeOut(folder[second.Name]).Status.Value ~= "Faint" then
				endOfTurn(getPokeOut(folder[second.Name]),turnTable,moves[getPokeOut(folder[second.Name])])
			end

			game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(client,op,turnTable,folder)
			game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(op,client,turnTable,folder)
			tableo[tonumber(ticket)][client] = false
			tableo[tonumber(ticket)][op] = false

			if not checkWin(clientFolder) and not checkWin(opFolder) then
				checkForFaint(getPokeOut(folder[first.Name]),getPokeOut(folder[second.Name]),client,op,folder,opFolder,clientFolder)
			else
				WinCheck(folder,opFolder,clientFolder,client,op)
			end	
		elseif (battleO[client]["Action"] == "Run") or (battleO[op]["Action"] == "Run") then
			--print(battleO[client]["Action"],battleO[op]["Action"])
			if battleO[client]["Action"] ~= "Run" then
				if game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket).Type.Value == "Rated" then
					local cid = client.UserId
					local oid = op.UserId
					local W = 1
					local C1 = 50
					local C2 = 400
					local R = ps:GetGamePointBalance(cid)
					local Rother =  ps:GetGamePointBalance(oid)
					local Change = C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
					ps:AwardPoints(cid, math.ceil(Change))
					ps:AwardPoints(oid, -math.ceil(Change))
					local BPGain = math.max(1,math.ceil(Change/3))
					local messageText = client.Name.." beat "..op.Name.." in a Rated Battle and gained "..BPGain.."  BP!"
					local color = Color3.new(1,1,1)
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireAllClients(messageText, "text", "server", color)
					client.BP.Value = client.BP.Value + BPGain
				end

				table.insert(turnTable,op.Name.." forfeited the battle!")
				game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(client,op,turnTable,folder)
				game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(client,client.Name,op)
			elseif battleO[op]["Action"] ~= "Run" then
				if game.ReplicatedStorage:WaitForChild("BattleStorage"):FindFirstChild(ticket).Type.Value == "Rated" then
					local oid = client.UserId
					local cid = op.UserId
					local W = 1
					local C1 = 50
					local C2 = 400
					local R = ps:GetGamePointBalance(cid)
					local Rother =  ps:GetGamePointBalance(oid)
					local Change = C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
					local BPGain = math.max(1,math.ceil(Change/3))
					local messageText = op.Name.." beat "..client.Name.." in a Rated Battle and gained "..BPGain.."  BP!"
					local color = Color3.new(1,1,1)
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireAllClients(messageText, "text", "server", color)
					op.BP.Value = op.BP.Value + BPGain
					ps:AwardPoints(cid, math.ceil(Change))
					ps:AwardPoints(oid, -math.ceil(Change))
				end
				table.insert(turnTable,client.Name.." forfeited the battle!")
				game.ReplicatedStorage:WaitForChild("REvents").PVP.ShowTurn:FireClient(op,client,turnTable,folder)
				game.ReplicatedStorage:WaitForChild("REvents").PVP.BattleResult:FireClient(op,op.Name,client)
			else
				print("Both players ran.")
			end
			task.wait(10)
			folder:Remove()
		end

	end
end)


game.Players.PlayerRemoving:Connect(function(player)
	local id = player.UserId
	local pName = player.Name
	for i,v in ipairs(game.ReplicatedStorage:WaitForChild("BattleStorage"):GetChildren()) do
		if v:FindFirstChild(player.Name) then
			spawn(function() 
				for _,folder in ipairs(v:GetChildren()) do
					if game.Players:FindFirstChild(folder.Name) then
						game.ReplicatedStorage:WaitForChild("REvents").PVP.PlayerLeft:FireClient(game.Players:FindFirstChild(folder.Name))
						if v.Type.Value == "Rated" then
							local cid = game.Players:FindFirstChild(folder.Name).UserId
							local oid = player.UserId
							local W = 1
							local C1 = 50
							local C2 = 400
							local R = ps:GetGamePointBalance(cid)
							local Rother =  ps:GetGamePointBalance(oid)
							local Change = C1 * (W - (1 / (1+10^ (-(R-Rother)/C2))))
							local BPGain = math.max(1,math.ceil(Change/3))
							local messageText = folder.Name.." beat "..pName.." in a Rated Battle and gained "..BPGain.."  BP!"
							local color = Color3.new(1,1,1)
							game.ReplicatedStorage:WaitForChild("ChatEvent"):FireAllClients(messageText, "text", "server", color)
							game.Players:FindFirstChild(folder.Name).BP.Value = game.Players:FindFirstChild(folder.Name.BP.Value + BPGain)
							ps:AwardPoints(cid, math.ceil(Change))
							ps:AwardPoints(oid, -math.ceil(Change))

						end
					end
				end

				v:Remove()

			end)
		end
	end
end)		
