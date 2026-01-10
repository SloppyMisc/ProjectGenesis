--This is the Party screen with "Switch", aka for when you're not in a battle
local Sprites = {["Inactive"] = "http://www.roblox.com/asset/?id=125060098",
	["Active"] = "http://www.roblox.com/asset/?id=125060039",
}
function turninactive(party)
	for i,v in ipairs(party:GetChildren()) do
		if v:FindFirstChild("active") then
			v:FindFirstChild("active").Image = Sprites["Inactive"]

			if v.Status.Text ~= "FNT" then
				v.BackgroundColor3 = Color3.new(154/255, 188/255, 217/255)
			else
				v.BackgroundColor3 = Color3.new(90/255,0,0)
			end
		end
	end
end

function findhealthbarsize(curhealth,maxhealth) --size is 150
	local multi = curhealth/maxhealth
	return .8*multi
end


function changevisible(thing,isa,bool)
	for i,v in ipairs(thing:GetChildren()) do
		if v:IsA(isa) then
			v.Visible = bool
		end
	end
end

function dcfenv(str)
	for i = 1, 6 do
		if getfenv()[str..i] ~= nil then
			getfenv()[str..i]:disconnect()
		end	
	end
end

function bigC(bool,partys)
	if bool == true then
		partys.Bottom.Line1.Visible = false
		partys.Bottom.Line2.Visible = false
		partys.Bottom.Stats.Visible = false
		partys.Bottom.Switch.Visible = false
		partys.Bottom.Cancel.Visible = false
		partys.Bottom.BigCancel.Visible = true	
	elseif bool == false then
		partys.Bottom.Line1.Visible = true
		partys.Bottom.Line2.Visible = true
		partys.Bottom.Stats.Visible = true
		partys.Bottom.Switch.Visible = true
		partys.Bottom.Cancel.Visible = true
		partys.Bottom.BigCancel.Visible = false
	end
end

local Sound1 = Instance.new("Sound",script.Parent)
Sound1.SoundId = "http://www.roblox.com/asset/?id=290841329"
local Sound2 = Instance.new("Sound",script.Parent)
Sound2.SoundId = "http://www.roblox.com/asset/?id=318763788"
local Math = require(game.ReplicatedStorage:WaitForChild("Functions").Math)

local ItemTab = require(game.ReplicatedStorage:WaitForChild("Information"):WaitForChild("Items"))
function boxupdate(pokemon,box,Party,pokeout,battle,var)
	dcfenv("Stat")
	dcfenv("Switch")
	pokemonderp = pokemon
	local poke = _G.Pokemon[pokemon.Name]
	if pokemon.Status.Value ~= "Faint" then
		box.ImageColor3 = Color3.new(154/255, 188/255, 217/255)
	else
		box.ImageColor3 = Color3.new(90/255,0,0)
	end
	box.Item.Visible = false
	if pokemon:FindFirstChild("HeldItem") and pokemon.HeldItem.Value ~= "" then
		box.Item.Image = ItemTab[pokemon.HeldItem.Value]["Sprite"]
		box.Item.Visible = true
	end
	box.PokeName.Text = _G.nickname(pokemon)
	box.PokeName.DropShadow.Text = box.PokeName.Text
	if pokemon:FindFirstChild("Reskin") then
		if poke["FormSprites"][pokemon.Reskin.Value] ~= nil then
			if poke["FormSprites"][pokemon.Reskin.Value]["Mini"] ~= nil then
				box.PokemonSprite.Image = poke["FormSprites"][pokemon.Reskin.Value]["Mini"]
			else
				box.PokemonSprite.Image = poke["FormSprites"][pokemon.Reskin.Value]["Front"]
			end
		else
			box.PokemonSprite.Image = poke["Sprites"]["Mini"]
		end
	else
		box.PokemonSprite.Image = poke["Sprites"]["Mini"]
	end
	box.Gender.Image = _G.Sprites["Symbols"][pokemon.Gender.Value]
	box.Level.Text = "Lv: "..pokemon.Lvl.Value
	box.Level.DropShadow.Text = box.Level.Text
	box.HPLabel.Text = pokemon.CurrentHP.Value.."/     "..pokemon.Stats.HPStat.Value
	box.HPLabel.DropShadow.Text = box.HPLabel.Text
	box.Health.Size = UDim2.new(findhealthbarsize(pokemon.CurrentHP.Value,pokemon.Stats.HPStat.Value),0,0.1,0)
	if box.Health.Size.X.Scale > .4 then
		box.Health.BackgroundColor3 = Color3.new(170/255,1,127/255)
	elseif  box.Health.Size.X.Scale <= .4 and   box.Health.Size.X.Scale >= .2 then
		box.Health.BackgroundColor3 = Color3.new(204/255,204/255,0)
	elseif  box.Health.Size.X.Scale < .2 and  box.Health.Size.X.Scale > 0 then
		box.Health.BackgroundColor3 = Color3.new(170/255,0,0)
		box.active.Image = Sprites["Active"]
	end
	if pokemon.Status.Value ~= "" then
		box.Status.Text = _G.Tables["Status"][pokemon.Status.Value][1]
		box.Status.BackgroundColor3 = _G.Tables["Status"][pokemon.Status.Value][2]
		box.Status.Visible = true
	else
		box.Status.Text = ""
		box.Status.Visible = false
	end
	if  pokemon.Status.Value == "Faint" then
		box.ImageColor3 = Color3.new(90/255,0,0)
	end

	getfenv()["Event"..pokemon.PartyPosition.Value] = box.MouseButton1Down:Connect(function()
		Sound1:Play()
		pokemonderp  = pokemon
		turninactive(partyscreen)
		if pokemonderp.Status.Value ~= "Faint" then
			box.ImageColor3 = Color3.new(105/255, 129/255, 148/255)
		else
			box.ImageColor3 = Color3.new(50/255,0,0)
		end	
		bigC(false,box.Parent)
		box.Parent.Bottom.dialog.Text  = "Currently Selected: ".._G.nickname(pokemonderp)
		box.Parent.Bottom.dialog.DropShadow.Text = box.Parent.Bottom.dialog.Text
		if var == "Cancel" then
			box.Parent.Bottom.Cancel.Visible = false
		end
		dcfenv("Stat")			
		dcfenv("Switch")
		getfenv()["Stat"..pokemonderp.PartyPosition.Value] = box.Parent.Bottom.Stats.MouseButton1Down:Connect(function()
			local blah = nil
			Sound2:Play()
			box.Parent.Visible = false
			blah = _G.StatScreen(pokemonderp,true,pokeout,var)
			repeat task.wait() until blah ~= nil 
			pokemonderp = blah
			box.Parent.Bottom.dialog.Text =  "Currently Selected: ".._G.nickname(pokemonderp)
			box.Parent.Bottom.dialog.DropShadow.Text = box.Parent.Bottom.dialog.Text
			turninactive(partyscreen)
			if pokemonderp.Status.Value ~= "Faint" then
				partyscreen["Pokemon"..pokemonderp.PartyPosition.Value].ImageColor3 = Color3.new(105/255, 129/255, 148/255)
			else
				partyscreen["Pokemon"..pokemonderp.PartyPosition.Value].ImageColor3 = Color3.new(50/255,0,0)
			end			
			partyscreen["Pokemon"..pokemonderp.PartyPosition.Value].active.Image = Sprites["Active"]
		end)

		getfenv()["Switch"..pokemonderp.PartyPosition.Value] = box.Parent.Bottom.Switch.MouseButton1Down:Connect(function()
			Sound2:Play()
			if pokemonderp == pokeout then
				box.Parent.Bottom.dialog.Text = pokeout.Name.." is already out!"
				box.Parent.Bottom.dialog.DropShadow.Text = box.Parent.Bottom.dialog.Text
			elseif pokemonderp.Status.Value == "Faint" or pokemonderp.CurrentHP.Value == 0 then
				box.Parent.Bottom.dialog.Text = "You can't send out a fainted Pokemon!"
				box.Parent.Bottom.dialog.DropShadow.Text = box.Parent.Bottom.dialog.Text
			else
				dcfenv("Stat")
				dcfenv("Switch")
				dcfenv("Event")
				pokeout.PartyPosition.Value = pokemonderp.PartyPosition.Value
				pokemonderp.PartyPosition.Value = 1
				pokemonswitch = pokemonderp
			end

		end)
	end)
	box.Visible = true
end



_G["PartyBattle"] = function(pokeout,battle,var)
	battle.Visible = false
	derp = true
	dcfenv("Event")
	dcfenv("Stat")
	dcfenv("Switch")
	pokemonswitch = nil
	if bigcancel ~= nil then bigcancel:disconnect() end
	if smallcancel ~= nil then smallcancel:disconnect() end
	partyscreen = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main").BlackScreen.Party
	--if game.Players.LocalPlayer:FindFirstChild("PokemonPartyBackup") then
	--	party = game.Players.LocalPlayer.PokemonPartyBackup
	--elseif game.Players.LocalPlayer:FindFirstChild("PokemonParty") then
	--	party = game.Players.LocalPlayer.PokemonParty
	--end
	party = game.Players.LocalPlayer.PokemonParty
	turninactive(partyscreen)
	for i,v in ipairs(partyscreen:GetChildren()) do
		if v:IsA("ImageButton") then
			v.Visible = false
		end
	end
	for i,v in pairs(party:GetChildren()) do
		if v.PartyPosition.Value <= 6 then
			boxupdate(v,partyscreen["Pokemon"..v.PartyPosition.Value],party,pokeout,battle,var)
		end
	end
	if var ~= "Cancel" then
		smallcancel = partyscreen.Bottom.Cancel.MouseButton1Down:Connect(function()
			dcfenv("Event")
			dcfenv("Stat")
			dcfenv("Switch")
			partyscreen.Visible = false
			derp = false
			battle.Visible = true
		end)
		bigcancel = partyscreen.Bottom.BigCancel.MouseButton1Down:Connect(function()
			dcfenv("Event")
			dcfenv("Stat")
			dcfenv("Switch")
			partyscreen.Visible = false
			derp = false
			battle.Visible = true
		end)
		bigC(true,partyscreen)
	else
		partyscreen.Bottom.BigCancel.Visible = false
		partyscreen.Bottom.Cancel.Visible = false
	end
	partyscreen.Title.Visible = true
	partyscreen.Bottom.dialog.Text = ""
	partyscreen.Bottom.dialog.DropShadow.Text = partyscreen.Bottom.dialog.Text
	partyscreen.Bottom.Visible = true
	partyscreen.Visible = true
	partyscreen.Bottom.dialog.Text = "Select a Pokemon to switch with "..pokeout.Name.."."
	partyscreen.Bottom.dialog.DropShadow.Text = partyscreen.Bottom.dialog.Text
	repeat task.wait() until pokemonswitch ~= nil or derp == false
	partyscreen.Visible = false
	battle.Visible = true
	if pokemonswitch ~= nil then
		return "Switch",pokemonswitch
	else
	end
end

