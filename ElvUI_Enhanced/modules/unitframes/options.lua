local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF

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
};

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
