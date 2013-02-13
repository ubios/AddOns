local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

function UF:Construct_GPS(frame, unit)
	local gps = CreateFrame("Frame", nil, frame)
	gps:SetTemplate("Default")
	gps:SetParent(frame)
	gps:EnableMouse(false)
	gps:SetFrameLevel(frame:GetFrameLevel() + 10)
	gps:SetWidth(E:Scale(48))
	gps:SetHeight(E:Scale(14))
	gps:SetAlpha(.9)
	gps:Hide()

	gps.Texture = gps:CreateTexture("OVERLAY")
	gps.Texture:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\media\\textures\\arrow.tga")
	gps.Texture:SetBlendMode("BLEND")
	gps.Texture:SetAlpha(.9)
	gps.Texture:SetWidth(E:Scale(12))
	gps.Texture:SetHeight(E:Scale(12))
	gps.Texture:SetPoint("LEFT", gps, "LEFT", 0, 0)

	gps.Text = gps:CreateFontString(nil, "OVERLAY")
	gps.Text:FontTemplate(E.media.font, 12, 'OUTLINE')
	gps.Text:SetPoint("RIGHT", gps, "RIGHT", 0 , 0)
	--UF.fontstrings[gps.Text] = true

	frame.unit = unit
	frame.gps = gps

	UF:CreateAndUpdateUF(unit)
end

function UF:EnhanceUpdateRoleIcon()
	for i=1, 5 do
		UF:UpdateRoleIconFrame(_G[("ElvUF_PartyUnitButton%d"):format(i)])
	end
	for r=10,40,15 do
		for i=1, r do
			UF:UpdateRoleIconFrame(_G[("ElvUF_Raid%dUnitButton%i"):format(r, i)])
		end
	end
end

function UF:UpdateRoleIconFrame(frame)
	frame:UnregisterEvent("UNIT_CONNECTION")
	frame:RegisterEvent("UNIT_CONNECTION", UF.UpdateRoleIconEnhanced)
	
	frame.LFDRole.Override = UF.UpdateRoleIconEnhanced
end

local CF = CreateFrame('Frame')
CF:RegisterEvent("PLAYER_ENTERING_WORLD")
CF:SetScript("OnEvent", function(self, event)
	UF:Construct_GPS(_G["ElvUF_Target"], 'target')
	UF:Construct_GPS(_G["ElvUF_Focus"], 'focus')
	UF:EnhanceDruidEclipse()
	UF:EnhanceUpdateRoleIcon()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
