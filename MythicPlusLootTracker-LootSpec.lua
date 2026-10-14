local AddonName, Addon = ...

-- Опции модуля
Addon.LootSpec = {}
local LootSpec = Addon.LootSpec

local panel = nil
local talentsFrame = nil
local talentsFrameParent = nil -- ReadyCheckListenerFrame или nil
local specButtonsFrame = nil
local currSpecButton = nil
local lastInstanceID = 0
local currentSpecLoot = 0
local talentsDataProvider = nil
local talentsScrollFrame = nil
local talentsScrollBar = nil
local oldTalentSelection = nil

-- Проверка включения модуля
local function IsEnabled()
    return Addon.DB ~= nil and Addon.DB.global.lootSpec ~= nil and Addon.DB.global.lootSpec.enabled ~= false
end

-- Создание фрейма списка талантов
local function CreateTalentsFrame()
    if talentsFrame then
        talentsFrame:Show()
        talentsFrame:SetAlpha(1)
        return talentsFrame
    end

    talentsFrame = CreateFrame("Frame", "MPLTLootSpecTalentsFrame", nil, "BackdropTemplate")
    talentsFrame.bg = talentsFrame:CreateTexture(nil, "BACKGROUND")
    talentsFrame.bg:SetPoint("LEFT", talentsFrame, "LEFT", 0, 0)
    talentsFrame.bg:SetSize(115, 46)
    talentsFrame.bg:SetAtlas("Professions-Recrafting-Panel", true)
    talentsFrame.bg:Show()

    talentsFrameParent = nil
    talentsScrollFrame = CreateFrame("Frame", nil, talentsFrame, "WowScrollBoxList")
    talentsScrollFrame:SetPoint("TOPLEFT", talentsFrame.bg, "TOPLEFT", 3, -3)
    talentsScrollFrame:SetPoint("BOTTOMRIGHT", talentsFrame.bg, "BOTTOMRIGHT", -16, 3)
    talentsScrollBar = CreateFrame("EventFrame", nil, talentsFrame, "MinimalScrollBar")
    talentsScrollBar:SetPoint("TOPLEFT", talentsScrollFrame, "TOPRIGHT", 2, 0)
    talentsScrollBar:SetPoint("BOTTOMLEFT", talentsScrollFrame, "BOTTOMRIGHT", 2, 0)

    talentsDataProvider = CreateDataProvider()

    -- Локальный создатель строки-кнопки вместо заранее заданных шаблонов
    local view = CreateScrollBoxListLinearView(1, 2, 2, 0)
    view:SetElementExtent(16)
    view:SetElementInitializer("Button", function(button, elementData)
        local id = elementData.ID
        local name = elementData.Name
        if not button.name then
            button.name = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            button.name:SetPoint("LEFT", button, "LEFT", 2, 0)
            button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        end

        button.name:SetText(name)
        if id == C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID()) then
            button:LockHighlight()
            oldTalentSelection = button
        else
            button:UnlockHighlight()
        end
        button:SetScript("OnClick", function()
            if not IsEnabled() then return end
            local canChange = C_ClassTalents.CanChangeTalents()
            if not canChange then return end

            if not PlayerSpellsFrame then
                PlayerSpellsFrame_LoadUI()
            end

            if oldTalentSelection then
                oldTalentSelection:UnlockHighlight()
            end
            oldTalentSelection = button

            button:LockHighlight()
            local result = PlayerSpellsFrame.TalentsFrame:LoadConfigInternal(id, true, true)
            -- fallback: C_ClassTalents.LoadConfig(id, true)
        end)
    end)

    talentsScrollFrame:SetView(view)
    ScrollUtil.InitScrollBoxListWithScrollBar(talentsScrollFrame, talentsScrollBar, view)

    return talentsFrame
end

-- Показ списка талантов
local function ShowTalents(parent)
    talentsFrameParent = parent
    talentsFrame:SetParent(parent)
    talentsFrame:ClearAllPoints()
    talentsFrame:SetPoint("TOPRIGHT", parent, "BOTTOM", -15, 0)

    -- Новый провайдер на каждый показ, иначе строки дублируются
    talentsDataProvider = CreateDataProvider()
    talentsScrollFrame:SetDataProvider(talentsDataProvider)

    local talentIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
    if not talentIDs or #talentIDs == 0 then
        talentsFrame:Hide()
        return
    end

    for i = 1, #talentIDs do
        local configID = tonumber(talentIDs[i])
        local configInfo = configID and C_Traits.GetConfigInfo(configID) or nil
        if configInfo then
            talentsDataProvider:Insert({ ID = configInfo.ID, Name = configInfo.name })
        end
    end

    -- В Midnight у ScrollBox нет Refresh()/Evaluate(): список перестраивается сам
    -- через события провайдера (каждый Insert триггерит FullUpdate немедленно)

    local height = #talentIDs
    talentsFrame:SetSize(100, 16 + 16 * height)
    if talentsFrame:GetHeight() < 100 then talentsFrame:SetHeight(100) end

    talentsFrame:Show()
    talentsFrame:SetAlpha(1)
end

-- Скрывать UI модуля
local function HideLootSpecUI()
    if not talentsFrame or not talentsFrame:IsVisible() then
        return
    end
    talentsFrame:Hide()
    talentsFrameParent = nil
    if specButtonsFrame then
        specButtonsFrame:Hide()
    end
end

-- Создание кнопок специализаций для спеки добычи
local function CreateSpecButtons()
    if specButtonsFrame then return end

    specButtonsFrame = CreateFrame("Frame", "MPLTLootSpecSpecButtonsFrame", nil, "BackdropTemplate")
    specButtonsFrame:Show()

    local GRID_DIRECTION = GridLayoutMixin.Direction.TopLeftToBottomRight
    local GRID_STRIDE = 4
    local GRID_PADDING_X = 4
    local GRID_PADDING_Y = 4

    local initialAnchor = AnchorUtil.CreateAnchor("LEFT", specButtonsFrame, "LEFT", 0, 0)
    local gridLayout = AnchorUtil.CreateGridLayout(GRID_DIRECTION, GRID_STRIDE, GRID_PADDING_X, GRID_PADDING_Y)
    local children = {}

    currentSpecLoot = GetLootSpecialization()
    if currentSpecLoot == 0 then
        currentSpecLoot = GetSpecializationInfo(GetSpecialization())
    end

    local numSpecs = GetNumSpecializations()
    specButtonsFrame:SetSize(40 * numSpecs + (numSpecs - 1) * GRID_PADDING_X, 40)

    for i = 1, numSpecs do
        local specID, specName, _, specIcon = GetSpecializationInfo(i)
        local button = CreateFrame("ItemButton", "MPLT_LootSpecSpecButton" .. specID, specButtonsFrame)
        button:SetParent(specButtonsFrame)
        button:SetSize(40, 40)
        button:SetPoint("BOTTOMLEFT", specButtonsFrame, "BOTTOMLEFT")
        button:Show()
        SetItemButtonTexture(button, specIcon)

        button.mask = button:CreateMaskTexture()
        button.mask:SetAtlas("UI-HUD-ActionBar-IconFrame-Mask", true)
        button.mask:SetPoint("CENTER", button)
        button.mask:SetSize(55, 55)
        button.icon = button.icon or button
        button.icon:AddMaskTexture(button.mask)

        if currentSpecLoot == specID then
            currSpecButton = button
            SetItemButtonDesaturated(button, false)
        else
            SetItemButtonDesaturated(button, true)
        end

        button:SetScript("OnClick", function(self)
            if not IsEnabled() then return end
            self:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")

            local currentSpec = GetSpecialization()
            if currentSpec == i and currentSpecLoot ~= specID then
                SetLootSpecialization(0)
            else
                SetLootSpecialization(specID)
            end
        end)

        button:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_LOOT_SPEC_UPDATED" then
                self:UnregisterEvent("PLAYER_LOOT_SPEC_UPDATED")
                if not IsEnabled() then return end

                local currentSpec = GetSpecialization()
                if currentSpec == i and currentSpecLoot ~= specID then
                    local specName = i
                    local info = ChatTypeInfo["SYSTEM"]
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("Changed loot spec to %s", specName), info.r, info.g, info.b, info.id)
                end

                if currSpecButton then
                    SetItemButtonDesaturated(currSpecButton, true)
                end
                SetItemButtonDesaturated(button, false)
                currSpecButton = button
            end
        end)

        button:SetScript("OnEnter", function(self)
            if not IsEnabled() then return end
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 20, 10)
            GameTooltip:SetText(specName, 1, 1, 1)
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", GameTooltip_Hide)

        table.insert(children, button)
    end

    AnchorUtil.GridLayout(children, initialAnchor, gridLayout)
end

-- Показ UI для отслеживания спеки добычи (Ready-check)
local function ShowLootSpecUI(parent)
    if not IsEnabled() then return end
    parent = parent or UIParent

    CreateSpecButtons()
    CreateTalentsFrame()

    talentsFrameParent = parent
    talentsFrame:SetParent(parent)
    talentsFrame:ClearAllPoints()
    talentsFrame:SetPoint("TOPRIGHT", parent, "BOTTOM", -15, 0)

    specButtonsFrame:SetParent(talentsFrame)
    specButtonsFrame:SetPoint("TOPLEFT", talentsFrame, "TOPRIGHT", 20, 0)

    talentsFrame:Show()
    specButtonsFrame:Show()

    ShowTalents(parent)
end

-- Обработчик входа в подземелье|рейд
local function OnPlayerEnteringWorld(event)
    if not IsEnabled() then return end
    currentSpecLoot = GetLootSpecialization()
    if currentSpecLoot == 0 then
        currentSpecLoot = GetSpecializationInfo(GetSpecialization())
    end

    CreateSpecButtons()
    CreateTalentsFrame()

    if IsInInstance() then
        local curentInstanceID = select(8, GetInstanceInfo())
        if lastInstanceID == curentInstanceID then
            return
        end
        lastInstanceID = curentInstanceID

        ShowLootSpecUI(ReadyCheckListenerFrame)
    else
        if lastInstanceID ~= 0 then
            lastInstanceID = 0
            HideLootSpecUI()
        end
    end
end

-- Обработчик Ready-check
local function OnReadyCheck(event, unit, timer)
    if not IsEnabled() then return end
    if timer and unit ~= GetUnitName("player") then
        return
    end
    ShowLootSpecUI(ReadyCheckListenerFrame)
end

-- Обработчик UNIT_SPELLCAST_SENT (воркшоп/Великое хранилище)
local function OnUnitSpellcastSent(unit, target, spellID)
    if not IsEnabled() then return end
    if unit ~= "player" then return end
    -- Наш spellID из Great Vault (449976)
    if spellID ~= 449976 then return end

    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID == Addon.Constants.GREAT_VAULT_MAP_ID then
        PlaySound(SOUNDKIT.RAID_WARNING)
        ShowLootSpecUI(ReadyCheckListenerFrame)
    end
end

-- Обработчик закрытия Великого Хранилища
local function OnPlayerInteractionManagerFrameHide(event, interactionType)
    if not IsEnabled() then return end
    if interactionType ~= Addon.Constants.GREAT_VAULT_INTERACTION_TYPE then
        return
    end
    HideLootSpecUI()
end

-- Работа с ReadyCheck_FINISHED
local function OnReadyCheckCompleted(event)
    if not IsEnabled() then return end
    HideLootSpecUI()
end

-- Фрейм событий модуля
local LootSpecEventHandler = CreateFrame("Frame")
LootSpecEventHandler:SetScript("OnEvent", function(self, event, ...)
    -- ADDON_LOADED обрабатываем до проверки IsEnabled: DB ещё не создан,
    -- а событие приходит и от чужих аддонов, грузящихся раньше нас
    if event == "ADDON_LOADED" then
        local name = ...
        if name == AddonName then
            self:UnregisterEvent("ADDON_LOADED")
            Addon.DB.global.lootSpec = Addon.DB.global.lootSpec or { enabled = false, lastInstanceID = 0 }
        end
        return
    end

    if not IsEnabled() then return end

    if event == "PLAYER_ENTERING_WORLD" then
        OnPlayerEnteringWorld(event)
    elseif event == "READY_CHECK" then
        OnReadyCheck(event, ...)
    elseif event == "UNIT_SPELLCAST_SENT" then
        OnUnitSpellcastSent(...)
    elseif event == "READY_CHECK_FINISHED" then
        OnReadyCheckCompleted(event)
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        -- interactionType=49 для Great Vault — игнорируем, находимся в окне
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        OnPlayerInteractionManagerFrameHide(event, ...)
    end
end)

LootSpecEventHandler:RegisterEvent("ADDON_LOADED")
LootSpecEventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
LootSpecEventHandler:RegisterEvent("READY_CHECK")
LootSpecEventHandler:RegisterEvent("READY_CHECK_FINISHED")
LootSpecEventHandler:RegisterEvent("UNIT_SPELLCAST_SENT")
LootSpecEventHandler:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
LootSpecEventHandler:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")

-- Публичные API модуля
function Addon.SetLootSpecEnabled(enabled)
    if enabled == nil then enabled = not Addon.DB.global.lootSpec.enabled end
    Addon.DB.global.lootSpec.enabled = enabled

    local checkbox = _G["MPLT_LootSpecToggle"]
    if enabled then
        checkbox:SetChecked(true)
        LootSpecEventHandler:RegisterAllEvents()
        if IsInInstance() then
            OnPlayerEnteringWorld("PLAYER_ENTERING_WORLD")
        end
    else
        checkbox:SetChecked(false)
        LootSpecEventHandler:UnregisterAllEvents()
        HideLootSpecUI()
    end
end

function Addon.CreateLootSpecCheckbox(parent)
    local checkbox = _G["MPLT_LootSpecToggle"]
    if checkbox then return end
    -- Окно ещё не создано — ждать: иначе галка станет сиротой без родителя и не появится
    if not MPLTLootFrame then return end

    -- MPLTLootFrameBg — это текстура из ButtonFrameTemplate, не фрейм: родителем должно быть окно
    checkbox = CreateFrame("CheckButton", "MPLT_LootSpecToggle", MPLTLootFrame, "UICheckButtonTemplate")
    -- parent — кнопка Import: галка справа от неё; без неё — слева от заголовка окна
    if parent then
        checkbox:SetPoint("LEFT", parent, "RIGHT", 6, 0)
    else
        checkbox:SetPoint("RIGHT", MPLTLootFrameTitleText, "LEFT", 0, -10)
    end
    checkbox:SetHitRectInsets(0, 0, 0, 0)
    checkbox:SetSize(24, 24)
    checkbox:SetScript("OnClick", function()
        Addon.SetLootSpecEnabled(nil)
    end)

    local text = checkbox:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
    text:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    text:SetText(Addon.localization.lootSpecOption)

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(Addon.localization.lootSpecOptionTip, 1, 1, 1)
        GameTooltip:AddLine(Addon.localization.lootSpecSection)
        GameTooltip:AddLine(string.format(Addon.localization.lootSpecRules, 449976))
        GameTooltip:Show()
    end)
    checkbox:SetScript("OnLeave", GameTooltip_Hide)
end
