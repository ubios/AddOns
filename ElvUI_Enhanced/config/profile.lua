local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--For some reason datatext settings refuses to work if there is no general setting block here O_o
--Core

--Unitframes
P['unitframe']['units']['target']['gps'] = {
	['enable'] = true,
	['position'] = 'BOTTOMRIGHT'
}

P['unitframe']['units']['focus']['gps']= {
	['enable'] = true,
	['position'] = 'LEFT'
}
