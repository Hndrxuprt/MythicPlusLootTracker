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
        frame.ItemContainer.CritText:SetText(Addon.localization.tradedItem)
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
    local name = select(1,Addon.GetEncounter(encounterId)) or tostring(encounterId)
    local fortune = string.format("%.1f",(elementData.fortune*100)).."%"
    button.Name:SetText(name.." - "..runs.." - "..fortune)
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

local function InitFortuneCompact(frame, elementData, dataIndex)
    local encounterId = elementData.encounterID
    local runs = elementData.runs
    local numLoot = elementData.numLoot or 0
    local name = select(1, Addon.GetEncounter(encounterId)) or tostring(encounterId)
    local fortuneVal = elementData.fortune or 0
    local fortune = string.format("%.0f", fortuneVal * 100) .. "%"

    frame.EncounterText:SetText(name)
    frame.EncounterText:SetTextScale(1.2)
    if CAMPAIGN_COMPLETE_COLOR then
        frame.EncounterText:SetTextColor(CAMPAIGN_COMPLETE_COLOR:GetRGB())
    end

    -- Статистика: метки сверху, значения снизу, в три колонки.
    -- Цвет удачи варьируется от красного (0%) к зелёному (100%).
    local fortunePct = fortuneVal * 100
    if fortunePct > 100 then fortunePct = 100 end
    local r = math.max(0, 1 - fortunePct / 50)
    local g = math.min(1, fortunePct / 50)
    local hex = string.format("%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), 0)

    if frame.RunsLabel then
        frame.RunsLabel:SetText(Addon.localization.runsLabel)
        frame.RunsLabel:SetTextScale(1.1)
        frame.RunsLabel:SetTextColor(1, 1, 1, 1)
    end
    if frame.ItemsLabel then
        frame.ItemsLabel:SetText(Addon.localization.itemsLabel)
        frame.ItemsLabel:SetTextScale(1.1)
        frame.ItemsLabel:SetTextColor(1, 1, 1, 1)
    end
    if frame.FortuneLabel then
        frame.FortuneLabel:SetText(Addon.localization.luckLabel)
        frame.FortuneLabel:SetTextScale(1.1)
        frame.FortuneLabel:SetTextColor(1, 1, 1, 1)
    end

    if frame.RunsValue then
        frame.RunsValue:SetText(runs)
        frame.RunsValue:SetTextScale(1.1)
        frame.RunsValue:SetTextColor(1, 1, 1, 1)
    end
    if frame.ItemsValue then
        frame.ItemsValue:SetText(numLoot)
        frame.ItemsValue:SetTextScale(1.1)
        frame.ItemsValue:SetTextColor(1, 1, 1, 1)
    end
    if frame.FortuneValue then
        frame.FortuneValue:SetText("|cff"..hex..fortune.."|r")
        frame.FortuneValue:SetTextScale(1.1)
    end

    -- Зебра + рамка.
    local zebra = (dataIndex % 2 == 0)
    if zebra then
        frame.RowBG:SetVertexColor(0.18, 0.18, 0.20, 0.55)
    else
        frame.RowBG:SetVertexColor(0.10, 0.10, 0.12, 0.45)
    end
    local border = { frame.RowBorderTop, frame.RowBorderBottom, frame.RowBorderLeft, frame.RowBorderRight }
    for _, tex in ipairs(border) do
        if tex then tex:SetVertexColor(0.35, 0.35, 0.38, 0.6) end
    end

    -- Фон подземелья с маской; для Overall/Great Vault — отдельные текстуры.
    if frame.DungeonBG and frame.DungeonMask then
        if encounterId == Addon.Constants.OVERALL_ID then
            frame.DungeonBG:SetAtlas("groupfinder-background-custom-pve")
        elseif encounterId == Addon.Constants.GREAT_VAULT_ID then
            frame.DungeonBG:SetAtlas("talenttree-TitanConsole-background")
        else
            local bgImage = Addon.GetDungeonBackground(encounterId)
            if bgImage then
                frame.DungeonBG:SetTexture(bgImage)
            else
                frame.DungeonBG:SetTexture("Interface\\EncounterJournal\\UI-EJ-BACKGROUND-Default")
            end
        end
        frame.DungeonBG:SetVertexColor(1, 1, 1, 0.35)
        frame.DungeonBG:Show()
        if C_Texture.GetAtlasInfo("glues-characterSelect-GS-TopHUD-right") then
            frame.DungeonMask:SetAtlas("glues-characterSelect-GS-TopHUD-right", true)
        end
        frame.DungeonBG:AddMaskTexture(frame.DungeonMask)
    end
end

function Addon.PrepareEncounterList(playerID)
    local compact = Addon.DB and Addon.DB.global and Addon.DB.global.compactView
    DataProvider:Flush()

    if compact then
        local view = CreateScrollBoxListLinearView(0, 0, 2, 2, -1);
        view:SetElementExtent(48)
        view:SetElementInitializer("MPLT_FortuneCompactElementTemplate", function(frame, elementData)
            local idx = DataProvider:FindIndex(elementData)
            InitFortuneCompact(frame, elementData, idx)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(EncountersFrame.ScrollBox, EncountersFrame.ScrollBar, view)
        EncountersFrame.ScrollBox:Init(view)
        -- Перетираем callback зебры от полного вида пустым: компактные строки — Frame,
        -- у них нет SetNormalTexture, и зебра рисуется в InitFortuneCompact.
        ScrollUtil.RegisterAlternateRowBehavior(EncountersFrame.ScrollBox, function() end)
    else
        local view = CreateScrollBoxListLinearView(10, 10, 2, 2, 0);
        view:SetElementExtent(20)
        view:SetElementInitializer("FriendsFriendsButtonTemplate", function(button, elementData)
            Init_Button(button, elementData, playerID)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(EncountersFrame.ScrollBox, EncountersFrame.ScrollBar, view)
        EncountersFrame.ScrollBox:Init(view)

        ScrollUtil.RegisterAlternateRowBehavior(EncountersFrame.ScrollBox, function(frame, alternate)
            if not EncountersFrame.ScrollBox.hideStripes and frame.SetNormalTexture then
                local bg = frame:CreateTexture(nil, "BACKGROUND")
                frame:SetNormalTexture(bg)
                frame:GetNormalTexture():SetAtlas(alternate and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2")
            end
        end)
    end

    if MPLH_ENC_ENDED and MPLH_ENC_ENDED[Addon.currentSeason][playerID] then
        local overall = 0
        local overallFortune = 0
        local overallLoot = 0
        local greatVaultData
        for encounterID, runs in pairs(MPLH_ENC_ENDED[Addon.currentSeason][playerID]) do
            local fortune, numLoot = Addon.CalcFortune(playerID, encounterID, Addon.currentSeason)
            if encounterID == Addon.Constants.GREAT_VAULT_ID then
                greatVaultData = {encounterID = encounterID, runs = runs, fortune = fortune, numLoot = numLoot}
            else
                DataProvider:Insert({encounterID = encounterID, runs = runs, fortune = fortune, numLoot = numLoot})
            end
            overall = overall + runs
            overallLoot = overallLoot + numLoot
        end
        if overall > 0 then
            overallFortune = overallLoot / overall
        end
        EncountersFrame.ScrollBox:SetDataProvider(DataProvider)
        -- Компаратор: Overall всегда первый, Great Vault — второй, остальные по убыванию runs.
        local function SortComparator(enc1, enc2)
            if enc1 and enc2 then
                local isOverall1 = enc1.encounterID == Addon.Constants.OVERALL_ID
                local isOverall2 = enc2.encounterID == Addon.Constants.OVERALL_ID
                if isOverall1 then return true end
                if isOverall2 then return false end
                local isGV1 = enc1.encounterID == Addon.Constants.GREAT_VAULT_ID
                local isGV2 = enc2.encounterID == Addon.Constants.GREAT_VAULT_ID
                if isGV1 then return true end
                if isGV2 then return false end
                return enc1.runs > enc2.runs
            end
        end

        -- Overall и Great Vault вставляем до сортировки — компаратор фиксирует их вверху.
        DataProvider:Insert({encounterID = Addon.Constants.OVERALL_ID, runs = overall, fortune = overallFortune, numLoot = overallLoot})
        if greatVaultData then
            DataProvider:Insert(greatVaultData)
        end
        DataProvider:SetSortComparator(SortComparator)
    end

    EncountersFrame:ClearAllPoints()
    EncountersFrame:SetParent(MPLTLootFrame)
    if compact then
        EncountersFrame:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 5, Addon.Constants.Layout.TrackingOffsetY)
        EncountersFrame:SetSize(Addon.Constants.Layout.CompactContentWidth, 401)
        -- Скрываем декоративные текстуры полного вида.
        if EncountersFrame.bg then EncountersFrame.bg:Hide() end
        if EncountersFrame.title then EncountersFrame.title:Hide() end
        lootFrame:Hide()
    else
        EncountersFrame:SetPoint("TOPRIGHT", MPLTLootFrame, "TOPRIGHT", -19, -120)
        EncountersFrame:SetSize(290, 347)
        -- Возвращаем декоративные текстуры полного вида.
        if EncountersFrame.bg then EncountersFrame.bg:Show() end
        if EncountersFrame.title then EncountersFrame.title:Show() end
        -- Восстанавливаем список предметов: показываем фрейм и заполняем Overall.
        lootFrame:Show()
        MythicPlusLootTrackerLuckElementMixin:PrepareLootList(Addon.Constants.OVERALL_ID, playerID)
    end
    EncountersFrame:Show()
    EncountersFrame:SetAlpha(1)
end