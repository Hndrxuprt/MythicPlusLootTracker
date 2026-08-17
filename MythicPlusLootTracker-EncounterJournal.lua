local AddonName, Addon = ...

MPLTCoreMixin = {}

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
    if instanceID == 1194 then
        for k, v in pairs(Addon.currentSeasonEncounters) do
            if Addon.IsValueInTable(v, encID) then
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
                                Addon.CalcChance(playerID, instanceID, itemID, false, itemInfo.encounterID)
                            end
                        end
                    end
                    if MPLTLootFrame then
                        MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
                        Addon.UpdateSubFrames()
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

function Addon.InjectEncounterJournal()
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

    EncounterJournal.encounter.info.LootContainer.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, OnDataRangeChanged)
end