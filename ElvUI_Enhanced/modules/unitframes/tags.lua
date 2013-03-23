local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames')

local twipe = table.wipe

ElvUF.Tags.Methods['xafk'] = function(unit)
	local isAFK, isDND = UnitIsAFK(unit), UnitIsDND(unit)
	if isAFK then
		return ('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r'):format(DEFAULT_AFK_MESSAGE)
	elseif isDND then
		return ('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r'):format(L['DND'])
	else
		return ''
	end
end

ElvUF.Tags.Events['xthreat:percent'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['xthreat:percent'] = function(unit)
	if UnitCanAttack('player', unit) then
		local status, percent = select(2, UnitDetailedThreatSituation('player', unit))
		if (status) then
			return format('%.0f%%', percent)
		end
		return L["None"]
	end
	return ''
end

ElvUF.Tags.Events['xthreat:current'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['xthreat:current'] = function(unit)
	if UnitCanAttack('player', unit) then
		local status, _, _, threatvalue = select(2, UnitDetailedThreatSituation('player', unit))
		if (status) then
			return E:ShortValue(threatvalue)
		end
		return L["None"]
	end
	return ''
end

ElvUF.Tags.Events['xthreatcolor'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['xthreatcolor'] = function(unit)
	local status = select(2, UnitDetailedThreatSituation('player', unit))
	if (status) then
		return Hex(GetThreatStatusColor(status))
	else 
		return '|cFF808080'
	end
end

local GroupUnits = {}
local f = CreateFrame("Frame")

f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
	local groupType, groupSize
	twipe(GroupUnits)

	if IsInRaid() then
		groupType = "raid"
		groupSize = GetNumGroupMembers()
	elseif IsInGroup() then
		groupType = "party"
		groupSize = GetNumGroupMembers() - 1
		GroupUnits["player"] = true
	else
		groupType = "solo"
		groupSize = 1
	end

	for index = 1, groupSize do
		local unit = groupType..index
		if not UnitIsUnit(unit, "player") then
			GroupUnits[unit] = true
		end
	end
end)

local timers = {
}

local function CheckElapsedTimeFunction(name, unit, elapsed, func, arg1)
	timers[name] = timers[name] or {}
	timers[name][unit] = timers[name][unit] or {}
	if (GetTime() - (timers[name][unit][1] or 0)) > elapsed then
		timers[name][unit][1] = GetTime()
		timers[name][unit][2] = func(unit, arg1)
	end
	return timers[name][unit][2]
end

local function Distance(unit)
	local distance = E:GetDistance('player', unit)	
	if distance and distance > 0 then
		return format('%d', distance)
	end
	return ''
end

local function NearbyPlayers(unit, range)
	local unitsInRange, distance = 0
	for groupUnit, _ in pairs(GroupUnits) do
		if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
			distance = E:GetDistance(unit, groupUnit)
			if distance and distance <= range then
				unitsInRange = unitsInRange + 1
			end
		end
	end
	return unitsInRange
end

-- Extra Throttled version of distance, handy for large raidgroups
ElvUF.Tags.Methods['xdistance'] = function(unit)
	if not UnitIsConnected(unit) or UnitIsUnit(unit, 'player') then return end

	return CheckElapsedTimeFunction('distance', unit, .2, Distance)
end

-- Extra Throttled version of nearbyplayers, handy for large raidgroups
ElvUF.Tags.Methods['xnearbyplayers:8'] = function(unit)
	if not UnitIsConnected(unit) then return end

	return CheckElapsedTimeFunction('nearbyplayers:8', unit, .25, NearbyPlayers, 8)
end

-- Extra Throttled version of nearbyplayers, handy for large raidgroups
ElvUF.Tags.Methods['xnearbyplayers:10'] = function(unit)
	if not UnitIsConnected(unit) then return end

	return CheckElapsedTimeFunction('nearbyplayers:10', unit, .25, NearbyPlayers, 10)
end

-- Extra Throttled version of nearbyplayers, handy for large raidgroups
ElvUF.Tags.Methods['xnearbyplayers:30'] = function(unit)
	if not UnitIsConnected(unit) then return end

	return CheckElapsedTimeFunction('nearbyplayers:30', unit, .25, NearbyPlayers, 30)
end
