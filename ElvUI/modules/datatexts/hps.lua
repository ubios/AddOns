local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local DT = E:GetModule('DataTexts')

local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
local playerID, petID
local healTotal, lastHealAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = '';
local hpsInfoString = ('%s: '):format(L["HPS"])

local join = string.join
local max = math.max

local function Reset()
	timeStamp = 0
	combatTime = 0
	healTotal = 0
	lastHealAmount = 0
end	

local function SetHPS(self)
	self.text:SetFormattedText(displayString, hpsInfoString, combatTime == 0 and 0 or (healTotal / combatTime))
end

local function OnEvent(self, event, ...)
	lastPanel = self
	
	if event == 'PLAYER_ENTERING_WORLD' then
		playerID = UnitGUID('player')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 20 then
			Reset()
		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		if not events[select(2, ...)] then return end
		
		local id = select(4, ...)
		if not (id == playerID or id == petID) then return end
		
		if timeStamp == 0 then timeStamp = select(1, ...) end
		local overHeal = select(16, ...)
		lastSegment = timeStamp
		combatTime = select(1, ...) - timeStamp
		lastHealAmount = select(15, ...)
		healTotal = healTotal + max(0, lastHealAmount - overHeal)
	elseif event == UNIT_PET then
		petID = UnitGUID("pet")
	end
	
	SetHPS(self)
end

local function OnClick(self)
	Reset()
	SetHPS(self)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s", hex, "%.1f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('HPS', {'PLAYER_ENTERING_WORLD', 'COMBAT_LOG_EVENT_UNFILTERED', 'PLAYER_LEAVE_COMBAT', 'PLAYER_REGEN_DISABLED', 'UNIT_PET'}, OnEvent, nil, OnClick)
