local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDT = E:NewModule('ExtraDataTexts')
local ACD = LibStub("AceConfigDialog-3.0")
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local PANEL_HEIGHT = 22;
local SPACING = (E.PixelMode and 1 or 5)
local floor = math.floor

local extrapanel = {
	[1] = 3,
	[3] = 1,
	[5] = 1,
}

function EDT:UpdateSettings()
	for k, v in pairs(extrapanel) do
		local panel = _G[('Actionbar%dDataPanel'):format(k)]
		local wasVisible = panel:IsShown()

		if E.db.actionbar[('bar%d'):format(k)].enabled and E.db.datatexts[("actionbar%d"):format(k)] then
			panel:Show()
		else
			panel:Hide()
		end

		if (wasVisible ~= panel:IsShown()) then
			local mover = _G[('ElvAB_%d'):format(k)]

			if (mover) then
				local point, relativeTo, relativePoint, xOfs, yOfs = mover:GetPoint()
				local newYOfs = floor((wasVisible and (yOfs - PANEL_HEIGHT) or (yOfs + PANEL_HEIGHT)) + .5)
				if (newYOfs >= 0) then
					if k ~=1 and not E.db["movers"][mover:GetName()] then
						point = "BOTTOM"
						relativePoint = "BOTTOM"
						local calcOfs = floor(((_G['ElvUI_Bar1']:GetWidth() / 2) + (mover:GetWidth() / 2) + (SPACING * 2)) + .5)
						xOfs = k == 3 and calcOfs or -calcOfs
					end
					mover:ClearAllPoints()
					mover:Point(point, E.UIParent, relativePoint, xOfs, newYOfs)
					E:SaveMoverPosition(mover.name)	
					
					AB:UpdateButtonSettings()
				end
			end
		end
	end
end

function EDT:PositionDataPanel(panel, index)
	if not panel then return end
	
	local actionbar = _G[("ElvUI_Bar%d"):format(index)]
	local spacer = E.db.actionbar[("bar%d"):format(index)].backdrop and 0 or SPACING
	
	panel:ClearAllPoints()
	panel:Point('TOPLEFT', actionbar, 'BOTTOMLEFT', spacer, -spacer)
	panel:Point('BOTTOMRIGHT', actionbar, 'BOTTOMRIGHT', -spacer, -(spacer + PANEL_HEIGHT))
	
	EDT:UpdateSettings()
end

function EDT:OnInitialize()
	for k, v in pairs(extrapanel) do
		local actionbar = _G[("ElvUI_Bar%d"):format(k)]
		local panel = CreateFrame('Frame', ('Actionbar%dDataPanel'):format(k), Minimap)
		local spacer = E.db.actionbar[("bar%d"):format(k)].backdrop and 0 or SPACING

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