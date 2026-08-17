local AddonName, Addon = ...

function Addon.RecreateItemLink(itemLink)
    local parts = { strsplit(":", itemLink) }
    local itemContext = parts[14]
    if itemContext ~= "16" then 
        itemContext = 16 
    end
    local numBonuses = parts[15]
    local numModifiers = ""
    local modifiers = ""
    local bonusIDs = ""
    if tonumber(numBonuses) then
        for i=1, tonumber(numBonuses) do
            bonusIDs = bonusIDs.. ":" ..(parts[15 + i] or "")
        end
    else
        numBonuses = "1"
        bonusIDs = ":3524"
    end
    local pos = 16 + (tonumber(numBonuses) or 0)
    numModifiers = parts[pos]
    if tonumber(numModifiers) then
        for i=1, tonumber(numModifiers)*2, 2 do
            local key = parts[pos+i] or ""
            local value = parts[pos+i+1] or ""
            if i == 1 then
                value = "1279"
            end
            modifiers = modifiers..":"..key..":"..value
        end
    else
        numModifiers = "1"
        modifiers = ":28:1279"
    end
    local id = parts[3]
    local linkLevel = parts[11]
    local specializationID = parts[12]
    local text = strmatch(itemLink, "[[](.*)[]]")
    local newLink = "|cnIQ4:|Hitem:"..id.."::::::::"..linkLevel..":"..specializationID..
    "::"..itemContext..":"..numBonuses..bonusIDs..":"..numModifiers..modifiers.."::::|h["..text.."]|h|r"
    return newLink, tonumber(id)
end

function Addon.SplitItemLink(itemLink)
    local s1, s2 = nil, nil
    s1, s2 = strsplit("~", itemLink, 2)
    return s1, s2
end