dofile("DungeonData.lua")

local dungeonNames = {
    enUS = {
        "Ragefire Chasm", "The Deadmines", "Wailing Caverns", "Shadowfang Keep",
        "Blackfathom Deeps", "The Stockade", "Gnomeregan", "Razorfen Kraul",
        "Scarlet Monastery", "Razorfen Downs", "Uldaman", "Maraudon", "Zul'Farrak",
        "The Temple of Atal'Hakkar", "Blackrock Depths", "Blackrock Spire", "Stratholme",
        "Dire Maul", "Scholomance"
    },
    deDE = {
        "Ragefireabgrund", "Die Todesminen", "Die Höhlen des Wehklagens", "Burg Shadowfang",
        "Blackfathom-Tiefe", "Das Verlies", "Gnomeregan", "Der Kral von Razorfen",
        "Das Scharlachrote Kloster", "Die Hügel von Razorfen", "Uldaman", "Maraudon",
        "Zul'Farrak", "Der Tempel von Atal'Hakkar", "Blackrocktiefen", "Blackrockspitze",
        "Stratholme", "Düsterbruch", "Scholomance"
    },
    frFR = {
        "Gouffre de Ragefeu", "Les Mortemines", "Cavernes des lamentations",
        "Donjon d'Ombrecroc", "Profondeurs de Brassenoire", "La Prison", "Gnomeregan",
        "Kraal de Tranchebauge", "Monastère écarlate", "Souilles de Tranchebauge", "Uldaman",
        "Maraudon", "Zul'Farrak", "Le temple d'Atal'Hakkar", "Profondeurs de Blackrock",
        "Pic Blackrock", "Stratholme", "Hache-tripes", "Scholomance"
    }
}

local raidNames = {
    enUS = {
        "Molten Core", "Onyxia's Lair", "Blackwing Lair", "Zul'Gurub",
        "Ruins of Ahn'Qiraj", "Ahn'Qiraj", "Naxxramas"
    },
    deDE = {
        "Geschmolzener Kern", "Onyxias Hort", "Pechschwingenhort", "Zul'Gurub",
        "Ruinen von Ahn'Qiraj", "Ahn'Qiraj", "Naxxramas"
    },
    frFR = {
        "Cœur du Magma", "Repaire d'Onyxia", "Repaire de l'Aile noire", "Zul'Gurub",
        "Ruines d'Ahn'Qiraj", "Ahn'Qiraj", "Naxxramas"
    }
}

local failures = 0
local dungeonCount = 0
local raidCount = 0

for locale, names in pairs(dungeonNames) do
    for _, zone in ipairs(names) do
        dungeonCount = dungeonCount + 1

        if not isDungeonZone(zone, locale) then
            failures = failures + 1
            print(string.format("FAIL: %s dungeon %s", locale, zone))
        end
    end
end

for locale, names in pairs(raidNames) do
    for _, zone in ipairs(names) do
        raidCount = raidCount + 1

        if not isRaidZone(zone, locale) then
            failures = failures + 1
            print(string.format("FAIL: %s raid %s", locale, zone))
        end
    end
end

local behaviorCases = {
    { name = "English locale alias", actual = isDungeonZone("The Deadmines", "enGB"), expected = true },
    { name = "case insensitive", actual = isDungeonZone("deadmines", "enUS"), expected = true },
    { name = "normal zone", actual = isDungeonZone("Westfall", "enUS"), expected = false },
    { name = "dungeon is not raid", actual = isRaidZone("Blackrock Depths", "enUS"), expected = false },
    { name = "nil dungeon", actual = isDungeonZone(nil, "enUS"), expected = false },
    { name = "nil raid", actual = isRaidZone(nil, "enUS"), expected = false }
}

for _, case in ipairs(behaviorCases) do
    if case.actual ~= case.expected then
        failures = failures + 1
        print(string.format("FAIL: %s", case.name))
    end
end

if failures > 0 then
    error(string.format("%d instance data test(s) failed", failures))
end

print(string.format(
    "Instance data tests passed: %d dungeon names, %d raid names, %d behavior cases",
    dungeonCount,
    raidCount,
    #behaviorCases
))
