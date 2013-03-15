local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local HG = E:NewModule('HealGlow', 'AceHook-3.0', 'AceEvent-3.0')

local twipe = table.wipe

local spells = {}
local playerId

HG.GroupUnits = {}

function HG:SetupVariables()
	playerId = UnitGUID('player')
	
	for _, spellID in ipairs({
		-- Druid
		102792, -- Wild Mushroom: Bloom
		-- Monk
		130654, -- Chi Burst
		124040, -- Chi Torpedo
		115106, -- Chi Wave
		115464, -- Healing Sphere
		116670, -- Uplift
		-- Paladin
		114852, -- Holy Prism (enemy target)
		114871, -- Holy Prism (friendly target)
		82327,  -- Holy Radiance
		85222,  -- Light of Dawn
		-- Priest
		121148, -- Cascade
		34861,  -- Circle of Healing
		64844,  -- Divine Hymn
		110745, -- Divine Star (holy version)
		122128, -- Divine Star (shadow version)
		120692, -- Halo (holy version)
		120696, -- Halo (shadow version)
		23455,  -- Holy Nova
		596,    -- Prayer of Healing
		-- Shaman
		1064,   -- Chain Heal
	}) do
		local name, _, icon = GetSpellInfo(spellID)
		if name then
			spells[name] = { spellID, icon }
		end
	end
	
end

function HG:GroupRosterUpdate()
	twipe(HG.GroupUnits)
	
	local unit
	for index = 1, GetNumGroupMembers() - (IsInGroup() and 1 or 0) do
		unit = format("%s%d", (IsInRaid() and "raid" or (IsInGroup() and "party" or "solo")), index)
		if not UnitIsUnit(unit, "player") then
			HG.GroupUnits[UnitGUID(unit)] = { unit, 0 }
		end
	end
end

function HG:ParseCombatLog(_, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName)
	if not playerId or sourceGUID ~= playerId or event ~= "SPELL_HEAL" or not spells[spellName] then
		return
	end
	
	if HG.GroupUnits[destGUID] then
		HG.GroupUnits[destGUID][2] = GetTime()
	end
end

function HG:Initialize()
	--if not E.private.farmer.enabled then return end

	HG:RegisterEvent("PLAYER_ENTERING_WORLD", "SetupVariables")
	HG:RegisterEvent("GROUP_ROSTER_UPDATE", "GroupRosterUpdate")
	HG:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "ParseCombatLog")
end

E:RegisterModule(HG:GetName())
