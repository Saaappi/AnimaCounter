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
local currentAnimaCount;
local e = CreateFrame("Frame"); -- This is the invisible frame that will listen for registered events.
local maxLevel = 60;

-- Event Registrations
e:RegisterEvent("ADDON_LOADED");
e:RegisterEvent("BAG_UPDATE");
e:RegisterEvent("PLAYER_LOGOUT");

-- Functions
local function ScanInventoryForAnima()
	if UnitLevel("player") < maxLevel then return end; -- No reason to account for anyone that isn't at least 60.
	for bag = 0, 4, 1 do -- Base inventory, plus the 4 additional bags a player can have.
		for slot = GetContainerNumSlots(bag), 1, -1 do -- Blizzard traverses bags in reverse order, let's follow that logic.
			local _, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(bag, slot);
			if itemID then
				local spellName, spellID = GetItemSpell(itemID);
				if spellName == "Deposit Anima" then
					local quantity = GetItemCount(itemID, false); -- This will need to be multipled against the anima from the spell description.
					local spell = Spell:CreateFromSpellID(spellID); -- GetSpellDescription isn't readily available on call, so create a spell object from the Spell Mixin. We'll get the description from that.
					spell:ContinueOnSpellLoad(function()
						local animaCountInDescription = string.match(spell:GetSpellDescription(), "%d+"); -- Extract the amount of anima from the spell's description.
						currentAnimaCount = currentAnimaCount + (quantity * animaCountInDescription);
					end);
				end
			end
		end
	end
	if IsShiftKeyDown() then
		if (tonumber(currentAnimaCount) > 0) then
			GameTooltip:AddLine("Anima Count: ", currentAnimaCount);
		end
	end
end

e:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == addonName then
		currentAnimaCount = AnimaCounterAnimaCount or 0;
	end
	if event == "BAG_UPDATE" then
		ScanInventoryForAnima();
	end
	if event == "PLAYER_LOGOUT" then
		AnimaCounterAnimaCount = currentAnimaCount;
	end
end);

GameTooltip:HookScript("OnTooltipSetItem", ScanInventoryForAnima);