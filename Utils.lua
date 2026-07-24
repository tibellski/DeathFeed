local guildMembers = {}

function copyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end

            copyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function trimHistory()
    while #DeathFeedDB.history > maxHistory do
        table.remove(DeathFeedDB.history)
    end
end

function printMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[DeathFeed]|r " .. message)
end

function isHardcoreDeathChannel(channelName)
    return channelName
        and (
            string.find(channelName, "HardcoreDeaths")
            or string.find(channelName, "Morts extrêmes")
            or string.find(channelName, "HardcoreTode")
        )
end

function runWho(name)
    if not name or name == "" then
        return
    end

    if C_FriendList and C_FriendList.SendWho then
        C_FriendList.SendWho(name)
    elseif SendWho then
        SendWho(name)
    else
        ChatFrame_OpenChat("/who " .. name)
    end
end

function isGuildMember(name)
    return guildMembers[name] == true
end

function colorLevel(level)
    local number = tonumber(level)

    if not number then
        return level
    end

    if number >= 50 then
        return "|cffff3333" .. level .. "|r"
    elseif number >= 30 then
        return "|cffff8800" .. level .. "|r"
    elseif number >= 20 then
        return "|cffffff00" .. level .. "|r"
    else
        return "|cff88ff88" .. level .. "|r"
    end
end

local function requestGuildRoster()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
end

function updateGuildMembers(requestRefresh)
    if not IsInGuild() then
        wipe(guildMembers)
        return
    end

    if requestRefresh then
        requestGuildRoster()
    end

    local memberCount = GetNumGuildMembers()
    local newGuildMembers = {}
    local loadedMemberCount = 0

    for i = 1, memberCount do
        local fullName = GetGuildRosterInfo(i)

        if fullName then
            local name = string.match(fullName, "([^%-]+)") or fullName
            newGuildMembers[name] = true
            loadedMemberCount = loadedMemberCount + 1
        end
    end

    -- Roster data can arrive in partial snapshots. Keep the last complete cache
    -- until every entry reported by GetNumGuildMembers is readable.
    if memberCount > 0 and loadedMemberCount == memberCount then
        guildMembers = newGuildMembers
    end
end
