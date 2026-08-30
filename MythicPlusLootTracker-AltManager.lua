local AddonName, Addon = ...

MPLT_AltManagerMixin = {}

local AltManagerFrame = CreateFrame("Frame", "MPLTAltManagerFrame", UIParent, "OutputLogTemplate")
local DataProvider = CreateDataProvider()

local classSetItems = {
    271459, 271457, 271456, 271455, 271454,
    271547, 271546, 271545, 271549, 271544,
    271486, 271484, 271483, 271482, 271481,
    271513, 271511, 271510, 271509, 271508,
    271556, 271555, 271554, 271558, 271553,
    271468, 271466, 271465, 271464, 271463,
    271522, 271520, 271519, 271518, 271517,
    271567, 271565, 271564, 271563, 271562,
    271495, 271493, 271492, 271491, 271490,
    271504, 271502, 271501, 271500, 271499,
    271531, 271529, 271528, 271527, 271526,
    271540, 271538, 271537, 271536, 271535,
    271477, 271475, 271474, 271473, 271472,
}

local function IsItemClassSet(itemID)
    return (itemID and tContains(classSetItems, itemID))
end

local ITEM_FRAME_ORDER = { 1, 3, 4, 9, 6, 14, 5, 7, 8, 2, 10, 11, 12, 13, 15, 16 }

local function CreateItemSlotFrames(row)
    local prevFrame = nil
    for _, n in ipairs(ITEM_FRAME_ORDER) do
        local itemFrame = CreateFrame("Frame", nil, row, "MPLT_AltManagerSlotTemplate")
        itemFrame:SetSize(24, 24)
        if prevFrame then
            itemFrame:SetPoint("LEFT", prevFrame, "RIGHT", 3, 0)
        else
            itemFrame:SetPoint("BOTTOMLEFT", row.CharacterFrame, "BOTTOMLEFT", 170, 15)
        end
        itemFrame["Item"..n] = itemFrame.Slot
        itemFrame["ItemIcon"..n] = itemFrame.SlotIcon
        row["ItemFrame"..n] = itemFrame
        prevFrame = itemFrame
    end
end

local function CreateDungeonSlotFrames(row)
    for i = 1, Addon.Constants.MAX_KEY_RUNS do
        local dungeonFrame = CreateFrame("Frame", nil, row, "MPLT_AltManagerDungeonSlotTemplate")
        dungeonFrame:SetSize(24, 24)
        if i == 1 then
            dungeonFrame:SetPoint("TOP", row.CharacterFrame, "TOP", 31, -11)
        else
            dungeonFrame:SetPoint("LEFT", row["Dungeon"..(i-1)], "RIGHT", 3, 0)
        end
        dungeonFrame["DungeonIcon"..i] = dungeonFrame.SlotIcon
        dungeonFrame.DungeonLvl = dungeonFrame.SlotLvl
        row["Dungeon"..i] = dungeonFrame
    end
end

local function SetKeystone(frame, data)
    local keyName = nil
    if tonumber(data.currentKeystone) then
        local name = select(1,C_ChallengeMode.GetMapUIInfo(data.currentKeystone))
        keyName = name..Addon.Constants.Color.AltGray.." ("..data.currentKeystoneLvl..")"
    else
        keyName = Addon.localization.noKeystone
    end
    frame.CharacterFrame.CharKeystone:SetText(keyName)
    frame.CharacterFrame.CharKeystone:SetTextScale(1.2)
end

local function SetDungeons(frame, data)
    local mapInfo = data.keys
    for i=1, Addon.Constants.MAX_KEY_RUNS do
        if (not mapInfo) or (not mapInfo[i]) then
            frame["Dungeon"..i]["DungeonIcon"..i]:SetAlpha(0)
            frame["Dungeon"..i]:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                GameTooltip:Hide()
            end)
            frame["Dungeon"..i]:SetScript("OnLeave", GameTooltip_Hide)
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
            frame["Dungeon"..i]:SetScript("OnLeave", GameTooltip_Hide)
        end
    end
end

local function SetIlvlProg(frame, data)
    frame.CharacterFrame.CharIlvl:SetText(Addon.Constants.Color.AltGray..tostring(data.ilvl).." "..Addon.Constants.Color.AltDim..Addon.localization.ilvl)
    frame.CharacterFrame.CharIlvl:SetTextScale(1.2)
    frame.CharProg.CharProg:SetText(Addon.Constants.Color.AltGray..tostring(data.oneMPlus.." / "..data.fourMPlus.." / "..data.eightMPlus))
    frame.CharProg.CharProg:SetTextScale(1.2)
    frame.CharProg:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 20, 10)
        if next(data.mythicRuns) then
            GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, #data.mythicRuns))
            for i = 1, #data.mythicRuns do
                local runInfo = data.mythicRuns[i]
                local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID)
                local colour = ((i == 1) or (i == 4) or (i == 8)) and GREEN_FONT_COLOR or WHITE_FONT_COLOR
                GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name), colour)
            end
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
        end
        if next(data.raidRuns) then
            -- Имя рейдового экземпляра сохраняем в GetRaidRuns (первая запись),
            -- больше не берём его из C_AdventureJournal.GetSuggestions()[3].
            local instanceName = data.raidRuns[1].instanceName
            if instanceName then
                GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_ENCOUNTER_LIST, instanceName))
            end
            for i = 1, #data.raidRuns do
                GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, data.raidRuns[i][1], data.raidRuns[i][2]), GREEN_FONT_COLOR)
            end
        end
        GameTooltip:Show()
    end)
    frame.CharProg:SetScript("OnLeave", GameTooltip_Hide)
end

local function SetRio(frame, data)
    local rio = data.rio
    frame.CharRio.CharRio:SetText(rio and rio.." "..Addon.Constants.Color.AltDim..Addon.localization.rio or Addon.localization.noRIO)
    frame.CharRio.CharRio:SetTextColor(0.5, 0.5, 0.5)
    if rio then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(rio)
        frame.CharRio.CharRio:SetTextColor(color.r, color.g, color.b)
    end
    frame.CharRio.CharRio:SetTextScale(1.2)
    frame.CharRio:SetScript("OnLeave", GameTooltip_Hide)
end

local TIER_SLOTS = { [1] = true, [3] = true, [4] = true, [9] = true, [6] = true }

local function SetGear(frame, data)
    if data.gear then
        for i=1, 16 do
            local itemFrame = frame["ItemFrame"..i]
            local itemLink = data.gear[i]
            if not itemLink then
                itemFrame["ItemIcon"..i]:SetAlpha(0)
                -- Восстанавливаем рамку: серую для не-tier слота, жёлтую для tier-слота
                if TIER_SLOTS[i] then
                    itemFrame["Item"..i]:SetAtlas("talents-node-choiceflyout-square-yellow")
                else
                    itemFrame["Item"..i]:SetAtlas("talents-node-choiceflyout-square-gray")
                end
                itemFrame:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                    GameTooltip:Hide()
                end)
                itemFrame:SetScript("OnLeave", GameTooltip_Hide)
            else
                itemFrame["ItemIcon"..i]:SetAlpha(1)
                local itemID = GetItemInfoInstant(itemLink)
                local itemIcon = GetItemIcon(itemID)
                if TIER_SLOTS[i] then
                    if not IsItemClassSet(itemID) then
                        itemFrame["Item"..i]:SetAtlas("talents-node-choiceflyout-square-red")
                    else
                        itemFrame["Item"..i]:SetAtlas("talents-node-choiceflyout-square-yellow")
                    end
                else
                    itemFrame["Item"..i]:SetAtlas("talents-node-choiceflyout-square-gray")
                end
                itemFrame["ItemIcon"..i]:SetTexture(itemIcon)
                itemFrame:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 20, 10)
                    GameTooltip:SetHyperlink(itemLink)
                    GameTooltip:Show()
                end)
                itemFrame:SetScript("OnLeave", GameTooltip_Hide)
            end
        end
    end
end

local function SetOrderButtons(frame, playerID, elementData)
    local index = DataProvider:FindIndex(elementData)
    frame.UpButton:SetScript("OnClick", function(self)
        local tmp = nil
        tmp = MPLH_ORDER[index]
        MPLH_ORDER[index] = MPLH_ORDER[index-1]
        MPLH_ORDER[index-1] = tmp
        C_Timer.After(0.4, function()
            MPLT_AltManagerMixin:PrepareAltManager()
            Addon.UpdateSubFrames()
        end)
    end)
    frame.DownButton:SetScript("OnClick", function(self)
        local tmp = nil
        tmp = MPLH_ORDER[index]
        MPLH_ORDER[index] = MPLH_ORDER[index+1]
        MPLH_ORDER[index+1] = tmp
        C_Timer.After(0.4, function()
            MPLT_AltManagerMixin:PrepareAltManager()
            Addon.UpdateSubFrames()
        end)
    end)
    frame.RemoveChar:SetScript("OnClick", function(self)
        table.remove(MPLH_ORDER, index)
        MPLH_KACDATA[playerID] = nil
        C_Timer.After(0.4, function()
            MPLT_AltManagerMixin:PrepareAltManager()
            Addon.UpdateSubFrames()
        end)
    end)
    if CountTable(MPLH_ORDER) == 1 then
        frame.UpButton:Disable()
        frame.DownButton:Disable()
    elseif index == 1 then
        frame.UpButton:Disable()
        frame.DownButton:Enable()
    elseif index == #MPLH_ORDER then
        frame.UpButton:Enable()
        frame.DownButton:Disable()
    else
        frame.DownButton:Enable()
        frame.UpButton:Enable()
    end
end

function MPLT_AltManagerMixin:InitElements(frame, elementData)
    local playerID = elementData.playerID
    local data = MPLH_KACDATA[playerID]

    if not frame.slotsCreated then
        CreateItemSlotFrames(frame)
        CreateDungeonSlotFrames(frame)
        frame.slotsCreated = true
    end

    frame.CharacterFrame.CharName:SetText(playerID)
    frame.CharacterFrame.CharName:SetTextScale(0.5)
    Addon.SetNineSlice(frame.CharacterFrame, "characterupdate", 0.38, 0.5, 1, 1)
    frame.CharacterFrame:SetSize(600, 84)
    frame.CharacterFrame:Show()

    SetKeystone(frame, data)
    SetDungeons(frame, data)
    SetIlvlProg(frame, data)
    SetRio(frame, data)
    SetGear(frame, data)
    SetOrderButtons(frame, playerID, elementData)
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
    for i = 1, #MPLH_ORDER do
        DataProvider:Insert({playerID = MPLH_ORDER[i]})
    end
    AltManagerFrame.ScrollBox:SetDataProvider(DataProvider)
    AltManagerFrame.ScrollBar:SetScrollPercentage(scrollPos, true)

    AltManagerFrame:ClearAllPoints()
    AltManagerFrame:SetParent(MPLTLootFrame)
    AltManagerFrame:SetPoint("TOPLEFT", MPLTLootFrame, "TOPLEFT", 5, Addon.Constants.Layout.AltManagerOffsetY)
    AltManagerFrame:SetSize(Addon.Constants.Layout.ContentWidth, 425)
    AltManagerFrame:Hide()
    AltManagerFrame.NineSlice:Hide()
    AltManagerFrame.TitleContainer:Hide()
    AltManagerFrame.ClosePanelButton:Hide()
    AltManagerFrame.ScrollBar:Hide()
    AltManagerFrame.Bg:Hide()
    AltManagerFrame.ScrollBox.Shadows:Hide()
    AltManagerFrame:SetAlpha(1)
end