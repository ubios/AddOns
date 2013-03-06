local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local EO = E:NewModule('EnhancedOptions', 'AceEvent-3.0')
local EP = LibStub("LibElvUIPlugin-1.0")
local ElvUIEnhanced, ns = ...

local tsort = table.sort

local positionValues = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
	CENTER = 'CENTER',
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
}

function EO:DataTextOptions()
	local EDT = E:GetModule('ExtraDataTexts')

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
end

function EO:EquipmentOptions()
	local ME = E:GetModule('MiscEnh')
	local EQ = E:GetModule('Equipment')

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
			intro2 = {
				type = "description",
				name = L["DURABILITY_DESC"],
				order = 4,
			},		
			durability = {
				type = 'group',
				name = DURABILITY,
				guiInline = true,
				order = 5,
				get = function(info) return E.private.equipment.durability[ info[#info] ] end,
				set = function(info, value) E.private.equipment.durability[ info[#info] ] = value ME:UpdateDurability() end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L["Enable/Disable the display of durability information on the character screen."],
					},
					onlydamaged = {
						type = "toggle",
						order = 2,
						name = L["Damaged Only"],
						desc = L["Only show durabitlity information for items that are damaged."],
						disabled = function() return not E.private.equipment.durability.enable end,
					},
				},
			},
		},
	}
	
	EQ:UpdateTalentConfiguration()
end

function EO:FarmerOptions()
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
						set = function(info, value) E.private.farmer.farmbars.enable = value F:UpdateLayout() end
					},
					onlyactive = {
						order = 2,
						type = 'toggle',
						name = L['Only active buttons'],
						desc = L['Only show the buttons for the seeds, portals, tools you have in your bags.'],
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
					seedbardirection = {
						order = 4,
						type = 'select',
						name = L['Seed Bar Direction'],
						desc = L['The direction of the seed bar buttons (Horizontal or Vertical).'],
						set = function(info, value) E.private.farmer.farmbars.seedbardirection = value F:UpdateLayout() end,
						disabled = function() return not E.private.farmer.farmbars.enable end,
						values = {
							['VERTICAL'] = L['Vertical'],
							['HORIZONTAL'] = L['Horizontal'],
						},
					},				
				},
			},
		},
	}
end

function EO:MapOptions()
	local MB = E:GetModule('MinimapButtons')

	E.Options.args.general.args.minimap.args.locationdigits = {
		order = 20,
		type = 'range',
		name = L['Location Digits'],
		desc = L['Number of digits for map location.'],
		min = 0, max = 2, step = 1,
		get = function(info) return E.private.general.minimap.locationdigits end,
		set = function(info, value) E.private.general.minimap.locationdigits = value; E:GetModule('Minimap'):UpdateSettings() end,					
		disabled = function() return E.db.general.minimap.locationText ~= 'ABOVE' end,
	}

	E.Options.args.general.args.minimap.args.hideincombat = {
		order = 21,
		type = 'toggle',
		name = L["Combat Hide"],
		desc = L["Hide minimap while in combat."],
		get = function(info) return E.private.general.minimap.hideincombat end,
		set = function(info, value) E.private.general.minimap.hideincombat = value; E:GetModule('Minimap'):UpdateSettings() end,					
	}
	
	E.Options.args.general.args.minimap.args.fadeindelay = {
		order = 22,
		type = 'range',
		name = L["FadeIn Delay"],
		desc = L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"],
		min = 0, max = 20, step = 1,
		get = function(info) return E.private.general.minimap.fadeindelay end,	
		set = function(info, value) E.private.general.minimap.fadeindelay = value end,	
		disabled = function() return not E.private.general.minimap.hideincombat end,
	}
	
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
end

function EO:MiscOptions()
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
end

function EO:NameplateOptions()
	E.Options.args.nameplate.args.general.args.showthreat = {
		type = "toggle",
		order = 5,
		name = L["Threat Text"],
		desc = L["Display threat level as text on targeted, boss or mouseover nameplate."],
	}
end

function EO:UnitFramesOptions()
	local UF = E:GetModule('UnitFrames')
	
	--Target
	E.Options.args.unitframe.args.target.args.gps = {
		order = 1000,
		type = 'group',
		name = L['GPS'],
		get = function(info) return E.db.unitframe.units['target']['gps'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units['target']['gps'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
				desc = L['Show the direction and distance to the selected party or raid member.'],
			},
			position = {
				type = 'select',
				order = 3,
				name = L['Position'],
				values = positionValues,
			},
		},
	}
	
	--Focus
	E.Options.args.unitframe.args.focus.args.gps = {
		order = 1000,
		type = 'group',
		name = L['GPS'],
		get = function(info) return E.db.unitframe.units['focus']['gps'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units['focus']['gps'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
				desc = L['Show the direction and distance to the selected party or raid member.'],
			},
			position = {
				type = 'select',
				order = 3,
				name = L['Position'],
				values = positionValues,
			},
		},
	}
end

function EO:GetOptions()
	EO:DataTextOptions()
	EO:EquipmentOptions()
	EO:FarmerOptions()
	EO:MapOptions()
	EO:MiscOptions()
	EO:NameplateOptions()
	EO:UnitFramesOptions()
end

function EO:Initialize()
  EP:RegisterPlugin(ElvUIEnhanced, EO.GetOptions)
end

E:RegisterModule(EO:GetName())
