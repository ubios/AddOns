local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

E.Options.args.general.args.minimap.args.skinButtons = {
	order = 20,
	type = 'toggle',
	name = L['Skin Buttons'],
	desc = L['Skins the minimap buttons in Elv UI style.'],
	get = function(info) return E.private.general.minimap.skinButtons end,
	set = function(info, value) E.private.general.minimap.skinButtons = value; E:StaticPopup_Show("PRIVATE_RL") end,					
}

E.Options.args.general.args.minimap.args.skinStyle = {
	order = 21,
	type = 'select',
	name = L['Skin Style'],
	desc = L['Change settings for how the minimap buttons are skinned.'],
	get = function(info) return E.private.general.minimap.skinStyle end,
	set = function(info, value) E.private.general.minimap.skinStyle = value; E:GetModule('MinimapButtons'):UpdateLayout() end,
	values = {
		['NOANCHOR'] = L['No Anchor Bar'],
		['HORIZONTAL'] = L['Horizontal Anchor Bar'],
		['VERTICAL'] = L['Vertical Anchor Bar'],
	},
	disabled = function() return not E.private.general.minimap.skinButtons end,
}

E.Options.args.general.args.minimap.args.buttonSize = {
	order = 22,
	type = 'range',
	name = L['Button Size'],
	desc = L['The size of the minimap buttons.'],
	min = 16, max = 40, step = 1,
	get = function(info) return E.private.general.minimap.buttonSize end,
	set = function(info, value) E.private.general.minimap.buttonSize = value; E:GetModule('MinimapButtons'):UpdateLayout() end,
	disabled = function() return not E.private.general.minimap.skinButtons end,
}