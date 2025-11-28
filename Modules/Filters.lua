-- ZenPlates: Filters Module
-- Handles unit filtering and hiding specific unit types

local _, ZenPlates = ...
ZenPlates.Filters = {}

local Filters = ZenPlates.Filters
local Config = ZenPlates.Config
local Utils = ZenPlates.Utils

-- Check if a nameplate should be hidden based on filters
function Filters:ShouldHide(frame, nameText)
    if not nameText then return false end

    local name = nameText:GetText()
    if not name then return false end

    local cfg = ZenPlatesDB

    -- Check totem filter
    if cfg.hideTotem and Utils:IsTotem(name) then
        return true
    end

    -- Check critter filter
    if cfg.hideCritter and Utils:IsCritter(name) then
        return true
    end

    -- Check custom hide list
    if cfg.customHideList then
        for _, hideName in ipairs(cfg.customHideList) do
            if name == hideName or string.find(name, hideName) then
                return true
            end
        end
    end

    -- TODO: Add pet filtering

    return false
end

-- Apply hide/show based on filters
function Filters:ApplyFilters(frame, nameText)
    if self:ShouldHide(frame, nameText) then
        frame:Hide()
        return true
    end
    return false
end

-- Add unit to custom hide list
function Filters:AddToHideList(unitName)
    if not unitName or unitName == "" then return end

    if not ZenPlatesDB.customHideList then
        ZenPlatesDB.customHideList = {}
    end

    -- Check if already in list
    for _, name in ipairs(ZenPlatesDB.customHideList) do
        if name == unitName then
            return false
        end
    end

    table.insert(ZenPlatesDB.customHideList, unitName)
    return true
end

-- Remove unit from custom hide list
function Filters:RemoveFromHideList(unitName)
    if not unitName or not ZenPlatesDB.customHideList then return false end

    for i, name in ipairs(ZenPlatesDB.customHideList) do
        if name == unitName then
            table.remove(ZenPlatesDB.customHideList, i)
            return true
        end
    end

    return false
end

-- Clear custom hide list
function Filters:ClearHideList()
    ZenPlatesDB.customHideList = {}
end

-- Get hide list
function Filters:GetHideList()
    return ZenPlatesDB.customHideList or {}
end
