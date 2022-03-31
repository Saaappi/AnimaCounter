local addonName, t = ...
local levelRequiredForAnima = 51

BINDING_HEADER_ANIMACOUNTER = addonName;
BINDING_NAME_ANIMACOUNTER_CALCULATE_ANIMA = "Calculate Anima & Cataloged Research";
function AnimaCounterCountAnima(key)
	if (UnitLevel("player") < levelRequiredForAnima) then return end
	if key == GetBindingKey("ANIMACOUNTER_CALCULATE_ANIMA") then
		local animaCount = 0
		local researchCount = 0
		for bag = 0, 4, 1 do -- Base inventory, plus the 4 additional bags a player can have.
			for slot = GetContainerNumSlots(bag), 1, -1 do -- Blizzard traverses bags in reverse order, let's follow that logic.
				local _, count, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(bag, slot);
				local spellName, spellID = GetItemSpell(itemID)
				if (spellName == "Deposit Anima") then
					local spell = Spell:CreateFromSpellID(spellID) -- GetSpellDescription isn't readily available on call, so create a spell object from the Spell Mixin. We'll get the description from that.
					spell:ContinueOnSpellLoad(function()
						local animaCountFromItem = string.match(spell:GetSpellDescription(), "%d+") -- Extract the amount of anima from the spell's description.
						animaCount = animaCount + (count * animaCountFromItem)
					end)
				elseif (spellName == "Deliver Relic") then
					local spell = Spell:CreateFromSpellID(spellID) -- GetSpellDescription isn't readily available on call, so create a spell object from the Spell Mixin. We'll get the description from that.
					spell:ContinueOnSpellLoad(function()
						local researchCountFromItem = string.match(spell:GetSpellDescription(), "%d+") -- Extract the amount of anima from the spell's description.
						researchCount = researchCount + (count * researchCountFromItem)
					end)
				end
			end
		end
		
		local currentAnimaCount = C_CurrencyInfo.GetCurrencyInfo(1813).quantity
		local currentResearchCount = C_CurrencyInfo.GetCurrencyInfo(1931).quantity
		print("|cffFFD839" .. addonName .. "|r\n" .. 
		(animaCount+currentAnimaCount) .. " |cff5BA4E1Anima|r |T3528288:0|t\n" .. (researchCount+currentResearchCount) .. " |cff88AADCCataloged Research|r |T1506458:0|t" .. "\n" ..
		C_CurrencyInfo.GetCurrencyInfo(1810).quantity .. " |cff0070ddRedeemed Souls|r " .. "|T1391776:0|t" .. "\n" ..
		C_CurrencyInfo.GetCurrencyInfo(1979).quantity .. " |cff0070ddCyphers of the First Ones|r " .. "|T3950362:0|t"
		)
	end
end