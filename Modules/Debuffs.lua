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
    local cfg = ZenPlatesDB
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
function Debuffs:UpdateDebuffs(frame, unit)
    if not frame or not unit then return end
    if not ZenPlatesDB.showDebuffs then return end

    -- Create debuff container if needed
    if not frame.debuffs then
        frame.debuffs = CreateFrame("Frame", nil, frame)
        frame.debuffs:SetPoint("TOP", frame, "BOTTOM", 0, -4)
        frame.debuffs:SetWidth(ZenPlatesDB.width)
        frame.debuffs:SetHeight(ZenPlatesDB.debuffSize + 4)
        frame.debuffs.icons = {}
    end

    local cfg = ZenPlatesDB
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
            if not frame.debuffs.icons[shown] then
                frame.debuffs.icons[shown] = CreateDebuffIcon(frame.debuffs, shown)
            end

            local debuffIcon = frame.debuffs.icons[shown]
            debuffIcon.texture:SetTexture(icon)

            -- Position
            local row = math.floor((shown - 1) / debuffsPerRow)
            local col = (shown - 1) % debuffsPerRow
            debuffIcon:ClearAllPoints()
            debuffIcon:SetPoint("TOPLEFT", frame.debuffs, "TOPLEFT", col * (debuffSize + spacing), -row * (debuffSize + spacing))

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
            if cfg.enableDebuffCache then
                local guid = UnitGUID(unit)
                if guid then
                    if not self.Cache[guid] then
                        self.Cache[guid] = {}
                    end
                    self.Cache[guid][i] = {
                        name = name,
                        icon = icon,
                        duration = duration,
                        expirationTime = expirationTime,
                        caster = caster,
                    }
                end
            end

            debuffIcon:Show()
        end
    end

    -- Hide unused icons
    for i = shown + 1, #frame.debuffs.icons do
        frame.debuffs.icons[i]:Hide()
    end
end

-- Show cached debuffs (when unit is not targeted but still visible)
function Debuffs:ShowCachedDebuffs(frame, guid)
    if not guid or not self.Cache[guid] or not ZenPlatesDB.enableDebuffCache then return end

    -- TODO: Display cached debuffs with faded appearance
    -- This requires storing the debuff data and rendering it separately
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

        -- Remove empty entries
        if not next(debuffs) then
            self.Cache[guid] = nil
        end
    end
end
