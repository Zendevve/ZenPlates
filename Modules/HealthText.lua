local addonName, ns = ...
local HealthText = CreateFrame("Frame")
ns.HealthText = HealthText

-- Format large numbers with k/M abbreviations
local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fk", num / 1000)
    else
        return tostring(num)
    end
end

-- Update health text for a single nameplate
function ns:UpdateHealthText(frame)
    if not frame.zen then return end

    local healthBar = frame:GetChildren()
    if not healthBar then return end

    -- Create health text if it doesn't exist
    if not frame.zen.healthText then
        frame.zen.healthText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.zen.healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0) -- Dead center of the bar
        frame.zen.healthText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE") -- Match the name font style
        frame.zen.healthText:SetTextColor(1, 1, 1)
        frame.zen.healthText:SetShadowOffset(1, -1)
        frame.zen.healthText:SetShadowColor(0, 0, 0, 1)
    end

    -- Get current and max health
    local currentHealth = healthBar:GetValue()
    local maxHealth = select(2, healthBar:GetMinMaxValues())

    if maxHealth and maxHealth > 0 then
        local percentage = math.floor((currentHealth / maxHealth) * 100)
        local currentFormatted = FormatNumber(currentHealth)

        -- Format: "30.0k (100%)"
        local text = string.format("%s (%d%%)", currentFormatted, percentage)
        frame.zen.healthText:SetText(text)
    else
        frame.zen.healthText:SetText("")
    end
end

-- Update all visible nameplates
function ns:UpdateAllHealthText()
    for frame in pairs(ns.nameplates) do
        if frame:IsShown() then
            ns:UpdateHealthText(frame)
        end
    end
end

-- Update loop
local UPDATE_INTERVAL = 0.1
local timeSinceLast = 0

HealthText:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast > UPDATE_INTERVAL then
        ns:UpdateAllHealthText()
        timeSinceLast = 0
    end
end)
