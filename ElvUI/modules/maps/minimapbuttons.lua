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
local buttonSize = 28
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
			frame.original = {}
			frame.original.Width, frame.original.Height = frame:GetSize()
			frame.original.Point, frame.original.relativeTo, frame.original.relativePoint, frame.original.xOfs, frame.original.yOfs = frame:GetPoint()
			frame.original.Parent = frame:GetParent()
			frame.original.FrameStrata = frame:GetFrameStrata()
			if frame:HasScript("OnDragStart") then
				frame.original.DragStart = frame:GetScript("OnDragStart")
			end
			if frame:HasScript("OnDragEnd") then
				frame.original.DragEnd = frame:GetScript("OnDragEnd")
			end
			
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
	minimapButtonBar:Height(buttonSize + 4)
	minimapButtonBar:Width(buttonSize + 4)

	local lastFrame, anchor1, anchor2, offsetX, offsetY
	for i = 1, #moveButtons do
		local frame =	_G[moveButtons[i]]
		
		if E.private.general.minimap.skinStyle == 'NOANCHOR' then
			frame:SetParent(frame.original.Parent)
			if frame.original.DragStart then
				frame:SetScript("OnDragStart", frame.original.DragStart)
			end
			if frame.original.DragEnd then
				frame:SetScript("OnDragStop", frame.original.DragEnd)
			end

			frame:ClearAllPoints()
			frame:SetSize(frame.original.Width, frame.original.Height)
			frame:SetPoint(frame.original.Point, frame.original.relativeTo, frame.original.relativePoint, frame.original.xOfs, frame.original.yOfs)
			frame:SetFrameStrata(frame.original.FrameStrata)
			frame:SetMovable(true)
		else
			frame:SetParent(minimapButtonBar)
			frame:SetMovable(false)
			frame:SetScript("OnDragStart", nil)
			frame:SetScript("OnDragStop", nil)
			
			frame:ClearAllPoints()
			frame:SetFrameStrata("LOW")
			frame:Size(buttonSize)
			if E.private.general.minimap.skinStyle == 'HORIZONTAL' then
				anchor1 = 'RIGHT'
				anchor2 = 'LEFT'
				offsetX = -2
				offsetY = 0
			else
				anchor1 = 'TOP'
				anchor2 = 'BOTTOM'
				offsetX = 0
				offsetY = 2
			end
			
			if not lastFrame then
				frame:SetPoint(anchor1, minimapButtonBar, anchor1, offsetX, offsetY)
			else
				frame:SetPoint(anchor1, lastFrame, anchor2, offsetX, offsetY)
			end
		end
		lastFrame = frame	
	end
	
	if E.private.general.minimap.skinStyle ~= 'NOANCHOR' then
		if E.private.general.minimap.skinStyle == "HORIZONTAL" then
			minimapButtonBar:Width((buttonSize * #moveButtons) + (2 * #moveButtons+1) + 1)
		else
			minimapButtonBar:Height((buttonSize * #moveButtons) + (2 * #moveButtons+1) + 1)
		end
		minimapButtonBarAnchor:SetSize(minimapButtonBar:GetSize())
		minimapButtonBar:Show()
	end
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
	minimapButtonBar:SetTemplate("Transparent")
	minimapButtonBar:CreateShadow()
	minimapButtonBar:SetPoint("CENTER", minimapButtonBarAnchor, "CENTER", 0, 0)

	self:RegisterEvent("ADDON_LOADED", "StartSkinning")
end

function MB:Initialize()
	if not E.private.general.minimap.skinButtons then return end

	E.minimapbuttons = MB

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CreateFrames")
end

E:RegisterModule(MB:GetName())
