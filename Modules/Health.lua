-- ZenPlates: Health Module
-- Handles health bar styling, class colors, health detection, and elite/rare indicators

local _, ZenPlates = ...
ZenPlates.Health = {}

local Health = ZenPlates.Health
local Config = ZenPlates.Config
local Utils = ZenPlates.Utils

-- Backdrop template for brutalist design
local backdrop = {
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Update health percentage/value display
local function UpdateHealthText(healthBar)
    if not healthBar.pct then return end

    local curr, max = healthBar:GetValue(), select(2, healthBar:GetMinMaxValues())
    if max == 0 then return end

    local percent = (curr / max) * 100
    local cfg = Config.db.profile

    -- Only show when not at full health or if configured to always show
    if percent < 100 and curr > 0 then
        if cfg.healthTextMode == "PERCENT" then
            healthBar.pct:SetText(string.format("%d%%", percent))
        elseif cfg.healthTextMode == "VALUE" then
            healthBar.pct:SetText(Utils:FormatNumber(curr))
        elseif cfg.healthTextMode == "BOTH" then
            healthBar.pct:SetText(Utils:FormatNumber(curr) .. " (" .. string.format("%d%%", percent) .. ")")
        else
            healthBar.pct:SetText("")
        end
    else
        healthBar.pct:SetText("")
    end
end

-- Style a health bar with brutalist aesthetic
function Health:StyleHealthBar(virtual, healthBar, nameText, levelText, eliteIcon)
    local cfg = Config.db.profile

    -- Create background frame (brutalist border)
    if not virtual.bg then
        virtual.bg = CreateFrame("Frame", nil, healthBar)
        virtual.bg:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -1, 1)
        virtual.bg:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 1, -1)
        virtual.bg:SetFrameLevel(healthBar:GetFrameLevel() - 1)
        virtual.bg:SetBackdrop(backdrop)
        virtual.bg:SetBackdropBorderColor(unpack(cfg.borderColor))

        -- Background fill
        virtual.bg.fill = virtual.bg:CreateTexture(nil, "BACKGROUND")
        virtual.bg.fill:SetAllPoints(healthBar)
        virtual.bg.fill:SetTexture(cfg.texture)
        virtual.bg.fill:SetVertexColor(unpack(cfg.backdropColor))
    end

    -- Set health bar texture and size
    healthBar:SetStatusBarTexture(cfg.texture)
    healthBar:SetWidth(cfg.width)
    healthBar:SetHeight(cfg.height)

    -- Smart Coloring
    if cfg.useClassColors then
        -- Hook OnValueChanged to update color dynamically
        if not healthBar.colorHooked then
            healthBar:HookScript("OnValueChanged", function(self)
                Health:UpdateHealthColor(self)
            end)
            healthBar.colorHooked = true
        end
        Health:UpdateHealthColor(healthBar)
    end

    -- Style name text
    if nameText then
        nameText:SetFont(cfg.font, cfg.fontSize, cfg.fontOutline)
        nameText:ClearAllPoints()
        nameText:SetPoint("BOTTOM", healthBar, "TOP", 0, 4)
        nameText:SetShadowOffset(1, -1)
        nameText:SetTextColor(1, 1, 1) -- Pure white (brutalist)

        -- Add elite/rare indicators
        if eliteIcon and eliteIcon:IsShown() then
            local currentText = nameText:GetText() or ""
            if cfg.showElite and not string.find(currentText, "+") then
                nameText:SetText(currentText .. "+")
            end
        end
    end

    -- Style level text
    if levelText then
        levelText:SetFont(cfg.font, cfg.fontSize - 2, cfg.fontOutline)
        levelText:ClearAllPoints()
        levelText:SetPoint("LEFT", nameText, "RIGHT", 2, 0)
        levelText:SetShadowOffset(1, -1)
        levelText:SetTextColor(0.9, 0.9, 0.9) -- Slightly dimmer white
    end

    -- Create health text display
    if cfg.healthTextMode ~= "NONE" and not healthBar.pct then
        healthBar.pct = healthBar:CreateFontString(nil, "OVERLAY")
        healthBar.pct:SetFont(cfg.font, cfg.fontSize - 1, cfg.fontOutline)
        healthBar.pct:SetPoint("LEFT", healthBar, "RIGHT", 4, 0)
        healthBar.pct:SetShadowOffset(1, -1)
        healthBar.pct:SetTextColor(1, 1, 1)

        -- Hook health updates
        healthBar:SetScript("OnValueChanged", UpdateHealthText)
        UpdateHealthText(healthBar)
    end
end

-- Update health bar color based on reaction/threat/class
function Health:UpdateHealthColor(healthBar)
    local r, g, b = healthBar:GetStatusBarColor()

    -- If it's a player (class color), keep it
    -- In 3.3.5, standard UI handles class colors well for players
    -- We mainly want to ensure texture is correct

    -- If we want to override, we can check UnitReaction if we have the unit
    -- But since we don't always have the unit in 3.3.5 nameplates (without mouseover),
    -- we rely on the color provided by the game, just ensuring texture is applied.

    -- Ensure texture is set (sometimes resets)
    if healthBar:GetStatusBarTexture():GetTexture() ~= Config.db.profile.texture then
        healthBar:SetStatusBarTexture(Config.db.profile.texture)
    end
end
