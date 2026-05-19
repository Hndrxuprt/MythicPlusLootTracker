local AddonName, Addon = ...

local UIConfig = nil
local showOnlyEquip = false

local greatVaultTable = {}

local seasonID = Addon.currentSeason

MPLTCoreMixin = {}

-- Event handler for ADDON_LOADED event
local function AddonLoadedEvent(self, event, Name, ...)
	if Name == AddonName then

		--eventHandlerFrame:UnregisterEvent('ADDON_LOADED')
        if MPLH_ENC == nil then
            MPLH_ENC = {}
        end
        if MPLH_ENC[Addon.currentSeason] == nil then
            MPLH_ENC[Addon.currentSeason] = {}
        end
        if MPLH_ENC_ENDED == nil then
            MPLH_ENC_ENDED = {}
        end
        if MPLH_ENC_ENDED[Addon.currentSeason] == nil then
            MPLH_ENC_ENDED[Addon.currentSeason] = {}
        end
        if MPLH_TRACKITEM == nil then
            MPLH_TRACKITEM = {}
        end
        if MPLH_TRACKITEM_ORDER == nil then
            MPLH_TRACKITEM_ORDER = {}
        end

        if MPLH_TRACKEDITEM_ITEMORDER == nil then
            MPLH_TRACKEDITEM_ITEMORDER = {}
        end

        if MPLH_KACDATA == nil then
            MPLH_KACDATA = {}
        end
        if MPLH_ORDER == nil then
            MPLH_ORDER = {}
        end
		C_ChatInfo.RegisterAddonMessagePrefix('MPLT')

        Addon:Init()
	
	end
end

local function isValueinTable(table, searchValue)
    for key,value in pairs(table) do 
        if(value == searchValue) then 
            return true, key
        end
    end
    return false
end

local function isKeyInTable(table, searchValue)
    for key,value in pairs(table) do 
        if(key == searchValue) then 
            return true, key
        end
    end
    return false
end


local function SplitItemLink(itemLink)
    local s1, s2 = nil, nil
    s1, s2 = strsplit("~", itemLink, 2)
    return s1, s2
end

function GetDungeonTableLenght(table)
    local tableLenght = 0
    if table ~= nil then
        for k,v in pairs(table) do
            tableLenght = tableLenght + 1
        end
        return tableLenght
    end
end

function MPLT_UpdateSubFrames()
    local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
    local SubFrames = {"MPLTEncountersFrame", "MPLTTrackingFrame", "MPLTAltManagerFrame"}
    for index, frameName in pairs (SubFrames) do
        if index == tabID then
            _G[frameName]:Show()
        else
            if _G[frameName]:IsVisible() then
                _G[frameName]:Hide()
            end
        end
    end
    if tabID == 3 then
        UIConfig.dropDownChars:Hide()
        UIConfig.dropDownSeason:Hide()
    else
        UIConfig.dropDownChars:Show()
        UIConfig.dropDownSeason:Show()
    end
end

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())
    MPLT_UpdateSubFrames()
end

local function SetTabs(frame, numTabs, ...)
    frame.numTabs = numTabs
    local contents = {}
    local frameName = frame:GetName()
    for i = 1, numTabs do
        local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "PanelTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(select(i, ...))
        tab:SetScript("OnClick", Tab_OnClick)
        tab.content = CreateFrame ("Frame", nil, UIConfig.ScrollFrame)
        tab.content:SetSize(610,350)
        tab.content:Hide()

        --[[ tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND")
        tab.content.bg:SetAllPoints(true)
        tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6) ]]
        tab:Hide()
        tab:Show() -- Attempt to fix tab size depends on text lenght

        tinsert(contents, tab.content)

        if i == 1 then
            tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, 4)
        else
            tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i-1)], "TOPRIGHT", 2, 0)
        end
    end
    Tab_OnClick(_G[frameName.."Tab1"])

    return unpack(contents)
end


function RecreateItemLink(itemLink)
    --local itemLink = "|cnIQ4:|Hitem:234491:7462:::::::80:581::33:6:10390:6652:10384:11984:1507:10255:1:28:2462:::::|h[Sonic Ka-BOOM!-erang]|h|r"
    --local itemLink = "|cnIQ4:|Hitem:230905::::::::80:581::16:1:3524:1:28:1279:::::|h[Fractured Spark of Fortunes]|h|r"
    --RecreateItemLink("|cnIQ4:|Hitem:234491:7462:::::::80:581::33:6:10390:6652:10384:11984:1507:10255:1:28:2462:::::|h[Sonic Ka-BOOM!-erang]|h|r")
    local parts = { strsplit(":", itemLink) }
    local itemContext = parts[14]
    if itemContext ~= "16" then 
        itemContext = 16 
    end
    local numBonuses = parts[15]
    local numModifiers = ""
    local modifiers = ""
    local bonusIDs = ""
    if tonumber(numBonuses) then
        for i=1, tonumber(numBonuses) do
            bonusIDs = bonusIDs.. ":" ..(parts[15 + i] or "")
        end
    else
        numBonuses = "1"
        bonusIDs = ":3524"
    end
    local pos = 16 + (tonumber(numBonuses) or 0)
    numModifiers = parts[pos]
    if tonumber(numModifiers) then
        for i=1, tonumber(numModifiers)*2, 2 do
            local key = parts[pos+i] or ""
            local value = parts[pos+i+1] or ""
            if i == 1 then
                value = "1279"
            end
            modifiers = modifiers..":"..key..":"..value
        end
    else
        numModifiers = "1"
        modifiers = ":28:1279"
    end
    local id = parts[3]
    local linkLevel = parts[11]
    local specializationID = parts[12]
    local text = strmatch(itemLink, "[[](.*)[]]")
    local newLink = "|cnIQ4:|Hitem:"..id.."::::::::"..linkLevel..":"..specializationID..
    "::"..itemContext..":"..numBonuses..bonusIDs..":"..numModifiers..modifiers.."::::|h["..text.."]|h|r"
    return newLink, tonumber(id)
end

function GetEncounter(instance)
    local dungeonName = nil
    local mapID = nil
    local isRaid = select(11, EJ_GetInstanceInfo(instance))
    if instance == nil then
        local info = C_ChallengeMode.GetChallengeCompletionInfo()
        mapID = info.mapChallengeModeID
        if mapID then
            dungeonName = select(1, C_ChallengeMode.GetMapUIInfo(mapID))
            dungeonID = select(3, C_ChallengeMode.GetMapUIInfo(mapID))
            if dungeonName then
                return dungeonName, mapID
            end
        else
            print("no mapID")
        end
    elseif tonumber(instance) == 999999 then
        dungeonName = Addon.localization.gvault
        return dungeonName, instance 
    elseif tonumber(instance) == 888888 then
        dungeonName = "Overall"
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

local function GetItemSource(itemLink)
    local itemIDInitial = GetItemInfoInstant(itemLink)    
    local itemName = strmatch(itemLink, "[[](.*)[]]")
    local bossName = nil
    EJ_SetSearch(itemName)
    C_Timer.After(0.5, function()
        local isFinished = EJ_IsSearchFinished()
        local numResults = EJ_GetNumSearchResults()
        if numResults then
            for i=1, numResults do
                local EJCurrentTier = EJ_GetCurrentTier()
                if EJCurrentTier > 9 then
                    print (EJCurrentTier, "DF not yet implemented")
                    return
                end
                local id, stype, difficultyID, instanceID, encounterID, Link = EJ_GetSearchResult(i)
                local itemIDFromSearch = GetItemInfoInstant(Link)
                if encounterID then
                    if itemIDInitial == itemIDFromSearch then
                        for k, v in pairs(Addon.currentSeasonEncounters) do
                            if isValueinTable(v, encounterID) then
                                local itemSource = select(1,C_ChallengeMode.GetMapUIInfo(k))
                                return itemSource
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function GetItemIDFromName(itemName, callback)
    local cachedItemID = GetItemInfoInstant(itemName)
    if cachedItemID then
        callback(cachedItemID)
        return
    end
    EJ_SetSearch(itemName)
    C_Timer.After(0.5, function()
        local isFinished = EJ_IsSearchFinished()
        local numResults = EJ_GetNumSearchResults()
        if numResults then
            for i=1, numResults do
                local id, _, _, _, _, Link = EJ_GetSearchResult(i)
                local itemID = GetItemInfoInstant(Link)
                local foundName = Link:match("%|h%[(.-)%]%|h")
                if itemName == foundName then
                    callback(itemID)
                    return
                end
            end
        end
        callback(nil)
    end)
end
local function IsLinkBroken(itemLink)
    if itemLink:match("|Hitem:.*|Hitem") then
        return true
    end
    
    local itemID = itemLink:match("|Hitem:(%d+)")
    if not itemID then
        return true
    end
end

local function FixBrokenLinks(itemLink, callback) 
    local itemName = itemLink:match("%|h%[(.-)%]%|h")
    if not itemName then callback(nil) return end

    GetItemIDFromName(itemName, function(itemID)
        if not itemID then callback(nil) return end
        local fixedLink = itemLink:gsub("(|Hitem:)[^:]+(:)", "%1" .. itemID .. "%2", 1)
        callback(fixedLink)
    end)
end

function FixAboba(tbl, indent)
    if not tbl then
        local name, realm = UnitFullName("player")
        local playerID = name .. "-" .. realm
        tbl = MPLH_ENC[14][playerID]
    end
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    local pending = 0  -- Счетчик асинхронных операций
    
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            local original = k
            if not IsLinkBroken(original) then break end
            pending = pending + 1

            FixBrokenLinks(k, function(fixedLink) 
                if fixedLink then
                    print(spaces.."Обнаружена поврежденная ссылка:")
                    print(spaces.."Исходная: "..k)
                    print(spaces.."Исправленная: "..fixedLink)
                    
                    -- Заменяем ключ в таблице
                    tbl[fixedLink] = tbl[k]
                    tbl[k] = nil
                end
                
                pending = pending - 1
                if pending == 0 then 
                    print("Все ссылки обработаны!")
                end
            end)
        end
        if type(v) == "table" then
            pending = pending + 1
            FixAboba(v, indent + 1, function()
                pending = pending - 1
                if pending == 0 then 
                    print("Все ссылки обработаны!")
                end
            end)
        end
    end
    
    if pending == 0 then 
        print("Все ссылки обработаны!")
    end
end
--FixAboba()
--GetItemIDFromName("Fearless Challenger's Leggings")
--FixAboba(MPLH_ENC[14]["Äboba-Draenor"], 0, function() print("Все ссылки обработаны!") end)

local function isDungeonInCurrentSeason(journalID)
    local dungeonName = select(6, EJ_GetInstanceInfo(journalID))
    for k, v in pairs(C_ChallengeMode.GetMapTable()) do
        local seasonDungeonName = select(4, C_ChallengeMode.GetMapUIInfo(v))
        print(dungeonName, " ==== ", seasonDungeonName)
        if dungeonName == seasonDungeonName then
            print("GOTCHA")
        end
    end
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

local function CalcDungeonStat(instanceID)
    if not instanceID then
        instanceID = select(2,GetEncounter())
    end
    local name, realm = UnitFullName("player")
    local playerID = name .. "-" .. realm
    if MPLH_ENC_ENDED[seasonID][playerID] == nil then
        MPLH_ENC_ENDED[seasonID][playerID] = {}
    end
    if instanceID == 999999 then
        if MPLH_ENC_ENDED[seasonID][playerID][instanceID] == nil then
            MPLH_ENC_ENDED[seasonID][playerID][instanceID] = 1
        else
            MPLH_ENC_ENDED[seasonID][playerID][instanceID] = MPLH_ENC_ENDED[seasonID][playerID][instanceID] + 1
        end
        if _G["MPLH_TRACKITEM"][playerID] then
            for dung, items in pairs(_G["MPLH_TRACKITEM"][playerID]) do
                for key, value in pairs(items) do
                    MPLH_TRACKITEM[playerID][dung][key]["attempts"] = MPLH_TRACKITEM[playerID][dung][key]["attempts"]+1
                end
            end
        end
    elseif instanceID ~= nil and instanceID ~= 999999 then
        if MPLH_ENC_ENDED[seasonID][playerID][instanceID] == nil then
            MPLH_ENC_ENDED[seasonID][playerID][instanceID] = 1
        else
            MPLH_ENC_ENDED[seasonID][playerID][instanceID] = MPLH_ENC_ENDED[seasonID][playerID][instanceID] + 1
        end

        if _G["MPLH_TRACKITEM"][playerID] and _G["MPLH_TRACKITEM"][playerID][instanceID] then
            for k, v in pairs(_G["MPLH_TRACKITEM"][playerID][instanceID]) do
                MPLH_TRACKITEM[playerID][instanceID][k]["attempts"] = MPLH_TRACKITEM[playerID][instanceID][k]["attempts"]+1
            end
        end
    else
        print("CalcDungeon failed because of instanceID: ", instanceID)
    end
end

function CalcFortune(playerID, instanceID, seasonID)
    local fortune, pFortune, nFortune = 0,0,0
    local MPLH_TABLE = _G["MPLH_ENC"]
    local MPLH_ENDED_TABLE = _G["MPLH_ENC_ENDED"]
    if MPLH_TABLE[seasonID] and MPLH_TABLE[seasonID][playerID] and MPLH_TABLE[seasonID][playerID][instanceID] then
        if GetDungeonTableLenght(MPLH_TABLE[seasonID][playerID][instanceID]) > 0 then
            for k, v in pairs(MPLH_ENC[seasonID][playerID][instanceID]) do
                local itemType = select(6,GetItemInfoInstant(k))
                local isTraded = select(1,strsplit("~",k))
                if isTraded ~= "traded" and ((itemType == 2) or (itemType == 4)) then
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
        fotune = "N/A"
    end
    return fortune, pFortune
end

local function CalcChance(playerID, instanceID, item, reset, encounterID)
    local lootChance = 0
    local attempts = _G["MPLH_TRACKITEM"][playerID][instanceID][item]["attempts"]
    local spec = GetSpecialization()
    local specID = GetSpecializationInfo(spec)
    local _,_,classID = UnitClass("player")
    local numLoot = 0
    local wearableItems = 0
    EJ_SetLootFilter(classID, specID)
    if ( EJ_IsValidInstanceDifficulty(23) ) then
        EJ_SetDifficulty(23)
    end
    local function GetWearableForEnc(Enc)
        if Enc then
            local name, _, _, _, _, journalInstanceID, _, _ = EJ_GetEncounterInfo(Enc)
            EJ_SelectInstance(journalInstanceID) --Usage: EJ_SelectInstance(ID) for 1
            --EJ_SelectEncounter(Enc)
            numLoot = EJ_GetNumLoot()
            for i=1, numLoot do
                local info = C_EncounterJournal.GetLootInfoByIndex(i)
                if info.slot ~= "" and not info.displayAsPerPlayerLoot and not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(info.itemID) then
                    wearableItems = wearableItems + 1
                end
            end
        end
    end
    if not encounterID then
        --if instance not raid, check if boss from Addon.currentSeasonEncounters list
        
        for k, v in pairs(Addon.currentSeasonEncounters[instanceID]) do
            encounterID = v
            break 
            --GetWearableForEnc(v)
        end     
    end

    GetWearableForEnc(encounterID)

    if wearableItems > 0 then
        if reset then
            lootChance = string.format("%.2f", (((1/wearableItems) * 0.40)*100))
        else
            lootChance = string.format("%.2f", (((1/wearableItems) * 0.40)*(attempts+1)*100))
        end
    end
    if _G["MPLH_TRACKITEM"][playerID][instanceID][item]["chances"] == 0 then
        _G["MPLH_TRACKITEM"][playerID][instanceID][item]["chances"] = lootChance
    end
end

local tradedItems = {}

local function LootReceivedEvent(itemID, itemLink, quantity, playerID, lootEncounterId)
    if LinkUtil.IsLinkType(itemLink, "battlepet") then return end
    local dungeonName, instanceID = GetEncounter()
    local _,_,itemQuality,_,_,_,itemSubType,_,itemEquipLoc,_,_,classID,subclassID = C_Item.GetItemInfo(itemLink)
    if itemLink and ((itemQuality <= 6) and (itemQuality >= 2)) and not (itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE") then
        local newLink, itemID = RecreateItemLink(itemLink)
        local isInTraded, pos = isValueinTable(tradedItems, itemLink)
        if isInTraded then
            table.remove(tradedItems, pos)
            newLink = "traded~"..newLink
        end
        if _G["MPLH_TRACKITEM"][playerID] and _G["MPLH_TRACKITEM"][playerID][instanceID] and _G["MPLH_TRACKITEM"][playerID][instanceID][itemID] then
            if _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"] and _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"]["done"] == 0 then
                _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"]["done"] = 1
                _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"]["date"] = date("%d.%m.%y")
                _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"]["attempts"] = _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["attempts"]
                _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"]["chance"] = _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["chances"]

                --reset current attempts of this item
                _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["attempts"] = 0
                if isInTraded then
                    _G["MPLH_TRACKITEM"][playerID][instanceID][itemID]["done"]["traded"] = 1
                end
            end
            CalcChance(playerID, instanceID, itemID, reset)
        end
        C_MythicPlus.RequestMapInfo()
        local currentSeason = C_MythicPlus.GetCurrentSeason()
        EncounterLooted(instanceID, newLink, quantity, playerID, currentSeason)
    end
end

local function DetectGreatVault(itemLink)
    local itemType = select(6,GetItemInfoInstant(itemLink))
    local itemID = select(1, GetItemInfoInstant(itemLink))
    local mapID = C_Map.GetBestMapForUnit("player")
    if ((itemType == 2) or (itemType == 4)) and mapID == 2393 and isValueinTable(greatVaultTable, itemID) then
        print("DetectGreatVault", itemLink)
        local name, realm = UnitFullName("player")
        local fullname = name .. "-" .. realm
        local greatVault = 999999
        local dungeonName = GetEncounter(greatVault)
        CalcDungeonStat(greatVault)
        C_MythicPlus.RequestMapInfo()
        local currentSeason = C_MythicPlus.GetCurrentSeason()
        EncounterLooted(greatVault, itemLink, 1, fullname, currentSeason)
        wipe(greatVaultTable)
    end
end

local function DetectTrade(tradeSlotIndex)
    local slotItemLink = GetTradeTargetItemLink(tradeSlotIndex)
    if slotItemLink then
        local itemType = select(6,GetItemInfoInstant(slotItemLink))
        if (itemType == 2) or (itemType == 4) then
            tinsert(tradedItems, slotItemLink)
            return slotItemLink
        end
    end
end

local function ScrollFrame_OnMouseWheel(self, delta)
    local newValue = self:GetVerticalScroll() - (delta * 20);

    if (newValue < 0) then
        newValue = 0;
    elseif (newValue > self:GetVerticalScrollRange()) then
        newValue = self:GetVerticalScrollRange();
    end
    self:SetVerticalScroll(newValue);

end

local function sortTable(tbl)
    local sorted = {}
    for k,v in pairs(tbl) do
        table.insert(sorted,{k,v})
    end

    table.sort(sorted, function(a,b) return a[2]>b[2] end)

    return sorted
end

local function CopyTable(tbl)
    local tblType = type(tbl)
    local tblCopy
    if tblType == "table" then
        tblCopy = {}
        for k,v in pairs(tbl) do
            tblCopy[k]=v
        end
    else
        tblCopy = tbl
    end
    return tblCopy
end


-----------------------------------------------------------         
local framePool = CreateFramePool("Frame", UIParent, "BackdropTemplate")            
local fontPool = CreateFontStringPool(UIParent, "OVERLAY", nil, "NumberFontNormal")         
local itemIconPool = CreateTexturePool(UIParent)           
local ilvlPool = CreateFontStringPool(UIParent, "OVERLAY", nil, "NumberFont_OutlineThick_Mono_Small")
local buttonPool = CreateFramePool("Button", UIParent, "GossipTitleButtonTemplate")

local trackItemsButtonPool = CreateFramePool("Button", UIParent, "UIPanelButtonTemplate")

local function UpdateItemTable(playerID, dungeonName, content)
    framePool:ReleaseAll() 
    fontPool:ReleaseAll()
    itemIconPool:ReleaseAll()
    ilvlPool:ReleaseAll()
    
    local MPLH_ENC_TABLE = _G["MPLH_ENC"][seasonID]
    if MPLH_ENC_TABLE[playerID] ~= nil and MPLH_ENC_TABLE[playerID][dungeonName] ~= nil then
        local tbl = {}
        tbl = CopyTable(MPLH_ENC_TABLE[playerID][dungeonName])
        if showOnlyEquip then
            local onlyEquip = {}
            for key,value in pairs(MPLH_ENC_TABLE[playerID][dungeonName]) do
                local itemType = select(6,GetItemInfoInstant(key))
                if (itemType == 2) or (itemType == 4) then
                    onlyEquip[key]=value
                end
            end
            tbl = onlyEquip
        end

        local scrollLenght = GetDungeonTableLenght(tbl) 
        content:SetSize(308,scrollLenght*32);

        local sortedTable = sortTable(tbl)

        

        C_Timer.After(0.05, function()

            local lineOffset = 0
            
            local fontFrame = {}
            for _,v in pairs(sortedTable) do
                
                local fontFrame = framePool:Acquire()
                fontFrame:SetParent(content)
                fontFrame:SetClipsChildren(true)
                                
                local fontString = fontPool:Acquire()
                fontString:SetParent(fontFrame)
                
                local lootedItemsTexture = itemIconPool:Acquire()
                lootedItemsTexture:SetParent(fontFrame)

                fontFrame:Show()
                fontString:Show()
                lootedItemsTexture:Show()
                

                local itemLink, itemTexture = nil, nil
                local item = Item:CreateFromItemLink(v[1])
                item:ContinueOnItemLoad(function()
                    fontFrame:SetSize(330,30)
                    fontFrame:ClearAllPoints()
                    fontFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -30*lineOffset)
                    itemLink = v[1] 
                    itemTexture = item:GetItemIcon()
                    local traded = false
                    if itemLink ~= nil then
                        local s1, s2 = SplitItemLink(itemLink)
                        if s2 then
                            itemLink = s2
                            traded = true
                        else 
                            itemLink = s1
                        end
                        if traded then
                            fontString:SetText("x"..v[2].." "..itemLink.." *T")
                        else
                            fontString:SetText("x"..v[2].." "..itemLink)
                        end
                        
                        fontString:SetPoint("LEFT", fontFrame, "LEFT", 35, 0)
                        lootedItemsTexture:SetPoint("LEFT", fontString, "LEFT", -31, 0)
                        lootedItemsTexture:SetSize(30,30)
                        lootedItemsTexture:SetTexture(itemTexture)

                        if (select(1,GetDetailedItemLevelInfo(itemLink))) > 1 then
                            local itemLvlString = ilvlPool:Acquire()                
                            itemLvlString:SetParent(fontFrame)
                            itemLvlString:Show()
                            itemLvlString:SetText(select(1,GetDetailedItemLevelInfo(itemLink)))
                            itemLvlString:SetPoint("BOTTOMRIGHT", lootedItemsTexture, "BOTTOMRIGHT", 0, 0)
                        end
                        lineOffset = lineOffset+1
    
                        fontFrame:EnableMouse(true)
                        fontFrame:SetHyperlinksEnabled(true)
                        fontFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
    
                        fontFrame:SetScript("OnHyperlinkEnter", 
                            function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                                GameTooltip:SetPoint("RIGHT", fontFrame, "LEFT", -10, 0)
                                GameTooltip:SetHyperlink(v[1])
                                GameTooltip:Show()
                            end
                        )
                        fontFrame:SetScript("OnHyperlinkLeave", 
                            function(self)
                                GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                                GameTooltip:Hide()
                            end
                        )
                    else
                        print("loading itemLink from itemID failed", v[1])
                    end

                end)                
                
            end
        end)        
    else
        --print("ERROR LOADING TABLE")
    end
end
---------------------------------------------------------------------------------------
local EJTracker_HelpPlate = {
	FramePos = { x = 2, y = 40 },
	FrameSize = { width = 840, height = 520 },
	[1] = { ButtonPos = { x = 380,	y = -60 }, HighLightBox = { x = 390,  y = -80, width = 45, height = 385 },		ToolTipDir = "LEFT",   ToolTipText = Addon.localization.help1 },
	[2] = { ButtonPos = { x = 645,  y = -40 }, HighLightBox = { x = 670, y = -50, width = 110, height = 30 },	ToolTipDir = "LEFT",   ToolTipText = Addon.localization.help2 },
	[3] = { ButtonPos = Addon.localization.helpButton, HighLightBox = Addon.localization.helpBox,	ToolTipDir = "RIGHT",   ToolTipText = Addon.localization.help3 },
}
local function EJTrackerHelpPlate_ToggleTutorial()
	local helpPlate = EJTracker_HelpPlate;
	if ( helpPlate and not HelpPlate.IsShowingHelpInfo(helpPlate) ) then
		HelpPlate.Show( helpPlate, EncounterJournalEncounterFrameInfo, EJTracker_HelpButton );
	else
		HelpPlate.Hide(true);
	end
end
function MPLTCoreMixin:OnHide()
    local helpPlate = EJTracker_HelpPlate
    if ( helpPlate and HelpPlate.IsShowingHelpInfo(helpPlate) ) then
        HelpPlate.Hide(false)
    end   
end
local function InstaceIDToMapID(instanceID, encID)
    local mapID = instanceID
    if instanceID == 1194 then --current megadungeon JournalInstanceID
        for k, v in pairs(Addon.currentSeasonEncounters) do
            if isValueinTable(v, encID) then
                mapID = k
            end
        end
    elseif instanceID and Addon.EJInstaceIDToMapID[instanceID] then
        mapID = Addon.EJInstaceIDToMapID[instanceID]
    end
    return mapID
end

---------------------------------------------------------------------------------------
local EJTrackItemPool = CreateFramePool("Button", UIParent, "UIPanelCloseButtonNoScripts")

local function EJTrackItem()
    EJTrackItemPool:ReleaseAll()
    local name, realm = UnitFullName("player")
    local playerID = MPLTLootFrame and MPLTDropDown.defaultText or name .. "-" .. realm
    local isRaid = EncounterJournal_IsRaidTabSelected(EncounterJournal)

    --check if current season selected in dropdown menu and difficulty is mythic+
    if (EJ_GetCurrentTier() ~= EJ_GetNumTiers()) then
        return
    end
    --check if difficulty set to mythic+ for dungeons
    if (not isRaid) and (EJ_GetDifficulty() ~= 23) then
        return
    end

    local scrollBox = EncounterJournal.encounter.info.LootContainer.ScrollBox
    local scrollBar = EncounterJournalEncounterFrameInfo.LootContainer.ScrollBar
    local itemButtons = scrollBox:GetFrames()
    
    for _, button in ipairs(itemButtons) do
        if button.link then
            local elementData = button:GetElementData()
            local index = elementData.index
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(index)
            local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(button.link)
            local mplusEncounters = C_ChallengeMode.GetMapTable()
            local instanceID = IsRaid and EncounterJournal.instanceID or InstaceIDToMapID(EncounterJournal.instanceID, itemInfo.encounterID)
            if button:IsVisible() and LinkUtil.IsLinkType(button.link, "item") then
                local EJTrackItemButton = EJTrackItemPool:Acquire()
                EJTrackItemButton:SetParent(MPLT_ButtonHolder)
                EJTrackItemButton:SetPoint("RIGHT", button.IconBorder, "LEFT", 0, 0)
                EJTrackItemButton:SetSize(30,30)
                EJTrackItemButton:SetPushedAtlas("runecarving-icon-reagent-pressed")
                EJTrackItemButton:SetHighlightAtlas("GarrMission-AbilityHighlight")
                EJTrackItemButton:Show()
                EJTrackItemButton:SetScript("OnClick", function()
                    local scrollPos = scrollBar:GetScrollPercentage()
                    if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][instanceID] and MPLH_TRACKITEM[playerID][instanceID][itemID] then
                        if #_G["MPLH_TRACKEDITEM_ITEMORDER"][playerID][instanceID] > 1 then
                            tDeleteItem(MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID], itemID)
                            MPLH_TRACKITEM[playerID][instanceID][itemID] = nil
                        else
                            MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID] = nil
                            MPLH_TRACKITEM[playerID][instanceID] = nil
                            tDeleteItem(MPLH_TRACKITEM_ORDER[playerID], instanceID)
                        end
                    else
                        EJTrackItemButton:SetNormalAtlas("runecarving-icon-reagent-empty-error")
                        if instanceID then
                            if MPLH_TRACKITEM[playerID] == nil then
                                MPLH_TRACKITEM[playerID] = {}
                            end
                            if MPLH_TRACKITEM[playerID][instanceID] == nil then
                                MPLH_TRACKITEM[playerID][instanceID] = {}
                            end
                            itemID = tonumber(itemID)
                            if not isKeyInTable(MPLH_TRACKITEM[playerID][instanceID], itemID) then
                                MPLH_TRACKITEM[playerID][instanceID][itemID] = {}
                                MPLH_TRACKITEM[playerID][instanceID][itemID]["dateSince"] = date("%d.%m.%y")
                                MPLH_TRACKITEM[playerID][instanceID][itemID]["attempts"] = 0
                                MPLH_TRACKITEM[playerID][instanceID][itemID]["chances"] = 0
                                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"] = {
                                    ["done"] = 0,
                                    ["date"] = 0,
                                    ["attempts"] = 0,
                                    ["traded"] = 0,
                                    ["chance"] = 0,
                                }
                                if MPLH_TRACKEDITEM_ITEMORDER[playerID] == nil then
                                    MPLH_TRACKEDITEM_ITEMORDER[playerID] = {}
                                end
                                if MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID] == nil then
                                    MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID] = {}
                                end
                                if MPLH_TRACKITEM_ORDER[playerID] == nil then
                                    MPLH_TRACKITEM_ORDER[playerID] = {}
                                end
                                if not isValueinTable(_G["MPLH_TRACKEDITEM_ITEMORDER"][playerID][instanceID], itemID) then
                                    tinsert(MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID], itemID)
                                end
                                if not isValueinTable(_G["MPLH_TRACKITEM_ORDER"][playerID], instanceID) then
                                    tinsert(MPLH_TRACKITEM_ORDER[playerID], instanceID)
                                end
                                CalcChance(playerID, instanceID, itemID, false, itemInfo.encounterID)
                            end
                        end
                    end
                    if MPLTLootFrame then
                        MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
                        MPLT_UpdateSubFrames()
                    end
                    EncounterJournal_Refresh()
                    scrollBar:SetScrollPercentage(scrollPos)
                    --scrollBox:ScrollToElementDataIndex(scrollBoxIndex)
                end)
                if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][instanceID] and MPLH_TRACKITEM[playerID][instanceID][itemID] then
                    EJTrackItemButton:SetNormalAtlas("runecarving-icon-reagent-empty-error")
                else
                    --print("set GREEN icon")
                    EJTrackItemButton:SetNormalAtlas("runecarving-icon-reagent-empty")
                end
            end
        end
    end
end

local function OnDataRangeChanged()
    EJTrackItem()
end
-----------------------------------------------------------

local function CreateTrackedItemList(parent)
    local playerID = MPLTDropDown.defaultText
    MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
end

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------

function StoreCharacterData()
    if UnitLevel("player") < 90 then 
        return
    else
        local name, realm = UnitFullName("player")
        local _, class = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[class].colorStr
        local playerID = "|c"..classColor..name

        local updateDate = date("%d.%m.%y")

        --local fluxAmmount = C_CurrencyInfo.GetCurrencyInfo(2009).quantity --Cosmic Flux
        --local valorAmmount = C_CurrencyInfo.GetCurrencyInfo(1191).quantity --Valor

        --[[ local runHistory = C_MythicPlus.GetRunHistory(false, false)
        
        table.sort(runHistory, function(left, right) return left.level > right.level; end);
        local lowestLevel;
        local lowestCount = 0;
        for i = math.min(2, #runHistory), 1, -1 do
            local run = runHistory[i];
            if not lowestLevel then
                lowestLevel = run.level;
            end
            if lowestLevel == run.level then
                lowestCount = lowestCount + 1;
            else
                break;
            end
        end
        print (lowestLevel, lowestCount) ]]

--[[         local activities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus)
        table.sort(activities, function(left, right) return left.index < right.index; end)
        for i, activityInfo in ipairs(activities) do
            if i == 1 and activityInfo.level > 0 then
                oneMPlus = activityInfo.level
            end
            if i == 2 and activityInfo.level > 0 then
                fourMPlus = activityInfo.level
            end
            if i == 3 and activityInfo.level > 0 then
                eightMPlus = activityInfo.level
            end
        end ]]

        local mythicRuns = {}
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
            if next(mythicRuns) then
                wipe(mythicRuns)
            end
            for i = 1, 8 do
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
            for index, encounter in ipairs(encounters) do
                local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
                if instanceID ~= lastInstanceID then
                    local instanceName = EJ_GetInstanceInfo(instanceID);
                    --GameTooltip_AddBlankLineToTooltip(GameTooltip);	
                    --GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_ENCOUNTER_LIST, instanceName));
                    lastInstanceID = instanceID;
                end
                if name then
                    if encounter.bestDifficulty > 0 then
                        local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
                        tinsert(raidRuns, {name, completedDifficultyName})
                        --print(name, completedDifficultyName)
                        --GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, name, completedDifficultyName), GREEN_FONT_COLOR);
                    end
                end
            end
        end

        local container = nil
        local currentKeystone = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or "N/A"
        local currentKeystoneLvl = C_MythicPlus.GetOwnedKeystoneLevel() or "N/A"

        if MPLH_KACDATA[playerID] == nil then
            MPLH_KACDATA[playerID] = {}
            tinsert(MPLH_ORDER, playerID)
        end

        MPLH_KACDATA[playerID]["gear"] = {}
        for i=1, 17 do
            if i ~= 4 then
                local itemLink = GetInventoryItemLink("player", i)
                tinsert(MPLH_KACDATA[playerID]["gear"], itemLink)
            end
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
            --local name = C_ChallengeMode.GetMapUIInfo(maps[i])
            tinsert(MPLH_KACDATA[playerID]["keys"], {id=maps[i], level=level, dungeonScore = dungeonScore, inTimeInfo = inTimeInfo, overtimeInfo = overtimeInfo, affixScores = affixScores, overAllScore = overAllScore})
        end
        --[[ table.sort(MPLH_KACDATA[playerID]["keys"], function(a, b)
            if(b.dungeonScore ~= a.dungeonScore) then
                return a.dungeonScore > b.dungeonScore;
            else
                return strcmputf8i(a.id, b.id) > 0;
            end
	    end) ]]

        --Dinar quests progress
--[[         if select(4, GetBuildInfo()) == 90207 then
            local dinarQuest = "N/A"
            local dinarCondition = nil
            if C_QuestLog.IsOnQuest(66648) then
                dinarQuest = select(4,GetQuestObjectiveInfo(66648, 1, false))
                dinarCondition = select(5,GetQuestObjectiveInfo(66648, 1, false))
                dinarQuest = "stage1 "..dinarQuest.."/"..dinarCondition
            elseif C_QuestLog.IsOnQuest(66649) then
                dinarQuest = select(4,GetQuestObjectiveInfo(66649, 1, false))
                dinarCondition = select(5,GetQuestObjectiveInfo(66649, 1, false))
                dinarQuest = "stage2 "..dinarQuest.."/"..dinarCondition
            elseif C_QuestLog.IsOnQuest(66650) then
                dinarQuest = select(4,GetQuestObjectiveInfo(66649, 1, false))
                dinarCondition = select(5,GetQuestObjectiveInfo(66650, 1, false))
                dinarQuest = "stage3 "..dinarQuest.."/"..dinarCondition
            end
            MPLH_KACDATA[playerID]["dinarQuest"] = dinarQuest
        end ]]

        MPLH_KACDATA[playerID]["updateDate"] = updateDate
        MPLH_KACDATA[playerID]["oneMPlus"] = oneMPlus
        MPLH_KACDATA[playerID]["fourMPlus"] = fourMPlus
        MPLH_KACDATA[playerID]["eightMPlus"] = eightMPlus
        MPLH_KACDATA[playerID]["currentKeystone"] = currentKeystone
        MPLH_KACDATA[playerID]["currentKeystoneLvl"] = currentKeystoneLvl
        local r, g, b = GetItemLevelColor()
        MPLH_KACDATA[playerID]["ilvl"] = format("|cff%02x%02x%02x", r*255, g*255, b*255)..format("%.0f",select(2, GetAverageItemLevel()))
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

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------


local function ProcessData(self)
    local name, realm = UnitFullName("player")
    local playerID = name .. "-" .. realm
    if UIConfig == nil then
        local dungeonName = nil -- default value for dungeon ID Theatre of pain
            

        UIConfig = CreateFrame("Frame", "MPLTLootFrame", UIParent, "ButtonFrameTemplate")
        _G["UIConfig"] = UIConfig -- adds the frame via the name "UIConfig" to the global variables
        tinsert(UISpecialFrames, UIConfig:GetName()) -- instead frame:GetName() one could just use "UIConfig"
        UIConfig:SetSize(800,495)
        UIConfig:SetPoint("CENTER")
        UIConfig:SetMovable(true)
        UIConfig:EnableMouse(true)--   Receive mouse events (Buttons automatically have this set)
        UIConfig:RegisterForDrag("LeftButton")--   Register left button for dragging
        UIConfig:SetScript("OnDragStart",UIConfig.StartMoving)--  Set script for drag start
        UIConfig:SetScript("OnDragStop",UIConfig.StopMovingOrSizing)--    Set script for drag stop
        UIConfig:SetFrameStrata("HIGH")
        MPLTLootFrameInset.Bg:SetAtlas("Dragonflight-Landingpage-Background", true)
        MPLTLootFrameInset.Bg:SetHorizTile(false)
        MPLTLootFrameInset.Bg:SetVertTile(false)
        MPLTLootFrameInset.Bg:SetVertexColor(0.4, 0.4, 0.4)

        --------------------------------------
        --------------CONTENT 1---------------
        --------------------------------------

        UIConfig.desc = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        UIConfig.desc:ClearAllPoints()
        UIConfig.desc:SetPoint("BOTTOMLEFT", MPLTLootFrameBg, "BOTTOMLEFT", 8, 6)
        local version = C_AddOns.GetAddOnMetadata(AddonName, "Version")
        local author = C_AddOns.GetAddOnMetadata(AddonName, "Author")
        UIConfig.desc:SetText(Addon.localization.version..version.." | Discord: "..author)

        MPLTLootFrameTitleText:SetText(Addon.localization.title)
        MPLTLootFramePortrait:SetTexture("interface/icons/inv_bfa_paragoncache_orderofembers.blp") --Addon icon

        local showLootShiffButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        showLootShiffButton:Hide()
        showLootShiffButton:SetParent(MPLTLootFrame)
        showLootShiffButton:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 70, -30)
        showLootShiffButton:SetSize(100, 25)
        showLootShiffButton:SetText(Addon.localization.snifferTitle)
        showLootShiffButton:Show()
        showLootShiffButton:SetScript("OnClick", function()
            MPLT_LootSnifferMixin:Init()
        end)


        
        UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate")
        UIConfig.ScrollFrame:SetPoint("TOPLEFT", MPLTLootFrameBg, "TOPLEFT", 8, -45)
        UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", MPLTLootFrameBg, "BOTTOMRIGHT", -3, 30)
        UIConfig.ScrollFrame:SetSize(200,424)

        UIConfig.ScrollFrame:SetClipsChildren(true)

        PrepareEncounterList(playerID)

        UIConfig.dropDownChars = CreateFrame("DropdownButton", "MPLTDropDown", UIConfig, "WowStyle1DropdownTemplate")
        UIConfig.dropDownChars:SetDefaultText(playerID)
        UIConfig.dropDownChars.character = playerID
        UIConfig.dropDownChars:SetPoint("RIGHT", MPLTLootFrameTitleText, "RIGHT", 0, -35)
        UIConfig.dropDownChars:SetWidth(200)
        UIConfig.dropDownChars:SetupMenu(function(dropdown, rootDescription)
            rootDescription:CreateTitle("Characters")

            local function IsSelected(player)
                return UIConfig.dropDownChars.character == player
            end
    
            local function SetSelected(player)
                UIConfig.dropDownChars:SetDefaultText(player)
                UIConfig.dropDownChars.character = player
                fortune = CalcFortune(player, dungeonName, seasonID)

                local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
                if tabID == 1 then
                    PrepareEncounterList(player)
                    CreateTrackedItemList(content2)
                elseif tabID == 2 then
                    MPLT_TrackingElementMixin:PrepareTrackingList(player)
                end
                MPLT_UpdateSubFrames()
            end
            
            for k, v in pairs(MPLH_ENC[seasonID]) do
                rootDescription:CreateRadio(k, IsSelected, SetSelected, k)
            end
        end)

        UIConfig.dropDownSeason = CreateFrame("DropdownButton", "MPLTDropDownSeason", UIConfig, "WowStyle1DropdownTemplate")
        UIConfig.dropDownSeason:SetDefaultText(Addon.localization.season[Addon.currentSeason])
        UIConfig.dropDownSeason:SetPoint("RIGHT", MPLTLootFrameTitleText, "RIGHT", -215, -35)
        UIConfig.dropDownSeason:SetWidth(130)
        UIConfig.dropDownSeason.seasonID = seasonID
        UIConfig.dropDownSeason:SetupMenu(function(dropdown, rootDescription)
            rootDescription:CreateTitle("Seasons")

            local function IsSelected(season)
                return UIConfig.dropDownSeason.seasonID == season
            end
    
            local function SetSelected(season)
                UIConfig.dropDownSeason:SetDefaultText(season)
                UIConfig.dropDownSeason.seasonID = season
                seasonID = season

                local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
                if tabID == 1 then
                    PrepareEncounterList(playerID)
                elseif tabID == 2 then
                    MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
                end
                MPLT_UpdateSubFrames()
            end
            
            for k, v in pairs(MPLH_ENC) do
                rootDescription:CreateRadio(Addon.localization.season[k], IsSelected, SetSelected, k)
            end
        end)

        local content, content2, content3 = SetTabs(UIConfig, 3, Addon.localization.tab1, Addon.localization.tab2, Addon.localization.tab3)

        MPLT_AltManagerMixin:PrepareAltManager()

        UIConfig.ScrollFrame:SetScrollChild(content)
        UIConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)

        CreateTrackedItemList(content2)
    else
        if UIConfig:IsShown() then
            UIConfig:Hide()
        else
            local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
            if tabID == 1 then
                PrepareEncounterList(playerID)
            elseif tabID == 2 then
                MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
            end
            UIConfig:Show()
            MPLT_UpdateSubFrames()
        end
    end
end

function Addon:InitIcon()
    local icon = LibStub("LibDBIcon-1.0")
    local MPLTLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MythicPlusLootTracker", {
        type = "data source",
        text = "Mythic+ Loot Tracker",
        icon = "interface/icons/inv_bfa_paragoncache_orderofembers.blp",
        OnClick = function(button, buttonPressed)
            if buttonPressed == "LeftButton" then
                ProcessData(self)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then
                return
            end
            tooltip:AddLine("|cFFAA13D4Mythic+ Loot Tracker|r")
            tooltip:AddLine("|cFFFFFFFF" .. Addon.localization.mbutton)
        end,
    })

    icon:Register("MythicPlusLootTracker", MPLTLDB, Addon.DB.global.minimap)
end

function Addon:Init()
    Addon.DB = LibStub("AceDB-3.0"):New("MPLTOptions", {
        global = {
            minimap = {
                hide = false,
            },
        },
    })
    Addon:InitIcon()
end

local function ProcessEvent(self, event, ...)
	if event == 'ADDON_LOADED' then
		AddonLoadedEvent(self, event, ...)
        
        local addOnName = ...
        if addOnName == "Blizzard_EncounterJournal" then
            --hooksecurefunc("EncounterJournal_LootUpdate", EJTrackItem)
            local lastTier = EJ_GetNumTiers()
            if EJ_GetCurrentTier() ~= lastTier then
                EJ_SelectTier(lastTier)
            end
            local buttonsHolder = CreateFrame("Frame", "MPLT_ButtonHolder", nil, "MPLTBackdropTemplate")
            buttonsHolder:SetParent(EncounterJournalEncounterFrameInfo.LootContainer)
            buttonsHolder:SetPoint("TOPRIGHT", EncounterJournalEncounterFrameInfo.LootContainer, "TOPLEFT", 0, -20)
            buttonsHolder:SetSize(32,361)
            buttonsHolder:SetClipsChildren(true)
            buttonsHolder:Show()

            local EJTracker_HelpButton = CreateFrame("Button", "EJTracker_HelpButton", nil, "MainHelpPlateButton")
            EJTracker_HelpButton:SetParent(EncounterJournalEncounterFrameInfo.LootContainer)
            EJTracker_HelpButton:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPLEFT", 38, 90)
            EJTracker_HelpButton:Show()
            EJTracker_HelpButton:SetFrameLevel(520)
            EJTracker_HelpButton:SetScript("OnClick", EJTrackerHelpPlate_ToggleTutorial)
            

            EncounterJournal.encounter.info.LootContainer.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, OnDataRangeChanged, self)
        end
    elseif event == "FIRST_FRAME_RENDERED" then
        StoreCharacterData()      
        C_MythicPlus.RequestMapInfo()
        local seasonID = C_MythicPlus.GetCurrentSeason()
        if seasonID and Addon.currentSeason < seasonID then
            Addon.currentSeason = seasonID
        end
    elseif event == "CHAT_MSG_CURRENCY" or event == "CURRENCY_DISPLAY_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" then
        StoreCharacterData()  
    elseif event == 'ENCOUNTER_LOOT_RECEIVED' then
        local lootEncounterId, itemID, itemLink, quantity, unitName, className = ...
        local name, realm = UnitFullName("player")
        local playerID = name .. "-" .. realm

        if unitName == playerID or unitName == name then
            local _, _, difficultyIndex, _, _, _, _, _, _, _ = GetInstanceInfo()
            if difficultyIndex == 8 or difficultyIndex == 15 or difficultyIndex == 16 or difficultyIndex == 23 then
                LootReceivedEvent(itemID, itemLink, quantity, playerID, lootEncounterId)
            end
        end
    elseif event == 'CHALLENGE_MODE_COMPLETED' then
        CalcDungeonStat()
        
    elseif event == 'TRADE_TARGET_ITEM_CHANGED' then
        local tradeSlotIndex = ...
        local tradedItem = DetectTrade(tradeSlotIndex)

    elseif event == 'SHOW_LOOT_TOAST' then
        local typeIdentifier, itemLink, quantity, specID, sex, personalLootToast, toastMethod, lessAwesome, upgraded, corrupted = ...
        DetectGreatVault(itemLink)
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        if ... == 49 then
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
                tinsert(greatVaultTable, 199202)
            end
        end
    end
end

SLASH_MPLHCOMMAND1 = "/mplh"

SlashCmdList["MPLHCOMMAND"] = function()
    print("seasonID: ", seasonID)
    print("currentSeason: ", Addon.currentSeason)

end

eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('ADDON_LOADED')
eventHandlerFrame:RegisterEvent('FIRST_FRAME_RENDERED')
eventHandlerFrame:RegisterEvent('CHAT_MSG_LOOT')
eventHandlerFrame:RegisterEvent('CHAT_MSG_CURRENCY')
eventHandlerFrame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
eventHandlerFrame:RegisterEvent('CHALLENGE_MODE_COMPLETED')
eventHandlerFrame:RegisterEvent('TRADE_TARGET_ITEM_CHANGED')
eventHandlerFrame:RegisterEvent('SHOW_LOOT_TOAST')
eventHandlerFrame:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW')
eventHandlerFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
eventHandlerFrame:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
--eventHandlerFrame:RegisterEvent('WEEKLY_REWARDS_SHOW')
