local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--General
P['general']['minimap']['locationText'] = 'ABOVE'

--Unitframes
P['unitframe']['units']['target']['gps'] = {
	['enable'] = true,
	['position'] = 'BOTTOMRIGHT'
}

P['unitframe']['units']['target']['attackicon'] = {
	['enable'] = true,
	['xOffset'] = 24,
	['yOffset'] = 6,
}

P['unitframe']['units']['focus']['gps']= {
	['enable'] = true,
	['position'] = 'LEFT'
}

-- Nameplates
P['nameplate'].showthreat = true

-- DataTexts
P['datatexts']['Actionbar1DataPanel'] = false
P['datatexts']['Actionbar3DataPanel'] = false
P['datatexts']['Actionbar5DataPanel'] = false

P['datatexts']['panels']['Actionbar1DataPanel'] = {
	['left'] = 'Crit Chance',
	['middle'] = 'Target Range',
	['right'] = 'Armor',
}

P['datatexts']['panels']['Actionbar3DataPanel'] = 'Spec Switch'

P['datatexts']['panels']['Actionbar5DataPanel'] = 'Call to Arms'
