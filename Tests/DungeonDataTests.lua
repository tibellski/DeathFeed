dofile("DungeonData.lua")

local cases = {
    { zone = "The Deadmines", expected = true },
    { zone = "deadmines", expected = true },
    { zone = "  Blackrock   Depths  ", expected = true },
    { zone = "Upper Blackrock Spire", expected = true },
    { zone = "Westfall", expected = false },
    { zone = nil, expected = false }
}

for index, case in ipairs(cases) do
    local actual = isDungeonZone(case.zone)

    if actual ~= case.expected then
        error(string.format(
            "Dungeon data test %d failed: expected %s, got %s",
            index,
            tostring(case.expected),
            tostring(actual)
        ))
    end
end

local raidCases = {
    { zone = "Molten Core", expected = true },
    { zone = "onyxia's lair", expected = true },
    { zone = "  Temple   of Ahn'Qiraj ", expected = true },
    { zone = "Naxxramas", expected = true },
    { zone = "Stranglethorn Vale", expected = false },
    { zone = "Blackrock Depths", expected = false },
    { zone = nil, expected = false }
}

for index, case in ipairs(raidCases) do
    local actual = isRaidZone(case.zone)

    if actual ~= case.expected then
        error(string.format(
            "Raid data test %d failed: expected %s, got %s",
            index,
            tostring(case.expected),
            tostring(actual)
        ))
    end
end

print(string.format(
    "Instance data tests passed: %d dungeon, %d raid",
    #cases,
    #raidCases
))
