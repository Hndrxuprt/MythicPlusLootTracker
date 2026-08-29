local AddonName, Addon = ...
local GuideDB
local gearTable = {}

local SPEC_KEYS = {
    DEATHKNIGHT  = { "blood", "frost", "unholy" },
    DEMONHUNTER  = { "havoc", "vengeance", "devourer" },
    DRUID        = { "balance", "feral", "guardian", "restoration" },
    EVOKER       = { "devastation", "preservation", "augmentation" },
    HUNTER       = { "beast-mastery", "marksmanship", "survival" },
    MAGE         = { "arcane", "fire", "frost" },
    MONK         = { "brewmaster", "mistweaver", "windwalker" },
    PALADIN      = { "holy", "protection", "retribution" },
    PRIEST       = { "discipline", "holy", "shadow" },
    ROGUE        = { "assassination", "outlaw", "subtlety" },
    SHAMAN       = { "elemental", "enhancement", "restoration" },
    WARLOCK      = { "affliction", "demonology", "destruction" },
    WARRIOR      = { "arms", "fury", "protection" },
}
local function GetClassAndSpec()
    local class = select(2,UnitClass("player"))
    local spec = GetSpecialization()
    local specName = SPEC_KEYS[class][spec]
    return class, specName
end

local function SetItemSource(sourceType)
    sourceType = sourceType or "Mythic+"
    if not next(gearTable) then return end

    local spec = GetSpecialization()
    local specID = GetSpecializationInfo(spec)
    local _,_,classID = UnitClass("player")
    local isRaid
    EJ_SetLootFilter(classID, specID)

    local tbl
    if sourceType == "Raid" then
        tbl = Addon.RaidEJInstanceID
    elseif sourceType == "Mythic+" then
        tbl = Addon.MapIDToEJInstanceID
    elseif sourceType == "Overall" then
        tbl = Addon.CopyTable(Addon.MapIDToEJInstanceID)
        MergeTable(tbl, Addon.RaidEJInstanceID)
    end
    if not tbl or not next(tbl) then
        return
    end
    for mapID, instanceID in pairs(tbl) do
        EJ_SelectInstance(instanceID)
        isRaid = EJ_InstanceIsRaid()
        local dungeonName = C_ChallengeMode.GetMapUIInfo(isRaid and instanceID or mapID)
        if EncounterJournal then
            EJ_ContentTab_SelectAppropriateInstanceTab(instanceID)
            EncounterJournal_DisplayInstance(instanceID)
        end

        if ( EJ_IsValidInstanceDifficulty(Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS) ) then
            EJ_SetDifficulty(Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS)
        end
        local numLoot = EJ_GetNumLoot()
        for i=1, numLoot do
            local info = C_EncounterJournal.GetLootInfoByIndex(i)
            if info and info.slot ~= "" and not info.displayAsPerPlayerLoot then
                for _, data in ipairs(gearTable) do
                    if not data.source then
                        if info.itemID == data.itemID then
                            data.source = isRaid and instanceID or mapID
                        end
                    end
                end
            end
        end
    end
    if EncounterJournal then
        EncounterJournal_ListInstances()
    end
end

local function TrackItem()
    if next(gearTable) then
        local playerID = Addon.GetPlayerID()
        for _, data in ipairs(gearTable) do
            if data.source then
                Addon.MakeTrackedItemRecord(playerID, data.source, data.itemID)
                Addon.CalcChance(playerID, data.source, data.itemID, false)
            end
        end
        if MPLTLootFrame then
            MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
            Addon.UpdateSubFrames()
        end
    end
end

function MPLT_ImportClassCodexGear(sourceType)
    wipe(gearTable)
    local class, spec = GetClassAndSpec()

    local db = GuideDB and GuideDB.data

    if db and db[class] and db[class][spec] and db[class][spec].gear and db[class][spec].gear.all then
        local gearAll = db[class][spec].gear.all
        local tbl
        if sourceType == "Raid" then
            tbl = gearAll.raid
        elseif sourceType == "Mythic+" then
            tbl = gearAll.mplus
        elseif sourceType == "Overall" then
            tbl = gearAll.all
        end
        if tbl then
            for _, data in ipairs(tbl) do
                table.insert(gearTable, {slot = data.slot, itemID = data.itemId})
            end
        end
    end
    SetItemSource(sourceType)
    TrackItem()
end

local function ProcessEvent(self, event, ...)
	if event == 'PLAYER_LOGIN' then
        local lastTier = EJ_GetNumTiers()
        if EJ_GetCurrentTier() ~= lastTier then
            EJ_SelectTier(lastTier)
        end
        if not next(Addon.MapIDToEJInstanceID) then
            for i=1, 8 do
                local dungeonInstanceID = EJ_GetInstanceByIndex(i, false)
                if dungeonInstanceID then
                    local mapID = Addon.EJInstanceIDToMapID[dungeonInstanceID]
                    if mapID then
                        Addon.MapIDToEJInstanceID[mapID] = dungeonInstanceID
                    end
                end
            end
        end
        if not next(Addon.RaidEJInstanceID) then
            for i=1, 4 do
                local raidInstanceID = EJ_GetInstanceByIndex(i, true)
                Addon.RaidEJInstanceID[i] = raidInstanceID
            end
        end

        if C_AddOns.IsAddOnLoaded("ClassCodex") then
            if ClassCodex_LastScrape and ClassCodex_LastScrape > Guide_LastScrape then
                if ClassCodexSource then
                    GuideDB = ClassCodexSource["icyveins"]
                end
            else
                GuideDB = GuideSource["icyveins"]
            end
        end
    end
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('PLAYER_LOGIN')