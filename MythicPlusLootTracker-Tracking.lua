local AddonName, Addon = ...

MPLT_TrackingElementMixin = {}

local TrackingFrame = CreateFrame("Frame", "MPLTTrackingFrame", UIParent, "ScrollBoxSelectorTemplate") --ScrollBoxSelectorTemplate

local TrackingDataProvider = CreateDataProvider()

local GRID_DIRECTION = GridLayoutMixin.Direction.TopLeftToBottomRight;
local GRID_STRIDE    = 1;
local GRID_PADDING_X = 2;
local GRID_PADDING_Y = 2;

local gridLayout = AnchorUtil.CreateGridLayout(GRID_DIRECTION, GRID_STRIDE, GRID_PADDING_X, GRID_PADDING_Y)

function MPLT_TrackingElementMixin:InitElements(frame, elementData, playerID)
    local encounterID = elementData.encounterID
    local dungeonName = select(1,GetEncounter(encounterID))
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
        MPLT_UpdateSubFrames()
    end)
    local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", frame.EncounterContainer.Highlight, "BOTTOMLEFT", 70, 30)
    AnchorUtil.GridLayout(elementData.children[elementData.encounterID], initialAnchor, gridLayout)
    frame.EncounterContainer:SetHeight(100+60*#elementData.children[elementData.encounterID])
end

function MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
    local scrollPos = TrackingFrame.ScrollBar:GetScrollPercentage()
    TrackingDataProvider:Flush()

    local view = CreateScrollBoxListLinearView(0, 0, 2, 2, 0);
    local function CalculateHeight()
        return 100 + 60*#children
    end
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
    ScrollUtil.InitScrollBoxListWithScrollBar(TrackingFrame.ScrollBox, TrackingFrame.ScrollBar, view)
    TrackingFrame.ScrollBox:Init(view)
    TrackingFrame.ScrollBox:SetInterpolateScroll(true)
    TrackingFrame.ScrollBar:SetInterpolateScroll(true)
    TrackingFrame.ScrollBox:SetPanExtent(60)
    if MPLH_TRACKITEM_ORDER[playerID] then
        for i = 1, #_G["MPLH_TRACKITEM_ORDER"][playerID] do
            local encounterID = _G["MPLH_TRACKITEM_ORDER"][playerID][i]
            local children = {}
            for n = 1, #_G["MPLH_TRACKEDITEM_ITEMORDER"][playerID][encounterID] do
                local itemElementFrame = CreateFrame("Frame", "ItemElementFrame".."_"..encounterID, nil, "MPLT_TrackingItemElementTemplate")
                itemElementFrame:Show()
                local itemID = _G["MPLH_TRACKEDITEM_ITEMORDER"][playerID][encounterID][n]
                local item = Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    local itemLink = select(1,RecreateItemLink(item:GetItemLink()))
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
                    local dateSince = _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["dateSince"]
                    local attempts = _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["attempts"]
                    local chances = _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["chances"]
                    local doneDate = _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["done"]["date"]
                    local doneChance = _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["done"]["chance"]
                    local doneAttempts = _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["done"]["attempts"]
                    itemElementFrame.ItemContainer.ItemSince:SetText(Addon.localization.since.."|cffd9d7d7"..dateSince)
                    itemElementFrame.ItemContainer.ItemAttempts:SetText(Addon.localization.attempts.."|cffd9d7d7"..attempts)
                    itemElementFrame.ItemContainer.ItemChances:SetText(Addon.localization.chance.."|cffd9d7d7"..chances+(chances*attempts).."%")

                    if _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["done"]["done"] == 1 then
                        local doneText = ""
                        if _G["MPLH_TRACKITEM"][playerID][encounterID][itemID]["done"]["traded"] == 1 then
                            doneText = Addon.localization.got1..Addon.localization.gotTraded.."|cffd9d7d7"..doneDate
                                ..Addon.localization.got2.."|cffd9d7d7"..doneAttempts..Addon.localization.got3
                                ..Addon.localization.gotChance.."|cffd9d7d7"..(doneChance*doneAttempts).."%"
                        else
                            doneText = Addon.localization.got1.."|cffd9d7d7"..doneDate
                                ..Addon.localization.got2.."|cffd9d7d7"..doneAttempts..Addon.localization.got3
                                ..Addon.localization.gotChance.."|cffd9d7d7"..(doneChance*doneAttempts).."%"
                        end
                        itemElementFrame.ItemDone:Show()
                        itemElementFrame.ItemDone.ItemDoneText:SetText("|cffd9d7d7"..doneText)
                    end
                    itemElementFrame.RemoveItem:SetScript("OnClick", function()
                        if #_G["MPLH_TRACKEDITEM_ITEMORDER"][playerID][encounterID] > 1 then
                            tDeleteItem(MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID], itemID)
                            MPLH_TRACKITEM[playerID][encounterID][itemID] = nil
                        else
                            MPLH_TRACKEDITEM_ITEMORDER[playerID][encounterID] = nil
                            MPLH_TRACKITEM[playerID][encounterID] = nil
                            tDeleteItem(MPLH_TRACKITEM_ORDER[playerID], encounterID)
                        end
                        self:PrepareTrackingList(playerID)
                        MPLT_UpdateSubFrames()
                    end)
                end)
                if not children[encounterID] then
                    children[encounterID] = {}
                end
                table.insert(children[encounterID], itemElementFrame)
            end
            TrackingDataProvider:Insert({encounterID = encounterID, children = children})
        end
        TrackingFrame.ScrollBox:SetDataProvider(TrackingDataProvider)
    end
    TrackingFrame.ScrollBar:SetScrollPercentage(scrollPos, true)
    TrackingFrame:ClearAllPoints()
    TrackingFrame:SetParent(MPLTLootFrame)
    TrackingFrame:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 5, -65)
    TrackingFrame:SetSize(775, 401)
    TrackingFrame:Hide()
    TrackingFrame:SetAlpha(1)
end