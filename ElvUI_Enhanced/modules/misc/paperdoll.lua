local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local PD = E:NewModule('PaperDoll', 'AceTimer-3.0', 'AceEvent-3.0');

local find = string.find

local slots = {
	["HeadSlot"] = { true, true },
	["NeckSlot"] = { true, false },
	["ShoulderSlot"] = { true, true },
	["BackSlot"] = { true, false },
	["ChestSlot"] = { true, true },
	["WristSlot"] = { true, true },
	["MainHandSlot"] = { true, true },
	["SecondaryHandSlot"] = { true, true },
	["HandsSlot"] = { true, true },
	["WaistSlot"] = { true, true },
	["LegsSlot"] = { true, true },
	["FeetSlot"] = { true, true },
	["Finger0Slot"] = { true, false },
	["Finger1Slot"] = { true, false },
	["Trinket0Slot"] = { true, false },
	["Trinket1Slot"] = { true, false },
}

local levelAdjust = {
	["0"]=0,["1"]=8,["373"]=4,["374"]=8,["375"]=4,["376"]=4,
	["377"]=4,["379"]=4,["380"]=4,["445"]=0,["446"]=4,["447"]=8,
	["451"]=0,["452"]=8,["453"]=0,["454"]=4,["455"]=8,["456"]=0,
	["457"]=8,["458"]=0,["459"]=4,["460"]=8,["461"]=12,["462"]=16,
	["465"]=0,["466"]=4,["467"]=8 
}

local levelColors = {
	[0] = "|cffff0000",
	[1] = "|cff00ff00",
	[2] = "|cffffff88",
}

-- From http://www.wowhead.com/items?filter=qu=7;sl=16:18:5:8:11:10:1:23:7:21:2:22:13:24:15:28:14:4:3:19:25:12:17:6:9;minle=1;maxle=1;cr=166;crs=3;crv=0
local heirlooms = {
	[80] = {44102,42944,44096,42943,42950,48677,42946,42948,42947,42992,50255,44103,44107,44095,44098,44097,44105,42951,48683,48685,42949,48687,42984,44100,44101,44092,48718,44091,42952,48689,44099,42991,42985,48691,44094,44093,42945,48716},
}


function PD:UpdatePaperDoll()
	if InCombatLockdown() then
		PD:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdatePaperDoll")	
		return
	else
		PD:UnregisterEvent("PLAYER_REGEN_ENABLED")
 	end

	local frame, slot, current, maximum, r, g, b
	local itemLink, rarity, itemLevel, linkLevel, upgrade
	local	avgItemLevel, avgEquipItemLevel = GetAverageItemLevel()
	
	for k, info in pairs(slots) do
		frame = _G[("Character%s"):format(k)]

		slot = GetInventorySlotInfo(k)	
		if info[1] then
			frame.ItemLevel:SetText()
			if E.private.equipment.itemlevel.enable and info[1] then
				itemLink = GetInventoryItemLink("player", slot)
				
        if itemLink then
            rarity, itemLevel = select(3, GetItemInfo(itemLink))    
            if rarity == 7 then -- heirloom adjust
                itemLevel = self:HeirLoomLevel(itemLink)
            end
            upgrade = itemLink:match(":(%d+)\124h%[")
            if itemLevel and upgrade and levelAdjust[upgrade] then
                itemLevel = itemLevel + levelAdjust[upgrade]
            end
            if itemLevel and avgEquipItemLevel then
                frame.ItemLevel:SetFormattedText("%s%d|r", levelColors[(itemLevel < avgEquipItemLevel-10 and 0 or (itemLevel > avgEquipItemLevel + 10 and 1 or (2)))], itemLevel)
            end
        end
			end
		end

		if info[2] then
			frame.DurabilityInfo:SetText()
			if  E.private.equipment.durability.enable then
				current, maximum = GetInventoryItemDurability(slot)
				if current and maximum and (not E.private.equipment.durability.onlydamaged or current < maximum) then
					r, g, b = E:ColorGradient((current / maximum), 1, 0, 0, 1, 1, 0, 0, 1, 0)
					frame.DurabilityInfo:SetFormattedText("%s%.0f%%|r", E:RGBToHex(r, g, b), (current / maximum) * 100)
				end
			end
		end
	end
end

function PD:HeirLoomLevel(itemLink)
	local level = UnitLevel("player")
	if level > 80 then
		local _, _, _, _, itemId = find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
		itemId = tonumber(itemId)
		-- Downgrade it to 80 if found
		for k, iid in pairs(heirlooms[80]) do
			if iid == itemId then
				level = 80
				break
			end
		end	
		-- There are currently no 1-90 Heirlooms
		if level > 85 then level = 85 end
	end
	
	if level > 80 then
		return (( level - 80) * 26.6) + 200;
	elseif level > 70 then
		return (( level - 70) * 10) + 100;
	elseif level > 60 then
		return (( level - 60) * 4) + 60;
	else
		return level;
	end	
end

function PD:InitialUpdatePaperDoll()
	PD:UnregisterEvent("PLAYER_ENTERING_WORLD")
	PD:ScheduleTimer("UpdatePaperDoll", 10)
end

function PD:Initialize()
	local frame
	for k, info in pairs(slots) do
		frame = _G[("Character%s"):format(k)]

		if info[1] then
			frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
			frame.ItemLevel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
			frame.ItemLevel:FontTemplate(E.media.font, 12, "THINOUTLINE")
		end
		
		if info[2] then
			frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
			frame.DurabilityInfo:SetPoint("TOP", frame, "TOP", 0, -4)
			frame.DurabilityInfo:FontTemplate(E.media.font, 12, "THINOUTLINE")
		end
	end	
	
	PD:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdatePaperDoll")	
	PD:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdatePaperDoll")
	PD:RegisterEvent("SOCKET_INFO_UPDATE", "UpdatePaperDoll")
	PD:RegisterEvent("COMBAT_RATING_UPDATE", "UpdatePaperDoll")
	PD:RegisterEvent("MASTERY_UPDATE", "UpdatePaperDoll")
	
	PD:RegisterEvent("PLAYER_ENTERING_WORLD", "InitialUpdatePaperDoll")
end

E:RegisterModule(PD:GetName())