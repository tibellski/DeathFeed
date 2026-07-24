SLASH_DEATHFEED1 = "/deathfeed"
SLASH_DEATHFEED2 = "/df"

local function printCommandHelp()
    printMessage("Commands:")
    printMessage("/deathfeed - Show or hide the feed.")
    printMessage("/deathfeed show - Show the feed.")
    printMessage("/deathfeed hide - Hide the feed.")
    printMessage("/deathfeed clear - Clear history.")
    printMessage("/deathfeed reset - Reset and show the feed window.")
    printMessage("/deathfeed chat on - Hide original HardcoreDeaths chat.")
    printMessage("/deathfeed chat off - Show original HardcoreDeaths chat.")
    printMessage("/deathfeed minimap - Show or hide the minimap icon.")
    printMessage("/deathfeed testguild - Test guild color and sound locally.")
    printMessage("/deathfeed help - Show this help.")
end

local function addGuildDeathTest()
    updateGuildMembers(false)

    local playerName = UnitName("player")
    if not playerName or not isGuildMember(playerName) then
        printMessage("Guild test failed: your character was not found in the loaded guild roster.")
        return
    end

    local testName = getRandomOnlineGuildMember(playerName)
    if not testName then
        printMessage("Guild test unavailable: no other online guild member was found.")
        return
    end

    if not DeathFeedDB.playGuildSound then
        printMessage("Guild test stopped: enable 'Play sound on guild death' in the options first.")
        return
    end

    local zone = GetRealZoneText and GetRealZoneText() or "Test Zone"
    addDeathMessage({
        name = testName,
        level = tostring(UnitLevel("player") or 1),
        killer = "DeathFeed Test Dummy",
        zone = zone ~= "" and zone or "Test Zone"
    })

    setWindowShown(true)
    printMessage("Guild test added locally for " .. testName .. ". The new row should be green and a sound should have played.")
end

local function runGuildDeathTest()
    if not IsInGuild() then
        printMessage("Guild test unavailable: this character is not in a guild.")
        return
    end

    -- Ask the server for a fresh roster, then test through the same history,
    -- guild-color and sound path used by a real death message.
    updateGuildMembers(true)

    if C_Timer and C_Timer.After then
        C_Timer.After(1, addGuildDeathTest)
    else
        addGuildDeathTest()
    end
end

SlashCmdList["DEATHFEED"] = function(input)
    input = string.lower(input or "")

    if input == "" then
        setWindowShown(not isWindowShown())
    elseif input == "show" then
        setWindowShown(true)
    elseif input == "hide" then
        setWindowShown(false)
    elseif input == "clear" then
        wipe(DeathFeedDB.history)
        historyOffset = 0
        updateRows(false)
        printMessage("History cleared.")
    elseif input == "reset" then
        DeathFeedDB.point = "CENTER"
        DeathFeedDB.relativePoint = "CENTER"
        DeathFeedDB.x = 0
        DeathFeedDB.y = 0
        DeathFeedDB.hidden = false

        restoreWindowPosition()
        setWindowShown(true)
        printMessage("Window reset.")
    elseif input == "chat on" then
        DeathFeedDB.hideOriginalChat = true
        printMessage("Original HardcoreDeaths chat hidden.")
    elseif input == "chat off" then
        DeathFeedDB.hideOriginalChat = false
        printMessage("Original HardcoreDeaths chat visible.")
    elseif input == "minimap" then
        DeathFeedDB.minimap.hide = not DeathFeedDB.minimap.hide

        if ldbIcon then
            if DeathFeedDB.minimap.hide then
                ldbIcon:Hide("DeathFeed")
                printMessage("Minimap icon hidden.")
            else
                ldbIcon:Show("DeathFeed")
                printMessage("Minimap icon shown.")
            end
        end
    elseif input == "testguild" then
        runGuildDeathTest()
    elseif input == "help" then
        printCommandHelp()
    else
        printMessage("Unknown command: " .. input)
        printCommandHelp()
    end
end
