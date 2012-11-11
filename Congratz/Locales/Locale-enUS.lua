local L = LibStub("AceLocale-3.0"):NewLocale("Congratz", "enUS", true);

---- Default Messages ----
L["Congratulations"] = true;
L["Gratz"] = true;
L["Congratz"] = true;
L["Gz"] = true;
L["Gz m8"] = true;
L["Gratz #S"] = true;

L["Gratz All !!"] = true;
L["Gratz both."] = true;

L["Big gratz #N!"] = true;
L["Awesome, gratz #N!!"] = true;

---- Slash Commands ----
L["congratz"] = true;

L["Show"] = true;
L["Shows the current Congratz settings."] = true;
L["The message table contains the following entries:"] = true;
L["The group message is: %q"] = true;
L["The 2 person message is: %q"] = true;
L["The big gratz pattern is: %q"] = true;
L["The awesome pattern is: %q"] = true;
L["The random time delay range is 8 to %d seconds."] = true;

L["Debug"] = true;
L["Enable Congratz debug messages."] = true;

L["Information"] = true;
L["Shows current state of congratz."] = true;

L["Add"] = true;
L["Adds a message to the message table. Use #N or #S to be replace with the players name."] = true;
L["%q has been added to message table."] = true;

L["Delete"] = true;
L["Deletes the message in the specified postion."] = true;
L["There must be atleast one message in the table at all times."] = true;
L["No entry for position %d."] = true;
L["%q removed from the message table."] = true;

L["Group"] = true;
L["Sets a message for when multiple people earn a gratz."] = true;
L["%q is now the new group message."] = true;

L["Both"] = true;
L["Sets a message for when 2 people earn a gratz."] = true;
L["%q is now the new 2 person message."] = true;

L["BigGratz"] = true;
L["Pattern for big gratz message for achievements with 50 to 70 points."] = true;

L["Awesome"] = true;
L["Pattern for awesome message for achievements with over 70 points."] = true;

L["Delay"] = true;
L["Sets the range for the random delay (8 seconds is added to this)"] = true;
L["The random time delay range is now 8 to %d seconds."] = true;
L["You must enter a number greater than 0."] = true;
