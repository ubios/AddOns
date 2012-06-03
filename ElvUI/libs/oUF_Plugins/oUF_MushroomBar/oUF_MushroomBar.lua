--[[
	Documentation:
	
		Element handled:
			.MushroomBar (must be a table with statusbar inside)
		
		.MushroomBar only:
			.delay : The interval for updates (Default: 0.1)
			.Destroy (boolean): Enables/Disable the mushroom destruction on right click
			
--]]
local _, ns = ...
local oUF = ns.oUF or oUF or ElvUF
if not oUF then return end

if select(2, UnitClass('player')) ~= "DRUID" then return end

local _, pClass = UnitClass("player")
local total = 0
local delay = 0.1

local format = string.format
local ceil = math.ceil

local colors =
{
	[0] = {192, 0, 0},
	[1] = {255, 140, 0},
	[2] = {0, 205, 0},
}

local GetTotemInfo, SetValue, GetTime = GetTotemInfo, SetValue, GetTime
	
local function MushroomOnClick(self,...)
	local id = self.ID
	local mouse = ...
	 	-- print(id, mouse)
		if IsShiftKeyDown() then
			for j = 1, 3 do 
				DestroyTotem(j)
			end 
		else 
			DestroyTotem(id) 
		end
end
	
local function InitDestroy(self)
	local mushroom = self.MushroomBar
	for i = 1, 3 do
		local Destroy = CreateFrame("Button",nil, mushroom[i])
		Destroy:SetAllPoints(mushroom[i])
		Destroy:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		Destroy.ID = i
		Destroy:SetScript("OnClick", MushroomOnClick)
	end
end

local function UpdateSlot(self, slot)
	local mushroom = self.MushroomBar

	local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
	
	mushroom[slot]:Hide()
	mushroom[slot]:SetValue(1)
	
	-- If we have a totem then set his value 
	if not haveTotem or duration == 0 then return end
	
	mushroom[slot]:SetValue((startTime + duration) - GetTime())	
	-- Status bar update
	mushroom[slot]:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		
		if total >= delay then
			total = 0
			local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
			local estTimeLeft = (startTime + duration) - GetTime()
			if (estTimeLeft < 0) then estTimeLeft = 0 end
			
			self:SetValue(estTimeLeft)
			
			local colorCode = 2
			if (estTimeLeft < 90) then colorCode = 1 end
			if (estTimeLeft < 30) then colorCode = 0 end
			
			mushroom[slot]:SetStatusBarColor(unpack(colors[colorCode]))
			
			if not haveTotem then 
				mushroom[slot]:Hide()
				mushroom[slot]:SetScript("OnUpdate",nil)
				mushroom[slot]:SetValue(300)
			end
		end
	end)
	mushroom[slot]:Show()
end

local function Update(self, unit)
	-- Update on login
	for i = 1, 3 do
		UpdateSlot(self, i)
	end
end

local function UpdateMushroomBars(self, unit, spellName, _, _, spellID)
	-- print(unit.." casted "..spellName.." ["..spellID.."]")

	if (spellID == 88747) then
		for i = 1, 3 do
			UpdateSlot(self, i)
		end
	end
end

local function Event(self, event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		UpdateMushroomBars(self, ...)
	end
end

local function Enable(self, unit)
	local mushroom = self.MushroomBar
	
	if (mushroom) then
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Event)
		mushroom.colors = setmetatable(mushroom.colors or {}, {__index = colors})
		delay = mushroom.delay or delay
		if mushroom.Destroy then
			InitDestroy(self)
		end		
		TotemFrame:UnregisterAllEvents()		
		return true
	end	
end

local function Disable(self,unit)
	local mushroom = self.MushroomBar
	if(mushroom) then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Event)
		
		TotemFrame:Show()
	end
end
			
oUF:AddElement("MushroomBar", Update, Enable, Disable)

