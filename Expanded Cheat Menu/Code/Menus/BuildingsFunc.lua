-- See LICENSE for terms

-- BuildingTemplates,ClassTemplates.Building

local default_icon = "UI/Icons/IPButtons/dome_buildings.tga"
local default_icon2 = "UI/Icons/Sections/storage.tga"

function OnMsg.ClassesGenerate()
	local MsgPopup = ChoGGi.ComFuncs.MsgPopup
	local RetName = ChoGGi.ComFuncs.RetName
	local Trans = ChoGGi.ComFuncs.Translate
	local S = ChoGGi.Strings

	function ChoGGi.MenuFuncs.RotateDuringPlacement_Toggle()
		local buildings = ClassTemplates.Building

		if ChoGGi.UserSettings.RotateDuringPlacement then
			-- used when starting/loading a game
			ChoGGi.UserSettings.RotateDuringPlacement = nil

			for _,bld in pairs(buildings) do
				if bld.can_rotate_during_placement_ChoGGi_orig then
					bld.can_rotate_during_placement = false
					bld.can_rotate_during_placement_ChoGGi_orig = nil
				end
			end

		else
			-- used when starting/loading a game
			ChoGGi.UserSettings.RotateDuringPlacement = true

			for _,bld in pairs(buildings) do
				if bld.can_rotate_during_placement == false then
					bld.can_rotate_during_placement_ChoGGi_orig = true
					bld.can_rotate_during_placement = true
				end
			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.RotateDuringPlacement,S[302535920001407--[[Rotate During Placement--]]]),
			S[302535920001407--[[Rotate During Placement--]]]
		)
	end

	function ChoGGi.MenuFuncs.SponsorBuildingLimits_Toggle()
		local BuildingTechRequirements = BuildingTechRequirements
		local BuildingTemplates = BuildingTemplates

		if ChoGGi.UserSettings.SponsorBuildingLimits then
			-- used when starting/loading a game
			ChoGGi.UserSettings.SponsorBuildingLimits = nil

			for _,bld in pairs(BuildingTemplates) do
				-- set each status to false if it isn't
				for i = 1, 3 do
					local str = "sponsor_status" .. i .. "_ChoGGi_orig"
					if bld[str] then
						bld["sponsor_status" .. i] = bld[str]
						bld[str] = nil
					end
				end
			end

		else
			-- used when starting/loading a game
			ChoGGi.UserSettings.SponsorBuildingLimits = true

			for id,bld in pairs(BuildingTemplates) do
				-- set each status to false if it isn't
				for i = 1, 3 do
					local str = "sponsor_status" .. i .. "_ChoGGi_orig"
					if bld[str] ~= false then
						bld["sponsor_status" .. i .. "_ChoGGi_orig"] = bld[str]
						bld[str] = false
					end
				end

				-- and this bugger screws me over on GetBuildingTechsStatus
				local name = id
				if name:find("RC") and name:find("Building") then
					name = name:gsub("Building","")
				end
				table.remove_entry(BuildingTechRequirements[id],"check_supply",name)

			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		ChoGGi.ComFuncs.UpdateBuildMenu()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SponsorBuildingLimits,S[302535920001398--[[Remove Sponsor Limits--]]]),
			S[302535920001398--[[Remove Sponsor Limits--]]]
		)
	end

	function ChoGGi.MenuFuncs.BuildOnGeysers_Toggle()
		ChoGGi.UserSettings.BuildOnGeysers = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.BuildOnGeysers)
		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.BuildOnGeysers,S[302535920000064--[[Build On Geysers--]]]),
			S[302535920000064--[[Build On Geysers--]]]
		)
	end

	function ChoGGi.MenuFuncs.SetTrainingPoints()
		local ChoGGi = ChoGGi
		local sel = ChoGGi.ComFuncs.SelObject()
		if not sel or not IsKindOf(sel,"TrainingBuilding") then
			MsgPopup(
				S[302535920001116--[[Select a %s.--]]]:format(Trans(5443--[[Training Buildings--]])),
				Trans(5443--[[Training Buildings--]])
			)
			return
		end
		local id = sel.template_name
		local name = RetName(sel)
		local DefaultSetting = sel.base_evaluation_points
		local UserSettings = ChoGGi.UserSettings

		local ItemList = {
			{text = Trans(1000121--[[Default--]]),value = DefaultSetting},
			{text = 10,value = 10},
			{text = 15,value = 15},
			{text = 20,value = 20},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 75,value = 75},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
			{text = 1000,value = 1000},
		}

		if not UserSettings.BuildingSettings[id] then
			UserSettings.BuildingSettings[id] = {}
		end

		local hint = DefaultSetting
		local setting = UserSettings.BuildingSettings[id]
		if setting and setting.evaluation_points then
			hint = setting.evaluation_points
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value

			if type(value) == "number" then
				local objs = ChoGGi.ComFuncs.RetAllOfClass(sel.class)

				if value == DefaultSetting then
					setting.evaluation_points = nil
					-- remove setting so it uses base_ value
					for i = 1, #objs do
						objs[i].evaluation_points = nil
					end
				else
					setting.evaluation_points = value
					for i = 1, #objs do
						objs[i].evaluation_points = value
					end
				end

				ChoGGi.SettingFuncs.WriteSettings()
				MsgPopup(
					ChoGGi.ComFuncs.SettingState(choice[1].value,S[302535920001344--[[Points To Train--]]]),
					name
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = name .. ": " .. S[302535920001344--[[Points To Train--]]],
			hint = S[302535920000106--[[Current--]]] .. ": " .. hint,
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.SetServiceBuildingStats()
		local ChoGGi = ChoGGi
		local sel = ChoGGi.ComFuncs.SelObject()
		if not sel or not IsKindOf(sel,"StatsChange") then
			MsgPopup(
				S[302535920001116--[[Select a %s.--]]]:format(Trans(5439--[[Service Buildings--]])),
				Trans(4810--[[Service--]]),
				"UI/Icons/Sections/morale.tga"
			)
			return
		end
		local r = ChoGGi.Consts.ResourceScale
		local id = sel.template_name
		local ServiceInterestsList = table.concat(ServiceInterestsList,", ")
		local name = RetName(sel)
		local is_service = sel:IsKindOf("Service")

		local ReturnEditorType = ChoGGi.ComFuncs.ReturnEditorType
		local hint_type = S[302535920000138--[[Value needs to be a %s.--]]]
		local ItemList = {
			{text = Trans(728--[[Health change on visit--]]),value = sel.base_health_change / r,setting = "health_change",hint = hint_type:format(ReturnEditorType(sel.properties,"id","health_change"))},
			{text = Trans(729--[[Sanity change on visit--]]),value = sel.base_sanity_change / r,setting = "sanity_change",hint = hint_type:format(ReturnEditorType(sel.properties,"id","sanity_change"))},
			{text = Trans(730--[[Service Comfort--]]),value = sel.base_service_comfort / r,setting = "service_comfort",hint = hint_type:format(ReturnEditorType(sel.properties,"id","service_comfort"))},
			{text = Trans(731--[[Comfort increase on visit--]]),value = sel.base_comfort_increase / r,setting = "comfort_increase",hint = hint_type:format(ReturnEditorType(sel.properties,"id","comfort_increase"))},
		}
		if is_service then
			ItemList[#ItemList+1] = {text = Trans(734--[[Visit duration--]]),value = sel.base_visit_duration,setting = "visit_duration",hint = hint_type:format(ReturnEditorType(sel.properties,"id","visit_duration"))}
			-- bool
			ItemList[#ItemList+1] = {text = Trans(735--[[Usable by children--]]),value = sel.base_usable_by_children,setting = "usable_by_children",hint = hint_type:format(ReturnEditorType(sel.properties,"id","usable_by_children"))}
			ItemList[#ItemList+1] = {text = Trans(736--[[Children Only--]]),value = sel.base_children_only,setting = "children_only",hint = hint_type:format(ReturnEditorType(sel.properties,"id","children_only"))}

			for i = 1, 11 do
				local name = "interest" .. i
				ItemList[#ItemList+1] = {
					text = Trans(732--[[Service interest--]]) .. " " .. i,
					value = sel[name],
					setting = name,
					hint = hint_type:format(ReturnEditorType(sel.properties,"id",name)) .. "\n\n" .. ServiceInterestsList,
				}
			end
		end

		local BuildingSettings = ChoGGi.UserSettings.BuildingSettings
		if not BuildingSettings[id] then
			BuildingSettings[id] = {}
		end

		local bs_setting = BuildingSettings[id]
		if not bs_setting.service_stats then
			bs_setting.service_stats = {}
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local set = S[302535920000129--[[Set--]]]

			if choice[1].check1 then
				set = Trans(1000121--[[Default--]])

				bs_setting.service_stats = nil
				-- get defaults
				local temp = {
					health_change = sel:GetDefaultPropertyValue("health_change"),
					sanity_change = sel:GetDefaultPropertyValue("sanity_change"),
					service_comfort = sel:GetDefaultPropertyValue("service_comfort"),
					comfort_increase = sel:GetDefaultPropertyValue("comfort_increase"),
				}
				if is_service then
					temp.visit_duration = sel:GetDefaultPropertyValue("visit_duration")
					temp.usable_by_children = sel:GetDefaultPropertyValue("usable_by_children")
					temp.children_only = sel:GetDefaultPropertyValue("children_only")
					for i = 1, 11 do
						local name = "interest" .. i
						temp[name] = sel:GetDefaultPropertyValue(name)
					end
				end

				-- reset existing to defaults
				local objs = ChoGGi.ComFuncs.RetAllOfClass(id)
				for i = 1, #objs do
					local obj = objs[i]
					obj.base_health_change = temp.health_change
					obj.base_sanity_change = temp.sanity_change
					obj.base_service_comfort = temp.service_comfort
					obj.base_comfort_increase = temp.comfort_increase
					if is_service then
						obj.base_visit_duration = temp.visit_duration
						obj.base_usable_by_children = temp.usable_by_children
						obj.base_children_only = temp.children_only
						for j = 1, 11 do
							local name = "interest" .. j
							obj[name] = temp[name]
						end
					end
				end
			else
				-- build setting to save
				for i = 1,#choice do
					local setting = choice[i].setting
					local value,value_type = ChoGGi.ComFuncs.RetProperType(choice[i].value)
					-- check user added correct
					local editor_type = ReturnEditorType(sel.properties,"id",setting)
					if value_type == editor_type then
						if editor_type == "number" then
							bs_setting.service_stats[setting] = value * r
						elseif value == "" then
							bs_setting.service_stats[setting] = nil
						else
							bs_setting.service_stats[setting] = value
						end
					end
				end
				-- update existing buildings
				local objs = ChoGGi.ComFuncs.RetAllOfClass(id)
				local UpdateServiceComfortBld = ChoGGi.ComFuncs.UpdateServiceComfortBld
				for i = 1, #objs do
					UpdateServiceComfortBld(objs[i],bs_setting.service_stats)
				end
			end

			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				ChoGGi.ComFuncs.SettingState(set),
				S[302535920001114--[[Service Building Stats--]]],
				"UI/Icons/Sections/morale.tga"
			)
		end

		local custom_settings = false
		if next(bs_setting.service_stats) then
			custom_settings = true
		end
		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000129--[[Set--]]] .. " " .. name .. " " .. S[302535920001114--[[Service Building Stats--]]],
			hint = S[302535920001339--[[Are settings custom: %s--]]]:format(custom_settings),
			hint = S[302535920001340--[[Invalid settings will be skipped.--]]] .. "\n\n" .. S[302535920001339--[[Are settings custom: %s--]]]:format(custom_settings),
			custom_type = 4,
			check = {
				{
					title = Trans(1000121--[[Default--]]),
					hint = S[302535920001338--[[Reset to default.--]]],
				},
			},
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.SetExportWhenThisAmount()
		local ChoGGi = ChoGGi
		local DefaultSetting = Trans(1000121--[[Default--]])
		local UserSettings = ChoGGi.UserSettings
		local id = "SpaceElevator"
		local ItemList = {
			{text = DefaultSetting,value = DefaultSetting},
			{text = 10,value = 10},
			{text = 15,value = 15},
			{text = 20,value = 20},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 75,value = 75},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
			{text = 1000,value = 1000},
		}

		if not UserSettings.BuildingSettings[id] then
			UserSettings.BuildingSettings[id] = {}
		end

		local hint = DefaultSetting
		local setting = UserSettings.BuildingSettings[id]
		if setting and setting.export_when_this_amount then
			hint = setting.export_when_this_amount
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value

			if value == DefaultSetting then
				setting.export_when_this_amount = nil
			else
				setting.export_when_this_amount = value * ChoGGi.Consts.ResourceScale
			end

			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				ChoGGi.ComFuncs.SettingState(choice[1].value,S[302535920001336--[[Export When This Amount--]]]),
				S[302535920001336--[[Export When This Amount--]]],
				"UI/Icons/Sections/basic_active.tga"
			)
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920001336--[[Export When This Amount--]]],
			hint = S[302535920000106--[[Current--]]] .. ": " .. hint,
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.SetSpaceElevatorTransferAmount(setting_name,title)
		local ChoGGi = ChoGGi
		local r = ChoGGi.Consts.ResourceScale
		local DefaultSetting = SpaceElevator[setting_name] / r
		local UserSettings = ChoGGi.UserSettings
		local id = "SpaceElevator"
		local ItemList = {
			{text = Trans(1000121--[[Default--]]) .. ": " .. DefaultSetting,value = DefaultSetting},
			{text = 10,value = 10},
			{text = 15,value = 15},
			{text = 20,value = 20},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 75,value = 75},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
			{text = 1000,value = 1000},
		}

		if not UserSettings.BuildingSettings[id] then
			UserSettings.BuildingSettings[id] = {}
		end

		local hint = DefaultSetting
		local setting = UserSettings.BuildingSettings[id]
		if setting and setting[setting_name] then
			hint = setting[setting_name]
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value
			if type(value) == "number" then
				value = value * r

				if value == DefaultSetting * r then
					setting[setting_name] = nil
				else
					setting[setting_name] = value
				end

				local objs = UICity.labels.SpaceElevator or ""
				for i = 1, #objs do
					ChoGGi.ComFuncs.SetTaskReqAmount(objs[i],value,"export_request",setting_name)
				end

				ChoGGi.SettingFuncs.WriteSettings()
				MsgPopup(
					ChoGGi.ComFuncs.SettingState(choice[1].text,S[title]),
					S[302535920001332--[[Export Amount Per Trip--]]],
					"UI/Icons/Sections/basic_active.tga"
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[title],
			hint = S[302535920000106--[[Current--]]] .. ": " .. hint,
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.SpaceElevatorExport_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.SpaceElevatorToggleInstantExport = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.SpaceElevatorToggleInstantExport)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SpaceElevatorToggleInstantExport,S[302535920001330--[[Instant Export On Toggle--]]]),
			S[302535920001330--[[Instant Export On Toggle--]]]
		)
	end

	function ChoGGi.MenuFuncs.SetStorageAmountOfDinerGrocery()
		local DefaultSetting = 5
		local UserSettings = ChoGGi.UserSettings
		local r = ChoGGi.Consts.ResourceScale
		local ItemList = {
			{text = Trans(1000121--[[Default--]]) .. ": " .. DefaultSetting,value = DefaultSetting},
			{text = 10,value = 10},
			{text = 15,value = 15},
			{text = 20,value = 20},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 75,value = 75},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
		}

		-- other hint type
		local hint = DefaultSetting
		if UserSettings.ServiceWorkplaceFoodStorage then
			hint = UserSettings.ServiceWorkplaceFoodStorage
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value
			if type(value) == "number" then
				value = value * r

				if value == DefaultSetting * r then
					UserSettings.ServiceWorkplaceFoodStorage = nil
				else
					UserSettings.ServiceWorkplaceFoodStorage = value
				end

				local function SetStor(cls)
					local objs = ChoGGi.ComFuncs.RetAllOfClass(cls)
					for i = 1, #objs do
						objs[i].consumption_stored_resources = value
						objs[i].consumption_max_storage = value
					end
				end
				SetStor("Diner")
				SetStor("Grocery")

				ChoGGi.SettingFuncs.WriteSettings()
				MsgPopup(
					ChoGGi.ComFuncs.SettingState(choice[1].text,Trans(8830--[[Food Storage--]])),
					S[302535920000164--[[Storage Amount Of Diner & Grocery--]]],
					"UI/Icons/Sections/Food_1.tga"
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000105--[[Set Food Storage--]]],
			hint = S[302535920000106--[[Current--]]] .. ": " .. hint,
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.AlwaysDustyBuildings_Toggle()
		if ChoGGi.UserSettings.AlwaysDustyBuildings then
			ChoGGi.UserSettings.AlwaysDustyBuildings = nil
			-- dust clean up
			local objs = UICity.labels.Building or ""
			for i = 1, #objs do
				objs[i].ChoGGi_AlwaysDust = nil
			end
		else
			ChoGGi.UserSettings.AlwaysDustyBuildings = true
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000107--[[%s: I must not fear. Fear is the mind-killer. Fear is the little-death that brings total obliteration.
	I will face my fear. I will permit it to pass over me and through me,
	and when it has gone past I will turn the inner eye to see its path.
	Where the fear has gone there will be nothing. Only I will remain.--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.AlwaysDustyBuildings)),
			S[302535920000174--[[Always Dusty--]]],
			nil,
			true
		)
	end

	local function DustCleanUp(label)
		for i = 1, #label do
			ApplyToObjAndAttaches(label[i], SetObjDust, 0)
		end
	end
	function ChoGGi.MenuFuncs.AlwaysCleanBuildings_Toggle()
		if ChoGGi.UserSettings.AlwaysCleanBuildings then
			ChoGGi.UserSettings.AlwaysCleanBuildings = nil
		else
			ChoGGi.UserSettings.AlwaysCleanBuildings = true
			local labels = UICity.labels
			DustCleanUp(labels.Building or "")
			DustCleanUp(labels.GridElements or "")
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.AlwaysCleanBuildings,S[302535920000037--[[Always Clean--]]]),
			S[302535920000037--[[Always Clean--]]]
		)
	end

	function ChoGGi.MenuFuncs.SetProtectionRadius()
		local sel = ChoGGi.ComFuncs.SelObject()
		if not sel or not sel.protect_range then
			MsgPopup(
				S[302535920000108--[[Select something with a protect_range (MDSLaser/DefenceTower).--]]],
				S[302535920000178--[[Protection Radius--]]],
				"UI/Icons/Upgrades/behavioral_melding_02.tga"
			)
			return
		end
		local id = sel.template_name
		local DefaultSetting = g_Classes[id]:GetDefaultPropertyValue("protect_range")
		local ItemList = {
			{text = Trans(1000121--[[Default--]]) .. ": " .. DefaultSetting,value = DefaultSetting},
			{text = 40,value = 40},
			{text = 80,value = 80},
			{text = 160,value = 160},
			{text = 320,value = 320,hint = S[302535920000111--[[Cover the entire map from the centre.--]]]},
			{text = 640,value = 640,hint = S[302535920000112--[[Cover the entire map from a corner.--]]]},
		}

		if not ChoGGi.UserSettings.BuildingSettings[id] then
			ChoGGi.UserSettings.BuildingSettings[id] = {}
		end

		local hint = DefaultSetting
		local setting = ChoGGi.UserSettings.BuildingSettings[id]
		if setting and setting.protect_range then
			hint = tostring(setting.protect_range)
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value
			if type(value) == "number" then

				local tab = ChoGGi.ComFuncs.RetAllOfClass(id)
				for i = 1, #tab do
					tab[i].protect_range = value
					tab[i].shoot_range = value * guim
				end

				if value == DefaultSetting then
					ChoGGi.UserSettings.BuildingSettings[id].protect_range = nil
				else
					ChoGGi.UserSettings.BuildingSettings[id].protect_range = value
				end

				ChoGGi.SettingFuncs.WriteSettings()
				MsgPopup(
					S[302535920000113--[[%s range is now %s.--]]]:format(RetName(sel),choice[1].text),
					S[302535920000178--[[Protection Radius--]]],
					"UI/Icons/Upgrades/behavioral_melding_02.tga"
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000114--[[Set Protection Radius--]]],
			hint = S[302535920000106--[[Current--]]] .. ": " .. hint .. "\n\n" ..S[302535920000115--[[Toggle selection to update visible hex grid.--]]],
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.UnlockLockedBuildings()
		local everything = S[302535920000306--[[Everything--]]]
		local ItemList = {
			{
			text = " " .. everything,
			value = everything,
			},
		}
		local c = #ItemList

		local BuildingTemplates = BuildingTemplates
		local GetBuildingTechsStatus = GetBuildingTechsStatus
		for id,bld in pairs(BuildingTemplates) do
			if not GetBuildingTechsStatus(id) then
				c = c + 1
				ItemList[c] = {
					text = Trans(bld.display_name),
					value = id,
				}
			end
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local UnlockBuilding = UnlockBuilding
			-- if everything then ignore the choices and just use the itemlist
			if table.find(choice,"value",everything) then
				choice = ItemList
			end

			for i = 1, #choice do
				UnlockBuilding(choice[i].value)
			end
			ChoGGi.ComFuncs.UpdateBuildMenu()
			MsgPopup(
				S[302535920000116--[[%s: Buildings unlocked.--]]]:format(#choice),
				S[302535920000180--[[Unlock Locked Buildings--]]],
				default_icon
			)
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000117--[[Unlock Buildings--]]],
			hint = S[302535920000118--[[Pick the buildings you want to unlock (use Ctrl/Shift for multiple).--]]],
			multisel = true,
		}
	end

	function ChoGGi.MenuFuncs.PipesPillarsSpacing_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.ComFuncs.SetConstsG("PipesPillarSpacing",ChoGGi.ComFuncs.ValueRetOpp(Consts.PipesPillarSpacing,1000,ChoGGi.Consts.PipesPillarSpacing))
		ChoGGi.ComFuncs.SetSavedSetting("PipesPillarSpacing",Consts.PipesPillarSpacing)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000119--[[%s: Is that a rocket in your pocket?--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.PipesPillarSpacing)),
			S[302535920000182--[[Pipes Pillars Spacing--]]]
		)
	end

	function ChoGGi.MenuFuncs.UnlimitedConnectionLength_Toggle()
		local ChoGGi = ChoGGi
		if ChoGGi.UserSettings.UnlimitedConnectionLength then
			ChoGGi.UserSettings.UnlimitedConnectionLength = nil
			GridConstructionController.max_hex_distance_to_allow_build = 20
			const.PassageConstructionGroupMaxSize = 20
		else
			ChoGGi.UserSettings.UnlimitedConnectionLength = true
			GridConstructionController.max_hex_distance_to_allow_build = 1000
			const.PassageConstructionGroupMaxSize = 1000
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000119--[[%s: Is that a rocket in your pocket?--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.UnlimitedConnectionLength)),
			S[302535920000184--[[Unlimited Connection Length--]]]
		)
	end

	local function BuildingConsumption_Toggle(type1,str1,type2,func1,func2,str2)
		local ChoGGi = ChoGGi
		local sel = SelectedObj
		if not sel or not sel[type1] then
			MsgPopup(
				str1,
				Trans(3980--[[Buildings--]]),
				default_icon
			)
			return
		end
		local id = sel.template_name
		local UserSettings = ChoGGi.UserSettings

		if not UserSettings.BuildingSettings[id] then
			UserSettings.BuildingSettings[id] = {}
		end

		local setting = UserSettings.BuildingSettings[id]
		local which
		if setting[type2] then
			setting[type2] = nil
			which = func1
		else
			setting[type2] = true
			which = func2
		end

		local ComFuncs = ChoGGi.ComFuncs
		local blds = ComFuncs.RetAllOfClass(id)
		for i = 1, #blds do
			ComFuncs[which](blds[i])
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			RetName(sel) .. " " .. str2,
			which,
			default_icon
		)
	end

	function ChoGGi.MenuFuncs.BuildingPower_Toggle()
		BuildingConsumption_Toggle(
			"electricity_consumption",
			S[302535920000120--[[You need to select a building that uses electricity.--]]],
			"nopower",
			"AddBuildingElecConsump",
			"RemoveBuildingElecConsump",
			Trans(683--[[Power Consumption--]])
		)
	end

	function ChoGGi.MenuFuncs.BuildingWater_Toggle()
		BuildingConsumption_Toggle(
			"water_consumption",
			S[302535920000121--[[You need to select a building that uses water.--]]],
			"nowater",
			"AddBuildingWaterConsump",
			"RemoveBuildingWaterConsump",
			Trans(656--[[Water consumption--]])
		)
	end

	function ChoGGi.MenuFuncs.BuildingAir_Toggle()
		BuildingConsumption_Toggle(
			"air_consumption",
			S[302535920001250--[[You need to select a building that uses oxygen.--]]],
			"noair",
			"AddBuildingAirConsump",
			"RemoveBuildingAirConsump",
			Trans(657--[[Oxygen Consumption--]])
		)
	end

	function ChoGGi.MenuFuncs.SetMaxChangeOrDischarge()
		local ChoGGi = ChoGGi
		local sel = SelectedObj
		if not sel or (not sel.base_air_capacity and not sel.base_water_capacity and not sel.base_capacity) then
			MsgPopup(
				S[302535920000122--[[You need to select something that has capacity (air/water/elec).--]]],
				S[302535920000188--[[Set Charge & Discharge Rates--]]],
				default_icon
			)
			return
		end
		local id = sel.template_name
		local name = Trans(sel.display_name)
		local r = ChoGGi.Consts.ResourceScale

		--get type of capacity
		local CapType
		if sel.base_air_capacity then
			CapType = "air"
		elseif sel.base_water_capacity then
			CapType = "water"
		elseif sel.electricity and sel.electricity.storage_capacity then
			CapType = "electricity"
		end
		--probably selected something with colonists
		if not CapType then
			return
		end

		--get default amount
		local template = BuildingTemplates[id]
		local DefaultSettingC = template["max_" .. CapType .. "_charge"] / r
		local DefaultSettingD = template["max_" .. CapType .. "_discharge"] / r

		local ItemList = {
			{text = Trans(1000121--[[Default--]]),value = Trans(1000121--[[Default--]]),hint = S[302535920000124--[[Charge--]]]
				.. ": " .. DefaultSettingC .. " / " .. S[302535920000125--[[Discharge--]]]
				.. ": " .. DefaultSettingD},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 75,value = 75},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
			{text = 1000,value = 1000},
			{text = 2500,value = 2500},
			{text = 5000,value = 5000},
			{text = 10000,value = 10000},
		}

		--check if there's an entry for building
		if not ChoGGi.UserSettings.BuildingSettings[id] then
			ChoGGi.UserSettings.BuildingSettings[id] = {}
		end

		local hint = S[302535920000124--[[Charge--]]] .. ": " .. DefaultSettingC .. " / " .. S[302535920000125--[[Discharge--]]] .. ": " .. DefaultSettingD
		local setting = ChoGGi.UserSettings.BuildingSettings[id]
		if setting then
			if setting.charge and setting.discharge then
				hint = S[302535920000124--[[Charge--]]] .. ": " .. (setting.charge / r) .. " / " .. S[302535920000125--[[Discharge--]]] .. ": " .. (setting.discharge / r)
			elseif setting.charge then
				hint = setting.charge / r
			elseif setting.discharge then
				hint = setting.discharge / r
			end
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value
			local check1 = choice[1].check1
			local check2 = choice[1].check2

			if type(value) == "number" then
				local numberC = value * r
				local numberD = value * r

				if value == Trans(1000121--[[Default--]]) then
					if check1 then
						setting.charge = nil
						numberC = DefaultSettingC * r
					end
					if check2 then
						setting.discharge = nil
						numberD = DefaultSettingD * r
					end
				else
					if check1 then
						setting.charge = numberC
					end
					if check2 then
						setting.discharge = numberD
					end
				end

				-- updating time
				local str1,str2 = "max_" .. CapType .. "_charge","max_" .. CapType .. "_discharge"
				if CapType == "electricity" then
					local tab = UICity.labels.Power or ""
					for i = 1, #tab do
						if tab[i].template_name == id then
							if check1 then
								tab[i][CapType].max_charge = numberC
								tab[i][str1] = numberC
							end
							if check2 then
								tab[i][CapType].max_discharge = numberD
								tab[i][str2] = numberD
							end
							ChoGGi.ComFuncs.ToggleWorking(tab[i])
						end
					end
				else -- water and air
					local tab = UICity.labels["Life-Support"] or ""
					for i = 1, #tab do
						if tab[i].template_name == id then
							if check1 then
								tab[i][CapType].max_charge = numberC
								tab[i][str1] = numberC
							end
							if check2 then
								tab[i][CapType].max_discharge = numberD
								tab[i][str2] = numberD
							end
							ChoGGi.ComFuncs.ToggleWorking(tab[i])
						end
					end
				end

				ChoGGi.SettingFuncs.WriteSettings()
				MsgPopup(
					S[302535920000128--[[%s rate is now: %s--]]]:format(RetName(sel),choice[1].text),
					S[302535920000188--[[Set Charge & Discharge Rates--]]],
					default_icon2
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000129--[[Set--]]] .. " " .. name .. " " .. S[302535920000130--[[Dis/Charge Rates--]]],
			hint = S[302535920000131--[[Current rate--]]] .. ": " .. hint,
			check = {
				at_least_one = true,
				{
					title = S[302535920000124--[[Charge--]]],
					hint = S[302535920000132--[[Change charge rate--]]],
					checked = true,
				},
				{
					title = S[302535920000125--[[Discharge--]]],
					hint = S[302535920000133--[[Change discharge rate--]]],
				},
			},
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.FarmShiftsAllOn()
		local UICity = UICity
		local tab = UICity.labels.BaseFarm or ""
		for i = 1, #tab do
			tab[i].closed_shifts[1] = false
			tab[i].closed_shifts[2] = false
			tab[i].closed_shifts[3] = false
		end
		--BaseFarm doesn't include FungalFarm...
		tab = UICity.labels.FungalFarm or ""
		for i = 1, #tab do
			tab[i].closed_shifts[1] = false
			tab[i].closed_shifts[2] = false
			tab[i].closed_shifts[3] = false
		end

		MsgPopup(
			S[302535920000135--[[Well, I been working in a coal mine
	Going down, down
	Working in a coal mine
	Whew, about to slip down--]]],
			S[302535920000192--[[Farm Shifts All On--]]],
			"UI/Icons/Sections/Food_2.tga",
			true
		)
	end

	function ChoGGi.MenuFuncs.SetProductionAmount()
		local ChoGGi = ChoGGi
		local sel = SelectedObj
		if not sel or (not sel.base_air_production and not sel.base_water_production and not sel.base_electricity_production and not sel.producers) then
			MsgPopup(
				S[302535920000136--[[Select something that produces (air,water,electricity,other).--]]],
				S[302535920000194--[[Production Amount Set--]]],
				default_icon2
			)
			return
		end
		local id = sel.template_name
		local name = Trans(sel.display_name)

		--get type of producer
		local ProdType
		if sel.base_air_production then
			ProdType = "air"
		elseif sel.base_water_production then
			ProdType = "water"
		elseif sel.base_electricity_production then
			ProdType = "electricity"
		elseif sel.producers then
			ProdType = "other"
		end

		--get base amount
		local r = ChoGGi.Consts.ResourceScale
		local DefaultSetting
		if ProdType == "other" then
			DefaultSetting = sel.base_production_per_day1 / r
		else
			DefaultSetting = sel["base_" .. ProdType .. "_production"] / r
		end

		local ItemList = {
			{text = Trans(1000121--[[Default--]]) .. ": " .. DefaultSetting,value = DefaultSetting},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 75,value = 75},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
			{text = 1000,value = 1000},
			{text = 2500,value = 2500},
			{text = 5000,value = 5000},
			{text = 10000,value = 10000},
			{text = 25000,value = 25000},
			{text = 50000,value = 50000},
			{text = 100000,value = 100000},
		}

		-- check if there's an entry for building
		if not ChoGGi.UserSettings.BuildingSettings[id] then
			ChoGGi.UserSettings.BuildingSettings[id] = {}
		end

		local hint = DefaultSetting
		local setting = ChoGGi.UserSettings.BuildingSettings[id]
		if setting and setting.production then
			hint = tostring(setting.production / r)
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value
			if type(value) == "number" then
				local amount = value * r

				-- setting we use to actually update prod
				if value == DefaultSetting then
					-- remove setting as we reset building type to default (we don't want to call it when we place a new building if nothing is going to be changed)
					ChoGGi.UserSettings.BuildingSettings[id].production = nil
				else
					-- update/create saved setting
					ChoGGi.UserSettings.BuildingSettings[id].production = amount
				end

				-- all this just to update the displayed amount :)
				local function SetProd(label)
					local tab = ChoGGi.ComFuncs.RetAllOfClass(label)
					for i = 1, #tab do
						if tab[i].template_name == id then
							tab[i][ProdType]:SetProduction(amount)
						end
					end
				end
				if ProdType == "electricity" then
					-- electricity
					SetProd("Power")
				elseif ProdType == "water" or ProdType == "air" then
					-- water/air
					SetProd("Life-Support")
				else -- other prod

					local function SetProdOther(label)
						local tab = ChoGGi.ComFuncs.RetAllOfClass(label)
						for i = 1, #tab do
							if tab[i].template_name == id then
								tab[i]:GetProducerObj().production_per_day = amount
								tab[i]:GetProducerObj():Produce(amount)
							end
						end
					end
					-- extractors/factories
					SetProdOther("Production")
					-- moholemine/theexvacator
					SetProdOther("Wonders")
					-- farms
					if id:find("Farm") then
						SetProdOther("BaseFarm")
						SetProdOther("FungalFarm")
					end
				end

			end

			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				S[302535920000137--[[%s production is now: %s--]]]:format(RetName(sel),choice[1].text),
				S[302535920000194--[[Production Amount Set--]]],
				default_icon2
			)
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000129--[[Set--]]] .. " " .. name .. " " .. S[302535920000139--[[Production Amount--]]],
			hint = S[302535920000140--[[Current production--]]] .. ": " .. hint,
			skip_sort = true,
		}
	end

	function ChoGGi.MenuFuncs.SetFullyAutomatedBuildings()
		local ChoGGi = ChoGGi
		local sel = SelectedObj
		if not sel or not IsKindOf(sel,"Workplace") then
			MsgPopup(
				S[302535920000141--[[Select a building with workers.--]]],
				S[302535920000196--[[Fully Automated Building--]]],
				"UI/Icons/Upgrades/service_bots_02.tga"
			)
			return
		end
		local id = sel.template_name

		local ItemList = {
			{text = Trans(251103844022--[[Disable--]]),value = "Disable"},
			{text = 100,value = 100},
			{text = 150,value = 150},
			{text = 250,value = 250},
			{text = 500,value = 500},
			{text = 1000,value = 1000},
			{text = 2500,value = 2500},
			{text = 5000,value = 5000},
			{text = 10000,value = 10000},
			{text = 25000,value = 25000},
			{text = 50000,value = 50000},
			{text = 100000,value = 100000},
		}

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value

			if value == "Disable" then
				value = nil
				if choice[1].check then
					sel.max_workers = sel.base_max_workers
					sel.automation = sel.base_automation
					sel.auto_performance = sel.base_auto_performance
					ChoGGi.ComFuncs.ToggleWorking(sel)
				else
					local blds = ChoGGi.ComFuncs.RetAllOfClass(sel.class)
					for i = 1, #blds do
						local bld = blds[i]
						bld.max_workers = bld.base_max_workers
						bld.automation = bld.base_automation
						bld.auto_performance = bld.base_auto_performance
						ChoGGi.ComFuncs.ToggleWorking(bld)
					end
				end
			elseif type(value) == "number" then
				if choice[1].check then
					sel.max_workers = 0
					sel.automation = 1
					sel.auto_performance = value
					ChoGGi.ComFuncs.ToggleWorking(sel)
				else
					local blds = ChoGGi.ComFuncs.RetAllOfClass(sel.class)
					for i = 1, #blds do
						local bld = blds[i]
						bld.max_workers = 0
						bld.automation = 1
						bld.auto_performance = value
						ChoGGi.ComFuncs.ToggleWorking(bld)
					end
				end
			end

			ChoGGi.UserSettings.BuildingSettings[id].auto_performance = value
			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				S[302535920000143--[["%s
	I presume the PM's in favour of the scheme because it'll reduce unemployment."--]]]:format(choice[1].text),
				S[302535920000196--[[Fully Automated Building--]]],
				"UI/Icons/Upgrades/service_bots_02.tga",
				true
			)
		end

		-- check if there's an entry for building
		if not ChoGGi.UserSettings.BuildingSettings[id] then
			ChoGGi.UserSettings.BuildingSettings[id] = {}
		end

		local hint = "none"
		local setting = ChoGGi.UserSettings.BuildingSettings[id]
		if setting and setting.performance then
			hint = tostring(setting.performance)
		end

		local name = RetName(sel)
		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = name .. ": " .. S[302535920000144--[[Automated Performance--]]],
			hint = S[302535920000145--[[Sets performance of all automated buildings of this type--]]] .. "\n" .. S[302535920000106--[[Current--]]] .. ": " .. hint,
			check = {
				{
					title = S[302535920000769--[[Selected--]]],
					hint = S[302535920000147--[[Only apply to selected object instead of all %s.--]]]:format(name),
				},
			},
			skip_sort = true,
		}
	end

	do -- SchoolTrainAll_Toggle/SanatoriumCureAll_Toggle
		-- used to add or remove traits from schools/sanitariums
		local function BuildingsSetAll_Traits(cls,traits,bool)
			local objs = ChoGGi.ComFuncs.RetAllOfClass(cls)
			for i = 1, #objs do
				local obj = objs[i]
				for j = 1,#traits do
					if bool == true then
						obj:SetTrait(j,nil)
					else
						obj:SetTrait(j,traits[j])
					end
				end
			end
		end

		function ChoGGi.MenuFuncs.SchoolTrainAll_Toggle()
			local ChoGGi = ChoGGi
			if ChoGGi.UserSettings.SchoolTrainAll then
				ChoGGi.UserSettings.SchoolTrainAll = nil
				BuildingsSetAll_Traits("School",ChoGGi.Tables.PositiveTraits,true)
			else
				ChoGGi.UserSettings.SchoolTrainAll = true
				BuildingsSetAll_Traits("School",ChoGGi.Tables.PositiveTraits)
			end

			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				S[302535920000148--[["%s:
	You keep your work station so clean, Jerome.
	It's next to godliness. Isn't that what they say?"--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SchoolTrainAll)),
				S[302535920000200--[[Train All--]]],
				"UI/Icons/Upgrades/home_collective_02.tga",
				true
			)
		end

		function ChoGGi.MenuFuncs.SanatoriumCureAll_Toggle()
			local ChoGGi = ChoGGi
			if ChoGGi.UserSettings.SanatoriumCureAll then
				ChoGGi.UserSettings.SanatoriumCureAll = nil
				BuildingsSetAll_Traits("Sanatorium",ChoGGi.Tables.NegativeTraits,true)
			else
				ChoGGi.UserSettings.SanatoriumCureAll = true
				BuildingsSetAll_Traits("Sanatorium",ChoGGi.Tables.NegativeTraits)
			end

			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				S[302535920000149--[[%s:
	There's more vodka in this piss than there is piss.--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SanatoriumCureAll)),
				S[302535920000198--[[Cure All--]]],
				"UI/Icons/Upgrades/home_collective_02.tga",
				true
			)
		end
	end -- do

	function ChoGGi.MenuFuncs.ShowAllTraits_Toggle()
		local ChoGGi = ChoGGi

		if ChoGGi.UserSettings.SanatoriumSchoolShowAllTraits then
			ChoGGi.UserSettings.SanatoriumSchoolShowAllTraits = nil
			g_SchoolTraits = table.copy(const.SchoolTraits)
			g_SanatoriumTraits = table.copy(const.SanatoriumTraits)
		else
			ChoGGi.UserSettings.SanatoriumSchoolShowAllTraits = true
			g_SchoolTraits = ChoGGi.Tables.PositiveTraits
			g_SanatoriumTraits = ChoGGi.Tables.NegativeTraits
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000150--[[%s: Good for what ails you--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SanatoriumSchoolShowAllTraits)),
			S[302535920000202--[[Show All Traits--]]],
			"UI/Icons/Upgrades/factory_ai_04.tga"
		)
	end

	function ChoGGi.MenuFuncs.SanatoriumSchoolShowAll()
		local ChoGGi = ChoGGi
		local g_Classes = g_Classes
		ChoGGi.UserSettings.SanatoriumSchoolShowAll = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.SanatoriumSchoolShowAll)

		g_Classes.Sanatorium.max_traits = ChoGGi.ComFuncs.ValueRetOpp(g_Classes.Sanatorium.max_traits,3,#ChoGGi.Tables.NegativeTraits)
		g_Classes.School.max_traits = ChoGGi.ComFuncs.ValueRetOpp(g_Classes.School.max_traits,3,#ChoGGi.Tables.PositiveTraits)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000150--[[%s: Good for what ails you--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SanatoriumSchoolShowAll)),
			S[302535920000204--[[Show Full List--]]],
			"UI/Icons/Upgrades/factory_ai_04.tga"
		)
	end

	function ChoGGi.MenuFuncs.MaintenanceFreeBuildingsInside_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.InsideBuildingsNoMaintenance = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.InsideBuildingsNoMaintenance)

		local tab = UICity.labels.InsideBuildings or ""
		for i = 1, #tab do
			if tab[i].base_maintenance_build_up_per_hr then

				if ChoGGi.UserSettings.InsideBuildingsNoMaintenance then
					tab[i].ChoGGi_InsideBuildingsNoMaintenance = true
					tab[i].maintenance_build_up_per_hr = -10000
				else
					if not tab[i].ChoGGi_RemoveMaintenanceBuildUp then
						tab[i].maintenance_build_up_per_hr = nil
					end
					tab[i].ChoGGi_InsideBuildingsNoMaintenance = nil
				end

			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000151--[[%s: The spice must flow!--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.InsideBuildingsNoMaintenance)),
			S[302535920000206--[[Maintenance Free Inside--]]],
			"UI/Icons/Sections/dust.tga"
		)
	end

	function ChoGGi.MenuFuncs.MaintenanceFreeBuildings_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.RemoveMaintenanceBuildUp = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.RemoveMaintenanceBuildUp)

		local tab = UICity.labels.Building or ""
		for i = 1, #tab do
			if tab[i].base_maintenance_build_up_per_hr then
				if ChoGGi.UserSettings.RemoveMaintenanceBuildUp then
					tab[i].ChoGGi_RemoveMaintenanceBuildUp = true
					tab[i].maintenance_build_up_per_hr = -10000
				elseif not tab[i].ChoGGi_InsideBuildingsNoMaintenance then
					tab[i].ChoGGi_RemoveMaintenanceBuildUp = nil
					tab[i].maintenance_build_up_per_hr = nil
				end
			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000151--[[%s: The spice must flow!--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.RemoveMaintenanceBuildUp)),
			S[302535920000208--[[Maintenance Free--]]],
			"UI/Icons/Sections/dust.tga"
		)
	end

	function ChoGGi.MenuFuncs.MoistureVaporatorPenalty_Toggle()
		local ChoGGi = ChoGGi
		local const = const
		const.MoistureVaporatorRange = ChoGGi.ComFuncs.NumRetBool(const.MoistureVaporatorRange,0,ChoGGi.Consts.MoistureVaporatorRange)
		const.MoistureVaporatorPenaltyPercent = ChoGGi.ComFuncs.NumRetBool(const.MoistureVaporatorPenaltyPercent,0,ChoGGi.Consts.MoistureVaporatorPenaltyPercent)
		ChoGGi.ComFuncs.SetSavedSetting("MoistureVaporatorRange",const.MoistureVaporatorRange)
		ChoGGi.ComFuncs.SetSavedSetting("MoistureVaporatorRange",const.MoistureVaporatorPenaltyPercent)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000152--[["%s: Pussy, pussy, pussy! Come on in Pussy lovers! Here at the Titty Twister we�re slashing pussy in half! Give us an offer on our vast selection of pussy! This is a pussy blow out!
	Alright, we got white pussy, black pussy, spanish pussy, yellow pussy. We got hot pussy, cold pussy. We got wet pussy. We got smelly pussy. We got hairy pussy, bloody pussy. We got snapping pussy. We got silk pussy, velvet pussy, naugahyde pussy. We even got horse pussy, dog pussy, chicken pussy.
	C'mon, you want pussy, come on in Pussy Lovers! If we don�t got it, you don't want it! Come on in Pussy lovers!Attention pussy shoppers!
	Take advantage of our penny pussy sale! If you buy one piece of pussy at the regular price, you get another piece of pussy of equal or lesser value for only a penny!
	Try and beat pussy for a penny! If you can find cheaper pussy anywhere, fuck it!"--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.MoistureVaporatorRange)),
			S[302535920000210--[[Moisture Vaporator Penalty--]]],
			"UI/Icons/Upgrades/zero_space_04.tga",
			true
		)
	end

	function ChoGGi.MenuFuncs.CropFailThreshold_Toggle()
		local ChoGGi = ChoGGi
		local Consts = Consts
		Consts.CropFailThreshold = ChoGGi.ComFuncs.NumRetBool(Consts.CropFailThreshold,0,ChoGGi.Consts.CropFailThreshold)
		ChoGGi.ComFuncs.SetSavedSetting("CropFailThreshold",Consts.CropFailThreshold)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000153--[["%s:
	So, er, we the crew of the Eagle 5, if we do encounter, make first contact with alien beings,
	it is a friendship greeting from the children of our small but great planet of Potatoho."--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.CropFailThreshold)),
			Trans(4711--[[Crop Fail Threshold--]]),
			"UI/Icons/Sections/Food_1.tga",
			true
		)
	end

	function ChoGGi.MenuFuncs.CheapConstruction_Toggle()
		local list = {
			"Metals_cost_modifier",
			"Metals_dome_cost_modifier",
			"PreciousMetals_cost_modifier",
			"PreciousMetals_dome_cost_modifier",
			"Concrete_cost_modifier",
			"Concrete_dome_cost_modifier",
			"Polymers_dome_cost_modifier",
			"Polymers_cost_modifier",
			"Electronics_cost_modifier",
			"Electronics_dome_cost_modifier",
			"MachineParts_cost_modifier",
			"MachineParts_dome_cost_modifier",
			"rebuild_cost_modifier",
		}

		local Consts = Consts
		local cConsts = ChoGGi.Consts
		local SetConstsG = ChoGGi.ComFuncs.SetConstsG
		local ValueRetOpp = ChoGGi.ComFuncs.ValueRetOpp
		local SetSavedSetting = ChoGGi.ComFuncs.SetSavedSetting
		for i = 1, #list do
			local name = list[i]
			SetConstsG(name,ValueRetOpp(Consts[name],-100,cConsts[name]))
			SetSavedSetting(name,Consts[name])
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000154--[[%s:
Your home will not be a hut on some swampy outback planet your home will be the entire universe.--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.Metals_cost_modifier)),
			S[302535920000214--[[Cheap Construction--]]],
			"UI/Icons/Upgrades/build_2.tga"
		)
	end

	function ChoGGi.MenuFuncs.BuildingDamageCrime_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.ComFuncs.SetConstsG("CrimeEventSabotageBuildingsCount",ChoGGi.ComFuncs.ToggleBoolNum(Consts.CrimeEventSabotageBuildingsCount))
		ChoGGi.ComFuncs.SetConstsG("CrimeEventDestroyedBuildingsCount",ChoGGi.ComFuncs.ToggleBoolNum(Consts.CrimeEventDestroyedBuildingsCount))
		ChoGGi.ComFuncs.SetSavedSetting("CrimeEventSabotageBuildingsCount",Consts.CrimeEventSabotageBuildingsCount)
		ChoGGi.ComFuncs.SetSavedSetting("CrimeEventDestroyedBuildingsCount",Consts.CrimeEventDestroyedBuildingsCount)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000155--[[%s:
	We were all feeling a bit shagged and fagged and fashed,
	it having been an evening of some small energy expenditure, O my brothers.
	So we got rid of the auto and stopped off at the Korova for a nightcap.--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.CrimeEventSabotageBuildingsCount)),
			S[302535920000216--[[Building Damage Crime--]]],
			"UI/Icons/Notifications/fractured_dome.tga",
			true
		)
	end

	function ChoGGi.MenuFuncs.CablesAndPipesNoBreak_Toggle()
		local ChoGGi = ChoGGi
		local const = const
		ChoGGi.UserSettings.BreakChanceCablePipe = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.BreakChanceCablePipe)

		const.BreakChanceCable = ChoGGi.ComFuncs.ValueRetOpp(const.BreakChanceCable,600,10000000)
		const.BreakChancePipe = ChoGGi.ComFuncs.ValueRetOpp(const.BreakChancePipe,600,10000000)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000156--[[%s: Aliens? We gotta deal with aliens too?--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.BreakChanceCablePipe)),
			S[302535920000218--[[No Chance Of Break--]]],
			"UI/Icons/Notifications/timer.tga"
		)
	end

	function ChoGGi.MenuFuncs.CablesAndPipesInstant_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.ComFuncs.SetConstsG("InstantCables",ChoGGi.ComFuncs.ToggleBoolNum(Consts.InstantCables))
		ChoGGi.ComFuncs.SetConstsG("InstantPipes",ChoGGi.ComFuncs.ToggleBoolNum(Consts.InstantPipes))
		ChoGGi.ComFuncs.SetSavedSetting("InstantCables",Consts.InstantCables)
		ChoGGi.ComFuncs.SetSavedSetting("InstantPipes",Consts.InstantPipes)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000156--[[%s: Aliens? We gotta deal with aliens too?--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.InstantCables)),
			Trans(134--[[Instant Build--]]),
			"UI/Icons/Notifications/timer.tga"
		)
	end

	function ChoGGi.MenuFuncs.RemoveBuildingLimits_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.RemoveBuildingLimits = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.RemoveBuildingLimits)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000158--[[%s: No no I said over there.--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.RemoveBuildingLimits)),
			S[302535920000230--[[Remove Building Limits--]]]
		)
	end
	do -- Building_wonder_Toggle
		local function SetWonders(bool)
			local BuildingTemplates = BuildingTemplates
			for _,bld in pairs(BuildingTemplates) do
				if bld.group == "Wonders" then
					bld.wonder = bool
				end
			end
		end

		function ChoGGi.MenuFuncs.Building_wonder_Toggle()
			local ChoGGi = ChoGGi
			if ChoGGi.UserSettings.Building_wonder then
				ChoGGi.UserSettings.Building_wonder = nil
				SetWonders(true)
			else
				ChoGGi.UserSettings.Building_wonder = true
				SetWonders(false)
			end

			-- if the buildmenu is open
			ChoGGi.ComFuncs.UpdateBuildMenu()

			ChoGGi.SettingFuncs.WriteSettings()
			MsgPopup(
				ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.Building_wonder),
				S[302535920000159--[[Unlimited Wonders--]]],
				"UI/Icons/Sections/theory_1.tga"
			)
		end
	end -- do

	function ChoGGi.MenuFuncs.Building_dome_spot_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.Building_dome_spot = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.Building_dome_spot)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000160--[[%s: Freedom for spires!
	(restart to set disabled)--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.Building_dome_spot)),
			S[302535920000226--[[Remove Spire Point Limit--]]],
			"UI/Icons/Upgrades/plutonium_core_02.tga"
		)
	end

	function ChoGGi.MenuFuncs.Building_instant_build_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.Building_instant_build = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.Building_instant_build)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			S[302535920000161--[[%s: Buildings Instant Build--]]]:format(ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.Building_instant_build)),
			S[302535920001241--[[Instant Build--]]],
			"UI/Icons/Upgrades/autoregulator_02.tga"
		)
	end

	function ChoGGi.MenuFuncs.Building_hide_from_build_menu_Toggle()
		local ChoGGi = ChoGGi
		local BuildingTemplates = BuildingTemplates

		local bc = BuildCategories
		if not table.find(bc,"id","HiddenX") then
			bc[#bc+1] = {
				id = "HiddenX",
				name = Trans(1000155--[[Hidden--]]),
				image = "UI/Icons/bmc_placeholder.tga",
				highlight = "UI/Icons/bmc_placeholder_shine.tga",
			}
		end

		if ChoGGi.UserSettings.Building_hide_from_build_menu then
			ChoGGi.UserSettings.Building_hide_from_build_menu = nil
			for _,bld in pairs(BuildingTemplates) do
				if type(bld.hide_from_build_menu_ChoGGi) ~= "nil" then
					bld.hide_from_build_menu = bld.hide_from_build_menu_ChoGGi
					bld.hide_from_build_menu_ChoGGi = nil
				end
				if bld.group == "Hidden" then
					bld.build_category = "Hidden"
				end
			end
		else
			ChoGGi.UserSettings.Building_hide_from_build_menu = true
			for _,value in pairs(BuildMenuPrerequisiteOverrides) do
				if value == "hide" then
					value = true
				end
			end
			BuildMenuPrerequisiteOverrides.StorageMysteryResource = true
			BuildMenuPrerequisiteOverrides.MechanizedDepotMysteryResource = true
			for _,bld in pairs(BuildingTemplates) do
				if bld.id ~= "LifesupportSwitch" and bld.id ~= "ElectricitySwitch" then
					bld.hide_from_build_menu_ChoGGi = bld.hide_from_build_menu
					bld.hide_from_build_menu = false
				end
				if bld.group == "Hidden" and bld.id ~= "RocketLandingSite" and bld.id ~= "ForeignTradeRocket" then
					bld.build_category = "HiddenX"
				end
			end
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.Building_hide_from_build_menu),
			S[302535920000224--[[Show Hidden Buildings--]]],
			"UI/Icons/Sections/theory_1.tga"
		)
	end


	function ChoGGi.MenuFuncs.SetUIRangeBuildingRadius(id,msgpopup)
		local ChoGGi = ChoGGi
		local DefaultSetting = g_Classes[id]:GetDefaultPropertyValue("UIRange")
		local ItemList = {
			{text = Trans(1000121--[[Default--]]) .. ": " .. DefaultSetting,value = DefaultSetting},
			{text = 10,value = 10},
			{text = 15,value = 15},
			{text = 25,value = 25},
			{text = 50,value = 50},
			{text = 100,value = 100},
			{text = 250,value = 250},
			{text = 500,value = 500},
		}
		local UserSettings = ChoGGi.UserSettings

		if not UserSettings.BuildingSettings[id] then
			UserSettings.BuildingSettings[id] = {}
		end

		local hint = DefaultSetting
		if UserSettings.BuildingSettings[id].uirange then
			hint = UserSettings.BuildingSettings[id].uirange
		end

		local function CallBackFunc(choice)
			if choice.nothing_selected then
				return
			end
			local value = choice[1].value
			if type(value) == "number" then

				if value == DefaultSetting then
					UserSettings.BuildingSettings[id].uirange = nil
				else
					UserSettings.BuildingSettings[id].uirange = value
				end

				-- find a better way to update radius...
				local sel = SelectedObj
				CreateRealTimeThread(function()
					local objs = ChoGGi.ComFuncs.RetAllOfClass(id)
					for i = 1, #objs do
						objs[i]:SetUIRange(value)
						SelectObj(objs[i])
						Sleep(1)
					end
					SelectObj(sel)
				end)

				ChoGGi.SettingFuncs.WriteSettings()
				MsgPopup(
					choice[1].text .. ":\n" .. S[msgpopup],
					id,
					"UI/Icons/Upgrades/polymer_blades_04.tga",
					true
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = S[302535920000129--[[Set--]]] .. " " .. id .. " " .. S[302535920000163--[[Radius--]]],
			hint = S[302535920000106--[[Current--]]] .. ": " .. hint,
			skip_sort = true,
		}
	end

end
