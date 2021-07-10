--[[
	The purpose of the addon is to tell the player how much anima is in their inventory on demand.
]]--

--[[ TODO
]]--

--[[
	These variables are provided to the addon by Blizzard.
		addonName	: This is self explanatory, but it's the name of the addon.
		t			: This is an empty table. This is how the addon can communicate between files or local functions, sort of like traditional classes.
]]--
local addonName, t = ...;
local levelRequiredForAnima = 51;

BINDING_HEADER_ANIMACOUNTER = addonName;
BINDING_NAME_ANIMACOUNTER_CALCULATE_ANIMA = "Calculate Anima & Cataloged Research";
function AnimaCounterCountAnima(key)
	if (UnitLevel("player") < levelRequiredForAnima) then return end
	if key == GetBindingKey("ANIMACOUNTER_CALCULATE_ANIMA") then
		local currentAnimaCount = 0;
		local currentCatalogedResearchCount = 0;
		for bag = 0, 4, 1 do -- Base inventory, plus the 4 additional bags a player can have.
			for slot = GetContainerNumSlots(bag), 1, -1 do -- Blizzard traverses bags in reverse order, let's follow that logic.
				local _, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(bag, slot);
				local spellName, spellID = GetItemSpell(itemID);
				if (spellName == "Deposit Anima") then
					local quantity = GetItemCount(itemID, false); -- This will need to be multipled against the anima from the spell description.
					local spell = Spell:CreateFromSpellID(spellID); -- GetSpellDescription isn't readily available on call, so create a spell object from the Spell Mixin. We'll get the description from that.
					spell:ContinueOnSpellLoad(function()
						local animaCountInSpellDescription = string.match(spell:GetSpellDescription(), "%d+"); -- Extract the amount of anima from the spell's description.
						currentAnimaCount = currentAnimaCount + (quantity * animaCountInSpellDescription);
					end);
				elseif (spellName == "Deliver Relic") then
					local quantity = GetItemCount(itemID, false); -- This will need to be multipled against the anima from the spell description.
					local spell = Spell:CreateFromSpellID(spellID); -- GetSpellDescription isn't readily available on call, so create a spell object from the Spell Mixin. We'll get the description from that.
					spell:ContinueOnSpellLoad(function()
						local researchCountInSpellDescription = string.match(spell:GetSpellDescription(), "%d+"); -- Extract the amount of anima from the spell's description.
						currentCatalogedResearchCount = currentCatalogedResearchCount + (quantity * researchCountInSpellDescription);
					end);
				end
			end
		end
		
		AnimaCounterAnimaInReservoir = C_CurrencyInfo.GetCurrencyInfo(1813).quantity;
		CatalogedResearchCounterOwnedByPlayer = C_CurrencyInfo.GetCurrencyInfo(1931).quantity;
		print("|cffFFD839" .. addonName .. "|r\n" .. currentAnimaCount .. " |cff5BA4E1Anima|r (" .. (currentAnimaCount + AnimaCounterAnimaInReservoir) .. " |T3528288:0|t)\n" .. currentCatalogedResearchCount .. " |cffD4C79DCataloged Research|r (" .. (currentCatalogedResearchCount + CatalogedResearchCounterOwnedByPlayer) .. " |T1506458:0|t)");
	end
end