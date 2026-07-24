local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHAT_MSG_CHANNEL")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")

eventFrame:SetScript("OnEvent", function(_, event, message, sender, language, channelName)
    if event == "PLAYER_LOGIN" then
        -- The roster response is asynchronous. Request it here, then rebuild the
        -- cache when GUILD_ROSTER_UPDATE fires.
        updateGuildMembers(true)

        if DeathFeedDB.hidden then
            setWindowShown(false)
        end

        restoreWindowPosition()
        updateResizeBounds()
        restoreWindowPosition()
        updateLayout()
        trimHistory()
        setupMinimapIcon()
        updateRows(false)

        return
    end

    if event == "GUILD_ROSTER_UPDATE" then
        updateGuildMembers(false)
        return
    end

    if event == "PLAYER_GUILD_UPDATE" then
        updateGuildMembers(true)
        return
    end

    if not isHardcoreDeathChannel(channelName) then
        return
    end

    local death = parseDeathMessage(message)

    if death then
        addDeathMessage(death)
    else
        printParseError(message)
    end
end)
