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

local animationInfo = {
    TimerBar = {
        animType = "Translation",
		baseDuration = 15,
		durationDiff = 4,
		XOfs = -400,
		YOfs = 0,
    }
}

local testTable = {
    --["Aboba-Kaloboba"] = "|cnIQ4:|Hitem:221050::::::::80:256::16:7:11987:10390:6652:11964:10383:3147:10255:1:28:1279::::|h[Ancient Hardened Legwraps]|h|r",
    --["Abob-Kaloboba"] = "|cffa335ee|Hitem:221109::::::::80:102::16:7:11978:10390:6652:11964:10383:3131:10255:1:28:1279:::::|h[Candlebearer's Shroud]|h|r",
    --["Abo-Kaloboba"] = "|cnIQ4:|Hitem:221198::::::::80:1467::16:8:11979:6652:10395:10392:10383:11215:3134:10255:1:28:1279::::|h[85-Year Tenure Ring]|h|r",
    --["Ab-Kaloboba"] = "|cffa335ee|Hitem:221062::::::::80:1467::16:6:11985:10390:6652:10384:3141:10255:1:28:1279:::::|h[Scalding Queenmaker's Shiv]|h|r",
    --["Abbbb-Kaloboba"] = "|cnIQ4:|Hitem:168973::::::::80:256::16:6:11979:10390:6652:10384:10031:10255:1:28:1279::::|h[Neural Synapse Enhancer]|h|r",
    --["POomtis-Kaloboba"] = "\124cff0070dd\124Hitem:221116::::::::80::::1:3147:\124h[Glorious Defender's Poleaxe]\124h\124r",
    --["Choomtis-Kaloboba"] = "\124cff0070dd\124Hitem:221119::::::::80::::1:3147:\124h[Holybound Grips]\124h\124r",
    --["Doomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242464::::::::80::::1:3196:\124h[Swarmite's Frenzied Pedicel]\124h\124r",
    --["Doomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242468::::::::80::::1:3196:\124h[Al'dani Attendant's Gauze]\124h\124r",
    --["Hroomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242473::::::::80:::::\124h[Spittle-Stained Trousers]\124h\124r",
    --["ASdomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242475::::::::80::::1:3196:\124h[Eco-Dome Access Bands]\124h\124r",
    --["AOIKomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242476::::::::80::::1:3196:\124h[Taahbat's Desert Carbine]\124h\124r",
    --["Koaomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242484::::::::80::::1:3196:\124h[Soul-Scribe's Tabiqa Dagger]\124h\124r",
    --["Lksomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242487::::::::80::::1:3196:\124h[Fatebound Crusader]\124h\124r",
    --["Odomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242488::::::::80::::1:3196:\124h[Tunic of Sworn Revenge]\124h\124r",
    --["Yeomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242491::::::::80::::1:3196:\124h[Whispers of K'aresh]\124h\124r",
    --["Rksomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242493::::::::80::::1:3196:\124h[Starlit Safeguard]\124h\124r",
    --["Qweomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242495::::::::80::::1:3196:\124h[Incorporeal Warpclaw]\124h\124r",
    ["Woomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242497::::::::80::::1:3196:\124h[Azhiccaran Parapodia]\124h\124r",
    ["Roomtis-Kaloboba"] = "\124cff0070dd\124Hitem:242494::::::::80::::1:3196:\124h[Lily of the Eternal Weave]\124h\124r",
}

MPLT_LootSnifferMixin = {}
MPLT_LootSnifferMixin.lootTable = {}

local function GetCachedItem(itemLink)
    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()      
            return itemLink
        end)
    else
        return itemLink
    end
end

local function IsItemNeeded(itemID)
    local name, realm = UnitFullName("player")
    local playerID = name .. "-" .. realm

    local _, mapID = GetEncounter(instance)

    if MPLH_TRACKITEM and MPLH_TRACKITEM[playerID] then
        if MPLH_TRACKITEM[playerID][mapID] then
            if MPLH_TRACKITEM[playerID][mapID][itemID] then
                if MPLH_TRACKITEM[playerID][mapID][itemID]["done"]["done"] == 0 then
                    return true
                end
            end
        else
            for map, data in pairs(MPLH_TRACKITEM[playerID]) do
                if data[itemID] then
                    if data[itemID]["done"]["done"] == 0 then
                        return true
                    end
                end
            end
        end
    end

    return false
end

local function IsItemValid(itemID)
    local result = TooltipUtil.FindLinesFromGetter({Enum.TooltipDataLineType.EquipSlot}, "GetItemByID", itemID)
    if result then
        for i, lineData in ipairs(result) do
            if lineData.type == Enum.TooltipDataLineType.EquipSlot then
                --print("isValidItemType ", lineData.isValidItemType)
                --print("isValidInvSlot", lineData.isValidInvSlot)
                return lineData.isValidItemType, lineData.isValidInvSlot
            end
        end
    end
end
--/dump IsItemEquippable("|cnIQ4:|Hitem:221050::::::::80:256::16:7:11987:10390:6652:11964:10383:3147:10255:1:28:1279::::|h[Ancient Hardened Legwraps]|h|r")
--/dump IsItemEquippable("|cffa335ee|Hitem:221109::::::::80:102::16:7:11978:10390:6652:11964:10383:3131:10255:1:28:1279:::::|h[Candlebearer's Shroud]|h|r")
--/dump IsItemEquippable("|cffa335ee|Hitem:178865::::::::80:102::16:6:11979:6652:10384:11215:9951:10255:1:28:1279:::::|h[Xav's Pike of Authority]|h|r")
--/dump IsItemEquippable("|cffa335ee|Hitem:235811::::::::80:102::16:7:11987:10390:6652:11964:10383:3147:10255:1:28:1279:::::|h[Extravagant Epaulets]|h|r")
--/dump IsItemEquippable("|cffa335ee|Hitem:219305::::::::80:102::16:6:11986:10390:6652:10383:3144:10255:1:28:1279:::::|h[Carved Blazikon Wax]|h|r")
--/dump IsItemEquippable("|cffa335ee|Hitem:221099::::::::80:102::16:8:11985:10390:6652:10395:10392:10383:3141:10255:1:28:1279:::::|h[Wick's Golden Loop]|h|r")

--/dump IsItemUpgrade("|cffa335ee|Hitem:235811::::::::80:102::16:7:11987:10390:6652:11964:10383:3147:10255:1:28:1279:::::|h[Extravagant Epaulets]|h|r")
--/run print(IsItemEquippable("|cffa335ee|Hitem:221099::::::::80:102::16:8:11985:10390:6652:10395:10392:10383:3141:10255:1:28:1279:::::|h[Wick's Golden Loop]|h|r"))

function IsItemEquippable(itemLink)
    local equippable
    local _, _, _, _, role, primaryStat, _, _, _, _ = GetSpecializationInfo(GetSpecialization())
    local playerPreferredArmor = CLASS_ARMOR[UnitClassBase("player")]

    local function IsEquppable(itemLink)
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
                    --print("weapon stat: ", _G[stat])
                    if _G[stat] == SPEC_STAT_STRINGS[primaryStat] then
                        itemPrimaryStat = _G[stat]
                        --print(itemLink, ' its weapon ', itemEquipLoc)
                        return true
                    end
                end
            end
                
            if not itemPrimaryStat then 
                --print('its weapon, cant equip')
                return false 
            end
        end

        if itemEquipLoc == 'INVTYPE_TRINKET' then
            --print(itemLink, ' its trinket')
            return true
        else
            if classID == Enum.ItemClass.Armor then
                if subclassID == playerPreferredArmor then
                    --print(itemLink, ' its armor')
                    return true
                else
                    --print(itemLink, ' its armor, cant equip')
                    return false
                end
            end
        end
    end

    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()
            return IsEquppable(itemLink)
        end)
    else
        return IsEquppable(itemLink)
    end
end

--/dump GetItemLevelDiff("|cnIQ4:|Hitem:221050::::::::80:256::16:7:11987:10390:6652:11964:10383:3147:10255:1:28:1279::::|h[Ancient Hardened Legwraps]|h|r")

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
    
    --print(itemEquipLoc, equippedItem1, equippedItem2)

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

    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()
            return IsUpgrade(itemLink)
        end)
    else
        return IsUpgrade(itemLink)
    end
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
    if MPLT_LootSnifferMixin.timer then
        --print("Cancel Autoclose")
        askingFrame.TimerAnim:Stop()
        askingFrame.AutocloseText:SetAlpha(0)
        askingFrame.autoclose = false
        MPLT_LootSnifferMixin.timer:Cancel()
        MPLT_LootSnifferMixin.timer = nil
    end
end)
askingFrame:SetTitle(Addon.localization.snifferTitle)
askingFrame:SetFrameStrata("HIGH")
askingFrame.AutocloseText:SetText(Addon.localization.snifferAutoclose)

askingFrame:Hide()

local DataProvider = CreateDataProvider()

local function AddNewItem(itemLink, unitName, isBis)
    --print("adding item to DataProvider")
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

function MPLT_LootSnifferMixin:Timer()
    local slideAnimGroup = askingFrame.TimerBar:CreateAnimationGroup()
    self.slideAnimGroup = slideAnimGroup

    local translationAnimation = self.slideAnimGroup:CreateAnimation("Translation");
	translationAnimation = self.slideAnimGroup:CreateAnimation("Translation");
	translationAnimation:SetSmoothing("IN");
	slideAnimGroup.translationAnimation = translationAnimation;
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
        frame.ItemFrame.ItemOwner:SetText(itemOwner)
        frame.ItemFrame:SetSize(430, 28)
        frame.ItemFrame.ItemLink:SetText(itemLink)

        frame:SetScript("OnEnter", function(self)
            if MPLT_LootSnifferMixin.timer then
                --print("Cancel Autoclose")
                askingFrame.TimerAnim:Stop()
                askingFrame.AutocloseText:SetAlpha(0)
                MPLT_LootSnifferMixin.timer:Cancel()
                MPLT_LootSnifferMixin.timer = nil
            end
        end)

        frame.ItemFrame.ItemLink:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()

            if MPLT_LootSnifferMixin.timer then
                --print("Cancel Autoclose")
                askingFrame.TimerAnim:Stop()
                askingFrame.AutocloseText:SetAlpha(0)
                MPLT_LootSnifferMixin.timer:Cancel()
                MPLT_LootSnifferMixin.timer = nil
            end
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

    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()         
            SetRowData()
        end)
    else
        SetRowData()
    end
end

function MPLT_LootSnifferMixin:PrepareScrollFrame()
    DataProvider:Flush()
    if not view then
        local view = CreateScrollBoxListLinearView()
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

--/run MPLT_TestItem("\124cff0070dd\124Hitem:221116::::::::80::::1:3147:\124h[Glorious Defender's Poleaxe]\124h\124r")
--/run MPLT_TestItem("\124cff0070dd\124Hitem:221119::::::::80::::1:3147:\124h[Holybound Grips]\124h\124r")



function MPLT_LootSnifferMixin:TestItem(itemLink, unitName)
    if not unitName then
        unitName, realm = UnitFullName("player")
        unitName = unitName.."-"..realm
    end
    local itemID
    local function testItem(itemLink)
        if IsItemNeeded(itemID) then
            --print("BIS ITEM FOUND")
            AddNewItem(itemLink, unitName, true)
        elseif IsItemUpgrade(itemLink) then
            --print("I NEED THIS ITEM 3:", itemLink)
            AddNewItem(itemLink, unitName, false)
        end
    end
    if not C_Item.IsItemDataCachedByID(itemLink) then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()      
            itemID = item:GetItemID()   
            testItem(itemLink)
        end)
    else
        itemID = GetItemInfoInstant(itemLink)
        testItem(itemLink)
    end

end

function MPLT_LootSnifferMixin:Test()
    for name, item in pairs(testTable) do
        self:TestItem(item, name)
    end
    MPLT_LootSnifferMixin:Init()
end

function MPLT_LootSnifferMixin:Autoclose()
    if not askingFrame.autoclose then
        return
    end

    if self.timer then
        askingFrame.TimerAnim:Stop()
        self.timer:Cancel()
        self.timer = nil
    end

    askingFrame.TimerAnim:Play()

    self.timer = C_Timer.NewTimer(10, function()
        askingFrame:Hide()
        askingFrame:SetAlpha(0)
        self.timer:Cancel()
        self.timer = nil
    end)
end

local savedInstanceID
local function ProcessEvent(self, event, ...)
    if event == 'ENCOUNTER_LOOT_RECEIVED' then
        local lootEncounterId, itemID, itemLink, quantity, unitName, className = ...

        local itemBindType = select(14, C_Item.GetItemInfo(itemLink))
        local itemType = select(6,GetItemInfoInstant(itemLink))

        if UnitIsUnit('player', unitName) then

            -- don't suggest boe or warband
            if not (itemType == 2 or itemType == 4) or (itemBindType == 2 or itemBindType > 7) then
                return
            end
            if not IsItemNeeded(itemID) and not IsItemUpgrade(itemLink) then
                local chatType = "PARTY"
                if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                    chatType = 'INSTANCE_CHAT'
                end
                C_Timer.After((math.random(3,5)), function()
                    C_ChatInfo.SendChatMessage(itemLink.. " roll", chatType)
                end)
            end
            return
        end

        --don't track warband items
        if itemBindType > 7 then return end

        local instanceID = select(8,GetInstanceInfo())

        if savedInstanceID ~= instanceID then
            wipe(MPLT_LootSnifferMixin.lootTable)
            savedInstanceID = instanceID
        end

        --print("MPLT sniffsniff: ", unitName, lootEncounterId, itemLink)

        if IsItemNeeded(itemID) then
            --print("I NEED THIS ITEM 1:", itemLink)
            AddNewItem(itemLink, unitName, true)
            MPLT_LootSnifferMixin:Init()
        elseif IsItemUpgrade(itemLink) then
            --print("I NEED THIS ITEM 2:", itemLink)
            AddNewItem(itemLink, unitName, false)
            MPLT_LootSnifferMixin:Init()
        end
    end
end

eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')