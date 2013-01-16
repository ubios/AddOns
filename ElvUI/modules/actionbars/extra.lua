local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local AB = E:GetModule('ActionBars');

function AB:SetupExtraButton()
	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 150)
	holder:Size(ExtraActionBarFrame:GetSize())
	
	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
		
	ExtraActionBarFrame.ignoreFramePositionManager  = true
	
	local button
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		button = _G[("ExtraActionButton%d"):format(i)]
		if button then
			button.noResize = true;
			button.pushed = true
			button.checked = true
			
			self:StyleButton(button, true)
			button:SetTemplate()
			_G[("ExtraActionButton%dIcon"):format(i)]:SetDrawLayer('ARTWORK')
			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)
		end
	end
	
	if HasExtraActionBar() then
		ExtraActionBarFrame:Show();
	end
	
	E:CreateMover(holder, 'BossButton', L['Boss Button'], nil, nil, nil, 'ALL,ACTIONBARS');
end