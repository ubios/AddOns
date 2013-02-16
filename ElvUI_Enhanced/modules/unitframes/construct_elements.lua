local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames')

local eclipsedirection = {
  ["sun"] = function (frame, change)
  	frame.Text:SetText(change and "#>" or ">")
  	frame.Text:SetTextColor(cahnge and 1 or .2 , change and 1 or .2, 1, 1) 
  end,
  ["moon"] = function (frame, change)
  	frame.Text:SetText(change and "<#" or "<") 
  	frame.Text:SetTextColor(1, 1, change and 1 or .3, 1) 
  end,
  ["none"] = function (frame, change)
		frame.Text:SetText() 
  end,
}

function UF:Construct_GPS(frame, unit)
	local gps = CreateFrame("Frame", nil, frame)
	gps:SetTemplate("Default")
	gps:SetParent(frame)
	gps:EnableMouse(false)
	gps:SetFrameLevel(frame:GetFrameLevel() + 10)
	gps:Size(48, 14)
	gps:SetAlpha(.9)
	gps:Hide()

	gps.Texture = gps:CreateTexture(nil, "OVERLAY")
	gps.Texture:SetTexture([[Interface\AddOns\ElvUI_Enhanced\media\textures\arrow.tga]])
	gps.Texture:SetBlendMode("BLEND")
	gps.Texture:SetAlpha(.9)
	gps.Texture:Size(12, 12)
	gps.Texture:SetPoint("LEFT", gps, "LEFT", 0, 0)

	gps.Text = gps:CreateFontString(nil, "OVERLAY")
	gps.Text:FontTemplate(E.media.font, 12, 'OUTLINE')
	gps.Text:SetPoint("RIGHT", gps, "RIGHT", 0 , 0)

	UF:Configure_FontString(gps.Text)

	gps.unit = unit
	frame.gps = gps

	UF:CreateAndUpdateUF(unit)
end

function UF:EnhanceDruidEclipse()
	-- add eclipse prediction when playing druid
	if E.myclass == "DRUID" then
		ElvUF_Player.EclipseBar.callbackid = LibBalancePowerTracker:RegisterCallback(function(energy, direction, virtual_energy, virtual_direction, virtual_eclipse)
			if (ElvUF_Player.EclipseBar:IsShown()) then
				-- improve visibility of eclipse direction indicator
				ElvUF_Player.EclipseBar.Text:SetFont([[Interface\AddOns\ElvUI\media\fonts\Continuum_Medium.ttf]], 18, 'OUTLINE')
				eclipsedirection[virtual_direction](ElvUF_Player.EclipseBar, direction ~= virtual_direction)
			end
		end)
		
		ElvUF_Player.EclipseBar.PostUpdatePower = function()
			if (ElvUF_Player.EclipseBar:IsShown()) then
				energy, direction, virtual_energy, virtual_direction, virtual_eclipse = LibBalancePowerTracker:GetEclipseEnergyInfo()
				eclipsedirection[virtual_direction](ElvUF_Player.EclipseBar, direction ~= virtual_direction)	
			end
		end
	end
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
