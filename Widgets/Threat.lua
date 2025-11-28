-- ZenPlates: Threat Widget
-- Visual threat indicator for tanks and DPS

local _, ZenPlates = ...
local ThreatWidget = {}

function ThreatWidget:Create(virtual)
    local indicator = virtual:CreateTexture(nil, "OVERLAY")
    indicator:SetSize(16, 16)
    indicator:SetPoint("LEFT", virtual.healthBar, "RIGHT", 4, 0)
    indicator:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
    return indicator
end

function ThreatWidget:Update(indicator, virtual)
    if not virtual.isTarget then
        indicator:Hide()
        return
    end

    -- In 3.3.5, we can check threat on target
    local isTanking, status, pct, rawPct = UnitDetailedThreatSituation("player", "target")

    if status then
        if status >= 2 then
            -- High threat / Tanking
            indicator:SetTexCoord(0, 19/64, 22/64, 41/64) -- Tank icon
            indicator:Show()
        elseif status == 1 then
            -- Warning
            indicator:SetTexCoord(20/64, 39/64, 1/64, 20/64) -- DPS icon (warning)
            indicator:Show()
        else
            indicator:Hide()
        end
    else
        indicator:Hide()
    end
end

ZenPlates.WidgetCore:RegisterWidget("Threat", ThreatWidget)
