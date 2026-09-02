local AddonName, Addon = ...

local greatVaultTable = {}
local tradedItems = {}

-- DifficultyIDs для рейдовых лут-листов журнала (Normal/Heroic/Mythic).
local RAID_DIFFICULTIES = { 14, 15, 16 }

function Addon.GetEncounter(instance)
    local dungeonName = nil
    local mapID = nil
    local isRaid = select(11, EJ_GetInstanceInfo(instance))
    if instance == nil then
        local info = C_ChallengeMode.GetChallengeCompletionInfo()
        mapID = info.mapChallengeModeID
        if mapID and mapID ~= 0 then
            dungeonName = select(1, C_ChallengeMode.GetMapUIInfo(mapID))
            if dungeonName then
                return dungeonName, mapID
            end
        else
            instance = select(8, GetInstanceInfo())
            dungeonName = select(1,GetInstanceInfo() )
            return dungeonName, instance
        end
    elseif instance == Addon.Constants.GREAT_VAULT_ID then
        dungeonName = Addon.localization.gvault
        return dungeonName, instance 
    elseif instance == Addon.Constants.OVERALL_ID then
        dungeonName = Addon.localization.overall
        return dungeonName, instance 
    elseif isRaid and isRaid ~= 0 then
        dungeonName = select (1, EJ_GetInstanceInfo(instance))
        return dungeonName, instance
    else
        dungeonName = select(1, C_ChallengeMode.GetMapUIInfo(instance))
        if dungeonName then
            return dungeonName, instance
        else
            dungeonName = select (1, EJ_GetInstanceInfo(instance))
            return dungeonName, instance
        end
    end
end

-- Возвращает путь фоновой текстуры подземелья из EncounterJournal.
-- Для M+ принимает mapID (резолвит в journalInstanceID), для рейдов — EJ instanceID.
-- Возвращает nil для сентинелов (Great Vault / Overall) и если фон недоступен.
function Addon.GetDungeonBackground(instance)
    if instance == nil
        or instance == Addon.Constants.GREAT_VAULT_ID
        or instance == Addon.Constants.OVERALL_ID then
        return nil
    end
    local isRaid = select(11, EJ_GetInstanceInfo(instance))
    if isRaid and isRaid ~= 0 then
        return select(3, EJ_GetInstanceInfo(instance))
    end
    -- M+: instance — это mapID; резолвим journalInstanceID из данных аддона.
    local dungeon = Addon.Dungeons and Addon.Dungeons[instance]
    if dungeon and dungeon.journalInstanceID then
        return select(3, EJ_GetInstanceInfo(dungeon.journalInstanceID))
    end
    -- Запасной путь: рантайм-таблица, заполняемая из EJ_GetInstanceByIndex.
    local ejID = Addon.MapIDToEJInstanceID and Addon.MapIDToEJInstanceID[instance]
    if ejID then
        return select(3, EJ_GetInstanceInfo(ejID))
    end
    return nil
end

local function EncounterLooted(encounter, itemLink, quantity, playerID, season)
    if MPLH_ENC[season] == nil then
        MPLH_ENC[season] = {}
    end   
    if MPLH_ENC[season][playerID] == nil then
        MPLH_ENC[season][playerID] = {}
    end   
    if MPLH_ENC[season][playerID][encounter] == nil then
        MPLH_ENC[season][playerID][encounter] = {}
    end
    if MPLH_ENC[season][playerID][encounter][itemLink] == nil then
        MPLH_ENC[season][playerID][encounter][itemLink] = quantity
    else
        MPLH_ENC[season][playerID][encounter][itemLink] = MPLH_ENC[season][playerID][encounter][itemLink] + quantity
    end
end

function Addon.CalcDungeonStat(instanceID)
    if not instanceID then
        instanceID = select(2,Addon.GetEncounter())
    end
    local playerID = Addon.GetPlayerID()
    if MPLH_ENC_ENDED[Addon.currentSeason][playerID] == nil then
        MPLH_ENC_ENDED[Addon.currentSeason][playerID] = {}
    end
    if instanceID == Addon.Constants.GREAT_VAULT_ID then
        if MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] == nil then
            MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] = 1
        else
            MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] = MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] + 1
        end
        if MPLH_TRACKITEM[playerID] then
            for dung, items in pairs(MPLH_TRACKITEM[playerID]) do
                for key, value in pairs(items) do
                    MPLH_TRACKITEM[playerID][dung][key]["attempts"] = MPLH_TRACKITEM[playerID][dung][key]["attempts"]+1
                end
            end
        end
    elseif instanceID ~= nil and instanceID ~= Addon.Constants.GREAT_VAULT_ID then
        if MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] == nil then
            MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] = 1
        else
            MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] = MPLH_ENC_ENDED[Addon.currentSeason][playerID][instanceID] + 1
        end

        if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][instanceID] then
            for k, v in pairs(MPLH_TRACKITEM[playerID][instanceID]) do
                MPLH_TRACKITEM[playerID][instanceID][k]["attempts"] = MPLH_TRACKITEM[playerID][instanceID][k]["attempts"]+1
            end
        end
    end
end

function Addon.CalcFortune(playerID, instanceID, seasonID)
    local fortune, pFortune, nFortune = 0,0,0
    local MPLH_TABLE = MPLH_ENC
    local MPLH_ENDED_TABLE = MPLH_ENC_ENDED
    if MPLH_TABLE[seasonID] and MPLH_TABLE[seasonID][playerID] and MPLH_TABLE[seasonID][playerID][instanceID] then
        if Addon.GetTableLength(MPLH_TABLE[seasonID][playerID][instanceID]) > 0 then
            for k, v in pairs(MPLH_ENC[Addon.currentSeason][playerID][instanceID]) do
                local itemType = select(6,GetItemInfoInstant(k))
                local isTraded = select(1,strsplit("~",k))
                if isTraded ~= "traded" and Addon.IsEquippableItemType(itemType) then
                    pFortune = pFortune + 1
                end
            end
            if MPLH_ENDED_TABLE[seasonID][playerID] and MPLH_ENDED_TABLE[seasonID][playerID][instanceID] then
                nFortune = MPLH_ENDED_TABLE[seasonID][playerID][instanceID]
            end
            if nFortune > 0 then
                fortune = pFortune/nFortune
            end     
        end
    else
        local fortune = "N/A"
    end
    return fortune, pFortune
end

function Addon.CalcChance(playerID, instanceID, item, reset, encounterID)
    local lootChance = 0
    local spec = GetSpecialization()
    local specID = GetSpecializationInfo(spec)
    local _,_,classID = UnitClass("player")
    local numLoot = 0
    local wearableItems = 0
    EJ_SetLootFilter(classID, specID)
    local function GetWearableForEnc(Enc)
        if Enc then
            local name, _, _, _, _, journalInstanceID, _, _ = EJ_GetEncounterInfo(Enc)
            if journalInstanceID then
                EJ_SelectInstance(journalInstanceID)
                if EJ_InstanceIsRaid() then
                    for _, difficultyID in ipairs(RAID_DIFFICULTIES) do
                        if EJ_IsValidInstanceDifficulty(difficultyID) then
                            EJ_SetDifficulty(difficultyID)
                            break
                        end
                    end
                elseif EJ_IsValidInstanceDifficulty(Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS) then
                    EJ_SetDifficulty(Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS)
                end
                numLoot = EJ_GetNumLoot()
                for i=1, numLoot do
                    local info = C_EncounterJournal.GetLootInfoByIndex(i)
                    if info.slot ~= "" and not info.displayAsPerPlayerLoot and not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(info.itemID) then
                        wearableItems = wearableItems + 1
                    end
                end
            end
        end
    end
    if not encounterID then
        if Addon.currentSeasonEncounters[instanceID] then
            for k, v in pairs(Addon.currentSeasonEncounters[instanceID]) do
                encounterID = v
                break
            end
        else
            local _, _, journalInstanceID = EJ_GetInstanceInfo(instanceID)
            if journalInstanceID then
                local _, _, firstEncounterID = EJ_GetEncounterInfoByIndex(1, journalInstanceID)
                if firstEncounterID then
                    encounterID = firstEncounterID
                end
            end
        end
    end

    GetWearableForEnc(encounterID)

    if wearableItems > 0 then
        lootChance = tonumber(string.format("%.2f", ((1/wearableItems) * Addon.Constants.LOOT_DROP_RATE)*100))
    end
    local chances = MPLH_TRACKITEM[playerID][instanceID][item]["chances"]
    if not chances or chances == 0 then
        MPLH_TRACKITEM[playerID][instanceID][item]["chances"] = lootChance
    end
end

function Addon.LootReceivedEvent(itemID, itemLink, quantity, playerID, lootEncounterId)
    if LinkUtil.IsLinkType(itemLink, "battlepet") then return end
    local dungeonName, instanceID = Addon.GetEncounter()
    local _,_,itemQuality,_,_,_,itemSubType,_,itemEquipLoc,_,_,classID,subclassID = C_Item.GetItemInfo(itemLink)
    if itemLink and ((itemQuality <= 6) and (itemQuality >= 2)) and not (itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE") then
        local newLink, itemID = Addon.RecreateItemLink(itemLink)
        local isInTraded, pos = Addon.IsValueInTable(tradedItems, itemLink)
        if isInTraded then
            table.remove(tradedItems, pos)
            newLink = "traded~"..newLink
        end
        if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][instanceID] and MPLH_TRACKITEM[playerID][instanceID][itemID] then
            if MPLH_TRACKITEM[playerID][instanceID][itemID]["done"] and MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["done"] == 0 then
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["done"] = 1
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["date"] = date("%d.%m.%y")
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["attempts"] = MPLH_TRACKITEM[playerID][instanceID][itemID]["attempts"]
                -- attempts ещё не включает текущий забег (он засчитывается на CHALLENGE_MODE_COMPLETED),
                -- поэтому шанс на момент получения — база, умноженная на попытки + текущий забег.
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["chance"] = tonumber(MPLH_TRACKITEM[playerID][instanceID][itemID]["chances"] or 0) * (MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["attempts"] + 1)

                MPLH_TRACKITEM[playerID][instanceID][itemID]["attempts"] = 0
                if isInTraded then
                    MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["traded"] = 1
                end
            end
            Addon.CalcChance(playerID, instanceID, itemID, false, lootEncounterId)
        end
        C_MythicPlus.RequestMapInfo()
        local currentSeason = C_MythicPlus.GetCurrentSeason()
        EncounterLooted(instanceID, newLink, quantity, playerID, currentSeason)
    end
end

function Addon.DetectGreatVault(itemLink)
    local itemType = select(6,GetItemInfoInstant(itemLink))
    local itemID = select(1, GetItemInfoInstant(itemLink))
    local mapID = C_Map.GetBestMapForUnit("player")
    if Addon.IsEquippableItemType(itemType) and mapID == Addon.Constants.GREAT_VAULT_MAP_ID and Addon.IsValueInTable(greatVaultTable, itemID) then
        local fullname = Addon.GetPlayerID()
        local greatVault = Addon.Constants.GREAT_VAULT_ID
        local dungeonName = Addon.GetEncounter(greatVault)
        Addon.CalcDungeonStat(greatVault)
        C_MythicPlus.RequestMapInfo()
        local currentSeason = C_MythicPlus.GetCurrentSeason()
        EncounterLooted(greatVault, itemLink, 1, fullname, currentSeason)
        wipe(greatVaultTable)
    end
end

function Addon.DetectTrade(tradeSlotIndex)
    local slotItemLink = GetTradeTargetItemLink(tradeSlotIndex)
    if slotItemLink then
        local itemType = select(6,GetItemInfoInstant(slotItemLink))
        if Addon.IsEquippableItemType(itemType) then
            tinsert(tradedItems, slotItemLink)
            return slotItemLink
        end
    end
end

function Addon.CollectGreatVaultRewards()
    if C_WeeklyRewards.HasAvailableRewards() and C_WeeklyRewards.CanClaimRewards() then
        local activities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus)
        table.sort(activities, function(left, right) return left.index < right.index; end)
        for i, activityInfo in ipairs(activities) do
            for key, value in pairs (activityInfo.rewards) do
                for k, v in pairs(value) do
                    if k == "id" then
                        tinsert(greatVaultTable, v)
                    end
                end
            end
        end
        tinsert(greatVaultTable, Addon.Constants.GREAT_VAULT_ITEM_ID)
    end
end