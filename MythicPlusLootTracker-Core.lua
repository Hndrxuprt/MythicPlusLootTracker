local AddonName, Addon = ...

local UIConfig = nil

local greatVaultTable = {}

function Addon.GetPlayerID()
    local name, realm = UnitFullName("player")
    return name .. "-" .. realm
end

function Addon.GetPlayerName()
    return select(1, UnitFullName("player"))
end

function Addon.IsEquippableItemType(itemType)
    return itemType == 2 or itemType == 4
end

function Addon.GetTableLength(tbl)
    local length = 0
    if tbl ~= nil then
        for _ in pairs(tbl) do
            length = length + 1
        end
    end
    return length
end

function Addon.MakeTrackedItemRecord(playerID, instanceID, itemID)
    if MPLH_TRACKITEM[playerID] == nil then
        MPLH_TRACKITEM[playerID] = {}
    end
    if MPLH_TRACKITEM[playerID][instanceID] == nil then
        MPLH_TRACKITEM[playerID][instanceID] = {}
    end
    local record = MPLH_TRACKITEM[playerID][instanceID][itemID]
    if record == nil then
        record = {
            ["dateSince"] = date("%d.%m.%y"),
            ["attempts"] = 0,
            ["chances"] = 0,
            ["done"] = {
                ["done"] = 0,
                ["date"] = 0,
                ["attempts"] = 0,
                ["traded"] = 0,
                ["chance"] = 0,
            },
        }
        MPLH_TRACKITEM[playerID][instanceID][itemID] = record
        if MPLH_TRACKEDITEM_ITEMORDER[playerID] == nil then
            MPLH_TRACKEDITEM_ITEMORDER[playerID] = {}
        end
        if MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID] == nil then
            MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID] = {}
        end
        if MPLH_TRACKITEM_ORDER[playerID] == nil then
            MPLH_TRACKITEM_ORDER[playerID] = {}
        end
        if not tContains(MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID], itemID) then
            tinsert(MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID], itemID)
        end
        if not tContains(MPLH_TRACKITEM_ORDER[playerID], instanceID) then
            tinsert(MPLH_TRACKITEM_ORDER[playerID], instanceID)
        end
    end
    return record
end

function Addon.CancelAutoclose(frame, owner)
    if owner.timer then
        frame.TimerAnim:Stop()
        frame.AutocloseText:SetAlpha(0)
        owner.timer:Cancel()
        owner.timer = nil
    end
end

function Addon.StopAutoclose(frame, owner)
    if owner.timer then
        frame.TimerAnim:Stop()
        frame.AutocloseText:SetAlpha(0)
        frame.autoclose = false
        owner.timer:Cancel()
        owner.timer = nil
    end
end

function Addon.StartAutoclose(frame, owner, restart)
    if not frame.autoclose then
        return
    end
    if owner.timer then
        frame.TimerAnim:Stop()
        owner.timer:Cancel()
        owner.timer = nil
    end
    if restart then
        frame.TimerAnim:Restart()
    else
        frame.TimerAnim:Play()
    end
    owner.timer = C_Timer.NewTimer(10, function()
        frame:Hide()
        frame:SetAlpha(0)
        owner.timer:Cancel()
        owner.timer = nil
    end)
end

function Addon.RunOnItemReady(itemLink, callback)
    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(callback)
    else
        callback()
    end
end

MPLTCoreMixin = {}

local function AddonLoadedEvent(self, event, Name, ...)
	if Name == AddonName then

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

local function SplitItemLink(itemLink)
    local s1, s2 = nil, nil
    s1, s2 = strsplit("~", itemLink, 2)
    return s1, s2
end



function Addon.FindItemInBags(itemLink)
    for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local foundLink = C_Container.GetContainerItemLink(bag, slot)
            if foundLink == itemLink then
                return bag, slot
            end
        end
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
        tab.content:SetSize(Addon.Constants.Layout.TabContentWidth, Addon.Constants.Layout.TabContentHeight)
        tab.content:Hide()
        tab:Hide()
        tab:Show()

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
    elseif Addon.Constants.GREAT_VAULT_ID then
        dungeonName = Addon.localization.gvault
        return dungeonName, instance 
    elseif Addon.Constants.OVERALL_ID then
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
    else
        print("CalcDungeon failed because of instanceID: ", instanceID)
    end
end

function CalcFortune(playerID, instanceID, seasonID)
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

local function CalcChance(playerID, instanceID, item, reset, encounterID)
    local lootChance = 0
    local attempts = MPLH_TRACKITEM[playerID][instanceID][item]["attempts"]
    local spec = GetSpecialization()
    local specID = GetSpecializationInfo(spec)
    local _,_,classID = UnitClass("player")
    local numLoot = 0
    local wearableItems = 0
    EJ_SetLootFilter(classID, specID)
    if ( EJ_IsValidInstanceDifficulty(Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS) ) then
        EJ_SetDifficulty(Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS)
    end
    local function GetWearableForEnc(Enc)
        if Enc then
            local name, _, _, _, _, journalInstanceID, _, _ = EJ_GetEncounterInfo(Enc)
            EJ_SelectInstance(journalInstanceID)
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
        for k, v in pairs(Addon.currentSeasonEncounters[instanceID]) do
            encounterID = v
            break 
        end     
    end

    GetWearableForEnc(encounterID)

    if wearableItems > 0 then
        if reset then
            lootChance = string.format("%.2f", (((1/wearableItems) * Addon.Constants.LOOT_DROP_RATE)*100))
        else
            lootChance = string.format("%.2f", (((1/wearableItems) * Addon.Constants.LOOT_DROP_RATE)*(attempts+1)*100))
        end
    end
    if MPLH_TRACKITEM[playerID][instanceID][item]["chances"] == 0 then
        MPLH_TRACKITEM[playerID][instanceID][item]["chances"] = lootChance
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
        if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][instanceID] and MPLH_TRACKITEM[playerID][instanceID][itemID] then
            if MPLH_TRACKITEM[playerID][instanceID][itemID]["done"] and MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["done"] == 0 then
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["done"] = 1
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["date"] = date("%d.%m.%y")
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["attempts"] = MPLH_TRACKITEM[playerID][instanceID][itemID]["attempts"]
                MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["chance"] = MPLH_TRACKITEM[playerID][instanceID][itemID]["chances"]

                MPLH_TRACKITEM[playerID][instanceID][itemID]["attempts"] = 0
                if isInTraded then
                    MPLH_TRACKITEM[playerID][instanceID][itemID]["done"]["traded"] = 1
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
    if Addon.IsEquippableItemType(itemType) and mapID == Addon.Constants.GREAT_VAULT_MAP_ID and isValueinTable(greatVaultTable, itemID) then
        local fullname = Addon.GetPlayerID()
        local greatVault = Addon.Constants.GREAT_VAULT_ID
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
        if Addon.IsEquippableItemType(itemType) then
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

function Addon.sortTable(tbl)
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
    
    local MPLH_ENC_TABLE = MPLH_ENC[Addon.currentSeason]
    if MPLH_ENC_TABLE[playerID] ~= nil and MPLH_ENC_TABLE[playerID][dungeonName] ~= nil then
        local tbl = {}
        tbl = CopyTable(MPLH_ENC_TABLE[playerID][dungeonName])

        local scrollLength = Addon.GetTableLength(tbl) 
        content:SetSize(308,scrollLength*32);

        local sortedTable = Addon.sortTable(tbl)

        

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
    end
end

local EJTracker_HelpPlate = {
	FramePos = { x = 2, y = 40 },
	FrameSize = { width = 840, height = 520 },
	[1] = { ButtonPos = { x = 380,	y = -60 }, HighLightBox = { x = 390,  y = -80, width = 45, height = 385 },		ToolTipDir = "LEFT",   ToolTipText = Addon.localization.help1 },
	[2] = { ButtonPos = { x = 645,  y = -40 }, HighLightBox = { x = 670, y = -50, width = 110, height = 30 },	ToolTipDir = "LEFT",   ToolTipText = Addon.localization.help2 },
	[3] = { ButtonPos = Addon.Constants.HelpPlate.helpButton, HighLightBox = Addon.Constants.HelpPlate.helpBox,	ToolTipDir = "RIGHT",   ToolTipText = Addon.localization.help3 },
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
local function InstanceIDToMapID(instanceID, encID)
    local mapID = instanceID
    if instanceID == 1194 then --current megadungeon JournalInstanceID
        for k, v in pairs(Addon.currentSeasonEncounters) do
            if isValueinTable(v, encID) then
                mapID = k
            end
        end
    elseif instanceID and Addon.EJInstanceIDToMapID[instanceID] then
        mapID = Addon.EJInstanceIDToMapID[instanceID]
    end
    return mapID
end

local EJTrackItemPool = CreateFramePool("Button", UIParent, "UIPanelCloseButtonNoScripts")

local function EJTrackItem()
    EJTrackItemPool:ReleaseAll()
    local playerID = MPLTLootFrame and MPLTDropDown.defaultText or Addon.GetPlayerID()
    local isRaid = EncounterJournal_IsRaidTabSelected(EncounterJournal)

    if (EJ_GetCurrentTier() ~= EJ_GetNumTiers()) then
        return
    end
    if (not isRaid) and (EJ_GetDifficulty() ~= Addon.Constants.EJ_DIFFICULTY_MYTHIC_PLUS) then
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
            local instanceID = isRaid and EncounterJournal.instanceID or InstanceIDToMapID(EncounterJournal.instanceID, itemInfo.encounterID)
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
                        if #MPLH_TRACKEDITEM_ITEMORDER[playerID][instanceID] > 1 then
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
                            itemID = tonumber(itemID)
                            if not MPLH_TRACKITEM[playerID] or not MPLH_TRACKITEM[playerID][instanceID] or not MPLH_TRACKITEM[playerID][instanceID][itemID] then
                                Addon.MakeTrackedItemRecord(playerID, instanceID, itemID)
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
                end)
                if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][instanceID] and MPLH_TRACKITEM[playerID][instanceID][itemID] then
                    EJTrackItemButton:SetNormalAtlas("runecarving-icon-reagent-empty-error")
                else
                    EJTrackItemButton:SetNormalAtlas("runecarving-icon-reagent-empty")
                end
            end
        end
    end
end

local function OnDataRangeChanged()
    EJTrackItem()
end

local function CreateTrackedItemList(parent)
    local playerID = MPLTDropDown.defaultText
    MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
end

function StoreCharacterData()
    if UnitLevel("player") < Addon.Constants.MIN_CHARACTER_LEVEL then 
        return
    else
        local name = Addon.GetPlayerName()
        local _, class = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[class].colorStr
        local playerID = "|c"..classColor..name

        local updateDate = date("%d.%m.%y")

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
        local numKeys = 0
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
                numKeys = numKeys + 1
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
                lastInstanceID = instanceID;
                end
                if name then
                    if encounter.bestDifficulty > 0 then
                        local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
                        tinsert(raidRuns, {name, completedDifficultyName})
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
        for i=1, Addon.Constants.GEAR_SLOT_COUNT do
            if i ~= Addon.Constants.GEAR_SLOT_SKIP then
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
            tinsert(MPLH_KACDATA[playerID]["keys"], {id=maps[i], level=level, dungeonScore = dungeonScore, inTimeInfo = inTimeInfo, overtimeInfo = overtimeInfo, affixScores = affixScores, overAllScore = overAllScore})
        end

        MPLH_KACDATA[playerID]["updateDate"] = updateDate
        MPLH_KACDATA[playerID]["oneMPlus"] = oneMPlus
        MPLH_KACDATA[playerID]["fourMPlus"] = fourMPlus
        MPLH_KACDATA[playerID]["eightMPlus"] = eightMPlus
        MPLH_KACDATA[playerID]["currentKeystone"] = currentKeystone
        MPLH_KACDATA[playerID]["currentKeystoneLvl"] = currentKeystoneLvl
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

local function ProcessData(self)
    local playerID = Addon.GetPlayerID()
    if UIConfig == nil then
        local dungeonName = nil

        UIConfig = CreateFrame("Frame", "MPLTLootFrame", UIParent, "ButtonFrameTemplate")
        _G["UIConfig"] = UIConfig
        tinsert(UISpecialFrames, UIConfig:GetName())
        UIConfig:SetSize(Addon.Constants.Layout.MainWindowWidth, Addon.Constants.Layout.MainWindowHeight)
        UIConfig:SetPoint("CENTER")
        UIConfig:SetMovable(true)
        UIConfig:EnableMouse(true)
        UIConfig:RegisterForDrag("LeftButton")
        UIConfig:SetScript("OnDragStart",UIConfig.StartMoving)
        UIConfig:SetScript("OnDragStop",UIConfig.StopMovingOrSizing)
        UIConfig:SetFrameStrata("HIGH")
        MPLTLootFrameInset.Bg:SetAtlas("Dragonflight-Landingpage-Background", true)
        MPLTLootFrameInset.Bg:SetHorizTile(false)
        MPLTLootFrameInset.Bg:SetVertTile(false)
        MPLTLootFrameInset.Bg:SetVertexColor(0.4, 0.4, 0.4)

        UIConfig.desc = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        UIConfig.desc:ClearAllPoints()
        UIConfig.desc:SetPoint("BOTTOMLEFT", MPLTLootFrameBg, "BOTTOMLEFT", 8, 6)
        local version = C_AddOns.GetAddOnMetadata(AddonName, "Version")
        local author = C_AddOns.GetAddOnMetadata(AddonName, "Author")
        UIConfig.desc:SetText(Addon.localization.version..version.." | Discord: "..author)

        MPLTLootFrameTitleText:SetText(Addon.localization.title)
        MPLTLootFramePortrait:SetTexture("interface/icons/inv_bfa_paragoncache_orderofembers.blp")

        local showLootSnifferButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        showLootSnifferButton:Hide()
        showLootSnifferButton:SetParent(MPLTLootFrame)
        showLootSnifferButton:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 70, -30)
        showLootSnifferButton:SetSize(100, 25)
        showLootSnifferButton:SetText(Addon.localization.snifferTitle)
        showLootSnifferButton:Show()
        showLootSnifferButton:SetScript("OnClick", function()
            MPLT_LootSnifferMixin:Init()
        end)

        local showRollButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        showRollButton:Hide()
        showRollButton:SetParent(MPLTLootFrame)
        showRollButton:SetPoint("LEFT", showLootSnifferButton, "RIGHT", 4, 0)
        showRollButton:SetSize(100, 25)
        showRollButton:SetText(Addon.localization.rollButton)
        showRollButton:Show()
        showRollButton:SetScript("OnClick", function()
            MPLT_RollFrameMixin:Init()
        end)

        if C_AddOns.IsAddOnLoaded("ClassCodex") then
            local showImportButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
            showImportButton:Hide()
            showImportButton:SetParent(MPLTLootFrame)
            showImportButton:SetPoint("LEFT", showRollButton, "RIGHT", 4, 0)
            showImportButton:SetSize(100, 25)
            showImportButton:SetText(Addon.localization.CCImportButton)
            showImportButton:Show()
            showImportButton:SetScript("OnClick", function()
                local type = "Mythic+"
                if IsShiftKeyDown() then
                    type = "Raid"
                elseif IsAltKeyDown() then
                    type = "Overall"
                end
                MPLT_ImportClassCodexGear(type)
            end)
            showImportButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip_AddNormalLine(GameTooltip, Addon.localization.CCImportButtonDesc1)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddHighlightLine(GameTooltip, Addon.localization.CCImportButtonDesc2)
                GameTooltip_AddColoredLine(GameTooltip, Addon.localization.CCImportButtonDesc3, LIGHTYELLOW_FONT_COLOR)
                GameTooltip_AddColoredLine(GameTooltip, Addon.localization.CCImportButtonDesc4, LIGHTYELLOW_FONT_COLOR)
                GameTooltip_AddColoredLine(GameTooltip, Addon.localization.CCImportButtonDesc5, LIGHTYELLOW_FONT_COLOR)
                GameTooltip:SetScale(0.82)
                GameTooltip:Show()
            end)
            showImportButton:SetScript("OnLeave",function(self)
                GameTooltip:SetScale(1)
                GameTooltip:Hide()
            end)


            local texture = C_AddOns.GetAddOnMetadata("ClassCodex", "IconTexture")
            if texture then
                showImportButton.icon = showImportButton:CreateTexture()
                showImportButton.icon:SetSize(16, 16)
                showImportButton.icon:SetPoint("LEFT", showImportButton, "LEFT", 8, 0)
                showImportButton.icon:SetTexture(texture)
                showImportButton.icon:Show()
            end
        end


        
        UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate")
        UIConfig.ScrollFrame:SetPoint("TOPLEFT", MPLTLootFrameBg, "TOPLEFT", 8, -45)
        UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", MPLTLootFrameBg, "BOTTOMRIGHT", -3, 30)
        UIConfig.ScrollFrame:SetSize(Addon.Constants.Layout.ScrollFrameWidth, Addon.Constants.Layout.ScrollFrameHeight)

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
                fortune = CalcFortune(player, dungeonName, Addon.currentSeason)

                local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
                if tabID == 1 then
                    PrepareEncounterList(player)
                    CreateTrackedItemList(content2)
                elseif tabID == 2 then
                    MPLT_TrackingElementMixin:PrepareTrackingList(player)
                end
                MPLT_UpdateSubFrames()
            end
            
            for k, v in pairs(MPLH_ENC[Addon.currentSeason]) do
                rootDescription:CreateRadio(k, IsSelected, SetSelected, k)
            end
        end)

        UIConfig.dropDownSeason = CreateFrame("DropdownButton", "MPLTDropDownSeason", UIConfig, "WowStyle1DropdownTemplate")
        UIConfig.dropDownSeason:SetDefaultText(Addon.localization.season[Addon.currentSeason])
        UIConfig.dropDownSeason:SetPoint("RIGHT", MPLTLootFrameTitleText, "RIGHT", -215, -35)
        UIConfig.dropDownSeason:SetWidth(130)
        UIConfig.dropDownSeason.seasonID = Addon.currentSeason
        UIConfig.dropDownSeason:SetupMenu(function(dropdown, rootDescription)
            rootDescription:CreateTitle("Seasons")

            local function IsSelected(season)
                return UIConfig.dropDownSeason.seasonID == season
            end
    
            local function SetSelected(season)
                UIConfig.dropDownSeason:SetDefaultText(season)
                UIConfig.dropDownSeason.seasonID = season
                Addon.currentSeason = season

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
            tooltip:AddLine(Addon.Constants.Color.Brand.."Mythic+ Loot Tracker|r")
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
        C_Timer.After(1, function()
            StoreCharacterData()      
        end)
        C_MythicPlus.RequestMapInfo()
        local currentSeason = C_MythicPlus.GetCurrentSeason()
        if currentSeason and Addon.currentSeason < currentSeason then
            Addon.currentSeason = currentSeason
        end
    elseif event == "CHAT_MSG_CURRENCY" or event == "CURRENCY_DISPLAY_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" then
        StoreCharacterData()  
    elseif event == 'ENCOUNTER_LOOT_RECEIVED' then
        local lootEncounterId, itemID, itemLink, quantity, unitName, className = ...
        local playerID = Addon.GetPlayerID()
        local name = Addon.GetPlayerName()

        if unitName == playerID or unitName == name then
            local _, _, difficultyIndex, _, _, _, _, _, _, _ = GetInstanceInfo()
            if isValueinTable(Addon.Constants.MPLUS_DIFFICULTY_INDICES, difficultyIndex) then
                LootReceivedEvent(itemID, itemLink, quantity, playerID, lootEncounterId)
            end
        end
    elseif event == 'CHALLENGE_MODE_COMPLETED' then
        CalcDungeonStat()
        StoreCharacterData()
    elseif event == 'TRADE_TARGET_ITEM_CHANGED' then
        local tradeSlotIndex = ...
        local tradedItem = DetectTrade(tradeSlotIndex)

    elseif event == 'SHOW_LOOT_TOAST' then
        local typeIdentifier, itemLink, quantity, specID, sex, personalLootToast, toastMethod, lessAwesome, upgraded, corrupted = ...
        DetectGreatVault(itemLink)
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        if ... == Addon.Constants.GREAT_VAULT_INTERACTION_TYPE then
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
