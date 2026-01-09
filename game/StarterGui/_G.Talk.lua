local bgm = workspace:WaitForChild("BackgroundMusic")
local CharcadetEvolve = Instance.new("Sound")
CharcadetEvolve.SoundId = "rbxassetid://17684572290"  
CharcadetEvolve.Parent = game.Players.LocalPlayer.PlayerGui  
CharcadetEvolve.Volume = 1 
if _G.progress == nil then
	_G.progress = {}
end

repeat task.wait() until game.Players.LocalPlayer and _G.BattleReady

local Signals = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signals"))
local Remotes = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Remotes"))

print(script.Parent)
game.Players.LocalPlayer:WaitForChild("PokemonParty",100) 
if #game.Players.LocalPlayer.PokemonParty:GetChildren() > 0  then
	print("Destroy")
	script:Destroy()
end
task.wait(2)

trial = false
local BattleGrounds = {"WildGrass","Lake","Cave","Inside","PurpleInside",}
trainers = {"Black Belt","Bug Catcher","Youngster","Lass","Fisherman","Gentleman","Scientist","Hiker","School Kid","School Girl","Camper","Gentleman","Cupid"}
names = {"Julie","Adam","BananaBoy","Swagmaster","Dennis","David","Zachary","Adriel","Bobby","Carmen","Brianna","Hannah","Summer","Jennifer","Sara","Tyler","Albert","Peter","Oscar","Ryan","Riley","Jacob","Jake","Brandon","Bryan","Thomas","Tom","Billy","William","Fergie","Andrew","Andy","Jason","Fred","Ralph","Isabella","Elsa","Conner","Xanthus","Breach","Bryce","Detritus","Wobble","odb","Bebee2","PizzaPower","Dora","Diego","Boots","Gloves","Goatman","Robin","Williams","Miley","wish","ISO"}
p = game.Players.LocalPlayer
game.Players.LocalPlayer:WaitForChild("PlayerGui",300):WaitForChild("Main",300):WaitForChild("BlackScreen",300)
local speech = p.PlayerGui:WaitForChild("DialogTalk").TalkB.Talk
local talkinfo = speech.Parent.Parent.info
local mouse = p:GetMouse()
pressedq = nil
gui = p.PlayerGui
main = gui:WaitForChild("Main")
battle = gui:WaitForChild("Main").BlackScreen
menu = gui:WaitForChild("Main").Menu
menu:WaitForChild("Scroll")
local pokemontable = {}

local updateparty = false
local PC = require(game.ReplicatedStorage:WaitForChild("Functions").PC)
local REvents = game:GetService("ReplicatedStorage"):WaitForChild("REvents")
local battleTowerCreate = REvents.Battle.BattleTowerCreate
local battleTowerRemove = REvents.Battle.BattleTowerRemove

garypokemon = {
	["Grass"] = "Charmander",
	["Water"] = "Bulbasaur",
	["Fire"] = "Squirtle"
}
local taxi = {
	["Pewter City"] = "1",
	["Cerulean City"] = "2",
	["Vermillion City"] = "3",
	["Celadon City"] = "4",
	["Fuchsia City"] = "5",
	["Saffron City"] = "6",
	["Cinnabar Volcano"] = "7",
	["Indigo"] = "Indigo",
	["Elegant Valley"] = "EV",
	["Mysterious Grotto"] = "Mysterious Grotto",
	["Mausoleum of Origins"] = "Mausoleum of Origins"
}

local rotommoves = {
	["ThunderShock"] = true,
	["Overheat"] = true,
	["Blizzard"] = true,
	["Leaf Storm"] = true,
	["Air Slash"]=  true,
	["Hydro Pump"] = true
}

function disappear(model)
	if model then
		local partlist = {}
		if model:FindFirstChild("Model") then
			model.Event:Destroy()
		end
		for i,v in ipairs(model:GetChildren()) do
			if v:IsA("Part") then
				table.insert(partlist, v)
			end
		end
		for i = 1, 10 do
			for i,v in ipairs(partlist) do
				v.Transparency = v.Transparency + .1
			end
			task.wait(.05)
		end
		model:Destroy()
	end
end
locations = {
	["Mom's"] = Vector3.new(107.751, 37.967, 177.711),
	["Lavender Town"] =  Vector3.new(-2493.688, 58.113, 1537.497),
	["Route 3"] = Vector3.new(-608.89, 68.188, 1676.244),
	["Celadon City"] = Vector3.new(-1809.035, 32.269, 357.819),
	["Cerulean City"] = Vector3.new(-1270.96, 72.483, 1378.177),
	["Cinnabar Volcano"] = Vector3.new(-5039, 321.535, 2359),
	["Fuchsia City"] = Vector3.new(-3980.219, 14.479, -272.834),
	["Pewter City"] = Vector3.new(-42, 62.073, 1662),
	["Saffron City"] = Vector3.new(-4446.912, 17.864, 981.881),
	["Vermillion City"] = Vector3.new(-2666.245, 59.07, 781.812),
	["Viridian City"] = Vector3.new(-25.994, 45.116, 873.619),
	["Indigo"] = Vector3.new(9801, 228.27, 394),
	["Elegant Valley"] = Vector3.new(-9140,  115.857, 805),
	["Mysterious Grotto"] = Vector3.new(-2407.515,  196.159,  4356.761),
	["Mausoleum of Origins"] = Vector3.new(-620.306, 50.613,  -4374.258),
}

defeated = {}

local BP = 1
local Streak = 0
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

local Math = require(game.ReplicatedStorage:WaitForChild("Functions").Math)
local Battle = require(game.ReplicatedStorage:WaitForChild("Functions").Battle)
local Pokedex = require(game.ReplicatedStorage:WaitForChild("Functions").Pokedex)

function HPcalc(lvl,iv,ev,poke) 
	return ((iv+2* _G.Pokemon[poke]["Stats"]["HP"] +(ev/4))*lvl/100)+10+lvl
end


function otherstatcalc(basestat,lvl,iv,ev,nature,poke)
	return (((iv+2*_G.Pokemon[poke]["Stats"][basestat]+(ev/4))*lvl/100)+5) * nature
end

function nickname(pokemon)
	local success, canLocalUserChat = pcall(function()
		return game:GetService("TextChatService"):CanUserChatAsync(game.Players.LocalPlayer.UserId)
	end)
	if pokemon:FindFirstChild("Nickname") and success and canLocalUserChat then
		return pokemon:FindFirstChild("Nickname").Value
	else
		return pokemon.Name
	end
end

local stats = {"HP","Atk","Def","SpA","SpD","Speed"}
local nStats = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("NatureStats"))
function determinenature(stat,nature)
	if nStats[stat.." Boost"][nature] then
		return 1.1
	elseif nStats[stat.." Down"][nature] then
		return .9
	else return 1
	end
end	
local canTalk = true
function empty()

end
function sound(create)
	local s
	if create == true then
		s = Instance.new("Sound",gui)
		s.SoundId = "rbxassetid://11937871015"
		s:Play()
	else 
		s:Stop()
		s:Destroy()
	end
end


function scrolling()
	local effect = Instance.new("Sound",script)
	effect.SoundId = "rbxassetid://325182533"
	effect.Pitch = math.random(75,85)/100
	effect:Play()
	spawn(function() task.wait(2)
		effect:Destroy()
	end)
end

function scanMoves(tab)
	for i,v in ipairs(p.PokemonParty:GetChildren()) do
		for _,move in ipairs(v.Moves:GetChildren()) do
			if tab[move.Name] == true then
				return false
			end
		end
	end
	return true
end
function fadeytext(text)
	main.MessageThing.Text = text
	main.BlackScreen.Visible = true
	for i = 1, 0, -.05 do
		main.MessageThing.TextTransparency = i
		main.MessageThing.TextStrokeTransparency = i  
		task.wait(.05)
	end
	task.wait(.5)
	for i = 0, 1, .05 do
		main.MessageThing.TextTransparency = i 
		main.MessageThing.TextStrokeTransparency = i 
		task.wait(.05)
	end
	main.MessageThing.TextTransparency = 1
	main.MessageThing.TextStrokeTransparency = 1
end


function createpokedex(pokemon)
	local value = Instance.new("StringValue")
	value.Name = _G.Pokemon[pokemon]["Pokedex"]
	value.Value = pokemon
	local caught = Instance.new("BoolValue",value)
	caught.Name = "Caught"
	caught.Value = true
	value.Parent = p.Pokedex
end

local nxtButton = nil

speech.Parent.Next.MouseEnter:Connect(function()
	speech.Parent.Next.ImageColor3 = Color3.new(125/255, 0, 0)
end)

speech.Parent.Next.MouseLeave:Connect(function()
	speech.Parent.Next.ImageColor3 = Color3.new(1, 0, 0)
end)

function scrolltext(text,choice)
	speech.Text = " "
	if nxtButton then
		nxtButton:disconnect()
	end
	local skip = false
	nxtButton = speech.Parent.Next.MouseButton1Down:Connect(function()
		if skip == false then
			skip = true
		end
	end)
	local pressedq = game:GetService("UserInputService").InputBegan:Connect(function(inputObj)
		if inputObj.KeyCode == Enum.KeyCode.Q then
			if skip == false then
				skip = true
			end
		end
	end)
	p.PlayerGui:WaitForChild("DialogTalk").info.Visible = false
	menu.Visible = false
	speech.Parent.Visible = true
	speech.Visible = true
	local continue = false
	speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
	speech.Parent.popup.No.Visible = false
	if sayyes then sayyes:disconnect() end
	if sayno then sayno:disconnect() end
	if choice then
		speech.Parent.Next.Visible = false
		speech.Parent.popup.Yes.Visible = true 
		speech.Parent.popup.Visible = true
		speech.Parent.popup.No.Visible = true
	end
	--p.Character.Humanoid.WalkSpeed = 0
	for i = 1, #text do
		scrolling()
		speech.Text = string.sub(text,1,i)
		speech.DropShadow.Text = speech.Text
		task.wait(.04)
		if skip == true then
			speech.Text = text
			speech.DropShadow.Text = text
			break
		end
	end
	if pressedq then  pressedq:disconnect() end
	if nxtButton then nxtButton:disconnect() end
	nxtButton = speech.Parent.Next.MouseButton1Down:Connect(function()
		continue = true
		if pressedq then  pressedq:disconnect() end
	end)
	local pressedq = game:GetService("UserInputService").InputBegan:Connect(function(inputObj)
		if inputObj.KeyCode == Enum.KeyCode.Q then
			continue = true
			if pressedq then  pressedq:disconnect() end
		end
	end)
	repeat task.wait() until continue == true or choice == true
	if choice == nil then
		speech.Parent.Visible = false
		speech.Visible = false
		menu.Visible = true
	end
	--	if nxtButton then
	--		nxtButton:disconnect()
	--	end
end

local cheerAnim = Instance.new("Animation",script)
cheerAnim.AnimationId = "http://www.roblox.com/asset/?id=129423030"

function cheer(model)
	local anim = model.Humanoid:LoadAnimation(cheerAnim)
	anim:Play()
end


local laughAnim = Instance.new("Animation",script)
laughAnim.AnimationId = "http://www.roblox.com/asset/?id=129423131"

function laugh(model)
	local anim = model.Humanoid:LoadAnimation(laughAnim)
	anim:Play()
end

local nodAnim = Instance.new("Animation",script)
nodAnim.AnimationId = "http://www.roblox.com/asset/?id=428704872"

function nod(model)
	local anim = model.Humanoid:LoadAnimation(nodAnim)
	anim:Play()
end

local pointAnim = Instance.new("Animation",script)
pointAnim.AnimationId = "http://www.roblox.com/asset/?id=128853357"

function point(model)
	local anim = model.Humanoid:LoadAnimation(pointAnim)
	anim:Play()
end

local bowAnim = Instance.new("Animation",script)
bowAnim.AnimationId = "http://www.roblox.com/asset/?id=429578642"

function bow(model)
	local Anim = model.Humanoid:LoadAnimation(bowAnim)
	Anim:Play()
end

function alertSoundPlay(parent)
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://11937821340"
	Sound.Volume = 1.25
	Sound.Parent = script
	return Sound
end	
function turnModel(model)
	local cframetab = {}
	local position = model:WaitForChild("HumanoidRootPart").CFrame
	for i = 1, 8 do
		cframetab[i] = model:WaitForChild("HumanoidRootPart").CFrame:lerp(CFrame.new(model:WaitForChild("HumanoidRootPart").Position,Vector3.new(p.Character:WaitForChild("HumanoidRootPart").Position.X,model:WaitForChild("HumanoidRootPart").Position.Y,p.Character:WaitForChild("HumanoidRootPart").Position.Z)), i/8) 
	end
	for i,v in ipairs(cframetab) do
		model:WaitForChild("HumanoidRootPart").CFrame = v
		task.wait(.03)
	end
	model:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(model:WaitForChild("HumanoidRootPart").Position,Vector3.new(p.Character:WaitForChild("HumanoidRootPart").Position.X,model:WaitForChild("HumanoidRootPart").Position.Y,p.Character:WaitForChild("HumanoidRootPart").Position.Z))
	return position
end


function cameraChange(model)
	local cam = workspace.CurrentCamera
	if model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Head") then
		point(model)
		task.wait(.5)
		--local goal = CFrame.new(model.Head.Position,model.Head.Position + model.Head.CFrame.lookVector * 2)
		local goal = CFrame.new((model.Head.CFrame + model:WaitForChild("HumanoidRootPart").CFrame.lookVector * 3.5).p,model.Head.Position)
		local cframetab = {}
		for i = 1, 10 do
			cframetab[i] = cam.CoordinateFrame:lerp(goal, i/10) 
		end
		cam.CameraType = "Scriptable"
		for i,v in ipairs(cframetab) do
			cam.CoordinateFrame = v
			task.wait(.03)
		end
		cam.CoordinateFrame = goal
		--soundAlert:Destroy()
	end
end


function turnPlayerModel(pointTo)
	if pointTo:FindFirstChild("HumanoidRootPart") then
		local model = p.Character
		local cframetab = {}
		local position = model:WaitForChild("HumanoidRootPart").CFrame
		for i = 1, 8 do
			cframetab[i] = model:WaitForChild("HumanoidRootPart").CFrame:lerp(CFrame.new(model:WaitForChild("HumanoidRootPart").Position,Vector3.new(pointTo:WaitForChild("HumanoidRootPart").Position.X,model:WaitForChild("HumanoidRootPart").Position.Y,pointTo:WaitForChild("HumanoidRootPart").Position.Z)), i/8) 
		end
		for i,v in ipairs(cframetab) do
			model:WaitForChild("HumanoidRootPart").CFrame = v
			task.wait(.03)
		end
		model:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(model:WaitForChild("HumanoidRootPart").Position,Vector3.new(pointTo:WaitForChild("HumanoidRootPart").Position.X,model:WaitForChild("HumanoidRootPart").Position.Y,pointTo:WaitForChild("HumanoidRootPart").Position.Z))
		return position
	end
end

function returnModel(model,position)
	if model and  model:FindFirstChild("HumanoidRootPart") then
		for i = 1, 8 do
			model:WaitForChild("HumanoidRootPart").CFrame = model:WaitForChild("HumanoidRootPart").CFrame:lerp(position, 1/8) 
			task.wait(.03)
		end
		model:WaitForChild("HumanoidRootPart").CFrame = position
	end
end

function numberpokemon(name)
	local thepolicearecoming = 0
	for i,v in ipairs(p.PokemonParty:GetChildren()) do
		if v.Name == name then
			thepolicearecoming = thepolicearecoming + 1
		end
	end
	return thepolicearecoming
end

function healafterbattle()
	Battle:Heal()
end

function healopp()
	if p:FindFirstChild("OppPokemon") then
		for i,v in ipairs(p.OppPokemon:GetChildren()) do
			v.CurrentHP.Value = v.Stats.HPStat.Value
			v.Status.Value = ""
			for _,move in ipairs(v.Moves:GetChildren()) do
				if move.Name ~= "Transform" then
					move.PP.Value = _G.Moves[move.Name]["PP"]
				else
					move.Name = "Double-Edge"
				end
			end
		end
	end
end

function findhighestlevel()
	local highestlevel = 0 
	for i,v in ipairs(p.PokemonParty:GetChildren()) do
		if v.Lvl.Value > highestlevel then
			highestlevel = v.Lvl.Value
		end
	end	
	return highestlevel
end

function findaveragelevel()
	local totallvl = 0
	local party = p.PokemonParty:GetChildren()
	for i,v in ipairs(party) do
		totallvl = totallvl + v.Lvl.Value
	end
	return math.ceil(totallvl/#party)
end


function creategui(move,position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,0,0,25)
	button.Position = position
	button.Text = move
	button.Font = "ArialBold"
	button.FontSize = "Size24"
	button.Parent = main.MoveRelearner
end

function findlead()
	for i,v in ipairs(p.PokemonParty:GetChildren()) do
		if v.PartyPosition.Value == 1 then
			return v
		end
	end	
	return false
end

function tablefind(table, str)
	for i,v in pairs(table) do
		if i == str then
			return true
		end
	end
	return false
end
local note = {"MusicalNote1","MusicalNote2","MusicalNote3","MusicalNote4"}

function musicalNoteCheck()
	local count = 4
	for i,v in ipairs(note) do
		if tablefind(_G.progress,v) then
			if _G.progress[v] == 2 then
				count = count - 1
			end
		end
	end
	return count
end

events = {
	["DracoDragonJay"] = {1,
		["Events"] = {
			[1] = function()
				if p.Badges:FindFirstChild("Champ") then
					scrolltext("What is this pokemon....")
					scrolltext("Im not a trainer so...catch it for me.")
					_G.progress["DracoDragonJay"] = 2
					_G.InWild = true
					_G.nwiqkndqwndqlwkndlkqoc("Suicune",p.OppPokemon,95,false)
					local blah = _G.BattleInitiate(nil,nil,"You have won the battle!",p.Name.." has no Pokemon! "..p.Name.." blacked out!","PurpleInside")
					repeat task.wait() until blah ~= nil
					_G.InWild = false
					if blah == "Win" then
						task.wait(1.4)
						_G.debtalk = false
						return
					elseif blah == "Lose" then
						healafterbattle()
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Pewter City"].Position + Vector3.new(0,5,0))
						_G.debtalk = false
					end
				else
					scrolltext("Come back with the title of a champion")
				end
			end,
			[2] = function()
				scrolltext("You're really powerful !")
			end
		}
	},
	["Oak"] = {1,
		["Events"] = {
			[1] = function()
				p.Character.Humanoid.WalkSpeed = 0
				if #p.PokemonParty:GetChildren() == 0 then

					local area = Vector3.new(34.401, 24.267, 162.311)

					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0)) local hit,pos repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).Unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character) task.wait(.25)
					until hit p.Character:WaitForChild("HumanoidRootPart").Anchored = false 			

					turnPlayerModel(workspace.Oak)			

					scrolltext("Oak: Prepare to begin your Pokemon journey in which is only happening because of Midnight Moon Gacha!")
					local oldpos = turnModel(workspace.Gary1)
					scrolltext("Gary: About time you come here.")
					scrolltext("Oak: Now, "..p.Name..", pick your first Pokemon!")
					scrolltext("Gary: No fair Gramps! What about me?")
					scrolltext("Oak: Be patient, Gary. You can pick one too.")
					game.Lighting:WaitForChild("SelectStarters"):Clone().Parent = p.PlayerGui
					repeat task.wait() until _G.SelectStarter ~= nil 
					scrolltext("Gary: Wow, ".._G.SelectStarter:reverse().."? I choose "..garypokemon[_G.Pokemon[_G.SelectStarter:reverse()]["Type"][1]].."!")
					scrolltext("You: I'm better then you!")
					point(workspace.Gary1)
					scrolltext("Gary: Nope. Get ready to lose, "..p.Name.."!")
					_G.PiayingCheckers("normal",_G.SelectStarter:reverse(),p.PokemonParty,5,true)
					Pokedex:Create(_G.SelectStarter:reverse(),true)
					if game.ReplicatedStorage:WaitForChild("REvents").Pokemon.StarterCheck:InvokeServer(_G.SelectStarter:reverse()) == false then
						p:Kick()
					end
					_G.PiayingCheckers("normal",garypokemon[_G.Pokemon[_G.SelectStarter:reverse()]["Type"][1]],p.OppPokemon,5,true)
					repeat task.wait() until #p.OppPokemon:GetChildren() > 0 
					local blah =_G.BattleInitiate("Trainer","Gary","I picked the wrong Pokemon!","I knew I made the right choice!","Inside")
					--p.Character.Humanoid.WalkSpeed = 0
					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						scrolltext("Gary: Lucky one.")
					elseif blah == "Lose" then
						laugh(workspace.Gary1)
						scrolltext("Gary: LOL LOSER!")
						task.wait(.05)
					end
					returnModel(workspace.Gary1,oldpos)
					healafterbattle()
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("Oak: That was an amazing battle! Both of you have potential!")
					scrolltext("Oak: Anyway, "..p.Name..", can you do me a favor? I ordered a special parcel.")
					scrolltext("Oak: It arrived today at the Pokemart at Viridian City.")
					scrolltext("Oak: I'll give you something if you deliver this to me.")
					scrolltext("Oak: And here, have 3 Pokeballs.")
					scrolltext("In a wild Pokemon battle, you can go into your bag and go to the Pokeball tab.")
					scrolltext("Afterwards, you can use the Pokeball on the Wild Pokemon.")
					scrolltext("You should lower the HP of the Pokemon and inflict it with a status.")
					scrolltext("Those increases the chances of catching it.")
					Math:Oak(3)
				else
					scrolltext("Oak: You already have a Pokemon! Get my parcel in Viridian City!")
				end
				p.Character.Humanoid.WalkSpeed = 16
				_G.progress["ShopkeeperOak"] = 2
				_G.progress["Mom"] = 3	
				_G.progress["Oak"] = 2			
			end,
			[2] = function() 
				scrolltext("Have you got my package yet?")
				scrolltext("Looks like you don't have it! Go to Viridian City!")
			end,
			[3] = function()
				scrolltext("Oak: Thanks for delivering my parcel!")
				scrolltext("Oak: I used to give Pokedexes out to people...")
				scrolltext("Oak: But they're as common as cellphones nowadays...")
				scrolltext("Oak: I know! You can have these Pokeballs!")
				scrolltext("<Oak gives you 5 Pokeballs.>")
				scrolltext("Gary: I'll be on Route 22. Come if you dare.")
				Math:Oak(5)


				_G.progress["Gary2"] = 2
				_G.progress["Oak"] = 4
			end,
			[4] = function()
				scrolltext("Oak: Remember to fill up your Pokedex!")
			end	
		},
	},	
	["Mom"] = {1,
		["Events"] = {
			[1] = function(model) 
				scrolltext("Mom: I can't believe my little "..p.Name.." is going to be a Pokemon Trainer!")
				scrolltext("Professor Oak is ready to give you your Pokemon. He's in his lab across the street.") 
				cheer(model)
				_G.progress["Mom"] = 2
			end,
			[2] = function() 
				scrolltext("Mom: What are you waiting for? Professor Oak is ready for you across the street.")
			end,
			[3] = function()
				scrolltext("Mom: You picked out such a cute Pokemon!")
				scrolltext("If you ever need a place to rest, you're always welcome here.")
				scrolltext("Talk to me again if you need to heal up your Pokemon.")
				_G.progress["Mom"] = 4
			end,
			[4] = function()
				scrolltext("Mom: Here you go, sweetie!") 
				scrolltext("<She heals your Pokemon.>") 
				healafterbattle()
			end
		}
	},
	["ShopkeeperOak"]  = {1,
		["Events"] ={
			[1] = function()
				scrolltext("Talk to Professor Oak, please!")
				scrolltext("Besides that, welcome to the PokeMart!")
				_G.Shop()
			end,
			[2] = function() 
				scrolltext("Welcome to the PokeMart! How may I--")
				scrolltext("You are here for Oak's Parcel?")
				scrolltext("Take what you want then!")
				scrolltext("<You snatched the parcel from the Clerk!>")
				_G.progress["ShopkeeperOak"] = 3
				_G.progress["Oak"] = 3
			end,
			[3] = function()
				scrolltext("Welcome to the PokeMart!")
				_G.Shop()
			end
		}
	},

	["PC"] = {1,
		["Events"] = {
			[1] = function()
				p.PlayerGui.SoundEffect.SoundId = "rbxassetid://6454696110"
				p.PlayerGui.SoundEffect:Play()
				scrolltext("<You boot up the PC.>")
				if main.Trade.Visible == false then
					_G.PCSystem()
				end
			end
		}

	},
	["Nurse Joy"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Welcome to the PokeCenter.")
				scrolltext("Do you want me to heal your Pokemon? ",true)
				local choice
				Math:PokeChange(model)
				sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true
					healafterbattle()	
					p.PlayerGui.SoundEffect.SoundId = "rbxassetid://11937849688"
					p.PlayerGui.SoundEffect:Play()
					bow(model)
					scrolltext("See you next tuesday!")
					choice = true
				end)
				sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()

					speech.Parent.Next.Visible = true
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					scrolltext("R.I.P. Juice WRLD and YOUR POKEMON!")
					choice = true
				end)	
				p.Character.Humanoid.WalkSpeed = 0
				speech.Parent.popup.Yes.Visible = true 
				speech.Parent.popup.Visible = true
				speech.Parent.popup.No.Visible = true
				menu.Visible = false
				repeat task.wait() until choice
			end
		}

	},
	["Gary2"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Gary: Nerd! I'm catching this Eevee!")
				scrolltext("<You have to get Oak's Parcel back to Oak before you can rebattle Gary!>")
			end,
			[2] = function()
				scrolltext("Gary: I'M BETTER THEN YOU!")
				scrolltext("Gary: I AM GOING TO WIN THIS!")
				_G.PiayingCheckers("normal","Eevee",p.OppPokemon,13,true)
				if _G.SelectStarter ~= nil then
					_G.PiayingCheckers("normal",garypokemon[_G.Pokemon[_G.SelectStarter:reverse()]["Type"][1]],p.OppPokemon,11,true)
				else _G.PiayingCheckers("normal","Piplup",p.OppPokemon,15,true)
				end
				repeat task.wait() until #p.OppPokemon:GetChildren() > 1
				local blah =_G.BattleInitiate("Trainer","Gary","Beginner's luck.","I expected that as much.","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("Gary: I'm surprised someone LIKE you can get so lucky.")
					_G.progress["Gary2"] = 3
					--p.Character.Humanoid.WalkSpeed = 16
				elseif blah == "Lose" then
					healafterbattle()
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Viridian City"].Position + Vector3.new(0,5,0))
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[3] = function() scrolltext("Go away.") end
		},
	},
	["Shopkeeper"]  = {1,
		["Events"] ={
			[1] = function()
				scrolltext("Welcome to the PokeMart!")
				_G.Shop()
			end
		}
	},
	["Brock"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("I'm Brock, Pewter City's gym leader.")
				scrolltext("I am the best rock type trainer in the world.")
				scrolltext("Years of training have made my Pokemon rock-hard with determinination.")
				point(model)
				scrolltext("Prepare to get crushed!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Brock.Pokemon)
				local blah =_G.BattleInitiate("1st Leader","Brock","I underestimated you!","Good try.","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					nod(model)
					scrolltext("That was an amazing battle.")
					scrolltext("You are no doubt worthy of my gym badge.")
					local messageText = p.Name.. " has beaten Brock and earned the Boulder Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					scrolltext("<"..p.Name.." has earned the Boulder Badge!>")
					scrolltext("Take this Rock Tomb TM!")
					Math:FuncAddItem("Rock Tomb", p.Bag["TMs"],1)
					scrolltext("<You got TM Rock Tomb>")
					scrolltext("Rock Tomb  is a Rock attack that slows the enemy down. Perfect for Rock types!")
					scrolltext("What's next for you? I would suggest traveling east to Cerulean City.")
					scrolltext("Oh yeah, I also have something for you. Silph Co. wants me to give these Exp. Shares to up and coming trainers.")
					scrolltext("You fit the bill, so here you go!")
					scrolltext("<You got the Exp. Share!>")
					scrolltext("To use the Exp. Share, you must turn it on. To do that, go into the Evolve Tab in your bag and turn on your Exp. Share!")
					scrolltext("Once it's on, every non-Fainted Pokemon in your party gets experience in battle!")
					Math:AddBoolItem("Exp. Share",p.Bag.Evolution)
					Math:AwardBadge(1)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Brock"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Pewter City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				if not p.Bag.Evolution:FindFirstChild("Exp. Share") then
					scrolltext("Oh, hey, "..p.Name..", welcome back.")
					scrolltext("Silph Co. gave me these Exp. Shares to give to experienced trainers.")
					scrolltext("You're pretty experienced, since you beat me!")
					scrolltext("<You got the Exp. Share!>")
					scrolltext("To use the Exp. Share, you must turn it on. To do that, go into the Evolve Tab in your bag and turn on your Exp. Share!")
					scrolltext("Once it's on, every non-Fainted Pokemon in your party gets experience in battle!")
					Math:AddBoolItem("Exp. Share",p.Bag.Evolution)
				else
					scrolltext("Go forth, "..p.Name.."! I'm rooting for you!")
				end
			end
		}
	},
	["CashShop"] = {1,
		["Events"] = { [1] =function() scrolltext("I'm the traveling evolution stone salesman!") 
			scrolltext("I sell stones for Robux to people like you.")
			scrolltext("Every PokeMart also sells stones in the \"Special\" Tab for Pokedollars.")
			scrolltext("Talk to me again if interested!")
			_G.progress["CashShop"] = 2
		end,
		[2] = function() scrolltext("Remember: no refunds. I recommend only buying these when you need them.")
			_G.CashShop()
		end
		}},
	["Misty"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("I'm Misty, Cerulean City's gym leader.")
				scrolltext("Well i used to be, my gym was bought and i couldent do anything about it..so we moved down here amd made it home, Well enough of the talk lets battle!")
				scrolltext("Be warned - I am tough!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(workspace.Misty.Pokemon)
				local blah =_G.BattleInitiate("2nd Leader","Misty","Evaporated...","Haha! I win!","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					task.wait(.2)
					scrolltext("You're pretty good!")
					local animation = Instance.new("Animation",script.Parent)
					animation.AnimationId = "http://www.roblox.com/asset/?id=428704872"
					model.Humanoid:LoadAnimation(animation):Play()
					task.wait(.6)
					animation:Destroy()
					local messageText = p.Name.. " has beaten Misty and earned the Cascade Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					scrolltext("<"..p.Name.." has earned the Cascade Badge!>")
					scrolltext("Take this Water Pulse TM!")
					Math:FuncAddItem("Water Pulse", p.Bag["TMs"],1)
					scrolltext("<You got TM Water Pulse>")
					scrolltext("Water Pulse is a Water attack that has a decent chance to confuse the enemy.")
					scrolltext("What's next for you? I would suggest going to Route 5 and traveling to Vermillion City.")
					Math:AwardBadge(2)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Misty"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Cerulean City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				local badgesneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = true,
					["4"] = true,
					["5"] = true,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgesneeded[v.Name] == false then
						badgesneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgesneeded) then
					scrolltext("You beat me, do you want a free Togepi?")
					if #p.PokemonParty:GetChildren() < 6 then 
						scrolltext("It's so cute... but it's not a water type.")
						scrolltext("<You got a Togepi!>")

						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static", p.PokemonParty, "Togepi")


						--Pokedex:Create("Togepi",true)
						_G.progress["Misty"] = 3
					else
						scrolltext("You have a full party! Come back when you don't have a full party!")
					end
				else
					scrolltext("You must have the first two badges in order to get this Togepi. Come back when you do.")
				end

			end,
			[3] = function()
				scrolltext("Go forth. I'm rooting for you!")
			end
		}
	},
	["Surge"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("Hey kid - what do you think you're doing here? You won't last long in combat!")
				scrolltext("That's for sure! I tell you, kid, electric type Pokemon saved me during the war!")
				scrolltext("They zapped my enemies into paralysis. The same thing I'll do to you!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Surge.Pokemon)
				local blah =_G.BattleInitiate("3rd Leader","Lt. Surge","You're the real deal!","Kid, you better train!","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					local messageText = p.Name.. " has beaten Lt. Surge and earned the Thunder Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					nod(model)
					scrolltext("Consider this proof that you defeated me, kid!")
					scrolltext("<"..p.Name.." has earned the Thunder Badge!>")
					scrolltext("Take this Charge Beam TM!")
					Math:FuncAddItem("Charge Beam", p.Bag["TMs"],1)
					scrolltext("<You got TM Charge Beam>")
					scrolltext("Charge Beam is an Electric attack that has a very high chance of raising the users Sp. Atk!")
					scrolltext("What's next for you? I would suggest traveling west to Lavender Town.")
					Math:AwardBadge(3)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Surge"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Vermillion City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("Hey kid, still slugging and chugging away? My Pokemon and I are still at it!")
			end
		}
	},

	["Giovanni"] = {1,
		["Events"] = {
			[1] = function()
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Giovanni.Pokemon)
				scrolltext("Who are you?")
				scrolltext(p.Name.."? I'm impressed you got here.")
				scrolltext("It doesn't matter though - I will destroy you from where you stand!")
				local blah =_G.BattleInitiate("Boss","Giovanni","Sound the retreat.","Have fun climbing the tower again.","PurpleInside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("Impossible... just a mere kid disrupting my plans?")
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Giovanni"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Lavender Town"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("After you defeated Giovanni, he put a body double in his place. I don't know where he is.")
			end
		}
	},
	["Gary3"] = {1,
		["Events"] = {
			[1] = function()
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Gary3.Pokemon)
				scrolltext("Why are you at the Pokemon Tower, "..p.Name.."?")
				scrolltext("None of your Pokemon are deceased...")
				scrolltext("I traded Pokemon around, so now I have all three starters.")
				scrolltext("Hope you've been training... prepare to battle.")
				local blah =_G.BattleInitiate("Trainer","Gary","Your luck streak will end soon.","I expected as much.","PurpleInside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("I already have 6 gym badges! Smell ya later, chump.")
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Gary3"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Lavender Town"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("You've already beat me here.")
			end
		}
	},
	["Erika"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("Hello. Lovely weather, isn't it? It's so pleasant... oh dear... I must have dozed off...")
				scrolltext("Welcome. My name is Erika. I am the leader of Celadon Gym. My Pokemon are of Grass-type.")
				scrolltext("Oh? You want to challenge me? Very well, but I will not lose.")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Erika.Pokemon)		
				local blah =_G.BattleInitiate("4th Leader","Erika","I told you so.","Better luck next time.","WildGrass")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					bow(model)
					scrolltext("Oh! I concede defeat. You are remarkably strong. I must confer you the Rainbow Badge!")
					local messageText = p.Name.. " has beaten Erika and earned the Rainbow Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					scrolltext("<"..p.Name.." has earned the Rainbow Badge!>")
					scrolltext("Take this Grass Knot TM!")
					Math:FuncAddItem("Grass Knot", p.Bag["TMs"],1)
					scrolltext("<You got TM Grass Knot>")
					scrolltext("You know the saying 'The bigger they are, the harder they fall?' Well, that's Grass Knot in a nutshell!")
					scrolltext("What's next for you? I would suggest traveling west to Fuchsia Town.")
					Math:AwardBadge(4)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Erika"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Celadon City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("You are cataloging Pokemon? I must say I'm impressed.")
				scrolltext("I would never collect Pokemon if they were unattractive."	)
			end
		}
	},
	["PokemonTower"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("We are currently closed for renovations. Come back later.")
			end
		}
	},
	["EeveeGiver"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Hello, do you want a free Eevee?")
				if #p.PokemonParty:GetChildren() < 6 then 
					scrolltext("I don't care if you don't want it! Take this Eevee! :3")
					scrolltext("You got an Eevee!")
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static", p.PokemonParty, "Eevee")
					--Pokedex:Create("Eevee",true)
					_G.progress["EeveeGiver"] = 2
				else
					scrolltext("You have a full party! Come back when you don't have a full party!")
				end

			end,
			[2] = function()
				scrolltext("Hopefully my pal has served you well!")
			end
		},
	},
	["Koga"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("Fwahahaha! A mere kid like you dares to challenge me? Very well.")
				scrolltext(" I shall show you true terror as a ninja master!")
				scrolltext("You shall feel the despair of powerful Poison Pokemon!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Koga.Pokemon)		
				local blah =_G.BattleInitiate("5th Leader","Koga","Hmph!","Another victim!","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					bow(model)
					scrolltext("You have proven your worth. Here! Take the Soul Badge!")
					local messageText = p.Name.. " has beaten Koga and earned the Soul Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					scrolltext("<"..p.Name.." has earned the Soul Badge!>")
					scrolltext("Take this Sludge Bomb TM!")
					Math:FuncAddItem("Sludge Bomb", p.Bag["TMs"],1)
					scrolltext("<You got TM Sludge Bomb>")
					scrolltext("Sludge Bomb is a powerful poison type move.")
					scrolltext("What's next for you? I would suggest traveling to Saffron City.")
					Math:AwardBadge(5)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Koga"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Fuchsia City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("I subjected you to everything I could muster. But my efforts failed. I must hone my skills. Go away.")
			end
		}
	},
	["WildBattle"] = {1,
		["Events"] = {

			[1] = function()
				--				wildpokemon = {
				--					["Tier 1"]=20951796,
				--					["Tier 2"]= 20951797,
				--					["Tier 3"]= 20951798  
				--				}
				--				scrolltext("At this place, you can battle RANDOM wild Pokemon for Robux.")
				--				scrolltext("Tier 1 - ALL Pokemon. Tier 2 - Only 2nd and final evolutions. Tier 3 - Only final evolutions.")
				--				scrolltext("You still have to CAPTURE the Pokemon in battle. The Pokemon's level depends on your party's level.")
				--				scrolltext("If you fail to capture or do not like the Pokemon you got, a refund will not be granted.")
				--		
				--		for i,v in ipairs(p.PlayerGui.DialogTalk:GetChildren()) do
				--				if v:IsA("TextButton") then
				--					v.Visible = true
				--					if v.Name == "Cancel" then
				--							getfenv()["Arena"..v.Name] = v.MouseButton1Down:Connect(function()
				--								p.Character.Humanoid.WalkSpeed = 0
				--								for i_,blah in ipairs(p.PlayerGui.DialogTalk:GetChildren()) do
				--								blah.Visible = false
				--								if getfenv()["Arena"..blah.Name] then getfenv()["Arena"..blah.Name]:disconnect() end
				--								end
				--								scrolltext("Come again soon!")
				--							end)
				--					else
				--						getfenv()["Arena"..v.Name] = v.MouseButton1Down:Connect(function()
				--								for i_,blah in ipairs(p.PlayerGui.DialogTalk:GetChildren()) do
				--								blah.Visible = false
				--								if getfenv()["Arena"..blah.Name] then getfenv()["Arena"..blah.Name]:disconnect() end
				--								end
				--								game:GetService("MarketplaceService"):PromptProductPurchase(p,wildpokemon[v.Text])
				--					end)
				--						
				--					end
				--				end
				--		end
				scrolltext("I used to be pretty important, but my job was outsourced.")
				scrolltext("Use the roulette instead.")
			end
		}
	},
	["Taxi"] = {1,
		["Events"] = {
			[1] = function()
				local t = 1
				local order = {
					p.PlayerGui:WaitForChild("Main").Taxi["Pewter City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Cerulean City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Vermillion City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Celadon City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Fuchsia City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Saffron City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Cinnabar Volcano"],
					p.PlayerGui:WaitForChild("Main").Taxi["Indigo"],
					p.PlayerGui:WaitForChild("Main").Taxi["Elegant Valley"],
					p.PlayerGui:WaitForChild("Main").Taxi["Mysterious Grotto"],
					p.PlayerGui:WaitForChild("Main").Taxi["Mausoleum of Origins"],
				}
				scrolltext("Hello, and welcome to Kanto's very own taxi service!")
				scrolltext("We can teleport you to cities where you have obtained a Gym badge.")
				p.PlayerGui:WaitForChild("Main").Taxi["Viridian City"].Visible = true
				for i,v in ipairs(order) do
					if p.Badges:FindFirstChild(taxi[v.Name]) then
						v.Position = UDim2.new(0,0,0,25*(t+1))
						t = t + 1
						v.Visible = true
					else
						v.Visible = false
					end
				end	
				p.PlayerGui:WaitForChild("Main").Taxi.Close.Position = UDim2.new(0,0,0,25*(t+1))
				p.PlayerGui:WaitForChild("Main").Taxi.Visible = true
			end
		}
	},
	["TMShop"]  = {1,
		["Events"] ={
			[1] = function()
				scrolltext("Welcome to the TM Shop! All TMs have unlimited uses!")
				_G.TMShop()
			end
		}
	},
	["Jackie Chan"] = {1,
		["Events"] = {
			[1] = function()
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("My name is Jackie Chan - and I'm not your typical Black Belt!")
				scrolltext("I've trained my Hitmonlees to STAGGERING levels!")
				scrolltext("You need to be really lucky to defeat me!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace["Jackie Chan"].Pokemon)
				local blah =_G.BattleInitiate("Black Belt","Jackie Chan","Hmph!","You died honorably.","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("Wow! You deserved something... I would give a badge, but I don't want to get arrested.")
					scrolltext("I know! You can have a Hitmonlee! Talk to me again if you want one.")
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Jackie Chan"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Saffron City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("You want a Hitmonlee? Okay!")
				if #p.PokemonParty:GetChildren() < 6 then 
					scrolltext("Bye, Hitmonlee!")
					scrolltext("<You got an Hitmonlee!>")
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty,string.reverse("eelnomtiH"))
					Pokedex:Create("Hitmonlee",true)
					_G.progress["Jackie Chan"] = 3
				else
					scrolltext("You have a full party! Come back when you don't have a full party!")
				end
			end,
			[3] = function()
				scrolltext("That Hitmonlee I gave to you was descended from the blood of CHAMPIONS.")
			end
		}
	},
	["Bruce Lee"] = {1,
		["Events"] = {
			[1] = function()
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("My name is Bruce Lee - and I'm a very special Black Belt!")
				scrolltext("I've trained my Hitmonchans to DESTRUCTIVE levels!")
				scrolltext("I have to be really unlucky to lose!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace["Bruce Lee"].Pokemon)
				local blah =_G.BattleInitiate("Black Belt","Bruce Lee","...!","Not even a good try.","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("Wow! You deserve something...")
					scrolltext("I know! You can have a Hitmonchan! Talk to me again if you want one.")
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Bruce Lee"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Saffron City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("You want a Hitmonchan? Okay!")
				if #p.PokemonParty:GetChildren() < 6 then 
					scrolltext("Bye, Hitmonchan!")
					scrolltext("<You got an Hitmonchan!>")
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty,string.reverse("nahcnomtiH"))
					Pokedex:Create("Hitmonchan",true)
					_G.progress["Bruce Lee"] = 3
				else
					scrolltext("You have a full party! Come back when you don't have a full party!")
				end
			end,
			[3] = function()
				scrolltext("That Hitmonchan I gave to you was PUREBRED to win the BEST martial arts competitions.")
			end
		}
	},
	["Sabrina"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("I had a vision of your arrival! I've had psychic powers since I was a child.")
				point(model)
				scrolltext("I'm Sabrina - I dislike fighting, but still, I will show you my powers!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace["Sabrina"].Pokemon)
				local blah =_G.BattleInitiate("6th Leader","Sabrina","Your power is too strong!","I foresaw this.","PurpleInside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("I'm shocked! But a loss is a loss. Here! Have the Marsh Badge!")
					local messageText = p.Name.. " has beaten Sabrina and earned the Marsh Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					scrolltext("Take this Calm Mind TM!")
					Math:FuncAddItem("Calm Mind", p.Bag["TMs"],1)
					scrolltext("<You got TM Calm Mind>")
					scrolltext("<"..p.Name.." has earned the Marsh Badge!>")
					scrolltext("What's next for you? I would suggest traveling to Mt. Cinnabar.")
					Math:AwardBadge(6)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Sabrina"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Saffron City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("According to the future, you are destined for great things.")
			end
		}
	},
	["Gary4"] = {1,
		["Events"] = {
			[1] = function()
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace["Gary4"].Pokemon)
				scrolltext("Fancy seeing you here, "..p.Name.."!")
				scrolltext("Looks like you've been training - so have I!")
				scrolltext("I won't go down at all to a newbie like you.")
				scrolltext("Prepare to battle!")
				local blah =_G.BattleInitiate("Trainer","Gary","Your luck streak will end one day.","I expected as much.","WildGrass")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("I'm going to Mt. Cinnabar to battle Blaine! Smell ya later!")
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Gary4"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Saffron City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("You've already beat me here.")
			end
		}
	},
	["Pokemon Shop"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Hello... this place isn't exactly legal.")
				scrolltext("We sell Pokemon for Pokedollars here.")
				scrolltext("To shop with us, you need to have less than 6 party members.")
				if #p.PokemonParty:GetChildren() < 6 then 
					_G.PokemonShop()
				else
					scrolltext("You have a full party! Come back when you don't have a full party!")
				end

			end,
		},
	},
	["Blaine"] = {1,
		["Events"] = {
			[1] = function()
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("I'm Blaine - I've mastered this volcano!.")
				scrolltext("Prepared to get incinerated!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Blaine.Pokemon)		
				local blah =_G.BattleInitiate("7th Leader","Blaine","I've burnt out...","Good battle.","Cave")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					scrolltext("I've been reduced to ashes! Here! Have the Volcano Badge!")
					local messageText = p.Name.. " has beaten Blaine and earned the Volcano Badge!"
					game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
					scrolltext("<"..p.Name.." has earned the Volcano Badge!>")
					scrolltext("Take this Overheat TM!")
					Math:FuncAddItem("Overheat", p.Bag["TMs"],1)
					scrolltext("<You got TM Overheat>")
					scrolltext("Overheat makes the user go all out, but it has a drawback since it's so powerful.")
					scrolltext("The last gym leader - if you have 7 gym badges - is waiting for you at Viridian City.")
					Math:AwardBadge(7)
					p.Character.Humanoid.WalkSpeed = 16
					_G.progress["Blaine"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Cinnabar Volcano"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("My Fire-type Pokemon will be even stronger! Just you watch!")
			end
		}
	},

	["NicknameGuy"]  = {1,
		["Events"] ={
			[1] = function()
				local success, canLocalUserChat = pcall(function()
					return game:GetService("TextChatService"):CanUserChatAsync(game.Players.LocalPlayer.UserId)
				end)
				if success and canLocalUserChat  then
					scrolltext("Welcome! I have the only power in the world to give your Pokemon nicknames!")
					_G.Nickname()
				else
					scrolltext("Sorry, but your account does not have access to the nickname feature.")
				end
			end
		}
	},
	["MoveRelearner"] = 
		{1,
			["Events"] = {
				[1] = function()
					scrolltext("I'm the Move Relearner.")
					scrolltext("Do you want to reteach one of your Pokemon a move?") 
					scrolltext("Let me check if you have the $10000 Pokedollars, since this is hard work for me!")
					if p.Money.Value >= 10000 then 
						scrolltext("Okay, you have the cash! Remember, it costs 10000!")
						_G.MoveRelearner()
					else
						scrolltext("You don't have enough cash... I don't run a charity!")
					end

				end,

			},
		},
	["SkarmoryGiver"] = {1,
		["Events"] = {
			[1] = function(model)
				local badgesneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = false,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgesneeded[v.Name] == false then
						badgesneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				scrolltext("Looks like your team needs spicing up!")
				if tablecheck(badgesneeded) then
					if #p.PokemonParty:GetChildren() < 6 then 
						scrolltext("Your team doesn't look that strong, so have this Skarmory.")
						laugh(model)
						scrolltext("Haha, just kidding! Your team looks plenty strong!")
						scrolltext("You got a Skarmory!")
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static", p.PokemonParty, "Skarmory")

						--Pokedex:Create("Skarmory",true)
						_G.progress["SkarmoryGiver"] = 2
					else
						scrolltext("You have a full party! Come back when you don't have a full party!")
					end
				else
					scrolltext("You do not have at least 6 badges. Please go get them and return.")

				end

			end,
			[2] = function()
				scrolltext("I'm still lonely...")
			end
		},
	},
	["LugiaGuy"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Lazy bear. Dragonfly. Doctor. Fire bird. Magnets..")
				scrolltext("I had a dream about those things once...")
				scrolltext("I would love to see those things again, but... I don't know where to find them.")
				local pokemonneeded = {
					["Snorlax"] = false,
					["Vibrava"] = false,
					["Chansey"] = false,
					["Moltres"] = false,
					["Magneton"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					cheer(model)

					scrolltext("Oh wow! You actually have all of those!")
					scrolltext("Just like my dream...")
					scrolltext("...Do you want a Lugia? Talk to me again...")
					_G.progress["LugiaGuy"] = 2
				end
			end,
			[2] = function()
				if #p.PokemonParty:GetChildren() < 6 then 
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static", p.PokemonParty, "Lugia")
					scrolltext("Here is your Lugia...")
					scrolltext("<YOU GOT A LUGIA! WHAT?!>")
					scrolltext("Congrats on finding out what to do! --WishNite")
					_G.progress["LugiaGuy"] = 3
				else 
					scrolltext("You need less than 6 Pokemon in your party...")
				end
			end,
			[3] = function()
				scrolltext("Good job!")
			end
		},
	},
	["ArticunoFeather"] = {1,
		["Events"] = {
			[1] = function(model)
				local pokemonneeded = {
					["Articuno"] = false
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(tbl)
					for _, v in pairs(tbl) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					local roll = math.random(1,40)
					if roll == 7 then
						scrolltext("The air freezes! Galarian Articuno emerges from the mist to confront you!")
						_G.InWild = true
						_G.PiayingCheckers("normal","Galarian Articuno",p.OppPokemon,65,false)
						local result = _G.BattleInitiate(nil,nil,"You have defeated Galarian Articuno!",p.Name.." has no Pokemon! "..p.Name.." blacked out!","PurpleInside")							
						repeat task.wait() until result ~= nil
						_G.InWild = false
						if result == "Win" then
							local feather = workspace:FindFirstChild("ArticunoFeather")
							if feather then
								if not feather.PrimaryPart then
									local part = feather:FindFirstChildWhichIsA("BasePart")
									if part then
										feather.PrimaryPart = part
									else
										warn("No BasePart found in ArticunoFeather model!")
									end
								end
								if feather.PrimaryPart then
									feather:SetPrimaryPartCFrame(feather.PrimaryPart.CFrame * CFrame.new(0, -1000, 0))
								end
							end
							task.wait(1.4)
							_G.debtalk = false
							return
						elseif result == "Lose" then
							healafterbattle()
							game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Fuchsia City"].Position + Vector3.new(0,5,0))
							_G.debtalk = false
						end

					else
						scrolltext("The frosty feather shimmers but nothing stirs. Try again!")
					end

				else
					scrolltext("The chill in the air is a sign...")
					scrolltext("Perhaps you need a companion who has mastered the icy winds.")
				end
			end
		}
	},
	["MoltresFeather"] = {1,
		["Events"] = {
			[1] = function(model)
				local pokemonneeded = {
					["Moltres"] = false
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(tbl)
					for _, v in pairs(tbl) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					local roll = math.random(1,40)
					if roll == 7 then
						scrolltext("Flames blaze fiercely! Galarian Moltres swoops down to battle!")
						_G.InWild = true
						_G.PiayingCheckers("normal","Galarian Moltres",p.OppPokemon,65,false)
						local result = _G.BattleInitiate(nil,nil,"You have defeated Galarian Moltres!",p.Name.." has no Pokemon! "..p.Name.." blacked out!","PurpleInside")							
						repeat task.wait() until result ~= nil
						_G.InWild = false
						if result == "Win" then
							local feather = workspace:FindFirstChild("MoltresFeather")
							if feather then
								if not feather.PrimaryPart then
									local part = feather:FindFirstChildWhichIsA("BasePart")
									if part then
										feather.PrimaryPart = part
									else
										warn("No BasePart found in MoltresFeather model!")
									end
								end
								if feather.PrimaryPart then
									feather:SetPrimaryPartCFrame(feather.PrimaryPart.CFrame * CFrame.new(0, -1000, 0))
								end
							end
							task.wait(1.4)
							_G.debtalk = false
							return
						elseif result == "Lose" then
							healafterbattle()
							game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Cinnabar Volcano"].Position + Vector3.new(0,5,0))
							_G.debtalk = false
						end

					else
						scrolltext("The ember flickers softly, but the flames don’t ignite. Try again!")
					end

				else
					scrolltext("A faint warmth lingers... only the fiery spirit can stir the ember into flame.")
				end
			end
		}
	},
	["ZapdosFeather"] = {1,
		["Events"] = {
			[1] = function(model)
				local pokemonneeded = {
					["Zapdos"] = false
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(tbl)
					for _, v in pairs(tbl) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					local roll = math.random(1,40)
					if roll == 7 then
						scrolltext("Dark clouds gather! Galarian Zapdos strikes down to face you!")
						_G.InWild = true
						_G.PiayingCheckers("normal","Galarian Zapdos",p.OppPokemon,65,false)
						local result = _G.BattleInitiate(nil,nil,"You have defeated Galarian Zapdos!",p.Name.." has no Pokemon! "..p.Name.." blacked out!","PurpleInside")							
						repeat task.wait() until result ~= nil
						_G.InWild = false
						if result == "Win" then
							local feather = workspace:FindFirstChild("ZapdosFeather")
							if feather then
								if not feather.PrimaryPart then
									local part = feather:FindFirstChildWhichIsA("BasePart")
									if part then
										feather.PrimaryPart = part
									else
										warn("No BasePart found in ZapdosFeather model!")
									end
								end
								if feather.PrimaryPart then
									feather:SetPrimaryPartCFrame(feather.PrimaryPart.CFrame * CFrame.new(0, -1000, 0))
								end
							end
							task.wait(1.4)
							_G.debtalk = false
							return
						elseif result == "Lose" then
							healafterbattle()
							game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Lavender Town"].Position + Vector3.new(0,5,0))
							_G.debtalk = false
						end
					else
						scrolltext("Sparks crackle around the feather, but the storm stays calm. Try again!")
					end
				else
					scrolltext("A spark dances nearby, but only those who command the storm can awaken the thunder's wrath.")
				end
			end
		}
	},
	["Hooh"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Mr. Weirdo. Opera. Tongue. Supercomputer.")
				scrolltext("I had a dream about those things once...")
				scrolltext("I would love to see those things again, but... I don't know where to find them.")
				local pokemonneeded = {
					["Lickitung"] = false,
					["Jynx"] = false,
					["Mr. Mime"] = false,
					["Metagross"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then 
					cheer(model)

					scrolltext("Oh wow! You actually have all of those!")
					scrolltext("Just like my dream...")
					scrolltext("...Do you want a Ho-Oh? Talk to me again...")
					_G.progress["Hooh"] = 2
				end
			end,
			[2] = function()
				if #p.PokemonParty:GetChildren() < 6 then  
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static", p.PokemonParty, "Ho-Oh")
					scrolltext("Here is your Ho-Oh...")
					scrolltext("<YOU GOT A Ho-Oh! WHAT?!>")
					scrolltext("Congrats on finding out what to do! --WishNite")
					_G.progress["Hooh"] = 3
				else 
					scrolltext("You need less than 6 Pokemon in your party...")
				end
			end,
			[3] = function()
				scrolltext("Good job!")
			end
		},
	},
	["8thGymPerson"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("The gym leader doesn't want to talk to inexperienced people.")
				scrolltext("You need at least 7 badges before you can proceed...")

				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = false,
					["7"] = false
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then 
					scrolltext("You have enough badges.")
					scrolltext("You shall suffice for master...")
					scrolltext("Talk to me again if you want to enter the 8th gym.")
					_G.progress["8thGymPerson"] = 2

				else 
					scrolltext("Master doesn't want low tier fry like you. Get all 7 badges and you can enter.")
				end
			end,
			[2] = function()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = "Saffron City"
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(Vector3.new(-43, -63.5, 725) + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
				p.Character.Humanoid.WalkSpeed = 16
			end
		}
	},
	["GiovanniBoss"] = {1,
		["Events"] = {
			[1] = function()
				for _,pokemon in ipairs (game:GetService("Workspace").GiovanniBoss.Pokemon:GetChildren()) do
					pokemon:Clone().Parent = p.OppPokemon
				end
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("Oh -- I remember you. You foiled my plans at Lavender Tower.")
				scrolltext("I bet you didn't expect me to be the 8th gym leader! ")
				scrolltext("It's the perfect front...")
				scrolltext("I'll put an end to your adventure!")
				local blah =_G.BattleInitiate("Boss","Giovanni",((findhighestlevel() >= 95 and "I refuse to lose!") or "..."),"As expected.","PurpleInside")
				p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					if findhighestlevel() >= 95 then
						scrolltext("Hurray! I have gathered enough data on you!")
						scrolltext("Prepare for this! I've copied your team!")
						for i,v in ipairs(p.PokemonParty:GetChildren()) do
							v:Clone().Parent =	p.OppPokemon			
						end
						healopp()
						local blah =_G.BattleInitiate("Boss","Giovanni",("But I used your Pokemon..."),"Hah. Your team is really good!","PurpleInside")
						p.Character.Humanoid.WalkSpeed = 16
						repeat task.wait() until blah ~= nil
						if blah == "Win" then
							scrolltext("...You're just better than me.")
							scrolltext("Having lost, I cannot face my followers. I have betrayed their trust. I'm disbanding Team Rocket.")
							scrolltext("And... here. The Earth Badge!")
							local messageText = p.Name.. " notices if Midnight Moon Gacha never did this, you never would have made it this far!"
							game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
							scrolltext("<"..p.Name.." has earned the Earth Badge! You're ready for the Elite Four!>")
							messageText = p.Name.. " earned the Earth Badge!"
							game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
							scrolltext("Take this Earthquake TM!")
							Math:FuncAddItem("Earthquake", p.Bag["TMs"],1)
							scrolltext("<You got TM Earthquake!>")
							scrolltext("Earthquake is a powerful move for powerful Pokemon, a staple!")
							scrolltext("There is a cave called Victory Road west of here... that's your next destination.")
							Math:AwardBadge(8)
							_G.progress["GiovanniBoss"] = 2
						elseif blah == "Lose" then 
							healafterbattle()
							main.TeleportScreen.Visible = true
							p.Character:WaitForChild("HumanoidRootPart").Anchored = true
							local area = "Viridian City"
							game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
							local hit,pos
							repeat 
								local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
								task.wait(.25)
							until hit and game.Workspace.WhitedOut:FindFirstChild(area)
							p.Character:WaitForChild("HumanoidRootPart").Anchored = false
							main.TeleportScreen.Visible = false
							p.Character.Humanoid.WalkSpeed = 16
							task.wait(.05)

						end
					else
						scrolltext("...You're just better than me.")
						scrolltext("Having lost, I cannot face my followers. I have betrayed their trust. I'm disbanding Team Rocket.")
						scrolltext("And... here. The Earth Badge!")
						local messageText = p.Name.. " earned the Earth Badge!"
						game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
						scrolltext("<"..p.Name.." has earned the Earth Badge! You're ready for the Elite Four!>")
						scrolltext("There is a cave called Victory Road west of here... that's your next destination.")
						Math:AwardBadge(8)
						_G.progress["GiovanniBoss"] = 2
					end
					p.Character.Humanoid.WalkSpeed = 16
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Viridian City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function()
				scrolltext("Team Rocket is over. Go west of Viridian City...")
				Math:AwardBadge(8)
			end
		}
	},
	["PokeRoulette"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Want a random Pokemon...?")
				scrolltext("Talk to me again if you're interested in \"Pokemon Roulette.\"")
				_G.progress["PokeRoulette"] = 2
			end,
			[2] = function()
				if #p.PokemonParty:GetChildren() > 0 then
					scrolltext("The game automatically saves all your Pokemon after using the Roulette.")
					Signals.Roulette:Fire()
				else
					scrolltext("You need a Pokemon in your party to use the Roulette.")
				end
			end
		}
	},
	["2Million"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("What a special occasion! The game has recently hit 2 million visits.")
				scrolltext("To commemorate this landmark, you can have a Shinifier!!") 
				if p.Bag["Evolution"]:FindFirstChild("Shinifer") then
					p.Bag["Evolution"]:FindFirstChild("Shinifer").Value = p.Bag["Evolution"]:FindFirstChild("Shinifer").Value + 1
				else
					local derp = Instance.new("NumberValue")
					derp.Value = 1
					derp.Name = "Shinifier"
					derp.Parent = p.Bag["Evolution"]
				end
				_G.progress["2Million"] = 2
			end,
			[2] = function()
				scrolltext("Thank you for playing this game!")
			end
		},
	},
	["MewNPC"] = {1,
		["Events"] = {
			[1] = function()
				if p.UserId >= 1 then
					scrolltext("I give out Mews to some people!")
					scrolltext("You need to meet two requirements.")
					scrolltext("You need the \"Mew\" Gamepass and less than 6 Pokemon in your party.")
					if #p.PokemonParty:GetChildren() < 6 and p.MewVIP.Value == true then 
						scrolltext("You meet all requirements. Here, take this Mew!")
						scrolltext("<You got a Mew!>")
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Mew")
						--Pokedex:Create("Mew",true)
						_G.progress["MewNPC"] = 2
					elseif p.MewVIP.Value == true then
						scrolltext("You have the gamepass, but you have a full party! Come back when you don't!")
					else
						scrolltext("You don't meet the requirements. Sorry!")
						scrolltext("If you DO have the Mew gamepass, try leaving and re-entering the game.")
					end
				else 
					scrolltext("This feature is locked for Guests. Make an account!")
				end
			end,
			[2] = function()
				scrolltext("Thanks for supporting the game!")
			end
		},
	},
	["AshNPC"] = {1,
		["Events"] = {
			[1] = function()
				if p.UserId >= 1 then
					scrolltext("I give out AshGreninja to some people!")
					scrolltext("You need to meet two requirements.")
					scrolltext("You need the \"AshGreninja\" Gamepass and less than 6 Pokemon in your party.")
					if #p.PokemonParty:GetChildren() < 6 and p.AshVIP.Value == true then 
						scrolltext("You meet all requirements. Here, take this AshGreninja!")
						scrolltext("<You got a Ash Greninja!>")
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "AshGreninja")
						--	Pokedex:Create("AshGreninja",true)
						_G.progress["AshNPC"] = 2
					elseif p.AshVIP.Value == true then
						scrolltext("You have the gamepass, but you have a full party! Come back when you don't!")
					else
						scrolltext("You don't meet the requirements. Sorry!")
						scrolltext("If you DO have the AshGreninja gamepass, try leaving and re-entering the game.")
					end
				else 
					scrolltext("This feature is locked for Guests. Make an account!")
				end
			end,
			[2] = function()
				scrolltext("Thanks for supporting the game!")
			end
		},
	},
	["GerbilNPC"] = {1,
		["Events"] = {
			[1] = function()
				if  p.UserId >= 1 then
					scrolltext("I give out legendary dogs to some people!")
					scrolltext("The legendary dogs are: Raikou, Entei, Suicune, and I'll give you a random one!")
					scrolltext("You need to meet two requirements.")
					scrolltext("You need the \"Other Legendary 10x\" Gamepass and less than 6 Pokemon in your party.")
					if #p.PokemonParty:GetChildren() < 6 and p.OtherLegendary.Value == true then 
						scrolltext("You meet all requirements. Here, take this Pokemon!!")
						local gerbils = {"Raikou","Entei","Suicune"}
						local gselect = gerbils[math.random(1,#gerbils)]

						scrolltext("<You got a "..gselect.."!>")
						scrolltext("Hopefully my "..gselect.." is what you wanted :P")
						local pokemonName = gselect
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.DogHack:InvokeServer(pokemonName)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty,gselect)
						Pokedex:Create(gselect,true)
						_G.progress["GerbilNPC"] = 2
					elseif  p.OtherLegendary.Value == true then
						scrolltext("You have the gamepass, but you have a full party! Come back when you don't!")
					else
						scrolltext("You don't meet the requirements. Sorry!")
						scrolltext("If you DO have the required gamepass, try leaving and re-entering the game.")
					end
				else 
					scrolltext("This feature is locked for Guests. Make an account!")
				end
			end,
			[2] = function()
				scrolltext("Thanks for supporting the game!")
			end
		},
	},
	["FortuneTeller"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("I just have a feeling that "..game.ReplicatedStorage:WaitForChild("RarePokemonSpawn").Value.." has rare Pokemon!")
				point(model)
				scrolltext("These hunches change frequently, so YOU should come back in a couple of minutes!")
			end,
		},
	},
	["ArticunoNPC"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Well well... a determined soul, treading so far down the path.")
				scrolltext("Prove your worth, and perhaps... a chilling little surprise will find its way to you.")
			end,
		},
	},
	["Lorelei"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("Welcome to the Pokemon League. I am Lorelei of the Elite Four.")
				scrolltext("No one can best me when it comes to icy Pokemon. Your Pokemon will be at my mercy!")
				laugh(model)
				scrolltext("Haha, the Pokemon league really allows anyone in nowadays, don't they?")
				scrolltext("Let's begin the battle!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(workspace.Lorelei.Pokemon)
				local blah =_G.BattleInitiate("Elite Four","Lorelei","...","...","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0

					local valget = game.ReplicatedStorage:WaitForChild("REvents").Internal.jxbf:InvokeServer()

					scrolltext("You have gained $"..valget.." for winning!")
					scrolltext("Wow, you're pretty strong!")
					bow(model)
					scrolltext("I apologize for underestimating you.")
					scrolltext("However, I am only the first test.")
					scrolltext("Say hello to Bruno for me!")
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = Vector3.new(6284.36, 36.493, -34427.426)
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
					task.wait(1)
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit 
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--				local badge = Instance.new("IntValue",p.Badges)
					--				badge.Name = 1
					--				p.Character.Humanoid.WalkSpeed = 16
					--				_G.progress["Brock"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Bruno"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("I am Bruno of the Elite Four.")
				scrolltext("Through rigorous training, people and Pokemon can become stronger!")
				scrolltext("I've weight trained with my Pokemon!")
				cheer(model)
				scrolltext("We will grind you down with our superior power! Hoo hah!!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(workspace.Bruno.Pokemon)
				local blah =_G.BattleInitiate("Elite Four","Bruno","...","...","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					local valget = game.ReplicatedStorage:WaitForChild("REvents").Internal.jxbf:InvokeServer()
					scrolltext("You have gained $"..valget.." for winning!")
					scrolltext("What? How could I lose?")
					scrolltext("My job is done here!")
					scrolltext("...you have to fight that witch... good luck! ")
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = Vector3.new(3737.491, 41.435, 1005.533)
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
					task.wait(1)
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit 
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--				local badge = Instance.new("IntValue",p.Badges)
					--				badge.Name = 1
					--				p.Character.Humanoid.WalkSpeed = 16
					--				_G.progress["Brock"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Spring"] = {1,
		["Events"] = {
			[1] = function()
				p.Character.Humanoid.WalkSpeed = 0
				scrolltext("Surprised to see me here?")
				scrolltext("I am Spring of the Elite Four.")
				scrolltext("You know, I'm only here because Agatha died last year!!!!!!!!")
				scrolltext("You might want to turn back.... No? Then prepare to see my true powers!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(workspace.Spring.Pokemon)
				local blah =_G.BattleInitiate("Elite Four","Spring","...","...","PurpleInside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					local valget = game.ReplicatedStorage:WaitForChild("REvents").Internal.jxbf:InvokeServer()
					scrolltext("You have gained $"..valget.." for winning!")
					scrolltext("What?")
					scrolltext("No! This is impossible! I can't lose to you!")
					scrolltext("I worked so hard training this team to the max for you! And I lost! Anyways, good match!")
					scrolltext(" . . . ")
					scrolltext("You're now the Pokemon League champion...")
					scrolltext("Or you would have been, but you have one more challenge ahead!")
					scrolltext("His name is... Gary! He beat the Elite Four before you!")
					scrolltext("Good luck!")
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = Vector3.new(-1445.359, -357.1, 628.869)
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
					task.wait(1)
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit 
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--				local badge = Instance.new("IntValue",p.Badges)
					--				badge.Name = 1
					--				p.Character.Humanoid.WalkSpeed = 16
					--				_G.progress["Brock"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Lance"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				point(model)
				scrolltext("Ah, I heard about you, "..p.Name.. "! I am the third of the Elite Four!")
				scrolltext("You can call me Lance the dragon trainer!")
				scrolltext("Dragon Pokemon are mythical creatures, hard to raise, but their powers are superior!")
				scrolltext("They're virtully indestructible! Are you ready to lose?")
				scrolltext("Your league challenge ends here, "..p.Name.."!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.Lance.Pokemon)		

				local blah =_G.BattleInitiate("Elite Four","Lance","...","...","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					local valget = game.ReplicatedStorage:WaitForChild("REvents").Internal.jxbf:InvokeServer()
					scrolltext("You have gained $"..valget.." for winning!")
					scrolltext("That's it! I hate to admit it, but you're a Pokemon master!")
					cheer(model)
					scrolltext("Good job!!!!!!!!")
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = Vector3.new(5973.281, 14.45, -6000)

					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
					task.wait(1)
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit 
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--				local badge = Instance.new("IntValue",p.Badges)
					--				badge.Name = 1
					--				p.Character.Humanoid.WalkSpeed = 16
					--				_G.progress["Brock"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["ChampionGary"] = {1,
		["Events"] = {
			[1] = function(model)
				p.Character.Humanoid.WalkSpeed = 0
				point(model)
				scrolltext("Hey, I was looking forward to seeing you, "..p.Name.."!")
				scrolltext("While working on my Pokedex, I looked all over for powerful Pokemon!")
				scrolltext("Not only that, I constructed teams that would beat any Pokemon type!")
				scrolltext("And now, I, Gary, am the Pokemon Champion! You know what that means, "..p.Name.."?")
				cheer(model)
				scrolltext("I'm the most powerful trainer in the world, thanks to the Midnight Moon Gacha kid!")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.ChampionGary.Pokemon)
				local blah =_G.BattleInitiate("Champion","Gary","...","...","Inside")
				--p.Character.Humanoid.WalkSpeed = 0
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					p.Character.Humanoid.WalkSpeed = 0
					local valget = game.ReplicatedStorage:WaitForChild("REvents").Internal.jxbf:InvokeServer("Gary")
					scrolltext("You have gained $"..valget.." for winning!")
					scrolltext("W- W- W- W- Wha- What???")
					scrolltext("After all that work to get here... my reign is over? It's not fair!")
					scrolltext("Why? Why did I lose? I never made any mistakes raising my Pokemon...")
					scrolltext("I hate to admit it, but you're the new Pokemon Champion!")
					if p.UserId > 0 and p.Badges:FindFirstChild("Champ") then
						scrolltext("You beat me again... wow... I am really pathetic.")
					else
						scrolltext("I guess I'll be doing the honors.")
						point(model)
						scrolltext("Since you beat me, you get a cool Shinifier.")
						scrolltext("AND not only that, you get this cool memorial plaque!")
						scrolltext("<Gary gave you the Shinifier and the memorial plaque.>")
						scrolltext("Reminder By Midnight: The game isn't over! New Pokemon love that plaque! You'll be able to find more Pokemon with that!")
						local messageText = p.Name.. " has beaten the Champion!"
						game.ReplicatedStorage:WaitForChild("ChatEvent"):FireServer(messageText, "text", "server")
						Math:AwardBadge("Champ")
						p.Character.Humanoid.WalkSpeed = 16			
						--				if p.Bag["Evolution"]:FindFirstChild("Shinifier") then
						--				p.Bag["Evolution"]:FindFirstChild("Shinifier").Value = p.Bag["Evolution"]:FindFirstChild("Shinifer".Value + 1) 
						--				else
						--				local derp = Instance.new("NumberValue")
						--				derp.Value = 1
						--				derp.Name = "Shinifier"
						--				derp.Parent = p.Bag["Evolution"]
						--				end
					end
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					task.wait(1)
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--				local badge = Instance.new("IntValue",p.Badges)
					--				badge.Name = "Champ"
					--				p.Character.Humanoid.WalkSpeed = 16
					--				_G.progress["Brock"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*100) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["E4Enterer"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Oh, you're new here!")
				scrolltext("Let's see if you have all 8 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = false,
					["7"] = false,
					["8"] = false
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have all 8 badges!")
					scrolltext("You can now use the Taxi to teleport to the Indigo Plateau!")
					scrolltext("If you want, you can do the Elite Four challenge by talking to me again!")
					Math:AwardBadge("Indigo")			
					_G.progress["E4Enterer"] = 2
				else
					scrolltext("You don't have all 8 badges. BUT! Midnight Moon Gacha can fix that!")
				end
			end,
			[2] = function()
				if not p:WaitForChild("Badges"):FindFirstChild("Indigo") then
					scrolltext("Now wait a second here, I would have sworn I let you fast travel here!")
					scrolltext("I'm so sorry! You are all set now!")
					Math:AwardBadge("Indigo")
					return
				end
				scrolltext("Hope you're ready for this!")
				scrolltext("You have to defeat the Elite Four. And you won't get access to a PokeCenter.")
				scrolltext("Lastly, you have to beat the Elite Four in one sitting.")
				scrolltext("I wish you good luck!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(2385.401, 33.57, -6344.3)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},
	["VRoadChecker"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have all 8 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = false,
					["7"] = false,
					["8"] = false
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have all 8 badges!")
					scrolltext("To enter, just talk to me again.")
					scrolltext("To leave, talk to the Taxi Driver at the end of the cave.")
					_G.progress["VRoadChecker"] = 2
				else
					scrolltext("You don't have all 8 badges. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(9560.501, 241.91, 1204.8)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},
	["Spiritomb2"] = {1,
		["Events"] = {
			[1] = function()
				if p.Badges:FindFirstChild("Champ") then
					scrolltext("Wow, you're the Pokemon League Champion.")
					scrolltext("Fight this wild Spiritomb for me.")
					_G.progress["Spiritomb"] = 2
					_G.InWild = true
					_G.PiayingCheckers("normal","Spiritomb",p.OppPokemon,80,false)
					local blah = _G.BattleInitiate(nil,nil,"You have won the battle!",p.Name.." has no Pokemon! "..p.Name.." blacked out!","PurpleInside")							
					repeat task.wait() until blah ~= nil
					_G.InWild = false
					if blah == "Win" then
						task.wait(1.4)
						_G.debtalk = false
						return
					elseif blah == "Lose" then
						healafterbattle()
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Lavender Town"].Position + Vector3.new(0,5,0))
						_G.debtalk = false
					end
				else
					scrolltext("Come back when you're the best trainer in the world.")
				end
			end,
			[2] = function()
				scrolltext("Nice, I guess.")
			end
		}
	},
	["HoopaUnbound"] = {1,
		["Events"] = {
			[1] = function()
				if p.Badges:FindFirstChild("Champ") then
					scrolltext("Wow, you're the Pokemon League Champion.")
					scrolltext("Fight this wild Hoopa-Unbound for me.")
					_G.progress["Hoopa-Unbound"] = 2
					_G.InWild = true
					_G.PiayingCheckers("normal","Hoopa-Unbound",p.OppPokemon,95,false)
					local blah = _G.BattleInitiate(nil,nil,"You have won the battle!",p.Name.." has no Pokemon! "..p.Name.." blacked out!","PurpleInside")							
					repeat task.wait() until blah ~= nil
					_G.InWild = false
					if blah == "Win" then
						task.wait(1.4)
						_G.debtalk = false
						return
					elseif blah == "Lose" then
						healafterbattle()
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(workspace.WhitedOut["Pewter City"].Position + Vector3.new(0,5,0))
						_G.debtalk = false
					end
				else
					scrolltext("Come back when you're the best trainer in the world.")
				end
			end,
			[2] = function()
				scrolltext("You're really powerful !")
			end
		}
	},
	["StatsJudge"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("You can call me the Judge.  That's actually not my real name, but it's what everyone calls me.")
				scrolltext("It's because of this weird power I have. It's a gift, really.")
				scrolltext("I can discern--or judge, you might say--the overall potential of individual pokemon.")
				scrolltext("How about it? Let me judge the potential of your Pokemon!")
				_G.progress["StatsJudge"] = 2
			end,
			[2] = function()
				if p:WaitForChild("Badges"):FindFirstChild("Champ") and not game:GetService("MarketplaceService"):PlayerOwnsAsset(p,316840779) then
					Math:AwardBadge("Champ")
				elseif not p:WaitForChild("Badges"):FindFirstChild("Champ") and game:GetService("MarketplaceService"):PlayerOwnsAsset(p,316840779)  then
					Math:AwardBadge("Champ")
				end
				scrolltext("I'm going to judge the first Pokemon in your Party...")
				local judgedpokemon = findlead()
				scrolltext("Hmm, it's a "..judgedpokemon.Name.."?")
				local ivs = 0
				local higheststat = 0
				local statstring = nil
				for i,v in ipairs(judgedpokemon.IV:GetChildren()) do
					ivs = ivs + v.Value
					if v.Value > higheststat then
						higheststat = v.Value
						statstring = v.Name
					end
				end
				local str = nil
				if ivs <= 90 then
					str = "average"
				elseif ivs > 90 and ivs <= 120 then
					str = "above average"
				elseif ivs > 120 and ivs <= 150 then
					str = "relatively superior"
				else 
					str = "outstanding"
				end
				scrolltext("This Pokemon's potential is "..str.." overall.")
				if statstring == nil then
					scrolltext("This Pokemon has no potential whatsoever!")
				else
					local stat = {["HPIV"] = "HP",
						["AtkIV"] = "Attack",
						["DefIV"] = "Defense",
						["SpeedIV"] = "Speed",
						["SpDIV"] = "Special Defense",
						["SpAIV"] = "Special Attack",
					}

					scrolltext("Incidentally, I would say its greatest potential lies in its "..stat[statstring]..".")
					for i,v in ipairs(judgedpokemon.IV:GetChildren()) do
						if v.Name ~= statstring and v.Value == higheststat then
							scrolltext("But its "..stat[v.Name].." is equally as good.")
						end
					end
					if higheststat <= 10 then
						scrolltext("To be honest, it has pretty bad stats. That's how I judge it.")
					elseif higheststat > 10 and higheststat <= 15 then
						scrolltext("Its stats are so-so. I've seen better, but I've seen worse. That's how I judge it.")
					elseif higheststat > 15 and higheststat <= 25 then
						scrolltext("Its definitely got some good stats. That's how I judge it.")
					elseif higheststat > 25 and higheststat <= 30 then
						scrolltext("This Pokemon has some fantastic stats. That's how I judge it.")
					else
						scrolltext("These stats...! Stats like those, they cannot be beat. That's how I judge it.")
					end
				end
			end
		}
	},	
	["RegiChecker"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Bring me the lords of rock, ice, and steel, and you shall be rewarded...")
				if p.PokemonParty:FindFirstChild("Registeel") and p.PokemonParty:FindFirstChild("Regice") and p.PokemonParty:FindFirstChild("Regirock")   then
					if #p.PokemonParty:GetChildren() < 6  then
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.RegiCheck:InvokeServer()
						cheer(model)
						scrolltext("Here... take this Regigigas... you've earnt it.")
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Regigigas")
						_G.progress["RegiChecker"] = 2
					else
						scrolltext("You have a full party...")
					end
				else
					scrolltext("You do not have all 3 lords in your party...")
				end

			end,
			[2] = function()
				scrolltext("...")
			end
		}
	},
	["OakHeatran"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Oh, hey, "..p.Name..", didn't expect to see you here!")
				scrolltext("I was just searching for rare Pokemon in my spare time.")
				scrolltext("Standing still in Pallet Town is really boring, if you know what I mean.")
				scrolltext("In fact, if you have 300 or more Pokedex entries, I'll give you a cool Pokemon.")
				local t = 0
				for i,v in ipairs(p.Pokedex:GetChildren()) do 
					if v.Caught.Value == true then
						t = t + 1
					end
				end
				if  t >= 300 then
					if #p.PokemonParty:GetChildren() < 6  then
						cheer(model)
						scrolltext("Wow! "..t.." Pokedex entries!?")
						scrolltext("You deserve this EXTREMELY rare Heatran. You can only get this from me!")
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Heatran")
						_G.progress["OakHeatran"] = 2
					else
						scrolltext("You have a full party...")
					end
				else
					scrolltext("Eh, "..t.." Pokemon is sort of close to 300.")
					scrolltext("See me again when you have 300 Pokedex entries.")
				end

			end,
			[2] = function()
				scrolltext("...")
			end
		}
	},
	["KaitoNecrozma"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Oh, hey, "..p.Name..", didn't expect to see you here!")
				scrolltext("I was just searching for rare Pokemon in my spare time.")
				scrolltext("Standing still here gets really boring, if you know what I mean.")
				scrolltext("In fact, if you have 600 or more Pokedex entries, I'll give you a cool Pokemon.")
				local t = 0
				for i,v in ipairs(p.Pokedex:GetChildren()) do 
					if v.Caught.Value == true then
						t = t + 1
					end
				end
				if  t >= 600 then
					if #p.PokemonParty:GetChildren() < 6  then
						cheer(model)
						scrolltext("Wow! "..t.." Pokedex entries!?")
						scrolltext("You deserve this EXTREMELY rare Necrozma. You can only get this from me!")
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Necrozma")
						_G.progress["KaitoNecrozma"] = 2
					else
						scrolltext("You have a full party...")
					end
				else
					scrolltext("Eh, "..t.." Pokemon is sort of close to 600.")
					scrolltext("See me again when you have 600 Pokedex entries.")
				end

			end,
			[2] = function()
				scrolltext("...")
			end
		}
	},
	["EVChecker"] = {1,
		["Events"] = {
			[1] = function(model)
				cheer(model)
				scrolltext("Welcome back! I am so glad to see you!")
				scrolltext("I can check your Pokemon's innate stats.")
				_G.EVChecker()
			end
		}	
	},
	["ElegantValleyTP"] = {1,
		["Events"] = {
			[1] = function(model)
				local choice 
				if not p:WaitForChild("Badges"):FindFirstChild("Elegant Valley") then
					Math:AwardBadge("EV")
				end
				scrolltext("I created this cool place called Elegant Valley, do you want to go to it?",true)
				sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true
					cheer(model)
					scrolltext("Hurray! Taking you there now.")
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations["Elegant Valley"]+Vector3.new(0,5,0))
					local area = Vector3.new(locations["Elegant Valley"])
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(Vector3.new(-9139.74, 113.09, 806.04) + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit 
					main.TeleportScreen.Visible = false

					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					choice = true
				end)
				sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true
					scrolltext("Well, okay then. It will always be available to you.")
					choice = true
				end)	
				p.Character.Humanoid.WalkSpeed = 0
				speech.Parent.popup.Yes.Visible = true speech.Parent.popup.Visible = true
				speech.Parent.popup.No.Visible = true
				menu.Visible = false
				repeat task.wait() until choice 		
			end
		},
	},
	["PokeSwarm"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("A swarm of "..game.ReplicatedStorage:WaitForChild("SwarmPokemon").Value:reverse().." has showed up in "..game.ReplicatedStorage:WaitForChild("SwarmLocation").Value.."!")
				scrolltext("Go to "..game.ReplicatedStorage:WaitForChild("SwarmLocation").Value..", as there is rare Pokemon showing up there! 1/5 chance to encounter!")
				scrolltext("This report changes every 10 minutes, so come back later to see what other swarms are going on!")							
			end
		},
	},
	["Fridge"] = {1,
		["Events"] = {
			[1] = function()
				local rotomfound = false	
				local newmove = "Blizzard"
				for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
					if yourpokeout.Name:find(string.reverse("motoR")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout) then
						rotomfound = true

						Math:RotomChange(yourpokeout,"Rotom-Frost",newmove)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout)

					end
				end
				if rotomfound == true then
					scrolltext("All your Rotom have been converted into Rotom-Frost.")
				else
					scrolltext("This is a nice fridge.")
				end							
			end
		},
	},
	["LawnMower"] = {1,
		["Events"] = {
			[1] = function()
				local rotomfound = false	
				local newmove = "Leaf Storm"
				for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
					if yourpokeout.Name:find(string.reverse("motoR")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout) then
						rotomfound = true
						Math:RotomChange(yourpokeout,"Rotom-Mow",newmove)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout)

					end
				end
				if rotomfound == true then
					scrolltext("All your Rotom have been converted into Rotom-Mow.")
				else
					scrolltext("This is an environment friendly lawn mower.")
				end							
			end
		},
	},
	["Fan"] = {1,
		["Events"] = {
			[1] = function()
				local rotomfound = false	
				local newmove = "Air Slash"
				for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
					if yourpokeout.Name:find(string.reverse("motoR")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout) then
						rotomfound = true
						Math:RotomChange(yourpokeout,"Rotom-Fan",newmove)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout)

					end
				end
				if rotomfound == true then
					scrolltext("All your Rotom have been converted into Rotom-Fan.")
				else
					scrolltext("This is a fan so sharp it could cut off your fingers! Wow!")
				end							
			end
		},
	},
	["Washer"] = {1,
		["Events"] = {
			[1] = function()
				local rotomfound = false	
				local newmove = "Hydro Pump"
				for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
					if yourpokeout.Name:find(string.reverse("motoR")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout) then
						rotomfound = true
						Math:RotomChange(yourpokeout,"Rotom-Wash",newmove)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout)

					end
				end
				if rotomfound == true then
					scrolltext("All your Rotom have been converted into Rotom-Wash.")
				else
					scrolltext("This is a washing machine. It'd be nice if you could jump inside it.")
				end							
			end
		},
	},
	["Oven"] = {1,
		["Events"] = {
			[1] = function()
				local rotomfound = false	
				local newmove = "Overheat"
				for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
					if yourpokeout.Name:find(string.reverse("motoR")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout) then
						rotomfound = true
						Math:RotomChange(yourpokeout,"Rotom-Heat",newmove)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout)

					end
				end
				if rotomfound == true then
					scrolltext("All your Rotom have been converted into Rotom-Heat.")
				else
					scrolltext("This is an oven. You could go for some grub right now!")
				end							
			end
		},
	},
	["Radio"] = {1,
		["Events"] = {
			[1] = function()
				local rotomfound = false	
				local newmove = "ThunderShock"
				for _,yourpokeout in ipairs(p.PokemonParty:GetChildren())  do
					if yourpokeout.Name:find(string.reverse("motoR")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout) then
						rotomfound = true
						Math:RotomChange(yourpokeout,"Rotom",newmove)
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.rotomCheck:InvokeServer(yourpokeout)

					end
				end
				if rotomfound == true then
					scrolltext("All your Rotom have left their appliances, becoming regular Rotom.")
				else
					scrolltext("This is a radio. It is pretty useless to possess.")
				end							
			end
		},
	},
	["GiratinaOrigin"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = nil
				local choice
				scrolltext("Bring me either the lord of time or the lord of space and the lord of antimatter...")
				if (p.PokemonParty:FindFirstChild(string.reverse("aglaiD")) or  p.PokemonParty:FindFirstChild(string.reverse("aiklaP"))) and  (p.PokemonParty:FindFirstChild(string.reverse("anitariG")) or  p.PokemonParty:FindFirstChild(string.reverse("O-anitariG"))) then
					scrolltext("You have the necessary Pokemon... I can change your Giratina's form... ",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("Okay... I have changed your Giratina(s)...")
						for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
							if yourpokeout.Name:find(string.reverse("anitariG")) then
								if yourpokeout.Name == string.reverse("anitariG") and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.giratinaCheck:InvokeServer(yourpokeout)  then

									newpokename = string.reverse("O-anitariG")


								elseif yourpokeout.Name == string.reverse("O-anitariG") and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.giratinaCheck:InvokeServer(yourpokeout) then
									newpokename = string.reverse("anitariG") 


								end


								Math:GiratinaChange(yourpokeout,newpokename)
								game.ReplicatedStorage:WaitForChild("REvents").Pokemon.giratinaCheck:InvokeServer(yourpokeout)

							end
						end
						choice = true
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("Okay...")
						choice = true
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false
					repeat task.wait() until choice
				else
					scrolltext("Do not have the necessary Pokemon...")						
				end


			end
		},
	},
	["Meteor4"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = "Deoxys"
				scrolltext("This meteorite looks very normal.")
				if (p.PokemonParty:FindFirstChild(string.reverse("syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("A-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("D-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("S-syxoeD")))   then
					scrolltext("Do you want to change all your Deoxys into normal Deoxys?",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("<Your Deoxys has been changed!>")
						for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
							if yourpokeout.Name:find(string.reverse("syxoeD")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout) then

								Math:DeoxysChange(yourpokeout,"Deoxys")			
								game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout)

							end
						end
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false 
						speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("The meteorite looks sad.")
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false

				end		
			end
		},
	},
	["Meteor1"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = "Deoxys-A"
				scrolltext("This meteorite looks like it destroyed something.")
				if (p.PokemonParty:FindFirstChild(string.reverse("syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("A-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("D-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("S-syxoeD")))   then
					scrolltext("Do you want to change all your Deoxys into Attack forme Deoxys?",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("<Your Deoxys has been changed!>")
						for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
							if yourpokeout.Name:find(string.reverse("syxoeD")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout) then

								Math:DeoxysChange(yourpokeout,"Deoxys-A")
								game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout)


							end
						end
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("The meteorite looks sad.")
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false

				end		
			end
		},
	},
	["Meteor2"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename ="Deoxys-D"
				scrolltext("This meteorite looks like it can withstand anything.")
				if (p.PokemonParty:FindFirstChild(string.reverse("syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("A-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("D-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("S-syxoeD")))   then
					scrolltext("Do you want to change all your Deoxys into Defense forme Deoxys?",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("<Your Deoxys has been changed!>")
						for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
							if yourpokeout.Name:find(string.reverse("syxoeD")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout) then

								Math:DeoxysChange(yourpokeout,newpokename)
								game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout)


							end
						end
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("The meteorite looks sad.")
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false

				end		
			end
		},
	},
	["Meteor3"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = "Deoxys-S"
				scrolltext("This meteorite looks like it hit the atmosphere at blazing speeds.")
				if (p.PokemonParty:FindFirstChild(string.reverse("syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("A-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("D-syxoeD"))) or (p.PokemonParty:FindFirstChild(string.reverse("S-syxoeD")))   then
					scrolltext("Do you want to change all your Deoxys into Speed forme Deoxys?",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("<Your Deoxys has been changed!>")
						for _,yourpokeout in ipairs(p.PokemonParty:GetChildren()) do
							if yourpokeout.Name:find(string.reverse("syxoeD")) and game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout) then

								Math:DeoxysChange(yourpokeout,"Deoxys-S")
								game.ReplicatedStorage:WaitForChild("REvents").Pokemon.deoxysCheck:InvokeServer(yourpokeout)


							end
						end
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("The meteorite looks sad.")
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false

				end		
			end
		},
	},
	["MysteriousGrottoTP"] = {1,
		["Events"] = {
			[1] = function()

				if not p:WaitForChild("Badges"):FindFirstChild("Mysterious Grotto") then
					Math:AwardBadge("Mysterious Grotto")
				end
				scrolltext("A new place has just been discovered... it's called Mysterious Grotto.")
				scrolltext("I'm setting up an expedition, do you want to join?",true)
				local choice
				sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true
					scrolltext("Alright!")
					main.TeleportScreen.BackgroundTransparency = 1
					main.TeleportScreen.Visible = true
					for i = 1,20 do
						main.TeleportScreen.BackgroundTransparency = main.TeleportScreen.BackgroundTransparency - .05
						task.wait()
					end
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true

					local area =locations["Mysterious Grotto"]
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))

					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit  and game.Workspace.WhitedOut:FindFirstChild("Mysterious Grotto")
					main.TeleportScreen.Visible = false

					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					for i = 1,20 do
						main.TeleportScreen.BackgroundTransparency = main.TeleportScreen.BackgroundTransparency + .05
						task.wait()
					end
					main.TeleportScreen.Visible = false
					main.TeleportScreen.BackgroundTransparency = 0
					choice = true
				end)
				sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true
					scrolltext("You can always join the expedition!")
					choice = true
				end)	
				p.Character.Humanoid.WalkSpeed = 0
				speech.Parent.popup.Yes.Visible = true speech.Parent.popup.Visible = true
				speech.Parent.popup.No.Visible = true
				menu.Visible = false
				repeat task.wait() until choice 	
			end
		},
	},
	["HardFight"] = {1,
		["Events"] = {
			[1] = function()	
				if not p.Badges:FindFirstChild("8") then
					scrolltext("[This strange man doesn't seem to notice your presence.]")
				else
					scrolltext("Jg zpv bsfou qsfqbsfe zpv ejf!")
					scrolltext("[This strange man attacks!]")
					game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.HardFight.PossiblePokemon)
					local blah =_G.BattleInitiate("?????","","Vomvdlz","Opu tuspoh fopvhi","Inside")
					repeat task.wait() until blah ~= nil
					if blah == "Win" then

						scrolltext("[The strange man says some gibberish, and gives you a bag of Pokedollars.]")
						p.Character.Humanoid.WalkSpeed = 0

						local valget = Math:Entity("Black")
						scrolltext("You have gained $"..valget.." for winning!")
					elseif blah == "Lose" then
						healafterbattle()
						main.TeleportScreen.Visible = true
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						local area = "Celadon City"
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
						local hit,pos
						repeat 
							local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
							task.wait(.25)
						until hit and game.Workspace.WhitedOut:FindFirstChild(area)
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						main.TeleportScreen.Visible = false
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
				end
			end

		},
	},
	["HardFight2"] = {1,
		["Events"] = {
			[1] = function()	
				if not p.Badges:FindFirstChild("8") then
					scrolltext("Zpv ibwf qpufoujbm.")
					scrolltext("[You didn't understand what the stranger said.]")
				else
					scrolltext("Zpv uijol zpvs tp tuspoh? J xjmm foe zpv!")
					scrolltext("Zpvs kvtu bopuifs ubshfu...")
					scrolltext("[The entity attacks!]")
					game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.HardFight2.PossiblePokemon)
					local blah =_G.BattleInitiate("cptt","gjhiu","Vomvdlz","Opu tuspoh fopvhi","Inside")
					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						scrolltext("Ublf uijt, ju't b cbh pg uijsuz uipvtboe qplfepmmbst.")
						scrolltext("Nbzcf... ofyu ujnf J'mm cf mvdlz...")
						p.Character.Humanoid.WalkSpeed = 0
						local valget = Math:Entity("Purple")
						scrolltext("You have gained $"..valget.." for winning!")
					elseif blah == "Lose" then
						healafterbattle()
						main.TeleportScreen.Visible = true
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						local area = "Viridian City"
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
						local hit,pos
						repeat 
							local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
							task.wait(.25)
						until hit and game.Workspace.WhitedOut:FindFirstChild(area)
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						main.TeleportScreen.Visible = false
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
				end
			end

		},
	},
	["HardFight3"] = {1,
		["Events"] = {
			[1] = function()	
				if sayyes then sayyes:disconnect() end
				if sayno then sayno:disconnect() end
				if not p.Badges:FindFirstChild("8") then
					scrolltext("Zpv ibwf qpufoujbm.")
					scrolltext("[You didn't understand what the stranger said.]")
				elseif not scanMoves({["Calm Mind"] = true,["Nasty Plot"] = true,["Quiver Dance"] = true,["Swords Dance"] = true,["Bulk Up"] = true,["Dragon Dance"] = true}) then
					scrolltext("[The stranger takes a look at you.]")
					scrolltext("Ml Calm Mind, Quiver Dance, Swords Dance, Bulk Up, Nasty Plot, Dragon Dance.")
					scrolltext("[You deduce that the stranger won't battle you if you have those moves.]")
				else
					scrolltext("Zpv nbz ibwf efgfbufe nz cspuifst, cvu J xpo'u mptf!")
					scrolltext("Zpv nbz bcvtf uif evnc AI, cvu hppe mvdl!")
					scrolltext("[The stranger attacks!]")
					game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.HardFight3.PossiblePokemon)
					local blah =_G.BattleInitiate("/_/","","Vomvdlz","Opu tuspoh fopvhi","Inside")
					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						scrolltext("J'n hjwjoh zpv b Pachirisu.")
						scrolltext("[Even though it's still gibberish, you can tell that it wants to give you a Pachirisu.]")
						scrolltext("[Accept the Pachirisu?]",true)
						sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
							speech.Parent.popup.Yes.Visible = false 
							speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							speech.Parent.Next.Visible = true
							local prisoner = _G.PiayingCheckers("normal",string.reverse("usirihcaP"),p.PlayerGui,30,true)
							if #p.PokemonParty:GetChildren() < 6 then
								Math:SwapParty(prisoner,#p.PokemonParty:GetChildren() + 1)
								Math:ParentChange(prisoner,p.PokemonParty)
								scrolltext(prisoner.Name.." was added to the Party.")
							else
								local newbox,number = findbox()
								if newbox ~= false then
									scrolltext(prisoner.Name.." was sent to "..newbox..".")
									Math:SwapParty(prisoner,number)
									Math:ParentChange(prisoner, p.PC[newbox])
								else
									scrolltext("You have no room for more Pokemon.")
								end
							end
						end)
						sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
							speech.Parent.Next.Visible = true
							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							scrolltext("[You can rebattle this entity.]")
						end)	
						p.Character.Humanoid.WalkSpeed = 0
						speech.Parent.popup.Yes.Visible = true 
						speech.Parent.popup.Visible = true
						speech.Parent.popup.No.Visible = true
						menu.Visible = false

					elseif blah == "Lose" then
						healafterbattle()
						main.TeleportScreen.Visible = true
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						local area = "Viridian City"
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
						local hit,pos
						repeat 
							local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
							task.wait(.25)
						until hit and game.Workspace.WhitedOut:FindFirstChild(area)
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						main.TeleportScreen.Visible = false
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
				end
			end

		},
	},
	["BattleTower"] = {1,
		["Events"] = {
			[1] = function(model)
				bow(model)	
				scrolltext("Welcome to the Battle Tower, where you do 3v3 battles!")
				scrolltext("You'll pick 3 Pokemon from your party, and then you will battle 5 random trainers in a row.")
				scrolltext("If you win, you get Battle Points, or BP, which can be used to buy a variety of prizes!")
				scrolltext("Last but not least, you cannot use certain Pokemon in the Battle Tower, nor can you use items.")
				scrolltext("Talk to me again if you want to participate!")
				_G.progress["BattleTower"] = 2
			end,
			[2] = function(model)
				bow(model)
				scrolltext("Do you want to participate in the Battle Tower? Your current streak is "..Streak..".", true)

				sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false 
					speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true

					if #p.PokemonParty:GetChildren() >= 3 then
						scrolltext("Pick 3 Pokemon that you will use at the Battle Tower.")
						scrolltext("The Pokemon that you battle will either be level 50 or the highest level Pokemon, whichever one is higher.")
						scrolltext("Some Pokemon and the item Focus Sash are not allowed at the Battle Tower.")

						local Done, Poke1, Poke2, Poke3 = _G.BattleTowerSelectPoke()
						repeat task.wait() until Done

						if Done == "Close" then
							scrolltext("We hope to see you again.")
						else

							-- Send the selected Pokémon to the server to create the new battle party
							battleTowerCreate:FireServer(Poke1, Poke2, Poke3)

							scrolltext("The Pokemon you selected are "..nickname(Poke1)..", "..nickname(Poke2)..", and "..nickname(Poke3).."!")
							scrolltext("Let's start! :3")

							local lose = false
							for num = 1, 5 do
								local randtrainer = trainers[math.random(1, #trainers)]
								local randname = names[math.random(1, #names)]
								local Poke1, Poke2, Poke3 = _G.GetBattleTowerTeam(Streak)

								_G.PiayingCheckers("normal",Poke1, p.OppPokemon, math.max(50, findhighestlevel()), true, true)
								_G.PiayingCheckers("normal",Poke2, p.OppPokemon, math.max(50, findhighestlevel()), true, true)
								_G.PiayingCheckers("normal",Poke3, p.OppPokemon, math.max(50, findhighestlevel()), true, true)

								local blah = _G.BattleInitiate(randtrainer, randname, "I am Trainer "..num..".", "You beat "..(num-1).." Trainers.", BattleGrounds[math.random(#BattleGrounds)], "Wow.")
								repeat task.wait() until blah ~= nil
								p.Character.Humanoid.WalkSpeed = 0
								healafterbattle()

								if blah == "Win" then
									scrolltext("Nice!")
								elseif blah == "Lose" then
									lose = true
									break
								end
							end

							-- Remove the temporary Battle Tower party and restore original
							battleTowerRemove:FireServer()

							if lose then
								scrolltext("You lost. Better luck next time.")
								scrolltext("Streak reset to 0.")
								Streak = 0
							else
								local OS = Streak
								Streak = Streak + 1
								scrolltext("Good job on winning! You're now on a "..Streak.." Streak!")

								local BPwon = OS + 3
								if BPwon > 300 then
									BPwon = 300
								end
								scrolltext("For winning, you get "..BPwon.." BP!")

								Math:BPChange(BPwon)
							end

							p.Character.Humanoid.WalkSpeed = 16
						end
					else
						scrolltext("Sorry, you need 3 Pokemon in your party to partake in the Battle Tower.")
					end
				end)

				sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
					speech.Parent.Next.Visible = true
					speech.Parent.popup.Yes.Visible = false
					speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					scrolltext("We hope to see you again.")
				end)

				p.Character.Humanoid.WalkSpeed = 0
				speech.Parent.popup.Yes.Visible = true 
				speech.Parent.popup.Visible = true
				speech.Parent.popup.No.Visible = true
				menu.Visible = false
			end
		}
	},
	["BPItemShop"]  = {1,
		["Events"] ={
			[1] = function(model)
				bow(model)
				scrolltext("Welcome to the BP Item Shop, where you can trade BP for items!")
				_G.BPItemShop()
			end
		}
	},
	["BPTMShop"]  = {1,
		["Events"] ={
			[1] = function(model)
				bow(model)
				scrolltext("Welcome to the BP TM Shop, where you can trade BP for TMs!")
				_G.BPTMShop()
			end
		}
	},
	["HardFight4"] = {1,
		["Events"] = {
			[1] = function()	
				if not p.Badges:FindFirstChild("8") then
					scrolltext("Zpv ibwf qpufoujbm.")
					scrolltext("[You didn't understand what the stranger said.]")
				else
					scrolltext("Zpv... gpvoe nf... Op jufnt bmmpxfe.")
					scrolltext("Jg zpv'sf sfbmmz tuspoh, zpv dbo cfbu nf xjuipvu vtjoh jufnt.")
					scrolltext("[You have a feeling you can't use items against this stranger.]")
					scrolltext("[The stranger attacks!]")
					game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.HardFight4.PossiblePokemon)
					local blah =_G.BattleInitiate("Dzuifvs","","Vomvdlz","Opu tuspoh fopvhi","Inside","Wow")
					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						scrolltext("J xjmm hjwf zpv Dark Pulse TM.")
						scrolltext("[Even though it's still gibberish, you can tell that it's going to give you the TM Dark Pulse.")
						scrolltext("<You Got TM Dark Pulse!>")
						Math:FuncAddItem("Dark Pulse", p.Bag["TMs"],1)
						scrolltext("[The entity tries its hardest to speak the next few words...]")
						scrolltext("Me battle no more.")
						_G.progress["HardFight4"] = 2
					elseif blah == "Lose" then
						healafterbattle()
						main.TeleportScreen.Visible = true
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						local area = "Mysterious Grotto"
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
						local hit,pos
						repeat 
							local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
							task.wait(.25)
						until hit and game.Workspace.WhitedOut:FindFirstChild(area)
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						main.TeleportScreen.Visible = false
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
				end
			end,
			[2] = function()
				scrolltext("[Silence.]")
			end
		}
	},
	["RestTM"]  = {1,
		["Events"] ={
			[1] = function()
				scrolltext("Zzzz... huh?")
				scrolltext("Oh... thanks for waking me up. I was about to fall.")
				scrolltext("...Hmm. I'll guess I'll give you this.")
				Math:FuncAddItem("Rest", p.Bag["TMs"],1)
				scrolltext("<You Got TM Rest!>")
				scrolltext("Rest is a move, that when used, heals your Pokemon. But it causes your Pokemon to sleep.")
				scrolltext("Perfect move for defensive Pokemon who don't mind going to sleep for a couple of turns.")
				_G.progress["RestTM"] = 2
			end,
			[2] = function()
				scrolltext("Zzz...")
			end
		}
	},
	["SurfTM"]  = {1,
		["Events"] ={
			[1] = function()
				scrolltext("Wow, you're an expert swimmer!")
				scrolltext("You should let your Pokemon out using this!")
				Math:FuncAddItem("Surf", p.Bag["TMs"],1)
				scrolltext("<You Got TM Surf!>")
				scrolltext("Surf is a powerful Water type move that has no secondary effect.")
				scrolltext("It's so reliable, it's perfect!")
				_G.progress["SurfTM"] = 2
			end,
			[2] = function()
				scrolltext("Surf's up!")
			end
		}
	},
	["BrockCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Rock Slide"
				local trainer = "Brock"
				local modal = "BrockCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(workspace[modal].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["MistyCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Scald"
				local trainer = "Misty"
				local modal = "MistyCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["SurgeCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Thunderbolt"
				local trainer = "Lt. Surge"
				local modal = "SurgeCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)		
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["ErikaCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Giga Drain"
				local trainer = "Erika"
				local modal = "ErikaCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["KogaCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Dazzling Gleam"
				local trainer = "Koga"
				local modal = "KogaCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)		
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["SabrinaCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Psychic"
				local trainer = "Sabrina"
				local modal = "SabrinaCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["BlaineCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Flamethrower"
				local trainer = "Blaine"
				local modal = "BlaineCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)		
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["GiovanniCave"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Stone Edge"
				local trainer = "Giovanni"
				local modal = "GiovanniCave"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[modal].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I have been training to rebattle you...")
				scrolltext("I won't lose this time! Good luck!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really too strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Falkner"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Roost"
				local trainer = "Falkner"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Bugsy"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "X-Scissor"
				local trainer = "Bugsy"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Whitney"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Swords Dance"
				local trainer = "Whitney"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)		
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Morty"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Shadow Ball"
				local trainer = "Morty"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Chuck"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Bulk Up"
				local trainer = "Chuck"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Jasmine"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Flash Cannon"
				local trainer = "Jasmine"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Pryce"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Ice Beam"
				local trainer = "Pryce"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)		
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["Clair"]  = {1,
		["Events"] ={
			[1] = function()
				local TMaward = "Dragon Pulse"
				local trainer = "Clair"
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace[trainer].Pokemon)
				scrolltext("I am "..trainer.."!")
				scrolltext("I come from Johto, looking to battle strong trainers!")
				scrolltext("Are you strong? Let's see!")
				local blah =_G.BattleInitiate(trainer,"","...","...","Cave")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You are really strong...")
					if not p.Bag.TMs:FindFirstChild(TMaward) then
						scrolltext("I will give you TM "..TMaward..".")
						Math:FuncAddItem(TMaward, p.Bag["TMs"],1)
						scrolltext("<You got TM "..TMaward.."!>")
						scrolltext("I'll battle you again, or you can wait tomorrow... another person will be here.")
					end
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Elegant Valley"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
		}
	},
	["NatureChanger"] = 
		{1,
			["Events"] = {
				[1] = function(model)
					laugh(model)
					scrolltext("Hey, person. I am mad scientist! It's so cool! Haha.")
					scrolltext("I am working on something revolutionary... I can change a Pokemon's personality.") 
					scrolltext("With this experiment, you can change one of your Pokemon's nature to whatever you want.")
					scrolltext("If you didn't know, a Pokemon's nature affects the inherent stats of a Pokemon.")

					if p.Money.Value >= 100000 then
						scrolltext("Since the material for this experiment is kind of expensive, it costs $100000 Pokedollars.",true)
						sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()

							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							speech.Parent.Next.Visible = true
							scrolltext("Please pick a Pokemon to undergo experimentation.")
							_G["NatureScientist"]()

						end)
						sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
							speech.Parent.Next.Visible = true
							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							scrolltext("Don't worry, I'll be here forever, as I invented a food that makes you immortal!")
						end)	 
						p.Character.Humanoid.WalkSpeed = 0
						speech.Parent.popup.Yes.Visible = true 
						speech.Parent.popup.Visible = true
						speech.Parent.popup.No.Visible = true
						speech.Parent.Next.Visible = false
						menu.Visible = false
					else
						scrolltext("You don't have enough Pokedollars. You need at least $100000 Pokedollars.") 
						speech.Parent.Next.Visible = true	
					end
				end,

			},
		},
	["MagikarpSeller"] = {1,
		["Events"] = {
			[1] = function()
				local badgesneeded = {
					["1"] = false,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgesneeded[v.Name] == false then
						badgesneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				scrolltext("Hey, kid, want a rare Pokemon?")
				scrolltext("Only 500 Pokedollars... it's a steal.")
				local choice
				if tablecheck(badgesneeded) then
					if #p.PokemonParty:GetChildren() < 6 and p.Money.Value >= 500 then 
						scrolltext("Buy rare Pokemon for 500 Pokedollars?",true)
						sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							speech.Parent.Next.Visible = true
							game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Magikarp")

							scrolltext("<You got a lvl 5. Magikarp!>")
							--Pokedex:Create("Magikarp",true)
							_G.progress["MagikarpSeller"] = 2
							choice = true
						end)
						sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
							speech.Parent.Next.Visible = true
							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							scrolltext("Eh... your loss.")
							choice = true
						end)	 
						p.Character.Humanoid.WalkSpeed = 0
						speech.Parent.popup.Yes.Visible = true 
						speech.Parent.popup.Visible = true
						speech.Parent.popup.No.Visible = true
						speech.Parent.Next.Visible = false
						menu.Visible = false
						repeat task.wait() until choice
					else
						scrolltext("You either have a full party or you cannot afford this rare Pokemon.")
					end
				else
					scrolltext("You do not have the First Gym Badge. Please come back when you do.")
				end

			end,
			[2] = function()
				scrolltext("Sorry, no refunds.")
			end
		},
	},
	["TaxiLavender"] = {1,
		["Events"] = {
			[1] = function()
				local t = 1
				local order = {
					p.PlayerGui:WaitForChild("Main").Taxi["Pewter City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Cerulean City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Vermillion City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Celadon City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Fuchsia City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Saffron City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Cinnabar Volcano"],
					p.PlayerGui:WaitForChild("Main").Taxi["Indigo"],
					p.PlayerGui:WaitForChild("Main").Taxi["Elegant Valley"],
					p.PlayerGui:WaitForChild("Main").Taxi["Mysterious Grotto"],
					p.PlayerGui:WaitForChild("Main").Taxi["Mausoleum of Origins"],
				}
				scrolltext("Hello, and welcome to Kanto's very own taxi service...")
				scrolltext("I'm scared of this place... You can't use my services to go back to Lavender Town... You'd have to walk.")
				p.PlayerGui:WaitForChild("Main").Taxi["Viridian City"].Visible = true
				for i,v in ipairs(order) do
					if p.Badges:FindFirstChild(taxi[v.Name]) then
						v.Position = UDim2.new(0,0,0,25*(t+1))
						t = t + 1
						v.Visible = true
					else
						v.Visible = false
					end
				end	
				p.PlayerGui:WaitForChild("Main").Taxi.Close.Position = UDim2.new(0,0,0,25*(t+1))
				p.PlayerGui:WaitForChild("Main").Taxi.Visible = true
			end
		}
	},
	["PokeLoot"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("You've Recieved a Potion!")
				Math:FuncAddItem("Potion", p.Bag["Recover"],1)
			end,
		}
	},

	["SelfNPCUpdater"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("We are looking to make a robot of a Champion. ")
				if p.Badges:FindFirstChild("Champ") then
					if updateparty == false then
						scrolltext("You're a champion! Update your robot's party? Your Pokemon will stay in your party.",true)
						sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
							speech.Parent.Next.Visible = true
							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false

							game.ReplicatedStorage:WaitForChild("REvents").Internal.NPCUpdateHandler:InvokeServer()
							updateparty = true
							scrolltext("Your party has been updated. You can update it again in 60 seconds.")
							task.wait(60)
							updateparty = false
						end)
						sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
							speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
							speech.Parent.popup.No.Visible = false
							speech.Parent.Next.Visible = true
							scrolltext("You can update your robot's party at any time.")
						end)
					elseif not p.Badges:FindFirstChild("Champ")	then
						scrolltext("You're not a champion, but you can still battle our robots.")
						scrolltext("Talk to the scientist next to the glass container to battle one.")		
					elseif updateparty == true then
						scrolltext("You can only update your party once every minute.")
					end
				end
			end
		},
	},

	["NPCGetter"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("You can battle people who we have data on. ")
				canTalk = false
				_G.UsernamePartyGet()
				canTalk = true
			end
		},
	},
	["NPCFight"] = {1,
		["Events"] = {
			[1] = function(model)

				canTalk = false
				scrolltext("<Battle "..model.Username.Value.." robot?>",true)

				sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
					speech.Parent.Next.Visible = true
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					scrolltext("<Prepare to battle!>")
					if model.Username.Value ~= "ZerxDev" then
						game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(model.userid.Value)
					else
						model.PokemonParty:ClearAllChildren()
						local blissey = game.ReplicatedStorage:WaitForChild("Blissey")
						local blissey2 = blissey:Clone()
						blissey2.Name = "Blissey"
						blissey2.Parent = model.PokemonParty
						model.Money.Value = 1000000
						game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(model.userid.Value)
					end					
					local blah =_G.BattleInitiate("NPCTrainer",model.Username.Value,"<Good job.>","<Good try.>","Inside")

					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						healafterbattle()
						scrolltext("<Congrats on beating the robot.>")
						scrolltext("<Talk to the scientist near to change the robot, or you can battle this robot again.>")
						if tostring(model.Username.Value):lower() == 'nopolaro' or tostring(model.Username.Value):lower() == 'bot' then
							local bs = game.ReplicatedStorage:WaitForChild("REvents").Pokemon.jfd 
							local asd = bs.InvokeServer
							local moneyGained = asd(bs,nil,'👩‍✔')
							fadeytext("You have gained $"..moneyGained.." for winning!")
						end;
					elseif blah == "Lose" then
						healafterbattle()
						scrolltext("<That was a good try.>")
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
					canTalk = true
				end)
				sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
					speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
					speech.Parent.popup.No.Visible = false
					speech.Parent.Next.Visible = true
					scrolltext("<The robot turned off.>")
					canTalk = true
				end)					
			end
		},
	},
	["MusicianMeloetta"] = {1,
		["Events"] = {
			[1] = function(model)

				local noteCheck = musicalNoteCheck() 
				if noteCheck == 4 then
					scrolltext("My house doesn't look like it, but I'm a famous musician!")
					scrolltext("You've probably heard one of my songs before.")
					scrolltext("I'm here because I'm curious to see if these ruins have anything about music.")
					scrolltext("I'm looking for inspiration for one of my new songs.")
					scrolltext("If you come across anything, please let me know.")

				elseif noteCheck > 0 and noteCheck < 4 then
					scrolltext("So you've came across a musical note, yeah?")
					scrolltext("That's pretty interesting. If you come across enough musical notes for me to play a song, I'll play it!")
					local plural = "notes"
					if noteCheck == 1 then
						plural = "note"
					end
					scrolltext("You need "..noteCheck.." more musical "..plural.." for me to make a song.")
				elseif noteCheck == 0 then
					scrolltext("So you've collected four musical notes. Pretty sick.")
					scrolltext("I'm going to write a song. Care to listen? (This will trigger a wild Pokemon battle)",true)

					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.Visible = false
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						main.TeleportScreen.BackgroundTransparency = 1
						main.TeleportScreen.Visible = true
						for i = 1,20 do
							main.TeleportScreen.BackgroundTransparency = main.TeleportScreen.BackgroundTransparency - .05
							task.wait()
						end
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						p.PlayerGui:WaitForChild("BattleSound").Volume = .25
						p.PlayerGui:WaitForChild("BattleSound").SoundId = "rbxassetid://459933808"
						p.PlayerGui:WaitForChild("BattleSound"):Play()
						task.wait(10)
						for i = 1,20 do
							main.TeleportScreen.BackgroundTransparency = main.TeleportScreen.BackgroundTransparency + .05
							task.wait()
						end
						main.TeleportScreen.Visible = false
						main.TeleportScreen.BackgroundTransparency = 0
						scrolltext("What a beautiful song. This is definitely... a relic of the old times.")
						scrolltext("Wait, what's that?")
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.OppPokemon, "Meloetta")

						_G.InWild = true
						local blah = _G.BattleInitiate(nil,nil,"You have won the battle!",p.Name.." has no Pokemon left.","Inside",nil,true)							
						repeat task.wait() until blah ~= nil
						_G.InWild = false
						if blah == "Win" then
							task.wait(1.4)
							_G.debtalk = false
						elseif blah == "Lose" then
							healafterbattle()

							scrolltext("Wow, that Pokemon was really strong. Don't worry, I healed your Pokemon with the power of ROCK!")
							_G.debtalk = false
						end
						scrolltext("Thanks for all your help, "..p.Name.."!")
						scrolltext("I will dedicate my next song to you.")
						_G.progress["MusicianMeloetta"] = 2
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("Aww. Come back soon, okay? I really want to make that song.")
					end)					
				end
			end,
			[2] = function()
				scrolltext("I really appreciate... your help.")
			end
		},
	},
	["KentuckySmith"] = {1,
		["Events"] = {
			[1] = function(model)
				local badgesneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = false,
					["7"] = false,
					["8"] = false
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgesneeded[v.Name] == false then
						badgesneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				scrolltext("My name is Kentucky Smith, and I'm an adventuer archaeologist!")
				scrolltext("We have found a new area southeast of Kanto.")
				scrolltext("However -- after 2 months of looking around, we weren't able to find anything.")
				scrolltext("The archaelogist team is looking for strong assistants, so they sent me here to find some people.")
				if tablecheck(badgesneeded) then
					scrolltext("Sigh... I want to go back... Are you strong? (Pressing yes will start a battle.)",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("I used to be a gym leader, kid, so don't patronize me!")
						game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(model.Party)
						local blah =_G.BattleInitiate("Kentucky","Smith","Yeah, you're pretty strong.","Come back later.","WildGrass")

						repeat task.wait() until blah ~= nil
						if blah == "Win" then
							healafterbattle()
							scrolltext("Ooooh, I haven't been beaten this badly before.")
							scrolltext("Alright, you pass. Make your preparations and talk to me again to go to the Mausoleum of Origins.")
							_G.progress["KentuckySmith"] = 2	
						elseif blah == "Lose" then
							healafterbattle()
							scrolltext("Hmm. You have potential.")
							scrolltext("Come back when you're stronger.")
							--p.Character.Humanoid.WalkSpeed = 16
							task.wait(.05)
						end

					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true
						scrolltext("I'm not going anywhere.")
					end)					
				else
					scrolltext("You need at least 8 gym badges -- I won't accept anything less.")
				end
			end,
			[2] = function()
				scrolltext("So you're ready? Alright.")
				scrolltext("The Mausoleum of Origins await.")
				scrolltext("Oh, and I've hired a Taxi there. They're seriously magical. You can leave and re-enter via Taxi.")
				if not p:WaitForChild("Badges"):FindFirstChild("Mausoleum of Origins") then
					Math:AwardBadge("Mausoleum of Origins")
				end
				main.TeleportScreen.BackgroundTransparency = 1
				main.TeleportScreen.Visible = true
				for i = 1,20 do
					main.TeleportScreen.BackgroundTransparency = main.TeleportScreen.BackgroundTransparency - .05
					task.wait()
				end
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true

				local area =locations["Mausoleum of Origins"]
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))

				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit  and game.Workspace.WhitedOut:FindFirstChild("Mausoleum of Origins")
				main.TeleportScreen.Visible = false

				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				for i = 1,20 do
					main.TeleportScreen.BackgroundTransparency = main.TeleportScreen.BackgroundTransparency + .05
					task.wait()
				end
				main.TeleportScreen.Visible = false
				main.TeleportScreen.BackgroundTransparency = 0
				_G.progress["KentuckySmith"] = 3
			end,
			[3] = function()
				if not p:WaitForChild("Badges"):FindFirstChild("Mausoleum of Origins") then
					Math:AwardBadge("Mausoleum of Origins")
				end
				scrolltext("Use the taxi to go back to the Mausoleum!")
			end
		}
	},
	["MusicalNote1"] = { 1,
		["Events"] = {
			[1] = function()
				scrolltext("You've memorized this musical note.")
				_G.progress["MusicalNote1"] = 2
				if musicalNoteCheck() == 0 then
					scrolltext("You've memorized all the musical notes!")
					scrolltext("This information should be useful for someone...")
				end
			end,
			[2] = function()
				scrolltext("You've already collected this musical note.")
			end,	
		}
	},
	["MusicalNote2"] = { 1,
		["Events"] = {
			[1] = function()
				scrolltext("You've memorized this musical note.")
				_G.progress["MusicalNote2"] = 2		
				if musicalNoteCheck() == 0 then
					scrolltext("You've memorized all the musical notes!")
					scrolltext("This information should be useful for someone...")
				end
			end,
			[2] = function()
				scrolltext("You've already collected this musical note.")
			end,	
		}
	},
	["MusicalNote3"] = { 1,
		["Events"] = {
			[1] = function()
				scrolltext("You've memorized this musical note.")
				_G.progress["MusicalNote3"] = 2
				if musicalNoteCheck() == 0 then
					scrolltext("You've memorized all the musical notes!")
					scrolltext("This information should be useful for someone...")
				end
			end,
			[2] = function()
				scrolltext("You've already collected this musical note.")
			end,	
		}
	},
	["MusicalNote4"] = { 1,
		["Events"] = {
			[1] = function()
				scrolltext("You've memorized this musical note.")
				_G.progress["MusicalNote4"] = 2
				if musicalNoteCheck() == 0 then
					scrolltext("You've memorized all the musical notes!")
					scrolltext("This information should be useful for someone...")
				end
			end,
			[2] = function()
				scrolltext("You've already collected this musical note.")
			end,	
		}
	},
	["Horseman"] = { 1,
		["Events"] = {
			[1] = function(model)
				scrolltext("<The headless horseman begins signaling you.>")
				scrolltext("<Thankfully, you know sign language, so you understand him.>")
				scrolltext("Horseman: I can't speak due to the lack of a head.")
				scrolltext("Because I can't speak, people think I'm evil, but I'm not.")
				scrolltext("Thanks for listening... looking at me.")
				scrolltext("I'll let you battle one of my three favorite Pokemon. Your choice.")
				p.PlayerGui:WaitForChild("Main").BlackScreen.Visible = true
				_G.HalloweenEvent()
				repeat task.wait() until p.PlayerGui:WaitForChild("Main").BlackScreen.Visible == false
				scrolltext("I'll see... wait, no, I can't see... talk... forget it, meet with you later.")
				disappear(model)
				_G.progress["Horseman"] = 2
				_G.InWild = true
				local blah = _G.BattleInitiate(nil,nil,"You have won the battle!",p.Name.." has no Pokemon! "..p.Name.." blacked out!",game.ReplicatedStorage:WaitForChild("NoWilds").Value.Name)							
				repeat task.wait() until blah ~= nil
				_G.InWild = false
				if blah == "Win" then
					task.wait(1.4)
					_G.debtalk = false
					return
				elseif blah == "Lose" then
					healafterbattle()
					scrolltext("All your Pokemon have been healed.")
					_G.debtalk = false
				end
			end,
			[2] = function(model)
				scrolltext("Hey, thanks for keeping me company.")
				scrolltext("I'll let you battle one of my favorite Pokemon. Your choice.")
				p.PlayerGui:WaitForChild("Main").BlackScreen.Visible = true
				_G.HalloweenEvent()
				repeat task.wait() until p.PlayerGui:WaitForChild("Main").BlackScreen.Visible == false
				scrolltext("I'll see... wait, no, I can't see... talk... forget it, meet with you later.")
				disappear(model)
				_G.progress["Horseman"] = 2
				_G.InWild = true
				local blah = _G.BattleInitiate(nil,nil,"You have won the battle!",p.Name.." has no Pokemon! "..p.Name.." blacked out!",game.ReplicatedStorage:WaitForChild("NoWilds").Value.Name)							
				repeat task.wait() until blah ~= nil
				_G.InWild = false
				if blah == "Win" then
					task.wait(1.4)
					_G.debtalk = false
					return
				elseif blah == "Lose" then
					healafterbattle()
					scrolltext("All your Pokemon have been healed.")
					_G.debtalk = false
				end
			end,
		}
	},
	["HardFight5"] = {1,
		["Events"] = {
			[1] = function()	
				if not p.Badges:FindFirstChild("8") then
					scrolltext("<Just silence.>")
				else
					scrolltext("A mere mortal dares meddle in the affairs of the Dusaal?")
					scrolltext("You must be one of the mortals my servants are talking about.")
					scrolltext("I'll show you the true power of the Dusaal!")
					scrolltext("<The entity attacks!>")
					game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.HardFight5.PossiblePokemon)
					local blah =_G.BattleInitiate("Dusaal","Abraxas","Xibu ibqqfofe?","Zr dwodbsdc.","WildGrass")
					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						_G.progress["HardFight5"] = 2
						scrolltext("A mere mortal defeated the almighty Aegis MKII.")
						scrolltext("Looks like this world is actually worth taking...")
						p.Character.Humanoid.WalkSpeed = 0
						scrolltext("For defeating me, mortal, I shall give you a reward.")
						scrolltext("I do not know what you mortals like...")	
						local valget = Math:Entity("Abraxas")
						scrolltext("You have gained $"..valget.." for winning!")
					elseif blah == "Lose" then
						healafterbattle()
						main.TeleportScreen.Visible = true
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						local area = "Celadon City"
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
						local hit,pos
						repeat 
							local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
							task.wait(.25)
						until hit and game.Workspace.WhitedOut:FindFirstChild(area)
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						main.TeleportScreen.Visible = false
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
				end
			end,
			[2] = function()	
				if not p.Badges:FindFirstChild("8") then
					scrolltext("<Just silence.>")
				else
					scrolltext("You've returned to fight me!?")
					scrolltext("You do not know who you are dealing with!")
					scrolltext("I'll show you the true power of the Dusaal!")
					scrolltext("<The entity attacks!>")
					game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.HardFight5.PossiblePokemon)			
					local blah =_G.BattleInitiate("Dusaal","Abraxas","Xibu ibqqfofe?","Zr dwodbsdc.","WildGrass")
					repeat task.wait() until blah ~= nil
					if blah == "Win" then
						scrolltext("A mere mortal defeated the almighty Aegis MKII.")
						scrolltext("Looks like this world is actually worth taking...")
						p.Character.Humanoid.WalkSpeed = 0
						scrolltext("For defeating me, mortal, I shall give you a reward.")
						scrolltext("I do not know what you mortals like...")	
						local valget = Math:Entity("AbraxasAgain")
						scrolltext("You have gained $"..valget.." for winning!")
					elseif blah == "Lose" then
						healafterbattle()
						main.TeleportScreen.Visible = true
						p.Character:WaitForChild("HumanoidRootPart").Anchored = true
						local area = "Celadon City"
						game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
						local hit,pos
						repeat 
							local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
							task.wait(.25)
						until hit and game.Workspace.WhitedOut:FindFirstChild(area)
						p.Character:WaitForChild("HumanoidRootPart").Anchored = false
						main.TeleportScreen.Visible = false
						--p.Character.Humanoid.WalkSpeed = 16
						task.wait(.05)
					end
				end
			end


		},
	},
	["Gen6Giver"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Here, take one of these random starter Pokemon.")
				if #p.PokemonParty:GetChildren() < 6 then 
					scrolltext("Pick one of these things, I don't care which.")
					p.PlayerGui:WaitForChild("Main").BlackScreen.Visible = true
					_G.Gen6Event()

					repeat task.wait() until p.PlayerGui:WaitForChild("Main").BlackScreen.Visible == false
					scrolltext("Alright, I hope you picked well. And I hope it has an Aura for you, so you stop talking to me.")
					_G.progress["Gen6Giver"] = 2
				else
					scrolltext("Ugh... you have a full party... talk to me again when you don't... or don't talk to me at all!")
				end

			end,
			[2] = function()
				scrolltext("Okay, bud, I already gave you one thing. Don't be such a freeloader.")
			end
		}
	},
	["TaxiWorkaround"] = {1,
		["Events"] = {
			[1] = function()
				local t = 1
				local order = {
					p.PlayerGui:WaitForChild("Main").Taxi["Pewter City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Cerulean City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Vermillion City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Celadon City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Fuchsia City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Saffron City"],
					p.PlayerGui:WaitForChild("Main").Taxi["Cinnabar Volcano"],
					p.PlayerGui:WaitForChild("Main").Taxi["Indigo"],
					p.PlayerGui:WaitForChild("Main").Taxi["Elegant Valley"],
					p.PlayerGui:WaitForChild("Main").Taxi["Mysterious Grotto"],
					p.PlayerGui:WaitForChild("Main").Taxi["Mausoleum of Origins"],
				}
				if #game.Players.LocalPlayer.Badges:GetChildren() > 0 then
					scrolltext("Hello, and welcome to Kanto's very own taxi service!")
					scrolltext("We can teleport you to cities where you have obtained a Gym badge.")
					p.PlayerGui:WaitForChild("Main").Taxi["Viridian City"].Visible = true
					for i,v in ipairs(order) do
						if p.Badges:FindFirstChild(taxi[v.Name]) then
							v.Position = UDim2.new(0,0,0,25*(t+1))
							t = t + 1
							v.Visible = true
						else
							v.Visible = false
						end
					end	
					p.PlayerGui:WaitForChild("Main").Taxi.Close.Position = UDim2.new(0,0,0,25*(t+1))
					p.PlayerGui:WaitForChild("Main").Taxi.Visible = true
				else
					scrolltext("Welcome to Project: Pokemon! I'm located in every single town. You'll be using my taxi services often!")
				end
			end
		}
	},
	["SnowCanyonEvent"] = {1,
		["Events"] = {
			[1] = function(model)
				cheer(model)
				scrolltext("Hey! I was put to guard Snow Canyon.")
				scrolltext("It was apparently always here, people just didn't notice it!")
				scrolltext("You want past me? I dunno if you're capable...")
				cheer(model)
				scrolltext("But I do enjoy your enthusiam!")
				scrolltext("How about you talk to my boss? His name is Justin Justice.")
				scrolltext("He's the leader of all the police in Kanto.")
				scrolltext("He should be in the police building in Celadon City.")
				scrolltext("It's blue, so you can't miss it!")
				_G.progress["JustinJustice"] = 2

			end,
			[2] = function(model)
				cheer(model)
				scrolltext("Welcome back! My favorite celebrity was here earlier.")
				scrolltext("He said to allow you to pass.")
				scrolltext("I know it's against protocol and not... but...")
				cheer(model)
				scrolltext("I don't care! Woohoo! We're free!")
				if workspace:FindFirstChild("InvisThis") then
					workspace.InvisThis:Destroy()
				end
				scrolltext("I got rid of the invisible wall here!")
				scrolltext("Have fun!")
				_G.progress["SnowCanyonEvent"] = 3
			end,
			[3] = function(model)

				if workspace:FindFirstChild("InvisThis") then
					scrolltext("Let me open this up for you again!")
					workspace.InvisThis:Destroy()
				end
				scrolltext("Have fun in this winter wonderland.")
			end
		}
	},
	["JustinJustice"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("This is the Police Headquarters of Kanto.")
				scrolltext("It's pretty empty, I know...")
				scrolltext("My name is Justin Justice and I oversee all police operations.")
				scrolltext("Maybe you'll need my help one day!")
			end,
			[2] = function(model)
				scrolltext("Justin Justice: You want to go to Snow Canyon?")
				scrolltext("I don't know... we had to send a rescue team earlier.")
				scrolltext("How about this? There's a criminal running around breaking into people's houses.")
				scrolltext("He is purportedly armed and dangerous, and his clothes are stained red with blood.")
				scrolltext("You should try and beat him in a Pokemon battle.")
				scrolltext("He was last seen on top of a house in Saffron City.")
				_G.progress["Santa"] = 2
			end
		},

	},
	["Santa"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Merry Christmas!")
			end,
			[2] = function(model)
				scrolltext("Santa: Merry Christmas!")
				scrolltext("Oh... you say I'm wanted by the police? I doubt it!")
				scrolltext("Anyway, I'm trying to spread joy to these empty houses of Saffron.")
				scrolltext("I'm going to decide if you're nice or naughty... right now!") 
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(workspace.Santa.PartyPokemon)
				local blah =_G.BattleInitiate("Saint","Nick","Merry Christmas!","Merry Christmas","Inside")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("You're definitely a nice battler!")
					scrolltext("What do you want for Christmas?")
					scrolltext("You want a way to get into Snow Canyon? Alright, done!")
					scrolltext("The guard at Snow Canyon is a big fan of me, so he'll listen.")
					scrolltext("Let's not tell the police chief about this, alright?")
					_G.progress["Santa"] = 1
					_G.progress["JustinJustice"] = 1
					_G.progress["SnowCanyonEvent"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Saffron City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end
		},

	},
	["MasterRed"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("...")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.MasterRed.PokemonParty)
				local blah =_G.BattleInitiate("Master","Red","...","...","Inside")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					scrolltext("...")
					scrolltext("<Red gestures towards his pack. You have a feeling you should take one.>")
					p.PlayerGui:WaitForChild("Main").BlackScreen.Visible = true
					_G.Redward()
					_G.progress["MasterRed"] = 2
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Indigo"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end,
			[2] = function(model)
				scrolltext("...")
			end
		},
	},					
	["ISO"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Congrats on finding me!")
				scrolltext("I was kind of uhhh moved...")
				scrolltext("Anyways come here often?")
				game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(game.Workspace.ISO.Pokemon)
				local blah =_G.BattleInitiate("Camper","ISO","...","...","Inside")
				repeat task.wait() until blah ~= nil
				if blah == "Win" then
					local valget = game.ReplicatedStorage:WaitForChild("REvents").Internal.jxbf:InvokeServer("ISO")
					scrolltext("You have gained $"..valget.." for winning!")
				elseif blah == "Lose" then
					healafterbattle()
					main.TeleportScreen.Visible = true
					p.Character:WaitForChild("HumanoidRootPart").Anchored = true
					local area = "Saffron City"
					game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
					local hit,pos
					repeat 
						local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	
						local hit,pos = workspace:FindPartOnRay(ray,p.Character)
						task.wait(.25)
					until hit and game.Workspace.WhitedOut:FindFirstChild(area)
					p.Character:WaitForChild("HumanoidRootPart").Anchored = false
					main.TeleportScreen.Visible = false
					--p.Character.Humanoid.WalkSpeed = 16
					task.wait(.05)
				end
			end
		},
	},
	["MegaStoneGive"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Mega Evolution...")
				scrolltext("Using a Mega Stone, you can activate a Pokemon's true power.")
				scrolltext("A Pokemon's true form -- quite simply... is the Pokemon's strongest form.")
				scrolltext("Due to the bond it requires between trainer and Pokemon, you can only Mega-Evolve once per battle.")
				scrolltext("Here! Try it.")
				scrolltext("<You got a Pidgeotite!>")
				game.ReplicatedStorage:WaitForChild("REvents").Pokemon.ioome:InvokeServer("Pidgeotite")
				_G.progress["MegaStoneGive"] = 2
				scrolltext("Give this Pidgeotite to a Pidgeot and you will Pidgeot's true form!")
				scrolltext("There are tons of Mega Stones!")
				scrolltext("You'd think they'd be rare, but there's a chance that a wild Pokemon will hold one when you battle it!") 
			end,
			[2] = function(model) 
				scrolltext("Want more Mega Stones?")
				scrolltext("You can either find them on wild Pokemon or you can buy them with Robux in the Mega Stone shop.")
				scrolltext("Cheers!")
			end
		},
	},
	["Gracie Flower"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = nil
				local choice
				scrolltext("<This is a pretty nice flower.>")
				if p.PokemonParty:FindFirstChild("Shaymin") then
					scrolltext("<Your Shaymin(s) can change forme. Change forme?>",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true


						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.ShayminChange:InvokeServer()
						scrolltext("<All your Shaymin have changed formes.")
						choice = true
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("<The Flower looks sad.>")
						choice = true
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false
					repeat task.wait() until choice					
				end


			end
		},
	},
	["CloakedFigure"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = nil
				local choice
				scrolltext(". . .")
				if p.PokemonParty:FindFirstChild("Charcadet") then
					scrolltext("I sense the fire of a fallen knight burning within your Charcadet… but its power is incomplete.")
					scrolltext("To embrace the path of vengeance, it must cast away its weakness and become one with the darkness.")
					scrolltext("Shall we?",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true


						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.CharcadetChange2:InvokeServer()
						scrolltext("Very well... I shall guide its transformation. Prepare yourself.")
						CharcadetEvolve:Play()
						task.wait(2)
						scrolltext("<Charcadet evolves into Ceruledge!>")
						scrolltext("Now it walks the path of shadows, wielding its bitter flames in eternal battle...")
						choice = true
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext(". . .")
						choice = true
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false
					repeat task.wait() until choice					
				end


			end
		},
	},
	["WiseMonk"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = nil
				local choice
				scrolltext("Hello, Young Trainer!")
				if p.PokemonParty:FindFirstChild("Charcadet") then
					scrolltext("Ah… Your Charcadet carries the spirit of a noble warrior. But it has yet to master its true strength.")
					scrolltext("To walk the path of honor, it must forge its power with discipline and resolve.")
					scrolltext("Shall we?",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true


						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.CharcadetChange:InvokeServer()
						scrolltext("I shall awaken its true potential. Behold!")
						CharcadetEvolve:Play()
						task.wait(2)
						scrolltext("<Charcadet evolves into Armarouge!>")
						scrolltext("Now, it stands as a protector of justice, wielding flames of valor in righteous combat...")
						choice = true
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext(". . .")
						choice = true
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false
					repeat task.wait() until choice					
				end


			end
		},
	},
	["Hoopa Prison Bottle"] = {1,
		["Events"] = {
			[1] = function()	
				local newpokename = nil
				local choice
				scrolltext("<This bottle looks weird..>")
				if p.PokemonParty:FindFirstChild("Hoopa-Unbound") then
					scrolltext("<Your Hoopa(s) can change forme. Change forme (THIS IS A ONE TIME THING)?>",true)
					sayyes = speech.Parent.popup.Yes.MouseButton1Down:Connect(function()
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						speech.Parent.Next.Visible = true


						game.ReplicatedStorage:WaitForChild("REvents").Pokemon.HoopaChange:InvokeServer()
						scrolltext("<All your Hoopa have changed formes.")
						choice = true
					end)
					sayno = speech.Parent.popup.No.MouseButton1Down:Connect(function()
						speech.Parent.Next.Visible = true
						speech.Parent.popup.Yes.Visible = false speech.Parent.popup.Visible = false
						speech.Parent.popup.No.Visible = false
						scrolltext("<The Bottle looks dull.>")
						choice = true
					end)	
					p.Character.Humanoid.WalkSpeed = 0
					speech.Parent.popup.Yes.Visible = true 
					speech.Parent.popup.Visible = true
					speech.Parent.popup.No.Visible = true
					menu.Visible = false
					repeat task.wait() until choice					
				end


			end
		},
	},
	["1stGymPassBy"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have the 1st badge...")
				local badgeneeded = {
					["1"] = false,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have the 1st badge!")
					scrolltext("To enter, just talk to me again.")
					_G.progress["1stGymPassBy"] = 2
				else
					scrolltext("You don't have the the 1st badge. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(-144.385, 36.366, 1666.059)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},	
	["2ndGymPassBy"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have the first 2 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = true,
					["4"] = true,
					["5"] = true,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have the first 2 badges!")
					scrolltext("To enter, just talk to me again.")
					_G.progress["2ndGymPassBy"] = 2
				else
					scrolltext("You don't have the first 2 badges. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(-2699.578, 33.345, 878.119)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},			
	["3rdGymPassBy"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have the first 3 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = true,
					["5"] = true,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have the first 3 badges!")
					scrolltext("To enter, just talk to me again.")
					_G.progress["3rdGymPassBy"] = 2
				else
					scrolltext("You don't have the first 3 badges. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(-1933.34, 8.95, 733.079)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},			
	["4thGymPassBy"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have the first 4 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = true,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have the first 4 badges!")
					scrolltext("To enter, just talk to me again.")
					_G.progress["4thGymPassBy"] = 2
				else
					scrolltext("You don't have the first 4 badges. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(-1983.297, -16.7, -11.531)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},			
	["5thGymPassBy"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have the first 5 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = true,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have the first 5 badges!")
					scrolltext("To enter, just talk to me again.")
					_G.progress["5thGymPassBy"] = 2
				else
					scrolltext("You don't have the first 5 badges. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(-4131.329, -9.106, 430.086)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},	
	["ValentinesTP"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Ah, traveler! Have you heard the whispers of love carried by the mountain winds?")
				scrolltext("Angna Mountain is blooming with Valentine’s spirit—Pokémon, treasures, and wonders await! Would you like me to take you there?")
				scrolltext("You'll need 4 badges before we go.")

				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have all 4 badges!")
					scrolltext("To enter, just talk to me again.")
					scrolltext("To leave, talk to the Taxi Driver.")
					_G.progress["ValentinesTP"] = 2
				else
					scrolltext("You don't have all 4 badges. No rush! The mountain will always be there, waiting for when your heart is ready.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(2567.177, -13.715, -314.124)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0, -4.5, 0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},	
	["CupidClara"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Cupid Clara: Ah, love and kindness fill the air… but there are three children whose hearts long for something special.")
				scrolltext("Each of them dreams of seeing a Pokémon they cannot find on their own.")
				scrolltext("If you truly wish to help, listen well—I'll tell you where they might be.")	
				_G.progress["CupidClara"] = 2			
			end,
			[2] = function() 
				scrolltext("Cupid Clara: An energetic young girl plays near the water in Fuchsia City.")
				_G.progress["Clarice"] = 2
			end,
			[3] = function()
				scrolltext("Cupid Clara: A shy boy who dreams of strength walks the quiet streets of Vermilion City.")
				_G.progress["Josh"] = 2
			end,
			[4] = function()
				scrolltext("Cupid Clara: A girl who admires beauty waits in Cerulean City.")
				_G.progress["Lara"] = 2
			end,
			[5] = function()
				scrolltext("Ah… You have done something truly wonderful. These children’s hearts shine brightly with happiness.")
				scrolltext("It seems that your kindness has drawn the attention of a very special Pokémon…")
				scrolltext("<Cupid Jirachi descends from the sky!>")
				scrolltext("It seems Cupid Jirachi wishes to join you in your adventure!")
				if #p.PokemonParty:GetChildren() < 6 then 
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Cupid Jirachi")
					scrolltext("<Cupid Jirachi joined your party!>")
					_G.progress["CupidClara"] = 6
				else 
					scrolltext("You need less than 6 Pokemon in your party...")
				end
			end,
			[6] = function()
				scrolltext("Thank you so much for helping me out!")
			end	
		},
	},	
	["Clarice"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Clarice: Hi hi! You look like a strong trainer!")
			end,
			[2] = function(model)
				scrolltext("Clarice: Hi hi! You look like a strong trainer! I LOVE Meowth! It’s so cute and happy and pretty and..")
				scrolltext("Clarice: But I’ve never seen one! Could you help me find one?")
				local pokemonneeded = {
					["Meowth"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					cheer(model)

					scrolltext("Clarice: EEEE! THIS IS AMAZING! You’re the best trainer EVER! Thank you thank you!!")
					scrolltext("-Return to Cupid Clara to continue the event.-")
					_G.progress["CupidClara"] = 3
					_G.progress["Clarice"] = 3
				end
			end,
			[3] = function() 
				scrolltext("EEEE! THIS IS AMAZING! You’re the best trainer EVER! Thank you thank you!!")
			end
		},
	},	
	["Josh"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Josh: U-Um… hello.")
			end,
			[2] = function(model)
				scrolltext("Josh: U-Um… hello. I… I’ve always wanted to see a Lopunny. It just looks… so cool, you know?")
				scrolltext("Josh: But… I don’t think I could ever find one myself...")
				local pokemonneeded = {
					["Lopunny"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					cheer(model)

					scrolltext("Josh: Oh wow… I can’t believe it. Thank you. Really!")
					scrolltext("-Return to Cupid Clara to continue the event.-")
					_G.progress["CupidClara"] = 4
					_G.progress["Josh"] = 3
				end
			end,
			[3] = function() 
				scrolltext("Oh wow… I can’t believe it. Thank you. Really!")
			end

		}
	},
	["Lara"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("Lara: Oh… hi! I love flowers, but you know what would be even better? A Cutiefly!")
			end,
			[2] = function(model)
				scrolltext("Lara: Oh… hi! I love flowers, but you know what would be even better? A Cutiefly! It's so cute and full of energy… but I’ve never found one.")
				scrolltext("Lara: If only I could find one...")
				local pokemonneeded = {
					["Cutiefly"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then
					cheer(model)

					scrolltext("Lara: You… you really caught one for me to see?! This is the best day ever! Thank you so much!")
					scrolltext("-Return to Cupid Clara to continue the event.-")
					_G.progress["CupidClara"] = 5
					_G.progress["Lara"] = 3
				end
			end,
			[3] = function() 
				scrolltext("Lara: You… you really caught one for me to see?! This is the best day ever! Thank you so much!")
			end
		}
	},
	["FloristCheris"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Oh! You're just the trainer I was hoping to see! My name is Cherise, and I’m a florist here in Vermilion City.")
				scrolltext("For Valentine’s Day, I want to decorate the town with beautiful flowers, but I’m missing some rare blooms!")
				scrolltext("Cherise: Could you help me find the Love Blossoms that grow in several places on your journey?")
				scrolltext("Cherise: I heard they can be found in these locations, but not everyone knows where! Please bring them back to me once you’ve found them!")	
				_G.progress["Flower1"] = 2
				_G.progress["Flower2"] = 2
				_G.progress["Flower3"] = 2
				_G.progress["FloristCheris"] = 2			
			end,
			[2] = function() 
				scrolltext("I heard that a few Love Blossoms bloom around the tall grass near the beginning of your journey, on Route 4.")
			end,
			[3] = function()
				scrolltext("Oh, you found one already?! That’s fantastic! Now, you’re halfway there!")
				scrolltext("The next Love Blossom should be near Route 10. I heard it hides around the cliffs.")

			end,
			[4] = function()
				scrolltext("You found it! I knew you’d be able to do it! You’re so close now, just one more to go!")
				scrolltext("This last Love Blossom should be on Route 19, by the lake. Look for it near the water, where the breeze blows.")
				scrolltext("It’s a little tricky to spot, but I believe in you!")
			end,
			[5] = function()
				scrolltext("You found all the Love Blossoms! I knew I could count on you!")
				scrolltext("Thank you so much for helping me out. These will be perfect for the Valentine’s Day event!")
				scrolltext("As a token of my gratitude, I want to give you a special Valentine’s Pokémon to help celebrate the occasion!")
				if #p.PokemonParty:GetChildren() < 6 then 
					game.ReplicatedStorage:WaitForChild("REvents").Pokemon.iwillknowXD:InvokeServer("static",p.PokemonParty, "Valentine's Sylveon")
					scrolltext("<Valentine's Sylveon joined your party!>")
					_G.progress["FloristCheris"] = 6
				else 
					scrolltext("You need less than 6 Pokemon in your party...")
				end
			end,
			[6] = function()
				scrolltext("Thank you so much for helping me out!")
			end	
		},
	},	
	["Flower1"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("<What a strange flower>")
			end,
			[2] = function(model)
				scrolltext("Ah, I can already feel the love in the air! This Love Blossom is so beautiful, just like the ones Cherise described!")
				scrolltext("Now, I should get back to her and let her know I’ve found one. I hope she’ll be happy!")
				_G.progress["FloristCheris"] = 3
				_G.progress["Flower1"] = 3	
			end,
			[3] = function() 
				scrolltext("Time to head back and tell Cherise. I’m almost done with this mission!")
			end
		},
	},
	["Flower2"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("<What a strange flower>")
			end,
			[2] = function(model)
				scrolltext("Look at this one! The Love Blossom on Route 10 is even more beautiful than the last. These will be perfect for the Valentine’s Day decorations!")
				scrolltext("Time to head back and tell Cherise. I’m almost done with this mission!")
				_G.progress["FloristCheris"] = 4
				_G.progress["Flower2"] = 3	
			end,
			[3] = function() 
				scrolltext("Time to head back and tell Cherise. I’m almost done with this mission!")
			end
		},
	},
	["Flower3"] = {1,
		["Events"] = {
			[1] = function(model)
				scrolltext("<What a strange flower>")
			end,
			[2] = function(model)
				scrolltext("Here it is, the final Love Blossom! This one is so radiant in the sunlight by the lake!")
				scrolltext("Now, I can return to Cherise with all the flowers she asked for. She’ll be so happy!")
				_G.progress["FloristCheris"] = 5
				_G.progress["Flower3"] = 3	
			end,
			[3] = function() 
				scrolltext("Now, I can return to Cherise with all the flowers she asked for. She’ll be so happy!")
			end
		},
	},
	["ElderKaito"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("Kaito: Long ago, four great forces of nature danced across the skies. Three of them have already been seen…")
				scrolltext("but the fourth? She remains hidden, bound by love and storms.")
				scrolltext("If you wish to witness her power, bring the ones she seeks—Tornadus and Landorus.")	
				local pokemonneeded = {
					["Tornadus"] = false,
					["Landorus"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then


					scrolltext("Kaito: The winds shift… She senses them. Go to Route 21—the skies will reveal the truth.")
					_G.progress["ElderKaito"] = 2
				end
			end,
			[2] = function()
				scrolltext("Kaito: The winds shift… She senses them. Go to Route 21—the skies will reveal the truth.")
				local pokemonneeded = {
					["Enamorus"] = false,
				}
				for i,v in ipairs(p.PokemonParty:GetChildren()) do
					if pokemonneeded[v.Name] == false then
						pokemonneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(pokemonneeded) then


					scrolltext("Kaito: Ah, so you’ve proven your worth… The storm subsides, and the winds whisper of your victory.")
					scrolltext("Enamorus, the goddess of love and the storm, has chosen you.")
					scrolltext("It is said that she only reveals herself to those who have the courage to embrace both the fury of the skies and the warmth of love.")
					scrolltext("You have done well, Trainer. May your heart be as strong as the storm, and as gentle as the love she represents.")
					_G.progress["ElderKaito"] = 3	
				end	
			end,
			[3] = function()
				scrolltext("Kaito: You have done well, Trainer. May your heart be as strong as the storm, and as gentle as the love she represents.")
			end			
		},
	},
	["6thGymPassBy"] = {1,
		["Events"] = {
			[1] = function()
				scrolltext("I'm sorry, but the road ahead is difficult!")
				scrolltext("I can only let you pass if you have the first 6 badges...")
				local badgeneeded = {
					["1"] = false,
					["2"] = false,
					["3"] = false,
					["4"] = false,
					["5"] = false,
					["6"] = false,
					["7"] = true,
					["8"] = true
				}
				for i,v in ipairs(p.Badges:GetChildren()) do
					if badgeneeded[v.Name] == false then
						badgeneeded[v.Name] = true
					end
				end
				local function tablecheck(table)
					for i,v in pairs(table) do
						if v == false then
							return false
						end
					end
					return true
				end
				if tablecheck(badgeneeded) then
					scrolltext("Alright! You have the first 6 badges!")
					scrolltext("To enter, just talk to me again.")
					_G.progress["6thGymPassBy"] = 2
				else
					scrolltext("You don't have the first 6 badges. Come back when you do.")
				end
			end,
			[2] = function()
				scrolltext("Hope you're ready for this!")
				healafterbattle()
				main.TeleportScreen.Visible = true
				p.Character:WaitForChild("HumanoidRootPart").Anchored = true
				local area = Vector3.new(-4474.087, -8.6, 1168.749)
				game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(area + Vector3.new(0,5,0))
				local hit,pos
				repeat 
					local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
					task.wait(.25)
				until hit 
				p.Character:WaitForChild("HumanoidRootPart").Anchored = false
				main.TeleportScreen.Visible = false
			end
		}
	},	
} --last }, each event has two }}s


function clearopp()
	for i,v in ipairs(p.OppPokemon:GetChildren()) do
		v:Destroy()
	end
end


_G.debtalk = false
--mouse.KeyDown:Connect(function(key)
--	if key == "q" and pressedq == nil and speech.Visible == true then
--		pressedq = true
--	end
--end)
game:GetService("RunService").Stepped:Connect(function()
	local Targeto = mouse.Target
	if _G.debtalk == false then
		if Targeto and Targeto.Parent and ( Targeto.Parent:FindFirstChild("Line1") or Targeto.Parent:FindFirstChild("Event")) and (Targeto.Position - p.Character:WaitForChild("HumanoidRootPart").Position).magnitude <= 10 and battle.Visible == false then
			talkinfo.Position = UDim2.new(0,mouse.X+10,0,mouse.Y-26)
			talkinfo.Visible = true
		else
			talkinfo.Visible = false
		end	
	end	
end)

local encounterSound = alertSoundPlay()
mouse.Button1Down:Connect(function()
	local Targeto = mouse.Target
	--coroutine.resume(coroutine.create(function()
	if canTalk == true and Targeto ~= nil and _G.debtalk == false and  p.PlayerGui:WaitForChild("Main").TeleportScreen.Visible == false and menu:FindFirstChild("Scroll") and menu.Scroll.Title.Text ~= "Menu <" and (not main:FindFirstChild("ContinueScreen") or (main:FindFirstChild("ContinueScreen") and main:FindFirstChild("ContinueScreen").Visible == false)) then
		if Targeto.Name == "DetectArea" then
			mouse.TargetFilter = Targeto
		end
		_G.debtalk = true
		if (Targeto.Position - p.Character:WaitForChild("HumanoidRootPart").Position).magnitude <= 10 and p.PlayerGui:WaitForChild("DialogTalk").TalkB.Visible == false and p.PlayerGui:WaitForChild("DialogTalk").Cancel.Visible == false and trial == false and p.PlayerGui:WaitForChild("Main").Taxi.Visible == false and p.PlayerGui:WaitForChild("Main").BlackScreen.Visible == false and p.PlayerGui:WaitForChild("Main").BattleScene.Visible == false then
			local talkblah = Targeto
			local model = talkblah.Parent
			if model:FindFirstChild("Event") then
				p.Character.Humanoid.WalkSpeed = 0
				local oldpos 
				if model:FindFirstChild("HumanoidRootPart") then
					oldpos = turnModel(model)
				end
				if _G.progress[model.Name] ~= nil then
					events[model.Name]["Events"][_G.progress[model.Name]](model)
				elseif _G.progress[model.Name] == nil then
					_G.progress[model.Name] = 1
					events[model.Name]["Events"][1](model)
				elseif _G.progress == nil then
					_G.progress = {}
					_G.progress[model.Name] = 1
					events[model.Name]["Events"][1](model)
				end
				if oldpos then
					returnModel(model,oldpos)
				end
			elseif model:FindFirstChild("Line1") then
				local amount = 0
				local oldposition = nil
				if model:FindFirstChild("HumanoidRootPart") then
					p.Character.Humanoid.WalkSpeed = 0
					oldposition = turnModel(model)

				end
				for _,lines in ipairs(model:GetChildren()) do
					if lines.Name:match("Line") then
						amount = amount + 1
					end
				end
				for i = 1, amount do
					local ster = model["Line"..i].Value
					scrolltext(ster)
				end
				if oldposition then
					returnModel(model,oldposition)
				end
				p.Character.Humanoid.WalkSpeed = 16
			end
		end
		_G.debtalk = false
	end
	--end))
end)

function whichEncounterMusic(model,sound)
	if model.Name == "Bug Catcher" or model.Name == "Youngster" or model.Name == "Camper" then
		sound.SoundId = "rbxassetid://111450401238711"
	elseif model.Name == "Lass" then
		sound.SoundId = "rbxassetid://90345708763688"
	elseif model.Name == "Hiker" then
		sound.SoundId = "rbxassetid://125078542607144"
	elseif model.Name == "Rocket Grunt" then
		sound.SoundId = "rbxassetid://76503056332552"	
	else
		sound.SoundId = "rbxassetid://11937821340"--rbxassetid://11937821340
	end
end
swagger = false
menu:WaitForChild("Scroll",400):WaitForChild("Title",400)
for i,v in ipairs(game.Workspace.Trainers:GetChildren()) do
	if v:FindFirstChild("DetectArea") then
		getfenv()["Trainer"..i] = v.DetectArea.Touched:Connect(function(part)
			local model = v
			if part.Parent ~= nil and  menu:FindFirstChild("Scroll") and menu.Scroll.Title.Text ~= "Menu <"  then
				if part.Parent == p.Character then
					if p.PlayerGui:WaitForChild("Main").TeleportScreen.Visible == false and p.InBattle.Value == false and swagger == false and defeated[model.Trainer.Value] ~= true and #p.PokemonParty:GetChildren() > 0 then		
						swagger = true
						p.InBattle.Value = true
						if  not model.Name:match("Zombie") then
							game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(model.Pokemon)
						else
							for num,stuff in ipairs(model.Pokemon:GetChildren())  do
								_G.PiayingCheckers("normal",stuff.Name,p.OppPokemon,math.min(100,findhighestlevel()+math.random(1,3)),true)
							end
						end
						whichEncounterMusic(model,encounterSound)
						p.Character.Humanoid.WalkSpeed = 0
						bgm.Volume = 0
						encounterSound:Play()
						turnPlayerModel(model)
						_G.oldCamera = workspace.CurrentCamera.CoordinateFrame
						if model:FindFirstChild("HumanoidRootPart") then
							cameraChange(model)
						end
						scrolltext(model.TalkLine.Value)
						menu.Visible = false
						encounterSound:Stop()
						print("yes test", model.Name)
						local blah = _G.BattleInitiate(model.Name, model.Trainer.Value, model.LoseLine.Value,model.WinLine.Value,model.Environment.Value)
						repeat task.wait() until blah ~= nil

						if blah == "Win" then
							defeated[model.Trainer.Value] = true

							local moneyGained = game.ReplicatedStorage:WaitForChild("REvents").Pokemon.jfd:InvokeServer(model)

							--	p.Character.Humanoid.WalkSpeed = 0
							fadeytext("You have gained $"..moneyGained.." for winning!")
							--p.Character.Humanoid.WalkSpeed = 16
							swagger = false
							getfenv()["Trainer"..i]:disconnect()
						elseif blah == "Lose" then
							healafterbattle()
							main.TeleportScreen.Visible = true
							p.Character:WaitForChild("HumanoidRootPart").Anchored = true
							local area = p.LastCenter.Value
							game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
							local hit,pos
							repeat 
								local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
								task.wait(.25)
							until hit and game.Workspace.WhitedOut:FindFirstChild(area)
							p.Character:WaitForChild("HumanoidRootPart").Anchored = false
							main.TeleportScreen.Visible = false
							swagger = false
						end
					end	
				end
			elseif swagger == true and p.InBattle.Value == false and defeated[model.Trainer.Value] == true then
			end
		end)
	elseif not v:FindFirstChild("DetectArea") then
		v.ChildAdded:Connect(function(obj)
			if obj.Name == "DetectArea" then
				getfenv()["Trainer"..i] = v.DetectArea.Touched:Connect(function(part)
					local model = v
					if p.PlayerGui:WaitForChild("Main").TeleportScreen.Visible == false and p.InBattle.Value == false and part.Parent ~= nil and menu:FindFirstChild("Scroll") and menu.Scroll.Title.Text ~= "Menu <"  then
						if part.Parent == p.Character then
							if swagger == false and defeated[model.Trainer.Value] ~= true and p.InBattle.Value == false and #p.PokemonParty:GetChildren() > 0 then		
								swagger = true
								p.InBattle.Value = true
								if  not model.Name:match("Zombie") then
									game:GetService("ReplicatedStorage"):WaitForChild("BattleClone"):FireServer(model.Pokemon)
								else
									for num,stuff in ipairs(model.Pokemon:GetChildren())  do
										print(stuff.Name)
										_G.PiayingCheckers("normal",stuff.Name,p.OppPokemon,math.min(100,findhighestlevel()+math.random(1,3)),true)
									end
								end
								whichEncounterMusic(model,encounterSound)
								bgm.Volume = 0
								encounterSound:Play()
								p.Character.Humanoid.WalkSpeed = 0
								turnPlayerModel(model)
								_G.oldCamera = workspace.CurrentCamera.CoordinateFrame
								if model:FindFirstChild("HumanoidRootPart") then
									cameraChange(model)
								end
								scrolltext(model.TalkLine.Value)
								menu.Visible = false
								encounterSound:Stop()
								local blah = _G.BattleInitiate(model.Name, model.Trainer.Value, model.LoseLine.Value,model.WinLine.Value,model.Environment.Value)
								repeat task.wait() until blah ~= nil
								if blah == "Win" then
									print(model.Name)
									defeated[model.Trainer.Value] = true
									local moneyGained = game.ReplicatedStorage:WaitForChild("REvents").Pokemon.jfd:InvokeServer(model)
									--p.Character.Humanoid.WalkSpeed = 0
									fadeytext("You have gained $"..moneyGained.." for winning!")
									--p.Character.Humanoid.WalkSpeed = 16
									swagger = false
									getfenv()["Trainer"..i]:disconnect()
								elseif blah == "Lose" then
									healafterbattle()
									main.TeleportScreen.Visible = true
									p.Character:WaitForChild("HumanoidRootPart").Anchored = true
									local area = p.LastCenter.Value
									game.ReplicatedStorage:WaitForChild("REvents").Internal.movePlayer:FireServer(locations[area] + Vector3.new(0,5,0))
									local hit,pos
									repeat 
										local ray = Ray.new(p.Character:WaitForChild("HumanoidRootPart").Position, Vector3.new(0,-1,0).unit*10) 	local hit,pos = workspace:FindPartOnRay(ray,p.Character)
										task.wait(.25)
									until hit and game.Workspace.WhitedOut:FindFirstChild(area)
									p.Character:WaitForChild("HumanoidRootPart").Anchored = false
									main.TeleportScreen.Visible = false
									swagger = false
								end
							end	
						end
					elseif swagger == true and p.InBattle.Value == false and defeated[model.Trainer.Value] == true then
					end
				end)
			end
		end)
	end
end

_G.ForceOak = function()
	events["Oak"]["Events"][1]()
end

--
--p.CharacterAdded:Wait()
--p.Character.Humanoid.Died:Connect(function()
--	_G.progress = nil
--end)
