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
local a = 0;
local total = 0;
local e = CreateFrame("Frame"); -- This is the invisible frame that will listen for registered events.

-- Event Registrations
e:RegisterEvent("GLOBAL_MOUSE_UP");

e:SetScript("OnEvent", function(self, event, ...)
	if event == "GLOBAL_MOUSE_UP" then
		if UnitLevel("player") < 48 then return end; -- Anima can't be collected until at least 48, so don't bother running the code below because Anima won't be found.
		if CharacterFrame:IsVisible() then
			if TokenFrameContainerButton1:IsVisible() then -- Currency Tab: Shadowlands
				TokenFrameContainerButton5Name:SetText("Anima");
				for bag = 0, 4, 1 do -- Anima can only be stored in the inventory, so scan each bag.
					for slot = GetContainerNumSlots(bag), 1, -1 do -- Blizzard reads the bag in reverse, so let's match that in code.
						local _, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(bag, slot);
						if itemID then -- Catch any exception where itemID might be nil.
							local spellName, spellID = GetItemSpell(itemID);
							if spellName == "Deposit Anima" then
								local quantity = GetItemCount(itemID, false); -- This will need to be multipled against the anima from the spell description.
								local spell = Spell:CreateFromSpellID(spellID); -- GetSpellDescription isn't readily available on call, so create a spell object from the Spell Mixin. We'll get the description from that.
								spell:ContinueOnSpellLoad(function()
									local anima = string.match(spell:GetSpellDescription(), "%d+"); -- Extract the amount of anima from the spell's description.
									total = total + (quantity*anima);
								end);
							end
						end
					end
				end
				-- If the total anima the player has doesn't match what was previously written to the frame, then update it.
				a = (TokenFrameContainerButton5Count:GetText()):match("%((%d+)%)");
				if tonumber(a) ~= tonumber(total) then
					TokenFrameContainerButton5Count:SetText(TokenFrameContainerButton5Count:GetText() .. " (" .. total .. ")");
				end
				total = 0;
			end
		end
	end
end);