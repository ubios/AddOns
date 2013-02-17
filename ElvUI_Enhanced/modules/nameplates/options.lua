local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

E.Options.args.nameplate.args.general.args.showthreat = {
	type = "toggle",
	order = 5,
	name = L["Threat Text"],
	desc = L["Display threat level as text on targeted or mouseover nameplate."],
}