local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local M = E:NewModule('Misc', 'AceEvent-3.0', 'AceTimer-3.0');

E.Misc = M;
local UIErrorsFrame = UIErrorsFrame;
local InterrupMessage = INTERRUPTED.." %s's \124cff71d5ff\124Hspell: %d\124h[%s]\124h\124r!"

function M:ErrorFrameToggle(event)
	if event == 'PLAYER_REGEN_DISABLED' then
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName)
	if E.db.general.interruptAnnounce == "NONE" then return end
	if not (event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID('player')) then return end
	
	local inGroup, inRaid, inInstance, instanceType = IsInGroup(), IsInRaid(), IsInInstance()
	local chatMsg = format(InterrupMessage, destName, spellID, spellName)
	
	if inGroup then
		if (not inRaid and E.db.general.interruptAnnounce == RAID)
			or (not inInstance and E.db.general.interruptAnnounce == INSTANCE_CHAT) then
			SendChatMessage(chatMsg, PARTY, nil, nil)		
		else
			SendChatMessage(chatMsg, E.db.general.interruptAnnounce, nil, nil)
		end
	end
end

function M:MERCHANT_SHOW()
	if E.db.general.vendorGrays then
		E:GetModule('Bags'):VendorGrays(nil, true)
	end

	local autoRepair = E.db.general.autoRepair
	if IsShiftKeyDown() or autoRepair == 'NONE' or not CanMerchantRepair() then return end
	
	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney();
	if autoRepair == 'GUILD' and (not CanGuildBankRepair() or cost > withdrawLimit) then
		autoRepair = 'PLAYER'
	end
		
	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == 'GUILD')
			local c, s, g = cost%100, math.floor((cost%10000)/100), math.floor(cost/10000)
			
			if autoRepair == 'GUILD' then
				E:Print(L['Your items have been repaired using guild bank funds for: ']..GetCoinTextureString(cost, 12))
			else
				E:Print(L['Your items have been repaired for: ']..GetCoinTextureString(cost, 12))
			end
		else
			E:Print(L["You don't have enough money to repair."])
		end
	end
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid("player") then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if UnitExists("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

function M:IsPlayerMoving()
	local val = GetUnitSpeed('player')
	return val ~= 0
end

function M:CheckMovement()
	if not WorldMapFrame:IsShown() then return; end
	if self:IsPlayerMoving() then
		WorldMapFrame:SetAlpha(E.db.general.mapAlpha)
	else
		WorldMapFrame:SetAlpha(1)
	end
end

function M:PVPMessageEnhancement(_, msg)
	local _, instanceType = IsInInstance()
	if instanceType == 'pvp' or instanceType == 'arena' then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"]);
	end
end

function M:LoadAutoRelease()
	if not E.private.general.pvpautorelease then return end

	local autoreleasepvp = CreateFrame("frame")
	autoreleasepvp:RegisterEvent("PLAYER_DEAD")
	autoreleasepvp:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp")) then
			local soulstone = GetSpellInfo(20707)
			if ((E.myclass ~= "SHAMAN") and not (soulstone and UnitBuff("player", soulstone))) then
				RepopMe()
			end
		end

		-- auto resurrection for world PvP area...when active
		for index = 1, GetNumWorldPVPAreas() do
			local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(index)
			
			if (GetRealZoneText() == localizedName and isActive) then
				RepopMe()
			end
		end
	end)
end

local hideStatic = false;
function M:AutoInvite(event, leaderName)
	if not E.db.general.autoAcceptInvite then return; end

	if event == "PARTY_INVITE_REQUEST" then
		if QueueStatusMinimapButton:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if IsInGroup() then return end
		hideStatic = true

		-- Update Guild and Friendlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		local inGroup = false;

		for friendIndex = 1, GetNumFriends() do
			local friendName = GetFriendInfo(friendIndex)
			if friendName == leaderName then
				AcceptGroup()
				inGroup = true
				break
			end
		end

		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = GetGuildRosterInfo(guildIndex)
				if guildMemberName == leaderName then
					AcceptGroup()
					inGroup = true
					break
				end
			end
		end

		if not inGroup then
			for bnIndex = 1, BNGetNumFriends() do
				local _, _, _, name = BNGetFriendInfo(bnIndex)
				leaderName = leaderName:match("(.+)%-.+") or leaderName
				if name == leaderName then
					AcceptGroup()
					break
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic == true then
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = false
	end
end

function M:ForceCVars()
	if not GetCVarBool('lockActionBars') and E.private.actionbar.enable then
		SetCVar('lockActionBars', 1)
	end
end

function M:PLAYER_ENTERING_WORLD()
	self:ForceCVars()
end

function M:Initialize()
	self:LoadRaidMarker()
	self:LoadExpRepBar()
	self:LoadMirrorBars()
	self:LoadLoot()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:LoadAutoRelease()
	self:LoadQuestReward()
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL', 'PVPMessageEnhancement')
	self:RegisterEvent('PARTY_INVITE_REQUEST', 'AutoInvite')
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'AutoInvite')
	self:RegisterEvent('CVAR_UPDATE', 'ForceCVars')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	
	self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
end

E:RegisterModule(M:GetName())
