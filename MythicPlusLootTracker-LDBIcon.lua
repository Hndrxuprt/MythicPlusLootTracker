local AddonName, Addon = ...

function Addon:InitIcon()
    local icon = LibStub("LibDBIcon-1.0")
    local MPLTLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MythicPlusLootTracker", {
        type = "data source",
        text = Addon.localization.addonName,
        icon = "interface/icons/inv_bfa_paragoncache_orderofembers.blp",
        OnClick = function(button, buttonPressed)
            if buttonPressed == "LeftButton" then
                Addon.ToggleMainWindow()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then
                return
            end
            tooltip:AddLine(Addon.Constants.Color.Brand..Addon.localization.addonName.."|r")
            tooltip:AddLine("|cFFFFFFFF" .. Addon.localization.mbutton)
        end,
    })

    icon:Register("MythicPlusLootTracker", MPLTLDB, Addon.DB.global.minimap)
end

function Addon:Init()
    Addon.DB = LibStub("AceDB-3.0"):New("MPLTOptions", {
        global = {
            minimap = {
                hide = false,
            },
        },
    })
    Addon:InitIcon()
end