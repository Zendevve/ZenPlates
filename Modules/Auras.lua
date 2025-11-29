local addonName, ns = ...
local Auras = CreateFrame("Frame")
ns.Auras = Auras

-- Cache
local UnitDebuff = UnitDebuff
local CreateFrame = CreateFrame
local GetTime = GetTime

-- Configuration
local AURA_SIZE = ns.defaults.auraSize or 20
local AURA_SPACING = 4
local MAX_AURAS = 5

-- Update a specific aura icon
local function UpdateAuraIcon(frame, index, name, icon, count, debuffType, duration, expirationTime)
    if not frame.zen.auras then frame.zen.auras = {} end

    local button = frame.zen.auras[index]
    if not button then
        -- Create Icon Frame
        button = CreateFrame("Frame", nil, frame.zen)
        button:SetSize(AURA_SIZE, AURA_SIZE)

        -- Backdrop (Brutalist Border)
        button.backdrop = CreateFrame("Frame", nil, button)
        button.backdrop:SetPoint("TOPLEFT", -1, 1)
        button.backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
        button.backdrop:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        button.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

        -- Icon Texture
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetAllPoints()
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Zoom in to remove default borders

        -- Cooldown Spiral
        button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.cd:SetAllPoints()
        button.cd:SetReverse(true)

        -- Stack Count
        button.count = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
        button.count:SetFont(ns.defaults.font, 10, ns.defaults.fontStyle)
        button.count:SetTextColor(1, 1, 1)
        button.count:SetShadowOffset(1, -1)

        frame.zen.auras[index] = button
    end

    -- Update Content
    button.icon:SetTexture(icon)

    if count and count > 1 then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:Hide()
    end

    if duration and duration > 0 then
        button.cd:SetCooldown(expirationTime - duration, duration)
        button.cd:Show()
    else
        button.cd:Hide()
    end

    -- Position
    button:ClearAllPoints()
    if index == 1 then
        -- Anchor first aura to TOPLEFT of HealthBar (floating above)
        button:SetPoint("BOTTOMLEFT", frame.zen.healthBar, "TOPLEFT", 0, 12) -- 12px padding above bar (clears threat bar)
    else
        -- Anchor subsequent auras to the right of the previous one
        button:SetPoint("LEFT", frame.zen.auras[index-1], "RIGHT", AURA_SPACING, 0)
    end

    button:Show()
end

-- Scan auras for a unit and update the nameplate
function ns:UpdateAuras(frame)
    if not ns.defaults.showAuras then return end
    if not frame.zen or not frame.zen.name then return end

    local name = frame.zen.name:GetText()
    if not name then return end

    -- Determine UnitID (Target or Mouseover)
    local unit = nil
    if UnitExists("target") and UnitName("target") == name then
        unit = "target"
    elseif UnitExists("mouseover") and UnitName("mouseover") == name then
        unit = "mouseover"
    end

    -- Hide all existing auras first
    if frame.zen.auras then
        for _, button in pairs(frame.zen.auras) do
            button:Hide()
        end
    end

    if not unit then return end

    -- Scan Debuffs (PLAYER only)
    local auraIndex = 1
    for i = 1, 40 do
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff(unit, i)

        if not name then break end

        if unitCaster == "player" then
            UpdateAuraIcon(frame, auraIndex, name, icon, count, debuffType, duration, expirationTime)
            auraIndex = auraIndex + 1
            if auraIndex > MAX_AURAS then break end
        end
    end
end

-- Event Handling
Auras:RegisterEvent("UNIT_AURA")
Auras:RegisterEvent("PLAYER_TARGET_CHANGED")
Auras:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

Auras:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_AURA" then
        if unit == "target" then
            ns:UpdateAuras(ns:GetPlate("target"))
        elseif unit == "mouseover" then
            ns:UpdateAuras(ns:GetPlate("mouseover"))
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        ns:UpdateAuras(ns:GetPlate("target"))
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        ns:UpdateAuras(ns:GetPlate("mouseover"))
    end
end)

-- Helper to find plate by unit (Basic implementation, Core might have better)
function ns:GetPlate(unit)
    local name = UnitName(unit)
    if not name then return nil end

    for frame in pairs(ns.nameplates) do
        if frame:IsShown() and frame.zen and frame.zen.name and frame.zen.name:GetText() == name then
            return frame
        end
    end
    return nil
end
