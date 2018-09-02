-- See LICENSE for terms

local MsgPopup = ChoGGi.ComFuncs.MsgPopup
local Trans = ChoGGi.ComFuncs.Translate
local S = ChoGGi.Strings
local default_icon = "UI/Icons/Sections/spaceship.tga"

local type,tostring = type,tostring

function ChoGGi.MenuFuncs.InstantMissionGoal()
	local UICity = UICity

	local goal = UICity.mission_goal
	local target = GetMissionSponsor().goal_target + 1
	-- different goals use different targets, we'll just set them all
	goal.analyzed = target
	goal.amount = target
	goal.researched = target
	goal.colony_approval_sol = UICity.day
	ChoGGi.Temp.InstantMissionGoal = true
	MsgPopup(
		302535920001158--[[Mission goal--]],
		589254325694--[[Goal--]],
		default_icon
	)
end

function ChoGGi.MenuFuncs.InstantColonyApproval()
	CreateRealTimeThread(WaitPopupNotification, "ColonyViabilityExit_Delay")
	Msg("ColonyApprovalPassed")
	g_ColonyNotViableUntil = -1
end

function ChoGGi.MenuFuncs.MeteorHealthDamage_Toggle()
	local ChoGGi = ChoGGi
	local Consts = Consts
	ChoGGi.ComFuncs.SetConstsG("MeteorHealthDamage",ChoGGi.ComFuncs.NumRetBool(Consts.MeteorHealthDamage,0,ChoGGi.Consts.MeteorHealthDamage))
	ChoGGi.ComFuncs.SetSavedSetting("MeteorHealthDamage",Consts.MeteorHealthDamage)

	ChoGGi.SettingFuncs.WriteSettings()
	MsgPopup(S[302535920001160--[["%s
Damage? Total, sir.
It's what we call a global killer.
The end of mankind. Doesn't matter where it hits. Nothing would survive, not even bacteria."--]]]:format(ChoGGi.UserSettings.MeteorHealthDamage),
		547--[[Colonists--]],
		"UI/Icons/Notifications/meteor_storm.tga",
		true
	)
end

function ChoGGi.MenuFuncs.ChangeSponsor()
	local Presets = Presets

	local ItemList = {}
	local objs = Presets.MissionSponsorPreset.Default or ""
	for i = 1, #objs do
		local obj = objs[i]
		if obj.id ~= "random" and obj.id ~= "None" then
			local descr = GetSponsorDescr(obj, false, "include rockets", true, true)
			local stats
			-- the one we want is near the end, but there's also a blank item below it
			for i = 1, #descr do
				if type(descr[i]) == "table" then
					stats = descr[i]
				end
			end

			ItemList[#ItemList+1] = {
				text = Trans(obj.display_name),
				value = obj.id,
				hint = Trans(T{obj.effect,stats[2]})
			}
		end
	end
--~ Trans(T{7549, "<hours>:<minutes>", hours = hours, minutes = minutes})
	local function CallBackFunc(choice)
		local value = choice[1].value
		if not value then
			return
		end
		local g_CurrentMissionParams = g_CurrentMissionParams
		for i = 1, #ItemList do
			-- check to make sure it isn't a fake name (no sense in saving it)
			if ItemList[i].value == value then
				-- new spons
				g_CurrentMissionParams.idMissionSponsor = value
				-- apply tech from new sponsor
				local UICity = UICity
				local sponsor = GetMissionSponsor()
				UICity:GrantTechFromProperties(sponsor)
				sponsor:game_apply(UICity)
				sponsor:EffectsApply(UICity)
				UICity:ApplyModificationsFromProperties()
				--and bonuses
				UICity:InitMissionBonuses()

				MsgPopup(
					S[302535920001161--[[Sponsor for this save is now %s--]]]:format(choice[1].text),
					302535920001162--[[Sponsor--]],
					default_icon
				)
				break
			end
		end
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = 302535920000712--[[Set Sponsor--]],
		hint = string.format("%s: %s",S[302535920000106--[[Current--]]],Trans(GetMissionSponsor().display_name)),
	}
end

--set just the bonus effects
function ChoGGi.MenuFuncs.SetSponsorBonus()
	local ChoGGi = ChoGGi
	local Presets = Presets

	local ItemList = {}
	local objs = Presets.MissionSponsorPreset.Default or ""
	for i = 1, #objs do
		local obj = objs[i]
		if obj.id ~= "random" and obj.id ~= "None" then
			local descr = GetSponsorDescr(obj, false, "include rockets", true, true)
			local stats
			-- the one we want is near the end, but there's also a blank item below it
			for i = 1, #descr do
				if type(descr[i]) == "table" then
					stats = descr[i]
				end
			end

			ItemList[#ItemList+1] = {
				text = Trans(obj.display_name),
				value = obj.id,
				hint = string.format("%s\n\n%s: %s",Trans(T{obj.effect,stats[2]}),S[302535920001165--[[Enabled Status--]]],ChoGGi.UserSettings[string.format("Sponsor%s",obj.id)])
			}
		end
	end

	local function CallBackFunc(choice)
		local value = choice[1].value
		if not value then
			return
		end
		if choice[1].check2 then
			for i = 1, #ItemList do
				local value = ItemList[i].value
				if type(value) == "string" then
					value = string.format("Sponsor%s",value)
					ChoGGi.UserSettings[value] = nil
				end
			end
		else
			for i = 1, #choice do
				for j = 1, #ItemList do
					--check to make sure it isn't a fake name (no sense in saving it)
					local value = choice[i].value
					if ItemList[j].value == value and type(value) == "string" then
						local name = string.format("Sponsor%s",value)
						if choice[1].check1 then
							ChoGGi.UserSettings[name] = nil
						else
							ChoGGi.UserSettings[name] = true
						end
						if ChoGGi.UserSettings[name] then
							ChoGGi.CodeFuncs.SetSponsorBonuses(value)
						end
					end
				end
			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(#choice,302535920001166--[[Bonuses--]]),
			302535920001162--[[Sponsor--]]
		)
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = string.format("%s %s",S[302535920001162--[[Sponsor--]]],S[302535920001166--[[Bonuses--]]]),
		hint = string.format("%s: %s\n\n%s",S[302535920000106--[[Current--]]],Trans(GetMissionSponsor().display_name),S[302535920001168--[[Modded ones are mostly ignored for now (just cargo space/research points).--]]]),
		multisel = true,
		check = {
			{
				title = 302535920001169--[[Turn Off--]],
				hint = 302535920001170--[[Turn off selected bonuses (defaults to turning on).--]],
			},
			{
				title = 302535920001171--[[Turn All Off--]],
				hint = 302535920001172--[[Turns off all bonuses.--]],
			},
		},
	}
end

function ChoGGi.MenuFuncs.ChangeCommander()
	local Presets = Presets
	local g_CurrentMissionParams = g_CurrentMissionParams
	local UICity = UICity

	local ItemList = {}
	local objs = Presets.CommanderProfilePreset.Default or ""
	for i = 1, #objs do
		local obj = objs[i]
		if obj.id ~= "random" and obj.id ~= "None" then
			ItemList[#ItemList+1] = {
				text = Trans(obj.display_name),
				value = obj.id,
				hint = Trans(obj.effect)
			}
		end
	end

	local function CallBackFunc(choice)
		local value = choice[1].value
		if not value then
			return
		end
		for i = 1, #ItemList do
			--check to make sure it isn't a fake name (no sense in saving it)
			if ItemList[i].value == value then
				-- new comm
				g_CurrentMissionParams.idCommanderProfile = value
				-- apply tech from new commmander
				local comm = GetCommanderProfile()
				local UICity = UICity

				comm:game_apply(UICity)
				comm:OnApplyEffect(UICity)
				UICity:ApplyModificationsFromProperties()

				--and bonuses
				UICity:InitMissionBonuses()

				MsgPopup(
					S[302535920001173--[[Commander for this save is now %s.--]]]:format(choice[1].text),
					302535920001174--[[Commander--]],
					default_icon
				)
				break
			end
		end
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = 302535920000716--[[Set Commander--]],
		hint = string.format("%s: %s",S[302535920000106--[[Current--]]],Trans(GetCommanderProfile().display_name)),
	}
end

--set just the bonus effects
function ChoGGi.MenuFuncs.SetCommanderBonus()
	local Presets = Presets

	local ItemList = {}
	local objs = Presets.CommanderProfilePreset.Default or ""
	for i = 1, #objs do
		local obj = objs[i]
		if obj.id ~= "random" and obj.id ~= "None" then
			ItemList[#ItemList+1] = {
				text = Trans(obj.display_name),
				value = obj.id,
				hint = string.format("%s\n\n%s: %s",Trans(obj.effect),S[302535920001165--[[Enabled Status--]]],ChoGGi.UserSettings[string.format("Commander%s",obj.id)])
			}
		end
	end

	local function CallBackFunc(choice)
		local value = choice[1].value
		if not value then
			return
		end
		if choice[1].check2 then
			for i = 1, #ItemList do
				local value = ItemList[i].value
				if type(value) == "string" then
					value = string.format("Commander%s",value)
					ChoGGi.UserSettings[value] = nil
				end
			end
		else
			for i = 1, #choice do
				for j = 1, #ItemList do
					--check to make sure it isn't a fake name (no sense in saving it)
					local value = choice[i].value
					if ItemList[j].value == value and type(value) == "string" then
						local name = string.format("Commander%s",value)
						if choice[1].check1 then
							ChoGGi.UserSettings[name] = nil
						else
							ChoGGi.UserSettings[name] = true
						end
						if ChoGGi.UserSettings[name] then
							ChoGGi.CodeFuncs.SetCommanderBonuses(value)
						end
					end
				end
			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(#choice,302535920001166--[[Bonuses--]]),
			302535920001174--[[Commander--]]
		)
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = string.format("%s %s",S[302535920001174--[[Commander--]]],S[302535920001166--[[Bonuses--]]]),
		hint = string.format("%s: %s",S[302535920000106--[[Current--]]],Trans(GetCommanderProfile().display_name)),
		multisel = true,
		check = {
			{
				title = 302535920001169--[[Turn Off--]],
				hint = 302535920001170--[[Turn off selected bonuses (defaults to turning on).--]],
			},
			{
				title = 302535920001171--[[Turn All Off--]],
				hint = 302535920001172--[[Turns off all bonuses.--]],
			},
		},
	}
end

--pick a logo
function ChoGGi.MenuFuncs.ChangeGameLogo()
	local Presets = Presets

	local ItemList = {}
	local tab = Presets.MissionLogoPreset.Default or ""
	for i = 1, #tab do
		ItemList[#ItemList+1] = {
			text = Trans(tab[i].display_name),
			value = tab[i].id,
		}
	end

	local function CallBackFunc(choice)
		-- any newly built/landed uses this logo
		local value = choice[1].value
		if not value then
			return
		end

		local function ChangeLogo(Label,Name)
			local tab = UICity.labels[Label] or ""
			for i = 1, #tab do
				local tab2 = tab[i]:GetAttaches("Logo") or ""
				for j = 1, #tab2 do
					--if tab2[j].class == "Logo" then
						local tempLogo = tab2[j]
						if tempLogo then
							tempLogo:ChangeEntity(Name)
						end
					--end
				end
			end
		end

		local tab = Presets.MissionLogoPreset.Default or ""
		for i = 1, #tab do
			if tab[i].id == value then
				-- for any new objects
				g_CurrentMissionParams.idMissionLogo = value
				local entity_name = Presets.MissionLogoPreset.Default[value].entity_name
				-- loop through rockets and change logo
				ChangeLogo("AllRockets",entity_name)
				-- same for any buildings that use the logo
				ChangeLogo("Building",entity_name)

				MsgPopup(
					choice[1].text,
					302535920001177--[[Logo--]],
					default_icon
				)
			end
		end
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = 302535920001178--[[Set New Logo--]],
		hint = string.format("%s: %s",S[302535920000106--[[Current--]]],Trans(Presets.MissionLogoPreset.Default[g_CurrentMissionParams.idMissionLogo].display_name)),
	}
end

function ChoGGi.MenuFuncs.SetDisasterOccurrence(sType)
	local mapdata = mapdata

	local ItemList = {{
		text = string.format(" %s",S[302535920000036--[[Disabled--]]]),
		value = "disabled"
	}}
	local set_name = string.format("MapSettings_%s",sType)
	local data = DataInstances[set_name]

	for i = 1, #data do
		ItemList[#ItemList+1] = {
			text = data[i].name,
			value = data[i].name
		}
	end

	local function CallBackFunc(choice)
		local value = choice[1].value
		if not value then
			return
		end

		mapdata[set_name] = value
		if sType == "Meteor" then
			RestartGlobalGameTimeThread("Meteors")
			RestartGlobalGameTimeThread("MeteorStorm")
		else
			RestartGlobalGameTimeThread(sType)
		end

		MsgPopup(
			S[302535920001179--[[%s occurrence is now: %s--]]]:format(sType,value),
			3983--[[Disasters--]],
			"UI/Icons/Sections/attention.tga"
		)
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = string.format("%s %s %s",S[302535920000129--[[Set--]]],sType,S[302535920001180--[[Disaster Occurrences--]]]),
		hint = string.format("%s: %s",S[302535920000106--[[Current--]]],mapdata[set_name]),
	}
end

function ChoGGi.MenuFuncs.ChangeRules()
	local Presets = Presets
	local GameRulesMap = GameRulesMap
	local g_CurrentMissionParams = g_CurrentMissionParams

	local ItemList = {}
	local defs = Presets.GameRules.Default
	for i = 1, #defs do
		local def = defs[i]
		if def.id ~= "random" then
			ItemList[#ItemList+1] = {
				text = Trans(def.display_name),
				value = def.id,
				hint = string.format("%s\n%s",Trans(def.description),Trans(def.flavor))
			}
		end
	end

	local function CallBackFunc(choice)
		local value = choice[1].value
		if not value then
			return
		end

		local check1 = choice[1].check1
		local check2 = choice[1].check2
		if not check1 and not check2 then
			MsgPopup(
				302535920000038--[[Pick a checkbox next time...--]],
				302535920001181--[[Rules--]],
				default_icon
			)
			return
		elseif check1 and check2 then
			MsgPopup(
				302535920000039--[[Don't pick both checkboxes next time...--]],
				302535920001181--[[Rules--]],
				default_icon
			)
			return
		end

		for i = 1, #ItemList do
			--check to make sure it isn't a fake name (no sense in saving it)
			for j = 1, #choice do
				local value = choice[j].value
				if ItemList[i].value == value then
					--new comm
					if not g_CurrentMissionParams.idGameRules then
						g_CurrentMissionParams.idGameRules = {}
					end
					if check1 then
						g_CurrentMissionParams.idGameRules[value] = true
					elseif check2 then
						g_CurrentMissionParams.idGameRules[value] = nil
					end
				end
			end
		end

		-- apply new rules, something tells me this doesn't disable old rules...
		local rules = GetActiveGameRules()
		for i = 1, #rules do
			local rule = rules[i]
			GameRulesMap[rule]:OnInitEffect(UICity)
			GameRulesMap[rule]:OnApplyEffect(UICity)
		end

		MsgPopup(
			ChoGGi.ComFuncs.SettingState(#choice,302535920000129--[[Set--]]),
			302535920001181--[[Rules--]],
			default_icon
		)
	end

	local hint = {}
	local rules = g_CurrentMissionParams.idGameRules
	if type(rules) == "table" and next(rules) then
		hint[#hint+1] = S[302535920000106--[[Current--]]]
		hint[#hint+1] = ":"
		for Key,_ in pairs(rules) do
			hint[#hint+1] = " "
			hint[#hint+1] = Trans(Presets.GameRules.Default[Key].display_name)
		end
	end

	ChoGGi.ComFuncs.OpenInListChoice{
		callback = CallBackFunc,
		items = ItemList,
		title = 302535920001182--[[Set Game Rules--]],
		hint = ChoGGi.ComFuncs.TableConcat(hint),
		multisel = true,
		check = {
			{
				title = 302535920001183--[[Add--]],
				hint = 302535920001185--[[Add selected rules--]],
			},
			{
				title = 302535920000281--[[Remove--]],
				hint = 302535920001186--[[Remove selected rules--]],
			},
		},
	}
end
