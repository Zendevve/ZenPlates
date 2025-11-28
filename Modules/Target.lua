-- ZenPlates: Target Module
-- Handles target highlighting with glow effect (zoom disabled to prevent alignment issues)

local _, ZenPlates = ...
ZenPlates.Target = {}

local Target = ZenPlates.Target

-- Currently targeted nameplate
Target.CurrentTarget = nil

-- Apply glow effect to current target (zoom disabled - breaks positioning)
function Target:ApplyTargetEffects(frame, healthBar)
    if not frame or not healthBar then return end

    local cfg = ZenPlatesDB

    -- Remove effects from previous target
    if self.CurrentTarget and self.CurrentTarget ~= frame then
        self:RemoveTargetEffects(self.CurrentTarget)
    end

    -- DO NOT scale frames - interferes with WoW's nameplate positioning
    -- Only apply glow effect

    if cfg.targetGlow then
        if not frame.glow then
            -- Create glow texture
            frame.glow = frame:CreateTexture(nil, "BACKGROUND")
            frame.glow:SetTexture("Interface\\Buttons\\WHITE8X8")
            frame.glow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3)
            frame.glow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 3, -3)
            frame.glow:SetBlendMode("ADD")
        end

        local color = cfg.targetGlowColor or {1, 1, 1, 0.8}
        frame.glow:SetVertexColor(unpack(color))
        frame.glow:Show()

        -- Subtle pulsing animation
        if not frame.glowAnim then
            frame.glowAnim = 0
        end

        frame:SetScript("OnUpdate", function(self, elapsed)
            self.glowAnim = (self.glowAnim or 0) + elapsed
            local alpha =0.3 + (math.sin(self.glowAnim * 3) * 0.2)
            if self.glow then
                self.glow:SetAlpha(alpha)
            end
        end)
    end

    self.CurrentTarget = frame
end

-- Remove glow effects
function Target:RemoveTargetEffects(frame)
    if not frame then return end

    -- Don't reset scale - WoW handles positioning

    -- Remove glow
    if frame.glow then
        frame.glow:Hide()
    end

    -- Stop animation
    frame:SetScript("OnUpdate", nil)

    if self.CurrentTarget == frame then
        self.CurrentTarget = nil
    end
end

-- Update target on target change
function Target:OnTargetChanged()
    -- Effects are applied in the main skinning function
    -- This is called from the event handler
end
