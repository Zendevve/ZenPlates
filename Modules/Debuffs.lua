-- ZenPlates: Debuff Module
-- Handles debuff tracking, display, caching, and filtering

local _, ZenPlates = ...
ZenPlates.Debuffs = {}

local Debuffs = ZenPlates.Debuffs
local Config = ZenPlates.Config
local Utils = ZenPlates.Utils

-- Debuff cache for units (remembers debuffs when not targeted)
Debuffs.Cache = {}

-- Create debuff icon frame
local function CreateDebuffIcon(parent, index)
    local cfg = Config.db.profile
    local size = cfg.debuffSize or 20

    local icon = CreateFrame("Frame", nil, parent)
    icon:SetWidth(size)
    icon:SetHeight(size)

    -- Icon texture
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints()
    icon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    -- Border (brutalist - thick black border)
    icon.border = icon:CreateTexture(nil, "OVERLAY")
    icon.border:SetTexture("Interface\\Buttons\\WHITE8X8")
    icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    icon.border:SetVertexColor(0, 0, 0, 1)
    icon.border:SetDrawLayer("OVERLAY", 0)

    -- Duration text
    icon.duration = icon:CreateFontString(nil, "OVERLAY")
    icon.duration:SetFont(cfg.font, cfg.fontSize - 2, "OUTLINE")
    icon.duration:SetPoint("BOTTOM", icon, "BOTTOM", 0, 1)
    icon.duration:SetTextColor(1, 1, 1)
    icon.duration:SetShadowOffset(1, -1)

    icon:Hide()
    return icon
end

-- Update debuff display for a nameplate
function Debuffs:UpdateDebuffs(virtual, unit)
    if not virtual or not unit then return end
    local cfg = Config.db.profile
    if not cfg.showDebuffs then
        if virtual.debuffs then virtual.debuffs:Hide() end
        return
    end

    -- Create debuff container if needed
    if not virtual.debuffs then
        virtual.debuffs = CreateFrame("Frame", nil, virtual)
        virtual.debuffs:SetPoint("TOP", virtual, "BOTTOM", 0, -4)
        virtual.debuffs:SetWidth(cfg.width)
        virtual.debuffs:SetHeight(cfg.debuffSize + 4)
        virtual.debuffs.icons = {}
    end
    virtual.debuffs:Show()

    local debuffsPerRow = cfg.debuffsPerRow or 6
    local debuffSize = cfg.debuffSize or 20
    local spacing = 2
    local shown = 0

    -- Scan debuffs on unit
    for i = 1, 40 do
        local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(unit, i)

        if not name then break end

        -- Apply filter
        local shouldShow = false
        if cfg.debuffFilter == "all" then
            shouldShow = true
        elseif cfg.debuffFilter == "mine" then
            shouldShow = (caster == "player" or caster == "pet")
        elseif cfg.debuffFilter == "important" then
            -- TODO: Add important debuff list
            shouldShow = (caster == "player" or caster == "pet")
        end

        if shouldShow then
            shown = shown + 1

            -- Create icon if needed
            if not virtual.debuffs.icons[shown] then
                virtual.debuffs.icons[shown] = CreateDebuffIcon(virtual.debuffs, shown)
            end

            local debuffIcon = virtual.debuffs.icons[shown]
            debuffIcon.texture:SetTexture(icon)
            debuffIcon:SetWidth(debuffSize)
            debuffIcon:SetHeight(debuffSize)

            -- Position
            local row = math.floor((shown - 1) / debuffsPerRow)
            local col = (shown - 1) % debuffsPerRow
            debuffIcon:ClearAllPoints()
            debuffIcon:SetPoint("TOPLEFT", virtual.debuffs, "TOPLEFT", col * (debuffSize + spacing), -row * (debuffSize + spacing))

            -- Update duration
            if cfg.showDebuffDurations then
                local timeLeft = expirationTime - GetTime()
                if timeLeft > 0 then
                    debuffIcon.duration:SetText(string.format("%.0f", timeLeft))
                    debuffIcon.endTime = expirationTime
                    debuffIcon:SetScript("OnUpdate", function(self, elapsed)
                        local remaining = self.endTime - GetTime()
                        if remaining > 0 then
                            self.duration:SetText(string.format("%.0f", remaining))
                        else
                            self.duration:SetText("")
                            self:SetScript("OnUpdate", nil)
                        end
                    end)
                else
                    debuffIcon.duration:SetText("")
                end
            else
                debuffIcon.duration:SetText("")
            end

            -- Store in cache
            -- (Caching logic remains same, just ensure it uses Config.db.profile if needed)

            debuffIcon:Show()
        end
    end

    -- Hide unused icons
    for i = shown + 1, #virtual.debuffs.icons do
        virtual.debuffs.icons[i]:Hide()
    end
end

-- Show cached debuffs (when unit is not targeted but still visible)
function Debuffs:ShowCachedDebuffs(virtual, guid)
    -- TODO: Implement cached display
end

-- Clear old cache entries (call periodically)
function Debuffs:CleanCache()
    local now = GetTime()
    for guid, debuffs in pairs(self.Cache) do
        for i, debuff in pairs(debuffs) do
            if debuff.expirationTime and debuff.expirationTime < now then
                debuffs[i] = nil
            end
        end
        if not next(debuffs) then
            self.Cache[guid] = nil
        end
    end
end
