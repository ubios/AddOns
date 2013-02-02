local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local M = E:GetModule('Equipment')

local tsort = table.sort

E.Options.args.equipment = {
	type = 'group',
	name = L['Equipment'],
	get = function(info) return E.private.equipment[ info[#info] ] end,
	set = function(info, value) E.private.equipment[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L["EQUIPMENT_DESC"],
		},
		specialization = {
			order = 2,
			type = "group",
			name = L["Specialization"],
			guiInline = true,
			disabled = function() return GetNumEquipmentSets() == 0 end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
					desc = L['Enable/Disable the specialization switch.'],
					get = function(info) return E.private.equipment.specialization.enable end,
					set = function(info, value) E.private.equipment.specialization.enable = value end
				},
				primary = {
					type = "select",
					order = 2,
					name = L["Primary Talent"],
					desc = L["Choose the equipment set to use for your primary specialization."],
					disabled = function() return not E.private.equipment.specialization.enable end,
					values = function()
						local sets = { ["none"] = L["No Change"] }
						for i = 1, GetNumEquipmentSets() do
							local name = GetEquipmentSetInfo(i)
							if name then
								sets[name] = name
							end
						end
						tsort(sets, function(a, b) return a < b end)
						return sets
					end,
				},
				secondary = {
					type = "select",
					order = 3,
					name = L["Secondary Talent"],
					desc = L["Choose the equipment set to use for your secondary specialization."],
					disabled = function() return not E.private.equipment.specialization.enable end,
					values = function()
						local sets = { ["none"] = L["No Change"] }
						for i = 1, GetNumEquipmentSets() do
							local name, _, _, _, _, _, _, _, _ = GetEquipmentSetInfo(i)
							if name then
								sets[name] = name
							end
						end
						tsort(sets, function(a, b) return a < b end)
						return sets
					end,
				},
			},
		},
		battleground = {
			order = 3,
			type = "group",
			name = L["Battleground"],
			guiInline = true,
			disabled = function() return GetNumEquipmentSets() == 0 end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
					desc = L['Enable/Disable the battleground switch.'],
					get = function(info) return E.private.equipment.battleground.enable end,
					set = function(info, value) E.private.equipment.battleground.enable = value end
				},
				equipmentset = {
					type = "select",
					order = 2,
					name = L["Equipment Set"],
					desc = L["Choose the equipment set to use when you enter a battleground or arena."],
					disabled = function() return not E.private.equipment.battleground.enable end,
					values = function()
						local sets = {
							["none"] = L["No Change"],
						}
						for i = 1, GetNumEquipmentSets() do
							local name = GetEquipmentSetInfo(i)
							if name then
								sets[name] = name
							end
						end
						tsort(sets, function(a, b) return a < b end)
						return sets
					end,
				},
			},
		},
	},
}
