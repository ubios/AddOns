local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local HG = E:NewModule('HealGlow', 'AceHook-3.0', 'AceEvent-3.0')
local UF = E:GetModule('UnitFrames')

local twipe = table.wipe

local spells = {}
local playerId
local healGlowFrame
local healGlowTime

HG.GroupUnits = {}
HG.FrameBuffers = {}

local currentTime
local function ShowHealGlows(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < .1 then return end
	self.elapsed = 0

	currentTime = GetTime()
	for k, u in pairs(HG.GroupUnits) do
		for _, index in ipairs({0, 10, 25, 40}) do
				for _, frame in pairs(HG.FrameBuffers[index]) do			
					if frame.unit == u[1] then
						if currentTime < (u[2] + healGlowTime) then					
							frame.HealGlow:Show()
						else
							frame.HealGlow:Hide()
						end 
					end
				end	
		end
	end	
end

function HG:SetupVariables()
	HG:UnregisterEvent("PLAYER_ENTERING_WORLD")

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

	HG.FrameBuffers[0] = {}

	local frame
	for i=1, 5 do
		frame = _G[("ElvUF_PartyUnitButton%d"):format(i)]
		frame.HealGlow = UF:Construct_HealGlow(frame, ('party%d'):format(i))
		HG.FrameBuffers[0][i] = frame
	end
	for r = 10, 40, 15 do
		HG.FrameBuffers[r] = {}
		for i=1, r do
			frame = _G[("ElvUF_Raid%dUnitButton%i"):format(r, i)]
			frame.HealGlow = UF:Construct_HealGlow(frame, ('raid%d'):format(i))	
			HG.FrameBuffers[r][i] = frame
		end
	end
	
	UF:UpdateAllHeaders()
	
	healGlowFrame = CreateFrame("Frame")
	healGlowFrame:SetScript("OnEvent", function(self, event, ...)
		if (event=="COMBAT_LOG_EVENT_UNFILTERED") then
	  	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName = select(1, ...)
	  	
			if sourceGUID ~= playerId or event ~= "SPELL_HEAL" or not spells[spellName] then
				return
			end
			
			if HG.GroupUnits[destGUID] then
				HG.GroupUnits[destGUID][2] = GetTime()
			end
	  end
	end)

	HG:UpdateSettings()
end

function HG:UpdateSettings()
	local color = E.db.unitframe.glowcolor

	for i=1, 5 do
		HG.FrameBuffers[0][i].HealGlow:SetBackdropBorderColor(color.r , color.g, color.b)
	end
	for r=10,40,15 do
		for i=1, r do
			HG.FrameBuffers[r][i].HealGlow:SetBackdropBorderColor(color.r , color.g, color.b)
		end
	end
	
	healGlowTime = E.db.unitframe.glowtime

	if E.db.unitframe.healglow then
		healGlowFrame:SetScript("OnUpdate", ShowHealGlows)
		healGlowFrame:RegisterUnitEvent("COMBAT_LOG_EVENT_UNFILTERED", playerId)
	else
		healGlowFrame:SetScript("OnUpdate", nil)
		healGlowFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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

function HG:Initialize()
	HG:RegisterEvent("PLAYER_ENTERING_WORLD", "SetupVariables")
	HG:RegisterEvent("GROUP_ROSTER_UPDATE", "GroupRosterUpdate")
end

E:RegisterModule(HG:GetName())
