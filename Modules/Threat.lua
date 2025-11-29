local addonName, ns = ...
local Threat = CreateFrame("Frame")
ns.Threat = Threat

-- Get threat color based on percentage
local function GetThreatColor(percentage)
    if percentage >= 100 then
        return 1, 0, 0 -- Red (Aggro)
    elseif percentage >= 80 then
        return 1, 0.5, 0 -- Orange (High)
    elseif percentage >= 50 then
        return 1, 1, 0 -- Yellow (Medium)
    else
        return 0, 1, 0 -- Green (Low)
    end
end

-- Format threat value
local function FormatThreat(value)
    if value >= 1000 then
        return string.format("%.1fk", value / 1000)
    else
        return tostring(math.floor(value))
    end
end

-- Update threat display for a single nameplate
function ns:UpdateThreat(frame)
    if not frame.zen or not frame.zen.name then return end

    -- 1. Threat Differential (Left Side)
    if not frame.zen.threatDiff then
        frame.zen.threatDiff = frame.zen:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.zen.threatDiff:SetPoint("RIGHT", frame.zen.healthBar, "LEFT", -4, 0) -- Left of Health Bar
        frame.zen.threatDiff:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") -- Larger (was 10)
        frame.zen.threatDiff:SetShadowOffset(1, -1)
        frame.zen.threatDiff:Hide()
    end

    -- 2. Threat Level Number (Right Side)
    if not frame.zen.threatLevel then
        frame.zen.threatLevel = frame.zen:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.zen.threatLevel:SetPoint("LEFT", frame.zen.healthBar, "RIGHT", 4, 0) -- Right of Health Bar
        frame.zen.threatLevel:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Larger (was 14)
        frame.zen.threatLevel:SetShadowOffset(1, -1)
        frame.zen.threatLevel:Hide()
    end

    -- 3. Threat Status Bar (Top Left)
    if not frame.zen.threatBar then
        frame.zen.threatBar = CreateFrame("StatusBar", nil, frame.zen)
        frame.zen.threatBar:SetSize(30, 8) -- Thicker bar (was 4)
        frame.zen.threatBar:SetPoint("BOTTOMLEFT", frame.zen.healthBar, "TOPLEFT", 0, 1)
        frame.zen.threatBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        frame.zen.threatBar:SetMinMaxValues(0, 100)

        -- Background for threat bar
        local bg = frame.zen.threatBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(0, 0, 0, 0.5)

        -- Text inside threat bar
        frame.zen.threatBarText = frame.zen.threatBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.zen.threatBarText:SetPoint("CENTER", frame.zen.threatBar, "CENTER", 0, 0)
        frame.zen.threatBarText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE") -- Larger text (was 6)

        frame.zen.threatBar:Hide()
    end

    -- Only show threat for enemy units
    local name = frame.zen.name:GetText()
    if not name then
        frame.zen.threatDiff:Hide()
        frame.zen.threatLevel:Hide()
        frame.zen.threatBar:Hide()
        return
    end

    -- Check if unit exists and is enemy
    local unit = nil
    if UnitExists("target") and UnitName("target") == name then
        unit = "target"
    elseif UnitExists("mouseover") and UnitName("mouseover") == name then
        unit = "mouseover"
    end

    if unit and UnitCanAttack("player", unit) and UnitAffectingCombat("player") then
        local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", unit)

        if threatpct then
            local r, g, b = GetThreatColor(threatpct)

            -- Update Diff Text (Left)
            frame.zen.threatDiff:SetText(FormatThreat(threatvalue))
            frame.zen.threatDiff:SetTextColor(r, g, b)
            frame.zen.threatDiff:Show()

            -- Update Level Number (Right) - Just using status (0-3) as a proxy for "Level"
            frame.zen.threatLevel:SetText(status)
            frame.zen.threatLevel:SetTextColor(r, g, b)
            frame.zen.threatLevel:Show()

            -- Update Status Bar (Top)
            frame.zen.threatBar:SetValue(threatpct)
            frame.zen.threatBar:SetStatusBarColor(r, g, b)
            frame.zen.threatBarText:SetText(math.floor(threatpct).."%")
            frame.zen.threatBar:Show()
        else
            frame.zen.threatDiff:Hide()
            frame.zen.threatLevel:Hide()
            frame.zen.threatBar:Hide()
        end
    else
        frame.zen.threatDiff:Hide()
        frame.zen.threatLevel:Hide()
        frame.zen.threatBar:Hide()
    end
end

-- Update all visible nameplates
function ns:UpdateAllThreat()
    for frame in pairs(ns.nameplates) do
        if frame:IsShown() then
            ns:UpdateThreat(frame)
        end
    end
end

-- Update loop
local UPDATE_INTERVAL = 0.2
local timeSinceLast = 0

Threat:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast > UPDATE_INTERVAL then
        ns:UpdateAllThreat()
        timeSinceLast = 0
    end
end)
