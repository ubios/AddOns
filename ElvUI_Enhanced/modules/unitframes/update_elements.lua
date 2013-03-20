local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local LSR = LibStub("LibSpecRoster-1.0")

local sub = string.sub
local abs, atan2, cos, sin, sqrt2, random, floor, ceil = math.abs, math.atan2, math.cos, math.sin, math.sqrt(2), math.random, math.floor, math.ceil
local pairs, type, select, unpack = pairs, type, select, unpack
local GetPlayerMapPosition, GetPlayerFacing = GetPlayerMapPosition, GetPlayerFacing
local unitframeFont

local roleIconTextures = {
	TANK = [[Interface\AddOns\ElvUI\media\textures\tank.tga]],
	HEALER = [[Interface\AddOns\ElvUI\media\textures\healer.tga]],
	DAMAGER = [[Interface\AddOns\ElvUI\media\textures\dps.tga]],
	DC = [[Interface\AddOns\ElvUI_Enhanced\media\textures\dc.tga]],
}

local function CalculateCorner(r)
	return 0.5 + cos(r) / sqrt2, 0.5 + sin(r) / sqrt2;
end

local function RotateTexture(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 0.785398163);
	local LLx, LLy = CalculateCorner(angle + 2.35619449);
	local ULx, ULy = CalculateCorner(angle + 3.92699082);
	local URx, URy = CalculateCorner(angle - 0.785398163);
	
	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

function UF:UpdateGPS(frame)
	local gps = frame.gps
	if not gps then return end
	
	-- GPS Disabled or not GPS parent frame visible or not in Party or Raid, Hide gps
	if UnitIsUnit(gps.unit, 'player') or not (UnitInParty(gps.unit) or UnitInRaid(gps.unit)) then
		gps:Hide()
		return
	end
	
	local distance, angle = E:GetDistance('player', gps.unit)
	if not angle then
		-- no bearing show - to indicate we are lost :)
		gps.Text:SetText("-")
		gps.Texture:Hide()
		gps:Show()
		return
	end
	
	RotateTexture(gps.Texture, angle)
	gps.Texture:Show()

	gps.Text:SetFormattedText("%d", distance)
	gps:Show()
end

function UF:UpdateRoleIconEnhanced(event)
	-- rehook self from timer event
	if event and type(event) == "table" then
		self = event
	end

	local lfdrole = self.LFDRole
	local db = self.db.roleIcon
	local autochange = false
	
	if (not db) or (db and not db.enable) then 
		lfdrole:Hide()
		return
	end
	
	local role = UnitGroupRolesAssigned(self.unit)
	if role == 'NONE' then
		if self.isForced then
			local rnd = random(1, 4)
			role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER" or(rnd == 4 and "DC")))
		else
			_, role = LSR:getRole(UnitGUID(self.unit))
			autochange = true
		end
	end
	
	if not UnitIsConnected(self.unit) then role = "DC" end
	
	if role and role ~= 'NONE' then
		lfdrole:SetTexture(roleIconTextures[role])
		lfdrole:Show()
		if lfdrole.timer then
			UF:CancelTimer(lfdrole.timer)
			lfdrole.timer = nil
		end
		if autochange and not InCombatLockdown() and (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player')) and role ~= "DC" then
			UnitSetRole(self.unit, role)
		end	
	else
		lfdrole:Hide()
		if not lfdrole.timer then
			lfdrole.timer = UF:ScheduleRepeatingTimer("UpdateRoleIconEnhanced", 5, self)
		end
	end	
end