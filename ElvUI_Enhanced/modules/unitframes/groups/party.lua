local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames')

hooksecurefunc(UF, "Update_PartyFrames", function(self, frame, db)
	--HealGlow
	local healGlow = frame.HealGlow
	if not healGlow then return end

		--HealGlow
	local healGlow = frame.HealGlow
	if not healGlow then return end
	
	local color = E.db.unitframe.glowcolor
	healGlow:SetBackdropBorderColor(color.r , color.g, color.b)

	if E.db.unitframe.healglow then
		if not healGlow.timer then
			healGlow.timer = UF:ScheduleRepeatingTimer("UpdateHealGlow", 0.2, frame, frame.unit)
		end
	else
		if (healGlow.timer) then
			UF:CancelTimer(healGlow.timer)
			healGlow.timer = nil
		end
	end
end)
