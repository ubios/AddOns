local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

E.Options.args.general.args.general.args.pvpautorelease = {
	order = 40,
	type = "toggle",
	name = L['PvP Autorelease'],
	desc = L['Automatically release body when killed inside a battleground.'],
	get = function(info) return E.private.general.pvpautorelease end,
	set = function(info, value) E.private.general.pvpautorelease = value; E:StaticPopup_Show("PRIVATE_RL") end,
}

E.Options.args.general.args.general.args.autorepchange = {
	order = 41,
	type = "toggle",
	name = L['Track Reputation'],
	desc = L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'],
	get = function(info) return E.private.general.autorepchange end,
	set = function(info, value) E.private.general.autorepchange = value; end,
}
