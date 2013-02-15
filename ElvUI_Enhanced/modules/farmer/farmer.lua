local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local F = E:NewModule('Farmer', 'AceHook-3.0', 'AceEvent-3.0');

local farmSeedBarAnchor, farmToolBarAnchor, farmPortalBarAnchor
local tsort = table.sort
local activezones = { "Sunsong Ranch", "The Halfhill Market" }

local seedButtons = {}
local toolButtons = {}
local portalButtons = {}

local seeds = {
	[79102] = { 1 }, -- GreenCabbageSeeds
	[89328] = { 1 }, -- JadeSquashSeeds
	[80590] = { 1 }, -- JuicycrunchCarrotSeeds
	[80592] = { 1 }, -- MoguPumpkinSeeds
	[80594] = { 1 }, -- PinkTurnipSeeds
	[80593] = { 1 }, -- RedBlossomLeekSeeds
	[80591] = { 1 }, -- ScallionSeeds
	[89329] = { 1 }, -- StripedMelonSeeds
	[80595] = { 1 }, -- WhiteTurnipSeeds
	[89326] = { 1 }, -- WitchberrySeeds
	[85216] = { 2 }, -- EnigmaSeed
	[85217] = { 2 }, -- MagebulbSeed
	[85219] = { 2 }, -- OminousSeed
	[89202] = { 2 }, -- RaptorleafSeed
	[85215] = { 2 }, -- SnakerootSeed
	[89233] = { 2 }, -- SongbellSeed
	[91806] = { 2 }, -- UnstablePortalShard
	[89197] = { 2 }, -- WindshearCactusSeed
	[85267] = { 3 }, -- AutumnBlossomSapling
	[85268] = { 3 }, -- SpringBlossomSapling
	[85269] = { 3 }, -- WinterBlossomSapling
}

local tools = {
	[79104]	= { 1 }, -- RusyWateringCan
	[80513] = { 1 }, -- VintageBugSprayer
	[89880] = { 1 }, -- DentedShovel
	[89815] = { 1 }, -- MasterPlow
}

local portals = {
	[91850] = { "Horde" }, -- Orgrimmar Portal Shard
	[91861] = { "Horde" }, -- Thunder Bluff Portal Shard
	[91862] = { "Horde" }, -- Undercity Portal Shard
	[91863] = { "Horde" }, -- Silvermoon Portal Shard
	
	[91860] = { "Alliance" }, -- Stormwind Portal Shard
	[91864] = { "Alliance" }, -- Ironforge Portal Shard
	[91865] = { "Alliance" }, -- Darnassus Portal Shard
	[91866] = { "Alliance" }, -- Exodar Portal Shard
}

function F:InSeedZone()
	local subzone = GetSubZoneText()
	for i, zone in ipairs(activezones) do
		if (zone == subzone) then
			return true
		end
	end
	return false
end

function F:InFarmZone()
	return GetSubZoneText() == activezones[1]
end

function F:FarmerInventoryUpdate()
	if InCombatLockdown() then return end
	
	for i = 1, 3 do
		for _, button in ipairs(seedButtons[i]) do
			button.items = GetItemCount(button.itemId)
			button.text:SetText(button.items)
			button.icon:SetDesaturated(button.items == 0)
			button.icon:SetAlpha(button.items == 0 and .25 or 1)
		end
	end
	
	for _, button in ipairs(toolButtons) do
		button.items = GetItemCount(button.itemId)
		button.icon:SetDesaturated(button.items == 0)
		button.icon:SetAlpha(button.items == 0 and .25 or 1)
	end
	
	for _, button in ipairs(portalButtons) do
		button.items = GetItemCount(button.itemId)
		button.text:SetText(button.items)
		button.icon:SetDesaturated(button.items == 0)
		button.icon:SetAlpha(button.items == 0 and .25 or 1)
	end	
	
	self:UpdateLayout()
end

function F:UpdateBarLayout(bar, anchor, buttons)
	local count = 0
	bar:ClearAllPoints()
	bar:Point("LEFT", anchor, "LEFT", 0, 0)
	
	for i, button in ipairs(buttons) do
		button:ClearAllPoints()
		if not E.private.farmer.farmbars.onlyactive or button.items > 0 then
			button:Point("TOPLEFT", bar, "TOPLEFT", (count * 32) + 2, -2)
			button:Show()
			count = count + 1
		else
			button:Hide()
		end
	end
	
	bar:Width((count * 32) + 2)
	bar:Height(34)
	
	return count
end

function F:UpdateSeedBarLayout(seedBar, anchor, buttons, category)
	local count = 0
	seedBar:ClearAllPoints()
	seedBar:Point("TOPLEFT", anchor, "TOPLEFT", (category - 1)* 38, 0)
	
	for i, button in ipairs(buttons) do
		button:ClearAllPoints()
		if not E.private.farmer.farmbars.onlyactive or button.items > 0 then
			button:Point("TOPLEFT", seedBar, "TOPLEFT", 2, -(count * 32)-2)
			button:Show()
			count = count + 1
		else
			button:Hide()
		end
	end
	
	seedBar:Width(32)
	seedBar:Height((count * 32) + 2)
	return count
end

function F:UpdateBar(bar, layoutfunc, zonecheck, anchor, buttons, category)
	bar:Show()
	
	local count = layoutfunc(self, bar, anchor, buttons, category)
	if (E.private.farmer.farmbars.enable and count > 0 and zonecheck(self) and not InCombatLockdown()) then
		bar:Show()
	else
		bar:Hide()
	end
end

function F:UpdateLayout()
	for i=1, 3 do
		F:UpdateBar(_G[("FarmSeedBar%d"):format(i)], F.UpdateSeedBarLayout, F.InSeedZone, farmSeedBarAnchor, seedButtons[i], i)
	end
	F:UpdateBar(_G["FarmToolBar"], F.UpdateBarLayout, F.InFarmZone, farmToolBarAnchor, toolButtons)
	F:UpdateBar(_G["FarmPortalBar"], F.UpdateBarLayout, F.InFarmZone, farmPortalBarAnchor, portalButtons)
end

function F:CreateFarmButton(index, owner, buttonType, name, texture, allowDrop)
	local button = CreateFrame("Button", ("FarmerButton%d"):format(index), owner, "SecureActionButtonTemplate")
	button:Size(30, 30)
	button:SetTemplate()

	button.sortname = name
	button.itemId = index
	
	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetTexture(texture)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetInside()

	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetFont(E.media.normFont, 12, "OUTLINE")
	button.text:SetPoint("BOTTOMRIGHT", button, 1, 2)
	
	button:SetScript("OnEnter", function()
		GameTooltip:SetOwner(button, 'ANCHOR_TOPLEFT', 2, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(name)
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function()
		GameTooltip:Hide() 
	end)

	button:SetScript("OnMouseDown", function(self, mousebutton)
		if mousebutton == "LeftButton" then
			button:SetAttribute("type", buttonType)
			button:SetAttribute(buttonType, name)
		elseif mousebutton == "RightButton" and allowDrop then
			button:SetAttribute("type", "click")
			for container = 0, 4 do
				for slot = 1, GetContainerNumSlots(container) do
					if button.itemId == GetContainerItemID(container, slot) then
						PickupContainerItem(container, slot)
						DeleteCursorItem()
						return
					end
				end
			end			
		end
	end)
	
	return button
end				
				

function F:CreateFrames()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	farmSeedBarAnchor = CreateFrame("Frame", "FarmSeedBarAnchor", E.UIParent)
	farmSeedBarAnchor:Point("LEFT", E.UIParent, "LEFT", 4, -200)
	farmSeedBarAnchor:Size(96, 320)
	farmSeedBarAnchor:SetFrameStrata("BACKGROUND")

	E:CreateMover(farmSeedBarAnchor, "FarmSeedAnchor", "Farmer Seed Bar")
	
	farmToolBarAnchor = CreateFrame("Frame", "FarmToolBarAnchor", E.UIParent)
	farmToolBarAnchor:Point("BOTTOMLEFT", farmSeedBarAnchor, "TOPLEFT", 0, 4)
	farmToolBarAnchor:Size(128, 38)
	farmToolBarAnchor:SetFrameStrata("BACKGROUND")
	
	E:CreateMover(farmToolBarAnchor, "FarmToolAnchor", "Farmer Tool Bar")
	
	farmPortalBarAnchor = CreateFrame("Frame", "FarmPortalBarAnchor", E.UIParent)
	farmPortalBarAnchor:Point("BOTTOMLEFT", farmToolBarAnchor, "TOPLEFT", 0, 4)
	farmPortalBarAnchor:Size(128, 38)
	farmPortalBarAnchor:SetFrameStrata("BACKGROUND")
	
	E:CreateMover(farmPortalBarAnchor, "FarmPortalAnchor", "Farmer Portal Bar")

	for k, v in pairs(seeds) do
		seeds[k] = { v[1], GetItemInfo(k) }	
	end
	
	for k, v in pairs(tools) do
		tools[k] = { GetItemInfo(k) }
	end

	for k, v in pairs(portals) do
		portals[k] = { v[1], GetItemInfo(k) }
	end

	for i = 1, 3 do
		local seedBar = CreateFrame("Frame", ("FarmSeedBar%d"):format(i), UIParent)
		seedBar:SetFrameStrata("BACKGROUND")
		seedBar:SetTemplate("Transparent")
		seedBar:CreateShadow()
		seedBar:SetPoint("CENTER", farmSeedBarAnchor, "CENTER", 0, 0)

		seedButtons[i] = seedButtons[i] or {}
				
		for k, v in pairs(seeds) do
			if v[1] == i then
				tinsert(seedButtons[i], F:CreateFarmButton(k, seedBar, "item", v[2], v[11], false))
			end
			tsort(seedButtons[i], function(a, b) return a.sortname < b.sortname end)
		end
	end
	
	local toolBar = CreateFrame("Frame", "FarmToolBar", UIParent)	
	toolBar:SetFrameStrata("BACKGROUND")
	toolBar:SetTemplate("Transparent")
	toolBar:CreateShadow()
	toolBar:SetPoint("CENTER", farmToolBarAnchor, "CENTER", 0, 0)
	for k, v in pairs(tools) do
		tinsert(toolButtons, F:CreateFarmButton(k, toolBar, "item", v[1], v[10], true))
	end
	
	local portalBar = CreateFrame("Frame", "FarmPortalBar", UIParent)
	portalBar:SetFrameStrata("BACKGROUND")
	portalBar:SetTemplate("Transparent")
	portalBar:CreateShadow()
	portalBar:SetPoint("CENTER", farmPortalBarAnchor, "CENTER", 0, 0)
	local playerFaction = UnitFactionGroup('player')
	for k, v in pairs(portals) do
		if v[1] == playerFaction then
			tinsert(portalButtons, F:CreateFarmButton(k, portalBar, "item", v[2], v[11], false))
		end
	end
	
	self:FarmerInventoryUpdate()
	self:UpdateLayout()
	
	self:RegisterEvent("ZONE_CHANGED", "UpdateLayout")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLayout")
	self:RegisterEvent("BAG_UPDATE", "FarmerInventoryUpdate")
end

function F:Initialize()
	if not E.private.farmer.enabled then return end
	
	E.farmer = self

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CreateFrames")
end

E:RegisterModule(F:GetName())