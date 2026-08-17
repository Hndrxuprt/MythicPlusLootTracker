local AddonName, Addon = ...

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

function Addon.IsValueInTable(table, searchValue)
    for key, value in pairs(table) do
        if value == searchValue then
            return true, key
        end
    end
    return false
end

function Addon.CopyTable(tbl)
    local tblType = type(tbl)
    local tblCopy
    if tblType == "table" then
        tblCopy = {}
        for k, v in pairs(tbl) do
            tblCopy[k] = v
        end
    else
        tblCopy = tbl
    end
    return tblCopy
end

function Addon.sortTable(tbl)
    local sorted = {}
    for k, v in pairs(tbl) do
        table.insert(sorted, {k, v})
    end
    table.sort(sorted, function(a, b) return a[2] > b[2] end)
    return sorted
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

local NINE_SLICE_PART_NAMES = { "TopLeftCorner", "TopRightCorner", "TopBorder", "BottomLeftCorner", "BottomRightCorner", "BottomBorder", "LeftBorder", "RightBorder" }

local NINE_SLICE_ATLASES = {
    characterupdate = {
        "characterupdate-9slice-topleftcorner",
        "characterupdate-9slice-toprightcorner",
        "_characterupdate-9slice-topedge",
        "characterupdate-9slice-bottomleftcorner",
        "characterupdate-9slice-bottomrightcorner",
        "_characterupdate-9slice-bottomedge",
        "!characterupdate-9slice-leftedge",
        "!characterupdate-9slice-rightedge",
    },
    tooltipMaw = {
        "Tooltip-Maw-NineSlice-CornerTopLeft",
        "Tooltip-Maw-NineSlice-CornerTopRight",
        "_Tooltip-Maw-NineSlice-EdgeTop",
        "Tooltip-Maw-NineSlice-CornerBottomLeft",
        "Tooltip-Maw-NineSlice-CornerBottomRight",
        "_Tooltip-Maw-NineSlice-EdgeBottom",
        "!Tooltip-Maw-NineSlice-EdgeLeft",
        "!Tooltip-Maw-NineSlice-EdgeRight",
    },
}

function Addon.SetNineSlice(frame, atlasKey, r, g, b, a)
    local atlases = NINE_SLICE_ATLASES[atlasKey]
    for i, part in ipairs(NINE_SLICE_PART_NAMES) do
        frame[part]:SetAtlas(atlases[i], true)
        frame[part]:SetVertexColor(r, g, b, a)
    end
end

function Addon.SetBorderColor(frame, r, g, b, a)
    for _, part in ipairs(NINE_SLICE_PART_NAMES) do
        frame[part]:SetVertexColor(r, g, b, a)
    end
end