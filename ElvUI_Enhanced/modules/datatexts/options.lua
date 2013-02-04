local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDT = E:GetModule('ExtraDataTexts')
local DT = E:GetModule('DataTexts')

E.Options.args.datatexts.args.actionbar1 = {
	order = 20,
	name = L['Actionbar1DataPanel'],
	type = 'toggle',
	set = function(info, value) 
		E.db.datatexts[ info[#info] ] = value
		EDT:UpdateSettings()
	end,
}

E.Options.args.datatexts.args.actionbar3 = {
	order = 21,
	name = L['Actionbar3DataPanel'],
	type = 'toggle',
	set = function(info, value) 
		E.db.datatexts[ info[#info] ] = value
		EDT:UpdateSettings()
	end,
}

E.Options.args.datatexts.args.actionbar5 = {
	order = 22,
	name = L['Actionbar5DataPanel'],
	type = 'toggle',
	set = function(info, value) 
		E.db.datatexts[ info[#info] ] = value
		EDT:UpdateSettings()
	end,
}