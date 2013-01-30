local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

UF.Update_TargetFrameEnh = UF.Update_TargetFrame

function UF:Update_TargetFrame(frame, db)
	self:Update_TargetFrameEnh(frame, db)

	--GPS
	local gps = frame.gps
	if not gps then
		frame.gps = self:Construct_GPS(frame, 'target')
		gps = frame.gps
	end
	
	if gps.db.enable then
		local x, y = self:GetPositionOffset(gps.db.position)
		gps:ClearAllPoints()
		gps:Point(gps.db.position, frame.Health, gps.db.position, x, y)
		gps:SetFrameStrata("MEDIUM")
		gps:Show()
		frame:EnableElement('GPS')
	else
		frame:DisableElement('GPS')
		gps:Hide()
	end

	frame:UpdateAllElements()
end

UF:Update_AllFrames()
