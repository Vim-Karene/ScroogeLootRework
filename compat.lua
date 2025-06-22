-- get num group members backport
local addon = LibStub("AceAddon-3.0"):GetAddon("ScroogeLoot")

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
