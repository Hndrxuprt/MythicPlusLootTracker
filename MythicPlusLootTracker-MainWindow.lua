local AddonName, Addon = ...

local UIConfig = nil

function Addon.UpdateSubFrames()
    local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
    local SubFrames = {"MPLTEncountersFrame", "MPLTTrackingFrame", "MPLTAltManagerFrame"}
    for index, frameName in pairs (SubFrames) do
        if index == tabID then
            _G[frameName]:Show()
        else
            if _G[frameName]:IsVisible() then
                _G[frameName]:Hide()
            end
        end
    end
    if tabID == 3 then
        UIConfig.dropDownChars:Hide()
        UIConfig.dropDownSeason:Hide()
    else
        UIConfig.dropDownChars:Show()
        UIConfig.dropDownSeason:Show()
    end

    -- Компактный вид доступен на вкладках Fortune и Tracking; на остальных — полный размер окна.
    local compact = Addon.DB and Addon.DB.global and Addon.DB.global.compactView and (tabID == 1 or tabID == 2)
    if compact then
        MPLTLootFrame:SetWidth(Addon.Constants.Layout.CompactWindowWidth)
        UIConfig.dropDownChars:Hide()
        UIConfig.dropDownSeason:Hide()
        -- Верхние кнопки показываем обычного размера и перепривязываем к левому краю.
        if UIConfig.topButtons then
            for _, btn in ipairs(UIConfig.topButtons) do
                btn:Show()
                btn:ClearAllPoints()
                btn:SetSize(100, 25)
            end
            UIConfig.topButtons[1]:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 58, -28)
            for i = 2, #UIConfig.topButtons do
                UIConfig.topButtons[i]:SetPoint("LEFT", UIConfig.topButtons[i-1], "RIGHT", 4, 0)
            end
        end
        if UIConfig.compactToggle then
            UIConfig.compactToggle:Show()
        end
    else
        MPLTLootFrame:SetWidth(Addon.Constants.Layout.MainWindowWidth)
        if UIConfig.topButtons then
            for _, btn in ipairs(UIConfig.topButtons) do
                btn:Show()
                btn:ClearAllPoints()
                btn:SetSize(100, 25)
            end
            -- Полный вид: восстанавливаем исходные якоря.
            UIConfig.topButtons[1]:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 70, -30)
            for i = 2, #UIConfig.topButtons do
                UIConfig.topButtons[i]:SetPoint("LEFT", UIConfig.topButtons[i-1], "RIGHT", 4, 0)
            end
        end
        if UIConfig.compactToggle then
            -- Кнопка видна на вкладках Fortune и Tracking; на AltManager — скрывается.
            if tabID == 1 or tabID == 2 then
                UIConfig.compactToggle:Show()
            else
                UIConfig.compactToggle:Hide()
            end
        end
    end
end

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())
    Addon.UpdateSubFrames()
    -- При переключении на Fortune перестраиваем список, чтобы подхватить compactView.
    local tabID = self:GetID()
    if tabID == 1 and UIConfig then
        local playerID = UIConfig.dropDownChars and UIConfig.dropDownChars.character or Addon.GetPlayerID()
        Addon.PrepareEncounterList(playerID)
    end
end

local function SetTabs(frame, numTabs, ...)
    frame.numTabs = numTabs
    local contents = {}
    local frameName = frame:GetName()
    for i = 1, numTabs do
        local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "PanelTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(select(i, ...))
        tab:SetScript("OnClick", Tab_OnClick)
        tab.content = CreateFrame ("Frame", nil, UIConfig.ScrollFrame)
        tab.content:SetSize(Addon.Constants.Layout.TabContentWidth, Addon.Constants.Layout.TabContentHeight)
        tab.content:Hide()
        tab:Hide()
        tab:Show()

        tinsert(contents, tab.content)

        if i == 1 then
            tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, 4)
        else
            tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i-1)], "TOPRIGHT", 2, 0)
        end
    end
    Tab_OnClick(_G[frameName.."Tab1"])

    return unpack(contents)
end

local function ScrollFrame_OnMouseWheel(self, delta)
    local newValue = self:GetVerticalScroll() - (delta * 20);

    if (newValue < 0) then
        newValue = 0;
    elseif (newValue > self:GetVerticalScrollRange()) then
        newValue = self:GetVerticalScrollRange();
    end
    self:SetVerticalScroll(newValue);

end

local function CreateTrackedItemList(parent)
    local playerID = MPLTDropDown.defaultText
    MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
end

function Addon.ToggleMainWindow()
    local playerID = Addon.GetPlayerID()
    if UIConfig == nil then
        local dungeonName = nil

        UIConfig = CreateFrame("Frame", "MPLTLootFrame", UIParent, "ButtonFrameTemplate")
        _G["UIConfig"] = UIConfig
        tinsert(UISpecialFrames, UIConfig:GetName())
        UIConfig:SetSize(Addon.Constants.Layout.MainWindowWidth, Addon.Constants.Layout.MainWindowHeight)
        UIConfig:SetPoint("CENTER")
        UIConfig:SetMovable(true)
        UIConfig:EnableMouse(true)
        UIConfig:RegisterForDrag("LeftButton")
        UIConfig:SetScript("OnDragStart",UIConfig.StartMoving)
        UIConfig:SetScript("OnDragStop",UIConfig.StopMovingOrSizing)
        UIConfig:SetFrameStrata("HIGH")
        MPLTLootFrameInset.Bg:SetAtlas("Dragonflight-Landingpage-Background", true)
        MPLTLootFrameInset.Bg:SetHorizTile(false)
        MPLTLootFrameInset.Bg:SetVertTile(false)
        MPLTLootFrameInset.Bg:SetVertexColor(0.4, 0.4, 0.4)

        UIConfig.desc = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        UIConfig.desc:ClearAllPoints()
        UIConfig.desc:SetPoint("BOTTOMLEFT", MPLTLootFrameBg, "BOTTOMLEFT", 8, 6)
        local version = C_AddOns.GetAddOnMetadata(AddonName, "Version")
        local author = C_AddOns.GetAddOnMetadata(AddonName, "Author")
        UIConfig.desc:SetText(Addon.localization.version..version.." | Discord: "..author)

        MPLTLootFrameTitleText:SetText(Addon.localization.title)
        MPLTLootFramePortrait:SetTexture("interface/icons/inv_bfa_paragoncache_orderofembers.blp")

        -- Переключатель компактного вида вкладки Tracking: слева от кнопки закрытия окна.
        local compactToggle = CreateFrame("Frame", "MPLTCompactToggle", MPLTLootFrame, "MaximizeMinimizeButtonFrameTemplate")
        compactToggle:SetPoint("RIGHT", MPLTLootFrame.CloseButton, "LEFT", 0, 0)
        UIConfig.compactToggle = compactToggle
        -- Свой onClick вместо стандартного Maximize()/Minimize(): меняем флаг и перестраиваем список.
        -- Имена методов миксина контринтуитивны: SetMinimizedLook() показывает MinimizeButton
        -- (иконку "свернуть") — это вид полного/развёрнутого состояния; SetMaximizedLook() — наоборот.
        compactToggle.MaximizeButton:SetScript("OnClick", function()
            Addon.DB.global.compactView = false
            compactToggle:SetMinimizedLook()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            local playerID = UIConfig.dropDownChars.character or Addon.GetPlayerID()
            Addon.PrepareEncounterList(playerID)
            MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
            Addon.UpdateSubFrames()
        end)
        compactToggle.MinimizeButton:SetScript("OnClick", function()
            Addon.DB.global.compactView = true
            compactToggle:SetMaximizedLook()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            local playerID = UIConfig.dropDownChars.character or Addon.GetPlayerID()
            Addon.PrepareEncounterList(playerID)
            MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
            Addon.UpdateSubFrames()
        end)
        -- Тултип с подписью при наведении.
        compactToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            if Addon.DB.global.compactView then
                GameTooltip:SetText(Addon.localization.compactViewExpand)
            else
                GameTooltip:SetText(Addon.localization.compactView)
            end
            GameTooltip:Show()
        end)
        compactToggle:SetScript("OnLeave", GameTooltip_Hide)
        -- Синхронизируем вид кнопки с сохранённым состоянием.
        -- Полный вид → показываем "свернуть" (SetMinimizedLook); компакт → "развернуть" (SetMaximizedLook).
        if Addon.DB.global.compactView then
            compactToggle:SetMaximizedLook()
        else
            compactToggle:SetMinimizedLook()
        end
        -- Кнопка видна только на вкладке Tracking; UpdateSubFrames управляет видимостью.

        local showLootSnifferButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        showLootSnifferButton:Hide()
        showLootSnifferButton:SetParent(MPLTLootFrame)
        showLootSnifferButton:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 70, -30)
        showLootSnifferButton:SetSize(100, 25)
        showLootSnifferButton:SetText(Addon.localization.snifferTitle)
        showLootSnifferButton:Show()
        showLootSnifferButton:SetScript("OnClick", function()
            MPLT_LootSnifferMixin:Init()
        end)
        UIConfig.topButtons = { showLootSnifferButton }

        local showRollButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        showRollButton:Hide()
        showRollButton:SetParent(MPLTLootFrame)
        showRollButton:SetPoint("LEFT", showLootSnifferButton, "RIGHT", 4, 0)
        showRollButton:SetSize(100, 25)
        showRollButton:SetText(Addon.localization.rollButton)
        showRollButton:Show()
        showRollButton:SetScript("OnClick", function()
            MPLT_RollFrameMixin:Init()
        end)
        table.insert(UIConfig.topButtons, showRollButton)

        if C_AddOns.IsAddOnLoaded("ClassCodex") then
            local showImportButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
            showImportButton:Hide()
            showImportButton:SetParent(MPLTLootFrame)
            showImportButton:SetPoint("LEFT", showRollButton, "RIGHT", 4, 0)
            showImportButton:SetSize(100, 25)
            showImportButton:SetText(Addon.localization.CCImportButton)
            showImportButton:Show()
            showImportButton:SetScript("OnClick", function()
                local sourceType = "Mythic+"
                if IsShiftKeyDown() then
                    sourceType = "Raid"
                elseif IsAltKeyDown() then
                    sourceType = "Overall"
                end
                MPLT_ImportClassCodexGear(sourceType)
            end)
            showImportButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip_AddNormalLine(GameTooltip, Addon.localization.CCImportButtonDesc1)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddHighlightLine(GameTooltip, Addon.localization.CCImportButtonDesc2)
                GameTooltip_AddColoredLine(GameTooltip, Addon.localization.CCImportButtonDesc3, LIGHTYELLOW_FONT_COLOR)
                GameTooltip_AddColoredLine(GameTooltip, Addon.localization.CCImportButtonDesc4, LIGHTYELLOW_FONT_COLOR)
                GameTooltip_AddColoredLine(GameTooltip, Addon.localization.CCImportButtonDesc5, LIGHTYELLOW_FONT_COLOR)
                GameTooltip:SetScale(0.82)
                GameTooltip:Show()
            end)
            showImportButton:SetScript("OnLeave",function(self)
                GameTooltip:SetScale(1)
                GameTooltip:Hide()
            end)
            table.insert(UIConfig.topButtons, showImportButton)


            local texture = C_AddOns.GetAddOnMetadata("ClassCodex", "IconTexture")
            if texture then
                showImportButton.icon = showImportButton:CreateTexture()
                showImportButton.icon:SetSize(16, 16)
                showImportButton.icon:SetPoint("LEFT", showImportButton, "LEFT", 8, 0)
                showImportButton.icon:SetTexture(texture)
                showImportButton.icon:Show()
            end
        end


        
        UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate")
        UIConfig.ScrollFrame:SetPoint("TOPLEFT", MPLTLootFrameBg, "TOPLEFT", 8, -45)
        UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", MPLTLootFrameBg, "BOTTOMRIGHT", -3, 30)
        UIConfig.ScrollFrame:SetSize(Addon.Constants.Layout.ScrollFrameWidth, Addon.Constants.Layout.ScrollFrameHeight)

        UIConfig.ScrollFrame:SetClipsChildren(true)

        Addon.PrepareEncounterList(playerID)

        UIConfig.dropDownChars = CreateFrame("DropdownButton", "MPLTDropDown", UIConfig, "WowStyle1DropdownTemplate")
        UIConfig.dropDownChars:SetDefaultText(playerID)
        UIConfig.dropDownChars.character = playerID
        UIConfig.dropDownChars:SetPoint("RIGHT", MPLTLootFrameTitleText, "RIGHT", 0, -35)
        UIConfig.dropDownChars:SetWidth(200)
        UIConfig.dropDownChars:SetupMenu(function(dropdown, rootDescription)
            rootDescription:CreateTitle(Addon.localization.characters)

            local function IsSelected(player)
                return UIConfig.dropDownChars.character == player
            end
    
            local function SetSelected(player)
                UIConfig.dropDownChars:SetDefaultText(player)
                UIConfig.dropDownChars.character = player
                fortune = Addon.CalcFortune(player, dungeonName, Addon.currentSeason)

                local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
                if tabID == 1 then
                    Addon.PrepareEncounterList(player)
                    CreateTrackedItemList(content2)
                elseif tabID == 2 then
                    MPLT_TrackingElementMixin:PrepareTrackingList(player)
                end
                Addon.UpdateSubFrames()
            end
            
            for k, v in pairs(MPLH_ENC[Addon.currentSeason]) do
                rootDescription:CreateRadio(k, IsSelected, SetSelected, k)
            end
        end)

        UIConfig.dropDownSeason = CreateFrame("DropdownButton", "MPLTDropDownSeason", UIConfig, "WowStyle1DropdownTemplate")
        UIConfig.dropDownSeason:SetDefaultText(Addon.localization.season[Addon.currentSeason])
        UIConfig.dropDownSeason:SetPoint("RIGHT", MPLTLootFrameTitleText, "RIGHT", -215, -35)
        UIConfig.dropDownSeason:SetWidth(130)
        UIConfig.dropDownSeason.seasonID = Addon.currentSeason
        UIConfig.dropDownSeason:SetupMenu(function(dropdown, rootDescription)
            rootDescription:CreateTitle(Addon.localization.seasons)

            local function IsSelected(season)
                return UIConfig.dropDownSeason.seasonID == season
            end
    
            local function SetSelected(season)
                UIConfig.dropDownSeason:SetDefaultText(season)
                UIConfig.dropDownSeason.seasonID = season
                Addon.currentSeason = season

                local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
                if tabID == 1 then
                    Addon.PrepareEncounterList(playerID)
                elseif tabID == 2 then
                    MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
                end
                Addon.UpdateSubFrames()
            end
            
            for k, v in pairs(MPLH_ENC) do
                rootDescription:CreateRadio(Addon.localization.season[k], IsSelected, SetSelected, k)
            end
        end)

        local content, content2, content3 = SetTabs(UIConfig, 3, Addon.localization.tab1, Addon.localization.tab2, Addon.localization.tab3)

        MPLT_AltManagerMixin:PrepareAltManager()

        UIConfig.ScrollFrame:SetScrollChild(content)
        UIConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)

        CreateTrackedItemList(content2)
    else
        if UIConfig:IsShown() then
            UIConfig:Hide()
        else
            local tabID = PanelTemplates_GetSelectedTab(MPLTLootFrame)
            if tabID == 1 then
                Addon.PrepareEncounterList(playerID)
            elseif tabID == 2 then
                MPLT_TrackingElementMixin:PrepareTrackingList(playerID)
            end
            UIConfig:Show()
            Addon.UpdateSubFrames()
        end
    end
end