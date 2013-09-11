local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local TT = E:GetModule('Tooltip')

local bosses = {
	["25 Heroic"] = {
		["T16"] = { 8554, 8560, 8566, 8573, 8579, 8585, 8591, 8598, 8604, 8612, 8619, 8625, 8631, 8638 },
		["T15"] = { 8145, 8152, 8157, 8161, 8167, 8172, 8177, 8180, 8187, 8192, 8197, 8201, 8256 },
	},
	["10 Heroic"] = {
		["T16"] = { 8553, 8559, 8565, 8571, 8578, 8584, 8590, 8597, 8603, 8610, 8618, 8624, 8630, 8637 },
		["T15"] = { 8144, 8151, 8156, 8162, 8166, 8171, 8176, 8181, 8186, 8191, 8196, 8202, 8203 },
	},
	["25 Normal"] = {
		["T16"] = { 8552, 8558, 8564, 8570, 8577, 8583, 8589, 8596, 8602, 8609, 8617, 8623, 8629, 8636 },
		["T15"] = { 8143, 8150, 8155, 8160, 8165, 8170, 8175, 8182, 8185, 8190, 8195, 8200 },
	},
	["10 Normal"] = {
		["T16"] = { 8551, 8557, 8563, 8569, 8576, 8582, 8588, 8595, 8601, 8608, 8616, 8622, 8628, 8635 },
		["T15"] = { 8142, 8149, 8154, 8159, 8164, 8169, 8174, 8179, 8184, 8189, 8194, 8199 },
	},
	["Flex"] = {
		["T16"] = { 8550, 8556, 8562, 8568, 8575, 8581, 8587, 8594, 8600, 8606, 8615, 8621, 8627, 8634 },
		["T15"] = { 0 },
	},
	["LFR"] = {
		["T16"] = { 8549, 8555, 8561, 8567, 8574, 8580, 8586, 8593, 8599, 8605, 8614, 8620, 8626, 8632 },
		["T15"] = { 8141, 8148, 8153, 8158, 8163, 8168, 8173, 8178, 8183, 8188, 8193, 8198 },
	},
}

local playerGUID = UnitGUID("player")
local progressCache = {}

local function GetProgression(guid)
	local kills, complete = 0, false
	local statFunc = guid == playerGUID and GetStatistic or GetComparisonStatistic
	
	for diff, _ in pairs(bosses) do
		for level, _ in pairs(bosses[diff]) do
			local count = 0
			for statinfo = 1, #bosses[diff][level] do
				kills = tonumber((statFunc(bosses[diff][level][statinfo])))
				if kills and kills > 0 then 
					count = count + 1 
				end
			end
			if count > 0 then
				progressCache[guid].header = ("%s [%s]:"):format(diff, level)
				progressCache[guid].info = ("%d/%d"):format(count, #bosses[diff][level])		
				complete = true
				break
			end	
		end
		if complete then break end
	end
	if not complete then
		progressCache[guid].timer = 0
	end
end

local function UpdateProgression(guid)
	progressCache[guid] = progressCache[guid] or {}
	progressCache[guid].timer = GetTime()
		
	GetProgression(guid)	
end

local function SetProgressionInfo(guid, tt)
	if progressCache[guid] then
		for i=1, tt:NumLines() do
			local leftTipText = _G["GameTooltipTextLeft"..i]
			for diff, _ in pairs(bosses) do
				if (leftTipText:GetText() and leftTipText:GetText():find(diff)) then
					-- update found tooltip text line
					local rightTipText = _G["GameTooltipTextRight"..i]
					leftTipText:SetText(progressCache[guid].header)
					rightTipText:SetText(progressCache[guid].info)
					return
				end
			end
		end
		-- add progression tooltip line
		tt:AddDoubleLine(progressCache[guid].header, progressCache[guid].info, nil, nil, nil, 1, 1, 1)
	end
end

function TT:INSPECT_ACHIEVEMENT_READY(event, GUID)
	if (self.compareGUID ~= GUID) then return end

	local unit = "mouseover"
	if UnitExists(unit) then
		UpdateProgression(GUID)
		GameTooltip:SetUnit(unit)
	end
	ClearAchievementComparisonUnit()
	self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
end

hooksecurefunc(TT, 'ShowInspectInfo', function(self, tt, unit, level, r, g, b, numTries)
	if not E.db.tooltip.progressInfo then return end
	if not level or level < MAX_PLAYER_LEVEL then return end
	if not (unit and CanInspect(unit)) then return end
	
	local guid = UnitGUID(unit)
	
	if not progressCache[guid] or (GetTime() - progressCache[guid].timer) > 600 then
		if guid == playerGUID then
			UpdateProgression(guid)
		else
			ClearAchievementComparisonUnit()
			self.compareGUID = guid
			if SetAchievementComparisonUnit(unit) then
				self:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
			end
			return
		end
	end

	SetProgressionInfo(guid, tt)
end)
