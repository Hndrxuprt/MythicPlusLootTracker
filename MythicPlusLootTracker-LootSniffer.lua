local AddonName, Addon = ...

local function GetSlotID(itemEquipLoc)
	if itemEquipLoc == 'INVTYPE_HEAD' then return INVSLOT_HEAD
	elseif itemEquipLoc == 'INVTYPE_NECK' then return INVSLOT_NECK
	elseif itemEquipLoc == 'INVTYPE_SHOULDER' then return INVSLOT_SHOULDER
	elseif itemEquipLoc == 'BODY' then return INVSLOT_BODY
	elseif itemEquipLoc == 'INVTYPE_CHEST' then return INVSLOT_CHEST
	elseif itemEquipLoc == 'INVTYPE_ROBE' then return INVSLOT_CHEST
	elseif itemEquipLoc == 'INVTYPE_WAIST' then return INVSLOT_WAIST
	elseif itemEquipLoc == 'INVTYPE_LEGS' then return INVSLOT_LEGS
	elseif itemEquipLoc == 'INVTYPE_FEET' then return INVSLOT_FEET
	elseif itemEquipLoc == 'INVTYPE_WRIST' then return INVSLOT_WRIST
	elseif itemEquipLoc == 'INVTYPE_HAND' then return INVSLOT_HAND
	elseif itemEquipLoc == 'INVTYPE_FINGER' then return INVSLOT_FINGER1
	elseif itemEquipLoc == 'INVTYPE_TRINKET' then return INVSLOT_TRINKET1
	elseif itemEquipLoc == 'INVTYPE_CLOAK' then return INVSLOT_BACK
	elseif itemEquipLoc == 'INVTYPE_WEAPON' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_SHIELD' then return INVSLOT_OFFHAND
	elseif itemEquipLoc == 'INVTYPE_2HWEAPON' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_WEAPONMAINHAND' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_WEAPONOFFHAND' then return INVSLOT_OFFHAND
	elseif itemEquipLoc == 'INVTYPE_HOLDABLE' then return INVSLOT_OFFHAND
	elseif itemEquipLoc == 'INVTYPE_RANGED' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_THROWN' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_RANGEDRIGHT' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_TABARD' then return INVSLOT_TABARD
	else return nil
	end
end

local CLASS_ARMOR = {
    ["WARRIOR"] = 4,
	["DEATHKNIGHT"] = 4,
	["PALADIN"] = 4,
	["MONK"] = 2,
	["PRIEST"] = 1,
	["SHAMAN"] = 3,
	["DRUID"] = 2,
	["ROGUE"] = 2,
	["MAGE"] = 1,
	["WARLOCK"] = 1,
	["HUNTER"] = 3,
	["DEMONHUNTER"] = 2,
	["EVOKER"] = 3,
}

local messageText_EN = {
    "Hey! Could you spare this item for me? It would help a lot!",
    "Hi there! Is this item up for grabs? I'd really appreciate it!",
    "Hey mate! Mind passing me this item? It's perfect for my build!",
    "Hello! Any chance I could get this item? Would mean a lot!",
    "Hey! If you don't need this, could I have it? Thanks!",
    "Yo! This item is BIS for me — mind sharing? :D",
    "Hey friend! I'd be super grateful if I could snag this item!",
    "Hello! If this item is spare, I'd happily take it off your hands!",
    "Hey! Any way I could get this item? It's exactly what I need!",
    "Hi! Do you need this? If not, I'd love to have it!",
    "Hey! Would you consider giving this item to me? Thanks!",
    "Yo! If this item isn't useful to you, I'd gladly take it!",
    "Hello! Mind if I grab this item? It's perfect for my spec!",
    "Hey! Could I have this item? I'll owe you one!",
}
local messageText_RU = {
    "Привет! Не против отдать этот предмет? Он мне очень нужен!",
    "Приветик! Тебе нужна эта шмотка? Если нет, можешь отдать?",
    "Эй, друг! Не отдашь этот итем? Он мне оч нужен!",
    "Привет! Если тебе не нужен этот итем, я бы с радостью взял!",
    "Хей! Можно я заберу эту шмотку? Буду благодарен!",
    "Привет! Это мой бис, не отдашь? :3",
    "Здаров! Если итем лишний, я бы не отказался!",
    "Привет! Могу я взять этот предмет? Очень поможешь!",
    "Эй! Если не нужен, отдай плз, он мне зайдет!",
    "Привет! Не против, если я прикарманю этот предмет?",
    "Йо! Этот итем топ для меня, поделишься?",
    "Привет! Если итем тебе не нужен, я бы взял с радостью!",
    "Хай! Можно этот итем? Он мне прям в тему!",
    "Привет! Отдашь предмет? Буду очень благодарен!",
    "Эй, братик! Если не жалко, отдай этот предмет пжлста >_<",
}
local partyMessage_EN = {
    "do you need it?",
    "you need it?",
    "you need?",
    "can i have pls?",
    "u need?",
    "mind if I take?",
    "u keeping?",
}
local partyMessage_RU = {
    "нужна?",
    "тебе надо?",
    "отдашь?",
    "можешь отдать?",
    "отдашь плз?",
    "дай плз",
    "если не нужна, отдашь?",
}

MPLT_LootSnifferMixin = {}
MPLT_LootSnifferMixin.lootTable = {}

local function IsItemNeeded(itemID)
    local playerID = Addon.GetPlayerID()

    if not (MPLH_TRACKITEM and MPLH_TRACKITEM[playerID]) then
        return false
    end

    for _, data in pairs(MPLH_TRACKITEM[playerID]) do
        local record = data[itemID]
        if record and record["done"] and record["done"]["done"] == 0 then
            return true
        end
    end

    return false
end

local function IsItemValid(itemID)
    local result = TooltipUtil.FindLinesFromGetter({Enum.TooltipDataLineType.EquipSlot}, "GetItemByID", itemID)
    if result then
        for i, lineData in ipairs(result) do
            if lineData.type == Enum.TooltipDataLineType.EquipSlot then
                return lineData.isValidItemType, lineData.isValidInvSlot
            end
        end
    end
end

function IsItemEquippable(itemLink)
    local _, _, _, _, role, primaryStat, _, _, _, _ = GetSpecializationInfo(GetSpecialization())
    local playerPreferredArmor = CLASS_ARMOR[UnitClassBase("player")]

    local function IsEquippable(itemLink)
        local itemName, itemLink, _, _, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _,classID, subclassID, _, _, _, _ = C_Item.GetItemInfo(itemLink)

        if itemEquipLoc == 'INVTYPE_CLOAK' or itemEquipLoc == 'INVTYPE_FINGER' or itemEquipLoc == 'INVTYPE_NECK' then
            return true
        end

        if itemEquipLoc == 'INVTYPE_WEAPON' or
			itemEquipLoc == 'INVTYPE_SHIELD' or
			itemEquipLoc == 'INVTYPE_2HWEAPON' or
			itemEquipLoc == 'INVTYPE_WEAPONMAINHAND' or
			itemEquipLoc == 'INVTYPE_WEAPONOFFHAND' or
			itemEquipLoc == 'INVTYPE_HOLDABLE' or
			itemEquipLoc == 'INVTYPE_RANGED' or
			itemEquipLoc == 'INVTYPE_THROWN' or
			itemEquipLoc == 'INVTYPE_RANGEDRIGHT' then

            local itemStats = C_Item.GetItemStats(itemLink)
            local itemPrimaryStat
            if itemStats then
                for stat, _ in pairs(itemStats) do
                    if _G[stat] == SPEC_STAT_STRINGS[primaryStat] then
                        itemPrimaryStat = _G[stat]
                        return true
                    end
                end
            end
                
            if not itemPrimaryStat then 
                return false 
            end
        end

        if itemEquipLoc == 'INVTYPE_TRINKET' then
            return true
        else
            if classID == Enum.ItemClass.Armor then
                if subclassID == playerPreferredArmor then
                    return true
                else
                    return false
                end
            end
        end
    end

    return IsEquippable(itemLink)
end

function GetItemLevelDiff(itemLink)
    if not GetItemInfoInstant(itemLink) then return end
    local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
    local _, _, _, itemEquipLoc = C_Item.GetItemInfoInstant(itemLink)

    local equippedItem1, equippedItem2
    local slot1, slot2
    
    if itemEquipLoc == 'INVTYPE_FINGER' then
        slot1, slot2 = INVSLOT_FINGER1, INVSLOT_FINGER2
    elseif itemEquipLoc == 'INVTYPE_TRINKET' then
        slot1, slot2 = INVSLOT_TRINKET1, INVSLOT_TRINKET2
    elseif itemEquipLoc == 'INVTYPE_WEAPON' then
        slot1, slot2 = INVSLOT_MAINHAND, INVSLOT_OFFHAND
    else
        slot1 = GetSlotID(itemEquipLoc)
    end
    
    equippedItem1 = slot1 and GetInventoryItemLink("player", slot1)
    equippedItem2 = slot2 and GetInventoryItemLink("player", slot2)
    
    local ilvl1 = equippedItem1 and C_Item.GetDetailedItemLevelInfo(equippedItem1) or 0
    local ilvl2 = equippedItem2 and C_Item.GetDetailedItemLevelInfo(equippedItem2) or 0

    local equippedItemLevel

    if itemEquipLoc == 'INVTYPE_FINGER' or itemEquipLoc == 'INVTYPE_TRINKET' then
        equippedItemLevel = (ilvl1 and ilvl2) and math.min(ilvl1, ilvl2) or (ilvl1 or ilvl2)
    elseif itemEquipLoc == 'INVTYPE_WEAPON' then
        if equippedItem1 then
            local _, _, _, myItemEquipLoc = C_Item.GetItemInfoInstant(equippedItem1)
            if myItemEquipLoc == 'INVTYPE_2HWEAPON' or myItemEquipLoc == 'INVTYPE_WEAPON' or myItemEquipLoc == 'INVTYPE_WEAPONMAINHAND' or myItemEquipLoc == 'INVTYPE_RANGED' or myItemEquipLoc == 'INVTYPE_RANGEDRIGHT'then
                equippedItemLevel = ilvl1
            else
                equippedItemLevel = (ilvl1 and ilvl2) and math.min(ilvl1, ilvl2) or (ilvl1 or ilvl2)
            end
        end
    else
        equippedItemLevel = ilvl1
    end


    
    local diff = itemLevel - equippedItemLevel
    return diff
end

function IsItemUpgrade(itemLink)
    local itemID = GetItemInfoInstant(itemLink)

    local isValidItemType, isValidInvSlot = IsItemValid(itemID)

    if not (isValidItemType and isValidInvSlot) then
        return false
    end

    if not IsItemEquippable(itemLink) then 
        return false 
    end

    local function IsUpgrade(itemLink)

        local itemLevelDiff = GetItemLevelDiff(itemLink)

        if itemLevelDiff > 0 then
            return true
        else
            return false
        end
        
    end

    return IsUpgrade(itemLink)
end

function AskForItem(unitName, itemLink, chatType)
    
    local function isRussianName(name)
        return string.match(name, "[\192-я\241]+") and not string.match(name, "[A-Za-z]")
    end

    local isRu = isRussianName(unitName)
    local tbl

    if chatType == "PARTY" then
        tbl = isRu and partyMessage_RU or partyMessage_EN
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            chatType = 'INSTANCE_CHAT'
        end
    else
        tbl = isRu and messageText_RU or messageText_EN
    end

    local message = tbl[math.random(1,#tbl)].." "..itemLink
    
    C_ChatInfo.SendChatMessage(message, chatType, nil, unitName)
end

local askingFrame = CreateFrame("Frame", "AskingFrame", nil, "MPLT_LootSnifferFrameTemplate")
askingFrame:SetParent(UIParent)
askingFrame:SetPoint("LEFT", UIParent, "LEFT", 10, -150)
askingFrame:SetSize(430, 200)
askingFrame.ScrollBox.Shadows:Hide()
askingFrame:SetMovable(true)
askingFrame:EnableMouse(true)
askingFrame:SetClipsChildren(true)
askingFrame:RegisterForDrag("LeftButton")
askingFrame:SetScript("OnShow", function(self)
    askingFrame.autoclose = true
end)
askingFrame:SetScript("OnHide", function(self)
    askingFrame.autoclose = true
end)
askingFrame:SetScript("OnDragStart", function(self, button)
    self:StartMoving()
end)
askingFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
askingFrame:SetScript("OnEnter", function(self)
    Addon.StopAutoclose(askingFrame, MPLT_LootSnifferMixin)
end)
askingFrame:SetTitle(Addon.localization.snifferTitle)
askingFrame:SetFrameStrata("HIGH")
askingFrame.AutocloseText:SetText(Addon.localization.snifferAutoclose)

askingFrame:Hide()

local DataProvider = CreateDataProvider()
local view

local function AddNewItem(itemLink, unitName, isBis)
    local data = { itemLink = itemLink, owner = unitName, wAsked = false, pAsked = false, isBis = isBis }

    table.insert(MPLT_LootSnifferMixin.lootTable, data)
end

function MPLT_LootSnifferMixin:Init()
    self:PrepareScrollFrame()
    if not askingFrame:IsVisible() then
        askingFrame:Show()
        askingFrame:SetAlpha(1)
    end
    self:Autoclose()
end

function MPLT_LootSnifferMixin:Update(frame, elementData)
    local itemLink = elementData.itemLink
    local itemOwner = elementData.owner
    local myIlvl = elementData.myIlvl
    local itemIlvl = elementData.itemIlvl
    local bisItem = elementData.isBis
    local itemTexture

    local function SetRowData()
        local itemUpgrade = GetItemLevelDiff(itemLink)
        if itemUpgrade then
            itemUpgrade = CreateAtlasMarkup("plunderstorm-icon-small-upgrade", 15, 18)..itemUpgrade --CovenantSanctum-Upgrade-Icon-Available
        end
        if bisItem then
            frame.ItemFrame.BisTexture:Show()
        else
            frame.ItemFrame.BisTexture:Hide()
        end
        itemTexture = C_Item.GetItemIconByID(itemLink)
        

        frame.ItemFrame.ItemIcon:SetTexture(itemTexture)
        frame.ItemFrame.ItemUpgrade:SetText(itemUpgrade)
        frame.ItemFrame.ItemUpgrade:SetTextColor(0.0,1.0,0.0)
        frame.ItemFrame.ItemOwner:SetText(Addon.GetUnitColoredName(itemOwner))
        frame.ItemFrame:SetSize(430, 28)
        frame.ItemFrame.ItemLink:SetText(itemLink)

        frame:SetScript("OnEnter", function(self)
            Addon.CancelAutoclose(askingFrame, MPLT_LootSnifferMixin)
        end)

        frame.ItemFrame.ItemLink:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()

            Addon.CancelAutoclose(askingFrame, MPLT_LootSnifferMixin)
        end)
        frame.ItemFrame.ItemLink:SetScript("OnLeave", function(self)
            GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            GameTooltip:Hide()
        end)

        local index = DataProvider:FindIndex(elementData)
        if MPLT_LootSnifferMixin.lootTable[index] then
            if MPLT_LootSnifferMixin.lootTable[index].wAsked then
                frame.WhisperButton:Disable()
            else
                frame.WhisperButton:Enable()
            end
            if MPLT_LootSnifferMixin.lootTable[index].pAsked then
                frame.PartyButton:Disable()
            else
                frame.PartyButton:Enable()
            end
        else
            frame.WhisperButton:Enable()
            frame.PartyButton:Enable()
        end

        frame.WhisperButton:SetText(Addon.localization.snifferW)
        frame.WhisperButton:SetScript("OnClick", function(self)
            AskForItem(itemOwner, itemLink, "WHISPER")
            frame.WhisperButton:Disable()
            if MPLT_LootSnifferMixin.lootTable[index] then
                MPLT_LootSnifferMixin.lootTable[index].wAsked = true
            end
        end)
        frame.PartyButton:SetText(Addon.localization.snifferP)
        frame.PartyButton:SetScript("OnClick", function(self)
            AskForItem(itemOwner, itemLink, "PARTY")
            frame.PartyButton:Disable()
            if MPLT_LootSnifferMixin.lootTable[index] then
                MPLT_LootSnifferMixin.lootTable[index].pAsked = true
            end
        end)
        frame.ForgetButton:SetScript("OnClick", function(self)
            if MPLT_LootSnifferMixin.lootTable[index] then
                table.remove(MPLT_LootSnifferMixin.lootTable, index)
                DataProvider:RemoveIndex(index)
                MPLT_LootSnifferMixin:PrepareScrollFrame()
            end
        end)
    end
    frame.ItemFrame.ItemLink:SetJustifyH("LEFT")

    Addon.RunOnItemReady(itemLink, SetRowData)
end

function MPLT_LootSnifferMixin:PrepareScrollFrame()
    DataProvider:Flush()
    if not view then
        view = CreateScrollBoxListLinearView()
        view:SetPadding(6, 4, 4, 20, 2)
        view:SetElementExtent(26)
        view:SetElementInitializer("MPLT_LootSnifferRowTemplate", function(frame, elementData)
            MPLT_LootSnifferMixin:Update(frame, elementData)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(askingFrame.ScrollBox, askingFrame.ScrollBar, view)
        askingFrame.ScrollBox:Init(view)
        askingFrame.ScrollBox:SetInterpolateScroll(true)
        askingFrame.ScrollBar:SetInterpolateScroll(true)

        ScrollUtil.RegisterAlternateRowBehavior(askingFrame.ScrollBox, function(frame, alternate)
            if not self.hideStripes then
                frame:GetNormalTexture():SetAtlas(alternate and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2")
            end
        end)
        askingFrame.ScrollBox:SetDataProvider(DataProvider)
    end

    for k,data in pairs(MPLT_LootSnifferMixin.lootTable) do
        DataProvider:Insert({ itemLink = data.itemLink, owner = data.owner, asked = data.asked, isBis = data.isBis })
    end
end

function MPLT_LootSnifferMixin:Autoclose()
    Addon.StartAutoclose(askingFrame, self)
end

local savedInstanceID
local function ProcessEvent(self, event, ...)
    if event ~= 'ENCOUNTER_LOOT_RECEIVED' then return end

    local lootEncounterId, itemID, itemLink, quantity, unitName, className = ...
    local itemType = select(6, GetItemInfoInstant(itemLink))

    Addon.RunOnItemReady(itemLink, function()
        local itemBindType = select(14, C_Item.GetItemInfo(itemLink))

        if UnitIsUnit('player', unitName) then
            if not Addon.IsEquippableItemType(itemType) or (itemBindType == 2 or itemBindType >= 7) then
                return
            end
            if IsInGroup() and (not IsItemNeeded(itemID) and not IsItemUpgrade(itemLink)) then
                Addon.RollForItem(itemID, itemLink)
            end
            return
        end

        if itemBindType >= 7 then return end

        local instanceID = select(8, GetInstanceInfo())

        if savedInstanceID ~= instanceID then
            wipe(MPLT_LootSnifferMixin.lootTable)
            savedInstanceID = instanceID
        end

        if IsItemNeeded(itemID) then
            AddNewItem(itemLink, unitName, true)
            MPLT_LootSnifferMixin:Init()
        elseif IsItemUpgrade(itemLink) then
            AddNewItem(itemLink, unitName, false)
            MPLT_LootSnifferMixin:Init()
        end
    end)
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')