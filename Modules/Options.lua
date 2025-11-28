-- ZenPlates: Options Panel
-- Configuration UI with brutalist aesthetic

local _, ZenPlates = ...
ZenPlates.Options = {}

local Options = ZenPlates.Options
local Config = ZenPlates.Config

-- Create brutalist panel styling
local function StylePanel(panel)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    panel:SetBackdropColor(0.05, 0.05, 0.05, 1)
    panel:SetBackdropBorderColor(0, 0, 0, 1)
end

-- Create brutalist checkbox
local function CreateCheckbox(parent, label, tooltip)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetWidth(24)
    check:SetHeight(24)

    check.text = check:CreateFontString(nil, "OVERLAY")
    check.text:SetFont("Fonts\\FRIZQT__.TTF", 11, "NONE")
    check.text:SetText(label)
    check.text:SetPoint("LEFT", check, "RIGHT", 4, 0)
    check.text:SetTextColor(1, 1, 1)

    if tooltip then
        check.tooltipText = tooltip
    end

    return check
end

-- Create brutalist slider
local function CreateSlider(parent, label, min, max, step)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(180)

    slider.textLow = _G[slider:GetName().."Low"]
    slider.textHigh = _G[slider:GetName().."High"]
    slider.text = _G[slider:GetName().."Text"]

    if slider.textLow then slider.textLow:SetText(min) end
    if slider.textHigh then slider.textHigh:SetText(max) end
    if slider.text then
        slider.text:SetText(label)
        slider.text:SetTextColor(1, 1, 1)
    end

    slider.value = slider:CreateFontString(nil, "OVERLAY")
    slider.value:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    slider.value:SetPoint("TOP", slider, "BOTTOM", 0, -4)
    slider.value:SetTextColor(1, 1, 1)

    slider:SetScript("OnValueChanged", function(self, value)
        self.value:SetText(string.format("%.2f", value))
    end)

    return slider
end

-- Create dropdown (simple version)
local function CreateDropdown(parent, label, options)
    local dropdown = CreateFrame("Frame", nil, parent)
    dropdown:SetWidth(200)
    dropdown:SetHeight(40)

    dropdown.label = dropdown:CreateFontString(nil, "OVERLAY")
    dropdown.label:SetFont("Fonts\\FRIZQT__.TTF", 11, "NONE")
    dropdown.label:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
    dropdown.label:SetText(label)
    dropdown.label:SetTextColor(1, 1, 1)

    dropdown.button = CreateFrame("Button", nil, dropdown)
    dropdown.button:SetPoint("TOPLEFT", dropdown.label, "BOTTOMLEFT", 0, -4)
    dropdown.button:SetWidth(180)
    dropdown.button:SetHeight(24)
    dropdown.button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
    dropdown.button:GetNormalTexture():SetVertexColor(0.15, 0.15, 0.15, 1)

    dropdown.button.text = dropdown.button:CreateFontString(nil, "OVERLAY")
    dropdown.button.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "NONE")
    dropdown.button.text:SetPoint("LEFT", dropdown.button, "LEFT", 8, 0)
    dropdown.button.text:SetTextColor(1, 1, 1)

    dropdown.options = options
    dropdown.selectedIndex = 1

    return dropdown
end

-- Create main options panel
function Options:CreatePanel()
    local panel = CreateFrame("Frame", "ZenPlatesOptionsPanel", UIParent)
    panel.name = "ZenPlates"
    InterfaceOptions_AddCategory(panel)

    StylePanel(panel)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("ZENPLATES")
    title:SetTextColor(1, 1, 1)

    -- Subtitle
    local subtitle = panel:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont("Fonts\\FRIZQT__.TTF", 10, "NONE")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText("Hyperminimalist brutalist nameplates v2.0")
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    -- General Settings Section
    local generalHeader = panel:CreateFontString(nil, "OVERLAY")
    generalHeader:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    generalHeader:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -24)
    generalHeader:SetText("GENERAL")
    generalHeader:SetTextColor(1, 1, 1)

    local yOffset = -100

    -- Class Colors
    panel.classColors = CreateCheckbox(panel, "Use Class Colors", "Color health bars based on unit class")
    panel.classColors:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, yOffset)
    panel.classColors:SetChecked(ZenPlatesDB.useClassColors)
    panel.classColors:SetScript("OnClick", function(self)
        ZenPlatesDB.useClassColors = self:GetChecked()
    end)

    -- Show Health Percent
    panel.showPercent = CreateCheckbox(panel, "Show Health Percentage", "Display health as percentage")
    panel.showPercent:SetPoint("TOPLEFT", panel.classColors, "BOTTOMLEFT", 0, -8)
    panel.showPercent:SetChecked(ZenPlatesDB.showHealthPercent)
    panel.showPercent:SetScript("OnClick", function(self)
        ZenPlatesDB.showHealthPercent = self:GetChecked()
    end)

    -- Show Health Value
    panel.showValue = CreateCheckbox(panel, "Show Health Values", "Display estimated health values")
    panel.showValue:SetPoint("TOPLEFT", panel.showPercent, "BOTTOMLEFT", 0, -8)
    panel.showValue:SetChecked(ZenPlatesDB.showHealthValue)
    panel.showValue:SetScript("OnClick", function(self)
        ZenPlatesDB.showHealthValue = self:GetChecked()
    end)

    -- Show Elite
    panel.showElite = CreateCheckbox(panel, "Show Elite Indicator", "Display '+' for elite mobs")
    panel.showElite:SetPoint("TOPLEFT", panel.showValue, "BOTTOMLEFT", 0, -8)
    panel.showElite:SetChecked(ZenPlatesDB.showElite)
    panel.showElite:SetScript("OnClick", function(self)
        ZenPlatesDB.showElite = self:GetChecked()
    end)

    -- Target Effects Section
    local targetHeader = panel:CreateFontString(nil, "OVERLAY")
    targetHeader:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    targetHeader:SetPoint("TOPLEFT", panel.showElite, "BOTTOMLEFT", 0, -24)
    targetHeader:SetText("TARGET EFFECTS")
    targetHeader:SetTextColor(1, 1, 1)

    -- Target Zoom
    panel.targetZoom = CreateCheckbox(panel, "Enable Target Zoom", "Scale up the current target's nameplate")
    panel.targetZoom:SetPoint("TOPLEFT", targetHeader, "BOTTOMLEFT", 0, -12)
    panel.targetZoom:SetChecked(ZenPlatesDB.targetZoom)
    panel.targetZoom:SetScript("OnClick", function(self)
        ZenPlatesDB.targetZoom = self:GetChecked()
    end)

    -- Zoom Scale Slider
    panel.zoomScale = CreateSlider(panel, "Zoom Scale", 1.0, 1.5, 0.05)
    panel.zoomScale:SetPoint("TOPLEFT", panel.targetZoom, "BOTTOMLEFT", 24, -16)
    panel.zoomScale:SetValue(ZenPlatesDB.targetZoomScale)
    panel.zoomScale:SetScript("OnValueChanged", function(self, value)
        ZenPlatesDB.targetZoomScale = value
    end)

    -- Target Glow
    panel.targetGlow = CreateCheckbox(panel, "Enable Target Glow", "Add glow effect around target nameplate")
    panel.targetGlow:SetPoint("TOPLEFT", panel.zoomScale, "BOTTOMLEFT", -24, -16)
    panel.targetGlow:SetChecked(ZenPlatesDB.targetGlow)
    panel.targetGlow:SetScript("OnClick", function(self)
        ZenPlatesDB.targetGlow = self:GetChecked()
    end)

    -- Right Column
    local debuffHeader = panel:CreateFontString(nil, "OVERLAY")
    debuffHeader:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    debuffHeader:SetPoint("TOPLEFT", panel, "TOP", 20, yOffset)
    debuffHeader:SetText("DEBUFFS")
    debuffHeader:SetTextColor(1, 1, 1)

    -- Show Debuffs
    panel.showDebuffs = CreateCheckbox(panel, "Show Debuffs", "Display debuffs below nameplates")
    panel.showDebuffs:SetPoint("TOPLEFT", debuffHeader, "BOTTOMLEFT", 0, -12)
    panel.showDebuffs:SetChecked(ZenPlatesDB.showDebuffs)
    panel.showDebuffs:SetScript("OnClick", function(self)
        ZenPlatesDB.showDebuffs = self:GetChecked()
    end)

    -- Debuff Durations
    panel.showDebuffDurations = CreateCheckbox(panel, "Show Debuff Durations", "Display countdown timers on debuffs")
    panel.showDebuffDurations:SetPoint("TOPLEFT", panel.showDebuffs, "BOTTOMLEFT", 0, -8)
    panel.showDebuffDurations:SetChecked(ZenPlatesDB.showDebuffDurations)
    panel.showDebuffDurations:SetScript("OnClick", function(self)
        ZenPlatesDB.showDebuffDurations = self:GetChecked()
    end)

    -- Debuff Cache
    panel.debuffCache = CreateCheckbox(panel, "Enable Debuff Cache", "Remember debuffs when unit is not targeted")
    panel.debuffCache:SetPoint("TOPLEFT", panel.showDebuffDurations, "BOTTOMLEFT", 0, -8)
    panel.debuffCache:SetChecked(ZenPlatesDB.enableDebuffCache)
    panel.debuffCache:SetScript("OnClick", function(self)
        ZenPlatesDB.enableDebuffCache = self:GetChecked()
    end)

    -- Combo Points
    panel.comboPoints = CreateCheckbox(panel, "Show Combo Points", "Display combo points on target (Rogue/Druid)")
    panel.comboPoints:SetPoint("TOPLEFT", panel.debuffCache, "BOTTOMLEFT", 0, -8)
    panel.comboPoints:SetChecked(ZenPlatesDB.showComboPoints)
    panel.comboPoints:SetScript("OnClick", function(self)
        ZenPlatesDB.showComboPoints = self:GetChecked()
    end)

    -- Unit Filters Section
    local filterHeader = panel:CreateFontString(nil, "OVERLAY")
    filterHeader:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    filterHeader:SetPoint("TOPLEFT", panel.comboPoints, "BOTTOMLEFT", 0, -24)
    filterHeader:SetText("UNIT FILTERS")
    filterHeader:SetTextColor(1, 1, 1)

    -- Hide Totems
    panel.hideTotem = CreateCheckbox(panel, "Hide Totems", "Hide nameplates for totems")
    panel.hideTotem:SetPoint("TOPLEFT", filterHeader, "BOTTOMLEFT", 0, -12)
    panel.hideTotem:SetChecked(ZenPlatesDB.hideTotem)
    panel.hideTotem:SetScript("OnClick", function(self)
        ZenPlatesDB.hideTotem = self:GetChecked()
    end)

    -- Hide Critters
    panel.hideCritter = CreateCheckbox(panel, "Hide Critters", "Hide nameplates for critters")
    panel.hideCritter:SetPoint("TOPLEFT", panel.hideTotem, "BOTTOMLEFT", 0, -8)
    panel.hideCritter:SetChecked(ZenPlatesDB.hideCritter)
    panel.hideCritter:SetScript("OnClick", function(self)
        ZenPlatesDB.hideCritter = self:GetChecked()
    end)

    -- Reset Button
    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
    resetBtn:SetWidth(140)
    resetBtn:SetHeight(28)
    resetBtn:SetText("RESET TO DEFAULTS")
    resetBtn:SetScript("OnClick", function()
        Config:ResetToDefaults()
    end)

    -- Apply note
    local applyNote = panel:CreateFontString(nil, "OVERLAY")
    applyNote:SetFont("Fonts\\FRIZQT__.TTF", 9, "NONE")
    applyNote:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    applyNote:SetText("Type /reload to fully apply all changes")
    applyNote:SetTextColor(0.7, 0.7, 0.7)

    self.panel = panel
end

-- Initialize options panel
Options:CreatePanel()
