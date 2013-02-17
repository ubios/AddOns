local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local NP = E:GetModule('NamePlates')

local UnitCanAttack, UnitDetailedThreatSituation, GetThreatStatusColor = UnitCanAttack, UnitDetailedThreatSituation, GetThreatStatusColor
local format = string.format

function Hex(r, g, b)
	return format('|cFF%02x%02x%02x', r * 255, g * 255, b * 255)
end

hooksecurefunc(NP, 'SkinPlate', function(self, frame, nameFrame)
	if not frame.hp.threat then
		frame.hp.threat = frame.hp:CreateFontString(nil, "OVERLAY")
		frame.hp.threat:SetPoint("BOTTOMLEFT", frame.hp, "TOPRIGHT", 1, 1)
	end
	frame.hp.threat:FontTemplate(font, self.db.fontSize, 'OUTLINE')
end)

hooksecurefunc(NP, 'UpdateThreat', function(self, frame)
	if frame.hp.threat then
		frame.hp.threat:SetText()

		if self.db.showthreat then
			if frame.unit and UnitCanAttack('player', frame.unit) then
				local status, percent = select(2, UnitDetailedThreatSituation('player', frame.unit))
				if (status) then
					frame.hp.threat:SetFormattedText('%s%.0f%%|r', Hex(GetThreatStatusColor(status)), percent)
				else
					frame.hp.threat:SetFormattedText('|cFF808080%s|r', L["None"])
				end
			end
		end
	end
end)
