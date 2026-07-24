local failures = 0

local function assertEqual(actual, expected, label)
    if actual ~= expected then
        failures = failures + 1
        print(string.format("FAIL: %s (expected %s, got %s)", label, tostring(expected), tostring(actual)))
    end
end

function wipe(tableToWipe)
    for key in pairs(tableToWipe) do
        tableToWipe[key] = nil
    end
end

function IsInGuild()
    return true
end

local members = {
    { name = "Alice-Realm", isOnline = true },
    { name = "Bob", isOnline = true }
}

function GetNumGuildMembers()
    return #members
end

function GetGuildRosterInfo(index)
    local member = members[index]
    return member.name, nil, nil, nil, nil, nil, nil, nil, member.isOnline
end

DeathFeedDB = { history = {} }
maxHistory = 100

dofile("Utils.lua")

local namespaceRequests = 0
C_GuildInfo = {
    GuildRoster = function()
        namespaceRequests = namespaceRequests + 1
    end
}

updateGuildMembers(true)
assertEqual(namespaceRequests, 1, "requests roster through C_GuildInfo")
assertEqual(isGuildMember("Alice"), true, "stores name without realm")
assertEqual(isGuildMember("Bob"), true, "stores unqualified name")

members = {
    { name = "Charlie-Realm", isOnline = true },
    { name = "OfflineMember-Realm", isOnline = false }
}
updateGuildMembers(false)
assertEqual(namespaceRequests, 1, "does not request roster from update event")
assertEqual(isGuildMember("Alice"), false, "removes stale guild member")
assertEqual(isGuildMember("Charlie"), true, "rebuilds roster from update event")

members = {
    { name = "Incomplete-Realm", isOnline = true },
    { name = nil, isOnline = false }
}
updateGuildMembers(false)
assertEqual(isGuildMember("Charlie"), true, "keeps last complete roster during partial update")
assertEqual(isGuildMember("Incomplete"), false, "does not publish a partial roster")

C_GuildInfo = nil
local legacyRequests = 0
GuildRoster = function()
    legacyRequests = legacyRequests + 1
end

updateGuildMembers(true)
assertEqual(legacyRequests, 1, "falls back to legacy GuildRoster")

GuildRoster = nil
local ok = pcall(updateGuildMembers, true)
assertEqual(ok, true, "does not fail when neither roster request API exists")

if failures > 0 then
    os.exit(1)
end

print("All Utils tests passed")
