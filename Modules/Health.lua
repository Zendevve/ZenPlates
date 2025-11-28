-- ZenPlates: Health Module
-- Handles health bar styling, class colors, health detection, and elite/rare indicators

local _, ZenPlates = ...
ZenPlates.Health = {}

local Health = ZenPlates.Health
local Config = ZenPlates.Config
local Utils = ZenPlates.Utils

-- Health tracking for damage-based estimation
Health.TrackedUnits = {}

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
    local cfg = ZenPlatesDB

    -- Only show when not at full health
    if percent < 100 and curr > 0 then
        if cfg.showHealthPercent and not cfg.showHealthValue then
            healthBar.pct:SetText(string.format("%d%%", percent))
        elseif cfg.showHealthValue and not cfg.showHealthPercent then
            if cfg.healthValueFormat == "current" then
                healthBar.pct:SetText(Utils:FormatNumber(curr))
            elseif cfg.healthValueFormat == "both" then
                healthBar.pct:SetText(Utils:FormatNumber(curr) .. " / " .. Utils:FormatNumber(max))
            else -- smart
                healthBar.pct:SetText(Utils:FormatNumber(curr))
            end
        elseif cfg.showHealthPercent and cfg.showHealthValue then
            healthBar.pct:SetText(Utils:FormatNumber(curr) .. " (" .. string.format("%d%%", percent) .. ")")
        else
            healthBar.pct:SetText("")
        end
    else
        healthBar.pct:SetText("")
    end
end

-- Style a health bar with brutalist aesthetic
function Health:StyleHealthBar(frame, healthBar, nameText, levelText, eliteIcon)
    local cfg = ZenPlatesDB

    -- Create background frame (brutalist border)
    if not frame.bg then
        frame.bg = CreateFrame("Frame", nil, healthBar)
        frame.bg:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -1, 1)
        frame.bg:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 1, -1)
        frame.bg:SetFrameLevel(healthBar:GetFrameLevel() - 1)
        frame.bg:SetBackdrop(backdrop)
        frame.bg:SetBackdropBorderColor(unpack(cfg.borderColor))

        -- Background fill
        frame.bg.fill = frame.bg:CreateTexture(nil, "BACKGROUND")
        frame.bg.fill:SetAllPoints(healthBar)
        frame.bg.fill:SetTexture(cfg.texture)
        frame.bg.fill:SetVertexColor(unpack(cfg.backdropColor))
    end

    -- Set health bar texture and size
    healthBar:SetStatusBarTexture(cfg.texture)
    healthBar:SetWidth(cfg.width)
    healthBar:SetHeight(cfg.height)

    -- Apply class colors if enabled
    if cfg.useClassColors then
        local guid = healthBar.guid
        if guid then
            -- Try to get class from GUID (not reliable for NPCs, but works for players)
            local unitType = tonumber(string.sub(guid, 3, 5), 16)
            -- Player GUID type is 0x000 (0 in decimal)
            if unitType == 0 then
                -- This is a player, try to detect class
                -- Note: In 3.3.5a we can't easily get class from nameplate alone
                -- Color will be set via reaction color as fallback
            end
        end

        -- Use reaction colors as fallback (green/yellow/red)
        local r, g, b = healthBar:GetStatusBarColor()
        if r and g and b then
            healthBar:SetStatusBarColor(r, g, b)
        end
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

            -- TODO: Rare detection (R or R+) - needs classification check
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
    if (cfg.showHealthPercent or cfg.showHealthValue) and not healthBar.pct then
        healthBar.pct = healthBar:CreateFontString(nil, "OVERLAY")
        healthBar.pct:SetFont(cfg.font, cfg.fontSize - 1, cfg.fontOutline)
        healthBar.pct:SetPoint("LEFT", healthBar, "RIGHT", 4, 0)
        healthBar.pct:SetShadowOffset(1, -1)
        healthBar.pct:SetTextColor(1, 1, 1)

        -- Hook health updates
        healthBar:SetScript("OnValueChanged", UpdateHealthText)
        UpdateHealthText(healthBar)
    end

    -- Store GUID for tracking
    if not healthBar.guid then
        healthBar.guid = UnitGUID("target") -- Placeholder, will be updated
    end
end

-- Track damage events for health estimation
function Health:OnCombatLogEvent(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
    if sourceGUID ~= UnitGUID("player") then return end

    -- Track damage dealt to estimate health
    if eventType == "SWING_DAMAGE" or string.find(eventType, "_DAMAGE") then
        local amount = select(1, ...)

        if destGUID and amount then
            if not self.TrackedUnits[destGUID] then
                self.TrackedUnits[destGUID] = {
                    maxHealth = 0,
                    currentHealth = 0,
                    damageDealt = 0,
                }
            end

            self.TrackedUnits[destGUID].damageDealt = self.TrackedUnits[destGUID].damageDealt + amount
        end
    end
end
