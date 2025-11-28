-- ZenPlates: Target Module
-- Handles target highlighting, scaling, and effects

local _, ZenPlates = ...
ZenPlates.Target = {}

local Target = ZenPlates.Target
local Config = ZenPlates.Config

-- Apply effects when a plate becomes the target
function Target:ApplyTargetEffects(virtual, healthBar)
    local cfg = Config.db.profile

    -- 1. Scale
    if cfg.targetZoom then
        virtual:SetScale(cfg.targetZoomScale)
        -- Ensure we're on top
        virtual:SetFrameLevel(virtual:GetFrameLevel() + 5)
    end

    -- 2. Glow/Highlight
    if cfg.targetGlow then
        if not virtual.targetGlow then
            virtual.targetGlow = virtual:CreateTexture(nil, "BACKGROUND")
            virtual.targetGlow:SetTexture("Interface\\AddOns\\ZenPlates\\Media\\Glow") -- Assuming we have a glow texture, or use standard
            -- Fallback to standard glow if custom not available
            virtual.targetGlow:SetTexture("Interface\\Buttons\\WHITE8X8")

            virtual.targetGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3)
            virtual.targetGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 3, -3)
            virtual.targetGlow:SetBlendMode("ADD")
        end

        local r, g, b, a = unpack(cfg.targetGlowColor)
        virtual.targetGlow:SetVertexColor(r, g, b, a)
        virtual.targetGlow:Show()
    end

    -- 3. Update widgets
    if ZenPlates.WidgetCore then
        -- Enable target-specific widgets
        -- ZenPlates.WidgetCore:EnableWidget("TargetIndicator", virtual)
    end
end

-- Remove effects when a plate is no longer the target
function Target:RemoveTargetEffects(virtual)
    local cfg = Config.db.profile

    -- 1. Reset Scale
    virtual:SetScale(cfg.globalScale)

    -- 2. Hide Glow
    if virtual.targetGlow then
        virtual.targetGlow:Hide()
    end

    -- 3. Disable widgets
    if ZenPlates.WidgetCore then
        -- ZenPlates.WidgetCore:DisableWidget("TargetIndicator", virtual)
    end
end
