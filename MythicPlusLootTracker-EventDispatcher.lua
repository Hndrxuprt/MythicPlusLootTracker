local AddonName, Addon = ...

local function ProcessEvent(self, event, ...)
	if event == 'ADDON_LOADED' then
        local addOnName = ...
        Addon.OnAddonLoaded(addOnName)

        if addOnName == "Blizzard_EncounterJournal" then
            Addon.InjectEncounterJournal()
        end
    elseif event == "FIRST_FRAME_RENDERED" then
        C_Timer.After(1, function()
            Addon.StoreCharacterData()      
        end)
        C_MythicPlus.RequestMapInfo()
        local currentSeason = C_MythicPlus.GetCurrentSeason()
        if currentSeason and Addon.currentSeason < currentSeason then
            Addon.currentSeason = currentSeason
        end
    elseif event == "CHAT_MSG_CURRENCY" or event == "CURRENCY_DISPLAY_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" then
        Addon.StoreCharacterData()  
    elseif event == 'ENCOUNTER_LOOT_RECEIVED' then
        local lootEncounterId, itemID, itemLink, quantity, unitName, className = ...
        local playerID = Addon.GetPlayerID()
        local name = Addon.GetPlayerName()

        if unitName == playerID or unitName == name then
            local _, _, difficultyIndex, _, _, _, _, _, _, _ = GetInstanceInfo()
            if Addon.IsValueInTable(Addon.Constants.MPLUS_DIFFICULTY_INDICES, difficultyIndex) then
                Addon.LootReceivedEvent(itemID, itemLink, quantity, playerID, lootEncounterId)
            end
        end
    elseif event == 'CHALLENGE_MODE_COMPLETED' then
        Addon.CalcDungeonStat()
        Addon.StoreCharacterData()
    elseif event == 'TRADE_TARGET_ITEM_CHANGED' then
        local tradeSlotIndex = ...
        Addon.DetectTrade(tradeSlotIndex)
    elseif event == 'SHOW_LOOT_TOAST' then
        local typeIdentifier, itemLink, quantity, specID, sex, personalLootToast, toastMethod, lessAwesome, upgraded, corrupted = ...
        Addon.DetectGreatVault(itemLink)
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        if ... == Addon.Constants.GREAT_VAULT_INTERACTION_TYPE then
            Addon.CollectGreatVaultRewards()
        end
    end
end

SLASH_MPLHCOMMAND1 = "/mplh"

SlashCmdList["MPLHCOMMAND"] = function()
    print("currentSeason: ", Addon.currentSeason)
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('ADDON_LOADED')
eventHandlerFrame:RegisterEvent('FIRST_FRAME_RENDERED')
eventHandlerFrame:RegisterEvent('CHAT_MSG_CURRENCY')
eventHandlerFrame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
eventHandlerFrame:RegisterEvent('CHALLENGE_MODE_COMPLETED')
eventHandlerFrame:RegisterEvent('TRADE_TARGET_ITEM_CHANGED')
eventHandlerFrame:RegisterEvent('SHOW_LOOT_TOAST')
eventHandlerFrame:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW')
eventHandlerFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
eventHandlerFrame:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')