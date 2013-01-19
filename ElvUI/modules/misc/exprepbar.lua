local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local M = E:GetModule('Misc');

local find				= string.find
local gsub				= string.gsub
local format			= string.format
local incpat 			= gsub(gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local changedpat	= gsub(gsub(FACTION_STANDING_CHANGED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local decpat			= gsub(gsub(FACTION_STANDING_DECREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local standing    = ('%s:'):format(STANDING)
local reputation  = ('%s:'):format(REPUTATION)

FACTION_STANDING_LABEL100 = UNKNOWN

function M:UpdateExpRepAnchors()
	local repBar = ReputationBarMover
	local expBar = ExperienceBarMover

	if (E:HasMoverBeenMoved('ExperienceBarMover') or E:HasMoverBeenMoved('ReputationBarMover')) or not repBar or not expBar then return end
	repBar:ClearAllPoints()
	expBar:ClearAllPoints()
	
	if self.expBar:IsShown() and self.repBar:IsShown() then
		expBar:Point('TOP', E.UIParent, 'TOP', 0, -1)
		repBar:Point('TOP', self.expBar, 'BOTTOM', 0, -1)
	elseif self.expBar:IsShown() then
		expBar:Point('TOP', E.UIParent, 'TOP', 0, -1)
	else
		repBar:Point('TOP', E.UIParent, 'TOP', 0, -1)
	end
end

function M:UpdateExperience(event)
	local bar = self.expBar

	if(UnitLevel('player') == MAX_PLAYER_LEVEL) or IsXPUserDisabled() then
		bar:Hide()
	else
		bar:Show()
		
		local cur, max = UnitXP('player'), UnitXPMax('player')
		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)
		
		local rested = GetXPExhaustion()
		local textFormat = E.db.general.experience.textFormat
		
		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(math.min(cur + rested, max))
			
			if textFormat == 'PERCENT' then
				bar.text:SetFormattedText('%d%% R:%d%%', cur / max * 100, rested / max * 100)
			elseif textFormat == 'CURMAX' then
				bar.text:SetFormattedText('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max), E:ShortValue(rested))
			elseif textFormat == 'CURPERC' then
				bar.text:SetFormattedText('%s - %d%% R:%s [%d%%]', E:ShortValue(cur), cur / max * 100, E:ShortValue(rested), rested / max * 100)
			end
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)	

			if textFormat == 'PERCENT' then
				bar.text:SetFormattedText('%d%%', cur / max * 100)
			elseif textFormat == 'CURMAX' then
				bar.text:SetFormattedText('%s - %s', E:ShortValue(cur), E:ShortValue(max))
			elseif textFormat == 'CURPERC' then
				bar.text:SetFormattedText('%s - %d%%', E:ShortValue(cur), cur / max * 100)
			end			
		end
	end
	
	self:UpdateExpRepAnchors()
end

function M:GetWatchedFactionInformation()
	local faction = GetWatchedFactionInfo()
	if faction then
		if faction == GUILD then
			faction = GetGuildInfo("player")
		end
		
		for factionIndex = 1, GetNumFactions() do
			local name, _, standingID, barMin, barMax, barValue = GetFactionInfo(factionIndex)
			if name == faction then
				return true, name, standingID, barMin, barMax, barValue
			end
		end
	end
	
	return false 
end

function M:UpdateReputation(event)
	local bar = self.repBar
	
	local isWatched, name, standingID, barMin, barMax, barValue = self.GetWatchedFactionInformation()
	if not isWatched then
		bar:Hide()
	else
		bar:Show()

		local color = FACTION_BAR_COLORS[standingID]			
		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)	

		bar.statusBar:SetMinMaxValues(barMin, barMax)
		bar.statusBar:SetValue(barValue)

		local textFormat = E.db.general.reputation.textFormat		
		if textFormat == 'PERCENT' then
			bar.text:SetFormattedText('%s: %d%% [%s]', name, ((barValue - barMin) / (barMax - barMin) * 100), _G[('FACTION_STANDING_LABEL%d'):format(standingID)])
		elseif textFormat == 'CURMAX' then
			bar.text:SetFormattedText('%s: %s - %s [%s]', name, E:ShortValue(barValue - barMin), E:ShortValue(barMax - barMin), _G[('FACTION_STANDING_LABEL%d'):format(standingID)])
		elseif textFormat == 'CURPERC' then
			bar.text:SetFormattedText('%s: %s - %d%% [%s]', name, E:ShortValue(barValue - barMin), ((barValue - barMin) / (barMax - barMin) * 100), _G[('FACTION_STANDING_LABEL%d'):format(standingID)])
		end					
	end
	
	self:UpdateExpRepAnchors()
end

local function ExperienceBar_OnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -4)
	
	local curValue, maxValue = UnitXP('player'), UnitXPMax('player')
	local rested = GetXPExhaustion()
	GameTooltip:AddLine(L['Experience'])
	GameTooltip:AddLine(' ')
	
	GameTooltip:AddDoubleLine(L['XP:'], format(' %d / %d (%d%%)', curValue, maxValue, curValue/maxValue * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L['Remaining:'], format(' %d (%d%% - %d %s)', maxValue - curValue, (maxValue - curValue) / maxValue * 100, 20 * (maxValue - curValue) / maxValue, L['Bars']), 1, 1, 1)	
	
	if rested then
		GameTooltip:AddDoubleLine(L['Rested:'], format('+%d (%d%%)', rested, rested / maxValue * 100), 1, 1, 1)	
	end
	
	GameTooltip:Show()
end

local function ReputationBar_OnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -4)
	
	local isWatched, name, standingID, barMin, barMax, barValue = M:GetWatchedFactionInformation()
	if isWatched then
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(' ')
		
		GameTooltip:AddDoubleLine(standing, _G[('FACTION_STANDING_LABEL%d'):format(standingID)], 1, 1, 1)
		GameTooltip:AddDoubleLine(reputation, format('%d / %d (%d%%)', barValue - barMin, barMax - barMin, (barValue - barMin) / (barMax - barMin) * 100), 1, 1, 1)
	end
	GameTooltip:Show()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

function M:CreateBar(name, onEnter, ...)
	local bar = CreateFrame('Button', name, E.UIParent)
	bar:Point(...)
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', OnLeave)
	bar:SetFrameStrata('LOW')
	bar:SetTemplate('Default')
	bar:Hide()
	
	bar.statusBar = CreateFrame('StatusBar', nil, bar)
	bar.statusBar:SetInside()
	bar.statusBar:SetStatusBarTexture(E.media.normTex)
	
	bar.text = bar.statusBar:CreateFontString(nil, 'OVERLAY')
	bar.text:FontTemplate()
	bar.text:SetPoint('CENTER')
	
	E.FrameLocks[name] = true
	
	return bar
end

function M:SetWatchedFactionOnReputationBar(event, msg)
	if not E.private.general.autorepchange then return end
	
	local _, _, faction, amount = find(msg, incpat)
	if not faction then _, _, faction, amount = find(msg, changedpat) or find(msg, decpat) end
	if faction then
		if faction == GUILD_REPUTATION then
			faction = GetGuildInfo("player")
		end

		local active = GetWatchedFactionInfo()
		for factionIndex = 1, GetNumFactions() do
			local name = GetFactionInfo(factionIndex)
			if name == faction and name ~= active then
				-- check if watch has been disabled by user
				local inactive = IsFactionInactive(factionIndex) or SetWatchedFactionIndex(factionIndex)
				break
			end
		end
	end
end

function M:UpdateExpRepDimensions()
	self.expBar:Width(E.db.general.experience.width)
	self.expBar:Height(E.db.general.experience.height)
	
	self.repBar:Width(E.db.general.reputation.width)
	self.repBar:Height(E.db.general.reputation.height)
	
	self.repBar.text:FontTemplate(nil, E.db.general.reputation.textSize)
	self.expBar.text:FontTemplate(nil, E.db.general.experience.textSize)
end

function M:EnableDisable_ExperienceBar()
	if UnitLevel('player') ~= MAX_PLAYER_LEVEL and E.db.general.experience.enable then
		self:RegisterEvent('PLAYER_XP_UPDATE', 'UpdateExperience')
		self:RegisterEvent('PLAYER_LEVEL_UP', 'UpdateExperience')
		self:RegisterEvent("DISABLE_XP_GAIN", 'UpdateExperience')
		self:RegisterEvent("ENABLE_XP_GAIN", 'UpdateExperience')
		self:RegisterEvent('UPDATE_EXHAUSTION', 'UpdateExperience')
		self:UpdateExperience()	
	else
		self:UnregisterEvent('PLAYER_XP_UPDATE')
		self:UnregisterEvent('PLAYER_LEVEL_UP')
		self:UnregisterEvent("DISABLE_XP_GAIN")
		self:UnregisterEvent("ENABLE_XP_GAIN")
		self:UnregisterEvent('UPDATE_EXHAUSTION')
		self.expBar:Hide()
	end
	
	self:UpdateExpRepAnchors()
end

function M:EnableDisable_ReputationBar()
	if E.db.general.reputation.enable then
		-- required for the GetNumFactions() function to return all factions in the game
		ExpandAllFactionHeaders()

		self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", 'SetWatchedFactionOnReputationBar')
		self:RegisterEvent('UPDATE_FACTION', 'UpdateReputation')
		self:UpdateReputation()
	else
		self:UnregisterEvent('UPDATE_FACTION')
		self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
		self.repBar:Hide()
	end
end

function M:LoadExpRepBar()
	self.expBar = self:CreateBar('ElvUI_ExperienceBar', ExperienceBar_OnEnter, 'TOP', E.UIParent, 'TOP', 0, -1)
	self.expBar.statusBar:SetStatusBarColor(0, 0.4, 1, .8)
	self.expBar.rested = CreateFrame('StatusBar', nil, self.expBar)
	self.expBar.rested:SetInside()
	self.expBar.rested:SetStatusBarTexture(E.media.normTex)
	self.expBar.rested:SetStatusBarColor(1, 0, 1, 0.2)

	self.repBar = self:CreateBar('ElvUI_ReputationBar', ReputationBar_OnEnter, 'TOP', self.expBar, 'BOTTOM', 0, -1)

	self:UpdateExpRepDimensions()
	
	self:EnableDisable_ExperienceBar()
	self:EnableDisable_ReputationBar()

	E:CreateMover(self.expBar, "ExperienceBarMover", L["Experience Bar"])
	E:CreateMover(self.repBar, "ReputationBarMover", L["Reputation Bar"])
	
	self:UpdateExpRepAnchors()
end