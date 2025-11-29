local addonName, ns = ...
local ComboPoints = CreateFrame("Frame")
ns.ComboPoints = ComboPoints

-- Configuration
local CP_SIZE = 10
local CP_SPACING = 2
local MAX_CP = 5

-- Colors
local COLORS = {
    [1] = {1, 1, 0}, -- Yellow
    [2] = {1, 1, 0}, -- Yellow
    [3] = {1, 0.5, 0}, -- Orange
    [4] = {1, 0.5, 0}, -- Orange
    [5] = {1, 0, 0}, -- Red
}

-- Create CP frames for a nameplate
local function CreateComboPoints(frame)
    frame.zen.cps = {}

    for i = 1, MAX_CP do
        local cp = CreateFrame("Frame", nil, frame.zen)
        cp:SetSize(CP_SIZE, CP_SIZE)

        -- Backdrop (Brutalist Border)
        cp.backdrop = CreateFrame("Frame", nil, cp)
        cp.backdrop:SetPoint("TOPLEFT", -1, 1)
        cp.backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
        cp.backdrop:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        cp.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

        -- Fill Texture
        cp.fill = cp:CreateTexture(nil, "ARTWORK")
        cp.fill:SetAllPoints()
        cp.fill:SetTexture("Interface\\Buttons\\WHITE8X8")

        -- Position
        if i == 1 then
            -- Center the group of 5 points
            -- Total width = (5 * 10) + (4 * 2) = 58
            -- Start X = -29 (half of 58)
            cp:SetPoint("BOTTOMLEFT", frame.zen.healthBar, "TOP", -( (MAX_CP*CP_SIZE + (MAX_CP-1)*CP_SPACING) / 2 ), 4)
        else
            cp:SetPoint("LEFT", frame.zen.cps[i-1], "RIGHT", CP_SPACING, 0)
        end

        cp:Hide()
        frame.zen.cps[i] = cp
    end
end

-- Update CP display
function ns:UpdateComboPoints(frame)
    if not frame.zen or not frame.zen.name then return end

    -- Only show on target
    local isTarget = UnitExists("target") and frame.zen.name:GetText() == UnitName("target")

    if not isTarget then
        if frame.zen.cps then
            for i = 1, MAX_CP do
                frame.zen.cps[i]:Hide()
            end
        end
        return
    end

    -- Create if needed
    if not frame.zen.cps then
        CreateComboPoints(frame)
    end

    local points = GetComboPoints("player", "target")

    for i = 1, MAX_CP do
        if i <= points then
            local color = COLORS[points] or COLORS[5]
            frame.zen.cps[i].fill:SetVertexColor(unpack(color))
            frame.zen.cps[i]:Show()
        else
            frame.zen.cps[i]:Hide()
        end
    end
end

-- Event Handling
ComboPoints:RegisterEvent("UNIT_COMBO_POINTS")
ComboPoints:RegisterEvent("PLAYER_TARGET_CHANGED")

ComboPoints:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_COMBO_POINTS" then
        if unit == "player" or unit == "vehicle" then
            ns:UpdateComboPoints(ns:GetPlate("target"))
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Update old target (to hide) and new target (to show)
        -- Since we don't track "old target", we just update all visible plates or just the new target?
        -- Safest is to update the new target, and rely on the fact that other plates won't match "target" anymore.
        -- But we need to trigger an update on the *previous* target frame to hide its points.
        -- Iterating all plates is cheap enough.
        for frame in pairs(ns.nameplates) do
            if frame:IsShown() then
                ns:UpdateComboPoints(frame)
            end
        end
    end
end)
