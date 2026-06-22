local dungeonZoneNames = {
    enUS = {
        "Ragefire Chasm",
        "The Deadmines",
        "Deadmines",
        "Wailing Caverns",
        "Shadowfang Keep",
        "Blackfathom Deeps",
        "The Stockade",
        "The Stockades",
        "Stormwind Stockade",
        "Stormwind Stockades",
        "Gnomeregan",
        "Razorfen Kraul",
        "Scarlet Monastery",
        "Razorfen Downs",
        "Uldaman",
        "Maraudon",
        "Zul'Farrak",
        "The Temple of Atal'Hakkar",
        "Temple of Atal'Hakkar",
        "Sunken Temple",
        "Blackrock Depths",
        "Blackrock Spire",
        "Lower Blackrock Spire",
        "Upper Blackrock Spire",
        "Stratholme",
        "Dire Maul",
        "Scholomance"
    },
    deDE = {
        "Ragefireabgrund",
        "Die Todesminen",
        "Die Höhlen des Wehklagens",
        "Burg Shadowfang",
        "Blackfathom-Tiefe",
        "Das Verlies",
        "Gnomeregan",
        "Der Kral von Razorfen",
        "Das Scharlachrote Kloster",
        "Die Hügel von Razorfen",
        "Uldaman",
        "Maraudon",
        "Zul'Farrak",
        "Der Tempel von Atal'Hakkar",
        "Blackrocktiefen",
        "Blackrockspitze",
        "Stratholme",
        "Düsterbruch",
        "Scholomance"
    },
    frFR = {
        "Gouffre de Ragefeu",
        "Les Mortemines",
        "Cavernes des lamentations",
        "Donjon d'Ombrecroc",
        "Profondeurs de Brassenoire",
        "La Prison",
        "Gnomeregan",
        "Kraal de Tranchebauge",
        "Monastère écarlate",
        "Souilles de Tranchebauge",
        "Uldaman",
        "Maraudon",
        "Zul'Farrak",
        "Le temple d'Atal'Hakkar",
        "Profondeurs de Blackrock",
        "Pic Blackrock",
        "Stratholme",
        "Hache-tripes",
        "Scholomance"
    }
}

local raidZoneNames = {
    enUS = {
        "Molten Core",
        "Onyxia's Lair",
        "Blackwing Lair",
        "Zul'Gurub",
        "Ruins of Ahn'Qiraj",
        "The Ruins of Ahn'Qiraj",
        "Ahn'Qiraj",
        "Temple of Ahn'Qiraj",
        "The Temple of Ahn'Qiraj",
        "Ahn'Qiraj Temple",
        "Naxxramas"
    },
    deDE = {
        "Geschmolzener Kern",
        "Onyxias Hort",
        "Pechschwingenhort",
        "Zul'Gurub",
        "Ruinen von Ahn'Qiraj",
        "Ahn'Qiraj",
        "Naxxramas"
    },
    frFR = {
        "Cœur du Magma",
        "Repaire d'Onyxia",
        "Repaire de l'Aile noire",
        "Zul'Gurub",
        "Ruines d'Ahn'Qiraj",
        "Ahn'Qiraj",
        "Naxxramas"
    }
}

local localeAliases = {
    enGB = "enUS"
}

local dungeonZones = {}
local raidZones = {}

local function normalizeZoneName(zone)
    if type(zone) ~= "string" then
        return nil
    end

    zone = string.gsub(zone, "^%s*(.-)%s*$", "%1")
    zone = string.gsub(zone, "%s+", " ")
    return string.lower(zone)
end

local function createZoneLookups(zoneNames)
    local lookups = {}

    for locale, names in pairs(zoneNames) do
        local lookup = {}

        for _, zone in ipairs(names) do
            lookup[normalizeZoneName(zone)] = true
        end

        lookups[locale] = lookup
    end

    return lookups
end

local function getDataLocale(locale)
    if not locale and type(GetLocale) == "function" then
        locale = GetLocale()
    end

    locale = localeAliases[locale] or locale

    if not dungeonZoneNames[locale] then
        return "enUS"
    end

    return locale
end

dungeonZones = createZoneLookups(dungeonZoneNames)
raidZones = createZoneLookups(raidZoneNames)

function isDungeonZone(zone, locale)
    local normalizedZone = normalizeZoneName(zone)
    local localizedZones = dungeonZones[getDataLocale(locale)]
    return normalizedZone and localizedZones[normalizedZone] == true or false
end

function isRaidZone(zone, locale)
    local normalizedZone = normalizeZoneName(zone)
    local localizedZones = raidZones[getDataLocale(locale)]
    return normalizedZone and localizedZones[normalizedZone] == true or false
end
