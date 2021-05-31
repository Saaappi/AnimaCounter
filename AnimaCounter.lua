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
local animaTotal = 0;
local e = CreateFrame("Frame"); -- This is the invisible frame that will listen for registered events.

SLASH_AnimaCounter1 = "/ac";
SLASH_AnimaCounter2 = "/animacounter";
SlashCmdList["AnimaCounter"] = function(command, editbox)
	local _, _, command, arguments = string.find(command, "%s?(%w+)%s?(.*)"); -- Using pattern matching the addon will be able to interpret subcommands.
	if not command or command == "" then
		if UnitLevel("player") < 48 then return end; -- Anima can't be collected until at least 48, so don't bother running the code below because Anima won't be found.
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
							animaTotal = animaTotal + (quantity*anima);
						end);
					end
				end
			end
		end
		if animaTotal == 0 then -- If the player doesn't open their bags shortly after logging in, then Anima detected can be 0.
			print("|cffefcb42" .. addonName .. "|r: No " .. "|cff66bbff" .. "Anima" .. "|r found. This may be a mistake. Open your bags, then try again.");
		else
			print("|cffefcb42" .. addonName .. "|r: " .. animaTotal .. " |cff66bbff" .. "Anima" .. "|r");
		end
		animaTotal = 0; -- Reset the total to prevent tainting consecutive executions.
	end
end