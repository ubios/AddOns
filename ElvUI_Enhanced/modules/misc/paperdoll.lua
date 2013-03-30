local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local ED = E:NewModule('EnhDurability', 'AceEvent-3.0');

local slots = {
	"SecondaryHandSlot",
	"MainHandSlot",
	"FeetSlot",
	"LegsSlot",
	"HandsSlot",
	"WristSlot",
	"WaistSlot",
	"ChestSlot",
	"ShoulderSlot",
	"HeadSlot"
}

function ED:UpdateDurability()
	if InCombatLockdown() then
		ED:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateDurability")	
		return
	else
		ED:UnregisterEvent("PLAYER_REGEN_ENABLED")
 	end

	local frame = _G["CharacterFrame"]
	local slot, current, maximum, r, g, b
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		frame.DurabilityInfo:SetText()

		if E.private.equipment.durability.enable then
			slot = GetInventorySlotInfo(slots[i])
			current, maximum = GetInventoryItemDurability(slot)

			if current and maximum and (not E.private.equipment.durability.onlydamaged or current < maximum) then
				r, g, b = E:ColorGradient((current / maximum), 1, 0, 0, 1, 1, 0, 0, 1, 0)
				frame.DurabilityInfo:SetFormattedText("%s%.0f%%|r", E:RGBToHex(r, g, b), (current / maximum) * 100)
			end
		end
	end
end

function ED:Initialize()
	local frame
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
		frame.DurabilityInfo:SetPoint("TOP", frame, "TOP", 0, -4)
		frame.DurabilityInfo:FontTemplate(E.media.font, 12, "THINOUTLINE")
	end	
	
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdateDurability")	
	self:UpdateDurability();
end

E:RegisterModule(ED:GetName())