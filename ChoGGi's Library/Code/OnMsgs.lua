local StringFormat = string.format
local S = ChoGGi.Strings

--~ ChoGGi.Temp.UIScale = (LocalStorage.Options.UIScale + 0.0) / 100 or 100
ChoGGi.Temp.UIScale = (LocalStorage.Options.UIScale + 0.0) / 100
-- used for resizing my dialogs to scale
function OnMsg.SystemSize()
	ChoGGi.Temp.UIScale = (LocalStorage.Options.UIScale + 0.0) / 100
end

-- we don't add shortcuts and ain't supposed to drink no booze
function OnMsg.ShortcutsReloaded()
	ChoGGi.ComFuncs.Rebuildshortcuts()
end

-- so we at least have keys when it happens
function OnMsg.ReloadLua()
	if type(XShortcutsTarget.UpdateToolbar) == "function" then
		ChoGGi.ComFuncs.Rebuildshortcuts()
	end
end

-- use this message to perform post-built actions on the final classes
function OnMsg.ClassesBuilt()
	-- add cat for my items
	local bc = BuildCategories
	if not table.find(bc,"id","ChoGGi") then
		local image = StringFormat("%sUI/bmc_incal_resources.png",ChoGGi.LibraryPath)
		local highlight = StringFormat("%sUI/bmc_incal_resources_shine.png",ChoGGi.LibraryPath)

		bc[#bc+1] = {
			id = "ChoGGi",
			name = S[302535920001400--[[ChoGGi--]]],
			image = image,
			highlight = highlight,
			-- pre-gagarin
			img = image,
			highlight_img = highlight,
		}
	end
end
