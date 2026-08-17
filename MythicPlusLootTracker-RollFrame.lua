local AddonName, Addon = ...

function Addon.GetUnitColoredName(name)
    local _, class = UnitClass(name)
    if class then
        local classColor = RAID_CLASS_COLORS[class].colorStr
        name = C_ColorUtil.WrapTextInColorCode(name, classColor)
    end
    return name
end

local function GetRollColor(value)
    local min = 1
    local max = 100
    local ratio = (value - min) / (max - min)
    
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end
    
    local hue = ratio * 120
    
    local r, g, b = C_ColorUtil.ConvertHSVToRGB(hue, 1, 1)
    
    local color = CreateColor(r, g, b)
    return C_ColorUtil.WrapTextInColor(value, color)
end

MPLT_RollFrameMixin = {}

MPLT_RollFrameMixin.onCloseCallback = function()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    wipe(Addon.itemRolls)
    return true
end

MPLT_RollFrameRowMixin = {}
MPLT_RollOfferButtonMixin = {}
MPLT_RollAnimMixin = {}

function MPLT_RollAnimMixin:OnFinished()
    local callback = self:GetParent().AnimCallback
    if callback then
        callback()
    end
end

function MPLT_RollOfferButtonMixin:OnClick()
    local itemLink = Addon.itemRolls.itemLink
    if not itemLink then return end
    local chatType = "PARTY"
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        chatType = 'INSTANCE_CHAT'
    end
    C_ChatInfo.SendChatMessage(itemLink.." roll", chatType)
end

local rollFrame = CreateFrame("Frame", "RollFrame", nil, "MPLT_RollFrameTemplate")
rollFrame:SetParent(UIParent)
rollFrame:SetPoint("LEFT", UIParent, "LEFT", 10, -150)
rollFrame:SetSize(260, 140)
rollFrame.ScrollBox.Shadows:Hide()
rollFrame:SetMovable(true)
rollFrame:EnableMouse(true)
rollFrame:SetClipsChildren(true)
rollFrame:RegisterForDrag("LeftButton")
rollFrame:SetScript("OnShow", function(self)
    rollFrame.autoclose = true
end)
rollFrame:SetScript("OnHide", function(self)
    rollFrame.autoclose = true
end)
rollFrame:SetScript("OnDragStart", function(self, button)
    self:StartMoving()
end)
rollFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
rollFrame:SetScript("OnEnter", function(self)
    if MPLT_RollFrameMixin.timer then
        rollFrame.TimerAnim:Stop()
        rollFrame.AutocloseText:SetAlpha(0)
        rollFrame.autoclose = false
        MPLT_RollFrameMixin.timer:Cancel()
        MPLT_RollFrameMixin.timer = nil
    end
end)
rollFrame:SetTitle("")
rollFrame:SetFrameStrata("HIGH")
rollFrame.AutocloseText:SetText(Addon.localization.snifferAutoclose)

rollFrame:Show()

MPLT_RollFrameMixin.DataProvider = CreateDataProvider()

function MPLT_RollFrameMixin:Autoclose()
    if not rollFrame.autoclose then
        return
    end

    if self.timer then
        rollFrame.TimerAnim:Stop()
        self.timer:Cancel()
        self.timer = nil
    end

    rollFrame.TimerAnim:Restart()

    self.timer = C_Timer.NewTimer(10, function()
        rollFrame:Hide()
        rollFrame:SetAlpha(0)
        self.timer:Cancel()
        self.timer = nil
    end)
end
function MPLT_RollFrameMixin:StopAutoclose()
    if self.timer then
        rollFrame.TimerAnim:Stop()
        rollFrame.AutocloseText:SetAlpha(0)
        rollFrame.autoclose = false
        self.timer:Cancel()
        self.timer = nil
    end
end

function MPLT_RollFrameMixin:PrepareScrollFrame()
    self.DataProvider:Flush()
    if not view then
        local view = CreateScrollBoxListLinearView()
        view:SetPadding(6, 4, 4, 20, 2)
        view:SetElementExtent(26)
        view:SetElementInitializer("MPLT_RollFrameRowTemplate", function(frame, elementData)
            MPLT_RollFrameMixin:Update(frame, elementData)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(rollFrame.ScrollBox, rollFrame.ScrollBar, view)
        rollFrame.ScrollBox:Init(view)
        rollFrame.ScrollBox:SetInterpolateScroll(true)
        rollFrame.ScrollBar:SetInterpolateScroll(true)

        ScrollUtil.RegisterAlternateRowBehavior(rollFrame.ScrollBox, function(frame, alternate)
            if not self.hideStripes then
                frame:GetNormalTexture():SetAtlas(alternate and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2")
            end
        end)
        rollFrame.ScrollBox:SetDataProvider(self.DataProvider)
    end

    if Addon.itemRolls.rolls then
        for name, roll in pairs(Addon.itemRolls.rolls) do
            self.DataProvider:Insert({ name = name, roll = roll })
        end
    end

    local function SortByRoll(data1, data2)
        return data1.roll > data2.roll
    end

    self.DataProvider:SetSortComparator(SortByRoll)
end

function MPLT_RollFrameMixin:Update(frame, elementData)
    local itemLink = Addon.itemRolls.itemLink
    local name = elementData.name
    local roll = elementData.roll
    Addon.itemRolls.shown = Addon.itemRolls.shown or {}
    local animShown = Addon.itemRolls.shown[name] or false

    local function SetRowData()
        frame.RollFrame.RollName:SetText(Addon.GetUnitColoredName(name))
        frame.RollFrame.RollAmount:SetText(GetRollColor(roll))

        if not animShown then
            frame.NeedRollAnim:Show()
            frame.NeedRollAnim.Animation:Restart()
            frame.NeedRollAnim.AnimCallback = function()
                frame.RollFrame.Animation:Restart()
                Addon.itemRolls.shown[name] = true
            end
        else
            frame.RollFrame:Show()
            frame.RollFrame.RollAmount:SetAlpha(1)
        end
        
        frame.TradeButton:SetScript("OnClick", function(self)
            local bag, slot = Addon.FindItemInBags(itemLink)
            if bag and slot then
                C_Container.PickupContainerItem(bag, slot)
            end
            if CursorHasItem() then
                C_Item.DropItemOnUnit(name)
            end
        end)
    end

    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()         
            SetRowData()
        end)
    else
        SetRowData()
    end
end

function MPLT_RollFrameMixin:Init()
    self:PrepareScrollFrame()
    if not rollFrame:IsVisible() then
        rollFrame:Show()
        rollFrame:SetAlpha(1)
    end
    self:Autoclose()
end

local body = RANDOM_ROLL_RESULT:sub(3)

local patternBody = body:gsub("([%(%)])", "%%%1"):gsub("%%d", "(%%d+)")

local rollPattern = "^(.*)" .. patternBody .. "$"

Addon.itemRolls = {}

local latestItem

function Addon.RollForItem(itemID, itemLink)
    if not itemID then return end

    wipe(Addon.itemRolls)

    Addon.itemRolls.itemID = itemID
    Addon.itemRolls.itemLink = itemLink

    local itemTexture = C_Item.GetItemIconByID(itemLink)
    rollFrame.ItemContainer.ItemIcon:SetTexture(itemTexture)
    rollFrame.ItemContainer.ItemLink:SetText(itemLink)
    rollFrame.ItemContainer.ItemLink:SetJustifyH("LEFT")

    rollFrame.ItemContainer.ItemLink:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Show()
    end)
    rollFrame.ItemContainer.ItemLink:SetScript("OnLeave", function(self)
        GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        GameTooltip:Hide()
    end)

    latestItem = itemID

    MPLT_RollFrameMixin:Init()
end

local function ProcessEvent(self, event, ...)
    if event == 'CHAT_MSG_SYSTEM' then
        local msg = ...

        if not msg then return end

        local name, roll, min, max = msg:match(rollPattern)

        if not name then return end

        if tonumber(min) <= 1 and tonumber(max) == 100 then

            if latestItem and latestItem == Addon.itemRolls.itemID then
                if not Addon.itemRolls.rolls then
                    Addon.itemRolls.rolls = {}
                end
                if not Addon.itemRolls.rolls[name] then
                    Addon.itemRolls.rolls[name] = roll
                    if rollFrame:IsVisible() then
                        MPLT_RollFrameMixin:PrepareScrollFrame()
                        MPLT_RollFrameMixin:StopAutoclose()
                    end
                end
            end
        end
        
    end
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent("CHAT_MSG_SYSTEM")