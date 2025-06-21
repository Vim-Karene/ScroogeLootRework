local addon = LibStub("AceAddon-3.0"):GetAddon("ScroogeLoot")
local PlayerData = addon:NewModule("SLPlayerData")

function PlayerData:OnInitialize()
    self.db = addon:GetPlayerDB()
    self.db.players = self.db.players or {}
end

function PlayerData:Get(name)
    return self.db.players[name]
end

function PlayerData:Add(name, class)
    if not self.db.players[name] then
        self.db.players[name] = {
            name = name,
            class = class,
            raiderrank = false,
            SP = 0,
            DP = 0,
            attended = 0,
            absent = 0,
            attendance = 0,
            item1 = "",
            item1recieved = false,
            item2 = "",
            item2recieved = false,
            item3 = "",
            item3recieved = false,
        }
    end
end

function PlayerData:UpdateAttendance(name)
    local p = self:Get(name)
    if p then
        local total = p.attended + p.absent
        if total > 0 then
            p.attendance = math.floor((p.attended / total) * 100 + 0.5)
        else
            p.attendance = 0
        end
    end
end

function PlayerData:SendUpdate()
    if addon.isMasterLooter then
        addon:SendCommand("group", "playerdata_update", self.db.players)
    end
end

function PlayerData:RewardRaidDay()
    if not addon.isMasterLooter then return end
    local raid = {}
    if addon:IsInRaid() then
        for i = 1, addon:GetNumGroupMembers() do
            local name, _, _, _, _, class = GetRaidRosterInfo(i)
            if name then
                raid[#raid+1] = name
                self:Add(name, class)
                local p = self.db.players[name]
                if p.raiderrank then
                    p.SP = (p.SP or 0) + 5
                end
                p.attended = (p.attended or 0) + 1
                self:UpdateAttendance(name)
            end
        end
    end
    for name, p in pairs(self.db.players) do
        if not tContains(raid, name) then
            p.absent = (p.absent or 0) + 1
            self:UpdateAttendance(name)
        end
    end
    self:SendUpdate()
end

function PlayerData:Apply(data)
    self.db.players = data or {}
end

function PlayerData:ExportXML()
    local out = "<players>"
    for name,p in pairs(self.db.players) do
        out = out..string.format("<player name='%s' class='%s' raiderrank='%s' SP='%d' DP='%d' attended='%d' absent='%d' attendance='%d' item1='%s' item1recieved='%s' item2='%s' item2recieved='%s' item3='%s' item3recieved='%s'/>",
            p.name, p.class or "", tostring(p.raiderrank), p.SP or 0, p.DP or 0, p.attended or 0, p.absent or 0, p.attendance or 0,
            p.item1 or "", tostring(p.item1recieved), p.item2 or "", tostring(p.item2recieved), p.item3 or "", tostring(p.item3recieved))
    end
    out = out .. "</players>"
    return out
end

function PlayerData:ImportXML(xml)
    wipe(self.db.players)
    for attrs in xml:gmatch("<player ([^/>]+)/>") do
        local p = {}
        for k,v in attrs:gmatch("(.-)='(.-)'") do
            if k == "SP" or k == "DP" or k == "attended" or k == "absent" or k == "attendance" then
                p[k] = tonumber(v)
            elseif k == "raiderrank" or k:find("recieved") then
                p[k] = v == "true"
            else
                p[k] = v
            end
        end
        self.db.players[p.name] = p
    end
    self:SendUpdate()
end

addon.PlayerData = PlayerData

