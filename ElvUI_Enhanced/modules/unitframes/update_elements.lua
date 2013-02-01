local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local LSR = LibStub("LibSpecRoster-1.0")
local MAP = LibStub("LibMapData-1.0")

local sub = string.sub
local abs, atan2, cos, sin, sqrt2, random, floor, ceil = math.abs, math.atan2, math.cos, math.sin, math.sqrt(2), math.random, math.floor, math.ceil
local pairs, type, select, unpack = pairs, type, select, unpack
local GetPlayerMapPosition, GetPlayerFacing = GetPlayerMapPosition, GetPlayerFacing
local mapfile, mapfloor
local unitframeFont

local roleIconTextures = {
	TANK = [[Interface\AddOns\ElvUI\media\textures\tank.tga]],
	HEALER = [[Interface\AddOns\ElvUI\media\textures\healer.tga]],
	DAMAGER = [[Interface\AddOns\ElvUI\media\textures\dps.tga]]
}

-- Register callback for changing map and floor (GPS)
MAP:RegisterCallback("MapChanged", function (event, map, floor, w, h)
	mapfile = map
	mapfloor = floor
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
	if not (UnitInParty(frame.unit) or UnitInRaid(frame.unit)) then
		gps:Hide()
		return
	end
	
	local angle, px, py, tx, ty = GetBearing(frame.unit)
	if angle == 999 then
		-- no bearing show - to indicate we are lost :)
		gps.Text:SetText("-")
		gps.Texture:Hide()
		gps:Show()
		return
	end
	
	RotateTexture(gps.Texture, angle)
	gps.Texture:Show()

	local distance = MAP:Distance(mapfile, mapfloor, px, py, tx, ty)
	gps.Text:SetFormattedText("%d", distance)
	gps:Show()
end

local eclipsedirection = {
  ["sun"] = function (frame, change)
  	frame.Text:SetText(change and "#>" or ">")
  	frame.Text:SetTextColor(.2 ,.2, 1, 1) 
  end,
  ["moon"] = function (frame, change)
  	frame.Text:SetText(change and "<#" or "<") 
  	frame.Text:SetTextColor(1, 1, .3, 1) 
  end,
  ["none"] = function (frame, change)
		frame.Text:SetText() 
  end,
}

-- add eclipse prediction when playing druid
if E.myclass == "DRUID" then
	ElvUF_Player.EclipseBar.callbackid = LibBalancePowerTracker:RegisterCallback(function(energy, direction, virtual_energy, virtual_direction, virtual_eclipse)
		if (ElvUF_Player.EclipseBar:IsShown()) then
			eclipsedirection[virtual_direction](ElvUF_Player.EclipseBar, direction ~= virtual_direction)
		end
	end)

	ElvUF_Player.EclipseBar.PostPowerUpdate = function()
		if (ElvUF_Player.EclipseBar:IsShown()) then
			energy, direction, virtual_energy, virtual_direction, virtual_eclipse = LibBalancePowerTracker:GetEclipseEnergyInfo()
			eclipsedirection[virtual_direction](self, direction ~= virtual_direction)	
		end
	end
end
