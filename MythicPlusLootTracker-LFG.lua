local AddonName, Addon = ...

local fontStrings = {}
local function GetOrCreateFontString(self)
    local fontString = fontStrings[self]
    if fontString == nil then
        fontString = self:CreateFontString("FontString", "Overlay", "NumberFont_Shadow_Small")
        fontString:SetParent(self.DataDisplay)
        fontString:SetPoint("TOPLEFT", self.DataDisplay, "BOTTOMLEFT", 23, 1)
        fontString:SetTextScale(0.85)
        fontString:SetJustifyH("RIGHT")

        fontStrings[self] = fontString
    end
    return fontString
end

local function PrepareNumItems(parentFrame)
    local fontString = GetOrCreateFontString(parentFrame)

    fontString:Hide()

    if LFGListFrame.CategorySelection.selectedCategory ~= GROUP_FINDER_CATEGORY_ID_DUNGEONS then
        return
    end

    local function GetSearchResultMapID(resultID)
        local resultInfo = C_LFGList.GetSearchResultInfo(resultID)
        if not resultInfo then return end
        local activityID = resultInfo.activityIDs[1]
        local mapID = Addon.ActivityID[activityID]
        return mapID, resultInfo.isDelisted, activityID
    end
    local resultID = parentFrame.resultID
    
    local mapID, delisted = GetSearchResultMapID(resultID)

    if LFGListFrame:IsVisible() then
        local playerID = Addon.GetPlayerID()
        local text = 0
        if MPLH_TRACKITEM[playerID] and MPLH_TRACKITEM[playerID][mapID] then
            text = Addon.GetTableLength(MPLH_TRACKITEM[playerID][mapID])
        end

        local dataParent = select(2,parentFrame.DataDisplay:GetPoint())
        parentFrame.DataDisplay:SetPoint("TOPRIGHT", dataParent, "TOPRIGHT", 0, -2)

        if text < 1 then
            fontString:SetTextColor(0.9, 0.5, 0.5)
        elseif text < 3 then
            fontString:SetTextColor(0.9, 0.9, 0.5)
        elseif text >= 3 then 
            fontString:SetTextColor(0.5, 0.9, 0.5)
        end
        if delisted then
            fontString:SetTextColor(0.3, 0.3, 0.3)
        end
        text = text.." items"
        fontString:SetText(text)
        fontString:Show()
    end
end

local function OnLFGListSearchEntryUpdate(self)
    if LFGListFrame then
        PrepareNumItems(self)
    end
end

hooksecurefunc("LFGListSearchEntry_Update", OnLFGListSearchEntryUpdate)