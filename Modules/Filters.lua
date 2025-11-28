-- ZenPlates: Filters Module
-- Handles unit filtering (hiding specific plates)

local _, ZenPlates = ...
ZenPlates.Filters = {}

local Filters = ZenPlates.Filters
local Config = ZenPlates.Config

function Filters:ApplyFilters(virtual, nameText)
    local cfg = Config.db.profile
    if not nameText then return false end

    local name = nameText:GetText()
    if not name then return false end

    -- 1. Totems
    if cfg.hideTotem then
        -- Simple name check for common totems
        if name:find("Totem") then
            virtual:Hide()
            return true
        end
    end

    -- 2. Critters (Level 1 neutral/friendly usually)
    -- Hard to detect without unit data, but we can check level text if available

    -- 3. Custom List
    -- if cfg.customHideList[name] then
    --     virtual:Hide()
    --     return true
    -- end

    virtual:Show()
    return false
end
