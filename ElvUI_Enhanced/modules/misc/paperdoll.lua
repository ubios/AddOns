local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local M = E:GetModule('MiscEnh');

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

function M:UpdateDurability()
	local frame = _G["CharacterFrame"]
	if not frame:IsShown() then return end
	
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

function M:LoadPaperDollDurability()
	_G["CharacterFrame"]:HookScript("OnShow", function(self)
		M:UpdateDurability()
	end)
	
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdateDurability")

	local frame
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
		frame.DurabilityInfo:SetPoint("CENTER", frame, "CENTER", 0, 0)
		frame.DurabilityInfo:FontTemplate(E.media.font, 12, "OUTLINE")
	end	
end