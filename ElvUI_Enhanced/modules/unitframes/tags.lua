local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

ElvUF.Tags.Methods['afk'] = function(unit)
	local isAFK, isDND = UnitIsAFK(unit), UnitIsDND(unit)
	if isAFK then
		return ('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r'):format(DEFAULT_AFK_MESSAGE)
	elseif isDND then
		return ('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r'):format(L['DND'])
	else
		return ''
	end
end

ElvUF.Tags.Events['name:abbrev'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbrev'] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 5) or ''
end

ElvUF.Tags.Events['xthreat:percent'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['xthreat:percent'] = function(unit)
	local status, percent = select(2, UnitDetailedThreatSituation('player', unit))
	if (status) then
		return format('%.0f%%', percent)
	else 
		return L["None"]
	end
end

ElvUF.Tags.Events['xthreat:current'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['xthreat:current'] = function(unit)
	local status, _, _, threatvalue = select(2, UnitDetailedThreatSituation('player', unit))
	if (status) then
		return E:ShortValue(threatvalue)
	else 
		return L["None"]
	end
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
