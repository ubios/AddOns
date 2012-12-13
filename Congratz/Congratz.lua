---- Ace Setup ----
Congratz = LibStub("AceAddon-3.0"):NewAddon("Congratz", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceTimer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Congratz", false);

---- Slash Command Options ----
local options = {
  name = "Congratz",
  handler = Congratz,
  type = 'group',
  args = {
		-- Shows the gratzmsg table.
		show = {
			type = "execute",
			name = L["Show"],
			desc = L["Shows the current Congratz settings."],
			func = "ShowMessage",
		},
		-- Shows debug messages.
		debug = {
			type = "execute",
			name = L["Debug"],
			desc = L["Enable Congratz debug messages."],
			func = "ToggleDebug",
		},
		-- Shows information about the enabled or disabled state.
		info = {
			type = "execute",
			name = L["Information"],
			desc = L["Shows current state of congratz."],
			func = "ShowInformation",
		},		
		-- Adds a message to the gratzmsg table.
		add = {
			type = "input",
			name = L["Add"],
			desc = L["Adds a message to the message table. Use #N or #S to be replace with the players name."],
			pattern = "%w+",
			get = false,
			set = "AddMessage",
			},
		-- Deletes a message from the gratzmsg table.
		delete = {
			type = "input",
			name = L["Delete"],
			desc = L["Deletes the message in the specified postion."],
			pattern = "%d+",
			get = false,
			set = "DeleteMessage",
		},
		-- Configures the group gratz message.
		group = {
			type = "input",
			name = L["Group"],
			desc = L["Sets a message for when multiple people earn a gratz."],
			pattern = "%w+",
			get = false,
			set = "GroupMessage",
		},
		-- Configures the 2 person gratz message.
		both = {
			type = "input",
			name = L["Both"],
			desc = L["Sets a message for when 2 people earn a gratz."],
			pattern = "%w+",
			get = false,
			set = "BothMessage",
		},
		biggratz = {
			type = "input",
			name = L["BigGratz"],
			desc = L["Pattern for big gratz message for achievements with 50 to 70 points."],
			pattern = "%w+",
			get = false,
			set = "BigGratzPattern",
		},
		awesome = {
			type = "input",
			name = L["Awesome"],
			desc = L["Pattern for awesome message for achievements with over 70 points."],
			pattern = "%w+",
			get = false,
			set = "AwesomePattern",
		},
		-- Changes the random delay time value.
		delay = {
			type = "input",
			name = L["Delay"],
			desc = L["Sets the range for the random delay (8 seconds is added to this)"],
			pattern = "%d+",
			get = false,
			set = "RandomTime",
		},
	},
};

---- Default Options ----

local defaults = {
	profile =  {
		gratzmsg = {
			L["Congratulations"],
			L["Gratz"],
			L["Congratz"],
			L["Gz"],
			L["Gz m8"],
			L["Gratz #S"],
		},
		groupmsg = L["Gratz All !!"],
		bothmsg = L["Gratz both."],
		biggratzpattern = L["Big gratz #N!"],
		awesomepattern = L["Awesome, gratz #N!!"],
		randomtime = 12,
	},
};

-- Initialise tracking variables.
local cachedAchievements = { }
local timerstarted = false;
local gratznumber = 0;
local isafk = false;
local inBG = false;
local debug = false;
local format = string.format
local find = string.find
local random = math.random
local playerName,_ = UnitName("Player")
local achievementParseString = "|?c?f?f?(%x*)|?\124H?([^:]*):?(%d+):?([^:]*):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"

---- Setup Functions ----

function Congratz:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CongratzDB", defaults, "Default");
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Congratz", options);
	self:RegisterChatCommand(L["congratz"], "SlashCommand");
	
	Congratz:ResetTrackingValues()	
end

function Congratz:OnEnable()
	-- Register the guild achieved message event to respond to guildies getting achievements.
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT");
	
	-- Register the chat msg system event to respond to afk messages.
	self:RegisterEvent("CHAT_MSG_SYSTEM");
		
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")	
end

function Congratz:utf8sub(str, start, numChars)
  local currentIndex = start
  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    if char > 240 then
      currentIndex = currentIndex + 4
    elseif char > 225 then
      currentIndex = currentIndex + 3
    elseif char > 192 then
      currentIndex = currentIndex + 2
    else
      currentIndex = currentIndex + 1
    end
    numChars = numChars -1
  end
  return str:sub(start, currentIndex - 1)
end

---- Events ----

function Congratz:PLAYER_ENTERING_BATTLEGROUND(event, ...)
	if not inBG then
		inBG = true
		Congratz:PrintDebug("Player entered battleground...no Congratz message");
	end
end

function Congratz:PLAYER_ENTERING_WORLD(event, ...)
	if inBG then
		inBG = false
		Congratz:PrintDebug("Player left battleground...Congratz message on");
	end
end

function Congratz:CHAT_MSG_GUILD_ACHIEVEMENT(event, msg, player)
	-- Outputs a gratzmessage to guild chat.
	if not (isafk or inBG) then
		Congratz:PrintDebug("Achievement detected.")
			
		local _, _, Color, LinkType, Id, PlayerGuid, Completed, Month, Day, Year, Criteria1, Criteria2, Criteria3, Criteria4, Name = string.find(msg, achievementParseString)
		Congratz:PrintDebug(format("Found link type %s with id %d for player with guid %s, with name %s.", LinkType, Id, PlayerGuid, Name))
		
		local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch = GetAchievementInfo(Id)
		
		local criteria = GetAchievementNumCriteria(id)
		local totalPoints = points
		
		local previousId = GetPreviousAchievement(id)
		while previousId do
			id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch = GetAchievementInfo(previousId)
			Congratz:PrintDebug(format("Previous Achievement for player %s with id %d with name %s and points value of %d (%d criteria).", player, id, name, points, criteria));		
			
			totalPoints = totalPoints + points
			previousId = GetPreviousAchievement(id)
		end
		
		local minimumPoints = 10
		local achievementCategoryId = GetAchievementCategory(id)
		local categoryName, parentId = GetCategoryInfo(achievementCategoryId)
		
		while not parentId == -1 do
			achievementCategoryId = parentId
			categoryName, parentId = GetCategoryInfo(achievementCategoryId)
		end

		if achievementCategoryId == 96 then -- exploration
			minimumPoints = 20		
		end
		
		if achievementCategoryId == 155 then -- world events
			minimumPoints = 40		
		end
		
		if achievementCategoryId == 169 then	-- professions
			minimumPoints = 70
		end

		Congratz:PrintDebug(format("Achievement for player %s with id %d with name %s [%s] and points value of %d (%d criteria).", player, id, name, categoryName, totalPoints, criteria));

		if (player == playerName) then
			Congratz:PrintDebug("Achievement by player, no message!!")
			return
		end

		if (totalPoints > minimumPoints or criteria > 2) then
			local found = Congratz:PlayerExists(player)
			if found == -1 then
				-- add player to list
				Congratz:PrintDebug(format("Adding %s to cached achievements at position %d.", player, gratznumber))
				cachedAchievements[gratznumber] = { player, totalPoints }
				gratznumber = gratznumber + 1
			elseif (cachedAchievements[found][2] < totalPoints) then
				-- update player totalPoints if second achievement has higher value
				Congratz:PrintDebug(format("Updating %s cached achievements to %d points at position %d", player, totalPoints, found))
				cachedAchievements[found][2] = totalPoints
			end
			
			Congratz:PrintDebug(format("There are now %d players in the list.", gratznumber))
			
			-- start timed message if not done so before
			if not timerstarted then
				timerstarted = true
				-- Generate a random time delay, and add 8 secons to it.
				local delay = random(Congratz.db.profile.randomtime) + 8
				self:ScheduleTimer(function() Congratz:GratzMessage() end, delay)
			end
		else
			Congratz:Print(format("Low ranked achievement with %d points in category %s and minimal criteria, no gratz message!!", totalPoints, categoryName))
		end
		Congratz:PrintDebug("-----")
	else
		Congratz:PrintDebug("AFK or BG...no Congratz message");
	end
end

function Congratz:CHAT_MSG_SYSTEM(event, msg)
	-- Checks for AFK status of player
	if string.find(msg, MARKED_AFK) then
		-- turn on afk marker
		isafk = true;
		Congratz:PrintDebug("AFK..no Congratz message");
		-- cancel running timers
		self:CancelAllTimers()
	end
	if string.find(msg, CLEARED_AFK) then
		-- turn off afk marker
		isafk = false;
		Congratz:PrintDebug("Congratz message on");
	end
end

---- Slash Commands ----

function Congratz:SlashCommand(input)
	-- Called when a /slash command for this addon is used.
	if not input or input:trim() == "" then
		LibStub("AceConfigCmd-3.0").HandleCommand(Congratz, L["congratz"], "Congratz", "");
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(Congratz, L["congratz"], "Congratz", input);
	end
end

function Congratz:ShowMessage()
	Congratz:Print(L["The message table contains the following entries:"]);
	for i, value in ipairs(Congratz.db.profile.gratzmsg) do
		Congratz:Print(format("    %d: %q",i,value));
	end
	Congratz:Print(format(L["The group message is: %q"],Congratz.db.profile.groupmsg));
	Congratz:Print(format(L["The 2 person message is: %q"],Congratz.db.profile.bothmsg));
	Congratz:Print(format(L["The big gratz pattern is: %q"],Congratz.db.profile.biggratzpattern));
	Congratz:Print(format(L["The awesome pattern is: %q"],Congratz.db.profile.awesomepattern));
	Congratz:Print(format(L["The random time delay range is 8 to %d seconds."],Congratz.db.profile.randomtime + 8));
end

function Congratz:ToggleDebug()
	if not debug then
		Congratz:Print("Debug enabled.");
		debug = true;
			
		--Congratz:CHAT_MSG_GUILD_ACHIEVEMENT(event, "%s has earned the achievement |cffffff00|Hachievement:1181:0500000004ACF96C:1:11:4:12:4294967295:4294967295:4294967295:4294967295|h[Don't Know!]|h|r!", "Pinokkio")
		--Congratz:CHAT_MSG_GUILD_ACHIEVEMENT(event, "%s has earned the achievement |cffffff00|Hachievement:0869:0500000004ACF96C:1:11:4:12:4294967295:4294967295:4294967295:4294967295|h[Don't Know!]|h|r!", "Pinokkio")
	else
		Congratz:Print("Debug disabled.");
		debug = false;
	end
end

function Congratz:AddMessage(info,arg)
	table.insert(Congratz.db.profile.gratzmsg, arg);
	Congratz:Print(format(L["%q has been added to message table."],arg));
end

function Congratz:DeleteMessage(info,arg)
	local pos = tonumber(arg);
	if #Congratz.db.profile.gratzmsg == 1 and pos == 1 then
		Congratz:Print(L["There must be atleast one message in the table at all times."]);
	elseif not Congratz.db.profile.gratzmsg[pos] then
		Congratz:Print(format(L["No entry for position %d."],pos));
	else
		local msgremove = Congratz.db.profile.gratzmsg[pos];
		table.remove(Congratz.db.profile.gratzmsg, pos);
		Congratz:Print(format(L["%q removed from the message table."],msgremove));
	end
end

function Congratz:ShowInformation()
	if isafk then
		Congratz:Print("You are afk, congratz disabled.");
	elseif inBG then
		Congratz:Print("You are in a Battleground, congratz disabled.");
	else
		Congratz:Print("Congratz is enabled.");
	end
end

function Congratz:RandomTime(info,arg)
	delay = tonumber(arg)
	if delay >= 1 then
		Congratz.db.profile.randomtime = delay
		Congratz:Print(format(L["The random time delay range is now 8 to %d seconds."],delay + 8));
	else
		Congratz:Print(L["You must enter a number greater than 0."]);
	end
end

function Congratz:GroupMessage(info,arg)
	Congratz.db.profile.groupmsg = arg;
	Congratz:Print(format(L["%q is now the new group message."],arg));
end

function Congratz:BothMessage(info,arg)
	Congratz.db.profile.bothmsg = arg;
	Congratz:Print(format(L["%q is now the new 2 person message."],arg));
end

function Congratz:BigGratzPattern(info,arg)
	Congratz.db.profile.biggratzpattern = arg;
	Congratz:Print(format(L["%q is now the big gratz pattern."],arg));
end

function Congratz:AwesomePattern(info,arg)
	Congratz.db.profile.awesomepattern = arg;
	Congratz:Print(format(L["%q is now the awesome pattern."],arg));
end
	
---- Functions ----

function Congratz:PlayerExists(player)
	Congratz:PrintDebug(format("Cheking if player %s in gratz list.", player))
	for key, value in pairs(cachedAchievements) do
		Congratz:PrintDebug(format("List item %d: %s with points %d.", key, value[1], value[2]))			
		if (value[1] == player) then
			Congratz:PrintDebug(format("Player matches, returning value %d.", index))
			return key
		end
	end
	return -1
end

function Congratz:ResetTrackingValues()
	Congratz:PrintDebug("Resetting tracking values.");

	gratznumber = 0
	cachedAchievements = {}
	timerstarted = false;
end

function Congratz:PrintDebug(msg)
	if debug then Congratz:Print(msg) end
end

function Congratz:GratzMessage()
	Congratz:PrintDebug(format("Sending gratz message to %d player(s).", gratznumber))
	
	local player = cachedAchievements[0][1]
	local points = cachedAchievements[0][2]

	local msg;
	-- Congratz:Print(format("Entered gratz message [%d].", gratznumber));
	if gratznumber > 2 then
		-- Case 1: Multiple people have earned an achievement.
		-- Uses group gratz message.
		msg = Congratz.db.profile.groupmsg;
	end
	if gratznumber == 2 then
		msg = Congratz.db.profile.bothmsg;
	end
	if gratznumber == 1 then
		-- Case 2: A single person has earned an achievement.
		if string.find(player, "Eruliss") then
			msg = "Gratz love";
		else
			-- Generates a random message from the gratzmsg table.
			local i = random(#Congratz.db.profile.gratzmsg);
			msg = Congratz.db.profile.gratzmsg[i];
		
			if (points >= 50 and points<70) then
				msg = Congratz.db.profile.biggratzpattern
			end
			if (points >= 70) then
				msg = Congratz.db.profile.awesomepattern
			end
			
			-- Replace variables in message string.
			local lastLetter
			local length
			for i = 3, string.len(player) do
				lastLetter = Congratz:utf8sub(player, i, 1)
				--print("Check letter: "..lastLetter)
				if (string.find("aeiou", lastLetter) == nil) then
					--print("Break at: "..i)
					length = i
					break
				end
			end
			
			local playerShortname = Congratz:utf8sub(player, 1, length);
			
			msg = msg:gsub("#N", player);
			msg = msg:gsub("#n", player);
			msg = msg:gsub("#S", playerShortname);
			msg = msg:gsub("#s", playerShortname);
		end	
	end
	
	-- Send the message through the specified channel.
	if debug then
		SendChatMessage(msg, "SAY");	
	else
		SendChatMessage(msg, "GUILD");
	end
	
	-- Reset tracking values.
	Congratz:ResetTrackingValues()
end
