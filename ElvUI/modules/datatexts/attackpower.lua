local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local pwr
local displayString = ''
local lastPanel;

local function OnEvent(self, event, unit)	
	if (event == "UNIT_AURA" or event == "UNIT_STATS") and unit ~= 'player' then return end

	if E.myclass == "HUNTER" then
		local Rbase, RposBuff, RnegBuff = UnitRangedAttackPower("player");
		pwr = Rbase + RposBuff + RnegBuff;
	else
		local base, posBuff, negBuff = UnitAttackPower("player");
		pwr = base + posBuff + negBuff;	
	end
	
	self.text:SetFormattedText(displayString, pwr) 	
	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", L['AP'], ": ", hex, "%d|r")
	
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
DT:RegisterDatatext('Attack Power', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "UNIT_ATTACK_POWER", "UNIT_RANGED_ATTACK_POWER"}, OnEvent)

