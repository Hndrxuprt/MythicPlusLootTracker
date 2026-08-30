local AddonName, Addon = ...

local function GetMythicRuns()
    local mythicRuns = {}
    C_MythicPlus.RequestMapInfo()
    local runHistory = C_MythicPlus.GetRunHistory(false, true);
    if #runHistory > 0 then
        local comparison = function(entry1, entry2)
            if ( entry1.level == entry2.level ) then
                return entry1.mapChallengeModeID < entry2.mapChallengeModeID;
            else
                return entry1.level > entry2.level;
            end
        end
        table.sort(runHistory, comparison);
        for i = 1, Addon.Constants.MAX_KEY_RUNS do
            if runHistory[i] then
                tinsert(mythicRuns, runHistory[i])
            end
        end
    end
    local oneMPlus, fourMPlus, eightMPlus = 0, 0, 0
    if next(mythicRuns) then
        for i = 1, #mythicRuns do
            local runInfo = mythicRuns[i]
            if i == 1 then
                oneMPlus = runInfo.level
            elseif i == 4 then
                fourMPlus = runInfo.level
            elseif i == 8 then
                eightMPlus = runInfo.level
            end
        end
    end
    return mythicRuns, oneMPlus, fourMPlus, eightMPlus
end

local function GetRaidRuns()
    local raidRuns = {}
    local encounters = C_WeeklyRewards.GetActivityEncounterInfo(3, 1)
    if encounters then
        table.sort(encounters, function(left, right)
            if left.instanceID ~= right.instanceID then
                return left.instanceID < right.instanceID;
            end
            local leftCompleted = left.bestDifficulty > 0;
            local rightCompleted = right.bestDifficulty > 0;
            if leftCompleted ~= rightCompleted then
                return leftCompleted;
            end
            return left.uiOrder < right.uiOrder;
        end)
        local lastInstanceID = nil;
        local instanceName = nil;
        for index, encounter in ipairs(encounters) do
            local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
            if instanceID ~= lastInstanceID then
                instanceName = EJ_GetInstanceInfo(instanceID);
                lastInstanceID = instanceID;
            end
            if name then
                if encounter.bestDifficulty > 0 then
                    local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
                    -- Сохраняем имя рейдового экземпляра в первой записи блока,
                    -- чтобы тултип AltManager не пересоздавал его через
                    -- C_AdventureJournal.GetSuggestions()[3] (хрупкий хардкод).
                    local entry = { name, completedDifficultyName }
                    if instanceName and #raidRuns == 0 then
                        entry.instanceName = instanceName
                    end
                    tinsert(raidRuns, entry)
                end
            end
        end
    end
    return raidRuns
end

function Addon.StoreCharacterData()
    if UnitLevel("player") < Addon.Constants.MIN_CHARACTER_LEVEL then 
        return
    else
        local name = Addon.GetPlayerName()
        local _, class = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[class].colorStr
        local playerID = "|c"..classColor..name

        local updateDate = date("%d.%m.%y")

        local mythicRuns, oneMPlus, fourMPlus, eightMPlus = GetMythicRuns()
        local raidRuns = GetRaidRuns()

        local currentKeystone = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or "N/A"
        local currentKeystoneLvl = C_MythicPlus.GetOwnedKeystoneLevel() or "N/A"

        if MPLH_KACDATA[playerID] == nil then
            MPLH_KACDATA[playerID] = {}
            tinsert(MPLH_ORDER, playerID)
        end

        -- Захват экипировки. На входе в игру PLAYER_EQUIPMENT_CHANGED стреляет
        -- очередью, пока инвентарь ещё синхронизируется, и GetInventoryItemLink
        -- возвращает nil для всех слотов. Переприсваивание gear={} в этот момент
        -- стирало ранее сохранённые ссылки — поэтому у части альтов gear = {}.
        -- Сначала собираем во временную таблицу и перезаписываем gear только если
        -- удалось прочитать хотя бы одну ссылку; иначе оставляем старые данные.
        local newGear = {}
        local gearIdx = 0
        local anyLink = false
        for i=1, Addon.Constants.GEAR_SLOT_COUNT do
            if i ~= Addon.Constants.GEAR_SLOT_SKIP then
                gearIdx = gearIdx + 1
                -- Прямое индексирование сохраняет nil-дырки на своих местах;
                -- tinsert с nil сжимал массив и сдвигал хвостовые слоты.
                local itemLink = GetInventoryItemLink("player", i)
                newGear[gearIdx] = itemLink
                if itemLink then
                    anyLink = true
                end
            end
        end
        if anyLink then
            MPLH_KACDATA[playerID]["gear"] = newGear
        elseif MPLH_KACDATA[playerID]["gear"] == nil then
            MPLH_KACDATA[playerID]["gear"] = {}
        end

        MPLH_KACDATA[playerID]["rio"] = C_ChallengeMode.GetOverallDungeonScore()
        MPLH_KACDATA[playerID]["keys"] = {}
        local maps = C_ChallengeMode.GetMapTable()
        for i=1, #maps do
            local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(maps[i])
            local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(maps[i])
            local level = 0
            local dungeonScore = 0
            if(inTimeInfo and overtimeInfo) then
                local inTimeScoreIsBetter = inTimeInfo.dungeonScore > overtimeInfo.dungeonScore
                level = inTimeScoreIsBetter and inTimeInfo.level or overtimeInfo.level
                dungeonScore = inTimeScoreIsBetter and inTimeInfo.dungeonScore or overtimeInfo.dungeonScore
            elseif(inTimeInfo or overtimeInfo) then
                level = inTimeInfo and inTimeInfo.level or overtimeInfo.level
                dungeonScore = inTimeInfo and inTimeInfo.dungeonScore or overtimeInfo.dungeonScore
            end
            tinsert(MPLH_KACDATA[playerID]["keys"], {id=maps[i], level=level, dungeonScore = dungeonScore, inTimeInfo = inTimeInfo, overtimeInfo = overtimeInfo, affixScores = affixScores, overAllScore = overAllScore})
        end

        MPLH_KACDATA[playerID]["updateDate"] = updateDate
        MPLH_KACDATA[playerID]["oneMPlus"] = oneMPlus
        MPLH_KACDATA[playerID]["fourMPlus"] = fourMPlus
        MPLH_KACDATA[playerID]["eightMPlus"] = eightMPlus
        -- Кейстоун: как и gear, не затираем сохранённое значение "N/A", если
        -- C_MythicPlus ещё не прогрузил ключ на раннем PLAYER_EQUIPMENT_CHANGED.
        if tonumber(currentKeystone) then
            MPLH_KACDATA[playerID]["currentKeystone"] = currentKeystone
            MPLH_KACDATA[playerID]["currentKeystoneLvl"] = currentKeystoneLvl
        elseif MPLH_KACDATA[playerID]["currentKeystone"] == nil then
            MPLH_KACDATA[playerID]["currentKeystone"] = currentKeystone
            MPLH_KACDATA[playerID]["currentKeystoneLvl"] = currentKeystoneLvl
        end
        local r, g, b = GetItemLevelColor()
        MPLH_KACDATA[playerID]["ilvl"] = format("|cff%02x%02x%02x", r*255, g*255, b*255)..floor(select(2, GetAverageItemLevel()))
        if MPLH_KACDATA[playerID]["mythicRuns"] and next(MPLH_KACDATA[playerID]["mythicRuns"]) then
            wipe(MPLH_KACDATA[playerID]["mythicRuns"])
        end
        MPLH_KACDATA[playerID]["mythicRuns"] = mythicRuns

        if MPLH_KACDATA[playerID]["raidRuns"] and next(MPLH_KACDATA[playerID]["raidRuns"]) then
            wipe(MPLH_KACDATA[playerID]["raidRuns"])
        end
        MPLH_KACDATA[playerID]["raidRuns"] = raidRuns
        
    end

end