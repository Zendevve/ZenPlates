local addonName, ns = ...
local Glow = CreateFrame("Frame")
ns.Glow = Glow

-- Update loop to check for target (via default glow visibility)
local UPDATE_INTERVAL = 0.1
local timeSinceLast = 0

Glow:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast > UPDATE_INTERVAL then
        ns:UpdateGlows()
        timeSinceLast = 0
    end
end)

function ns:UpdateGlows()
    for frame in pairs(ns.nameplates) do
        if frame:IsShown() and frame.zen then
            ns:CheckGlow(frame)
        end
    end
end

function ns:CheckGlow(frame)
    -- Create custom glow if missing
    if not frame.zen.glow then
        -- Create a thin border frame instead of a thick glow
        frame.zen.glow = CreateFrame("Frame", nil, frame.zen)
        frame.zen.glow:SetAllPoints()
        frame.zen.glow:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 2,
        })
        frame.zen.glow:SetBackdropBorderColor(1, 0, 0, 1) -- Red
        frame.zen.glow:Hide()
    end

    -- Check if this is the target (stored glow region would be shown by Blizz)
    local defaultGlow = frame.zen.glowRegion

    if defaultGlow and defaultGlow:IsShown() then
        -- This is the target - show subtle red border
        frame.zen.glow:Show()
    else
        frame.zen.glow:Hide()
    end
end
