local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDT = E:NewModule('ExtraDataTexts')
local ACD = LibStub("AceConfigDialog-3.0")
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local PANEL_HEIGHT = 22;
local SPACING = (E.PixelMode and 1 or 5)

local extrapanel = {
	[1] = 3,
	[3] = 1,
	[5] = 1,
}

function EDT:UpdateSettings()
	local wasVisible = false
	for k, v in pairs(extrapanel) do
		if (_G[('Actionbar%dDataPanel'):format(k)]:IsShown()) then
			wasVisible = true
		end
	end

	local panel
	local isVisible = false
	for k, v in pairs(extrapanel) do
		panel = _G[('Actionbar%dDataPanel'):format(k)]
		if E.db.datatexts[("actionbar%d"):format(k)] then
			panel:Show()
			isVisible = true
		else
			panel:Hide()
		end
	end
	
	if (wasVisible ~= isVisible) then
		local mover = _G['ElvAB_1']
		if (mover) then
			local point, relativeTo, relativePoint, xOfs, yOfs = mover:GetPoint()
			local newYOfs = wasVisible and (yOfs - 26) or (yOfs + 26)
			if (newYOfs > 0) then
				mover:SetPoint(point, relativeTo, relativePoint, xOfs, newYOfs)
				E.db.movers[name] = format('%s\031%s\031%s\031%d\031%d', point, relativeTo:GetName(), relativePoint, E:Round(xOfs), E:Round(newYOfs))
				
				ACD['Close'](ACD, 'ElvUI')
			end
		end
	end
end

function EDT:PositionDataPanel(panel, index)
	if not panel then return end
	
	local actionbar = _G["ElvUI_Bar"..index]
	local spacer = E.db.actionbar["bar"..index].backdrop and 0 or SPACING
	
	panel:ClearAllPoints()
	panel:Point('TOPLEFT', actionbar, 'BOTTOMLEFT', spacer, -spacer)
	panel:Point('BOTTOMRIGHT', actionbar, 'BOTTOMRIGHT', -spacer, -(spacer + PANEL_HEIGHT))
end

function EDT:OnInitialize()
	for k, v in pairs(extrapanel) do
		local actionbar = _G[("ElvUI_Bar%d"):format(k)]
		local panel = CreateFrame('Frame', ('Actionbar%dDataPanel'):format(k), Minimap)
		local spacer = E.db.actionbar["bar"..k].backdrop and 0 or SPACING

		panel:Point('TOPLEFT', actionbar, 'BOTTOMLEFT', spacer, -spacer)
		panel:Point('BOTTOMRIGHT', actionbar, 'BOTTOMRIGHT', -spacer, -(spacer + PANEL_HEIGHT))	
		panel:SetTemplate('Default', true)

		DT:RegisterPanel(panel, v, 'ANCHOR_BOTTOM', 0, -4)
	end
	
	--DT:LoadDataTexts()
	--DT:PanelLayoutOptions()
	self:UpdateSettings()
	
	hooksecurefunc(AB,"PositionAndSizeBar",function(self, barName)
		local barnumber = tonumber(string.match(barName, "%d+"))
		if extrapanel[barnumber] then
			EDT:PositionDataPanel(_G[('Actionbar%dDataPanel'):format(barnumber)], barnumber)
		end
	end)
end

E:RegisterModule(EDT:GetName())