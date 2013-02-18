local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local F = E:GetModule('Farmer')

E.Options.args.farmer = {
	type = 'group',
	name = L['Farmer'],
	get = function(info) return E.private.farmer[ info[#info] ] end,
	set = function(info, value) E.private.farmer[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L["FARMER_DESC"],
		},
		enabled = {
			order = 2,
			type = 'toggle',
			name = L['Enable'],
			set = function(info, value) E.private.farmer.enabled = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		farmbars = {
			order = 3,
			type = "group",
			name = L["Farmer Bars"],
			guiInline = true,
			disabled = function() return not E.private.farmer.enabled end,
			get = function(info) return E.private.farmer.farmbars[ info[#info] ] end,
			set = function(info, value) E.private.farmer.farmbars[ info[#info] ] = value end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L['Enable'],
					desc = L['Enable/Disable the farmer bars.'],
					get = function(info) return E.private.farmer.farmbars.enable end,
					set = function(info, value) E.private.farmer.farmbars.enable = value F:UpdateLayout() end
				},
				onlyactive = {
					order = 2,
					type = 'toggle',
					name = L['Only active buttons'],
					desc = L['Only show the buttons for the seeds, portals, tools you have in your bags.'],
					get = function(info) return E.private.farmer.farmbars.onlyactive end,
					set = function(info, value) E.private.farmer.farmbars.onlyactive = value F:UpdateLayout() end,
					disabled = function() return not E.private.farmer.farmbars.enable end,
				},
				droptools = {
					order = 3,
					type = 'toggle',
					name = L['Drop Tools'],
					desc = L['Automatically drop tools from your bags when leaving the farming area.'],
					disabled = function() return not E.private.farmer.farmbars.enable end,
				},
			},
		},
	},
}
