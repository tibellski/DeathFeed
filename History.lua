local function getMinimumLevel()
    return tonumber(DeathFeedDB.minimumLevel) or 10
end

local function shouldShowRow(row, minimumLevel)
    if row.isGuildDeath == true or isGuildMember(row.name) then
        return true
    end

    return (tonumber(row.level) or 0) >= minimumLevel
end

function getVisibleRows()
    local visibleRows = {}
    local maxRows = getMaxRows()
    local visibleIndex = 1
    local minimumLevel = getMinimumLevel()

    for _, row in ipairs(DeathFeedDB.history) do
        if shouldShowRow(row, minimumLevel) then
            if visibleIndex > historyOffset and #visibleRows < maxRows then
                table.insert(visibleRows, row)
            end

            visibleIndex = visibleIndex + 1
        end
    end

    return visibleRows
end

function getVisibleRowCount()
    local count = 0
    local minimumLevel = getMinimumLevel()

    for _, row in ipairs(DeathFeedDB.history) do
        if shouldShowRow(row, minimumLevel) then
            count = count + 1
        end
    end

    return count
end

function addDeathMessage(death)
    local isGuildDeath = isGuildMember(death.name)
    local row = {
        time = date("%H:%M"),
        name = death.name,
        level = death.level,
        killer = death.killer,
        mobClassification = getMobClassification(death.killer),
        zone = death.zone,
        isGuildDeath = isGuildDeath
    }

    table.insert(DeathFeedDB.history, 1, row)

    trimHistory()

    if DeathFeedDB.playGuildSound and isGuildDeath then
        PlaySound(1172, "Master")
    end

    historyOffset = 0
    updateRows(shouldShowRow(row, getMinimumLevel()))
end
