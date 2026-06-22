DeathFeedDB = DeathFeedDB or {}

local newDeathFadeDuration = 0.6

local defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
    width = 180,
    height = 124,
    hidden = false,
    hideOriginalChat = true,
    compactMode = false,
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

if DeathFeedDB.compactMode == nil then
    DeathFeedDB.compactMode = DeathFeedDB.hideKiller == true
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

DeathFeedDB.layoutVersion = layoutVersion

copyDefaults(defaults, DeathFeedDB)

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
    local compactWidth = 145
    local fullMinWidth = 400
    local maxWidth = 650
    local minWidth = compactWidth
    local minHeight = getFrameChromeHeight() + (5 * rowHeight)

    if not DeathFeedDB.compactMode then
        minWidth = fullMinWidth
    end

    if DeathFeedWindow.SetResizeBounds then
        DeathFeedWindow:SetResizeBounds(minWidth, minHeight, maxWidth, 500)
    end

    if previousCompactMode ~= nil and previousCompactMode ~= DeathFeedDB.compactMode then
        local width = minWidth

        if DeathFeedDB.compactMode then
            DeathFeedDB.fullWidth = math.max(fullMinWidth, DeathFeedWindow:GetWidth())
        else
            width = math.max(fullMinWidth, math.min(maxWidth, tonumber(DeathFeedDB.fullWidth) or fullMinWidth))
        end

        DeathFeedWindow:SetWidth(width)
        DeathFeedDB.width = width
    elseif DeathFeedDB.compactMode and DeathFeedWindow:GetWidth() ~= minWidth then
        DeathFeedWindow:SetWidth(minWidth)
        DeathFeedDB.width = minWidth
    elseif DeathFeedWindow:GetWidth() < minWidth then
        DeathFeedWindow:SetWidth(minWidth)
        DeathFeedDB.width = minWidth
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

    if DeathFeedDB.compactMode then
        DeathFeedWindow:StartSizing("BOTTOM")
    else
        DeathFeedWindow:StartSizing("BOTTOMRIGHT")
    end
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
    DeathFeedDB.width = DeathFeedWindow:GetWidth()
    DeathFeedDB.height = DeathFeedWindow:GetHeight()

    if not DeathFeedDB.compactMode then
        DeathFeedDB.fullWidth = DeathFeedDB.width
    end

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
    if not DeathFeedDB.compactMode then
        return 27
    end

    return 10
end

function getFrameChromeHeight(compactMode)
    if compactMode == nil then
        compactMode = DeathFeedDB.compactMode
    end

    if not compactMode then
        return 46
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

            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:AddLine(rowName)
            GameTooltip:AddLine("Level: " .. rowLevel, 1, 1, 1)
            GameTooltip:AddLine("Killed by: " .. rowKiller, 1, 0.45, 0.45)
            GameTooltip:AddLine("Zone: " .. rowZone, 0.8, 0.8, 0.8)

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
    rowTexts[i].name = makeColumn(DeathFeedWindow, 75, y, 70)
    rowTexts[i].killer = makeColumn(DeathFeedWindow, 150, y, 120)
    rowTexts[i].zone = makeColumn(DeathFeedWindow, 275, y, 120)
end

function updateLayout()
    local width = DeathFeedWindow:GetWidth()
    local columnGap = 5
    local zoneRightMargin = 5

    local timeX = 8
    local levelX = 48
    local nameX = 75
    local killerX = 150
    local zoneX = killerX

    local nameWidth = 70
    local killerWidth = 0
    local zoneWidth = 0

    if not DeathFeedDB.compactMode then
        nameWidth = 70
        killerWidth = (width - killerX - columnGap - zoneRightMargin) / 2
        zoneWidth = killerWidth
        zoneX = killerX + killerWidth + columnGap
    end

    headerTexts.time:ClearAllPoints()
    headerTexts.time:SetPoint("TOPLEFT", timeX, -26)

    headerTexts.level:ClearAllPoints()
    headerTexts.level:SetPoint("TOPLEFT", levelX, -26)

    headerTexts.name:ClearAllPoints()
    headerTexts.name:SetPoint("TOPLEFT", nameX, -26)

    headerTexts.killer:ClearAllPoints()
    headerTexts.killer:SetPoint("TOPLEFT", killerX, -26)

    headerTexts.zone:ClearAllPoints()
    headerTexts.zone:SetPoint("TOPLEFT", zoneX, -26)

    headerTexts.time:SetShown(not DeathFeedDB.compactMode)
    headerTexts.level:SetShown(not DeathFeedDB.compactMode)
    headerTexts.name:SetShown(not DeathFeedDB.compactMode)
    headerTexts.killer:SetShown(not DeathFeedDB.compactMode)
    headerTexts.zone:SetShown(not DeathFeedDB.compactMode)

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

        rowTexts[i].killer:SetShown(not DeathFeedDB.compactMode)
        rowTexts[i].zone:SetShown(not DeathFeedDB.compactMode)
    end
end

function updateRows(animated)
    trimHistory()

    local maxRows = getMaxRows()
    local visibleRows = getVisibleRows()

    for i = 1, maxHistory do
        local row = visibleRows[i]

        if i <= maxRows and row then
            local rowTime = tostring(row.time or "")
            local rowLevel = tostring(row.level or "")
            local rowName = tostring(row.name or "Unknown")
            local rowKiller = tostring(row.killer or "Unknown")
            local rowZone = tostring(row.zone or "Unknown")

            rowFrames[i].row = row
            rowFrames[i].deathName = rowName
            rowFrames[i]:EnableMouse(true)
            rowFrames[i]:Show()

            rowTexts[i].time:SetText("|cff888888" .. rowTime .. "|r")

            rowTexts[i].level:SetText(colorLevel(rowLevel))

            if isGuildMember(rowName) then
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
                rowTexts[i].killer:SetText("|cffff7777" .. rowKiller .. "|r")
            end

            rowTexts[i].zone:SetText("|cffcccccc" .. rowZone .. "|r")

            rowTexts[i].time:Show()
            rowTexts[i].level:Show()
            rowTexts[i].name:Show()

            rowTexts[i].killer:SetShown(not DeathFeedDB.compactMode)
            rowTexts[i].zone:SetShown(not DeathFeedDB.compactMode)

            if animated and i == 1 and historyOffset == 0 then
                rowTexts[i].time:SetAlpha(0)
                rowTexts[i].level:SetAlpha(0)
                rowTexts[i].name:SetAlpha(0)
                if not DeathFeedDB.compactMode then
                    rowTexts[i].killer:SetAlpha(0)
                end

                if not DeathFeedDB.compactMode then
                    rowTexts[i].zone:SetAlpha(0)
                end

                UIFrameFadeIn(rowTexts[i].time, newDeathFadeDuration, 0, 1)
                UIFrameFadeIn(rowTexts[i].level, newDeathFadeDuration, 0, 1)
                UIFrameFadeIn(rowTexts[i].name, newDeathFadeDuration, 0, 1)
                if not DeathFeedDB.compactMode then
                    UIFrameFadeIn(rowTexts[i].killer, newDeathFadeDuration, 0, 1)
                end

                if not DeathFeedDB.compactMode then
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
