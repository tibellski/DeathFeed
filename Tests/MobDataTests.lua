function GetLocale()
    return "enUS"
end

dofile("MobData.lua")

local cases = {
    { name = "elite", mob = "Son of Arugal", locale = "enUS", expected = "Elite" },
    { name = "rare elite", mob = "Humar the Pridelord", locale = "enUS", expected = "Rare Elite" },
    { name = "world boss", mob = "Onyxia", locale = "enUS", expected = "World Boss" },
    { name = "rare", mob = "Broken Tooth", locale = "enUS", expected = "Rare" },
    { name = "German localization", mob = "Grimmeiche", locale = "deDE", expected = "Elite" },
    { name = "French localization", mob = "Froncechêne", locale = "frFR", expected = "Elite" },
    { name = "English locale alias", mob = "Onyxia", locale = "enGB", expected = "World Boss" },
    { name = "normal mob", mob = "Defias Pillager", locale = "enUS", expected = nil },
}

local failures = 0

for _, case in ipairs(cases) do
    local actual = getMobClassification(case.mob, case.locale)

    if actual ~= case.expected then
        failures = failures + 1
        print(string.format(
            "FAIL: %s (expected %s, got %s)",
            case.name,
            tostring(case.expected),
            tostring(actual)
        ))
    else
        print("PASS: " .. case.name)
    end
end

if failures > 0 then
    error(string.format("%d mob data test(s) failed", failures))
end

print(string.format("All %d mob data tests passed", #cases))
