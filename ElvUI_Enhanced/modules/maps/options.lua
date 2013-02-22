local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local MB = E:GetModule('MinimapButtons')

E.Options.args.general.args.minimapbar = {
	order = 2,
	get = function(info) return E.private.general.minimapbar[ info[#info] ] end,	
	type = "group",
	name = L["Minimap Button Bar"],
	guiInline = true,
	args = {
		skinButtons = {
			order = 1,
			type = 'toggle',
			name = L['Skin Buttons'],
			desc = L['Skins the minimap buttons in Elv UI style.'],
			set = function(info, value) E.private.general.minimapbar.skinButtons = value; E:StaticPopup_Show("PRIVATE_RL") end,					
		},
		skinStyle = {
			order = 2,
			type = 'select',
			name = L['Skin Style'],
			desc = L['Change settings for how the minimap buttons are skinned.'],
			set = function(info, value) E.private.general.minimapbar.skinStyle = value; MB:UpdateLayout() end,
			disabled = function() return not E.private.general.minimapbar.skinButtons end,
			values = {
				['NOANCHOR'] = L['No Anchor Bar'],
				['HORIZONTAL'] = L['Horizontal Anchor Bar'],
				['VERTICAL'] = L['Vertical Anchor Bar'],
			},
		},
		buttonSize = {
			order = 3,
			type = 'range',
			name = L['Button Size'],
			desc = L['The size of the minimap buttons.'],
			min = 16, max = 40, step = 1,
			set = function(info, value) E.private.general.minimapbar.buttonSize = value; MB:UpdateLayout() end,
			disabled = function() return not E.private.general.minimapbar.skinButtons or E.private.general.minimapbar.skinStyle == 'NOANCHOR' end,
		},
		mouseover = {
			order = 4,
			name = L['Mouse Over'],
			desc = L['The frame is not shown unless you mouse over the frame.'],
			type = "toggle",
			set = function(info, value) E.private.general.minimapbar.mouseover = value; MB:ChangeMouseOverSetting() end,
			disabled = function() return not E.private.general.minimapbar.skinButtons or E.private.general.minimapbar.skinStyle == 'NOANCHOR' end,
		},
	}
}

E.Options.args.general.args.minimap.args.locationText.values = {
	['MOUSEOVER'] = L['Minimap Mouseover'],
	['SHOW'] = L['Always Display'],
	['ABOVE'] = L['Above Minimap'],
	['HIDE'] = L['Hide'],
}
