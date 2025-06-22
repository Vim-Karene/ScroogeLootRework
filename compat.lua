-- get num group members backport
local addon = LibStub("AceAddon-3.0"):GetAddon("ScroogeLoot")

-- Backfill string helpers missing in the 3.3.5a Lua API
if not string.split then
    ---Split a string using the WoW provided `strsplit` helper.
    ---@param sep string
    ---@param str string
    ---@return ...
    function string.split(sep, str)
        return strsplit(sep, str)
    end
end

if not string.trim then
    ---Trim a string using the WoW provided `strtrim` helper.
    ---@param str string
    ---@return string
    function string.trim(str)
        return strtrim(str)
    end
end

function addon:IsInRaid() 
    return GetNumRaidMembers() > 0
end

function addon:IsInGroup()
    return (GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0)
end

function addon:GetNumGroupMembers()
    if addon:IsInRaid() then 
        return GetNumRaidMembers()
    else
        return GetNumPartyMembers()
    end
end

function addon:UnitIsGroupLeader(unit)
    if UnitIsGroupLeader then
        return UnitIsGroupLeader(unit)
    end
    unit = unit or "player"
    if unit == "player" then
        if addon:IsInRaid() then
            return IsRaidLeader()
        elseif addon:IsInGroup() then
            return IsPartyLeader()
        end
        return true
    end

    if UnitInRaid(unit) then
        local index = GetPartyLeaderIndex()
        return index > 0 and UnitIsUnit(unit, "raid" .. index)
    elseif UnitInParty(unit) then
        local index = GetPartyLeaderIndex()
        if index == 0 then
            return unit == "player"
        else
            return UnitIsUnit(unit, "party" .. index)
        end
    end
    return false
end
