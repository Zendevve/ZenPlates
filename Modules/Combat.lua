-- ZenPlates: Combat Module
-- Handles combo points and other combat-related features

local _, ZenPlates = ...
ZenPlates.Combat = {}

local Combat = ZenPlates.Combat
local Config = ZenPlates.Config

-- Create combo points widget
function Combat:CreateComboPoints(virtual, healthBar)
    if not virtual.comboPoints then
        virtual.comboPoints = CreateFrame("Frame", nil, virtual)
        virtual.comboPoints:SetSize(60, 10)
        virtual.comboPoints:SetPoint("BOTTOM", healthBar, "TOP", 0, 12)

        virtual.comboPoints.points = {}
        for i = 1, 5 do
            local point = virtual.comboPoints:CreateTexture(nil, "OVERLAY")
            point:SetSize(8, 8)
            point:SetTexture(Config.db.profile.texture)
            point:SetVertexColor(1, 0.9, 0) -- Gold

            if i == 1 then
                point:SetPoint("LEFT", virtual.comboPoints, "LEFT", 0, 0)
            else
                point:SetPoint("LEFT", virtual.comboPoints.points[i-1], "RIGHT", 2, 0)
            end

            point:Hide()
            virtual.comboPoints.points[i] = point
        end
    end
end

-- Update combo points for a specific plate
function Combat:UpdateComboPoints(virtual)
    if not virtual or not virtual.comboPoints then return end

    local cfg = Config.db.profile
    if not cfg.showComboPoints then
        virtual.comboPoints:Hide()
        return
    end

    -- Only show on target
    if not virtual.isTarget then
        virtual.comboPoints:Hide()
        return
    end

    local points = GetComboPoints("player", "target")
    if points > 0 then
        virtual.comboPoints:Show()
        for i = 1, 5 do
            if i <= points then
                virtual.comboPoints.points[i]:Show()
            else
                virtual.comboPoints.points[i]:Hide()
            end
        end
    else
        virtual.comboPoints:Hide()
    end
end

-- Update all combo points (called on event)
function Combat:UpdateAllComboPoints()
    -- Find target plate
    if ZenPlates.VirtualPlates then
        local plates = ZenPlates.VirtualPlates:GetVisiblePlates()
        for _, virtual in pairs(plates) do
            if virtual.isTarget then
                self:UpdateComboPoints(virtual)
                break
            end
        end
    end
end

function Combat:RegisterEvents()
    -- Events are handled by Core/EventHandler.lua
end
