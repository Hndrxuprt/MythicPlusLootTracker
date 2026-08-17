local AddonName, Addon = ...

MythicPlusLootTrackerLuckElementMixin = {}

local EncountersFrame = CreateFrame("Frame", "MPLTEncountersFrame", UIParent, "ScrollBoxSelectorTemplate") --ScrollBoxSelectorTemplate
EncountersFrame.bg = EncountersFrame:CreateTexture(nil, "BACKGROUND")
EncountersFrame.bg:SetParent(EncountersFrame)
EncountersFrame.bg:SetPoint("TOP", EncountersFrame, "TOP", 0, 5)
EncountersFrame.bg:SetAtlas("auctionhouse-background-buy-commodities-market", false)
EncountersFrame.bg:SetSize(300,350)

EncountersFrame.title = EncountersFrame:CreateTexture(nil, "BACKGROUND")
EncountersFrame.title:SetParent(EncountersFrame)
EncountersFrame.title:SetPoint("BOTTOM", EncountersFrame, "TOP", 0, -5)
EncountersFrame.title:SetAtlas("auctionhouse-background-buy-noncommodities-market", false)
EncountersFrame.title:SetSize(300,60)

local lootFrame = CreateFrame("Frame", "MPLTItemsFrame", UIParent, "ScrollBoxSelectorTemplate") --ScrollBoxSelectorTemplate
local LootDataProvider = CreateDataProvider()

function MythicPlusLootTrackerLuckElementMixin:InitLootList(frame, elementData)
    local name = elementData.itemLink
    local traded, itemLink = strsplit("~", name, 2)
    local itemID = select(1,GetDetailedItemLevelInfo(itemLink or traded))
    frame.ItemContainer.Item:SetItem(itemLink or traded)
    frame.ItemContainer.Item.Count:SetText(itemID)
    frame.ItemContainer.Item.Count:Show()
    frame.ItemContainer.Text:SetText(itemLink or traded)
    frame.ItemContainer.Index:SetText(LootDataProvider:FindIndex(elementData))
    frame.ItemContainer.Index:SetTextColor(0.6, 0.6, 0.6, 1.0)
    frame.ItemContainer.AmountText:SetText("x"..elementData.amount)
    frame.ItemContainer.AmountText:SetTextColor(0.8, 0.8, 0.8, 1.0)
    frame.ItemContainer.CritFrame:Hide()
    frame.ItemContainer.CritText:SetText("")
    if itemLink then
        frame.ItemContainer.CritFrame:Show()
        frame.ItemContainer.CritText:SetText("Traded item")
        frame.ItemContainer.CritText:SetTextColor(0.7, 0.3, 0.3, 1.0)
        frame.ItemContainer.CritFrame:SetVertexColor(0.5, 0.1, 0.1)
    end

    frame.ItemContainer.Item:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("RIGHT", frame, "LEFT", -10, 0)
        GameTooltip:SetHyperlink(itemLink or traded)
        GameTooltip:Show()
    end)
    frame.ItemContainer.Item:SetScript("OnLeave", function(self)
        GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        GameTooltip:Hide()
    end)
end
function MythicPlusLootTrackerLuckElementMixin:PrepareLootList(dungeonID, playerID)
    LootDataProvider:Flush()

    local view = CreateScrollBoxListLinearView(1, 1, 2, 20, 1) --top, bottom, left, right, spacing
    view:SetElementExtent(46)
	view:SetElementInitializer("MythicPlusLootTrackerLuckElementTemplate", function(frame, elementData)
        MythicPlusLootTrackerLuckElementMixin:InitLootList(frame, elementData)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(lootFrame.ScrollBox, lootFrame.ScrollBar, view)
    lootFrame.ScrollBox:Init(view)
    lootFrame.ScrollBox:SetInterpolateScroll(true)
    lootFrame.ScrollBar:SetInterpolateScroll(true)
    local function GetData(dungeonID)
        if MPLH_ENC[Addon.currentSeason][playerID] and MPLH_ENC[Addon.currentSeason][playerID][dungeonID] then
            for itemLink, amount in pairs(MPLH_ENC[Addon.currentSeason][playerID][dungeonID]) do
                local itemType = select(6,GetItemInfoInstant(itemLink))
                    if Addon.IsEquippableItemType(itemType) then
                        LootDataProvider:Insert({itemLink = itemLink, amount = amount})
                    end
            end
        end
    end
    if dungeonID ~= Addon.Constants.OVERALL_ID then
        GetData(dungeonID)
    else
        if MPLH_ENC[Addon.currentSeason] and MPLH_ENC[Addon.currentSeason][playerID] then
            for dungeonID, _v in pairs(MPLH_ENC[Addon.currentSeason][playerID]) do
                GetData(dungeonID)
            end
        end
    end
    local function SortComparator(amount1, amount2)
        if amount1 and amount2 then
            return amount1.amount > amount2.amount
        end
    end
    LootDataProvider:SetSortComparator(SortComparator)
    lootFrame.ScrollBox:SetDataProvider(LootDataProvider)
    lootFrame:ClearAllPoints()
    lootFrame:SetParent(EncountersFrame)
    lootFrame:SetPoint("TOPRIGHT", EncountersFrame, "TOPLEFT", -15, 54)
    lootFrame:SetSize(460, 401)
    lootFrame:Show()
    lootFrame:SetAlpha(1)
end

local DataProvider = CreateDataProvider()

local oldSelection
local function Init_Button(button, elementData, playerID)
    local encounterId = elementData.encounterID
    local runs = elementData.runs
    local name = select(1,GetEncounter(encounterId))
    local fortune = string.format("%.1f",(elementData.fortune*100)).."%"
    button.name:SetText(name.." - "..runs.." - "..fortune)
    button:SetScript("OnClick", function()
        if oldSelection then
            oldSelection:UnlockHighlight()
        end
        oldSelection = button
        button:LockHighlight()
        MythicPlusLootTrackerLuckElementMixin:PrepareLootList(encounterId, playerID)
    end)

    if encounterId == Addon.Constants.OVERALL_ID then
        button:LockHighlight()
        button:Click()
    end
end

function PrepareEncounterList(playerID)
    DataProvider:Flush()

    local view = CreateScrollBoxListLinearView(10, 10, 2, 2, 0);
    view:SetElementExtent(20)
	view:SetElementInitializer("FriendsFriendsButtonTemplate", function(button, elementData)
		Init_Button(button, elementData, playerID)
	end)
    ScrollUtil.InitScrollBoxListWithScrollBar(EncountersFrame.ScrollBox, EncountersFrame.ScrollBar, view)
    EncountersFrame.ScrollBox:Init(view)

    ScrollUtil.RegisterAlternateRowBehavior(EncountersFrame.ScrollBox, function(frame, alternate)
        if not EncountersFrame.ScrollBox.hideStripes then
            local bg = frame:CreateTexture(nil, "BACKGROUND")
            frame:SetNormalTexture(bg)
            frame:GetNormalTexture():SetAtlas(alternate and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2")
        end
    end)

    if MPLH_ENC_ENDED and MPLH_ENC_ENDED[Addon.currentSeason][playerID] then
        local overall = 0
        local overallFortune = 0
        local overallLoot = 0
        for encounterID, runs in pairs(MPLH_ENC_ENDED[Addon.currentSeason][playerID]) do
            local fortune, numLoot = CalcFortune(playerID, encounterID, Addon.currentSeason)
            DataProvider:Insert({encounterID = encounterID, runs = runs, fortune = fortune})
            overall = overall + runs
            overallLoot = overallLoot + numLoot
        end
        overallFortune = overallLoot/overall
        DataProvider:Insert({encounterID = Addon.Constants.OVERALL_ID, runs = overall, fortune = overallFortune})
        EncountersFrame.ScrollBox:SetDataProvider(DataProvider)
    end
    local function SortComparator(enc1, enc2)
        if enc1 and enc2 then
            return enc1.runs > enc2.runs
        end
    end
    DataProvider:SetSortComparator(SortComparator)

    EncountersFrame:ClearAllPoints()
    EncountersFrame:SetParent(MPLTLootFrame)
    EncountersFrame:SetPoint("TOPRIGHT", MPLTLootFrame, "TOPRIGHT", -19, -120)
    EncountersFrame:SetSize(290, 347)
    EncountersFrame:Show()
    EncountersFrame:SetAlpha(1)
end