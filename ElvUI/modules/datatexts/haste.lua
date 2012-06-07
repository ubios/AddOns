local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local displayString = ''
local lastPanel;

local function OnEvent(self, event, unit)
	if (event == "UNIT_AURA" or event == "UNIT_STATS") and unit ~= 'player' then return end
	lastPanel = self

	local hasteRating
	if E.role == "Caster" then
		hasteRating = UnitSpellHaste("player")
	elseif E.myclass == "HUNTER" then
		hasteRating = GetRangedHaste()
	else
		hasteRating = GetMeleeHaste()
	end
	self.text:SetFormattedText(displayString, hasteRating)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", STAT_HASTE, ": ", hex, "%.2f%%|r")
	
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('Haste', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "UNIT_SPELL_HASTE"}, OnEvent)
