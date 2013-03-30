local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local EI = E:NewModule('EnhItemLevel', 'AceEvent-3.0');

local slots = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"WristSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot"
}

local levelAdjust = {
	["0"]=0,["1"]=8,["373"]=4,["374"]=8,["375"]=4,["376"]=4,
	["377"]=4,["379"]=4,["380"]=4,["445"]=0,["446"]=4,["447"]=8,
	["451"]=0,["452"]=8,["453"]=0,["454"]=4,["455"]=8,["456"]=0,
	["457"]=8,["458"]=0,["459"]=4,["460"]=8,["461"]=12,["462"]=16
}

local levelColors = {
	[0] = "|cffff0000",
	[1] = "|cff00ff00",
	[2] = "|cffffff88",
}

function EI:UpdateItemLevel()
	if InCombatLockdown() then
		EI:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateItemLevel")	
		return
	else
		EI:UnregisterEvent("PLAYER_REGEN_ENABLED")
 	end
 	
 	local frame = _G["CharacterFrame"]
	local slot, itemLink, rarity, itemLevel, upgrade
	local	avgItemLevel, avgEquipItemLevel = GetAverageItemLevel()
	
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		frame.ItemLevel:SetText()

		if E.private.equipment.itemlevel.enable then
			slot = GetInventorySlotInfo(slots[i])
			itemLink = GetInventoryItemLink("player", slot)
			
			if itemLink then
				rarity, itemLevel = select(3, GetItemInfo(itemLink))
		
				upgrade = itemLink:match(":(%d+)\124h%[")
				if itemLevel and upgrade and levelAdjust[upgrade] then
					itemLevel = itemLevel + levelAdjust[upgrade]
				end
				
				frame.ItemLevel:SetFormattedText("%s%d|r", levelColors[(itemLevel < avgEquipItemLevel-10 and 0 or (itemLevel > avgEquipItemLevel + 10 and 1 or (2)))], itemLevel)
			end
		end
	end 	
 	
end

function EI:Initialize()
	local frame
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
		frame.ItemLevel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
		frame.ItemLevel:FontTemplate(E.media.font, 12, "THINOUTLINE")
	end	
	
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateItemLevel")
	self:RegisterEvent("SOCKET_INFO_UPDATE", "UpdateItemLevel")

	self:UpdateItemLevel()
end

E:RegisterModule(EI:GetName())