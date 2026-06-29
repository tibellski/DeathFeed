local coloredAddonName = "|cffcc4444DeathFeed|r"

DeathFeedOptionsPanel = CreateFrame("Frame", "DeathFeedOptionsPanel")
DeathFeedOptionsPanel.name = coloredAddonName

local optionsTitle = DeathFeedOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsTitle:SetPoint("TOPLEFT", 16, -16)
optionsTitle:SetText(coloredAddonName)

DeathFeedOptionsCategory = nil

if Settings and Settings.RegisterCanvasLayoutCategory then
    DeathFeedOptionsCategory = Settings.RegisterCanvasLayoutCategory(DeathFeedOptionsPanel, coloredAddonName)
    Settings.RegisterAddOnCategory(DeathFeedOptionsCategory)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(DeathFeedOptionsPanel)
end

local sectionSpacing = -22
local controlSpacing = -8
local contentInset = 8

local function makeDescription(parent, text)
    local description = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetText("|cff888888" .. text .. "|r")
    description:SetJustifyH("LEFT")
    return description
end

local optionsSubtitle = makeDescription(
    DeathFeedOptionsPanel,
    "Tune the feed behavior without changing how deaths are parsed."
)

optionsSubtitle:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -6)
optionsSubtitle:SetWidth(560)

local function makeSection(text, relativeTo, offsetX)
    local section = DeathFeedOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")

    if relativeTo then
        section:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", offsetX or -contentInset, sectionSpacing)
    else
        section:SetPoint("TOPLEFT", optionsSubtitle, "BOTTOMLEFT", 0, -24)
    end

    section:SetText(text)
    return section
end

local function makeCheckbox(name, text, relativeTo, offsetY)
    local checkbox = CreateFrame(
        "CheckButton",
        name,
        DeathFeedOptionsPanel,
        "InterfaceOptionsCheckButtonTemplate"
    )

    checkbox:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", contentInset, offsetY or controlSpacing)
    checkbox.Text:SetText(text)
    return checkbox
end

local chatSection = makeSection("Chat", nil)

local hideChatCheckbox = CreateFrame(
    "CheckButton",
    "DeathFeedHideChatCheckbox",
    DeathFeedOptionsPanel,
    "InterfaceOptionsCheckButtonTemplate"
)

hideChatCheckbox:SetPoint("TOPLEFT", chatSection, "BOTTOMLEFT", contentInset, controlSpacing)
hideChatCheckbox.Text:SetText("Hide original HardcoreDeaths chat")

hideChatCheckbox:SetScript("OnShow", function(self)
    self:SetChecked(DeathFeedDB.hideOriginalChat)
end)

hideChatCheckbox:SetScript("OnClick", function(self)
    DeathFeedDB.hideOriginalChat = self:GetChecked()
end)

local feedSection = makeSection("Feed", hideChatCheckbox)

local playSoundCheckbox = makeCheckbox(nil, "Play sound on guild death", feedSection)

playSoundCheckbox:SetScript("OnShow", function(self)
    self:SetChecked(DeathFeedDB.playGuildSound)
end)

playSoundCheckbox:SetScript("OnClick", function(self)
    DeathFeedDB.playGuildSound = self:GetChecked()
end)

local minimumLevelLabel = DeathFeedOptionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontNormal"
)

minimumLevelLabel:SetPoint("TOPLEFT", playSoundCheckbox, "BOTTOMLEFT", contentInset, -14)
minimumLevelLabel:SetText("Minimum level to display")

local minimumLevelDropdown = CreateFrame(
    "Frame",
    "DeathFeedMinimumLevelDropdown",
    DeathFeedOptionsPanel,
    "UIDropDownMenuTemplate"
)

minimumLevelDropdown:SetPoint("TOPLEFT", minimumLevelLabel, "BOTTOMLEFT", -15, -4)

local minimumLevelOptions = {
    10,
    20,
    30,
    40,
    50,
    60
}

local function updateMinimumLevelDropdownText()
    UIDropDownMenu_SetText(
        minimumLevelDropdown,
        tostring(DeathFeedDB.minimumLevel or 10)
    )
end

UIDropDownMenu_Initialize(minimumLevelDropdown, function()
    for _, value in ipairs(minimumLevelOptions) do
        local info = UIDropDownMenu_CreateInfo()

        info.text = tostring(value)
        info.value = value
        info.checked = DeathFeedDB.minimumLevel == value

        info.func = function()
            DeathFeedDB.minimumLevel = value
            historyOffset = 0
            updateMinimumLevelDropdownText()
            updateRows(false)
            CloseDropDownMenus()
        end

        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetWidth(minimumLevelDropdown, 80)
updateMinimumLevelDropdownText()

minimumLevelDropdown:SetScript("OnShow", function()
    updateMinimumLevelDropdownText()
end)

local minimumLevelHelp = DeathFeedOptionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontHighlightSmall"
)

minimumLevelHelp:SetPoint("TOPLEFT", minimumLevelDropdown, "BOTTOMLEFT", 15, -2)
minimumLevelHelp:SetText("|cff888888Guild deaths are always shown.|r")

local windowSection = makeSection("Window", minimumLevelHelp, -16)

local lockWindowCheckbox = makeCheckbox(nil, "Lock window position and size", windowSection)

lockWindowCheckbox:SetScript("OnShow", function(self)
    self:SetChecked(DeathFeedDB.windowLocked)
end)

lockWindowCheckbox:SetScript("OnClick", function(self)
    if setWindowLocked then
        setWindowLocked(self:GetChecked())
    else
        DeathFeedDB.windowLocked = self:GetChecked()
    end
end)

local minimapSection = makeSection("Minimap", lockWindowCheckbox)

local hideMinimapCheckbox = makeCheckbox(nil, "Hide minimap icon", minimapSection)

hideMinimapCheckbox:SetScript("OnShow", function(self)
    self:SetChecked(DeathFeedDB.minimap and DeathFeedDB.minimap.hide)
end)

hideMinimapCheckbox:SetScript("OnClick", function(self)
    DeathFeedDB.minimap = DeathFeedDB.minimap or {}
    DeathFeedDB.minimap.hide = self:GetChecked()

    if ldbIcon then
        if DeathFeedDB.minimap.hide then
            ldbIcon:Hide("DeathFeed")
        else
            ldbIcon:Show("DeathFeed")
        end
    end
end)

local maintenanceSection = makeSection("Maintenance", hideMinimapCheckbox)

local clearButton = CreateFrame(
    "Button",
    nil,
    DeathFeedOptionsPanel,
    "UIPanelButtonTemplate"
)

clearButton:SetSize(120, 24)
clearButton:SetPoint("TOPLEFT", maintenanceSection, "BOTTOMLEFT", contentInset, -10)
clearButton:SetText("Clear history")

clearButton:SetScript("OnClick", function()
    wipe(DeathFeedDB.history)
    historyOffset = 0
    updateRows(false)
end)

local resetWindowButton = CreateFrame(
    "Button",
    nil,
    DeathFeedOptionsPanel,
    "UIPanelButtonTemplate"
)

resetWindowButton:SetSize(150, 24)
resetWindowButton:SetPoint("LEFT", clearButton, "RIGHT", 8, 0)
resetWindowButton:SetText("Reset window")

resetWindowButton:SetScript("OnClick", function()
    DeathFeedDB.point = "CENTER"
    DeathFeedDB.relativePoint = "CENTER"
    DeathFeedDB.x = 0
    DeathFeedDB.y = 0

    if DeathFeedWindow then
        DeathFeedWindow:ClearAllPoints()
        DeathFeedWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end)
