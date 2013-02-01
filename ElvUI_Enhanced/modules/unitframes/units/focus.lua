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

	if not db.gps then return end

	if db.gps.enable then
		local x, y = self:GetPositionOffset(db.gps.position)		
		gps:ClearAllPoints()
		gps:Point(db.gps.position, frame.Health, db.gps.position, x, y)
		gps:SetFrameStrata("MEDIUM")
		gps:Show()
		
		gps.timer = UF:ScheduleRepeatingTimer("UpdateGPS", 0.1, frame)
		frame:EnableElement('GPS')
	else
		if (gps.timer) then
			UF:CancelTimer(gps.timer)
			gps.timer = nil
		end
		frame:DisableElement('GPS')
		gps:Hide()
	end

	frame:UpdateAllElements()
end

UF:Update_AllFrames()
