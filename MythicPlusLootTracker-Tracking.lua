local AddonName, Addon = ...

MPLT_TrackingElementMixin = {}

local TrackingFrame = CreateFrame("Frame", "MPLTTrackingFrame", UIParent, "ScrollBoxSelectorTemplate") --ScrollBoxSelectorTemplate

local TrackingDataProvider = CreateDataProvider()

local GRID_DIRECTION = GridLayoutMixin.Direction.TopLeftToBottomRight;
local GRID_STRIDE    = 1;
local GRID_PADDING_X = 2;
local GRID_PADDING_Y = 2;

local gridLayout = AnchorUtil.CreateGridLayout(GRID_DIRECTION, GRID_STRIDE, GRID_PADDING_X, GRID_PADDING_Y)

-- Compact layout: иконки выкладываются сеткой 6 в ряд справа от названия подземелья.
local COMPACT_STRIDE    = 6
local COMPACT_ITEM_W    = 32
local COMPACT_ITEM_H    = 52
local COMPACT_PADDING_X = 2
local COMPACT_PADDING_Y = 2
local COMPACT_ICON_ANCHOR_X = 172 -- X-отступ от левого края строки до первой иконки
local COMPACT_ICON_ANCHOR_Y = -2
local COMPACT_ROW_PAD    = 0     -- отступ над/под содержимым строки
local compactGridLayout = AnchorUtil.CreateGridLayout(GRID_DIRECTION, COMPACT_STRIDE, COMPACT_PADDING_X, COMPACT_PADDING_Y)

function MPLT_TrackingElementMixin:InitElements(frame, elementData, playerID)
    local encounterID = elementData.encounterID
    Addon.SetNineSlice(frame.EncounterContainer, "tooltipMaw", 1, 0.7, 0.7, 0.6)
    local dungeonName = select(1,Addon.GetEncounter(encounterID))
    frame.EncounterContainer.EncounterText:SetText(dungeonName)
    frame.EncounterContainer.EncounterText:SetTextScale(0.6)
    local children = elementData.children
    for _, f in pairs(children[encounterID]) do
        local frameName, encID = strsplit("_", f:GetDebugName(), 2)
        if frameName == "ItemElementFrame" and tonumber(encID) == elementData.encounterID then
            f:SetParent(frame)
            f:SetSize(400,60)
            f:Show()
        end
    end
    frame.RemoveEnc:SetScript("OnClick", function()
        tDeleteItem(MPLH_TRACKITEM_ORDER[playerID], encounterID)
        MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] = nil
        MPLH_TRACKITEM[playerID][encounterID] = nil
        self:PrepareTrackingList(playerID)
        Addon.UpdateSubFrames()
    end)
    local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", frame.EncounterContainer.Highlight, "BOTTOMLEFT", 70, 30)
    AnchorUtil.GridLayout(elementData.children[elementData.encounterID], initialAnchor, gridLayout)
    frame.EncounterContainer:SetHeight(100+60*#elementData.children[elementData.encounterID])
end

function MPLT_TrackingElementMixin:InitCompactElements(frame, elementData, playerID)
    local encounterID = elementData.encounterID
    local dungeonName = select(1, Addon.GetEncounter(encounterID))
    frame.EncounterText:SetText(dungeonName)
    frame.EncounterText:SetTextScale(1.2)

    -- Цвет названия: CAMPAIGN_COMPLETE_COLOR (глобальный ColorMixin из клиента).
    if CAMPAIGN_COMPLETE_COLOR then
        frame.EncounterText:SetTextColor(CAMPAIGN_COMPLETE_COLOR:GetRGB())
    end

    -- Количество попыток в подземелье: attempts хранится per-item, но одинаково
    -- для всех трекаемых предметов данжа (инкрементится на CHALLENGE_MODE_COMPLETED).
    -- Берём attempts первого предмета данжа; для сентинелов — 0.
    local dungeonAttempts = 0
    local itemOrder = MPLH_TRACKEDITEM_ITEMORDER[playerID] and MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID]
    if itemOrder and itemOrder[1] then
        local rec = MPLH_TRACKITEM[playerID][encounterID] and MPLH_TRACKITEM[playerID][encounterID][itemOrder[1]]
        if rec then
            dungeonAttempts = rec["attempts"] or 0
        end
    end
    if frame.AttemptsText then
        frame.AttemptsText:SetText(Addon.localization.attempts..dungeonAttempts)
        frame.AttemptsText:SetTextScale(1.4)
        -- Почти белый цвет попыток.
        frame.AttemptsText:SetTextColor(0.8, 0.8, 0.8, 1)
    end

    -- Зебра + рамка строки: чередуем фон по индексу подземелья в списке.
    local dataIndex = elementData.dataIndex or 1
    local zebra = (dataIndex % 2 == 0)
    if zebra then
        frame.RowBG:SetVertexColor(0.18, 0.18, 0.20, 0.55)
    else
        frame.RowBG:SetVertexColor(0.10, 0.10, 0.12, 0.45)
    end
    -- Рамка-разделитель — четыре текстуры по периметру (XML), цвет задаём здесь.
    local border = { frame.RowBorderTop, frame.RowBorderBottom, frame.RowBorderLeft, frame.RowBorderRight }
    for _, tex in ipairs(border) do
        if tex then tex:SetVertexColor(0.35, 0.35, 0.38, 0.6) end
    end

    -- Удаление всего подземелья из отслеживания.
    if frame.RemoveEnc then
        frame.RemoveEnc:SetScript("OnClick", function()
            tDeleteItem(MPLH_TRACKITEM_ORDER[playerID], encounterID)
            MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] = nil
            MPLH_TRACKITEM[playerID][encounterID] = nil
            self:PrepareTrackingList(playerID)
            Addon.UpdateSubFrames()
        end)
    end

    -- Полупрозрачный фон подземелья из EncounterJournal с маской.
    -- Для Great Vault — отдельная текстура.
    if frame.DungeonBG and frame.DungeonMask then
        local bgImage
        if encounterID == Addon.Constants.GREAT_VAULT_ID then
            bgImage = nil -- используется атлас ниже
            frame.DungeonBG:SetAtlas("talenttree-TitanConsole-background")
            frame.DungeonBG:SetVertexColor(1, 1, 1, 0.35)
            frame.DungeonBG:Show()
            if C_Texture.GetAtlasInfo("glues-characterSelect-GS-TopHUD-right") then
                frame.DungeonMask:SetAtlas("glues-characterSelect-GS-TopHUD-right", true)
            end
            frame.DungeonBG:AddMaskTexture(frame.DungeonMask)
        else
            bgImage = Addon.GetDungeonBackground(encounterID)
            if bgImage then
                frame.DungeonBG:SetTexture(bgImage)
                frame.DungeonBG:SetVertexColor(1, 1, 1, 0.35)
                frame.DungeonBG:Show()
                if C_Texture.GetAtlasInfo("glues-characterSelect-GS-TopHUD-right") then
                    frame.DungeonMask:SetAtlas("glues-characterSelect-GS-TopHUD-right", true)
                end
                frame.DungeonBG:AddMaskTexture(frame.DungeonMask)
            else
                frame.DungeonBG:Hide()
            end
        end
    end

    local children = elementData.children
    for _, f in pairs(children[encounterID]) do
        local frameName = strsplit("_", f:GetDebugName(), 2)
        if frameName == "CompactItemFrame" then
            f:SetParent(frame)
            f:Show()
        end
    end

    -- Вертикально центрируем блок иконок по высоте строки: строка = PAD + ITEM_H*rows + PAD,
    -- блок занимает ITEM_H*rows, значит верхний отступ = PAD = (строка - блок)/2.
    local count = #elementData.children[elementData.encounterID]
    local rows = math.ceil(count / COMPACT_STRIDE)
    local blockH = COMPACT_ITEM_H * rows
    local rowExtent = COMPACT_ROW_PAD + blockH + COMPACT_ROW_PAD
    local centerY = -((rowExtent - blockH) / 2)
    local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", frame, "TOPLEFT", COMPACT_ICON_ANCHOR_X, centerY)
    AnchorUtil.GridLayout(elementData.children[elementData.encounterID], initialAnchor, compactGridLayout)
end

function MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
    local compact = Addon.DB and Addon.DB.global and Addon.DB.global.compactView
    local scrollPos = TrackingFrame.ScrollBar:GetScrollPercentage()
    TrackingDataProvider:Flush()

    local view = CreateScrollBoxListLinearView(0, 0, 2, 2, -1);
    local function CalculateHeight()
        return 100 + 60*#children
    end
    if compact then
        view:SetElementExtentCalculator(function(dataIndex, elementData)
            local count = #elementData.children[elementData.encounterID]
            local rows = math.ceil(count / COMPACT_STRIDE)
            return COMPACT_ROW_PAD + COMPACT_ITEM_H * rows + COMPACT_ROW_PAD
        end)
        view:SetElementInitializer("MPLT_TrackingCompactEncounterElementTemplate", function(frame, elementData)
            MPLT_TrackingElementMixin:InitCompactElements(frame, elementData, playerID)
        end)
        view:SetElementResetter(function(frame, elementData)
            local children = {frame:GetChildren()}
            for _, child in ipairs(children) do
                local frameName = strsplit("_", child:GetDebugName(), 2)
                if frameName == "CompactItemFrame" then
                    child:Hide()
                end
            end
        end)
    else
        view:SetElementExtentCalculator(function(dataIndex, elementData)
            local height = #elementData.children[elementData.encounterID]
            return 100 + 60*height
        end)
        view:SetElementInitializer("MPLT_TrackingEncounterElementTemplate", function(frame, elementData)
            MPLT_TrackingElementMixin:InitElements(frame, elementData, playerID)
        end)
        view:SetElementResetter(function(frame, elementData)
            local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", frame.EncounterContainer.Highlight, "BOTTOMLEFT", 70, 30)
            AnchorUtil.GridLayout(elementData.children[elementData.encounterID], initialAnchor, gridLayout)
            local children = {frame:GetChildren()}

            for i, child in ipairs(children) do
                local frameName, encID = strsplit("_", child:GetDebugName(), 2)
                if frameName == "ItemElementFrame" then
                    child:Hide()
                end
            end
        end)
    end
    ScrollUtil.InitScrollBoxListWithScrollBar(TrackingFrame.ScrollBox, TrackingFrame.ScrollBar, view)
    TrackingFrame.ScrollBox:Init(view)
    TrackingFrame.ScrollBox:SetInterpolateScroll(true)
    TrackingFrame.ScrollBar:SetInterpolateScroll(true)
    TrackingFrame.ScrollBox:SetPanExtent(60)
    if MPLH_TRACKITEM_ORDER[playerID] then
        for i = 1, #MPLH_TRACKITEM_ORDER[playerID] do
            local encounterID = MPLH_TRACKITEM_ORDER[playerID][i]
            local children = {}
            -- В компактном виде полученные (done) предметы идут в начале списка иконок.
            local orderedItems
            if compact then
                local doneItems, restItems = {}, {}
                for n = 1, #MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] do
                    local id = MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID][n]
                    local rec = MPLH_TRACKITEM[playerID][encounterID][id]
                    if rec and rec["done"] and rec["done"]["done"] == 1 then
                        table.insert(doneItems, id)
                    else
                        table.insert(restItems, id)
                    end
                end
                orderedItems = {}
                for _, id in ipairs(doneItems) do table.insert(orderedItems, id) end
                for _, id in ipairs(restItems) do table.insert(orderedItems, id) end
            else
                orderedItems = MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID]
            end
            for n = 1, #orderedItems do
                local itemID = orderedItems[n]
                if compact then
                    local itemElementFrame = CreateFrame("Frame", "CompactItemFrame".."_"..encounterID.."_"..n, nil, "MPLT_TrackingCompactItemElementTemplate")
                    itemElementFrame:EnableMouse(true)
                    itemElementFrame:Show()
                    local item = Item:CreateFromItemID(itemID)
                    item:ContinueOnItemLoad(function()
                        local itemLink = select(1,Addon.RecreateItemLink(item:GetItemLink()))
                        itemElementFrame.icon:SetTexture(item:GetItemIcon())
                        itemElementFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                        itemElementFrame:SetScript("OnEnter",
                            function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -50, 57)
                                GameTooltip:SetHyperlink(itemLink)
                                GameTooltip:Show()
                            end
                        )
                        -- Правый клик по иконке — удалить предмет из отслеживания.
                        itemElementFrame:SetScript("OnMouseUp", function(self, button)
                            if button == "RightButton" then
                                if #MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] > 1 then
                                    tDeleteItem(MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID], itemID)
                                    MPLH_TRACKITEM[playerID][encounterID][itemID] = nil
                                else
                                    MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] = nil
                                    MPLH_TRACKITEM[playerID][encounterID] = nil
                                    tDeleteItem(MPLH_TRACKITEM_ORDER[playerID], encounterID)
                                end
                                MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
                                Addon.UpdateSubFrames()
                            end
                        end)
                        local attempts = MPLH_TRACKITEM[playerID][encounterID][itemID]["attempts"]
                        local chances = tonumber(MPLH_TRACKITEM[playerID][encounterID][itemID]["chances"] or 0)
                        local done = MPLH_TRACKITEM[playerID][encounterID][itemID]["done"]
                        if done["done"] == 1 then
                            local doneChance = done["chance"]
                            if type(doneChance) == "string" then
                                doneChance = (tonumber(doneChance) or 0) * done["attempts"]
                            end
                            itemElementFrame.Chance:SetText("|cff4cff00"..string.format("%.1f%%", doneChance).."|r")
                        else
                            itemElementFrame.Chance:SetText(Addon.Constants.Color.TextLight..string.format("%.1f%%", chances + (chances*attempts)))
                        end
                    end)
                    if not children[encounterID] then
                        children[encounterID] = {}
                    end
                    table.insert(children[encounterID], itemElementFrame)
                else
                    local itemElementFrame = CreateFrame("Frame", "ItemElementFrame".."_"..encounterID, nil, "MPLT_TrackingItemElementTemplate")
                    itemElementFrame:Show()
                    local item = Item:CreateFromItemID(itemID)
                    item:ContinueOnItemLoad(function()
                        local itemLink = select(1,Addon.RecreateItemLink(item:GetItemLink()))
                        itemElementFrame.ItemContainer.icon:SetTexture(item:GetItemIcon())
                        itemElementFrame.ItemContainer.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                        itemElementFrame.ItemContainer.ItemText:SetText(itemLink)

                        itemElementFrame.ItemContainer:SetScript("OnEnter",
                            function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -50, 57)
                                GameTooltip:SetHyperlink(itemLink)
                                GameTooltip:Show()
                            end
                        )
                        local dateSince = MPLH_TRACKITEM[playerID][encounterID][itemID]["dateSince"]
                        local attempts = MPLH_TRACKITEM[playerID][encounterID][itemID]["attempts"]
                        local chances = tonumber(MPLH_TRACKITEM[playerID][encounterID][itemID]["chances"] or 0)
                        local doneDate = MPLH_TRACKITEM[playerID][encounterID][itemID]["done"]["date"]
                        local doneChance = MPLH_TRACKITEM[playerID][encounterID][itemID]["done"]["chance"]
                        local doneAttempts = MPLH_TRACKITEM[playerID][encounterID][itemID]["done"]["attempts"]
                        -- Старые записи хранили базовый шанс строкой без множителя попыток;
                        -- новые — числом, уже с учётом попыток на момент получения.
                        if type(doneChance) == "string" then
                            doneChance = (tonumber(doneChance) or 0) * doneAttempts
                        end
                        itemElementFrame.ItemContainer.ItemSince:SetText(Addon.localization.since..Addon.Constants.Color.TextLight..dateSince)
                        itemElementFrame.ItemContainer.ItemAttempts:SetText(Addon.localization.attempts..Addon.Constants.Color.TextLight..attempts)
                        itemElementFrame.ItemContainer.ItemChances:SetText(Addon.localization.chance..Addon.Constants.Color.TextLight..chances+(chances*attempts).."%")

                        if MPLH_TRACKITEM[playerID][encounterID][itemID]["done"]["done"] == 1 then
                            local traded = MPLH_TRACKITEM[playerID][encounterID][itemID]["done"]["traded"] == 1
                            local doneTemplate = traded and Addon.localization.doneTraded or Addon.localization.done
                            local doneText = string.format(doneTemplate, doneDate, doneAttempts, doneChance)
                            itemElementFrame.ItemDone:Show()
                            itemElementFrame.ItemDone.ItemDoneText:SetText(Addon.Constants.Color.TextLight..doneText)
                        end
                        itemElementFrame.RemoveItem:SetScript("OnClick", function()
                            if #MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] > 1 then
                                tDeleteItem(MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID], itemID)
                                MPLH_TRACKITEM[playerID][encounterID][itemID] = nil
                            else
                                MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] = nil
                                MPLH_TRACKITEM[playerID][encounterID] = nil
                                tDeleteItem(MPLH_TRACKITEM_ORDER[playerID], encounterID)
                            end
                            self:PrepareTrackingList(playerID)
                            Addon.UpdateSubFrames()
                        end)
                    end)
                    if not children[encounterID] then
                        children[encounterID] = {}
                    end
                    table.insert(children[encounterID], itemElementFrame)
                end
            end
            TrackingDataProvider:Insert({encounterID = encounterID, children = children, dataIndex = i})
        end
        TrackingFrame.ScrollBox:SetDataProvider(TrackingDataProvider)
    end
    TrackingFrame.ScrollBar:SetScrollPercentage(scrollPos, true)
    TrackingFrame:ClearAllPoints()
    TrackingFrame:SetParent(MPLTLootFrame)
    TrackingFrame:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 5, Addon.Constants.Layout.TrackingOffsetY)
    if compact then
        TrackingFrame:SetSize(Addon.Constants.Layout.CompactContentWidth, 401)
    else
        TrackingFrame:SetSize(Addon.Constants.Layout.ContentWidth, 401)
    end
    TrackingFrame:Hide()
    TrackingFrame:SetAlpha(1)
end