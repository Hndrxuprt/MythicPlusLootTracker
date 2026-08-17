local AddonName, Addon = ...

MPLT_AltManagerMixin = {}
OutputLogMixin = {}

local AltManagerFrame = CreateFrame("Frame", "MPLTAltManagerFrame", UIParent, "OutputLogTemplate")
local DataProvider = CreateDataProvider()

local classSetItems = {
    249955, 249953, 249952, 249951, 249950,
    250043, 250042, 250041, 250045, 250040,
    249982, 249980, 249979, 249978, 249977,
    250009, 250007, 250006, 250005, 250004,
    250052, 250051, 250050, 250054, 250049,
    249964, 249962, 249961, 249960, 249959,
    250018, 250016, 250015, 250014, 250013,
    250063, 250061, 250060, 250059, 250058,
    249991, 249989, 249988, 249987, 249986,
    250000, 249998, 249997, 249996, 249995,
    250027, 250025, 250024, 250023, 250022,
    250036, 250034, 250033, 250032, 250031,
    249973, 249971, 249970, 249969, 249968,
}

local function IsItemClassSet(itemID)
    return (itemID and tContains(classSetItems, itemID))
end

function MPLT_AltManagerMixin:OnEnter()
    
end

function MPLT_AltManagerMixin:InitElements(frame, elementData)
    local playerID = elementData.playerID
    frame.CharacterFrame.CharName:SetText(elementData.playerID)
    frame.CharacterFrame.CharName:SetTextScale(0.5)
    local keyName = nil
    if tonumber(_G["MPLH_KACDATA"][playerID]["currentKeystone"]) then
        local name = select(1,C_ChallengeMode.GetMapUIInfo(_G["MPLH_KACDATA"][playerID]["currentKeystone"]))
        keyName = name.."|cffc7c7c7".." (".._G["MPLH_KACDATA"][playerID]["currentKeystoneLvl"]..")"
    else
        keyName = "No keystone"
    end
    frame.CharacterFrame.CharKeystone:SetText(keyName)
    frame.CharacterFrame.CharKeystone:SetTextScale(1.2)
    local mapInfo = MPLH_KACDATA[playerID]["keys"]
    for i=1, 8 do
        if (not mapInfo) or (not mapInfo[i]) then
            frame["Dungeon"..i]["DungeonIcon"..i]:SetAlpha(0)
            frame["Dungeon"..i]:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                GameTooltip:Hide()
            end)
        else
            local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo[i].id)
            if (texture == 0) then
                texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes"
            end
            if mapInfo[i].level > 0 then
                frame["Dungeon"..i].DungeonLvl:SetText(mapInfo[i].level)
                local color
                if(mapInfo[i].overAllScore) then
                    color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(mapInfo[i].overAllScore)
                end
                if(not color) then
                    color = HIGHLIGHT_FONT_COLOR
                end
                frame["Dungeon"..i].DungeonLvl:SetTextColor(color.r, color.g, color.b)
                frame["Dungeon"..i].DungeonLvl:Show()
            else
                frame["Dungeon"..i].DungeonLvl:Hide()
            end
            frame["Dungeon"..i]["DungeonIcon"..i]:SetAlpha(1)
            frame["Dungeon"..i]["DungeonIcon"..i]:SetTexture(texture)
            frame["Dungeon"..i]["DungeonIcon"..i]:SetDesaturated(mapInfo[i].level == 0)

            frame["Dungeon"..i]:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 20, 10)
                local name = C_ChallengeMode.GetMapUIInfo(mapInfo[i].id)
                GameTooltip:SetText(name, 1, 1, 1)

                local isOverTimeRun = false

                local seasonBestDurationSec, seasonBestLevel, members
                local tyrScore, fortScore

                if(mapInfo[i].overAllScore and (mapInfo[i].inTimeInfo or mapInfo[i].overtimeInfo)) then
                    local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(mapInfo[i].overAllScore)
                    if(not color) then
                        color = HIGHLIGHT_FONT_COLOR
                    end
                    GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(mapInfo[i].overAllScore)), GREEN_FONT_COLOR)
                end
                if(mapInfo[i].affixScores and #mapInfo[i].affixScores > 0) then
                    for _, affixInfo in ipairs(mapInfo[i].affixScores) do
                        GameTooltip_AddBlankLineToTooltip(GameTooltip)
                        GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name))
                        GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level)..
                            " ("..(affixInfo.score == mapInfo[i].dungeonScore and affixInfo.score*1.5 or affixInfo.score*0.5)..")", HIGHLIGHT_FONT_COLOR)
                        if(affixInfo.overTime) then
                            if(affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR)
                            else
                                GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR)
                            end
                        else
                            if(affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, true), HIGHLIGHT_FONT_COLOR)
                            else
                                GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, false), HIGHLIGHT_FONT_COLOR)
                            end
                        end
                    end
                end

                GameTooltip:Show()
            end)
        end
    end
    frame.CharacterFrame.CharIlvl:SetText("|cffc7c7c7"..tostring(_G["MPLH_KACDATA"][playerID]["ilvl"]).." |cff7d7d7dilvl")
    frame.CharacterFrame.CharIlvl:SetTextScale(1.2)
    frame.CharProg.CharProg:SetText("|cffc7c7c7"..tostring(_G["MPLH_KACDATA"][playerID]["oneMPlus"].." / ".._G["MPLH_KACDATA"][playerID]["fourMPlus"].." / ".._G["MPLH_KACDATA"][playerID]["eightMPlus"]))
    frame.CharProg.CharProg:SetTextScale(1.2)
    frame.CharProg:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 20, 10)
        if next(MPLH_KACDATA[playerID]["mythicRuns"]) then
            GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, #MPLH_KACDATA[playerID]["mythicRuns"]))
            for i = 1, #MPLH_KACDATA[playerID]["mythicRuns"] do
                local runInfo = MPLH_KACDATA[playerID]["mythicRuns"][i]
                local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID)
                local colour = ((i == 1) or (i == 4) or (i == 8)) and GREEN_FONT_COLOR or WHITE_FONT_COLOR
                GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name), colour)
            end
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
        end
        if next(MPLH_KACDATA[playerID]["raidRuns"]) then
            local suggestions = C_AdventureJournal.GetSuggestions()
            local raidSuggestion = suggestions[3]
            local raidEJID = raidSuggestion.ej_instanceID

            local instanceName = EJ_GetInstanceInfo(raidEJID) --Undermine
            GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_ENCOUNTER_LIST, instanceName))
            for i = 1, #MPLH_KACDATA[playerID]["raidRuns"] do
                GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, MPLH_KACDATA[playerID]["raidRuns"][i][1], MPLH_KACDATA[playerID]["raidRuns"][i][2]), GREEN_FONT_COLOR)
            end
        end
        GameTooltip:Show()
    end)
    local rio = _G["MPLH_KACDATA"][playerID]["rio"]
    frame.CharRio.CharRio:SetText(rio and rio.." |cff7d7d7drio" or "No RIO")
    frame.CharRio.CharRio:SetTextColor(0.5, 0.5, 0.5)
    if rio then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(rio)
        frame.CharRio.CharRio:SetTextColor(color.r, color.g, color.b)
    end
    frame.CharRio.CharRio:SetTextScale(1.2)
    if MPLH_KACDATA[playerID]["gear"] then
        for i=1, 16 do
            if not MPLH_KACDATA[playerID]["gear"][i] then
                frame["ItemFrame"..i]["ItemIcon"..i]:SetAlpha(0)
                frame["ItemFrame"..i]:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                    GameTooltip:Hide()
                end)
            else
                frame["ItemFrame"..i]["ItemIcon"..i]:SetAlpha(1)
                local itemID = GetItemInfoInstant(MPLH_KACDATA[playerID]["gear"][i])
                local itemIcon = GetItemIcon(itemID)
                if (i==1 or i==3 or i==4 or i==9 or i==6) then
                    if not IsItemClassSet(itemID) then
                        frame["ItemFrame"..i]["Item"..i]:SetAtlas("talents-node-choiceflyout-square-red")
                    else
                        frame["ItemFrame"..i]["Item"..i]:SetAtlas("talents-node-choiceflyout-square-yellow")
                    end
                end
                frame["ItemFrame"..i]["ItemIcon"..i]:SetTexture(itemIcon)
                frame["ItemFrame"..i]:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 20, 10)
                    GameTooltip:SetHyperlink(MPLH_KACDATA[playerID]["gear"][i])
                    GameTooltip:Show()
                end)
            end
        end
    end

    frame.CharacterFrame:SetSize(600, 84)
    frame.CharacterFrame:Show()
    local index = DataProvider:FindIndex(elementData)
    frame.UpButton:SetScript("OnClick", function(self)
        local tmp = nil
        tmp = _G["MPLH_ORDER"][index]
        _G["MPLH_ORDER"][index] = _G["MPLH_ORDER"][index-1]
        _G["MPLH_ORDER"][index-1] = tmp
        C_Timer.After(0.4, function()
            MPLT_AltManagerMixin:PrepareAltManager()
            MPLT_UpdateSubFrames()
        end)
    end)
    frame.DownButton:SetScript("OnClick", function(self)
        local tmp = nil
        tmp = _G["MPLH_ORDER"][index]
        _G["MPLH_ORDER"][index] = _G["MPLH_ORDER"][index+1]
        _G["MPLH_ORDER"][index+1] = tmp
        C_Timer.After(0.4, function()
            MPLT_AltManagerMixin:PrepareAltManager()
            MPLT_UpdateSubFrames()
        end)
    end)
    frame.RemoveChar:SetScript("OnClick", function(self)
        table.remove(MPLH_ORDER, index)
        MPLH_KACDATA[playerID] = nil
        C_Timer.After(0.4, function()
            MPLT_AltManagerMixin:PrepareAltManager()
            MPLT_UpdateSubFrames()
        end)
    end)
    if CountTable(MPLH_ORDER) == 1 then
        frame.UpButton:Disable()
        frame.DownButton:Disable()
    elseif index == 1 then
        frame.UpButton:Disable()
        frame.DownButton:Enable()
    elseif index == #_G["MPLH_ORDER"] then
        frame.UpButton:Enable()
        frame.DownButton:Disable()
    else
        frame.DownButton:Enable()
        frame.UpButton:Enable()
    end
end

function MPLT_AltManagerMixin:PrepareAltManager()
    local scrollPos = AltManagerFrame.ScrollBar:GetScrollPercentage()
    DataProvider:Flush()

    local view = CreateScrollBoxListLinearView(0, 0, 2, 2, 2)
    view:SetElementInitializer("MPLT_AltManagerTemplate", function(frame, elementData)
		MPLT_AltManagerMixin:InitElements(frame, elementData)
	end)
    ScrollUtil.InitScrollBoxListWithScrollBar(AltManagerFrame.ScrollBox, AltManagerFrame.ScrollBar, view)
    AltManagerFrame.ScrollBox:Init(view)
    AltManagerFrame.ScrollBox:SetInterpolateScroll(true)
    AltManagerFrame.ScrollBar:SetInterpolateScroll(true)
    AltManagerFrame.ScrollBox:SetPanExtent(60)
    local children = {}
    for i = 1, #_G["MPLH_ORDER"] do
        local playerID = _G["MPLH_ORDER"][i]
        children[playerID] = {}
        DataProvider:Insert({playerID = playerID})
    end
    AltManagerFrame.ScrollBox:SetDataProvider(DataProvider)
    AltManagerFrame.ScrollBar:SetScrollPercentage(scrollPos, true)

    AltManagerFrame:ClearAllPoints()
    AltManagerFrame:SetParent(MPLTLootFrame)
    AltManagerFrame:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 5, -45)
    AltManagerFrame:SetSize(775, 425)
    AltManagerFrame:Hide()
    AltManagerFrame.NineSlice:Hide()
    AltManagerFrame.TitleContainer:Hide()
    AltManagerFrame.ClosePanelButton:Hide()
    AltManagerFrame.ScrollBar:Hide()
    AltManagerFrame.Bg:Hide()
    AltManagerFrame.ScrollBox.Shadows:Hide()
    AltManagerFrame:SetAlpha(1)
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('FIRST_FRAME_RENDERED')
