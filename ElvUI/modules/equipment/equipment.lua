local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local EQ = E:NewModule('Equipment', 'AceHook-3.0', 'AceEvent-3.0');

local changingEquipmentSet = nil
local join = string.join

local function GetCurrentEquipmentSet()
	if GetNumEquipmentSets() == 0 then return false end
	for i = 1, GetNumEquipmentSets() do
		local name, _, _, isEquipped = GetEquipmentSetInfo(i)
		if isEquipped then
			return name
		end
	end
	return false
end

function EQ:CheckForGearChange()
	if InCombatLockdown() or GetNumEquipmentSets() == 0 or not self.db then return end

	local active, activeSet = GetActiveSpecGroup(), GetCurrentEquipmentSet()
	
	local inInstance, instanceType = IsInInstance()
	if (inInstance and (instanceType == "pvp")) then
		if self.db.battleground.enable then
			local set = self.db.equipmentset
			if set ~= "none" and set ~= activeSet then
				changingEquipmentSet = set
				UseEquipmentSet(set)
			end
			return
		end
	end
	
	if not GetSpecializationInfo(1) then return end
	if self.db.specialization.enable then
		local set = active == 1 and self.db.primary or self.db.secondary
		if set ~= "none" and set ~= activeSet then
			changingEquipmentSet = set
			UseEquipmentSet(set)			
		end
	end
end

function EQ:UpdateTalentConfiguration()
	local specialization = GetSpecialization(false, false, 1)
	if (specialization) then
		E.Options.args.equipment.args.specialization.args.primary.name = select(2, GetSpecializationInfo(specialization)) or L["Primary Talent"]
	end
	specialization = GetSpecialization(false, false, 2)
	if (specialization) then
		E.Options.args.equipment.args.specialization.args.secondary.name = select(2, GetSpecializationInfo(specialization)) or L["Secondary Talent"]
	end
end

function EQ:EquipmentSwapFinished()
	if changingEquipmentSet then
		E:Print(join('', L["You have equipped equipment set: "], changingEquipmentSet))
		changingEquipmentSet = nil
	end
end

function EQ:Initialize()
	E.equipment = self
	
	self.db = E.private.equipment;
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckForGearChange")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckForGearChange")
	
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "UpdateTalentConfiguration")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateTalentConfiguration")
	
	-- self:RegisterEvent("EQUIPMENT_SWAP_PENDING", "PendingEquipmentSwap")
	self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", "EquipmentSwapFinished")
	
	self:UpdateTalentConfiguration()
end

E:RegisterModule(EQ:GetName())