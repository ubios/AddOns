local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local abs = math.abs
local floor = math.floor
local join = string.join
local format = string.format
local pairs = pairs

local defaultColor = { 1, 1, 1 }
local Profit	= 0
local Spent		= 0
local resetInfoFormatter = ("|cffaaaaaa%s|r"):format(L["Reset Data: Hold Shift + Right Click"])

local function OnEvent(self, event, ...)
	if not IsLoggedIn() then return end
	local NewMoney = GetMoney()
	ElvDB = ElvDB or { }
	ElvDB['gold'] = ElvDB['gold'] or {}
	ElvDB['gold'][E.myrealm] = ElvDB['gold'][E.myrealm] or {}
	ElvDB['gold'][E.myrealm][E.myname] = ElvDB['gold'][E.myrealm][E.myname] or NewMoney

	local OldMoney = ElvDB['gold'][E.myrealm][E.myname] or NewMoney

	local Change = NewMoney-OldMoney -- Positive if we gain money
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end

	self.text:SetText(GetCoinTextureString(NewMoney, E.db.datatexts.fontSize))

	ElvDB['gold'][E.myrealm][E.myname] = NewMoney
end

local function Click(self, btn)
	if btn == "RightButton" and IsShiftKeyDown() then
		ElvDB.gold = nil;
		OnEvent(self)
		DT.tooltip:Hide();
	else
		ToggleAllBags()
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L['Session:'])
	DT.tooltip:AddDoubleLine(L["Earned:"], GetCoinTextureString(Profit, E.db.datatexts.fontSize), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], GetCoinTextureString(Spent, E.db.datatexts.fontSize), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		DT.tooltip:AddDoubleLine(L["Deficit:"], GetCoinTextureString(abs(Profit-Spent), E.db.datatexts.fontSize), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		DT.tooltip:AddDoubleLine(L["Profit:"	], GetCoinTextureString(abs(Profit-Spent), E.db.datatexts.fontSize), 0, 1, 0, 1, 1, 1)
	end
	DT.tooltip:AddLine' '

	local totalGold = 0
	DT.tooltip:AddLine(L["Character: "])

	for k,_ in pairs(ElvDB['gold'][E.myrealm]) do
		if ElvDB['gold'][E.myrealm][k] then
			DT.tooltip:AddDoubleLine(k, GetCoinTextureString(ElvDB['gold'][E.myrealm][k], E.db.datatexts.fontSize), 1, 1, 1, 1, 1, 1)
			totalGold=totalGold+ElvDB['gold'][E.myrealm][k]
		end
	end

	DT.tooltip:AddLine' '
	DT.tooltip:AddLine(L["Server: "])
	DT.tooltip:AddDoubleLine(L["Total: "], GetCoinTextureString(totalGold, E.db.datatexts.fontSize), 1, 1, 1, 1, 1, 1)

	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			DT.tooltip:AddLine(" ")
			DT.tooltip:AddLine(CURRENCY)
		end
		if name and count then DT.tooltip:AddDoubleLine(name, count, 1, 1, 1) end
	end
	
	DT.tooltip:AddLine' '
	DT.tooltip:AddLine(resetInfoFormatter)

	DT.tooltip:Show()
end

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
DT:RegisterDatatext('Gold', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED'}, OnEvent, nil, Click, OnEnter)