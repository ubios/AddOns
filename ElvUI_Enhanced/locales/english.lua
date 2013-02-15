-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "enUS", true);

if not L then return end

-- Init
L["ENH_LOGIN_MSG"] = "You are using |cff1784d1ElvUI Enhanced|r version %s%s|r."
L["Your version of ElvUI is to old (required v5.1 or higher). Please, download the latest version from tukui.org."] = true

-- Equipment
L["Equipment"] = true
L["EQUIPMENT_DESC"] = "Adjust the settings for switching your gear set when you change specialization or enter a battleground."
L["No Change"] = true

L["Specialization"] = true
L["Enable/Disable the specialization switch."] = true

L["Primary Talent"] = true
L["Choose the equipment set to use for your primary specialization."] = true

L["Secondary Talent"] = true
L["Choose the equipment set to use for your secondary specialization."] = true

L["Battleground"] = true
L['Enable/Disable the battleground switch.'] = true

L["Equipment Set"] = true
L["Choose the equipment set to use when you enter a battleground or arena."] = true

L["You have equipped equipment set: "] = true

L["DURABILITY_DESC"] = "Adjust the settings for the durability information on the character screen."
L['Enable/Disable the display of durability information on the character screen.'] = true

L["Damaged Only"] = true
L["Only show durabitlity information for items that are damaged."] = true

-- GPS module
L['GPS'] = true
L['Show the direction and distance to the selected party or raid member.'] = true

-- Minimap Buttons
L['Skin Buttons'] = true
L['Skins the minimap buttons in Elv UI style.'] = true
L['Skin Style'] = true
L['Change settings for how the minimap buttons are skinned.'] = true
L['The size of the minimap buttons.'] = true

L['No Anchor Bar'] = true
L['Horizontal Anchor Bar'] = true
L['Vertical Anchor Bar'] = true

-- PvP Autorelease
L['PvP Autorelease'] = true
L['Automatically release body when killed inside a battleground.'] = true

-- Track Reputation
L['Track Reputation'] = true
L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'] = true

-- Extra Datatexts
L['Actionbar1DataPanel'] = 'Actionbar 1'
L['Actionbar3DataPanel'] = 'Actionbar 3'
L['Actionbar5DataPanel'] = 'Actionbar 5'

-- Farmer Module
L["FARMER_DESC"] = "Adjust the settings for the tools that help you farm more efficiently on Sunsong Ranch."
L['Farmer Bars'] = true
L['Enable/Disable the farmer bars.'] = true
L['Only active buttons'] = true
L['Only show the buttons for the seeds, portals, tools you have in your bags.'] = true