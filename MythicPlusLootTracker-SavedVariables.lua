local AddonName, Addon = ...

function Addon.OnAddonLoaded(addOnName)
    if addOnName ~= AddonName then
        return
    end

    if MPLH_ENC == nil then
        MPLH_ENC = {}
    end
    if MPLH_ENC[Addon.currentSeason] == nil then
        MPLH_ENC[Addon.currentSeason] = {}
    end
    if MPLH_ENC_ENDED == nil then
        MPLH_ENC_ENDED = {}
    end
    if MPLH_ENC_ENDED[Addon.currentSeason] == nil then
        MPLH_ENC_ENDED[Addon.currentSeason] = {}
    end
    if MPLH_TRACKITEM == nil then
        MPLH_TRACKITEM = {}
    end
    if MPLH_TRACKITEM_ORDER == nil then
        MPLH_TRACKITEM_ORDER = {}
    end
    if MPLH_TRACKEDITEM_ITEMORDER == nil then
        MPLH_TRACKEDITEM_ITEMORDER = {}
    end
    if MPLH_KACDATA == nil then
        MPLH_KACDATA = {}
    end
    if MPLH_ORDER == nil then
        MPLH_ORDER = {}
    end

    Addon:Init()
end