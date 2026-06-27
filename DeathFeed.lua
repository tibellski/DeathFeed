DeathFeedDB = DeathFeedDB or {}

local newDeathFadeDuration = 0.6
local compactWidth = 160
local killerMinWidth = 285
local fullMinWidth = 410
local maxWindowWidth = 650

local defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
    width = fullMinWidth,
    height = 124,
    hidden = false,
    hideOriginalChat = true,
    playGuildSound = true,
    minimumLevel = 10,
    minimap = {
        hide = false
    },
    history = {}
}

if DeathFeedDB.hideKiller == nil and DeathFeedDB.showKiller ~= nil then
    DeathFeedDB.hideKiller = not DeathFeedDB.showKiller
end

if DeathFeedDB.hideZone == nil and DeathFeedDB.showZone ~= nil then
    DeathFeedDB.hideZone = not DeathFeedDB.showZone
end

if DeathFeedDB.hideHeaders == nil and DeathFeedDB.showHeaders ~= nil then
    DeathFeedDB.hideHeaders = not DeathFeedDB.showHeaders
end

local savedCompactMode = DeathFeedDB.compactMode

if savedCompactMode == nil then
    savedCompactMode = DeathFeedDB.hideKiller == true
        and DeathFeedDB.hideZone == true
        and DeathFeedDB.hideHeaders == true
end

DeathFeedDB.showKiller = nil
DeathFeedDB.showZone = nil
DeathFeedDB.showHeaders = nil
DeathFeedDB.hideKiller = nil
DeathFeedDB.hideZone = nil
DeathFeedDB.hideHeaders = nil

local layoutVersion = tonumber(DeathFeedDB.layoutVersion) or 0

if layoutVersion < 1 then
    if DeathFeedDB.width == 517 then
        DeathFeedDB.width = 477
    end

    layoutVersion = 1
end

if layoutVersion < 2 then
    if DeathFeedDB.width == 477 then
        DeathFeedDB.width = 465
    end

    layoutVersion = 2
end

if layoutVersion < 4 then
    if DeathFeedDB.width == 465 then
        DeathFeedDB.width = 425
    end

    if DeathFeedDB.fullWidth == 465 then
        DeathFeedDB.fullWidth = 425
    end

    layoutVersion = 4
end

if layoutVersion < 5 then
    if DeathFeedDB.width == 425 then
        DeathFeedDB.width = 415
    end

    if DeathFeedDB.fullWidth == 425 then
        DeathFeedDB.fullWidth = 415
    end

    layoutVersion = 5
end

if layoutVersion < 6 then
    if DeathFeedDB.width == 415 then
        DeathFeedDB.width = 420
    end

    if DeathFeedDB.fullWidth == 415 then
        DeathFeedDB.fullWidth = 420
    end

    layoutVersion = 6
end

if layoutVersion < 7 then
    if DeathFeedDB.width == 420 then
        DeathFeedDB.width = 413
    end

    if DeathFeedDB.fullWidth == 420 then
        DeathFeedDB.fullWidth = 413
    end

    layoutVersion = 7
end

if layoutVersion < 8 then
    if DeathFeedDB.width == 413 then
        DeathFeedDB.width = 410
    end

    if DeathFeedDB.fullWidth == 413 then
        DeathFeedDB.fullWidth = 410
    end

    layoutVersion = 8
end

if layoutVersion < 9 then
    if DeathFeedDB.width == 410 then
        DeathFeedDB.width = 400
    end

    if DeathFeedDB.fullWidth == 410 then
        DeathFeedDB.fullWidth = 400
    end

    layoutVersion = 9
end

if layoutVersion < 10 then
    if DeathFeedDB.width == 400 then
        DeathFeedDB.width = 410
    end

    if DeathFeedDB.fullWidth == 400 then
        DeathFeedDB.fullWidth = 410
    end

    layoutVersion = 10
end

if layoutVersion < 11 then
    if savedCompactMode == true then
        DeathFeedDB.width = compactWidth
    elseif (tonumber(DeathFeedDB.width) or compactWidth) < fullMinWidth then
        DeathFeedDB.width = fullMinWidth
    end

    layoutVersion = 11
end

DeathFeedDB.layoutVersion = layoutVersion

copyDefaults(defaults, DeathFeedDB)

DeathFeedDB.width = math.max(compactWidth, math.min(maxWindowWidth, tonumber(DeathFeedDB.width) or compactWidth))

DeathFeedWindow = CreateFrame("Frame", "DeathFeedFrame", UIParent, "BackdropTemplate")
DeathFeedWindow:SetSize(DeathFeedDB.width, DeathFeedDB.height)

DeathFeedWindow:SetPoint(
    DeathFeedDB.point,
    UIParent,
    DeathFeedDB.relativePoint,
    DeathFeedDB.x,
    DeathFeedDB.y
)

DeathFeedWindow:SetMovable(true)
DeathFeedWindow:SetResizable(true)
DeathFeedWindow:EnableMouse(false)
DeathFeedWindow:SetClampedToScreen(true)

local function saveWindowPosition()
    local point, _, relativePoint, x, y = DeathFeedWindow:GetPoint()

    DeathFeedDB.point = point
    DeathFeedDB.relativePoint = relativePoint
    DeathFeedDB.x = x
    DeathFeedDB.y = y
end

local function getCompactModeForWidth(width)
    return (tonumber(width) or compactWidth) < killerMinWidth
end

local function shouldShowKillerColumn(width)
    return (tonumber(width) or compactWidth) >= killerMinWidth
end

local function shouldShowZoneColumn(width)
    return (tonumber(width) or compactWidth) >= fullMinWidth
end

local function syncCompactMode()
    local previousCompactMode = DeathFeedDB.compactMode
    DeathFeedDB.compactMode = getCompactModeForWidth(DeathFeedWindow:GetWidth())
    return previousCompactMode
end

DeathFeedDB.compactMode = getCompactModeForWidth(DeathFeedDB.width)

local function setWindowHeightKeepingTop(height)
    local oldTop = DeathFeedWindow:GetTop()
    local point, relativeTo, relativePoint, x, y = DeathFeedWindow:GetPoint()

    DeathFeedWindow:SetHeight(height)

    local newTop = DeathFeedWindow:GetTop()

    if oldTop and newTop and point then
        DeathFeedWindow:ClearAllPoints()
        DeathFeedWindow:SetPoint(point, relativeTo, relativePoint, x, y + oldTop - newTop)
    end

    DeathFeedDB.height = height
    saveWindowPosition()
end

function updateResizeBounds(previousCompactMode)
    local minHeight = getFrameChromeHeight() + (5 * rowHeight)

    if DeathFeedWindow.SetResizeBounds then
        DeathFeedWindow:SetResizeBounds(compactWidth, minHeight, maxWindowWidth, 500)
    end

    if DeathFeedWindow:GetWidth() < compactWidth then
        DeathFeedWindow:SetWidth(compactWidth)
        DeathFeedDB.width = compactWidth
    elseif DeathFeedWindow:GetWidth() > maxWindowWidth then
        DeathFeedWindow:SetWidth(maxWindowWidth)
        DeathFeedDB.width = maxWindowWidth
    end

    if previousCompactMode ~= nil and previousCompactMode ~= DeathFeedDB.compactMode then
        local previousChromeHeight = getFrameChromeHeight(previousCompactMode)
        local heightDelta = getFrameChromeHeight() - previousChromeHeight
        local newHeight = math.max(minHeight, math.min(500, DeathFeedWindow:GetHeight() + heightDelta))

        setWindowHeightKeepingTop(newHeight)
    elseif DeathFeedWindow:GetHeight() < minHeight then
        setWindowHeightKeepingTop(minHeight)
    end
end

local function scrollHistory(delta)
    local maxOffset = math.max(0, getVisibleRowCount() - getMaxRows())

    if delta < 0 then
        historyOffset = math.min(historyOffset + 1, maxOffset)
    else
        historyOffset = math.max(historyOffset - 1, 0)
    end

    updateRows(false)
end

local titleDragHandle = CreateFrame("Button", nil, DeathFeedWindow)
titleDragHandle:SetPoint("TOPLEFT", 4, -4)
titleDragHandle:SetPoint("TOPRIGHT", -4, -4)
titleDragHandle:SetHeight(22)
titleDragHandle:RegisterForDrag("LeftButton")
titleDragHandle:EnableMouse(true)

titleDragHandle:SetScript("OnDragStart", function()
    DeathFeedWindow:StartMoving()
end)

titleDragHandle:SetScript("OnDragStop", function()
    DeathFeedWindow:StopMovingOrSizing()
    saveWindowPosition()
end)

local resizeHandle = CreateFrame("Button", nil, DeathFeedWindow)
resizeHandle:SetSize(16, 16)
resizeHandle:SetPoint("BOTTOMRIGHT", 0, 0)
resizeHandle:SetHitRectInsets(-4, -4, -4, -4)

resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeHandle:SetFrameLevel(DeathFeedWindow:GetFrameLevel() + 50)
resizeHandle:SetAlpha(0)

local isResizing = false
local resizeHandleFadeDuration = 0.15

resizeHandle:SetScript("OnUpdate", function(self, elapsed)
    local targetAlpha = 0

    if isResizing or DeathFeedWindow:IsMouseOver() then
        targetAlpha = 1
    end

    local alpha = self:GetAlpha()

    if alpha < targetAlpha then
        self:SetAlpha(math.min(targetAlpha, alpha + elapsed / resizeHandleFadeDuration))
    elseif alpha > targetAlpha then
        self:SetAlpha(math.max(targetAlpha, alpha - elapsed / resizeHandleFadeDuration))
    end
end)

resizeHandle:SetScript("OnMouseDown", function(self)
    isResizing = true
    self:SetAlpha(1)
    DeathFeedWindow:StartSizing("BOTTOMRIGHT")
end)

resizeHandle:SetScript("OnMouseUp", function(self)
    isResizing = false
    DeathFeedWindow:StopMovingOrSizing()

    DeathFeedDB.width = DeathFeedWindow:GetWidth()
    DeathFeedDB.height = DeathFeedWindow:GetHeight()

    updateLayout()
    updateRows(false)
end)

DeathFeedWindow:SetScript("OnSizeChanged", function()
    local previousCompactMode = syncCompactMode()

    DeathFeedDB.width = DeathFeedWindow:GetWidth()
    DeathFeedDB.height = DeathFeedWindow:GetHeight()

    if not DeathFeedDB.compactMode then
        DeathFeedDB.fullWidth = DeathFeedDB.width
    end

    updateResizeBounds(previousCompactMode)
    updateLayout()
    updateRows(false)
end)

DeathFeedWindow:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 10,
    insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3
    }
})

DeathFeedWindow:SetBackdropColor(0.05, 0.05, 0.05, 0.90)
DeathFeedWindow:SetBackdropBorderColor(0.55, 0.55, 0.55, 1)

local title = DeathFeedWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 7, -8)
title:SetText("|cffcc4444Death Feed|r")

function getHeaderOffset()
    if shouldShowKillerColumn(DeathFeedWindow:GetWidth()) then
        return 25
    end

    return 10
end

function getFrameChromeHeight(compactMode)
    if compactMode == nil then
        compactMode = not shouldShowKillerColumn(DeathFeedWindow:GetWidth())
    end

    if not compactMode then
        return 44
    end

    return 29
end

function getMaxRows()
    local usableHeight = DeathFeedWindow:GetHeight() - getFrameChromeHeight()
    return math.max(1, math.min(maxHistory, math.floor((usableHeight + 0.01) / rowHeight)))
end

local function makeColumn(parent, x, y, width)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", x, y)
    text:SetWidth(width)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    text:SetNonSpaceWrap(false)
    return text
end

local headerTexts = {}

local function makeHeader(text)
    local header = DeathFeedWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetText(text)
    return header
end

headerTexts.time = makeHeader("|cff888888Time|r")
headerTexts.level = makeHeader("|cff888888Lvl|r")
headerTexts.name = makeHeader("|cff888888Name|r")
headerTexts.killer = makeHeader("|cff888888Killed by|r")
headerTexts.zone = makeHeader("|cff888888Zone|r")

local rowFrames = {}
local rowTexts = {}
local tooltipFadeDuration = 0.15
local tooltipLabelColor = "|cff888888"
local colorReset = "|r"

local function getNameColor(name, row)
    if row and (row.isGuildDeath == true or isGuildMember(name)) then
        return 0.33, 1, 0.33
    end

    return 0.87, 0.87, 0.87
end

local function colorKillerText(killer)
    if killer == "Fall damage" then
        return "|cff996633" .. killer .. colorReset
    elseif killer == "Drowning" then
        return "|cff3399ff" .. killer .. colorReset
    elseif killer == "Lava" then
        return "|cffffaa00" .. killer .. colorReset
    elseif killer == "Fatigue" then
        return "|cff66ccff" .. killer .. colorReset
    end

    return "|cffff7777" .. killer .. colorReset
end

local function colorZoneText(zone)
    if isRaidZone(zone) then
        return "|cffff3333" .. zone .. colorReset
    elseif isDungeonZone(zone) then
        return "|cffb266ff" .. zone .. colorReset
    end

    return "|cffdddddd" .. zone .. colorReset
end

local function makeIcon(texture, width, height)
    width = width or 12
    height = height or width
    return "|T" .. texture .. ":" .. height .. ":" .. width .. ":0:0|t"
end

local mobClassificationMarkers = {
    ["Elite"] = makeIcon("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"),
    ["Rare Elite"] = makeIcon("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"),
    ["World Boss"] = makeIcon("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
}

for i = 1, maxHistory do
    local y = -getHeaderOffset() - (i * rowHeight)

    rowFrames[i] = CreateFrame("Button", nil, DeathFeedWindow)
    rowFrames[i]:SetPoint("TOPLEFT", 6, y + 2)
    rowFrames[i]:SetSize(165, rowHeight)
    rowFrames[i]:SetFrameLevel(DeathFeedWindow:GetFrameLevel() + 10)
    rowFrames[i]:EnableMouse(false)
    rowFrames[i]:EnableMouseWheel(true)
    rowFrames[i]:RegisterForClicks("LeftButtonUp")
    rowFrames[i]:Hide()

    rowFrames[i]:SetScript("OnClick", function(self)
        runWho(self.deathName)
    end)

    rowFrames[i]:SetScript("OnMouseWheel", function(_, delta)
        scrollHistory(delta)
    end)

    rowFrames[i]:SetScript("OnEnter", function(self)
        if self.row then
            local rowName = tostring(self.row.name or "Unknown")
            local rowLevel = tostring(self.row.level or "")
            local rowKiller = tostring(self.row.killer or "Unknown")
            local rowZone = tostring(self.row.zone or "Unknown")
            local mobClassification = self.row.mobClassification or getMobClassification(rowKiller)
            local nameR, nameG, nameB = getNameColor(rowName, self.row)
            local marker = mobClassificationMarkers[mobClassification]
            local markerText = ""

            if marker then
                markerText = marker .. " "
            end

            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(rowName, nameR, nameG, nameB)
            GameTooltip:AddLine(tooltipLabelColor .. "Level: " .. colorReset .. colorLevel(rowLevel))
            GameTooltip:AddLine(tooltipLabelColor .. "Killed by: " .. colorReset .. markerText .. colorKillerText(rowKiller))

            GameTooltip:AddLine(tooltipLabelColor .. "Zone: " .. colorReset .. colorZoneText(rowZone))

            if UIFrameFadeRemoveFrame then
                UIFrameFadeRemoveFrame(GameTooltip)
            end

            GameTooltip:SetAlpha(0)
            GameTooltip:Show()
            UIFrameFadeIn(GameTooltip, tooltipFadeDuration, 0, 1)
        end
    end)

    rowFrames[i]:SetScript("OnLeave", function()
        if UIFrameFadeRemoveFrame then
            UIFrameFadeRemoveFrame(GameTooltip)
        end

        GameTooltip:SetAlpha(1)
        GameTooltip:Hide()
    end)

    rowTexts[i] = {}
    rowTexts[i].time = makeColumn(DeathFeedWindow, 8, y, 35)
    rowTexts[i].level = makeColumn(DeathFeedWindow, 48, y, 22)
    rowTexts[i].name = makeColumn(DeathFeedWindow, 75, y, 80)
    rowTexts[i].killer = makeColumn(DeathFeedWindow, 160, y, 120)
    rowTexts[i].zone = makeColumn(DeathFeedWindow, 285, y, 120)
end

function updateLayout()
    local width = DeathFeedWindow:GetWidth()
    local columnGap = 5
    local zoneRightMargin = 5

    local timeX = 8
    local levelX = 48
    local nameX = 75
    local killerX = 160
    local zoneX = killerX
    local headerY = -24

    local nameWidth = 80
    local killerWidth = 0
    local zoneWidth = 0
    local showKillerColumn = shouldShowKillerColumn(width)
    local showZoneColumn = shouldShowZoneColumn(width)

    if showZoneColumn then
        nameWidth = 80
        killerWidth = (width - killerX - columnGap - zoneRightMargin) / 2
        zoneWidth = killerWidth
        zoneX = killerX + killerWidth + columnGap
    elseif showKillerColumn then
        nameWidth = 80
        killerWidth = width - killerX - zoneRightMargin
    else
        nameWidth = width - nameX - zoneRightMargin
    end

    headerTexts.time:ClearAllPoints()
    headerTexts.time:SetPoint("TOPLEFT", timeX, headerY)

    headerTexts.level:ClearAllPoints()
    headerTexts.level:SetPoint("TOPLEFT", levelX, headerY)

    headerTexts.name:ClearAllPoints()
    headerTexts.name:SetPoint("TOPLEFT", nameX, headerY)

    headerTexts.killer:ClearAllPoints()
    headerTexts.killer:SetPoint("TOPLEFT", killerX, headerY)

    headerTexts.zone:ClearAllPoints()
    headerTexts.zone:SetPoint("TOPLEFT", zoneX, headerY)

    headerTexts.time:SetShown(showKillerColumn)
    headerTexts.level:SetShown(showKillerColumn)
    headerTexts.name:SetShown(showKillerColumn)
    headerTexts.killer:SetShown(showKillerColumn)
    headerTexts.zone:SetShown(showZoneColumn)

    for i = 1, maxHistory do
        local rowY = -getHeaderOffset() - (i * rowHeight)

        rowFrames[i]:ClearAllPoints()
        rowFrames[i]:SetPoint("TOPLEFT", 6, rowY + 2)
        rowFrames[i]:SetSize(math.max(1, width - 14), rowHeight)

        rowTexts[i].time:ClearAllPoints()
        rowTexts[i].time:SetPoint("TOPLEFT", timeX, rowY)
        rowTexts[i].time:SetWidth(35)

        rowTexts[i].level:ClearAllPoints()
        rowTexts[i].level:SetPoint("TOPLEFT", levelX, rowY)
        rowTexts[i].level:SetWidth(22)

        rowTexts[i].name:ClearAllPoints()
        rowTexts[i].name:SetPoint("TOPLEFT", nameX, rowY)
        rowTexts[i].name:SetWidth(math.max(40, nameWidth))

        rowTexts[i].killer:ClearAllPoints()
        rowTexts[i].killer:SetPoint("TOPLEFT", killerX, rowY)
        rowTexts[i].killer:SetWidth(killerWidth)

        rowTexts[i].zone:ClearAllPoints()
        rowTexts[i].zone:SetPoint("TOPLEFT", zoneX, rowY)
        rowTexts[i].zone:SetWidth(zoneWidth)

        rowTexts[i].killer:SetShown(showKillerColumn)
        rowTexts[i].zone:SetShown(showZoneColumn)
    end
end

function updateRows(animated)
    trimHistory()

    local maxRows = getMaxRows()
    local visibleRows = getVisibleRows()
    local width = DeathFeedWindow:GetWidth()
    local showKillerColumn = shouldShowKillerColumn(width)
    local showZoneColumn = shouldShowZoneColumn(width)

    for i = 1, maxHistory do
        local row = visibleRows[i]

        if i <= maxRows and row then
            local rowTime = tostring(row.time or "")
            local rowLevel = tostring(row.level or "")
            local rowName = tostring(row.name or "Unknown")
            local rowKiller = tostring(row.killer or "Unknown")
            local rowZone = tostring(row.zone or "Unknown")
            local mobClassification = row.mobClassification or getMobClassification(rowKiller)

            rowFrames[i].row = row
            rowFrames[i].deathName = rowName
            rowFrames[i]:EnableMouse(true)
            rowFrames[i]:Show()

            rowTexts[i].time:SetText("|cff888888" .. rowTime .. "|r")

            rowTexts[i].level:SetText(colorLevel(rowLevel))

            if row.isGuildDeath == true or isGuildMember(rowName) then
                rowTexts[i].name:SetText("|cff55ff55" .. rowName .. "|r")
            else
                rowTexts[i].name:SetText("|cffdddddd" .. rowName .. "|r")
            end
            
            if rowKiller == "Fall damage" then
                rowTexts[i].killer:SetText("|cff996633" .. rowKiller .. "|r")
            elseif rowKiller == "Drowning" then
                rowTexts[i].killer:SetText("|cff3399ff" .. rowKiller .. "|r")
            elseif rowKiller == "Lava" then
                rowTexts[i].killer:SetText("|cffffaa00" .. rowKiller .. "|r")
            elseif rowKiller == "Fatigue" then
                rowTexts[i].killer:SetText("|cff66ccff" .. rowKiller .. "|r")
            else
                local marker = mobClassificationMarkers[mobClassification]
                local markerText = ""

                if marker then
                    markerText = marker .. " "
                end

                rowTexts[i].killer:SetText(markerText .. "|cffff7777" .. rowKiller .. "|r")
            end

            local zoneColor = "|cffcccccc"

            if isRaidZone(rowZone) then
                zoneColor = "|cffff3333"
            elseif isDungeonZone(rowZone) then
                zoneColor = "|cffb266ff"
            end

            rowTexts[i].zone:SetText(zoneColor .. rowZone .. "|r")

            rowTexts[i].time:Show()
            rowTexts[i].level:Show()
            rowTexts[i].name:Show()

            rowTexts[i].killer:SetShown(showKillerColumn)
            rowTexts[i].zone:SetShown(showZoneColumn)

            if animated and i == 1 and historyOffset == 0 then
                rowTexts[i].time:SetAlpha(0)
                rowTexts[i].level:SetAlpha(0)
                rowTexts[i].name:SetAlpha(0)
                if showKillerColumn then
                    rowTexts[i].killer:SetAlpha(0)
                end

                if showZoneColumn then
                    rowTexts[i].zone:SetAlpha(0)
                end

                UIFrameFadeIn(rowTexts[i].time, newDeathFadeDuration, 0, 1)
                UIFrameFadeIn(rowTexts[i].level, newDeathFadeDuration, 0, 1)
                UIFrameFadeIn(rowTexts[i].name, newDeathFadeDuration, 0, 1)
                if showKillerColumn then
                    UIFrameFadeIn(rowTexts[i].killer, newDeathFadeDuration, 0, 1)
                end

                if showZoneColumn then
                    UIFrameFadeIn(rowTexts[i].zone, newDeathFadeDuration, 0, 1)
                end
            else
                rowTexts[i].time:SetAlpha(1)
                rowTexts[i].level:SetAlpha(1)
                rowTexts[i].name:SetAlpha(1)
                rowTexts[i].killer:SetAlpha(1)
                rowTexts[i].zone:SetAlpha(1)
            end
        else
            rowFrames[i].row = nil
            rowFrames[i].deathName = nil
            rowFrames[i]:EnableMouse(false)
            rowFrames[i]:Hide()

            rowTexts[i].time:SetText("")
            rowTexts[i].level:SetText("")
            rowTexts[i].name:SetText("")
            rowTexts[i].killer:SetText("")
            rowTexts[i].zone:SetText("")

            rowTexts[i].time:Hide()
            rowTexts[i].level:Hide()
            rowTexts[i].name:Hide()
            rowTexts[i].killer:Hide()
            rowTexts[i].zone:Hide()
        end
    end
end

function printParseError(message)
    printMessage("Failed to parse death message:")
    printMessage(message)
    printMessage("Please report this parser issue and include the message above:")
    printMessage("https://www.curseforge.com/wow/addons/deathfeed/comments")
end

function setWindowShown(shown)
    DeathFeedDB.hidden = not shown

    if shown then
        DeathFeedWindow:Show()
    else
        DeathFeedWindow:Hide()
    end
end

function isWindowShown()
    return DeathFeedWindow:IsShown()
end
