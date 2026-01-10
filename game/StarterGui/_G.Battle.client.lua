repeat task.wait() until game.Players.LocalPlayer.PlayerGui and _G.ready and _G.MovesReady and _G.SpritesReady and _G.TablesReady  and _G.EvolutionReady and _G.GUIsLoaded and _G.StatsReady
task.wait(2)
local bgm = workspace:WaitForChild("BackgroundMusic")
local REvents = game.ReplicatedStorage:WaitForChild("REvents")

--[[===========================================
ALL require() modules go here
--============================================]]
local Battle = require(game.ReplicatedStorage:WaitForChild("Functions").Battle)
local Pokedex = require(game.ReplicatedStorage:WaitForChild("Functions").Pokedex)
local ExpTables = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("ExpTables"))
local ItemList = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("Items"))
local natureStats = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("NatureStats"))
local Math = require(game.ReplicatedStorage:WaitForChild("Functions").Math)

--


modifierstat = {
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
accstat = {
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
evadestat = {
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
	["Paralysis"] = "Electric",
	["Poison"] = "Poison",
	["BadlyPoison"] = "Poison",
	["Freeze"] = "Ice"
}
partyb = {
	["Empty"] = "http://www.roblox.com/asset/?id=5720376789",
	["Status"] = "http://www.roblox.com/asset/?id=5720377310",
	["Faint"] = "http://www.roblox.com/asset/?id=5720377155",
	["Healthy"] = "http://www.roblox.com/asset/?id=5720403956",
}

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

--Contrary Helper
local function shouldInvertStatChanges(defender, attacker)
	if not defender or not attacker then return false end

	local defenderAbility = _G.Pokemon[defender.Name] and _G.Pokemon[defender.Name]["Ability"]
	local attackerAbility = _G.Pokemon[attacker.Name] and _G.Pokemon[attacker.Name]["Ability"]

	-- Check if defender has Contrary and attacker doesn't have ability-denying abilities
	return defenderAbility == "Contrary" and 
		not (attackerAbility == "Mold Breaker" or 
			attackerAbility == "Teravolt" or 
			attackerAbility == "Turboblaze")
end

-- Contrary Helper
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

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

local wildBattle = {9853251340,9852901022}
local trainerBattle = {9244095046,9853257675}
--[[==================================
Typewriter Effect Function
==================================
--]]
pressedq = nil

local berserkActivatedUser = false  -- Track if players Pokemon activated Berserk
local berserkActivatedOpp = false   -- Track if opponents Pokemon activated Berserk

scrollytext = nil
function scrolltext(gui,text,thing)
	scrollytext = true
	for i = 1, #text,2 do
		gui.Text = string.sub(text,1,i)

		if gui.Name ~= "Speak" then
			dropshadowdialog.Text = gui.Text
		else
			dropShaDia.Text = gui.Text
		end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Q) then
			gui.Text = text
			if gui.Name ~= "Speak" then
				dropshadowdialog.Text = text
			else
				dropShaDia.Text = text
			end
			pressedq = nil
			scrollytext = nil
			break
		end
		task.wait(.04)
	end
	gui.Text = text
	if gui.Name ~= "Speak" then
		dropshadowdialog.Text = text
	else
		dropShaDia.Text = text
	end
	scrollytext = nil
	if thing==nil and not game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Q) then
		task.wait(.35)
	elseif thing == nil and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Q) then
		task.wait(.45)
	end
end
--[[
==================================
Find Pokemon in the Party
==================================
--]]
function healafterbattle()
	local d = Battle:Heal()
	repeat task.wait() until d
end


function findlead(config)
	leadpokecom = nil
	for i,v in ipairs(config:GetChildren()) do
		for duh = 1, 6 do
			if duh == v.PartyPosition.Value and v.Status.Value ~= "Faint" then
				if leadpokecom == nil then
					leadpokecom = v
				elseif v.PartyPosition.Value < leadpokecom.PartyPosition.Value then
					leadpokecom = v
				end
			end
		end
	end
	if leadpokecom ~= nil then
		return leadpokecom
	else
		healafterbattle()
		return findlead(p.PokemonParty)
	end
end

--[[Return party to "original" state]]--
function originalparties(encode)
	if encode == true then
		for i,v in pairs (userteam:GetChildren()) do
			originalbattle[v] = v.PartyPosition.Value
		end
	elseif encode == false then
		for poke,banana in pairs(originalbattle) do
			Math:SwapPC(poke,banana)
		end
	end
end
--[[
==================================
Reorganize Party for Battle
==================================
--]]
function reorganize(config,poke)
	for i,v in ipairs(config:GetChildren()) do
		for duh = 1, 6 do
			if v.PartyPosition.Value == 1 and v.Status.Value == "Faint" then 
				Math:SwapPC(v,poke.PartyPosition.Value)
				Math:SwapPC(poke,1)
				break
			end
		end
	end
end

local PC = require(game.ReplicatedStorage:WaitForChild("Functions").PC)

function clearpokemon(p)
	for i,v in ipairs(p.OppPokemon:GetChildren()) do
		PC:Release(v)
	end
end
--[[
==================================
Check for PP
==================================
--]]
function ppchecker(moves)
	for i,v in ipairs(moves:GetChildren()) do
		if v.PP.Value > 0 then
			return false
		end
	end
	return true
end
--[[
==================================
Experience Bar Size Finder
==================================
--]]
function findexpbarsize(curlvl,nextlvl) 
	local multi = 1/nextlvl
	return (multi*curlvl)
end
--[[
==================================
Health Bar Size Finder
==================================
--]]
--hash


function findhealthbarsize(curhealth,maxhealth) --size is 109
	local multi = curhealth/maxhealth
	return multi
end
--[[
================================
Status
================================
--]]
function statusupdate(poke,foe)
	if poke.Status.Value ~= nil then
		if foe == true  then
			scrolltext(dialog,"The "..prefix.." "..poke.Name..statusstrings[poke.Status.Value])		
			tbox.Status.Text = _G.Tables["Status"][poke.Status.Value][1]
			tbox.Status.BackgroundColor3 = _G.Tables["Status"][poke.Status.Value][2]
			tbox.Status.Visible = true
			if prefix ~= "wild" then
				partycheck(theirparty)
			end
		else
			scrolltext(dialog,nickname(poke)..statusstrings[poke.Status.Value])
			ybox.Status.Text = _G.Tables["Status"][poke.Status.Value][1]
			ybox.Status.BackgroundColor3 = _G.Tables["Status"][poke.Status.Value][2]
			ybox.Status.Visible = true
			partycheck(yourparty)
		end
	end
end
--[[
===============================
Do they have Enough Pokemon Left?
===============================
--]]
function checkalive(cfg)
	for i,v in ipairs(cfg:GetChildren()) do
		if v.CurrentHP.Value > 0 and v.Status.Value ~= "Faint" then
			return true
		end
	end
	return false

end
--[[
===================================
Do they have more than 1 Pokemon alive?
====================================
--]]
function checknumber(cfg)
	local number = 0
	for i,v in ipairs(cfg:GetChildren()) do
		if v.CurrentHP.Value > 0 or v.Status.Value ~= "Faint" then
			number = number + 1
		end
	end
	return number
end

--if game.CreatorId ~= 2210737 then
--		p:Kick()
--	end
--[[
==================================
Change Visibility of a group of objects
==================================
--]]
function changevisible(thing,isa,bool)
	for i,v in ipairs(thing:GetChildren()) do
		if v:IsA(isa) and v.Name ~= "Back" and v.Name ~= "MegaEvolve" then
			v.Visible = bool
		end
	end
end
--[[
==================================
Party Bar Stuff
==================================
--]]
function partycheck(bar)
	local partycheck2
	if bar.Name == "TheirParty" then
		partycheck2 = p.OppPokemon
	else
		partycheck2 = p.PokemonParty
	end

	-- Clear the party balls
	for i = 1, 6 do
		bar["Ball"..i].Image = partyb["Empty"]
	end

	-- Check each Pokémon in the party
	for _, v in ipairs(partycheck2:GetChildren()) do
		-- Safely handle missing PartyPosition
		local partyPosition = v:FindFirstChild("PartyPosition")
		if not partyPosition then
			warn(v.Name .. " is missing PartyPosition. Skipping.")
		else
			for i = 1, 6 do
				if i == partyPosition.Value then
					if v.Status.Value == "Faint" then
						bar["Ball"..i].Image = partyb["Faint"]
					elseif v.Status.Value ~= "" then
						bar["Ball"..i].Image = partyb["Status"]
					else
						bar["Ball"..i].Image = partyb["Healthy"]
					end
				end
			end
		end
	end

	bar.Visible = true
end


--function findexploits

function findexploiters(poek)
	local staz = {"Atk","Def","SpA","SpD","Speed", "HP"}
	local HPChanged = false
	if poek.Lvl.Value > 100 or poek.Experience.Value <  ExpTables[_G.Pokemon[poek.Name]["ExpType"].."Exp"](poek.Lvl.Value) then		
		Math:ResetLevel(poek)


		HPChanged = true			
	end			
	if HPChanged == true then
		Math:StatChange(poek)
	end
	if poek.CurrentHP.Value > math.floor(HPcalc(poek.Lvl.Value,poek.IV["HPIV"].Value,poek.EV["HPEV"].Value,poek)) and poek.CurrentHP.Value > math.ceil(HPcalc(poek.Lvl.Value,poek.IV["HPIV"].Value,poek.EV["HPEV"].Value,poek)) then
		Math:Faint(poek)
	else

		for i,v in ipairs(staz) do
			if poek.IV[v.."IV"].Value > 31 then Math:ResetEV(poek.IV[v.."IV"]) end
			if poek.EV[v.."EV"].Value > 255 then Math:ResetEV(poek.EV[v.."IV"]) end

		end
		Math:StatChange(poek)
	end
end
	--[[
	==================================
	Update Pokemon Boxes
	==================================
	--]]
function boxupdate(config, box,your,transform)
	if your and config.Lvl.Value > 100 then
		Math:ResetLevel(config)
	end
	box.Level.Text = "Lv. "..config.Lvl.Value
	box.Level.Shadow.Text = box.Level.Text
	box.Gender.Image = _G.Sprites["Symbols"][config.Gender.Value]
	box.PokemonName.Text = nickname(config)
	box.PokemonName.Shadow.Text = box.PokemonName.Text
	box.HealthBG.Health.Size = UDim2.new(findhealthbarsize(config.CurrentHP.Value,config.Stats.HPStat.Value),-2,1,-2)
	box.Visible = true
	if your == true then
		if config.Name:reverse() ~= config.Reverse.Value then
			p:Kick()
		end
		if transform ~= true then
			findexploiters(config)
		end
		box.HPLabel.Text = config.CurrentHP.Value.."   /   "..config.Stats.HPStat.Value
		box.HPLabel.Shadow.Text = box.HPLabel.Text
		local value1 =  ExpTables[_G.Pokemon[config.Name]["ExpType"].."Exp"](config.Lvl.Value)
		local value2 =   ExpTables[_G.Pokemon[config.Name]["ExpType"].."Exp"](config.Lvl.Value + 1)
		local lvlblah = value2 - value1
		local nextlvl = value2 - config.Experience.Value
		local expbar = lvlblah - nextlvl
		box.ExpBG.Exp.Size = UDim2.new(findexpbarsize(expbar,lvlblah),0,1,0)
	end

	if config.Status.Value ~= "" then
		box.Status.Text = _G.Tables["Status"][config.Status.Value][1]
		box.Status.BackgroundColor3 = _G.Tables["Status"][config.Status.Value][2]
		box.Status.Visible = true
	else
		box.Status.Visible = false
	end
end
	--[[
	BallShake Animation
	--]]
function shakeball(gui)
	p.PlayerGui.SoundEffect.SoundId = "rbxassetid://11938055465"
	for i = 0,-45,-5 do
		gui.Rotation = i
		task.wait()
	end

	for i = -45,0,5 do
		gui.Rotation = i
		task.wait()
	end	
	for i = 0,45,5 do
		gui.Rotation = i
		task.wait()
	end	
	for i = 45,0,-5 do
		gui.Rotation = i
		task.wait()
	end
	p.PlayerGui.SoundEffect:Play()
	task.wait(.5)
end
function findbox()
	local numbers = {}
	for i,v in ipairs(p.PC:GetChildren()) do
		if #v:GetChildren() == 0 then
			return v.Name,1
		elseif #v:GetChildren() < 60 then
			for _,po in ipairs(v:GetChildren()) do
				numbers[po.PartyPosition.Value] = true
			end
			for swag = 1, 60 do
				if numbers[swag] == nil then
					return v.Name,swag
				end
			end
		end
	end
end
--creates pokedex entry (if they don't have one for their current pokemon)


function capturedpokemon(item)
	local prisoner = game.ReplicatedStorage:WaitForChild("REvents").Pokemon.catchPokemon:InvokeServer(theirpokeout,item)
	if #userteam:GetChildren() < 6 then
		PC:ParentChange(prisoner,userteam)
		Math:SwapParty(prisoner,#userteam:GetChildren())
		scrolltext(dialog,prisoner.Name.." was added to the Party.")
	else
		local newbox,number = findbox()
		scrolltext(dialog,prisoner.Name.." was sent to "..newbox..".")
		PC:ParentChange(prisoner, p.PC[newbox])
		Math:SwapParty(prisoner,number)

	end
	Pokedex:Caught(prisoner.Name) 
	Math:Caughter(prisoner,item)

end
		--[[
		Throwing Pokeball Animation
		--]]
thrownmsgs = {
	[-1] = "Oh no! The Pokemon broke free!",
	[0] = "Oh no! The Pokemon broke free!",
	[1] = "Aww! It appeared to be caught!",
	[2] = "Aargh! Almost had it!"
}

function throwingball(item)	
	p.PlayerGui.SoundEffect.SoundId = "rbxassetid://11938118465"
	pokeballanim.Position = UDim2.new(0,0,0.5,-95)
	p.PlayerGui.SoundEffect:Play()
	pokeballanim.Image = _G.Sprites["Pokeball"][item]["Open"]
	pokeballanim.Visible = true
	pokeballanim:TweenPosition(UDim2.new(0.75, -30,0.5, -25),"Out","Quad",.75)
	task.wait(.75)
	flash.Visible = true
	pokeballanim.Image = _G.Sprites["Pokeball"][item]["Closed"]
	task.wait(.1)
	theirpokemon.Visible = false
	flash.Visible = false
	pokeballanim:TweenPosition(UDim2.new(0.75, -30,0.5, 0),"Out","Quad",.6)
	if _G.Shakes == 0 then
		shakeball(pokeballanim)
	else
		for i = 1, _G.Shakes do
			shakeball(pokeballanim)
		end

	end
	if _G.ShakeCheck == "Success" then
		p.PlayerGui.SoundEffect.SoundId = "rbxassetid://11938139909"
		p.PlayerGui.SoundEffect:Play()
		scrolltext(dialog,"Gotcha! "..theirpokeout.Name.." was caught!")
		task.wait(.25)
		pokeballanim.Visible = false
	elseif _G.ShakeCheck == "Fail" then
		flash.Visible = true
		task.wait(.1)
		theirpokemon.Visible = true
		pokeballanim.Visible = false
		flash.Visible = false
		scrolltext(dialog,thrownmsgs[_G.Shakes-1])
	end
end
		--[[
		lame function
			--]]
function findexp(poke)
	for i,v in ipairs(pokemonexpsplit) do
		if poke == v then
			return false
		end
	end
	return true
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

function getHighestStat(pokemon)
	local stats = {
		"AtkStat",
		"DefStat",
		"SpAStat",
		"SpDStat",
		"SpeedStat"
	}
	local highest = {stat = "Atk", value = pokemon.Stats.AtkStat.Value}

	for _, stat in ipairs(stats) do
		local statName = stat:gsub("Stat", "")
		if pokemon.Stats[stat].Value > highest.value then
			highest = {stat = statName, value = pokemon.Stats[stat].Value}
		end
	end

	return highest.stat
end

function poisonEntryHazard(pokemon,box)
	local TSpikes 
	if box == "YourBox" then
		TSpikes = TSpikesFoe
	else
		TSpikes = TSpikesUser
	end
	if TSpikes > 0 then
		if not isLevitating(pokemon) then
			if not isType(pokemon,"Poison") and not isType(pokemon,"Steel") and pokemon.Status.Value == "" then
				if TSpikes == 1 then
					scrolltext(dialog,nickname(pokemon).." was poisoned by Toxic Spikes!")
					pokemon.Status.Value = "Poison"
				elseif TSpikes == 2 then
					scrolltext(dialog,nickname(pokemon).." was badly poisoned by Toxic Spikes!")
					pokemon.Status.Value = "BadlyPoison"
				end
			elseif isType(pokemon,"Poison") then
				scrolltext(dialog,nickname(pokemon).." absorbed the Toxic Spikes!")
				if box == "YourBox" then
					TSpikesFoe = 0
				else
					TSpikes = 0
				end
			end
		else
		end
	end
	--nothing...
end
			--[[
			=============================
			Send Out
			=============================
			]]--
function pokemonout(pokeball,pokemon,box,pokeout)
	p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6454685271"
	p.PlayerGui.SoundEffect:Play()  
	pokeball.Image = _G.Sprites["Pokeball"][pokeout.Pokeball.Value]["Closed"]
	pokeball.Visible = true
	task.wait(.3)
	pokeball.Image = _G.Sprites["Pokeball"][pokeout.Pokeball.Value]["Open"]
	task.wait(.3)
	flash.Visible = true
	pokeball.Visible = false

	if box.Name == "YourBox" then
		leechseeduser = false
		badpoisonUser = 0.0625
		poisonEntryHazard(pokeout,box)
		returnstats()

		_G.getBackSprite(pokemon,pokeout)
		boxupdate(pokeout,box,true)
		task.wait(.1)
		flash.Visible = false
		poisonEntryHazard(pokeout,box)
		boxupdate(pokeout,box,true)
		for i,v in pairs(originalstats) do
			if i.Parent and i.Parent.Name == "PokemonParty" then
				originalstats[i] = nil
			end
		end
		if not Pokedex:Check(pokeout.Name,p) then
			Pokedex:Create(pokeout.Name,true)
		else 
			Pokedex:Caught(pokeout.Name)
		end	
		urconfusion = false
		confusion1 = nil
		usermod = {
			["Atk"] = 0,
			["Def"] = 0,
			["SpA"] = 0,
			["SpD"] = 0,
			["Speed"] = 0,
			["Acc"] = 0,
			["Evade"] = 0 
		}
		--print(pokeout.Name)
		if findexp(pokeout)  then
			table.insert(pokemonexpsplit,pokeout)
		end
		flash.Visible = false
	else
		badpoisonOpp = 0.0625
		leechseedopp = false
		p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6454685271"
		p.PlayerGui.SoundEffect:Play()  
		pokemonexpsplit = {}
		table.insert(pokemonexpsplit,yourpokeout)
		theirconfusion = false
		confusion2 = nil
		oppmod = {
			["Atk"] = 0,
			["Def"] = 0,
			["SpA"] = 0,
			["SpD"] = 0,
			["Speed"] = 0,
			["Acc"] = 0,
			["Evade"] = 0 
		}
		leechseedopp = false
		--print(pokeout.Name)
		_G.getFrontSprite(pokemon,pokeout)

		boxupdate(pokeout,box,false)
		if not Pokedex:Check(pokeout.Name,p,zol)  and zol == nil  then
			Pokedex:Create(pokeout.Name)
		end
	end

	pokemon.Visible = true
	trainer.Visible = false
	task.wait(.1)
	flash.Visible = false
	poisonEntryHazard(pokeout,box)
	boxupdate(pokeout,box,false)
	task.wait(.3)
	if _G.Pokemon[pokeout.Name]["Ability"] then
		if _G.Pokemon[pokeout.Name]["Ability"] == "Pressure" then
			scrolltext(dialog,nickname(pokeout).." exerts its Pressure!")
		elseif _G.Pokemon[pokeout.Name]["Ability"] == "Intimidate" then
			scrolltext(dialog,nickname(pokeout).." is very intimdating!")

			-- Check for Contrary on the opponent
			local invertIntimidate = false
			if box.Name == "YourBox" and theirpokeout and _G.Pokemon[theirpokeout.Name] then
				invertIntimidate = _G.Pokemon[theirpokeout.Name]["Ability"] == "Contrary"
			elseif box.Name ~= "YourBox" and yourpokeout and _G.Pokemon[yourpokeout.Name] then
				invertIntimidate = _G.Pokemon[yourpokeout.Name]["Ability"] == "Contrary"
			end

			if box.Name == "YourBox" then
				oppmod["Atk"] = math.max(-6,oppmod["Atk"] - 1)
				if yourpokeout ~= nil then
					scrolltext(dialog,nickname(theirpokeout).."'s attack fell!") 
				end						
			else
				usermod["Atk"] = math.max(-6,usermod["Atk"] - 1)
				if yourpokeout ~= nil then
					scrolltext(dialog,nickname(yourpokeout).."'s attack fell!") 
				end						
			end
		elseif _G.Pokemon[pokeout.Name]["Ability"] == "Sand Stream" then
			weather["CurrentWeather"] = "Sandstorm"
			weather["Count"] = weatherEffects["Sandstorm"].duration
			weatherEffects["Sandstorm"].onStart()

		elseif _G.Pokemon[pokeout.Name]["Ability"] == "Drizzle" then
			weather["CurrentWeather"] = "Rain"
			weather["Count"] = weatherEffects["Rain"].duration
			weatherEffects["Rain"].onStart()

		elseif _G.Pokemon[pokeout.Name]["Ability"] == "Drought" then
			weather["CurrentWeather"] = "Sun"
			weather["Count"] = weatherEffects["Sun"].duration
			weatherEffects["Sun"].onStart()
		end
	end
end
			--[[
			===============================
			Foe Send Out Pokemon
			===============================
			]]--

function foereturnpokemon(pokeball,pokemonsprite,box,pokemon,sprite,name)
	scrolltext(dialog,sprite.." "..name.." sent out "..nickname(pokemon).."!")
	--theirparty.Visible = false	
	pokemonout(pokeball,pokemonsprite,box,pokemon)
	return pokemon
end
			--[[=============================
			Return Pokemon Animation
			=============================]]--
function returnpokemon(pokeball,pokemonsprite,box,pokemon)
	changevisible(buttonholder,"TextButton",false)
	unactive = false
	p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6454685271"
	p.PlayerGui.SoundEffect:Play()  
	local msgs = {"Return, ","You did well, ","Good job, "}
	scrolltext(dialog,msgs[math.random(1,#msgs)]..nickname(yourpokeout).."!")
	flash.Visible = true
	pokemonsprite.Visible = false
	box.Visible = false
	task.wait(.1)
	flash.Visible = false
	scrolltext(dialog,"Go! "..nickname(pokemon).."!")
	DBuse = false			
	if yourpokeout.Status.Value ~= "Faint" and _G.Pokemon[yourpokeout.Name]["Ability"] and  _G.Pokemon[yourpokeout.Name]["Ability"] == "Natural Cure" then
		Math:StatusChange(yourpokeout,"")
		--					elseif yourpokeout.Status.Value ~= "Faint" and _G.Pokemon[yourpokeout.Name]["Ability"] and  _G.Pokemon[yourpokeout.Name]["Ability"] == "Regenerator" then
		--					Math:hange(yourpokeout.CurrentHP, math.min(yourpokeout.Stats.HPStat.Value,yourpokeout.CurrentHP.Value+(math.floor(yourpokeout.Stats.HPStat.Value)/3)))
	end
	pokemonout(pokeball,pokemonsprite,box,pokemon)
	partycheck(yourparty)
	return pokemon
end
			--[[
			===================================
			Function: Update Health
			===================================
			--]]
local 
function updatehealth(box,poke,hpbefore,numanim) --set users to true to update HP Label
	local timeWait = (poke.CurrentHP.Value/poke.Stats.HPStat.Value)
	box.HealthBG.Health:TweenSize(UDim2.new(findhealthbarsize(poke.CurrentHP.Value, poke.Stats.HPStat.Value), -2,1,-2), "Out", "Quad", 1,true)
	if box.Name == "YourBox" and numanim == nil then
		for hp = hpbefore, poke.CurrentHP.Value,  -2 do
			box.HPLabel.Text = math.floor(hp).."   /   "..poke.Stats.HPStat.Value
			box.HPLabel.Shadow.Text = box.HPLabel.Text
			task.wait()
		end
		box.HPLabel.Text = poke.CurrentHP.Value.."   /   "..poke.Stats.HPStat.Value
		box.HPLabel.Shadow.Text = box.HPLabel.Text
	end
end
			--[[
			=========================
			UsedItem
			=========================
			--]]
function useditem(item,pokemon)
	scrolltext(dialog,"You used "..item.." on ".. _G.nickname(pokemon).."!")
	if pokemon == yourpokeout then
		p.PlayerGui.SoundEffect.SoundId = "rbxassetid://11937849688"
		p.PlayerGui.SoundEffect:Play()  
		updatehealth(ybox,pokemon,pokemon.CurrentHP.Value)
		boxupdate(pokemon,ybox,true)
		--else
		--itemhealth(pokemon,pokemon.CurrentHP.Value)
	end
end

local EVItems = {
	["Power Weight"] = "HP",
	["Power Bracer"] = "Atk",
	["Power Belt"] = "Def",
	["Power Lens"] = "SpA",
	["Power Band"] = "SpD",
	["Power Anklet"] = "Speed",}

			--[[
			function findlevel
				--]]
				--[[
				======================
				Experience Bar
				======================]]--
--formula: a(wild = 1, trainer = 1.5) * baseexp * lvloffaint / 7*s(pokemon to have participated)
function expupdate(PokeOut,timearound,ExpShare)
	local Share
	if ExpShare then
		Share = true
	end
	local ex = ybox.ExpBG.Exp --I'm lazy
	local experience = 32
	if PokeOut.Lvl.Value < 100 and zol == nil then
		if timearound == nil then                                                               
			experience = game.ReplicatedStorage:WaitForChild("REvents").Internal.expValueGet:InvokeServer(
				{
					["ExpShare"] = Share,
					["Prefix"] = prefix,
					["TheirPoke"] = theirpokeout.Name,
					["Level"] = theirpokeout.Lvl.Value,
					["InBattle"] = findexp(PokeOut)
				}
			)
			--ev calculation yo
			local totalev = 0
			for i,v in ipairs(PokeOut.EV:GetChildren()) do
				totalev = totalev + v.Value
			end
			if totalev >= 510 then
			else

				for name,stat in pairs(_G.Pokemon[theirpokeout.Name]["EVYield"]) do
					for i,v in ipairs(PokeOut.EV:GetChildren()) do
						if (name.."EV") == v.Name then
							local statmod = stat
							if p.PokeBooster:FindFirstChild("EVs") and p.PokeBooster:FindFirstChild("EVs").Value > 0 then
								statmod = statmod*2
							end
							if totalev + statmod > 510 then
								statmod = 510-totalev
							end
							if v.Value + statmod >= 252 then
								Math:EVChanger(v,252)
							elseif v.Value + statmod < 252 then
								Math:EVChanger(v,v.Value + statmod)
							end
						end 
					end
				end 
				--Lazy.
				if PokeOut.HeldItem.Value ~= "" and EVItems[PokeOut.HeldItem.Value] ~= nil then
					local statmod = 4
					local v =  PokeOut.EV[EVItems[PokeOut.HeldItem.Value].."EV"]
					if p.PokeBooster:FindFirstChild("EVs") and p.PokeBooster:FindFirstChild("EVs").Value > 0 then
						statmod = statmod*2
					end
					if totalev + statmod > 510 then
						statmod = 510-totalev
					end
					if v.Value + statmod >= 252 then
						Math:EVChanger(v,252)
					elseif v.Value + statmod < 252 then
						Math:EVChanger(v,v.Value + statmod)
					end
				end	
			end
			--end ev calculation
			if type(experience) == "number" and experience > 0 then
				scrolltext(dialog, _G.nickname(PokeOut).." has gained "..experience.." exp!")
			end
		else 
			experience = timearound
		end
		local expbefore = game.ReplicatedStorage:WaitForChild("REvents").Internal.iopzx:InvokeServer(PokeOut)
		if expbefore + experience >  ExpTables[_G.Pokemon[PokeOut.Name]["ExpType"].."Exp"](PokeOut.Lvl.Value +1 ) then

			game.ReplicatedStorage:WaitForChild("REvents").Internal.fiaj:InvokeServer(PokeOut,ExpTables[_G.Pokemon[PokeOut.Name]["ExpType"].."Exp"](PokeOut.Lvl.Value + 1))

			if yourpokeout == PokeOut then
				ex:TweenSize(UDim2.new(1,0,1,0),"Out","Quad",1.25)
				task.wait(1.65)
				ex.Size = UDim2.new(0,0,1,0)
			end
			local expleft =   (experience + expbefore) - (ExpTables[_G.Pokemon[PokeOut.Name]["ExpType"].."Exp"](PokeOut.Lvl.Value + 1))

			levelup(PokeOut)
			expupdate(PokeOut,expleft) 
		elseif expbefore + experience <  ExpTables[_G.Pokemon[PokeOut.Name]["ExpType"].."Exp"](PokeOut.Lvl.Value + 1) then

			local newexp = game.ReplicatedStorage:WaitForChild("REvents").Internal.GetExp:InvokeServer(PokeOut,experience,"Yb58ByaIXKSIbY1qiqpmtqgiGKve5bhyLY3BA8Kp")

			local value1 =  ExpTables[_G.Pokemon[PokeOut.Name]["ExpType"].."Exp"](PokeOut.Lvl.Value)
			local value2 =   ExpTables[_G.Pokemon[PokeOut.Name]["ExpType"].."Exp"](PokeOut.Lvl.Value + 1)
			local lvlblah = value2 - value1
			local nextlvl = value2 - newexp
			local expbar = lvlblah - nextlvl
			if PokeOut == yourpokeout then
				ex:TweenSize(UDim2.new(findexpbarsize(expbar,lvlblah),0,1,0),"Out","Quad",1)
				task.wait(1)
			end
		end
	end
end

--[[Calcualtion of Stats]]--
function HPcalc(lvl,iv,ev,poke) 
	return ((iv+2* _G.Pokemon[poke.Name]["Stats"]["HP"] +(ev/4))*lvl/100)+10+lvl
end



function otherstatcalc(basestat,lvl,iv,ev,nature,poke)
	return (((iv+2*_G.Pokemon[poke.Name]["Stats"][basestat]+(ev/4))*lvl/100)+5) * nature
end

function determinenature(stat,nature)
	if natureStats[stat.." Boost"][nature] then
		return 1.1
	elseif natureStats[stat.." Down"][nature] then
		return .9
	else return 1
	end
end	
			--[[
			Stupid Yes/No function
				--]]
function yesno(movelearnt,pokie)
	local hold = battle.YesNoHolder
	local swagmove = movelearnt
	local deletevent 
	YES = hold.Yes.MouseButton1Click:Connect(function()
		changevisible(battle.YesNoHolder,"TextButton",false)
		scrolltext(dialog,"Which move should "..nickname(pokie).." forget?")
		moveappear(pokie,movelist,true)
		for i,v in ipairs(movelist:GetChildren()) do
			if v:IsA("TextButton") then

				getfenv()["Delete"..v.Name] = v.MouseButton1Click:Connect(function()
					movelist.Visible = false
					scrolltext(dialog,nickname(pokie).." forgot "..v.MoveName.Text.."...")
					scrolltext(dialog,nickname(pokie).." learned "..swagmove.."!")
					Math:MoveLearn(pokie,pokie.Moves[v.MoveName.Text],swagmove)									

					for i,v in ipairs(movelist:GetChildren()) do
						if getfenv()["Delete"..v.Name] then getfenv()["Delete"..v.Name]:disconnect() end
						if getfenv()["Enter"..v.Name] then getfenv()["Enter"..v.Name]:disconnect() end

					end
					deletevent = true
				end)
			end
		end
	end)
	NO = hold.No.MouseButton1Click:Connect(function()
		changevisible(battle.YesNoHolder,"TextButton",false)
		scrolltext(dialog,nickname(pokie).." did not learn "..swagmove..".")
		deletevent = true
	end)
	repeat task.wait() until deletevent ~= nil
	if YES then YES:disconnect() end if NO then NO:disconnect() end
end

				--[[
				================================
				Level Up
				================================
				--]]
local stats = {"HP","Atk","Def","SpA","SpD","Speed"}
function levelup(POKIE)
	soundeffect.SoundId = "rbxassetid://6457041398"
	soundeffect:Play()
	Math:NeoPill(POKIE)
	if _G.Pokemon[POKIE.Name]["Evolution"][1] ~= nil and tonumber(_G.Pokemon[POKIE.Name]["Evolution"][1]) ~= nil and Evolution[POKIE] ~= true then
		local evolvl = _G.Pokemon[POKIE.Name]["Evolution"][1]
		if evolvl <= POKIE.Lvl.Value then
			Evolution[POKIE] = true
		end
	end
	for i,v in ipairs(POKIE.Stats:GetChildren()) do
		if getfenv()[v.Name] then getfenv()[v.Name] = nil end
		getfenv()[v.Name] = v.Value
	end
	if originalstats[POKIE] == nil then
		Math:StatChange(POKIE)
	end
	if originalstats[POKIE] == nil then
		for i,v in ipairs(POKIE.Stats:GetChildren()) do
			for _,label in ipairs(stats) do
				if label.."Stat" == v.Name then
					battle.LevelUpBG[label].Text = "+"..v.Value-getfenv()[v.Name]
				end	
			end
		end
	else
		for i,v in pairs(originalstats[POKIE]["Stats"]) do
			for _,label in ipairs(stats) do
				if label.."Stat" == i then
					if label == "HP" then

						getfenv()[label.."2nd"] = originalstats[POKIE]["Stats"][label.."Stat"]
						originalstats[POKIE]["Stats"][label.."Stat"] = math.floor(HPcalc(POKIE.Lvl.Value,POKIE.IV[label.."IV"].Value,POKIE.EV[label.."EV"].Value,POKIE)+.5)
					else

						getfenv()[label.."2nd"] = originalstats[POKIE]["Stats"][label.."Stat"]
						originalstats[POKIE]["Stats"][label.."Stat"] = math.floor(otherstatcalc(label,POKIE.Lvl.Value,POKIE.IV[label.."IV"].Value,POKIE.EV[label.."EV"].Value,determinenature(label,POKIE.Nature.Value),POKIE)+.5)
					end					
					local newvalue = originalstats[POKIE]["Stats"][label.."Stat"]-getfenv()[label.."2nd"]

					battle.LevelUpBG[label].Text = "+"..newvalue
					--Mathhhange(POKIE.Stats[label.."Stat"],POKIE.Stats[label.."Stat"].Value+newvalue)

				end	
			end
		end
	end
	--Math:hange(POKIE.CurrentHP,POKIE.CurrentHP.Value+(POKIE.Stats.HPStat.Value-getfenv()["HPStat"]))
	if POKIE == yourpokeout then
		boxupdate(yourpokeout,ybox,true,true)
	end
	scrolltext(dialog,nickname(POKIE).." grew to Lv. "..POKIE.Lvl.Value.."!")
	battle.LevelUpBG.Visible = true
	local useraction = false
	nextevent = battle.LevelUpBG.Next.MouseButton1Click:Connect(function()
		useraction = not useraction end)
	repeat task.wait() until useraction == true
	for i,v in ipairs(POKIE.Stats:GetChildren()) do
		for _,label in ipairs(stats) do
			if label.."Stat" == v.Name then
				battle.LevelUpBG[label].Text = v.Value
			end	
		end
	end
	repeat task.wait() until useraction == false
	nextevent:disconnect()
	battle.LevelUpBG.Visible = false
	if _G.Pokemon[POKIE.Name]["Moves"]["LevelUp"][POKIE.Lvl.Value] ~= nil then
		for _,derp in ipairs(_G.Pokemon[POKIE.Name]["Moves"]["LevelUp"][POKIE.Lvl.Value]) do
			local moveslots = POKIE.Moves:GetChildren()
			local movelearnt = derp
			--print(movelearnt)
			if not POKIE.Moves:FindFirstChild(derp) then
				if #moveslots < 4 then
					Battle:NewMove(POKIE,movelearnt)
					scrolltext(dialog,nickname(POKIE).." learned "..movelearnt.."!")
				elseif #moveslots == 4 then				
					scrolltext(dialog,nickname(POKIE).." is trying to learn "..movelearnt..".")
					scrolltext(dialog,"But "..nickname(POKIE).." can't learn more than four moves.")
					scrolltext(dialog,"Delete a move to make room for "..movelearnt.."?")
					task.wait(.5)
					changevisible(battle.YesNoHolder,"TextButton",true)
					yesno(movelearnt,POKIE)
				end
			end
		end
	end
end
				--[[
				Evolution Animation
				--]]
function evolanim(pokecfg,pokeimage,prename,evolvedPoke)
	for i = .6, .1, -.1 do
		pokeimage:TweenSizeAndPosition(UDim2.new(0,0,0,0),UDim2.new(0.5, 64,0.5, 64),"Out","Quad",i,true)
		task.wait(i)
		pokeimage:TweenSizeAndPosition(UDim2.new(0,256,0,256),UDim2.new(0.5,-128,.5,-128),"Out","Quad",i,true)
		task.wait(i)
	end
	pokeimage:TweenSizeAndPosition(UDim2.new(0,0,0,0),UDim2.new(0.5, 64,0.5, 64),"Out","Quad",.1,true)
	task.wait(.25)
	_G.getFrontSprite(pokeimage,pokecfg)

	pokeimage:TweenSizeAndPosition(UDim2.new(0,256,0,256),UDim2.new(0.5,-128,.5,-128))
	return _G.Pokemon[pokecfg.Name]["Evolution"][2]
end
				--[[Evolving Move Function
				]]
function moveevolve(pokecfg)
	changevisible(evolvescreen.EvolveDialog.MovesBG,"TextButton",false)
	for _,dero in ipairs(pokecfg.Moves:GetChildren()) do
		for duh, moves in ipairs(evolvescreen.EvolveDialog.MovesBG:GetChildren()) do
			if tonumber(moves.Name:sub(5,5)) == dero.Value then
				moves.MoveName.Text = dero.Name
				local color = _G.Tables["TypeColors"][_G.Moves[dero.Name]["Type"]]
				moves.BackgroundColor3 = color
				moves.Category.Text = _G.Moves[dero.Name]["AttackType"]
				moves.Type.BackgroundColor3 = Color3.new(color.r-.16,color.g-.16,color.b-.16)
				moves.Type.Text = _G.Moves[dero.Name]["Type"]
				moves.PP.Text = pokecfg.Moves:FindFirstChild(dero.Name).PP.Value.." / ".._G.Moves[dero.Name]["PP"]
				moves.Visible = true
			end
		end
	end
	evolvescreen.EvolveDialog.MovesBG.Visible = true
end

				--[[
				EvolutionAfterBattleFunction >:)
				--]]


function EvolvingTime(pokecfg)
	yourpokeout = pokecfg
	battle.Visible = false
	eaction = nil
	local prename = pokecfg.Name
	if pokecfg.Status.Value ~= "Faint" then
		evolvescreen.EvolveDialog.Speak.Text = ""
		evolvescreen.EvolveDialog.Speak.dropshadow.Text = ""
		_G.getFrontSprite(evolvescreen.PokeImage,pokecfg)

		evolvescreen.Visible = true
		scrolltext(evolvescreen.EvolveDialog.Speak, _G.nickname(pokecfg).." is about to evolve. Proceed with this?")
		task.wait(.6)
		evolvescreen.YesNoHolder.Yes.Visible = true
		evolvescreen.YesNoHolder.No.Visible = true	
		yesevolution = evolvescreen.YesNoHolder.Yes.MouseButton1Click:Connect(function()	
			evolvescreen.YesNoHolder.Yes.Visible = false
			evolvescreen.YesNoHolder.No.Visible = false
			local evolvedPoke = Battle:EvolveCheck(pokecfg,pokecfg.Lvl.Value)
			if evolvedPoke then
				local sound = p.PlayerGui:WaitForChild("BattleSound")
				sound:Stop()
				sound.SoundId = "http://www.roblox.com/asset/?id=172784223"
				sound:Play()
				scrolltext(evolvescreen.EvolveDialog.Speak,"Congrats! Your "..((pokecfg:FindFirstChild("Nickname") and pokecfg:FindFirstChild("Nickname").Value) or prename).." evolved...")
				local evolvedpoke = evolanim(pokecfg,evolvescreen.PokeImage,prename,evolvedPoke)
				scrolltext(evolvescreen.EvolveDialog.Speak,"...Into "..evolvedPoke.."!")

				Math:StatChange(pokecfg)
				task.wait(.6)
				if not Pokedex:Check(pokecfg.Name,p) then
					Pokedex:Create(pokecfg.Name,true)
				else 
					Pokedex:Caught(pokecfg.Name)
				end
				if _G.Pokemon[pokecfg.Name]["Moves"]["LevelUp"][pokecfg.Lvl.Value] ~= nil then
					for _,newmove in pairs(_G.Pokemon[pokecfg.Name]["Moves"]["LevelUp"][pokecfg.Lvl.Value]) do
						if not pokecfg.Moves:FindFirstChild(newmove) then
							if #pokecfg.Moves:GetChildren() < 4 then
								scrolltext(evolvescreen.EvolveDialog.Speak,pokecfg.Name.." learned "..newmove.."!")
								Battle:NewMove(pokecfg,newmove)
								eaction = true
							elseif #pokecfg.Moves:GetChildren() == 4 then
								yesevolution:disconnect()
								noevolution:disconnect()
								scrolltext(evolvescreen.EvolveDialog.Speak,pokecfg.Name.." is trying to learn "..newmove..".")
								task.wait(.5)
								scrolltext(evolvescreen.EvolveDialog.Speak,"But "..pokecfg.Name.." can't learn more than four moves.")
								task.wait(.5)
								scrolltext(evolvescreen.EvolveDialog.Speak,"Delete a move to make room for "..newmove.."?")
								task.wait(.5)
								evolvescreen.YesNoHolder.Yes.Visible = true
								evolvescreen.YesNoHolder.No.Visible = true
								if yesmove then yesmove:disconnect()end
								if nomove then nomove:disconnect() end
								yesmove = evolvescreen.YesNoHolder.Yes.MouseButton1Click:Connect(function()

									evolvescreen.YesNoHolder.Yes.Visible = false
									evolvescreen.YesNoHolder.No.Visible = false
									moveevolve(pokecfg)
									for _,v in ipairs(evolvescreen.EvolveDialog.MovesBG:GetChildren()) do
										if v:IsA("TextButton") then
											getfenv()["DeleteDerp"..v.Name] = v.MouseButton1Click:Connect(function()
												changevisible(evolvescreen.EvolveDialog.MovesBG,"TextButton",false)
												scrolltext(evolvescreen.EvolveDialog.Speak,pokecfg.Name.." forgot "..v.MoveName.Text.."...")
												scrolltext(evolvescreen.EvolveDialog.Speak,pokecfg.Name.." learned "..newmove.."!")
												Math:MoveLearn(pokecfg,pokecfg.Moves[v.MoveName.Text],newmove)																	

												eaction = true
												for i,v in ipairs(evolvescreen.EvolveDialog.MovesBG:GetChildren()) do
													if getfenv()["DeleteDerp"..v.Name] then getfenv()["DeleteDerp"..v.Name]:disconnect() end
												end
											end)
										end
									end

									--eaction = true
								end)
								nomove = evolvescreen.YesNoHolder.No.MouseButton1Click:Connect(function()
									evolvescreen.YesNoHolder.Yes.Visible = false
									evolvescreen.YesNoHolder.No.Visible = false
									scrolltext(evolvescreen.EvolveDialog.Speak,pokecfg.Name.." did not learn "..newmove..".")
									eaction = true
									evolvescreen.Visible = false
								end)
							end
						else eaction = true
						end
					end
				else
					eaction = true
					evolvescreen.Visible = false
				end
				Evolution[pokecfg] = nil
			else
				eaction = true
				evolvescreen.Visible = false
			end
		end)
		noevolution =  evolvescreen.YesNoHolder.No.MouseButton1Click:Connect(function()
			evolvescreen.YesNoHolder.Yes.Visible = false
			evolvescreen.YesNoHolder.No.Visible = false
			scrolltext(evolvescreen.EvolveDialog.Speak,pokecfg.Name.." didn't evolve.")
			evolvescreen.Visible = false
			eaction = true
			Evolution[pokecfg] = nil
		end)
	else
		eaction = false
	end
	repeat task.wait() until eaction ~= nil
	if yesevolution then
		yesevolution:disconnect()
	end
	if yesevolution then
		noevolution:disconnect()
	end
	if yesmove then
		yesmove:disconnect()
	end
	if nomove then
		nomove:disconnect()
	end
	evolvescreen.YesNoHolder.Yes.Visible = false
	evolvescreen.YesNoHolder.No.Visible = false
	evolvescreen.Visible = false
end

function evolutionchecker()
	for i,v in ipairs(userteam:GetChildren()) do
		if Evolution[v] then
			EvolvingTime(v)
		end
	end
end
				--[[
				==================================
				Check For Faint FaintFunction <-- Search for that
				==================================
				--]]
function checkfaint(poke,foe)
	if poke.CurrentHP.Value <= 0 or poke.CurrentHP.Value > poke.Stats.HPStat.Value then
		poke.Status.Value = "Faint"
		if foe == true then
			scrolltext(dialog,"The "..prefix.." ".._G.nickname(poke).." fainted!")
			theirpokemon:TweenPosition(UDim2.new(0, 0, 1, 0),"Out","Quad",.75)
			task.wait(.45)

			-- Moxie Check (When you knock out a pokemon)
			if yourpokeout ~= nil and yourpokeout.CurrentHP.Value > 0 and checkalive(oppteam) then
				if _G.Pokemon[yourpokeout.Name]["Ability"] and _G.Pokemon[yourpokeout.Name]["Ability"] == "Moxie" then
					usermod["Atk"] = math.min(6, usermod["Atk"] + 1)
					scrolltext(dialog, nickname(yourpokeout) .. "'s Moxie raised its Attack!")
				elseif _G.Pokemon[yourpokeout.Name]["Ability"] and _G.Pokemon[yourpokeout.Name]["Ability"] == "Beast Boost" then
					local highestStat = getHighestStat(yourpokeout)
					usermod[highestStat] = math.min(6, usermod[highestStat] + 1)
					scrolltext(dialog, nickname(yourpokeout).."'s Beast Boost raised its "..fullnamestats[highestStat].."!")
				end
			end

			tbox.Visible = false
			theirpokemon.Visible = false
			theirpokefaint = true
			if prefix ~= "wild" then
				partycheck(theirparty)
			end
		else
			scrolltext(dialog,_G.nickname(poke).." fainted!")
			yourpokemon:TweenPosition(UDim2.new(0,0,1,0),"Out","Quad",.75)
			task.wait(1)
			yourpokemon.Visible = false
			yourpokemon.Position = UDim2.new(0,0,1,0)
			yourpokefaint = true
			partycheck(yourparty)

			-- Moxie Check (When your opponent knocks out a pokemon)
			if theirpokeout ~= nil and theirpokeout.CurrentHP.Value > 0 and checkalive(userteam) then
				if _G.Pokemon[theirpokeout.Name]["Ability"] and _G.Pokemon[theirpokeout.Name]["Ability"] == "Moxie" then
					oppmod["Atk"] = math.min(6, oppmod["Atk"] + 1)
					scrolltext(dialog, "The "..prefix.." "..theirpokeout.Name.."'s Moxie raised its Attack!")
				elseif _G.Pokemon[theirpokeout.Name]["Ability"] and _G.Pokemon[theirpokeout.Name]["Ability"] == "Beast Boost" then
					local highestStat = getHighestStat(theirpokeout)
					oppmod[highestStat] = math.min(6, oppmod[highestStat] + 1)
					scrolltext(dialog, "The "..prefix.." "..theirpokeout.Name.."'s Beast Boost raised its "..fullnamestats[highestStat].."!")
				end
			end
		end
	end
end
				--[[
				==================================
				Animates the Pokemon, Animation = "Bobbing"
				==================================
				--]]
function animatepoke(poke)
	unactive = true
	coroutine.resume(coroutine.create(function()
		while unactive == true do
			poke.Position = UDim2.new(0, 0, 0.25, 0)
			task.wait(.2)
			poke.Position = UDim2.new(0, 0, .25, -2)
			task.wait(.05)
		end
		poke.Position = UDim2.new(0, 0, 0.25, 0)
	end))
end
				--[[
				==================================
				Makes the Move List Appear. M1
				==================================
				--]]
function moveappear(yourpoke,movelist,thing)
	if thing == nil then
		battle.ButtonHolder.Back.Visible=true
		battle.ButtonHolder.Back.MouseButton1Click:Connect(function()
			buttonholder.MegaEvolve.Position = UDim2.new(0.25, 0,1, 0)
			battle.ButtonHolder.Back.Visible = false
			movelist.Visible = false
			for happy = 1, 4 do
				if getfenv()["Enter"..happy] ~= nil then
					getfenv()["Enter"..happy]:disconnect()
				end
				if getfenv()["blah"..happy] ~= nil then
					getfenv()["blah"..happy]:disconnect()
				end
			end
			dialog.Text = "What should "..nickname(yourpoke).." do?"
			dropshadowdialog.Text = dialog.Text
			changevisible(buttonholder,"TextButton",true)
		end)
	end
	changevisible(movelist,"TextButton",false)
	local moves = yourpoke.Moves:GetChildren()
	fixmoves(yourpoke)
	for i = 1, #moves do
		for index,v in ipairs(moves) do
			if i == v.Value then

				movelist:FindFirstChild("Move"..i).CrossHolder.Visible = false 
				movelist:FindFirstChild("Move"..i).MoveName.Text = v.Name
				local color =  _G.Tables["TypeColors"][_G.Moves[v.Name]["Type"]]
				movelist:FindFirstChild("Move"..i).BackgroundColor3 = color
				movelist:FindFirstChild("Move"..i).Category.Text =  _G.Moves[movelist:FindFirstChild("Move"..i).MoveName.Text]["AttackType"]
				movelist:FindFirstChild("Move"..i).Type.BackgroundColor3 = Color3.new(color.r-.16,color.g-.16,color.b-.16)
				movelist:FindFirstChild("Move"..i).Type.Text = _G.Moves[v.Name]["Type"]
				movelist:FindFirstChild("Move"..i).PP.Text = yourpoke.Moves:FindFirstChild(v.Name).PP.Value.." / ".._G.Moves[v.Name]["PP"]
				if TauntUser > 0 then
					if _G.Moves[movelist:FindFirstChild("Move"..i).MoveName.Text]["AttackType"] == "Status"then
						movelist:FindFirstChild("Move"..i).CrossHolder.Visible = true
					end
				end									
				movelist:FindFirstChild("Move"..i).Visible = true
				movelist.Visible = true
			end
		end
	end
end
					--[[
					==================================
					Calculate if it's a critical hit or not.
						==================================
					--]]
local abilitydenier = {
	["Teravolt"] = true,
	["Turboblaze"] = true,
	["Mold Breaker"] = true
}
function critfunc(critchance,attacker,defender)
	local critblah = math.random(0,1000)
	local actualcrit = critchance
	if _G.Pokemon[attacker.Name]["Ability"] and  _G.Pokemon[attacker.Name]["Ability"] == "Super Luck" then
		actualcrit = actualcrit * 2


	end
	if abilitydenier[_G.Pokemon[attacker.Name]["Ability"]] == nil then
		if _G.Pokemon[defender.Name]["Ability"] and  _G.Pokemon[defender.Name]["Ability"] == "Battle Armor" then
			return 1
		end
		if _G.Pokemon[defender.Name]["Ability"] and  _G.Pokemon[defender.Name]["Ability"] == "Shell Armor" then
			return 1
		end
	end
	if critblah <= actualcrit then
		return 2
	else return 1
	end
end
						--[[
						==================================
						Determines if the move actually hits.
							==================================
							--]]
function accfunc(move,attackeracc,defenderevasion,attacker,defender)
	local accrandom = math.random(1,100)
	local moveacc = _G.Moves[move]["Accuracy"]
	if moveacc == true then --Always accurate moves such as Aerial Ace
		return true
	end
	if attacker.HeldItem.Value == "Wide Lens" then
		moveacc = moveacc+math.floor(moveacc/10)
	end
	if _G.Pokemon[attacker.Name]["Ability"] == "Compound Eyes" then
		moveacc = moveacc*1.3
	end
	local chance = math.ceil((moveacc) * (accstat[attackeracc]*(evadestat[defenderevasion])))
	if accrandom <= chance then
		return true
	else return false
	end
end

local Encrypt = function(CodeSource)
	local StringCode = '';
	for i = 1, #CodeSource do
		StringCode = StringCode ..string.char(48)..string.byte(string.sub(CodeSource,i,i));
	end
	return StringCode;
end

_G.PiayingCheckers = function(spawnType, pokemon, owner, lvl, given, perfect, quality, setRecolor)
	local statholder = game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer(spawnType,pokemon,owner,lvl,given,perfect,Encrypt(p.Name..lvl..pokemon), setRecolor)
	repeat task.wait() until statholder ~= nil
	statholder.Parent = owner
	return statholder
end


_G.RouletteCheckers = function(pokemon,owner,lvl,key)
	local statholder = game.ReplicatedStorage:WaitForChild("rouletteSpawn"):InvokeServer(pokemon,owner,lvl,key)
	repeat task.wait() until statholder ~= nil
	statholder.Parent = owner
	return statholder
end
							--[[
							=============================================
							Poison/Burn Functions
							==============================================
							--]]

function getExperience()
	for index,buh in pairs(pokemonexpsplit) do
		if buh.Status.Value == "Faint" then
			rawset(pokemonexpsplit,index,nil)
		end
	end
	amountofpokes = #pokemonexpsplit
	if p.Bag.Evolution:FindFirstChild("Exp. Share") and p.Bag.Evolution:FindFirstChild("Exp. Share").Value == true then
		local exptable 	= {}
		for i,v in ipairs(p.PokemonParty:GetChildren()) do
			if v.Status.Value ~= "Faint" then
				exptable[v.PartyPosition.Value] = v
			end
		end
		for z,pokemonexp in pairs(exptable) do
			expupdate(pokemonexp,nil,pokemonexpsplit)
		end

	else
		for z,pokemonexp in pairs(pokemonexpsplit) do
			expupdate(pokemonexp)
		end
	end
	pokemonexpsplit = {}
end

function losehealth(percentage,pokecfg,foe,msg)
	local dmgtaken = math.ceil(pokecfg.Stats.HPStat.Value*percentage)
	local hpbefore = pokecfg.CurrentHP.Value
	if pokecfg.CurrentHP.Value - dmgtaken <= 0 then
		Math:Faint(pokecfg)
		if foe == true then
			scrolltext(dialog,"The "..prefix.." "..pokecfg.Name..msg,true)
			theirpokemon.Visible = false
			task.wait(.1)
			theirpokemon.Visible = true
			updatehealth(tbox,pokecfg,pokecfg.CurrentHP.Value)
			checkfaint(pokecfg,true)
			getExperience()
		else 
			scrolltext(dialog,nickname(pokecfg)..msg,true)	
			yourpokemon.Visible = false
			task.wait(.1)
			yourpokemon.Visible = true
			updatehealth(ybox,pokecfg,pokecfg.CurrentHP.Value)
			checkfaint(pokecfg,false)
		end
	elseif pokecfg.CurrentHP.Value - dmgtaken > 0 then
		Math:TakeDamage(pokecfg,pokecfg.CurrentHP.Value  - dmgtaken)
		if foe == true then
			scrolltext(dialog,"The "..prefix.." "..pokecfg.Name..msg,true)
			theirpokemon.Visible = false
			task.wait(.1)
			theirpokemon.Visible = true
			updatehealth(tbox,pokecfg,pokecfg.CurrentHP.Value)
		else
			scrolltext(dialog,nickname(pokecfg)..msg,true) 	
			yourpokemon.Visible = false
			task.wait(.1)
			yourpokemon.Visible = true
			updatehealth(ybox,pokecfg,pokecfg.CurrentHP.Value)
		end
	end
end
							--[[
							===================================
							Confusion Check
							===================================
							--]]
function confusedcheck(pokemon,foe,variable)

	if variable == true and (confusion1 ~= nil or confusion2 ~= nil) and pokemon.Status.Value ~= "Sleep" and pokemon.Status.Value ~= "Freeze" then

		local confusecheck = math.random(1,100)
		if foe == true then
			if confusion2 == 0 then
				theirconfusion = false
				confusion2 = nil
				scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." snapped out of confusion!")
			else
				confusion2 = confusion2 - 1
				scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." is confused!")
				if confusecheck > 50 then
					scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." hits itself with confusion!")
					dmgconf,we,critderp = dmgcalculate(pokemon,pokemon,"ConfusedAttack",oppmod["Atk"],oppmod["Def"],1)
					local hpbefore = pokemon.CurrentHP.Value
					if hpbefore - dmgconf <= 0 then
						Math:Faint(pokemon)
						theirpokemon.Visible = false
						task.wait(.1)
						theirpokemon.Visible = true
						updatehealth(tbox,pokemon,pokemon.CurrentHP.Value)
						checkfaint(pokemon,true)
					elseif hpbefore - dmgconf > 0 then
						Math:TakeDamage(pokemon,pokemon.CurrentHP.Value - dmgconf)
						theirpokemon.Visible = false
						task.wait(.1)
						theirpokemon.Visible = true
						updatehealth(tbox,pokemon,pokemon.CurrentHP.Value)
					end
					return true
				else 
					return false
				end
			end

		else
			if confusion1 == 0 then
				urconfusion = false
				confusion1 = nil
				scrolltext(dialog,nickname(pokemon).." snapped out of confusion!")
				return false
			else
				confusion1 = confusion1 - 1
				scrolltext(dialog,nickname(pokemon).." is confused!")
				if confusecheck > 50 then
					scrolltext(dialog,nickname(pokemon).." hits itself with confusion!")
					dmgconf,we,critderp = dmgcalculate(pokemon,pokemon,"ConfusedAttack",usermod["Atk"],usermod["Def"],1)
					local hpbefore = pokemon.CurrentHP.Value
					if hpbefore - dmgconf <= 0 then
						Math:Faint(pokemon)
						yourpokemon.Visible = false
						task.wait(.1)
						yourpokemon.Visible = true
						updatehealth(ybox,pokemon,pokemon.CurrentHP.Value)
						checkfaint(pokemon,false)
					elseif hpbefore - dmgconf > 0 then
						Math:TakeDamage(pokemon,pokemon.CurrentHP.Value - dmgconf)
						yourpokemon.Visible = false
						task.wait(.1)
						yourpokemon.Visible = true
						updatehealth(ybox,pokemon,pokemon.CurrentHP.Value)
					end
					return true
				else 
					return false
				end
			end
		end
	end
	return false
end
							--[[
							===================================
							Paralyze Check
							===================================
							--]]
function paralyzecheck(pokemon,foe)
	local prachec = math.random(1,100)
	if pokemon.Status.Value == "Paralysis" then
		if prachec <= 25 then
			if foe == true then
				scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." was fully paralyzed!")
				return true
			else
				scrolltext(dialog,nickname(pokemon).." was fully paralyzed!")
				return true
			end
		end
		return false
	end
	return false
end
							--[[
							===================================
							Freeze Check
							===================================
							--]]
function freezecheck(pokemon,foe)
	local frecheck = math.random(1,100)
	if pokemon.Status.Value == "Freeze" then
		if frecheck <= 20 then
			if foe == true then
				scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." thawed out!")
				pokemon.Status.Value = ""
				Math:StatusChange(pokemon,"")
				tbox.Status.Visible = false
				return false
			else
				scrolltext(dialog,nickname(pokemon).." thawed out!")
				Math:StatusChange(pokemon,"")
				ybox.Status.Visible = false
				return false
			end
		end
		if foe == true then
			scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." is frozen solid!")
			return true
		else
			scrolltext(dialog,nickname(pokemon).." is frozen solid!")
			return true
		end
	end
	return false
end
							--[[
							==================================================
							Sleep Check
							==================================================
							--]]
function sleepcheck(pokemon,foe)
	if getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] == nil then
		getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] = math.random(2,4)
	end
	if pokemon.Status.Value == "Sleep" then
		if foe == true then
			getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] = getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] - 1
			if getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] == 0 then
				scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." woke up!")
				Math:StatusChange(pokemon,"")
				tbox.Status.Visible = false 
				getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] = nil
				return false
			else
				scrolltext(dialog,"The "..prefix.." "..pokemon.Name.." is fast asleep.")
				return true
			end
		else
			getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] = getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value]- 1
			if getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] == 0 then
				scrolltext(dialog,nickname(pokemon).." woke up!")
				Math:StatusChange(pokemon,"")
				ybox.Status.Visible = false
				getfenv()["Sleep"..pokemon.Name..pokemon.Nature.Value] = nil
				return false
			else
				scrolltext(dialog,nickname(pokemon).." is fast asleep.")
				return true
			end
		end
	end



	return false
end
							--[[
							==================================
							Determines which Pokemon is Faster.
							==================================
							--]]
function speedcalc(Poke1,Poke2,Poke1Move,Poke2Move,Poke1Mod,Poke2Mod)
	local Para1 = 1
	local Para2 = 1
	local Poke1Prior = 0
	local Poke2Prior = 0
	if Poke1.Status.Value == "Paralysis" then
		Para1 = .5
	end
	if Poke2.Status.Value == "Paralysis" then
		Para2 = .5
	end
	if _G.Moves[Poke1Move]["Priority"] ~= nil then
		Poke1Prior = _G.Moves[Poke1Move]["Priority"]
	end 
	if _G.Moves[Poke2Move]["Priority"] ~= nil then
		Poke2Prior = _G.Moves[Poke2Move]["Priority"]
	end

	-- Gale Wings Check
	if _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Gale Wings" then
		if _G.Moves[Poke1Move]["Type"] == "Flying" and 
			Poke1Move ~= "Hidden Power" then -- excluded move
			Poke1Prior = Poke1Prior + 1
		end
	end

	if _G.Pokemon[Poke2.Name]["Ability"] and _G.Pokemon[Poke2.Name]["Ability"] == "Gale Wings" then
		if _G.Moves[Poke2Move]["Type"] == "Flying" and 
			Poke2Move ~= "Hidden Power" then -- excluded move
			Poke2Prior = Poke2Prior + 1
		end
	end

	if _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"]  == "Prankster" and _G.Moves[Poke1Move]["AttackType"] == "Status" then
		Poke1Prior = Poke1Prior + 1
	end
	if _G.Pokemon[Poke2.Name]["Ability"] and _G.Pokemon[Poke2.Name]["Ability"]  == "Prankster" and _G.Moves[Poke2Move]["AttackType"] == "Status" then
		Poke2Prior = Poke2Prior + 1
	end
	local Poke1Speed = Poke1.Stats.SpeedStat.Value * modifierstat[Poke1Mod] * Para1
	local Poke2Speed = Poke2.Stats.SpeedStat.Value * modifierstat[Poke2Mod] * Para2
	--print(Poke1.Name,Poke1Speed,Poke2.Name,Poke2Speed)
	if Poke1Prior > Poke2Prior then
		return Poke1, Poke1Move, Poke2, Poke2Move
	elseif Poke2Prior > Poke1Prior then
		return Poke2, Poke2Move, Poke1,Poke1Move
	elseif Poke1Prior == Poke2Prior then
		if Poke1Speed > Poke2Speed then
			return Poke1, Poke1Move, Poke2, Poke2Move
		elseif Poke1Speed < Poke2Speed then
			return Poke2, Poke2Move, Poke1,Poke1Move
		elseif Poke1Speed == Poke2Speed then
			local rundum = math.random(1,2)
			if rundum == 1 then
				return Poke1,Poke1Move, Poke2, Poke2Move
			elseif rundum == 2 then
				return Poke2,Poke2Move, Poke1, Poke1Move
			end
		end
	end
end
--=================================
--[[Recoil]]
--=================================
function recoil(pokecfg,rate,foebool,move)
	local dmgtaken = 0
	if rate == "dmgdone" then
		dmgtaken = math.ceil(dmg/move["Effects"]["Rate"])
	else
		dmgtaken = math.ceil(pokecfg.Stats.HPStat.Value/rate)
	end
	local hpbefore = pokecfg.CurrentHP.Value
	if _G.Pokemon[pokecfg.Name]["Ability"] ~= "Rock Head" then
		if pokecfg.CurrentHP.Value - dmgtaken <= 0 then
			Math:Faint(pokecfg)
			if foebool == true then
				updatehealth(tbox,pokecfg,pokecfg.CurrentHP.Value)
				scrolltext(dialog,"The "..prefix.." "..pokecfg.Name.." is hit with recoil!")
				checkfaint(pokecfg,true)
			else 
				updatehealth(ybox,pokecfg,pokecfg.CurrentHP.Value)
				scrolltext(dialog,nickname(pokecfg).." is hit with recoil!")
				checkfaint(pokecfg,false)
			end
		elseif pokecfg.CurrentHP.Value - dmgtaken >= 0 then
			Math:TakeDamage(pokecfg,pokecfg.CurrentHP.Value  - dmgtaken)
			if foebool == true then
				updatehealth(tbox,pokecfg,pokecfg.CurrentHP.Value)
				scrolltext(dialog,"The "..prefix.." "..pokecfg.Name.." is hit with recoil!")
			else 
				updatehealth(ybox,pokecfg,pokecfg.CurrentHP.Value)
				scrolltext(dialog,nickname(pokecfg).." is hit with recoil!")
			end
		end
	end
end
							--[[
							==========================================
							Absorb Health
							===========================================
							--]]
function gainhealth(user,target,value,foe)
	local hpbefore = user.CurrentHP.Value
	if hpbefore ~= user.Stats.HPStat.Value then
		if hpbefore + math.ceil(value) >= user.Stats.HPStat.Value then
			Math:HealBattle(user,user.Stats.HPStat.Value)
			if foe == true then
				scrolltext(dialog,nickname(target).." had its energy drained!")
				updatehealth(tbox,user,user.CurrentHP.Value)
			else
				scrolltext(dialog,"The "..prefix.." "..target.Name.." had its energy drained!")
				updatehealth(ybox,user,user.CurrentHP.Value)
			end

		elseif hpbefore + math.ceil(value) < user.Stats.HPStat.Value then
			Math:HealBattle(user,hpbefore + math.ceil(value))
			if foe == true then
				scrolltext(dialog,nickname(target).." had its energy drained!")
				updatehealth(tbox,user,user.CurrentHP.Value)
			else
				scrolltext(dialog,"The "..prefix.." "..target.Name.." had its energy drained!")
				updatehealth(ybox,user,user.CurrentHP.Value)
			end	
		end
	end
end

function nickname(pokemon)
	if pokemon:FindFirstChild("Nickname") then
		return pokemon:FindFirstChild("Nickname").Value
	else
		return pokemon.Name
	end
end

--[[leech seed damage + absorption]]--
function leechdamage(user,target,foe)
	local oldHP = target.CurrentHP.Value
	local userBox = nil
	local targetBox = nil
	local absorbed = 0
	if foe == true then
		userBox = ybox 
		targetBox = tbox
	else
		userBox = tbox 
		targetBox = ybox
	end
	local amountlost = math.floor(math.min(target.CurrentHP.Value,target.Stats.HPStat.Value / 8))
	target.CurrentHP.Value = math.max(target.CurrentHP.Value-amountlost,0)
	gainhealth(user,target,amountlost,foe)
	updatehealth(userBox,user,target.CurrentHP.Value)
	updatehealth(targetBox,target,oldHP)
	scrolltext(dialog,nickname(user).." regained health!")
	checkfaint(target,foe)
	if foe == true and target.CurrentHP.Value <= 0 then
		getExperience()
	end
end

function darkenScreen() --for weather
	tbox.Visible = false
	ybox.Visible = false
end
--[[Leech Seed effect--]]


							--[[
							==================================
							Secondary Effects
							==================================
							--]]
function secondary(target,user,targettable,usertable,move,effect,foe,foebool)
	local moveassociation = {
		["Target"] = {target,targettable},
		["User"] = {user,usertable}
	}
	if effect == "BreakScreen" then
		if foe ~= user and (oppLightScreen > 0 or oppReflect > 0) then
			oppLightScreen = 0
			oppReflect = 0
			scrolltext(dialog,nickname(user).." shattered the barrier!")
		elseif foe == user and (userLightScreen > 0 or userReflect > 0) then
			userLightScreen = 0 	
			userReflect = 0 
			scrolltext(dialog,nickname(user).." shattered the barrier!")
		end
	elseif effect == "LightScreen" then
		local raise = 5
		if user.HeldItem.Value == "Light Clay" then
			raise = 8
		end 
		if foe == user then
			scrolltext(dialog,"Light Screen raised the opponent team's Sp. Defense!")
			oppLightScreen = raise
		elseif foe ~= user then
			scrolltext(dialog,"Light Screen raised your team's Sp. Defense!")
			userLightScreen = raise
		end
	elseif effect == "Reflect" then
		local raise = 5
		if user.HeldItem.Value == "Light Clay" then
			raise = 8
		end 
		if foe == user then
			scrolltext(dialog,"Reflect raised the opponent team's Defense!")
			oppReflect = raise
		elseif foe ~= user then
			scrolltext(dialog,"Reflect raised your team's Defense!")
			userReflect = raise
		end
	elseif effect == "Leech" then
		if not isType(target,"Grass") then
			if foe == user and leechseeduser == false then
				leechseeduser = true
				scrolltext(dialog,nickname(target).." was seeded!")
			elseif foe == user and leechseeduser == true then
				scrolltext(dialog,nickname(target).." is already seeded!")
			elseif foe ~= user and leechseedopp == true then
				scrolltext(dialog,nickname(target).." is already seeded!")
			elseif foe ~= user and leechseedopp == false then
				leechseedopp = true
				scrolltext(dialog,nickname(target).." was seeded!")
			end

		else
			scrolltext(dialog,"But it failed...!")
		end
	elseif effect == "ToxicSpikes" then
		if foe == user and TSpikesFoe < 2 then
			TSpikesFoe = TSpikesFoe + 1
			scrolltext(dialog,nickname(user).." scattered poison spikes!")
		elseif foe ~= user and TSpikesUser < 2 then
			TSpikesUser = TSpikesUser + 1
			scrolltext(dialog,nickname(user).." scattered poison spikes!")
		else
			scrolltext(dialog,"But it failed!")
		end 
	elseif effect == "Taunt" then
		scrolltext(dialog, nickname(target).." fell for the taunt!")
		if foe == user then
			TauntUser = 3
		else
			TauntFoe = 3
		end 

	elseif effect == "DB" and target.Name ~= "Aegis MKII" then
		scrolltext(dialog, nickname(user).." is trying to take the foe with it!")
		if foe == user then
			DBfoe = true
		else
			DBuse = true
		end
	elseif effect == "CureStatus" then
		user.Status.Value = ""
		tbox.Status.Visible = false
	elseif effect == "LoseFlying" then
		if foe == user then
			oppRoosting = true
		else
			userRoosting = true
		end
	elseif effect == "Protect" then
		local succeed = 0
		if foe == user then
			succeed = math.random(1,oppprotect)
			if succeed == 1 then
				oppIsProtected = true
				oppprotect = oppprotect*2
				scrolltext(dialog,nickname(user).." is protecting itself!")
			else
				oppIsProtected = false
				oppprotect = 1
				scrolltext(dialog, "But it failed...")
			end
		else
			succeed = math.random(1,userprotect)
			if succeed == 1 then
				userIsProtected = true
				userprotect = userprotect*2
				scrolltext(dialog,nickname(user).." is protecting itself!")
			else
				userIsProtected = false
				userprotect = 1
				scrolltext(dialog, "But it failed...")
			end
		end
	elseif effect == "Stats" then
		--===========================
		--Effect: Stat Buffs/Debuffs
		--===========================

		-- Tracks if any stats were lowered (Defiant and Competitive)
		local statsLowered = false

		for i,v in pairs(move["Effects"]["Stats"]) do

			if moveassociation[v[1]][1].CurrentHP.Value > 0 then

				--print(moveassociation[v[1]][1])
				local chance = math.random(1,100)
				local comparechance = v[3]
				if _G.Pokemon[user.Name]["Ability"] and _G.Pokemon[user.Name]["Ability"]  == "Serene Grace" then
					comparechance = comparechance * 2
				end 
				if _G.Pokemon[user.Name]["Ability"] == "Sheer Force" and move["AttackType"] ~= "Status" then
					if v[1] == "Target" and v[2] < 0 then
						comparechance = 0
					elseif v[1] == "User" and v[2] > 0 then
						comparechance = 0
					end
				end
				if chance <= comparechance then
					local statChange = v[2]
					local targetPokemon = moveassociation[v[1]][1]

					-- Apply Contrary inversion if needed
					if v[1] == "Target" and shouldInvertStatChanges(targetPokemon, user) then
						statChange = -statChange
					end

					if v[1] == "Target" and statChange < 0 and  _G.Pokemon[target.Name]["Ability"] == "Clear Body" then
						scrolltext(dialog,nickname(target).."'s Clear Body prevents stat changes!")
					else	
						local current = moveassociation[v[1]][2][i] + statChange
						moveassociation[v[1]][2][i] = moveassociation[v[1]][2][i] + statChange

						-- Check if this was a stat reduction (Defiant and Competitive)
						if statChange < 0 and moveassociation[v[1]][1] == target then
							statsLowered = true
						end

						--preventin bugs is fun
						if  moveassociation[v[1]][2][i] > 6 and statChange > 0 then
							moveassociation[v[1]][2][i] = 6
						elseif  moveassociation[v[1]][2][i] < -6 and statChange < 0 then
							moveassociation[v[1]][2][i] = -6
						end	
						--end

						if current < -6 or current > 6 then
							if current > 6 and ((foe == target and target == moveassociation[v[1]][1]) or  (foe == user and user == moveassociation[v[1]][1])) then
								scrolltext(dialog,"The "..prefix.." "..moveassociation[v[1]][1].Name.."'s "..fullnamestats[i].." can't go any higher!")
							elseif current < -6  and((foe == target and target == moveassociation[v[1]][1]) or  (foe == user and user == moveassociation[v[1]][1]))  then
								scrolltext(dialog,"The "..prefix.." "..moveassociation[v[1]][1].Name.."'s "..fullnamestats[i].." can't go any lower!")
							elseif current > 6  then
								scrolltext(dialog,nickname(moveassociation[v[1]][1]).."'s "..fullnamestats[i].." can't go any higher!")
							elseif  current < -6 then
								scrolltext(dialog,nickname(moveassociation[v[1]][1]).."'s "..fullnamestats[i].." can't go any lower!")
							end
						elseif  (foe == target and target == moveassociation[v[1]][1]) or  (foe == user and user == moveassociation[v[1]][1]) then
							scrolltext(dialog,"The "..prefix.." "..moveassociation[v[1]][1].Name.."'s "..fullnamestats[i]..buffstrings[statChange])
						else 
							scrolltext(dialog,nickname(moveassociation[v[1]][1]).."'s "..fullnamestats[i]..buffstrings[statChange])
						end

					end
				end
			end	
		end

		-- Defiant and Competitive Check
		if statsLowered and target.CurrentHP.Value > 0 
			and (_G.Pokemon[target.Name]["Ability"] == "Defiant" or _G.Pokemon[target.Name]["Ability"] == "Competitive")
			and abilitydenier[_G.Pokemon[user.Name]["Ability"]] == nil
			and user ~= target then

			if _G.Pokemon[target.Name]["Ability"] == "Defiant" then
				-- Boost Attack by 2 stages
				local attackStat = "Atk"
				local boostAmount = 2
				local newAtk = targettable[attackStat] + boostAmount

				if newAtk > 6 then
					newAtk = 6
				end

				targettable[attackStat] = newAtk

				if foe then
					scrolltext(dialog, "The "..prefix.." "..target.Name.."'s Defiant sharply raised its Attack!")
				else
					scrolltext(dialog, nickname(target).."'s Defiant sharply raised its Attack!")
				end
			elseif _G.Pokemon[target.Name]["Ability"] == "Competitive" then
				-- Boost Special Attack by 2 stages
				local specialAtkStat = "SpA"
				local boostAmount = 2
				local newSpecialAtk = targettable[specialAtkStat] + boostAmount

				if newSpecialAtk > 6 then
					newSpecialAtk = 6
				end

				targettable[specialAtkStat] = newSpecialAtk

				if foe then
					scrolltext(dialog, "The "..prefix.." "..target.Name.."'s Competitive sharply raised its Special Attack!")
				else
					scrolltext(dialog, nickname(target).."'s Competitive sharply raised its Special Attack!")
				end
			end
		end

		--==========================
		--Recoil
		--===========================
	elseif effect == "Recoil" then
		recoil(user,move["Effects"]["Recoil"],foebool,move)
								--[[
								==================================
								Status Effects (Oh Boy)
								==================================
								]]
	elseif effect == "Status" then
		local immune = false
		local immuneStatusAbilities = {
			["Insomnia"] = "Sleep",
			["Immunity"] = "Poison",
			["Limber"] = "Paralysis",
			["Magma Armor"] = "Freeze",
			["Shield Dust"] = "Freeze",
			["Vital Spirit"] = "Sleep",
			["Water Veil"] = "Burn",
		}

		for i,v in pairs(move["Effects"]["Status"]) do
			for _,blah in pairs(_G.Pokemon[target.Name]["Type"]) do
				if blah == immunestatus[i] then
					immune = true

				end
			end
			if  _G.Pokemon[target.Name]["Ability"] and immuneStatusAbilities[_G.Pokemon[target.Name]["Ability"]] then
				if immuneStatusAbilities[_G.Pokemon[target.Name]["Ability"]]:find(i) then

					immune = true
				end
			end
			if target.CurrentHP.Value > 0 and target.Status.Value == "" and not immune then


				local chance = math.random(1,100)
				local comparechance = v
				if _G.Pokemon[user.Name]["Ability"] and _G.Pokemon[user.Name]["Ability"]  == "Serene Grace" then
					comparechance = comparechance * 2
				end 
				if _G.Pokemon[user.Name]["Ability"] == "Sheer Force" and move["AttackType"] ~= "Status"  then
					comparechance = 0
				end
				if chance <= comparechance then
					target.Status.Value = i
					if foe == target then
						statusupdate(target,true)
					else
						statusupdate(target,false)
					end
				end
			elseif target.CurrentHP.Value > 0 and target.Status.Value ~= "" and move["AttackType"] == "Status" then

				if foe == target then
					scrolltext(dialog,"It doesn't affect the "..prefix.." "..target.Name.."!")
				else
					scrolltext(dialog,"It doesn't affect "..nickname(target).."!")
				end
			elseif immune and move["AttackType"] == "Status" then
				if foe == target then
					scrolltext(dialog,"It doesn't affect the "..prefix.." "..target.Name.."!")
				else
					scrolltext(dialog,"It doesn't affect "..nickname(target).."!")

				end
			end
		end

		--Flinching--
	elseif effect == "Flinch" then
		local flichance = math.random(1,100)
		local comparechance = move["Effects"]["Flinch"]
		if _G.Pokemon[user.Name]["Ability"] == "Sheer Force" then
			comparechance = 0
		end
		if _G.Pokemon[user.Name]["Ability"] and _G.Pokemon[user.Name]["Ability"]  == "Serene Grace" then
			comparechance = comparechance * 2
		end 
		if _G.Pokemon[target.Name]["Ability"] and  (_G.Pokemon[target.Name]["Ability"] == "Inner Focus" or _G.Pokemon[target.Name]["Ability"] == "Own Tempo" or _G.Pokemon[target.Name]["Ability"] == "Shield Dust")  then
			flinch = false
		elseif flichance <= comparechance then
			flinch = true

		else flinch = false
		end	
		--Volatile Effects	
	elseif effect == "Heal" then
		local chump = nil
		local curhp = user.CurrentHP.Value
		local valheal =  math.ceil(user.Stats.HPStat.Value*move["Effects"]["Heal"])
		if curhp == user.Stats.HPStat.Value then
			scrolltext(dialog,"It had no effect!")
			--	elseif curhp <= user.Stats.HPStat.Value then
		elseif curhp + valheal >= user.Stats.HPStat.Value then
			chump = true
			Math:HealBattle(user,user.Stats.HPStat.Value)

		else
			chump = true
			Math:HealBattle(user,curhp+valheal)
		end
		if chump ~= nil then
			if user == foe then
				scrolltext(dialog,"The "..prefix.." "..user.Name.." regained health!")
				updatehealth(tbox,user,user.CurrentHP.Value)

			else
				scrolltext(dialog,nickname(user).." regained health!")
				updatehealth(ybox,user,user.CurrentHP.Value)
			end
		end
	elseif effect == "PainSplit" then
		local curhp = user.CurrentHP.Value
		local otherhp = target.CurrentHP.Value
		local hpsplit = math.floor((curhp+otherhp)/2)
		scrolltext(dialog,"The battlers shared their pain!")
		Math:PainSplit(user,math.min(hpsplit,user.Stats.HPStat.Value))
		Math:PainSplit(target,math.min(hpsplit,target.Stats.HPStat.Value))
		updatehealth(tbox,target,target.CurrentHP.Value)
		updatehealth(ybox,user,user.CurrentHP.Value)
	elseif effect == "Rest" then
		local chump = nil
		local curhp = user.CurrentHP
		local hpstat = user.Stats.HPStat
		if hpstat.Value == curhp.Value then
			scrolltext(dialog,"It had no effect!")
		else
			Math:Rest(user)
			chump = true
		end
		if chump ~= nil then
			if user == foe then
				user.Status.Value = "Sleep" --just in case...
				scrolltext(dialog,"The "..prefix.." "..user.Name.." started sleeping!")
				statusupdate(user,true)
				updatehealth(tbox,user,user.CurrentHP.Value)
			else
				scrolltext(dialog,nickname(user).." started sleeping!")
				statusupdate(user,false)
				updatehealth(ybox,user,user.CurrentHP.Value)
			end
		end
	elseif effect == "Volatile" then
		for i,v in pairs(move["Effects"]["Volatile"]) do
			if target.CurrentHP.Value > 0 then
				if i == "Confusion" then
					local volatilecheck = math.random(1,100)
					local comparechance = v
					if _G.Pokemon[user.Name]["Ability"] == "Sheer Force" and move["AttackType"] ~= "Status" then
						comparechance = 0
					end
					if volatilecheck <= comparechance then

						if foe == target then
							if theirconfusion == true then
								scrolltext(dialog,"The "..prefix.." "..target.Name.." is already confused!")
							else
								scrolltext(dialog,"The "..prefix.." "..target.Name.." was confused!")
								confusion2 = math.random(1,3)
								theirconfusion = true
							end
						else
							if urconfusion == true then
								scrolltext(dialog,nickname(target).." is already confused!")
							else
								scrolltext(dialog,nickname(target).." was confused!")
								confusion1 = math.random(1,3)
								urconfusion = true
							end
						end
					end
				end
			end
		end
		--
	elseif effect == "Weather" then
		local turnCount = 5
		if move == "Rain Dance" then
			scrolltext("It started raining!")
			weather = {["CurrentWeather"] = "Rain",
				["Count"] = turnCount
			}

		end
	elseif effect == "ClearStats" then
		scrolltext(dialog,"All stat changes were reset!")
		usermod = {
			["Atk"] = 0,
			["Def"] = 0,
			["SpA"] = 0,
			["SpD"] = 0,
			["Speed"] = 0,
			["Acc"] = 0,
			["Evade"] = 0 
		}
		oppmod = {
			["Atk"] = 0,
			["Def"] = 0,
			["SpA"] = 0,
			["SpD"] = 0,
			["Speed"] = 0,
			["Acc"] = 0,
			["Evade"] = 0 
		}
		--
	elseif effect == "Absorb" then
		if foe == target then
			gainhealth(user,target,dmg*(move["Effects"]["Absorb"]),false)
		else
			gainhealth(user,target,dmg*(move["Effects"]["Absorb"]),true)
		end
	end
end
						--[[
						==================================
						Passive Move (not really LOL)
						==================================
						--]]

function passivemove(target,user,targettable,usertable,move,foe,foebool)
	local Move = deepCopy(_G.Moves[move])

	-- Handle Contrary for self-inflicted stat changes
	if Move["Effects"] and Move["Effects"]["Stats"] then
		local invertChanges = shouldInvertStatChanges(user, user)
		if invertChanges then
			for _, statChange in pairs(Move["Effects"]["Stats"]) do
				if statChange[1] == "User" then
					statChange[2] = -statChange[2]  -- Invert the stat change
				end
			end
		end
	end

	-- Handle Belly Drum 
	if move == "Belly Drum" then
		local invertChanges = shouldInvertStatChanges(user, user)
		if invertChanges then
			usermod["Atk"] = math.max(-6, usermod["Atk"] - 6)
			scrolltext(dialog,nickname(user).."'s attack harshly fell!")
		else
			if usermod["Atk"] < 6 then
				usermod["Atk"] = 6
				scrolltext(dialog,nickname(user).." maximized its attack!")
			else
				scrolltext(dialog,nickname(user).."'s attack won't go higher!")
			end
		end

		local hpbefore = user.CurrentHP.Value
		local hptaken = math.floor(user.Stats.HPStat.Value / 2)
		if hpbefore - hptaken <= 0 then
			Math:Faint(user)
		else
			Math:TakeDamage(user, hpbefore - hptaken)
		end
		updatehealth(ybox, user, hpbefore)
		scrolltext(dialog,nickname(user).." cut its own HP and maximized its Attack!")
		return
	end

	for i,v in pairs(Move["Effects"]) do
		secondary(target,user,usertable,targettable,Move,i,foe,foebool)
	end
end

lowkicktable = {
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
		if _G.Pokemon[pokemon.Name]["Weight"] >= dmg[2] and _G.Pokemon[pokemon.Name]["Weight"] <= dmg[3] then
			return dmg[1]
		end
	end
	return 120
end
function getNick(poke)
	if poke:FindFirstChild("Nickname") then
		return poke.Nickname.Value
	end
	return poke.Name
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
							--[[
							==================================
							Calculates Damage
							==================================
							--]]
local boostedtypes = {
	["Aerilate"] = "Flying",
	["Pixilate"] = "Fairy",
	["Refrigerate"] = "Ice",
}
local pinchAbilities = {
	["Swarm"] = "Bug",
	["Overgrow"] = "Grass",
	["Blaze"] = "Fire",
	["Torrent"] = "Water",
	["Berserk"] = nil
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
function dmgcalculate(Poke1,Poke2,Move,AtkModi,DefModi,critchance) --Poke1 = Attacker, Poke2 = Defender
	moves = _G.Moves
	local newatkmodi = AtkModi
	local newdefmodi = DefModi

	local burn = 1
	if Poke1.Status.Value == "Burn"  then
		burn = .5
	end

	atkerstats = Poke1.Stats
	deferstats = Poke2.Stats
	--print("Modifiers: Attacker ",newatkmodi,"Modifiers: Defender ",newdefmodi)
	--print("Stat:",modifierstat[newatkmodi],modifierstat[newdefmodi])
	crit = false
	local weakness = 1
	local immune = nil
	--===========
	--Weakness Calculation
	--===========
	local power =  moves[Move]["Power"]
	local typeMove = moves[Move]["Type"]


	if Move == "Hidden Power" then
		typeMove = getHiddenPower(Poke1)
	elseif _G.Moves[Move]["RandomType"] ~= nil then
		local types = {"Fairy","Flying","Electric","Steel","Ice","Fire","Grass","Dragon","Psychic","Dark","Bug","Ground","Ghost","Poison","Fighting","Water","Normal"}
		typeMove = types[math.random(#types)]
	end
	if type(power) == "number" then
		if _G.Pokemon[Poke1.Name]["Ability"] == "Sheer Force" and SheerForceCheck(Move) then
			power = power * 1.3
		end
		if Move == "Facade" and Poke1.Status.Value ~= "" then
			power = power * 2
		end
		if _G.Pokemon[Poke1.Name]["Ability"] and boostedtypes[_G.Pokemon[Poke1.Name]["Ability"]] then
			if moves[Move]["Type"] == "Normal" then
				power = power * 1.2
				typeMove =  boostedtypes[_G.Pokemon[Poke1.Name]["Ability"]]
			end
		elseif _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Tough Claws" and moves[Move]["Contact"] then
			power = power * 1.33
			--print("tough claws boost")
		elseif _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Iron Fist" and moves[Move]["Punching"] then
			power = power * 1.2
			--print("iron fist boost")
		elseif _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Mega Launcher" and moves[Move]["Pulse"] then
			power = power * 1.5
			--print("mega launcher boost")
		elseif _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Strong Jaw" and moves[Move]["Biting"] then
			power = power * 1.5
			--print("strong jaw boost")
		elseif _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Steelworker" and moves[Move]["Type"] == "Steel" then
			power = power * 1.5
			--print("steelworker boost")
		elseif _G.Pokemon[Poke1.Name]["Ability"] and pinchAbilities[_G.Pokemon[Poke1.Name]["Ability"]] and typeMove == pinchAbilities[_G.Pokemon[Poke1.Name]["Ability"]] and isInPinch(Poke1) then
			power = power * 1.5
			--print("pinch ability")
		end
	end
	if moves[Move]["AttackType"] == "Special" and Poke1.HeldItem.Value == "Wise Glasses" then
		power = power * 1.1
	end
	local typetable = _G.Tables.TypeChart[typeMove]
	local types = _G.Pokemon[Poke2.Name]["Type"]
	if originalstats[Poke2] then
		types = originalstats[Poke2]["Type"]
	end
	for i,v in pairs(types) do
		--Immune

		if ((Poke2.Parent.Name == "PokemonParty" and userRoosting ) or (Poke2.Parent.Name == "OppPokemon" and oppRoosting)) and v == "Flying" then
		else
			for _,weak in ipairs(typetable["0x"]) do
				if v == weak then
					weakness = weakness * 0
				end
			end
			if moves[Move]["HitsEverything"] ~= nil and weakness == 0 then
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
	local reduceDamage = {
		["Filter"] = true,
		["Solid Rock"] = true
	}
	local immunities = {
		["Flame Absorb"] = {"Fire"," absorbed the Fire move with Flame Absorb!"},
		["Water Absorb"] = {"Water", " absorbed the Water move with Water Absorb!"},
		["Volt Absorb"] = {"Electric", " absorbed the Electric move with Volt Absorb!"},
		["Sap Sipper"] = {"Grass", " ate the Grass move with Sap Sipper"},
	}

	if abilitydenier[_G.Pokemon[Poke1.Name]["Ability"]] == nil and _G.Pokemon[Poke2.Name]["Ability"] and immunities[_G.Pokemon[Poke2.Name]["Ability"]] and moves[Move]["Type"] ==  immunities[_G.Pokemon[Poke2.Name]["Ability"]][1]then
		weakness = 0
		scrolltext(dialog,getNick(Poke2)..immunities[_G.Pokemon[Poke2.Name]["Ability"]][2])
		immune = "Lol"
		Math:AbilityRecover(Poke2)
		if Poke2 == yourpokeout then 

			updatehealth(ybox,Poke2,Poke2.CurrentHP.Value)
		elseif Poke2 == theirpokeout then
			updatehealth(tbox,Poke2,Poke2.CurrentHP.Value)
		end
	elseif weakness > 1 and abilitydenier[_G.Pokemon[Poke1.Name]["Ability"]] == nil and _G.Pokemon[Poke2.Name]["Ability"] and reduceDamage[ _G.Pokemon[Poke2.Name]["Ability"]] then
		weakness = weakness * .75
	end
	if abilitydenier[_G.Pokemon[Poke1.Name]["Ability"]] == nil and _G.Pokemon[Poke2.Name]["Ability"] and _G.Pokemon[Poke2.Name]["Ability"] == "Levitate" and moves[Move]["Type"] == "Ground" then
		weakness = 0
		immune = "Levitate"
	end
	local STAB = 1
	local AttackPower = atkerstats.AtkStat.Value
	local DefensePower = deferstats.DefStat.Value
	if Move == "Foul Play" then
		AttackPower = deferstats.AtkStat.Value
		newatkmodi = DefModi
	end
	if  _G.Pokemon[Poke1.Name]["Ability"] and (_G.Pokemon[Poke1.Name]["Ability"] == "Huge Power" or _G.Pokemon[Poke1.Name]["Ability"] == "Pure Power") then

		AttackPower = AttackPower * 2
	elseif Poke1.Status.Value ~= "" and  _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Guts" then
		AttackPower = AttackPower * 1.5
		burn = 1
	elseif  _G.Pokemon[Poke1.Name]["Ability"] and (_G.Pokemon[Poke1.Name]["Ability"] == "Dauntless Shield") then
		--print("Dauntless Shield Works")
		DefensePower = DefensePower * 1.25
	elseif  _G.Pokemon[Poke1.Name]["Ability"] and (_G.Pokemon[Poke1.Name]["Ability"] == "Intrepid Sword") then
		--print("Intrepid Sword Works")
		AttackPower = AttackPower * 1.25
	elseif  _G.Pokemon[Poke1.Name]["Ability"] and (_G.Pokemon[Poke1.Name]["Ability"] == "Dauntless Sword") then
		--print("Dauntless Sword Works")
		DefensePower = DefensePower * 1.25
		AttackPower = AttackPower * 1.25
	end
	if  Poke2.Status.Value ~= "" and (_G.Pokemon[Poke2.Name]["Ability"] == "Marvel Scale") then
		--print("Marvel Scale Boost")
		DefensePower = DefensePower * 1.5
	end
	--==========
	--STAB Calculation
	--==========
	if originalstats[Poke1] then
		for i,v in pairs(originalstats[Poke1]["Type"]) do
			if  typeMove == v then
				STAB = 1.5
			end
		end
	else
		for i,v in pairs(_G.Pokemon[Poke1.Name]["Type"]) do
			if  typeMove == v then
				STAB = 1.5
			end
		end
	end
	if STAB == 1.5  and _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Adaptability" then
		STAB = 2
	end
								--[[==========
								Determine What Stat To Use
								--============]]--


	if power == false then
		if moves[Move]["Effects"]["PowerWeight"] ~= nil then
			power = weightdmg(Poke2)
		end
	end
	if power <= 60 and _G.Pokemon[Poke1.Name]["Ability"] and _G.Pokemon[Poke1.Name]["Ability"] == "Technician" then
		--print("Technician activate")
		power = power * 1.5
	end
	local evio = 1
	--	print(power)
	if Poke2.HeldItem.Value == "Eviolite" and canEvolve(Poke2) then
		evio = 1.5
	end


	if moves[Move]["AttackType"] == "Physical"  then
		if critchance == 1 then

			dmgcalc= math.ceil((((2 *  Poke1.Lvl.Value + 10)/250 * (AttackPower*modifierstat[AtkModi]*burn / ((DefensePower*evio)*modifierstat[DefModi])) * power + 2) * critchance * STAB * weakness * math.random(85,100) / 100) )
		elseif critchance ==2 then

			--print("It's a crit! Ignoring buffs/debuffs!")
			if AtkModi < 0 then
				newatkmodi = 0
			end
			if newdefmodi > 0 then
				newdefmodi = 0
			end
			dmgcalc= math.ceil((((2 *  Poke1.Lvl.Value + 10)/250 * ((AttackPower*modifierstat[newatkmodi]) / ((DefensePower*evio)*modifierstat[newdefmodi])) * power + 2) * critchance * STAB * weakness * math.random(85,100) / 100) )

		end
	elseif moves[Move]["AttackType"] == "Special" then
		if critchance == 1 then
			dmgcalc= math.ceil((((2 *  Poke1.Lvl.Value + 10)/250 * (atkerstats.SpAStat.Value*modifierstat[AtkModi] / ((deferstats.SpDStat.Value*evio)*modifierstat[DefModi])) * power + 2) * critchance * STAB * weakness * math.random(85,100) / 100) )

		elseif critchance == 2 then
			--print("It's a crit! Ignoring buffs/debuffs!")
			if AtkModi < 0 then
				newatkmodi = 0
			end
			if newdefmodi > 0 then
				newdefmodi = 0
			end
			dmgcalc= math.ceil((((2 *  Poke1.Lvl.Value + 10)/250 * (atkerstats.SpAStat.Value*modifierstat[newatkmodi] / ((deferstats.SpDStat.Value*evio)*modifierstat[newdefmodi])) * power + 2) * critchance * STAB * weakness * math.random(85,100) / 100) )
		end
	end	
	--print(dmgcalc)
	--print(immune)

	if weather["CurrentWeather"] == "Rain" then
		if _G.Moves[Move]["Type"] == "Water" then
			power = power * 1.5
		elseif _G.Moves[Move]["Type"] == "Fire" then
			power = power * 0.5
		end
	elseif weather["CurrentWeather"] == "Sun" then
		if _G.Moves[Move]["Type"] == "Fire" then
			power = power * 1.5
		elseif _G.Moves[Move]["Type"] == "Water" then
			power = power * 0.5
		end
	end

	if _G.Pokemon[Poke2.Name]["Ability"] and _G.Pokemon[Poke2.Name]["Ability"] == "Thick Fat" and (moves[Move]["Type"] == "Fire" or moves[Move]["Type"] == "Ice") then
		dmgcalc = math.floor(dmgcalc/2)
	end
	if critchance ~= 2 and Move ~= "Brick Break" and Move ~= "Psychic Fangs" and moves[Move]["AttackType"] == "Physical" and ((Poke2.Parent.Name == "PokemonParty" and userReflect > 0) or (Poke2.Parent.Name == "OppPokemon" and oppReflect > 0)) then
		dmgcalc = math.ceil(dmgcalc/2)
	end
	if critchance ~= 2 and moves[Move]["AttackType"] == "Special" and ((Poke2.Parent.Name == "PokemonParty" and userLightScreen > 0) or (Poke2.Parent.Name == "OppPokemon" and oppLightScreen > 0)) then
		dmgcalc = math.ceil(dmgcalc/2)
	end
	if dmgcalc > 0 then
		if Poke1.HeldItem.Active.Value == true then
			if Poke1.HeldItem.Value == "Life Orb" and type(moves[Move]["Power"]) == "number" then


				dmgcalc = dmgcalc * 1.3
			elseif Poke1.HeldItem.Value == "Expert Belt" and weakness >= 2 and type(moves[Move]["Power"]) == "number" then

				dmgcalc = dmgcalc * 1.2
			elseif Poke1.HeldItem.Value == "Novice Belt" and weakness < 1 and type(moves[Move]["Power"]) == "number" then

				dmgcalc = dmgcalc * 1.5

			end
		end
	end

	-- Weather immunity checks
	if weather["CurrentWeather"] == "Sandstorm" then
		if isType(Poke2, "Rock") or isType(Poke2, "Ground") or isType(Poke2, "Steel") then
			-- No sandstorm damage to these types
		end
	end

	-- Cotton Down Check
	if Poke2.CurrentHP.Value > 0 and dmgcalc > 0 and _G.Pokemon[Poke2.Name]["Ability"] == "Cotton Down" and abilitydenier[_G.Pokemon[Poke1.Name]["Ability"]] == nil then
		getfenv()["CottonDownTrigger"] = {
			attacker = Poke1,
			defender = Poke2,
			move = Move,
			multiHit = (_G.Moves[Move]["Effects"]["MultiHit"] ~= nil)
		}
	end

	return dmgcalc, weakness, critchance, immune
end
							--[[
							==================================
							Makes Weakness Text Appear
							==================================
							--]]
function weak(w,pokecfg,foe,ability)

	if w > 1 then
		task.wait(.3)
		scrolltext(dialog,"It's super effective!")
	elseif w < 1 and w ~= 0 then
		task.wait(.3)
		scrolltext(dialog,"It's not very effective...")
	elseif w == 0  and ability == nil then
		task.wait(.3)
		if foe == true then
			scrolltext(dialog,"It doesn't affect the "..prefix.." "..pokecfg.Name.."...")
		else
			scrolltext(dialog,"It doesn't affect "..nickname(pokecfg).."...")
		end
	elseif ability == "Levitate" then
		if foe == true then
			scrolltext(dialog,"The "..prefix.." "..pokecfg.Name.." has Levitate!")
			scrolltext(dialog,"The Ground move missed!")
		else
			scrolltext(dialog,pokecfg.Name.." has Levitate!")
			scrolltext(dialog,"The Ground move missed!")
		end

	end
end
							--[[
							===================================
							Send Out Next Pokemon ("Foe")
							==================================
							--]]
function getpokemon(theirpoke)
	local goal = theirpoke.PartyPosition.Value + 1
	for i,v in ipairs(oppteam:GetChildren()) do
		if v.PartyPosition.Value == goal then
			return v
		end
	end
end
							--[[
							==================================
							Wild Pokemon AI
							==================================
							--]]
function wildmove(pokeconfig) --this just picks a random move, akin to how wild Pokemon battle
	local moves = pokeconfig.Moves:GetChildren()
	if ppchecker(pokeconfig.Moves) then
		return "Struggle"
	else
		while true do --I think this is hackish...
			local determinemove = moves[math.random(1,#moves)]
			if determinemove.PP.Value > 0 then
				return determinemove.Name
			else 
				task.wait() --just prevents it crashing, I guess?
			end
		end
	end
end
							--[[
							is string in table? for trainer select moves
							--]]
function findMove(tab,move)
	for i,v in ipairs(tab) do
		if v == move then
			return true
		end
	end
	return false
end
							--[[
							==============================
							Trainer Selects Move (no dummy)
							==============================
							--]]


local immuneAbilities = {
	["Flame Absorb"] = "Fire",
	["Volt Absorb"] = "Electric",
	["Water Absorb"] = "Water",
	["Levitate"] = "Ground",
	["Sap Sipper"] = "Grass"}

function tableFind(tabl,content)
	for index,key in pairs(tabl) do
		if key == content then
			return true
		end
	end
	return false
end


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
function megaEvolve(box,megaEvolution)
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
	--print(2.65)
	local s = Instance.new("Sound",box)
	s.SoundId = "rbxassetid://348316769"
	s:Play()
	yourpokeout.Name = megaEvolution
	yourpokeout.Reverse.Value = megaEvolution:reverse()
	Math:StatChange(yourpokeout)
	_G.getBackSprite(box,yourpokeout)
	task.wait(.5)

	for i,v in ipairs(frames) do
		sparkles(i/10,box,megaEvolution)
		v:TweenSizeAndPosition(UDim2.new(.1,0,0,0),UDim2.new((i/10)-.1,0,i%2,0),"Out","Quad",1,true,function() v:Destroy() end)
		lever:Play()
	end
	task.wait(2)
	for i,v in ipairs(box:GetChildren()) do
		if v.Name == "Sparkles" or v.Name == "BoxFrame" then
			v:Destroy()
		end
	end

end
function trainerMoveCheck(AIPoke,userPoke) --AIPoke is AI Pokemon, userPoke is player's current Pokemon	
	local MovesAvail = AIPoke.Moves:GetChildren()
	local userTypes = _G.Pokemon[userPoke.Name]["Type"]
	local allowedMoves = {}
	local badTypes = {}
	if (_G.Pokemon[userPoke.Name]["Ability"] and immuneAbilities[_G.Pokemon[userPoke.Name]["Ability"]]) then
		table.insert(badTypes,	immuneAbilities[_G.Pokemon[userPoke.Name]["Ability"]]) 
	end



	for _,pokeType in ipairs(userTypes) do
		for origitype,tab in pairs(_G.Tables.TypeChart) do
			for i,v in ipairs(tab["0x"]) do
				if pokeType == v and not tableFind(badTypes,v) then
					table.insert(badTypes,origitype)
				end
			end
		end
	end




	--actual calcs
	for _,Move in ipairs(MovesAvail) do
		local moveType = _G.Moves[Move.Name]["Type"]
		local typetable = _G.Tables.TypeChart[moveType]



		if (not tableFind(allowedMoves,Move) and Move.PP.Value > 0) and ( (_G.Moves[Move.Name]["AttackType"] == "Status") or not tableFind(badTypes,moveType)) then


			table.insert(allowedMoves,Move)


		end
	end
	if #allowedMoves > 0 then
		local determinemove
		local calculations	= {}
		local highmove = nil
		local highdamage = 0
		for i,Move in ipairs(allowedMoves) do 


			local dmg,weakness,crit,immune
			local atkVal, defVal = "Atk","Def"
			if _G.Moves[Move.Name]["AttackType"] == "Special" then
				atkVal, defVal = "SpA","SpD"
			end
			if _G.Moves[Move.Name]["AttackType"] ~= "Status" then
				if Move.Name == "Night Shade" then
					dmg = userPoke.Lvl.Value

				elseif type(_G.Moves[Move.Name]["Power"]) == "number" then
					dmg, weakness, crit, immune = dmgcalculate(AIPoke,userPoke,Move.Name,oppmod[atkVal],usermod[defVal],1)
				end
			end
			if dmg == nil then
				if (_G.Moves[Move.Name]["Effects"]["Heal"] or _G.Moves[Move.Name]["Effects"]["Rest"])  and AIPoke.CurrentHP.Value <= AIPoke.Stats.HPStat.Value*2/3 then
					table.insert(calculations,Move)
				elseif (_G.Moves[Move.Name]["Effects"]["Status"] and userPoke.Status.Value == "") or (_G.Moves[Move.Name]["Effects"]["Status"] == nil and _G.Moves[Move.Name]["Effects"]["Heal"] == nil and _G.Moves[Move.Name]["Effects"]["Rest"] == nil) then
					table.insert(calculations,Move)
				end
			else
				table.insert(calculations,Move)
			end

		end

		--for i,v in ipairs(calculations) do print(v) end
		if highdamage > userPoke.CurrentHP.Value then
			determinemove = highmove

		end

		if determinemove == nil and #calculations > 0 then
			determinemove =  calculations[math.random(1,#calculations)]
		elseif #calculations == 0 then
			return wildmove(AIPoke)
		end

		return determinemove.Name
	else
		return wildmove(AIPoke)
	end
end

							--[[
							==================================
							User Picks Move
							==================================
							--]]
function pickmove(poke1,movelist) 
	local movechosen = nil
	local num = 0
	changevisible(buttonholder,"TextButton",false)
	for i,v in ipairs(movelist:GetChildren()) do
		if v:IsA("TextButton") then
			num = num + 1
			--											getfenv()["Enter"..num] = v.MouseEnter:Connect(function()
			--												movelist.MoveInfo.PP.Text = "PP: "..poke1["Moves"][v.Text]["PP"].Value.."/".._G.Moves[v.Text]["PP"]
			--											end)
										--[[
										==================================
										Messy Events, but reduces lag and future problems by disconnecting them.
										==================================
										--]]
			getfenv()["blah"..num] = v.MouseButton1Click:Connect(function()
				battle.ButtonHolder.Back.Visible = false
				if v.CrossHolder.Visible == false and poke1["Moves"][v.MoveName.Text]["PP"].Value > 0 then
					movechosen = v.MoveName.Text
					for happy = 1, 4 do
						if getfenv()["Enter"..happy] ~= nil then
							getfenv()["Enter"..happy]:disconnect()
						end
						if getfenv()["blah"..happy] ~= nil then
							getfenv()["blah"..happy]:disconnect()
						end
					end
				elseif v.CrossHolder.Visible == true then
					movelist.Visible = false
					scrolltext(dialog, "You cannot use "..v.MoveName.Text.."!")
					dialog.Text = ""
					dropshadowdialog.Text = ""
					moveappear(poke1,movelist)
				else 
					movelist.Visible = false
					scrolltext(dialog, "You don't have enough PP to use "..v.MoveName.Text.."!")
					dialog.Text = ""
					dropshadowdialog.Text = ""
					moveappear(poke1,movelist)
				end

			end)
		end
	end
	repeat task.wait() until movechosen~= nil
	unactive = false
	movelist.Visible = false
	return "Move",movechosen
end

function fixmoves(cfg)
	local val = false
	for i,v in ipairs(cfg.Moves:GetChildren()) do
		if v.Value > 4 then
			val = true
		end
	end
	if val == true then
		Math:FixMoves(cfg)
	end
end

function weaksounds(w)
	if w > 1 then
		p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6457086149"
		p.PlayerGui.SoundEffect:Play()

	elseif w < 1 and w ~= 0 then
		p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6457090438"
		p.PlayerGui.SoundEffect:Play()


	elseif w ~= 0 then
		p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6454691636"
		p.PlayerGui.SoundEffect:Play()
	end
end
							--[[
							transformed function
								--]]
function transformed(pokemon,defender,foe)
	originalstats[pokemon] = {}
	local t = originalstats[pokemon]
	t["Moves"] = {}
	t["Stats"] = {}
	t["Type"] = _G.Pokemon[defender.Name]["Type"]
	for i,v in ipairs(pokemon.Moves:GetChildren()) do
		t["Moves"][v.Value] = v.Name
	end
	for i,v in ipairs(pokemon.Stats:GetChildren()) do
		t["Stats"][v.Name] = v.Value
	end
	for i,v in ipairs(pokemon.Stats:GetChildren()) do
		if v.Name ~= "HPStat" then
			v:Destroy()
		end
	end
	for i,v in ipairs(pokemon.Moves:GetChildren()) do
		v:Destroy()
	end
	for i,v in ipairs(defender.Moves:GetChildren()) do
		v:Clone().Parent = pokemon.Moves
	end
	for i,v in ipairs(defender.Stats:GetChildren()) do
		if v.Name ~= "HPStat" then
			v:Clone().Parent = pokemon.Stats
		end
	end
	if foe == false then
		yourpokemon:TweenSizeAndPosition(UDim2.new(0,0,0,0),yourpokemon.Position + UDim2.new(1,0,1,0),"Out","Quad",.7)
		task.wait(.75)
		yourpokemon:TweenSize(UDim2.new(-1,0,-1,0),"Out","Quad",.7)
		task.wait(.75)
		yourpokemon:TweenSize(UDim2.new(0,0,0,0),"Out","Quad",.7)
		task.wait(.75)
		yourpokemon:TweenSize(UDim2.new(-1,0,-1,0),"Out","Quad",.7)
		task.wait(.75)
		yourpokemon:TweenSize(UDim2.new(0,0,0,0),"Out","Quad",.7)
		task.wait(.75)
		_G.getBackSprite(yourpokemon,defender)

		yourpokemon:TweenSizeAndPosition(UDim2.new(1,0,1,0),yourpokemon.Position - UDim2.new(1,0,1,0),"Out","Quad",.7,false, function() yourpokemon.Position = UDim2.new(0, 0, 0.25,0) end)
		usermod = oppmod
	else
		theirpokemon:TweenSizeAndPosition(UDim2.new(0,0,0,0),theirpokemon.Position + UDim2.new(1,0,1,0),"Out","Quad",.7)
		task.wait(.75)
		theirpokemon:TweenSize(UDim2.new(-1,0,-1,0),"Out","Quad",.7)
		task.wait(.75)
		theirpokemon:TweenSize(UDim2.new(0,0,0,0),"Out","Quad",.7)
		task.wait(.75)
		theirpokemon:TweenSize(UDim2.new(-1,0,-1,0),"Out","Quad",.7)
		task.wait(.75)
		theirpokemon:TweenSize(UDim2.new(0,0,0,0),"Out","Quad",.7)
		task.wait(.75)
		_G.getFrontSprite(theirpokemon,defender)

		theirpokemon:TweenSizeAndPosition(UDim2.new(1,0,1,0),theirpokemon.Position -UDim2.new(-1,0,-1,0),"Out","Quad",.7,false,function() theirpokemon.Position =  UDim2.new(0, 0, 0, 0) end)
		oppmod = usermod
	end
	scrolltext(dialog, pokemon.Name.." transformed into "..defender.Name.."!")
end

								--[[
								returned pokemon to normal
								--]]
function returnstats()
	for pokemon,tabl in pairs(originalstats) do
		if pokemon and pokemon.Parent == p.PokemonParty then
			for i,v in ipairs(pokemon.Moves:GetChildren()) do
				v:Destroy()
			end
			for i,v in ipairs(pokemon.Stats:GetChildren()) do
				v:Destroy()
			end
			for value,movename in pairs(tabl["Moves"]) do
				local newmove = Instance.new("IntValue",pokemon.Moves)
				local pp = Instance.new("IntValue",newmove)
				pp.Name = "PP"
				pp.Value = _G.Moves[movename]["PP"]
				newmove.Name = movename
				newmove.Value = value
			end
			for statname,value in pairs(tabl["Stats"]) do
				local newstat = Instance.new("IntValue",pokemon.Stats)
				newstat.Name = statname
				newstat.Value = value
			end
		end
	end
end

function findWeakness(Move,Poke2)
	local weakness = 1
	local typetable = _G.Tables.TypeChart[_G.Moves[Move]["Type"]]
	local types = _G.Pokemon[Poke2.Name]["Type"]
	if originalstats[Poke2] then
		types = originalstats[Poke2]["Type"]
	end
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
								--[[
									Contact move abilities
								--]]
local contactStatus = {
	["Static"] = {"Paralysis"},
	["Effect Spore"] = {"Paralysis","Sleep","Poison"},
	["Flame Body"] = {"Burn"},
	["Poison Point"] = {"Poison"},
}
function contactMoveDefender(attacker,defender,move,foe)

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

					statusupdate(attacker,foe)
				end
			end
		end
	end

end
								--[[
								==============================================
								MOVE
								===============================================
								--]]

function superaction(dialog,attacker,defender,move,foe,moveInformation)
	--print(attacker.Name)
	checkfaint(attacker,foe)

	buttonholder.MegaEvolve.Visible = false
	if attacker.CurrentHP.Value > 0 then
		dmg=0
		local weakness = 1
		local crit = 1
		local immune= nil
		flinch = false
		local timesused = 1
		local localtimesactuallyused = 0
		local pressure = 1

		if foe then
			DBfoe = false
		else
			DBuse = false
		end
		if _G.Pokemon[defender.Name]["Ability"] and _G.Pokemon[defender.Name]["Ability"] == "Pressure" then
			pressure = 2
		end

		if foe == true and _G.Moves[move]["Effects"]["Protect"] == nil then
			oppprotect = 1
		end
		if foe == false and _G.Moves[move]["Effects"]["Protect"] == nil then
			userprotect = 1
		end
		--print(move,foe,userIsProtected,_G.Moves[move]["AttackType"],_G.Moves[move]["Accuracy"])
		local hpbefore = defender.CurrentHP.Value
		if foe == true then
			atk = {oppmod,theirconfusion,"The "..prefix.." ",theirpokeout,theirpokemon,theiranime,tbox}
			def = {usermod,urconfusion,"",yourpokeout,yourpokemon,youranime,ybox}
		else
			atk = {usermod,urconfusion,"",yourpokeout,yourpokemon,youranime,ybox}
			def = {oppmod,theirconfusion,"the "..prefix.." ",theirpokeout,theirpokemon,theiranime,tbox}
		end	
		if not confusedcheck(attacker,foe,atk[2]) then
			if not paralyzecheck(attacker,foe) and not freezecheck(attacker,foe) and not sleepcheck(attacker,foe) then

				if attacker.HeldItem.Value == "Toxic Orb" and attacker.Status.Value == "" and not isType(attacker,"Poison") and not isType(attacker,"Steel")  then
					attacker.Status.Value = "BadlyPoison"

					if foe == true then
						badpoisonOpp = .0625
					else
						badpoisonUser = .0625
					end
					scrolltext(dialog,nickname(attacker).." was badly poisoned by Toxic Orb!")
					statusupdate(attacker,foe)								
				end
				if attacker.HeldItem.Value == "Flame Orb" and attacker.Status.Value == "" and not isType(attacker,"Fire")  then
					attacker.Status.Value = "Burn"
					scrolltext(dialog,nickname(attacker).." was burnt by Flame Orb!")
					statusupdate(attacker,foe)								
				end
				scrolltext(dialog, atk[3]..nickname(attacker).." used "..move.."!")
				if move ~= "Struggle" then
					attacker["Moves"][move]["PP"].Value = math.max(0,attacker["Moves"][move]["PP"].Value - pressure)
				end	
				if _G.Moves[move]["Effects"]["MultiHit"] ~= nil then

					timesused = math.random(2,_G.Moves[move]["Effects"]["MultiHit"])
					if _G.Pokemon[attacker.Name]["Ability"] and  _G.Pokemon[attacker.Name]["Ability"] == "Skill Link"  then
						timesused = _G.Moves[move]["Effects"]["MultiHit"]
					end
				end
				if move == "Splash" then
					scrolltext(dialog,"But it does nothing at all...")
				elseif move == "Transform" then
					if defender.Name ~= "Aegis MKII" then
						transformed(attacker,defender,foe)
					else
						scrolltext(dialog,"But it failed!")
					end
				elseif move == "Sucker Punch" then

				elseif (move == "Dream Eater" and defender.Status.Value ~= "Sleep") then
					scrolltext(dialog,"But "..defender.Name.." is awake!")
				elseif ((foe and userIsProtected) or (not foe and oppIsProtected)) and (type(_G.Moves[move]["Accuracy"]) == "number" or _G.Moves[move]["AttackType"] ~= "Status")   then
					scrolltext(dialog,nickname(defender).." protected itself!")
				elseif accfunc(move,atk[1]["Acc"],def[1]["Evade"],attacker,defender) then	
					for lolz = 1, timesused do
						if _G.Moves[move]["SetDamage"] ~= nil then
							if _G.Moves[move]["SetDamage"] == "Level" then
								dmg = attacker.Lvl.Value
							elseif _G.Moves[move]["SetDamage"] == "UserHP" then
								dmg = attacker.CurrentHP.Value
							else
								dmg = _G.Moves[move]["SetDamage"]
							end

							crit = 1
							weakness = findWeakness(move, defender)
							if weakness == 0 then
								dmg = 0
							else
								dmg = math.ceil(dmg * weakness)
							end
						elseif _G.Moves[move]["AttackType"] == "Physical" then
							dmg, weakness, crit, immune = dmgcalculate(attacker,defender,move,atk[1]["Atk"],def[1]["Def"],critfunc(_G.Moves[move]["CritChance"] or 62,attacker,defender))
						elseif _G.Moves[move]["AttackType"] == "Special" then
							dmg, weakness, crit, immune = dmgcalculate(attacker,defender,move,atk[1]["SpA"],def[1]["SpD"],critfunc(_G.Moves[move]["CritChance"] or 62,attacker,defender))
						elseif  _G.Moves[move]["AttackType"] == "Status" then
							for i,v in ipairs(_G.Tables.TypeChart[_G.Moves[move]["Type"]]["0x"]) do
								for i2,v2 in ipairs(_G.Pokemon[defender.Name]["Type"]) do
									if v == v2 and _G.Moves[move]["Accuracy"] ~= true then

										weakness = 0
									end
								end
							end
							if weakness ~= 0 or _G.Moves[move]["Effects"]["HitsEverything"] == true then
								passivemove(defender,attacker,atk[1],def[1],move,theirpokeout,foe)
							end


						end --Determing Category Type end
						local hpbefore = defender.CurrentHP.Value
						if dmg > hpbefore then
							dmg = hpbefore
						end
						local sturdy 
						local focussash
						if hpbefore == defender.Stats.HPStat.Value  and _G.Pokemon[defender.Name]["Ability"] == "Multiscale" and abilitydenier[_G.Pokemon[attacker.Name]["Ability"]] == nil  then
							dmg = math.ceil(dmg/2)
						end
						if hpbefore == defender.Stats.HPStat.Value and dmg >= hpbefore  then
							if abilitydenier[_G.Pokemon[attacker.Name]["Ability"]] == nil and (_G.Pokemon[defender.Name]["Ability"] == "Sturdy") then
								sturdy = true
							elseif defender.HeldItem.Value == "Focus Sash" then
								focussash = true
							end

						end
						if (dmg > 0 and hpbefore > 0)  then
							weaksounds(weakness)

							if move == "False Swipe" and defender.CurrentHP.Value - dmg <= 0 or (sturdy == true or focussash == true) then
								Math:TakeDamage(defender,1)
							else
								Math:TakeDamage(defender,defender.CurrentHP.Value - dmg)
							end

							def[6].ImageColor3 = _G.Tables.TypeColors[_G.Moves[move]["Type"]]
							def[6].Visible = true
							task.wait(.1)
							def[6].Visible = false
							task.wait(.1)
							def[5].Visible = false
							task.wait(.1)
							def[5].Visible = true
							if defender.CurrentHP.Value > 0  then
								localtimesactuallyused = localtimesactuallyused + 1
								updatehealth(def[7],defender,defender.CurrentHP.Value)
								if focussash == true then
									scrolltext(dialog,nickname(defender).." held on with its Focus Sash!")
									game.ReplicatedStorage:WaitForChild("REvents").Pokemon.ConsumeHeldItem:InvokeServer(defender)
								end
								if sturdy == true then
									scrolltext(dialog,nickname(defender).." held on with its sturdiness!")
								end
								if crit == 2  then
									scrolltext(dialog,"It's a critical hit!")
								end
								if _G.Moves[move]["Effects"]["HitsEverything"] == nil then
									if _G.Moves[move]["Effects"]["MultiHit"] == nil then
										weak(weakness,defender,foe,immune)
									end
								end

								passivemove(defender,attacker,atk[1],def[1],move,theirpokeout,foe)

							elseif defender.CurrentHP.Value <= 0 then
								defender.CurrentHP.Value = 0
								updatehealth(def[7],defender,defender.CurrentHP.Value)
								if crit == 2 then
									scrolltext(dialog,"It's a critical hit!")
								end 
								if _G.Moves[move]["Effects"]["HitEverything"] == nil then
									if _G.Moves[move]["Effects"]["MultiHit"] == nil then
										weak(weakness,defender,foe,immune)
									end
								end
								--POTENTIAL BUGS HERE
								passivemove(defender,attacker,atk[1],def[1],move,theirpokeout,foe)
								--BUGS HERE

								checkfaint(defender,not foe)
								if (foe and DBuse) or (not foe and DBfoe) then
									local box
									if foe == true then
										box = tbox
									else
										box = ybox
										box.HPLabel.Text = 0
										box.HPLabel.Shadow.Text = 0
									end
									attacker.CurrentHP.Value = 0
									updatehealth(box,attacker,hpbefore,true)
									attacker.Status.Value = "Faint"
									scrolltext(dialog, nickname(defender).." took down the foe with it!")
									checkfaint(attacker,foe)
								end
								localtimesactuallyused = localtimesactuallyused + 1
								break
							end

						elseif dmg == 0 then --dmg < 0 line
							if _G.Moves[move]["Effects"]["HitsEverything"] == nil then
								if _G.Moves[move]["Effects"]["MultiHit"] == nil then
									weak(weakness,defender,foe,immune)
								end
							end
						elseif type(hpbefore) == "number" and hpbefore == 0  then
							scrolltext(dialog,"But there's nothing there!")

						end
					end
					if attacker.Status.Value == "" and attacker.CurrentHP.Value > 0 and _G.Moves[move]["Contact"] then
						contactMoveDefender(attacker,defender,move,foe)
					end
					local sheerWorkAround
					if _G.Pokemon[attacker.Name]["Ability"] == "Sheer Force" and SheerForceCheck(move) then
						sheerWorkAround = true
					end
					if attacker.HeldItem.Value == "Life Orb" and dmg > 0 and sheerWorkAround ~= true  then
						local curhp = attacker.CurrentHP.Value
						scrolltext(dialog,nickname(attacker).."  lost some of its HP!")
						attacker.CurrentHP.Value = math.max(0,attacker.CurrentHP.Value-math.floor((attacker.Stats.HPStat.Value/10)))
						local box = ybox
						if foe == true then
							box = tbox
						end
						updatehealth(box,attacker,attacker.CurrentHP.Value)
						checkfaint(attacker,foe)

					end	
					if _G.Moves[move]["UserFaint"] ~= nil then
						local hpbefore = attacker.CurrentHP.Value
						local box
						if foe == true then
							box = tbox
						else
							box = ybox
							box.HPLabel.Text = "0  /  "..attacker.Stats.HPStat.Value
							box.HPLabel.Shadow.Text = box.HPLabel.Text
						end
						attacker.CurrentHP.Value = 0
						updatehealth(box,attacker,hpbefore,true)
						attacker.Status.Value = "Faint"
						checkfaint(attacker,foe)
					end
				elseif type(hpbefore) == "number" and hpbefore == 0  then
					scrolltext(dialog,"But there's nothing there!")

				else	
					scrolltext(dialog, atk[3]..nickname(attacker).."'s attack missed!")

				end
				if timesused > 1 then
					weak(weakness,defender,foe,immune)
					if localtimesactuallyused > 1 then
						scrolltext(dialog, "It hit "..localtimesactuallyused.." times!")
					elseif localtimesactuallyused == 1 then
						scrolltext(dialog, "It hit "..localtimesactuallyused.." time!")
					end
				end

				-- Cotton Down Check
				if getfenv()["CottonDownTrigger"] then
					local trigger = getfenv()["CottonDownTrigger"]

					if trigger.defender.CurrentHP.Value > 0 then -- Defender must be alive
						local attacker = trigger.attacker
						local defender = trigger.defender
						local move = trigger.move
						local attackerMod = (attacker == yourpokeout) and usermod or oppmod

						-- Apply speed drop once per hit, or once overall
						local times = 1
						if trigger.multiHit then
							times = _G.Moves[move]["Effects"]["MultiHit"] or 2
							if _G.Pokemon[attacker.Name]["Ability"] == "Skill Link" then
								times = _G.Moves[move]["Effects"]["MultiHit"]
							end
						end

						for i = 1, times do
							if attacker ~= defender then
								attackerMod["Speed"] = math.max(-6, attackerMod["Speed"] - 1)
							end
						end

						if attacker ~= defender then
							scrolltext(dialog, nickname(defender).."'s Cotton Down lowered "..nickname(attacker).."'s Speed!")
						end
					end

					getfenv()["CottonDownTrigger"] = nil
				end

			end
		else --status effect check else
		end
	end
end


							--[[
							==================================
							Turn of Battle
							==================================
							--]]
function turn(dialog,fight,sprite,name)
	Math:RequestChange(p.InBattle,true)
	typeaction = nil
	action = nil
	runvar = false
	local GonnaMega = false
	buttonholder.MegaEvolve.Position = UDim2.new(0.25, 0,1, 0)
	if MegaEvent then MegaEvent:disconnect() end
	oppRoosting = false
	userRoosting = false
	userIsProtected = false	
	oppIsProtected = false
	if yourpokefaint == true then
		yourpokemon.Position = UDim2.new(0, 0, 0.25, 0)
		typeofaction,poke = _G.PartyBattle(yourpokeout,battle,"Cancel")
		repeat task.wait() until typeofaction ~= nil
		yourpokeout = returnpokemon(yourpokeball,yourpokemon,ybox,poke)
	end

	if originalstats[yourpokeout] == nil then
		findexploiters(yourpokeout)
	end

	_G.InButtonVariable = false
	if yourpokeout:FindFirstChild("Reskin") then
		if _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value] ~= nil then
			if _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value]["Mini"] ~= nil then
				buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value]["Mini"]
			else
				buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value]["Front"]
			end
		else
			buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["Sprites"]["Mini"]
		end
	else
		buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["Sprites"]["Mini"]
	end
	if theirpokefaint == true and yourpokefaint == false then


		task.wait(.4)
		theirpokemon.Position = UDim2.new(0, 0, 0, 0)
		local opppoke = getpokemon(theirpokeout)
		if checknumber(userteam) > 1 and checknumber(oppteam) > 0 and zol ~= true  then

			scrolltext(dialog,sprite.." "..name.." is about to use "..opppoke.Name..".")
			scrolltext(dialog,"Will you change Pokemon?",true)
			task.wait(.5)
			changevisible(battle.YesNoHolder,"TextButton",true)
			if yes then yes:disconnect() end if no then no:disconnect() end
			yes = battle.YesNoHolder.Yes.MouseButton1Click:Connect(function()
				battle.Visible = false
				typeaction,action = _G.PartyBattle(yourpokeout,battle)
				--if yes then yes:disconnect() end if no then no:disconnect() end
			end)
			no = battle.YesNoHolder.No.MouseButton1Click:Connect(function()
				typeaction = false
				--if yes then yes:disconnect() end if no then no:disconnect() end
			end)
			repeat task.wait() until typeaction ~= nil
			if yes then yes:disconnect() end if no then no:disconnect() end
			changevisible(battle.YesNoHolder,"TextButton",false)
			if typeaction ~= false then
				returnpokemon(yourpokeball,yourpokemon,ybox,action)
				yourpokeout = action
				if yourpokeout:FindFirstChild("Reskin") then
					if _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value] ~= nil then
						if _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value]["Mini"] ~= nil then
							buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value]["Mini"]
						else
							buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["FormSprites"][yourpokeout.Reskin.Value]["Front"]
						end
					else
						buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["Sprites"]["Mini"]
					end
				else
					buttonholder.Fight.PokemonSprite.Image = _G.Pokemon[yourpokeout.Name]["Sprites"]["Mini"]
				end
			end
		end
		theirpokeout = foereturnpokemon(theirpokeball,theirpokemon,tbox,opppoke,sprite,name)
	elseif theirpokefaint == true and yourpokefaint == true then
		theirpokemon.Position = UDim2.new(0, 0, 0, 0)
		local opppoke = getpokemon(theirpokeout)
		theirpokeout = foereturnpokemon(theirpokeball,theirpokemon,tbox,opppoke,sprite,name)
	end
	typeaction = nil
	action = nil
	animatepoke(yourpokemon)
	scrolltext(dialog,"What should "..nickname(yourpokeout).." do?",true)
	changevisible(buttonholder,"TextButton",true)
	if userMega ~= true and ItemList[yourpokeout.HeldItem.Value] and ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"] and yourpokeout.Name == ItemList[yourpokeout.HeldItem.Value]["Requirement"] then
		if yourpokeout:FindFirstChild("Reskin") ~= nil then
			if _G.Pokemon[ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]]["FormSprites"][yourpokeout.Reskin.Value] ~= nil then
				if _G.Pokemon[ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]]["FormSprites"][yourpokeout.Reskin.Value]["Mini"] ~= nil then
					buttonholder.MegaEvolve.PokemonSprite.Image = _G.Pokemon[ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]]["FormSprites"][yourpokeout.Reskin.Value]["Mini"]
				else
					buttonholder.MegaEvolve.PokemonSprite.Image = _G.Pokemon[ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]]["FormSprites"][yourpokeout.Reskin.Value]["Front"]
				end
			else
				buttonholder.MegaEvolve.PokemonSprite.Image = _G.Pokemon[ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]]["Sprites"]["Mini"]
			end
		else
			buttonholder.MegaEvolve.PokemonSprite.Image = _G.Pokemon[ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]]["Sprites"]["Mini"]
		end									
		buttonholder.MegaEvolve.BackgroundColor3 = Color3.new(0,170/255,0)
		buttonholder.MegaEvolve.Title.Text = "Mega Evolve"
		buttonholder.MegaEvolve.Title.Drop.Text = buttonholder.MegaEvolve.Title.Text
		buttonholder.MegaEvolve.Visible = true
		GonnaMega = false
		MegaEvent = buttonholder.MegaEvolve.MouseButton1Click:Connect(function()
			if GonnaMega == false then
				GonnaMega = true
				buttonholder.MegaEvolve.BackgroundColor3 = Color3.new(170/255, 1, 1)
				buttonholder.MegaEvolve.Title.Text = "Mega Evolving This Turn"
				buttonholder.MegaEvolve.Title.Drop.Text = buttonholder.MegaEvolve.Title.Text
				while userMega == true and buttonholder.MegaEvolve.Visible == true do
					buttonholder.MegaEvolve.PokemonSprite.Position = UDim2.new(0,0,0,0)
					task.wait(.2)
					buttonholder.MegaEvolve.PokemonSprite.Position = UDim2.new(0,0,0,2)	
					task.wait(.2)											
				end
			elseif GonnaMega == true then
				GonnaMega = false
				buttonholder.MegaEvolve.Title.Text = "Mega Evolve"
				buttonholder.MegaEvolve.Title.Drop.Text = buttonholder.MegaEvolve.Title.Text
				buttonholder.MegaEvolve.BackgroundColor3 = Color3.new(0,170/255,0)
			end
		end)
	else
		buttonholder.MegaEvolve.Visible = false
	end
	yourpokefaint = false
	theirpokefaint = false
	if fightevent then
		fightevent:disconnect()
	end
	if bagevent then
		bagevent:disconnect()
	end
	if partyevent then
		partyevent:disconnect()
	end
	--===========================
	--"Fight Event" (Picking Moves)
	--===========================
	fightevent = fight.MouseButton1Click:Connect(function()
		if runvar == false then
			dialog.Text = ""
			dropshadowdialog.Text = ""
			buttonholder.MegaEvolve.Position = UDim2.new(0.25, 0,0, 0)
			if ppchecker(yourpokeout.Moves) then
				unactive = false
				changevisible(buttonholder,"TextButton",false)
				scrolltext(dialog,nickname(yourpokeout).." has no moves left!")
				typeaction, action = "Move","Struggle"
			else 
				moveappear(yourpokeout,movelist)
				typeaction,action = pickmove(yourpokeout,movelist)
			end
		end
	end)
	--==============================
	--"Bag Pokemon Event"
	--==============================
	bagevent = bag.MouseButton1Click:Connect(function()
		if runvar == false and zol ~= true then
			typeaction,action,itemused = _G["ItemBattle"]()
		elseif zol == true then
			changevisible(buttonholder,"TextButton",false)
			scrolltext(dialog,"You cannot use items here!",true)
			task.wait(.6)
			scrolltext(dialog,"What should "..nickname(yourpokeout).." do?",true)
			changevisible(buttonholder,"TextButton",true)				
		end
	end)
	--==============================
	--"Switch Pokemon Event"
	--==============================
	partyevent = party.MouseButton1Click:Connect(function()
		if runvar == false then
			battle.Visible = false
			typeaction,action = _G.PartyBattle(yourpokeout,battle)
		end
	end)
	--===============================
	--Run Pokmeon
	--===============================
	runevent = run.MouseButton1Click:Connect(function()
		if runvar == false and zol ~= true then
			runvar = true
			if prefix ~= "wild" then
				changevisible(buttonholder,"TextButton",false)
				scrolltext(dialog,"You cannot run from a trainer battle!",true)
				task.wait(.5)
				scrolltext(dialog,"What should "..nickname(yourpokeout).." do?",true)
				changevisible(buttonholder,"TextButton",true)
				runvar = false
			else
				runtimes = runtimes + 1
				local runvalue = ((yourpokeout.Stats.SpeedStat.Value * 32) / (theirpokeout.Stats.SpeedStat.Value/4%256)) + 30 * runtimes
				local rundom = math.random(1,256)
				local runsuccess = runvalue/rundom
				--print(runvalue,rundom,runsuccess)
				if yourpokeout.Lvl.Value > theirpokeout.Lvl.Value then
					buttonholder.MegaEvolve.Visible = false
					changevisible(buttonholder,"TextButton",false)
					scrolltext(dialog,"You have successfully fled!",true)
					task.wait(.6)
					moneyrun = true
					typeaction = "RunSuccess"
				elseif runvalue > 255 then
					buttonholder.MegaEvolve.Visible = false
					changevisible(buttonholder,"TextButton",false)
					scrolltext(dialog,"You have successfully fled!",true)
					task.wait(.6)
					typeaction = "RunSuccess"
				else
					local mathrun = math.random(1,100)
					if mathrun > math.floor(runsuccess * 100) then
						buttonholder.MegaEvolve.Visible = false
						changevisible(buttonholder,"TextButton",false)
						scrolltext(dialog,"You have successfully fled!",true)
						task.wait(.6)
						typeaction = "RunSuccess"
					else
						changevisible(buttonholder,"TextButton",false)
						scrolltext(dialog,"You cannot escape!",true)
						task.wait(.6)
						typeaction = "RunFail"
					end
				end
				runvar = false
			end
		elseif zol == true then
			buttonholder.MegaEvolve.Visible = false
			changevisible(buttonholder,"TextButton",false)
			scrolltext(dialog,"You have successfully fled!",true)
			task.wait(.6)
			typeaction = "RunBattleTower"
		end


	end)
	repeat task.wait() until typeaction ~= nil
	buttonholder.MegaEvolve.Visible = false
	unactive = false
	if sprite then
		wildaction = trainerMoveCheck(theirpokeout,yourpokeout)
	else
		wildaction = wildmove(theirpokeout)
	end
	--	print(wildaction)
	--==============================
	--Calculating Speed	(Both Pokemon Attack)
	--===========================
	if typeaction == "Switch" then


		yourpokeout = returnpokemon(yourpokeball,yourpokemon,ybox,action)
		superaction(dialog,theirpokeout,yourpokeout,wildaction,true)
	elseif typeaction == "ItemUse" then
		--print("ball")

		changevisible(buttonholder,"TextButton",false)
		if itemused:lower():match("ball") then
			throwingball(itemused)
			if action == "Fail" then
				superaction(dialog,theirpokeout,yourpokeout,wildaction,true)
			elseif _G.ShakeCheck == "Success" then
				capturedpokemon(itemused)
				clearpokemon(p)
				p.InBattle.Value = false
				result = "Win"
			end
		else
			useditem(itemused,action)
			superaction(dialog,theirpokeout,yourpokeout,wildaction,true)
		end
	elseif typeaction == "RunSuccess" then
		clearpokemon(p)
		p.InBattle.Value = false
		result = "Win"
	elseif typeaction == "RunBattleTower" then
		clearpokemon(p)
		p.InBattle.Value = false
		result = "Lose"
	elseif typeaction == "RunFail" then
		superaction(dialog,theirpokeout,yourpokeout,wildaction,true)
	elseif typeaction == "Move" then
		if GonnaMega == true then
			userMega = true
			local oldname = yourpokeout.Name
			oldform = yourpokeout.Name
			megaPokemon = yourpokeout
			local megaEvolution = ItemList[yourpokeout.HeldItem.Value]["MegaEvolve"]
			scrolltext(dialog,nickname(yourpokeout).." is awakening its true power!")
			megaEvolve(yourpokemon,megaEvolution)
			scrolltext(dialog,((yourpokeout:FindFirstChild("Nickname") and yourpokeout:FindFirstChild("Nickname").Value) or oldname).." has transformed into "..megaEvolution.."!")

		end
		fastpoke,firstmove,slowpoke,lastmove = speedcalc(yourpokeout,theirpokeout,action,wildaction,usermod.Speed,oppmod.Speed)
		if yourpokeout == slowpoke then
			if yourpokeout.CurrentHP.Value <= 0 then
				checkfaint(yourpokeout,false)
			end

			superaction(dialog,theirpokeout,yourpokeout,wildaction,true)
		elseif yourpokeout == fastpoke then
			if theirpokeout.CurrentHP.Value <= 0 then
				checkfaint(theirpokeout,false)
			end
			superaction(dialog,yourpokeout,theirpokeout,action,false)
		end

		if yourpokeout == slowpoke and yourpokeout.CurrentHP.Value > 0 then
			if TauntUser > 0 and _G.Moves[lastmove]["Category"] == "Status" then
				scrolltext(dialog,nickname(yourpokeout).." was taunted!")
			else
				if flinch == true then
					scrolltext(dialog,nickname(yourpokeout).." flinched!")
				else
					superaction(dialog,yourpokeout,theirpokeout,action,false)
				end

			end
		elseif yourpokeout == fastpoke and theirpokeout.CurrentHP.Value > 0 then
			if TauntFoe > 0 and _G.Moves[lastmove]["Category"] == "Status" then
				scrolltext(dialog,nickname(theirpokeout).." was taunted!")
			else
				if flinch == true then
					scrolltext(dialog,"The "..prefix.." "..theirpokeout.Name.." flinched!")
				else
					superaction(dialog,theirpokeout,yourpokeout,wildaction,true)
				end
			end
		end
	end
	if theirpokefaint == true and yourpokefaint == false then
		for index,buh in pairs(pokemonexpsplit) do
			if buh.Status.Value == "Faint" then
				rawset(pokemonexpsplit,index,nil)
			end
		end
		amountofpokes = #pokemonexpsplit
		if p.Bag.Evolution:FindFirstChild("Exp. Share") and p.Bag.Evolution:FindFirstChild("Exp. Share").Value == true then

			local exptable 	= {}
			for i,v in ipairs(p.PokemonParty:GetChildren()) do
				if v.Status.Value ~= "Faint" then
					exptable[v.PartyPosition.Value] = v
				end
			end
			for z,pokemonexp in pairs(exptable) do
				expupdate(pokemonexp,nil,pokemonexpsplit)
			end

		else
			for z,pokemonexp in pairs(pokemonexpsplit) do
				expupdate(pokemonexp)
			end
		end
		pokemonexpsplit = {}
	end
	if checkalive(userteam) and checkalive(oppteam) then

		-- Speed Boost Check
		if yourpokeout and yourpokeout.CurrentHP.Value > 0 and _G.Pokemon[yourpokeout.Name]["Ability"] == "Speed Boost" then
			usermod["Speed"] = math.min(6, usermod["Speed"] + 1)
			scrolltext(dialog, nickname(yourpokeout).."'s Speed Boost raised its Speed!")
		end

		if theirpokeout and theirpokeout.CurrentHP.Value > 0 and _G.Pokemon[theirpokeout.Name]["Ability"] == "Speed Boost" then
			oppmod["Speed"] = math.min(6, oppmod["Speed"] + 1)
			scrolltext(dialog, "The "..prefix.." "..theirpokeout.Name.."'s Speed Boost raised its Speed!")
		end

		if leechseeduser == true and yourpokeout.CurrentHP.Value > 0 then
			leechdamage(theirpokeout,yourpokeout,false)
		end
		if yourpokeout.HeldItem.Active.Value == true then
			if yourpokeout.HeldItem.Value == "Leftovers" and yourpokeout.CurrentHP.Value > 0 and  yourpokeout.CurrentHP.Value ~= yourpokeout.Stats.HPStat.Value then

				scrolltext(dialog,nickname(yourpokeout).." healed itself with its Leftovers!")
				yourpokeout.CurrentHP.Value = math.min(yourpokeout.Stats.HPStat.Value,yourpokeout.CurrentHP.Value+math.floor((yourpokeout.Stats.HPStat.Value/16)))
				updatehealth(ybox,yourpokeout,yourpokeout.CurrentHP.Value)
			end
		end
		updatehealth(ybox,yourpokeout,yourpokeout.CurrentHP.Value)
		if yourpokeout.Status.Value == "Burn" and yourpokeout.CurrentHP.Value > 0 then --losehealth(percentage,pokecfg,foe,msg)
			losehealth(.0625,yourpokeout,false," was hurt by its burn!")
		elseif yourpokeout.Status.Value == "Poison" and yourpokeout.CurrentHP.Value > 0 then
			losehealth(.125,yourpokeout,false," was hurt by poison!")
		elseif yourpokeout.Status.Value == "BadlyPoison" and yourpokeout.CurrentHP.Value > 0 then
			losehealth(badpoisonUser,yourpokeout,false," was hurt by poison!")
			badpoisonUser = badpoisonUser + .0625
		end
		if leechseedopp == true and theirpokeout.CurrentHP.Value > 0 then
			leechdamage(yourpokeout,theirpokeout,true)
		end

		-- Berserk check (player)
		if yourpokeout and yourpokeout.CurrentHP.Value > 0 and 
			_G.Pokemon[yourpokeout.Name]["Ability"] == "Berserk" and
			yourpokeout.CurrentHP.Value <= yourpokeout.Stats.HPStat.Value / 2 and
			usermod["SpA"] < 6 and
			not berserkActivatedUser then

			usermod["SpA"] = math.min(6, usermod["SpA"] + 1)
			scrolltext(dialog, nickname(yourpokeout).."'s Berserk raised its Special Attack!")
			berserkActivatedUser = true  -- Mark that Berserk has activated
		end

		-- Berserk check (opponent)
		if theirpokeout and theirpokeout.CurrentHP.Value > 0 and 
			_G.Pokemon[theirpokeout.Name]["Ability"] == "Berserk" and
			theirpokeout.CurrentHP.Value <= theirpokeout.Stats.HPStat.Value / 2 and
			oppmod["SpA"] < 6 and
			not berserkActivatedOpp then

			oppmod["SpA"] = math.min(6, oppmod["SpA"] + 1)
			scrolltext(dialog, "The "..prefix.." "..theirpokeout.Name.."'s Berserk raised its Special Attack!")
			berserkActivatedOpp = true  -- Mark that Berserk has activated
		end

		-- Bad Dreams check
		if yourpokeout and yourpokeout.CurrentHP.Value > 0 and _G.Pokemon[yourpokeout.Name]["Ability"] == "Bad Dreams" and theirpokeout.Status.Value == "Sleep" then
			losehealth(.125, theirpokeout, true, " is having a nightmare from Bad Dreams!")
		end

		if theirpokeout and theirpokeout.CurrentHP.Value > 0 and _G.Pokemon[theirpokeout.Name]["Ability"] == "Bad Dreams" and yourpokeout.Status.Value == "Sleep" then
			losehealth(.125, yourpokeout, false, " is having a nightmare from Bad Dreams!")
		end

		if theirpokeout.HeldItem.Value == "Leftovers" and theirpokeout.CurrentHP.Value > 0  and  theirpokeout.CurrentHP.Value ~= theirpokeout.Stats.HPStat.Value then

			scrolltext(dialog,nickname(theirpokeout).." healed itself with its Leftovers!")
			theirpokeout.CurrentHP.Value = math.min(theirpokeout.Stats.HPStat.Value,theirpokeout.CurrentHP.Value+math.floor((theirpokeout.Stats.HPStat.Value/16)))
			updatehealth(tbox,theirpokeout,theirpokeout.CurrentHP.Value)

		end
		if theirpokeout.Status.Value == "Burn" and theirpokeout.CurrentHP.Value > 0 then --losehealth(percentage,pokecfg,foe,msg)
			losehealth(.0625,theirpokeout,true," was hurt by its burn!")
		elseif theirpokeout.Status.Value == "Poison" and theirpokeout.CurrentHP.Value > 0 then
			losehealth(.125,theirpokeout,true," was hurt by poison!")
		elseif theirpokeout.Status.Value == "BadlyPoison" and theirpokeout.CurrentHP.Value > 0 then
			losehealth(badpoisonOpp,theirpokeout,true," was hurt by poison!")
			badpoisonOpp = badpoisonOpp + .0625
		end
		userReflect = userReflect - 1
		oppReflect = oppReflect - 1
		userLightScreen = userLightScreen - 1
		oppLightScreen = userLightScreen - 1
		if userReflect == 0 then
			scrolltext(dialog,"Your team's Reflect wore off!")
		end
		if oppReflect == 0 then
			scrolltext(dialog,"The opponent team's Reflect wore off!")
		end
		if userLightScreen == 0 then
			scrolltext(dialog,"Your team's Light Screen wore off!")
		end
		if oppLightScreen == 0 then
			scrolltext(dialog,"Your team's Light Screen wore off!")
		end
	end

	if weather["CurrentWeather"] then
		if weatherEffects[weather["CurrentWeather"]] then
			weatherEffects[weather["CurrentWeather"]].onTurnEnd()
			weather["Count"] = weather["Count"] - 1
			if weather["Count"] <= 0 then
				scrolltext(dialog, "The "..weather["CurrentWeather"]:lower().." subsided.")
				weather["CurrentWeather"] = nil
			end
		end
	end

	if not checkalive(userteam) then
		if loser~=nil then
			if name ~= nil then
				flash.Visible = true
				ybox.Visible = false
				trainer.Visible = true
				task.wait()
				flash.Visible = false
				scrolltext(dialog,loser)
				scrolltext(dialog,p.Name.." has no Pokemon!")
				if zol  == nil then
					scrolltext(dialog,p.Name.. " blacked out!")

				else
					scrolltext(dialog,p.Name.." lost the battle!")
				end			
			end
		end
		clearpokemon(p)
		Math:RequestChange(p.InBattle,false)
		result = "Lose"
		task.wait(.2)
		_G.currentgrass = nil
	elseif not checkalive(oppteam) then
		if name ~= nil then
			scrolltext(dialog,sprite.." "..name.." lost the battle!")
			flash.Visible = true
			tbox.Visible = false
			trainer.Visible = true
		end
		if winner ~= nil and result == nil then
			task.wait()
			flash.Visible = false
			scrolltext(dialog,winner)
		end
		clearpokemon(p)
		p.InBattle.Value = false
		evolutionchecker()
		if result ~= "Lose" then
			result = "Win"
		end
	end
	if result ~= "Win" and result ~= "Lose" then
		turn(dialog,fight,sprite,name)
	else
		if oldform and megaPokemon then
			megaPokemon.Name = oldform
			megaPokemon.Reverse.Value = oldform:reverse()
			Math:StatChange(megaPokemon)
		end
	end
end

--local textMod = require(script.CustomFont)												
p = game.Players.LocalPlayer
mouse = p:GetMouse()
p:WaitForChild("PlayerGui")
gui = p.PlayerGui
gui:WaitForChild("Main")
gui:WaitForChild("Main"):WaitForChild("BlackScreen")
battle = gui:WaitForChild("Main").BattleScene
unactive = true
yourpokeout = nil
theirpokeout = nil
trainer = battle.Trainer
tbox = battle.TheirBox
ybox = battle.YourBox
dialogbg = battle.dialogbg
evolvescreen = gui:WaitForChild("Main").BlackScreen.Evolution
movelist = dialogbg.MovesBG
weather = {
	["CurrentWeather"] = nil,
	["Count"] = 0
}

weatherEffects = {
	["Sandstorm"] = {
		duration = 5,
		onStart = function()
			scrolltext(dialog, "A sandstorm kicked up!")
		end,
		onTurnEnd = function()
			-- Sandstorm damage to non-Rock/Ground/Steel types
			if yourpokeout and yourpokeout.CurrentHP.Value > 0 then
				if not (isType(yourpokeout, "Rock") or isType(yourpokeout, "Ground") or isType(yourpokeout, "Steel")) then
					losehealth(0.0625, yourpokeout, false, " is buffeted by the sandstorm!")
				end
			end
			if theirpokeout and theirpokeout.CurrentHP.Value > 0 then
				if not (isType(theirpokeout, "Rock") or isType(theirpokeout, "Ground") or isType(theirpokeout, "Steel")) then
					losehealth(0.0625, theirpokeout, true, " is buffeted by the sandstorm!")
				end
			end
		end
	},

	["Rain"] = {
		duration = 5,
		onStart = function()
			scrolltext(dialog, "It started raining!")
		end,
		onTurnEnd = function()
			-- Rain doesn't have any turn-end effects by default
		end
	},

	["Sun"] = {
		duration = 5,
		onStart = function()
			scrolltext(dialog, "The sunlight turned harsh!")
		end,
		onTurnEnd = function()
			-- Sun doesn't have turn-end effects
		end
	}
}

theirpokemon = battle.TheirPokemon.Sprite
theirpokeball = battle.TheirPokeball
theiranime = battle.TheirPokemon.Animation
theirparty = battle.TheirParty
yourpokemon = battle.YourPokemon.Sprite
yourpokeball = battle.YourPokeball
dialog = dialogbg.dialog
dropshadowdialog = dialogbg.dialog.dropshadow
evolvedia = evolvescreen.EvolveDialog.Speak
dropShaDia = evolvescreen.EvolveDialog.Speak.dropshadow
youranime = battle.YourPokemon.Animation
yourparty = battle.YourParty
flash = battle.Flash
fight = battle.ButtonHolder.Fight
party = battle.ButtonHolder.Pokemon
run = battle.ButtonHolder.Run
bag = battle.ButtonHolder.Bag
pokeballanim = battle.PokeballAnim
--											for i,v in ipairs(evolvescreen.YesNoHolder:GetChildren()) do
--													textMod.Replace("HemiHead",v.Title.Drop)
--													textMod.Replace("HemiHead",v.Title)
--												end
soundeffect = p.PlayerGui.SoundEffect
prefix = ""
buttonholder = battle.ButtonHolder
mouse.KeyDown:Connect(function(key)
	if key == "q" and pressedq == nil and scrollytext == true then
		pressedq = true
	end
end)

--=====================================================
--MoveEvents
--=====================================================
local sound = Instance.new("Sound",script)
function wildAnim()
	spawn(function() zoomAnim() end)
	local absPosX = script.Parent:WaitForChild("Main").battleAnim.AbsoluteSize.Y
	for yPos = 0, absPosX*6, absPosX do
		for i = 0, 1, .1 do
			local newFrame = script.Parent:WaitForChild("Main").battleAnim:Clone()
			newFrame.Position = UDim2.new(i,0,0,yPos)
			newFrame.Rotation = 50
			newFrame.Parent = script.Parent:WaitForChild("Main").animHold
			newFrame.Visible = true
			task.wait()
			spawn(function()
				for i = 1, 10 do
					newFrame.Rotation = newFrame.Rotation - 5
					task.wait()
				end
			end)
		end
	end

	workspace.CurrentCamera.FieldOfView = 70
end

function trainAnim()
	spawn(function() zoomAnim() end)
	local absPosX = script.Parent:WaitForChild("Main").battleAnim.AbsoluteSize.Y
	for yPos = 0, absPosX*7, absPosX do
		for i = 0, 1, .2 do
			local newFrame = script.Parent:WaitForChild("Main").battleAnim:Clone()
			newFrame.Size = UDim2.new(0,0,0,0)
			newFrame.Rotation = 0
			newFrame.Position = UDim2.new(i-.1,0,0,yPos)
			local newFrame2 = script.Parent:WaitForChild("Main").battleAnim:Clone()
			newFrame2.Size = UDim2.new(0,0,0,0)
			newFrame2.Rotation = 0
			newFrame2.Position = UDim2.new(i,0,0,yPos)
			task.wait(.035)
			newFrame.Parent = script.Parent:WaitForChild("Main").animHold
			newFrame.Visible = true
			newFrame:TweenSize(UDim2.new(.1,1,.1,0),"Out","Quad",.25,true)
			newFrame2.Parent = script.Parent:WaitForChild("Main").animHold
			newFrame2.Visible = true
			newFrame2:TweenSize(UDim2.new(.1,1,.1,0),"Out","Quad",.25,true)
		end
	end
	task.wait(.3)
	workspace.CurrentCamera.FieldOfView = 70
end

function zoomAnim()
	for i = 70, 120, 2 do
		workspace.CurrentCamera.FieldOfView = i
		task.wait()
	end
	for i = 110, 10, -10 do
		workspace.CurrentCamera.FieldOfView = i
		task.wait()
	end
	workspace.CurrentCamera.FieldOfView = 70
end


--local Device = require(script.getPlatform)
function guiReplace()
	if p.PlayerGui:FindFirstChild("TouchGui") then
		dialog.FontSize = "Size24"
		dialog.dropshadow.FontSize = "Size24"
		evolvescreen.EvolveDialog.Speak.FontSize = "Size24"
		evolvescreen.EvolveDialog.Speak.dropshadow.FontSize = "Size24"
	end								
end
function wildWorkaround(poke)
	for i,v in ipairs(p.OppPokemon:GetChildren()) do
		if v ~= poke then
			v:Destroy()
		end
	end
end


local AuraSound = Instance.new("Sound",script)
AuraSound.Name = "AuraSound"
AuraSound.SoundId = "rbxassetid://182813133"
local ShinySound = Instance.new("Sound",script)
ShinySound.Name = "ShinySound"
ShinySound.SoundId = "rbxassetid://6454732114"

local inbattle = false
_G["BattleInitiate"] =
	function(trainersprite,trainername,winnermessage,losermessage,battlescene,expero,wildanim)
		if inbattle == false then
			inbattle = true
			script.Parent:WaitForChild("Main"):WaitForChild("Leaderboard").Visible = false

			guiReplace()
			zol = nil
			p.Character.Humanoid.WalkSpeed = 0
			p.PlayerGui:WaitForChild("Main").Menu.Visible = false	
			if p.PlayerGui:FindFirstChild("TouchGui") then
				p.PlayerGui.TouchGui:FindFirstChild("TouchControlFrame").Visible = false
			end
			moneyrun = nil
			if expero ~= nil then
				--	print("Battle Tower Detected.")
				zol = true
			end
			--=====================================================
			--Setting Values and Variables
			--=====================================================
			usermod = {
				["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 
			}
			oppmod = {
				["Atk"] = 0,
				["Def"] = 0,
				["SpA"] = 0,
				["SpD"] = 0,
				["Speed"] = 0,
				["Acc"] = 0,
				["Evade"] = 0 
			}
			Evolution = {

			}
			originalbattle = {
			}

			originalstats = {

			}
			--originalstats = {
			--instance = ["Moves"] = {}, ["Stats"]
			--}
			pokemonexpsplit = 
			{}
			_G.WildPokemon = nil
			p.InBattle.Value = true
			runtimes = 0
			theirpokemon.Image = ""
			yourpokemon.Image = ""

			theirpokefaint = false
			yourpokefaint = false
			winner = winnermessage
			loser = losermessage
			userprotect = 1
			userIsProtected = false
			oppprotect = 1
			oppIsProtected = false
			oppRoosting = false
			userRoosting = false
			badpoisonUser = 0.0625
			badpoisonOpp = 0.0625
			berserkActivatedUser = false
			berserkActivatedOpp = false
			oldform = nil
			megaPokemon = nil
			DBfoe = false
			TauntUser = 0
			TauntFoe = 0
			DBuse = false
			weather = {["CurrentWeather"] = nil,
				["Count"] = 0
			}
			TSpikesFoe = 0
			TSpikesUser = 0
			userLightScreen = 0
			userReflect = 0
			oppReflect = 0
			oppLightScreen = 0
			playeraction = false
			usermove = nil
			battle.Visible = false
			tbox.Visible = false
			ybox.Visible = false
			userMega = false
			theirpokeball.Visible = false
			theirpokemon.Visible = false
			theirparty.Visible = false
			yourpokeball.Visible = false
			yourpokemon.Visible = false
			yourparty.Visible = false
			tbox.Shiny.Visible = false
			tbox.Aura.Visible = false
			tbox.Caught.Visible = false
			battle.Parent.Party.Visible = false
			flash.Visible = false
			trainer.Visible = false
			leechseeduser = false
			leechseedopp = false
			battle.TheirPokemon.ItemSprite.Visible = false
			--
			yourpokemon.Position = UDim2.new(0,0, 0.25, 0)
			theirpokemon.Position = UDim2.new(0, 0, 0, 0)
			local sprite = trainersprite
			local name = trainername
			oppteam = p.OppPokemon
			userteam = p.PokemonParty
			result = nil
			originalparties(true)
			urconfusion = false
			theirconfusion = false

			partycheck(yourparty)
			--original values
			for i,v in ipairs(userteam:GetChildren()) do
				getfenv()["OriginalValue"..v.PartyPosition.Value..v.Name] = v.PartyPosition
			end 


			changevisible(buttonholder,"TextButton",false)
			dialog.Text = ""
			dropshadowdialog.Text = ""
			task.wait(.1)
			if trainersprite ~= nil and trainersprite ~= "NPCTrainer" then
				if trainersprite == "Elite Four" then
					trainer.Image = _G.Sprites["Trainers"][trainername]
				else
					trainer.Image = _G.Sprites["Trainers"][trainersprite]
				end

				partycheck(theirparty)
				trainer.Visible = true
				--=====================================================
				--Battle Start
				--=====================================================
			elseif trainersprite == nil then
				theirpokeout = findlead(oppteam,1)
				if not Pokedex:Check(theirpokeout.Name,p) and zol == nil then
					Pokedex:Create(theirpokeout.Name)
				end
				if theirpokeout ~= nil then
					_G.getFrontSprite(theirpokemon,theirpokeout)
					if theirpokeout:FindFirstChild("Aura") or theirpokeout:FindFirstChild("Reskin") then

						tbox.Aura.Visible = true
					elseif theirpokeout.Shiny.Value == true then      

						tbox.Shiny.Visible = true
					else

					end
					if theirpokeout ~= nil then
						if p.Pokedex:FindFirstChild(_G.Pokemon[theirpokeout.Name]["Pokedex"]) and p.Pokedex:FindFirstChild(_G.Pokemon[theirpokeout.Name]["Pokedex"]).Caught.Value == true then
							tbox.Caught.Visible = true
						else
							tbox.Caught.Visible = false
						end
					end
					boxupdate(theirpokeout,tbox,false)
					theirpokemon.Visible = true
					battle.Parent.Party.Visible = false
				else
					p.InBattle.Value = false

					evolutionchecker()
					return "Win"
				end
			end

			sound = p.PlayerGui:WaitForChild("BattleSound")
			local tsprite = trainersprite
			local tname = trainername
			if trainersprite == "NPCTrainer" then
				tsprite = "Robot"
				trainer.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username="..tname
				partycheck(theirparty)
				trainer.Visible = true
				sound.SoundId = "http://www.roblox.com/asset/?id="..trainerBattle[math.random(1,#trainerBattle)]
			elseif tname == "Abraxas" then
				sound.SoundId = "http://www.roblox.com/asset/?id=196517724"
			elseif trainersprite == "Elite Four" then
				sound.SoundId = "http://www.roblox.com/asset/?id=163691760"
			elseif trainersprite == "Master" then
				sound.SoundId = "http://www.roblox.com/asset/?id=166121095"
			elseif trainersprite == "Saint" then
				sound.SoundId = "http://www.roblox.com/asset/?id=181347288"
			elseif trainersprite == "?????" then
				sound.SoundId = "http://www.roblox.com/asset/?id=175757377"
			elseif trainersprite == "cptt" then
				sound.SoundId = "http://www.roblox.com/asset/?id=226672555"
			elseif trainersprite == "/_/" then
				sound.SoundId = "http://www.roblox.com/asset/?id=226672555"
			elseif trainersprite == "Champion" then
				sound.SoundId = "http://www.roblox.com/asset/?id=143993999"
			elseif trainersprite ~= "Zombie" and trainersprite ~= "Prince" and trainersprite ~= "Elite Four" and trainersprite ~= nil then
				sound.SoundId = "http://www.roblox.com/asset/?id="..trainerBattle[math.random(1,#trainerBattle)]

			elseif trainersprite == nil then
				sound.SoundId = "http://www.roblox.com/asset/?id="..wildBattle[math.random(1,#wildBattle)]						
			end
			sound:Stop()
			bgm.Volume = 0
			sound:Play()
			if trainersprite == nil and wildanim == true then
				wildAnim()
			elseif trainersprite == nil then
				zoomAnim()
			else
				trainAnim()
			end

			if trainersprite == nil and theirpokeout.HeldItem.Value ~= "" then	
				battle.TheirPokemon.ItemSprite.Image = ItemList[theirpokeout.HeldItem.Value]["Sprite"]
				battle.TheirPokemon.ItemSprite.Visible = true													
			end
			gui:WaitForChild("Main").BlackScreen.Visible = true
			script.Parent:WaitForChild("Main").animHold:ClearAllChildren()
			if battlescene ~= nil then
				battle.Image = _G.Sprites["BattleBGs"][battlescene]
			end
			battle.Visible = true


			task.wait(.8)
			if trainersprite ~= nil  then
				scrolltext(dialog,tsprite.." "..tname.." wants to battle!")
				theirpokeout = findlead(oppteam,1)
				prefix = "foe's"
			else
				_G.WildPokemon = theirpokeout
				wildWorkaround(theirpokeout)

				if theirpokeout:FindFirstChild("Aura") or theirpokeout:FindFirstChild("Reskin") then

					AuraSound:Play()
					scrolltext(dialog,"This Pokemon has a mysterious Aura!")
				elseif theirpokeout.Shiny.Value == true then
					ShinySound:Play()
					scrolltext(dialog,"It's a shiny "..theirpokeout.Name.."!")
				else
					scrolltext(dialog,"You have encountered a wild "..theirpokeout.Name.."!")
				end

				prefix = "wild"

				if theirpokeout.HeldItem.Value ~= "" then

					scrolltext(dialog,"It seems to be holding a "..theirpokeout.HeldItem.Value.."!")
					task.wait(.35)
					scrolltext(dialog,"If you want this item, you must catch this Pokemon!")
				end
			end
			yourpokeout = findlead(userteam,1)
			reorganize(userteam,yourpokeout)
			--=====================================================
			--Beginning Opponent Animation
			--=====================================================
			if tsprite ~= nil then
				--theirparty.Visible = false
				pokemonout(theirpokeball,theirpokemon,tbox,theirpokeout)
				scrolltext(dialog,tsprite.." "..tname.." sent out "..theirpokeout.Name.."!")
			end
			task.wait(.4)
			--=====================================================
			--Beginning User Animation
			--=====================================================
			scrolltext(dialog,"Go! "..nickname(yourpokeout).."!",true)
			pokemonout(yourpokeball,yourpokemon,ybox,yourpokeout)
			coroutine.resume(coroutine.create(function()repeat task.wait() until result ~= nil


				for i = 0, 1, .05 do
					gui:WaitForChild("Main").BlackScreen.Transparency = i
					task.wait(.05)
				end
				workspace.CurrentCamera.CameraType = "Custom"

				battle.Visible = false
				gui:WaitForChild("Main").BlackScreen.Visible = false
				gui:WaitForChild("Main").BlackScreen.Transparency = 0

			end))
			--=====================================================
			--Start of Battle
			--=====================================================
			turn(dialog,fight,tsprite,tname)
			originalparties(false)
			sound:Stop()
			if p:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("MuteBGM").Text == "Mute BG Music" then
				bgm.Volume = 0.3
			end
			returnstats()
			script.Parent:WaitForChild("Main").animHold:ClearAllChildren()
			workspace.CurrentCamera.CameraSubject = p.Character
			if _G.oldCamera ~= nil then
				workspace.CurrentCamera.CoordinateFrame = _G.oldCamera
				_G.oldCamera = nil
			end
			script.Parent:WaitForChild("Main"):WaitForChild("Leaderboard").Visible = true
			inbattle = false


			return result, moneyrun


		end
	end
for i,v in pairs(partyb) do
	game:GetService("ContentProvider"):Preload(v)
end

game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=124640823")

function colorLerpTab(img,color)
	local colorTab = {}
	local iterations = 10
	for i = 1, iterations do
		table.insert(colorTab,img.ImageColor3:lerp(color,i/iterations))
	end
	return colorTab
end


function colorChange(img,tab)
	local num = 1
	local tuple = tab
	local imgID = img.Image

	img.ImageColor3 = tuple[#tuple]

	spawn(function()
		while img.Image == imgID and (gui:WaitForChild("Main").BlackScreen.Visible == true or (img.Parent and img.Parent.Name == "TheirPokemon")) do
			for _,color in ipairs(tuple) do

				local ColorTab = colorLerpTab(img,color)
				for _,color3 in ipairs(ColorTab) do
					img.ImageColor3 = color3
					task.wait(.1)
					if img.Image ~= imgID or (gui:WaitForChild("Main").BlackScreen.Visible == false and img.Parent and img.Parent.Name ~= "TheirPokemon") then
						break
					end
				end
			end

		end
	end)

end

function getCountauras(cfg)
	local t = {}
	for i,v in ipairs(cfg.Aura:GetChildren()) do
		if v.Name == "ColorChange" then
			table.insert(t,v)
		end
	end
	return t
end

function AuraTable(poke)
	local t = {}
	local num = 1
	--											if poke.Aura:FindFirstChild("Animation") then
	--		num = 0
	--	end
	if poke:FindFirstChild("Aura") then
		local ter = getCountauras(poke)
		for numberOf = 1, #ter do
			for i,v in ipairs(ter) do
				if v:FindFirstChild("Number") and v.Number.Value == num then
					num = num + 1
					table.insert(t,_G.tintColors[v.Value])
				end
			end
		end
	end
	return t
end

local auraImage = {
	["Valentine Heart"] = {
		["Colors"] = {Color3.new(1,0,0),Color3.new(1,85/255,1),Color3.new(2/3,1/3,2/3)},
		["Image"] = {"rbxassetid://84706393788533"},
		["Size"] = UDim2.new(0,15,0,15),
		["Amount"] = 8,
	},
	["Pokeball Ring"] = {
		["Colors"] = {Color3.new(1,1,1)},
		["Image"] = {"rbxassetid://132564443870214","rbxassetid://84010115","rbxassetid://16512504192","rbxassetid://6293153360"},
		["Size"] = UDim2.new(0,24,0,24),
		["Amount"] = 8,	
	},
	["Money Ring"] = {
		["Colors"] = {Color3.new(1,1,1)},
		["Image"] = {"rbxassetid://16001803198"},
		["Size"] = UDim2.new(0,18,0,12),
		["Amount"] = 8,
	},
	["ROBLOX Logo"] = {
		["Colors"] = {Color3.new(1,1,1)},
		["Image"] = {"rbxassetid://732339893","rbxassetid://10086464520","rbxassetid://397296146","rbxassetid://15636231615","rbxassetid://2420004216","rbxassetid://5595249091"},
		["Size"] = UDim2.new(0,16,0,16),
		["Amount"] = 8,
	},
	["Badges"] = {
		["Colors"] = {Color3.new(1,1,1)},
		["Image"] = {"rbxassetid://5360414125","rbxassetid://5360415307","rbxassetid://5360441454","rbxassetid://5360445061","rbxassetid://5360446179","rbxassetid://5360446907","rbxassetid://5360448195","rbxassetid://5360449289","rbxassetid://38464948"},
		["Size"] = UDim2.new(0,26,0,26),
		["Amount"] = 8,
	},
	["Orbiting Fire"] = {
		["Colors"] = {Color3.new(1, 1, 1)},
		["Image"] = {"rbxassetid://5942391588"},
		["Size"] = UDim2.new(0,24,0,24),
		["Amount"] = 7
	}
}										
function drawCircle(parent,auraType)
	local colors = auraImage[auraType]["Colors"]
	local image = auraImage[auraType]["Image"]
	local multiply = 360/auraImage[auraType]["Amount"]
	local tab = {}
	local x, y, r = 0, 0,parent.AbsoluteSize.X-6
	for thing = 1, auraImage[auraType]["Amount"] do
		local i = thing * multiply
		local angle = i * math.pi / 180
		local t = Instance.new("ImageLabel",parent)
		t.ImageColor3 = colors[math.random(#colors)]
		t.ZIndex = 8
		t.Name = "Animation"
		t.BackgroundTransparency = 1
		t.Image = image[math.random(#image)]
		t.Size = auraImage[auraType]["Size"]
		if auraType == "Orbiting Fire" then
			t.ImageRectSize = Vector2.new(150,150)
			spawn(function()
				while t.Parent == parent do
					for i = 1, 6 do
						if t.Parent == parent then
							task.wait(.1)
							t.ImageRectOffset = Vector2.new((i-1)*150,0)
						else
							break
						end
					end
				end

			end)
		end
		local ptx, pty = math.floor(x + r * math.cos( angle )),math.floor( y + r * math.sin( angle ))
		t.Position = UDim2.new(.5,(-1*(ptx)/2)-(math.floor(t.Size.X.Offset)/2),.5,(-1*(pty)/2)-(math.floor(t.Size.Y.Offset)/2))
		tab[thing] = t
	end
	return tab
end

function animateCircle(tab,img,imgID,auraType)
	local count = auraImage[auraType]["Amount"]
	local curtab = tab
	local newtab = {}
	for i,v in ipairs(curtab) do
		if i == count then	
			newtab[1] = v
			pcall(function() v:TweenPosition(curtab[1].Position,"Out","Linear",.6,true) end)
		elseif i ~= count then

			newtab[i+1] = v
			pcall(function()  v:TweenPosition(curtab[i+1].Position,"Out","Linear",.6,true) end)
		end
	end
	task.wait(.61)
	if img:FindFirstChild("Animation") and img.Image == imgID and (gui:WaitForChild("Main").BlackScreen.Visible == true or (img.Parent and img.Parent.Name == "TheirPokemon"))  then
		animateCircle(newtab,img,imgID,auraType)
	else
		for i,v in ipairs(newtab) do
			v:Destroy()
		end
	end
end

function Confetti(box,Type)
	local absoluteSize = math.floor(box.AbsoluteSize.X/14)
	local amountCreated = math.random(absoluteSize-4,absoluteSize+4)							
	for i = 1, amountCreated do
		local confettiImage = Instance.new("ImageLabel")
		confettiImage.BackgroundTransparency = 1
		confettiImage.ZIndex = 7
		confettiImage.Name = "Animation"
		confettiImage.Image = "rbxassetid://672738002"
		if Type == "Confetti" then
			local colors = {Color3.new(0,1,0),Color3.new(1,0,0),Color3.new(0,0,1),Color3.new(1,1,0)}
			confettiImage.ImageColor3 = colors[math.random(#colors)]	
		else
			confettiImage.ImageColor3 = Color3.new(math.random(6,10)/10,math.random(6,10)/10,math.random(6,10)/10)
		end	
		local pick = math.random(1,8)

		confettiImage.Size = UDim2.new(0,16,0,18)
		confettiImage.ImageRectSize = Vector2.new(16,18)
		confettiImage.ImageRectOffset = Vector2.new(pick*16,0)


		local yRandom = math.random(-3,-1)

		confettiImage.Position = UDim2.new(math.random(-5,13)/20,-16,yRandom/10,0)
		confettiImage.Parent = box

		local waitTime = math.random(30,40)/10
		confettiImage:TweenPosition(UDim2.new(math.random(6,12)/10,confettiImage.Position.X.Offset,1,0),"Out","Linear",waitTime,true,function() confettiImage:Destroy() end)
	end
	task.wait(.55)
end


local currentAnimate = nil
_G.getFrontSprite = function(img,poke)
	img.ClipsDescendants = true
	local val = poke
	if type(val) == "userdata" then
		val = poke.Name
	end

	if img:FindFirstChild("Animation") then
		for i,v in ipairs(img:GetChildren()) do
			if v.Name == "Animation" then
				v:Destroy()
			end
		end
	end
	img.Image = (poke.Shiny.Value == true and _G.Pokemon[val]["Sprites"]["SF"]) or _G.Pokemon[val]["Sprites"]["Front"]
	img.ImageColor3 = Color3.new(1,1,1)

	if poke:FindFirstChild("Reskin") ~= nil then
		img.ImageRectOffset = Vector2.new(0,0)
		img.ImageRectSize = Vector2.new(0,0)
		if _G.Pokemon[val]["FormSprites"][poke.Reskin.Value] ~= nil then
			if poke.Shiny.Value == true then
				if _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["SF"] ~= nil then
					img.Image = _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["SF"]
				else
					img.Image = _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["Front"]
				end
			else
				img.Image = _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["Front"]
			end
		else
			img.Image = (poke.Shiny.Value == true and _G.Pokemon[val]["Sprites"]["SF"]) or _G.Pokemon[val]["Sprites"]["Front"]
		end
	end

	if poke:FindFirstChild("Aura") then
		if poke.Aura:FindFirstChild("Animation") then
			local animationAura = poke.Aura.Animation.Value
			if animationAura == "Confetti" or animationAura == "Rainbow Confetti" then
				local imgID = img.Image
				spawn(function() 
					while img.Image == imgID and (gui:WaitForChild("Main").BlackScreen.Visible == true or (img.Parent and img.Parent.Name == "TheirPokemon")) do
						task.wait(.2)
						if img.Image == imgID then
							Confetti(img,animationAura)
						end

					end	

				end)									
			else	
				local tab = drawCircle(img,animationAura)
				spawn(function() animateCircle(tab,img,img.Image,animationAura) end)
			end
		end
		if poke.Aura:FindFirstChild("ColorChange")  then
			if #poke.Aura:GetChildren() == 1 then
				--print(img.Name,"1")
				img.ImageColor3 = _G.tintColors[poke.Aura:FindFirstChild("ColorChange").Value]
			else	
				--print(img.Name,"2")											
				colorChange(img,AuraTable(poke))
			end
		end
	end
end
_G.getBackSprite = function(img,poke)
	img.ClipsDescendants = true
	local val = poke
	if type(val) == "userdata" then
		val = poke.Name
	end
	if img:FindFirstChild("Animation") then
		for i,v in ipairs(img:GetChildren()) do
			if v.Name == "Animation" then
				v:Destroy()
			end
		end
	end
	img.Image = (poke.Shiny.Value == true and _G.Pokemon[val]["Sprites"]["SB"]) or _G.Pokemon[val]["Sprites"]["Back"]
	img.ImageColor3 = Color3.new(1,1,1)

	if poke:FindFirstChild("Reskin") ~= nil then
		img.ImageRectOffset = Vector2.new(0,0)
		img.ImageRectSize = Vector2.new(0,0)
		if _G.Pokemon[val]["FormSprites"][poke.Reskin.Value] ~= nil then
			if poke.Shiny.Value == true then
				if _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["SB"] ~= nil then
					img.Image = _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["SB"]
				else
					img.Image = _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["Back"]
				end
			else
				img.Image = _G.Pokemon[val]["FormSprites"][poke.Reskin.Value]["Back"]
			end
		else
			img.Image = (poke.Shiny.Value == true and _G.Pokemon[val]["Sprites"]["SB"]) or _G.Pokemon[val]["Sprites"]["Back"]
		end
	end

	if poke:FindFirstChild("Aura") then
		if poke.Aura:FindFirstChild("Animation") then

			local animationAura = poke.Aura.Animation.Value
			if animationAura == "Confetti" or animationAura == "Rainbow Confetti" then
				local imgID = img.Image
				spawn(function() 
					while  img.Image == imgID and (gui:WaitForChild("Main").BlackScreen.Visible == true or (img.Parent and img.Parent.Name == "TheirPokemon")) do
						task.wait(.2)
						if img.Image == imgID then
							Confetti(img,animationAura)
						end
					end	
				end)									
			else	
				local tab = drawCircle(img,animationAura)
				spawn(function() animateCircle(tab,img,img.Image,animationAura) end)
			end
		end
		if poke.Aura:FindFirstChild("ColorChange")  then
			if #poke.Aura:GetChildren() == 1 then
				--print(img.Name,"1")
				img.ImageColor3 = _G.tintColors[poke.Aura:FindFirstChild("ColorChange").Value]
			else	
				--print(img.Name,"2")											
				colorChange(img,AuraTable(poke))
			end
		end
	end
end
_G.BattleReady = true
print("BattleReady")

