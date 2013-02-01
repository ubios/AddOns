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
	UF.fontstrings[gps.Text] = true
	gps.Text:SetPoint("RIGHT", gps, "RIGHT", 0 , 0)

	frame.gps = gps
	frame.unit = unit

	return gps
end
