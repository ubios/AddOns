local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local MB = E:NewModule('MinimapButtons', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');

-- Based on Square Minimap Buttons
-- Original authors:  Azilroka, Sinaris

local ignoreButtons = {
	"AsphyxiaUIMinimapHelpButton",
	"AsphyxiaUIMinimapVersionButton",
	"ElvConfigToggle",
	"ElvUIConfigToggle",
	"GameTimeframe",
	"HelpOpenTicketButton",
	"MiniMapMailframe",
	"MiniMapTrackingButton",
	"MiniMapVoiceChatframe",
	"QueueStatusMinimapButton",
	"TimeManagerClockButton",
}

local moveButtons = {}

local minimapButtonBarAnchor, minimapButtonBar

function MB:SkinButton(frame)
	if frame == nil or frame:GetName() == nil or (frame:GetObjectType() ~= "Button") or not frame:IsVisible() then return end
	
	local name = frame:GetName()	
	for i = 1, #ignoreButtons do
		if name == ignoreButtons[i] then return end
	end

	for i = 1,120 do
		if _G[("GatherMatePin%d"):format(i)] == frame then return end
		if _G[("Spy_MapNoteList_mini%d"):format(i)] == frame then return end
		if _G[("HandyNotesPin%d"):format(i)] == frame then return end
	end
	
	frame:SetPushedTexture(nil)
	frame:SetHighlightTexture(nil)
	frame:SetDisabledTexture(nil)
	if name == "DBMMinimapButton" then frame:SetNormalTexture("Interface\\Icons\\INV_Helmet_87") end
	if name == "SmartBuff_MiniMapButton" then frame:SetNormalTexture(select(3, GetSpellInfo(12051))) end

	if not frame.isSkinned then
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if (region:GetObjectType() == "Texture") then
				local texture = region:GetTexture()
			
				if (texture and (texture:find("Border") or texture:find("Background") or texture:find("AlphaMask"))) then
					region:SetTexture(nil)
				else
					region:ClearAllPoints()
					region:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
					region:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
					region:SetTexCoord( 0.1, 0.9, 0.1, 0.9 )
					region:SetDrawLayer( "ARTWORK" )
					if (name == "PS_MinimapButton") then
						region.SetPoint = function() end
					end
				end
			end
		end
		frame:SetTemplate("Default")
		tinsert(moveButtons, name)
		frame.isSkinned = true
	end
end

function MB:UpdateLayout()
	minimapButtonBar:Hide()
	minimapButtonBar:SetPoint("CENTER", minimapButtonBarAnchor, "CENTER", 0, 0)

	local lastFrame
	for i = 1, #moveButtons do
		local frame =	_G[moveButtons[i]]
		
		frame:SetParent(minimapButtonBar)
		frame:SetMovable(false)
		frame:SetScript("OnDragStart", nil)
		frame:SetScript("OnDragStop", nil)
		
		frame:ClearAllPoints()
		frame:SetFrameStrata("LOW")
		frame:Size(28)  
		if not lastFrame then
			frame:SetPoint("RIGHT", minimapButtonBar, "RIGHT", -4, 0)
		else
			frame:SetPoint("RIGHT", lastFrame, "LEFT", -4, 0)
		end
		lastFrame = frame	
	end

	minimapButtonBar:Width((28 * #moveButtons) + (4 * #moveButtons+1) + 3)
	minimapButtonBar:Show()
	
	minimapButtonBarAnchor:SetSize(minimapButtonBar:GetSize())
end

function MB:SkinMinimapButtons()
	for i = 1, Minimap:GetNumChildren() do
		self:SkinButton(select(i, Minimap:GetChildren()))
	end
	MB:UpdateLayout()
end

function MB:StartSkinning()
	E:Delay(15, self:SkinMinimapButtons())	
end

function MB:CreateFrames()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	minimapButtonBarAnchor = CreateFrame("Frame", "MinimapButtonBarAnchor", E.UIParent)
	minimapButtonBarAnchor:Point("TOPRIGHT", ElvConfigToggle, "BOTTOMRIGHT", -2, -2)
	minimapButtonBarAnchor:Size(200, 32)
	minimapButtonBarAnchor:SetFrameStrata("BACKGROUND")
	
	E:CreateMover(minimapButtonBarAnchor, "MinimapButtonAnchor", "Minimap Button Bar")

	minimapButtonBar = CreateFrame("Frame", "MinimapButtonBar", UIParent)
	minimapButtonBar:SetFrameStrata("BACKGROUND")
	minimapButtonBar:Height(34)
	minimapButtonBar:Width(34)
	minimapButtonBar:SetTemplate("Transparent")
	minimapButtonBar:CreateShadow()
	minimapButtonBar:SetPoint("CENTER", minimapButtonBarAnchor, "CENTER", 0, 0)

	self:RegisterEvent("ADDON_LOADED", "StartSkinning")
end

function MB:Initialize()
	E.minimapbuttons = MB

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CreateFrames")
end

E:RegisterModule(MB:GetName())
