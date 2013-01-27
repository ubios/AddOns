local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard')

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

function B:UpdateDurability()
	local frame, slot, current, maximum, r, g, b
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		slot = GetInventorySlotInfo(slots[i])
		current, maximum = GetInventoryItemDurability(slot)
		frame.DurabilityInfo:SetText()

		if current and maximum then
			r, g, b = E:ColorGradient((current / maximum), 1, 0, 0, 1, 1, 0, 0, 1, 0)
			frame.DurabilityInfo:SetFormattedText("%s%.0f%%|r", E:RGBToHex(r, g, b), (current / maximum) * 100)
		end
	end	
end

function B:PaperDollDurability()
	_G["CharacterFrame"]:HookScript("OnShow", function(self)
		B:UpdateDurability()
	end)

	local frame
	for i = 1, #slots do
		frame = _G[("Character%s"):format(slots[i])]
		frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
		frame.DurabilityInfo:SetPoint("CENTER", frame, "CENTER", 0, 0)
		frame.DurabilityInfo:FontTemplate(E.media.font, 12, "OUTLINE")
	end	
end