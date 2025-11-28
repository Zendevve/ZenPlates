-- ZenPlates: Combat Module
-- Handles combo points and combat-related features

local _, ZenPlates = ...
ZenPlates.Combat = {}

local Combat = ZenPlates.Combat
local Config = ZenPlates.Config

-- Create combo point display
function Combat:CreateComboPoints(frame, healthBar)
    if not ZenPlatesDB.showComboPoints then return end

    local playerClass = select(2, UnitClass("player"))
    if playerClass ~= "ROGUE" and playerClass ~= "DRUID" then return end

    local cfg = ZenPlatesDB
    local size = cfg.comboPointSize or 8

    if not frame.comboPoints then
        frame.comboPoints = CreateFrame("Frame", nil, frame)
        frame.comboPoints:SetPoint("BOTTOM", healthBar, "TOP", 0, 18)
        frame.comboPoints:SetWidth(size * 5 + 8)
        frame.comboPoints:SetHeight(size)
        frame.comboPoints.orbs = {}

        -- Create 5 combo point orbs
        for i = 1, 5 do
            local orb = frame.comboPoints:CreateTexture(nil, "OVERLAY")
            orb:SetTexture("Interface\\Buttons\\WHITE8X8")
            orb:SetWidth(size)
            orb:SetHeight(size)
            orb:SetPoint("LEFT", frame.comboPoints, "LEFT", (i - 1) * (size + 2), 0)

            -- Brutalist styling - simple squares
            orb:SetVertexColor(0.2, 0.2, 0.2, 0.8) -- Dark when inactive

            -- Border
            local border = frame.comboPoints:CreateTexture(nil, "BACKGROUND")
            border:SetTexture("Interface\\Buttons\\WHITE8X8")
            border:SetPoint("TOPLEFT", orb, "TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 1, -1)
            border:SetVertexColor(0, 0, 0, 1)

            frame.comboPoints.orbs[i] = orb
        end
    end
end

-- Update combo point display
function Combat:UpdateComboPoints(frame)
    if not frame or not frame.comboPoints then return end

    local comboPoints = GetComboPoints("player", "target")

    if comboPoints and comboPoints > 0 then
        frame.comboPoints:Show()

        for i = 1, 5 do
            if i <= comboPoints then
                -- Active combo point - bright color based on count
                if comboPoints < 3 then
                    frame.comboPoints.orbs[i]:SetVertexColor(1, 1, 0, 1) -- Yellow
                elseif comboPoints < 5 then
                    frame.comboPoints.orbs[i]:SetVertexColor(1, 0.5, 0, 1) -- Orange
                else
                    frame.comboPoints.orbs[i]:SetVertexColor(1, 0, 0, 1) -- Red
                end
            else
                -- Inactive combo point
                frame.comboPoints.orbs[i]:SetVertexColor(0.2, 0.2, 0.2, 0.8)
            end
        end
    else
        frame.comboPoints:Hide()
    end
end

-- Register combat events
function Combat:RegisterEvents()
    local eventFrame = CreateFrame("Frame")

    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("UNIT_COMBO_POINTS")

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_COMBO_POINTS" then
            -- Combo points will be updated in main nameplate update loop
            ZenPlates.Core:UpdateTargetNameplate()
        end
    end)
end
