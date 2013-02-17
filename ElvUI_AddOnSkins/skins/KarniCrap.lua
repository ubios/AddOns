local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "KarniCrapSkin"
local function SkinKarniCrap(self)
	AS:SkinFrame(KarniCrap)
	AS:SkinFrame(KarniCrap_CategoryFrame)
	AS:SkinFrame(KarniCrap_OptionsFrame)
	AS:SkinFrame(KarniCrap_Blacklist)
	AS:SkinFrame(KarniCrap_Whitelist)
	AS:SkinFrame(KarniCrap_Inventory)
	KarniCrap_Inventory_ScrollBar:StripTextures(True)
	KarniCrapTab1:Point("BOTTOMLEFT", KarniCrap, "BOTTOMLEFT",0,-30)
	S:HandleScrollBar(KarniCrap_Inventory_ScrollBarScrollBar)
	S:HandleButton(KarniCrap_BtnBlacklistRemove)
	S:HandleButton(KarniCrap_BtnWhitelistRemove)
	S:HandleCloseButton(KarniCrapCloseButton)
	S:HandleTab(KarniCrapTab1)
	S:HandleTab(KarniCrapTab2)
	S:HandleTab(KarniCrapTab3)
	S:HandleButton(KarniCrap_InvHeader1)
	S:HandleButton(KarniCrap_InvHeader2)
	S:HandleButton(KarniCrap_ValueHeader)
	S:HandleButton(KarniCrap_InvHeader4)
	S:HandleButton(KarniCrap_BtnDestroyItem)
	S:HandleButton(KarniCrap_BtnDestroyAllCrap)
	KarniCrapPortrait:Kill()

	--Checkboxes
	S:HandleCheckBox(KarniCrap_CBEnabled)
	S:HandleCheckBox(KarniCrap_CBPoor)
	S:HandleCheckBox(KarniCrap_Tab1_CBCommon)
	S:HandleCheckBox(KarniCrap_Tab1_CBUseStackValue)
	S:HandleCheckBox(KarniCrap_Tab1_CBEcho)
	S:HandleCheckBox(KarniCrap_CBDestroy)
	S:HandleCheckBox(KarniCrap_CBDestroySlots)
	S:HandleCheckBox(KarniCrap_CBNoDestroyTradeskill)
	S:HandleCheckBox(KarniCrap_CBDestroyGroup)
	S:HandleCheckBox(KarniCrap_CBDestroyRaid)
	S:HandleCheckBox(KarniCrap_Cloth_CBLinen)
	S:HandleCheckBox(KarniCrap_Cloth_CBLinen_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBWool)
	S:HandleCheckBox(KarniCrap_Cloth_CBWool_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBSilk)
	S:HandleCheckBox(KarniCrap_Cloth_CBSilk_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBMageweave)
	S:HandleCheckBox(KarniCrap_Cloth_CBMageweave_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBRunecloth)
	S:HandleCheckBox(KarniCrap_Cloth_CBRunecloth_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBNetherweave)
	S:HandleCheckBox(KarniCrap_Cloth_CBNetherweave_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBFrostweave)
	S:HandleCheckBox(KarniCrap_Cloth_CBFrostweave_Never)
	S:HandleCheckBox(KarniCrap_Cloth_CBEmbersilk)
	S:HandleCheckBox(KarniCrap_Cloth_CBEmbersilk_Never)
	S:HandleCheckBox(KarniCrap_Corpses_CBSkinnable)
	S:HandleCheckBox(KarniCrap_Corpses_CBGatherable)
	S:HandleCheckBox(KarniCrap_Corpses_CBMinable)
	S:HandleCheckBox(KarniCrap_Corpses_CBEngineerable)
	S:HandleCheckBox(KarniCrap_Corpses_CBSkilledEnough)
	S:HandleCheckBox(KarniCrap_Consumables_RBFood1)
	S:HandleCheckBox(KarniCrap_Consumables_RBFood2)
	S:HandleCheckBox(KarniCrap_Consumables_CBFoodMax)
	S:HandleCheckBox(KarniCrap_Consumables_RBWater1)
	S:HandleCheckBox(KarniCrap_Consumables_RBWater2)
	S:HandleCheckBox(KarniCrap_Consumables_CBWaterMax)
	S:HandleCheckBox(KarniCrap_Potions_RBHealth1)
	S:HandleCheckBox(KarniCrap_Potions_RBHealth2)
	S:HandleCheckBox(KarniCrap_Potions_CBHealthMax)
	S:HandleCheckBox(KarniCrap_Potions_RBMana1)
	S:HandleCheckBox(KarniCrap_Potions_RBMana2)
	S:HandleCheckBox(KarniCrap_Potions_CBManaMax)
	S:HandleCheckBox(KarniCrap_Quality_CBQualityPoor)
	S:HandleCheckBox(KarniCrap_Quality_CBQualityCommon)
	S:HandleCheckBox(KarniCrap_Quality_CBQualityUncommon)
	S:HandleCheckBox(KarniCrap_Quality_CBQualityRare)
	S:HandleCheckBox(KarniCrap_Quality_CBQualityEpic)
	S:HandleCheckBox(KarniCrap_Quality_CBQualityGrouped)
	S:HandleCheckBox(KarniCrap_Scrolls_CBMaxScrolls)
	S:HandleCheckBox(KarniCrap_Scrolls_CBScrollAgility)
	S:HandleCheckBox(KarniCrap_Scrolls_CBScrollIntellect)
	S:HandleCheckBox(KarniCrap_Scrolls_CBScrollProtection)
	S:HandleCheckBox(KarniCrap_Scrolls_CBScrollSpirit)
	S:HandleCheckBox(KarniCrap_Scrolls_CBScrollStamina)
	S:HandleCheckBox(KarniCrap_Scrolls_CBScrollStrength)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBCooking)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBFishing)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBPickpocketing)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBEnchanting)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBGathering)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBMilling)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBMining)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBProspecting)
	S:HandleCheckBox(KarniCrap_Tradeskills_CBSkinning)
	S:HandleCheckBox(KarniCrap_Inventory_CBHideQuestItems)
	S:HandleCheckBox(KarniCrap_CBOpenAtMerchant)

	for i = 1, 15 do
		S:HandleCloseButton(_G["KarniInvEntry"..i.."_BtnCrap"])
	end
end

AS:RegisterSkin(name,SkinKarniCrap)