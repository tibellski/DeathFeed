local dungeonZoneNames = {
    "Ragefire Chasm",
    "Wailing Caverns",
    "The Deadmines",
    "Deadmines",
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
    "Zul'Farrak",
    "Maraudon",
    "The Temple of Atal'Hakkar",
    "Temple of Atal'Hakkar",
    "Sunken Temple",
    "Blackrock Depths",
    "Blackrock Spire",
    "Lower Blackrock Spire",
    "Upper Blackrock Spire",
    "Dire Maul",
    "Scholomance",
    "Stratholme"
}

local raidZoneNames = {
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

for _, zone in ipairs(dungeonZoneNames) do
    dungeonZones[normalizeZoneName(zone)] = true
end

for _, zone in ipairs(raidZoneNames) do
    raidZones[normalizeZoneName(zone)] = true
end

function isDungeonZone(zone)
    local normalizedZone = normalizeZoneName(zone)
    return normalizedZone and dungeonZones[normalizedZone] == true or false
end

function isRaidZone(zone)
    local normalizedZone = normalizeZoneName(zone)
    return normalizedZone and raidZones[normalizedZone] == true or false
end
