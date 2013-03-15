local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local HG = E:GetModule('HealGlow')
local MAP = LibStub("LibMapData-1.0")
local LSR = LibStub("LibSpecRoster-1.0")

local sub = string.sub
local abs, atan2, cos, sin, sqrt2, random, floor, ceil = math.abs, math.atan2, math.cos, math.sin, math.sqrt(2), math.random, math.floor, math.ceil
local pairs, type, select, unpack = pairs, type, select, unpack
local GetPlayerMapPosition, GetPlayerFacing = GetPlayerMapPosition, GetPlayerFacing
local mapfile, maplevel
local unitframeFont

local roleIconTextures = {
	TANK = [[Interface\AddOns\ElvUI\media\textures\tank.tga]],
	HEALER = [[Interface\AddOns\ElvUI\media\textures\healer.tga]],
	DAMAGER = [[Interface\AddOns\ElvUI\media\textures\dps.tga]],
	DC = [[Interface\AddOns\ElvUI_Enhanced\media\textures\dc.tga]],
}

-- Register callback for changing map and floor (GPS)
MAP:RegisterCallback("MapChanged", function (event, map, level, w, h)
	mapfile = map
	maplevel = level
end)

local function GetBearing(unit)
  local tx, ty = GetPlayerMapPosition(unit)
  if tx == 0 and ty == 0 then
    return 999
  end
  local px, py = GetPlayerMapPosition("player")
  return -GetPlayerFacing() - atan2(tx - px, py - ty), px, py, tx, ty
end

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
	if not (UnitInParty(gps.unit) or UnitInRaid(gps.unit)) then
		gps:Hide()
		return
	end
	
	local angle, px, py, tx, ty = GetBearing(gps.unit)
	if angle == 999 then
		-- no bearing show - to indicate we are lost :)
		gps.Text:SetText("-")
		gps.Texture:Hide()
		gps:Show()
		return
	end
	
	RotateTexture(gps.Texture, angle)
	gps.Texture:Show()

	local distance = MAP:Distance(mapfile, maplevel, px, py, tx, ty)
	gps.Text:SetFormattedText("%d", distance)
	gps:Show()
end

function UF:UpdateHealGlow(frame, unit)
	if unit then
		if not UnitIsUnit(unit, 'player') then
			local unitId = UnitGUID(unit)
			if HG.GroupUnits[unitId] and GetTime() < HG.GroupUnits[unitId][2] + E.db.unitframe.glowtime then
				frame.HealGlow:Show()
			else
				frame.HealGlow:Hide()
			end
		end	
	end
end

function UF:ForceZoneChanged()
	MAP:ZoneChanged(true)
end

function UF:GetTargetDistance(unit)
  local tx, ty = GetPlayerMapPosition(unit)
  if tx == 0 and ty == 0 then return 0 end

  local px, py = GetPlayerMapPosition("player")
	return MAP:Distance(mapfile, maplevel, px, py, tx, ty)
end

function UF:UpdateRoleIconEnhanced(event)
	-- rehook self from timer event
	if event and type(event) == "table" then
		self = event
	end

	local lfdrole = self.LFDRole
	local db = self.db.roleIcon
	
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
	else
		lfdrole:Hide()
		if not lfdrole.timer then
			lfdrole.timer = UF:ScheduleRepeatingTimer("UpdateRoleIconEnhanced", 5, self)
		end
	end	
end