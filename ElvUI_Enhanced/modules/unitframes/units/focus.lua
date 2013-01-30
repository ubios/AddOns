local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

UF.Update_FocusFrameEnh = UF.Update_FocusFrame

function UF:Update_FocusFrame(frame, db)
	UF:Update_FocusFrameEnh(frame, db)

	--GPS
	local gps = frame.gps
	if not gps then 
		frame.gps = self:Construct_GPS(frame, 'focus')
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
