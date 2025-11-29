local addonName, ns = ...
local CastBar = CreateFrame("Frame")
ns.CastBar = CastBar

-- Update Timer Text
local function OnCastbarUpdate(self, elapsed)
    if not self:IsShown() then return end

    local current = self:GetValue()
    local min, max = self:GetMinMaxValues()
    local timeLeft = max - current

    if self.timerText then
        if timeLeft > 0 then
            self.timerText:SetText(string.format("%.1f", timeLeft))
        else
            self.timerText:SetText("")
        end
    end
end

-- Update Spell Name
local function OnCastbarShow(self)
    if not self.spellText then return end

    -- Try to find the unit this castbar belongs to
    -- The castbar is a child of the nameplate frame.
    local frame = self:GetParent()
    if not frame.zen or not frame.zen.name then return end

    local unitName = frame.zen.name:GetText()
    local unit = nil

    if UnitName("target") == unitName then
        unit = "target"
    elseif UnitName("mouseover") == unitName then
        unit = "mouseover"
    end

    -- If we found a unit, get the spell name
    if unit then
        local spell, _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
        if not spell then
            spell, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
        end

        if spell then
            self.spellText:SetText(spell)
        end
    else
        -- Fallback: If we can't find the unit (e.g. not target/mouseover),
        -- we might not be able to get the spell name easily in 3.3.5a without scanning combat log.
        -- For now, leave it empty or try to persist it?
        self.spellText:SetText("")
    end
end

-- Initialize CastBar Text
function ns:SetupCastBar(frame)
    local castBar = frame.zen and frame.zen.castBar
    if not castBar then return end
    if castBar.zenTextInitialized then return end

    -- Spell Name (Left)
    castBar.spellText = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    castBar.spellText:SetPoint("LEFT", castBar, "LEFT", 2, 0)
    castBar.spellText:SetPoint("RIGHT", castBar, "CENTER", 0, 0) -- Limit width
    castBar.spellText:SetJustifyH("LEFT")
    castBar.spellText:SetFont(ns.defaults.font, 9, ns.defaults.fontStyle)
    castBar.spellText:SetTextColor(1, 1, 1)
    castBar.spellText:SetShadowOffset(1, -1)

    -- Timer (Right)
    castBar.timerText = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    castBar.timerText:SetPoint("RIGHT", castBar, "RIGHT", -2, 0)
    castBar.timerText:SetFont(ns.defaults.font, 9, ns.defaults.fontStyle)
    castBar.timerText:SetTextColor(1, 1, 1)
    castBar.timerText:SetShadowOffset(1, -1)

    -- Hooks
    castBar:HookScript("OnShow", OnCastbarShow)
    castBar:HookScript("OnUpdate", OnCastbarUpdate)

    castBar.zenTextInitialized = true
end

-- Called from Core/Nameplates.lua
function ns:UpdateCastBar(frame)
    ns:SetupCastBar(frame)
end
