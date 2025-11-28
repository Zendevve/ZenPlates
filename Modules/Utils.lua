-- ZenPlates: Utility Functions
-- Shared helper functions used across modules

local _, ZenPlates = ...
ZenPlates.Utils = {}

local Utils = ZenPlates.Utils

-- Format large numbers (1234 -> 1.2k, 1234567 -> 1.2M)
function Utils:FormatNumber(value)
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fk", value / 1000)
    else
        return tostring(value)
    end
end

-- Format health as percentage
function Utils:FormatPercent(current, max)
    if max == 0 then return "0%" end
    return string.format("%d%%", (current / max) * 100)
end

-- Get class color by class token
function Utils:GetClassColor(class)
    if not class then return 0.5, 0.5, 0.5 end

    local colors = {
        ["DEATHKNIGHT"] = {0.77, 0.12, 0.23}, -- Red
        ["DRUID"]       = {1.00, 0.49, 0.04}, -- Orange
        ["HUNTER"]      = {0.67, 0.83, 0.45}, -- Green
        ["MAGE"]        = {0.41, 0.80, 0.94}, -- Cyan
        ["PALADIN"]     = {0.96, 0.55, 0.73}, -- Pink
        ["PRIEST"]      = {1.00, 1.00, 1.00}, -- White
        ["ROGUE"]       = {1.00, 0.96, 0.41}, -- Yellow
        ["SHAMAN"]      = {0.00, 0.44, 0.87}, -- Blue
        ["WARLOCK"]     = {0.58, 0.51, 0.79}, -- Purple
        ["WARRIOR"]     = {0.78, 0.61, 0.43}, -- Tan
    }

    return unpack(colors[class] or {0.5, 0.5, 0.5})
end

-- Get reaction color (friendly/neutral/hostile)
function Utils:GetReactionColor(unit)
    if not unit then return 0.5, 0.5, 0.5 end

    local r, g, b = UnitSelectionColor(unit)
    if r and g and b then
        return r, g, b
    end

    -- Fallback to manual check
    if UnitIsFriend("player", unit) then
        return 0.0, 1.0, 0.0 -- Green
    elseif UnitIsEnemy("player", unit) then
        return 1.0, 0.0, 0.0 -- Red
    else
        return 1.0, 1.0, 0.0 -- Yellow (neutral)
    end
end

-- Check if unit is a totem
function Utils:IsTotem(name)
    if not name then return false end

    local totems = {
        "Grounding Totem",
        "Tremor Totem",
        "Earthbind Totem",
        "Stoneclaw Totem",
        "Stoneskin Totem",
        "Strength of Earth Totem",
        "Frost Resistance Totem",
        "Flametongue Totem",
        "Magma Totem",
        "Searing Totem",
        "Fire Nova Totem",
        "Totem of Wrath",
        "Cleansing Totem",
        "Healing Stream Totem",
        "Mana Spring Totem",
        "Mana Tide Totem",
        "Windfury Totem",
        "Wrath of Air Totem",
        "Nature Resistance Totem",
        "Tranquil Air Totem",
    }

    for _, totem in ipairs(totems) do
        if name == totem then return true end
    end

    return false
end

-- Check if unit is a critter
function Utils:IsCritter(name)
    if not name then return false end

    local critters = {
        "Rabbit", "Squirrel", "Rat", "Sheep", "Cow", "Chicken",
        "Frog", "Cat", "Prairie Dog", "Deer", "Toad", "Snake",
    }

    for _, critter in ipairs(critters) do
        if string.find(name, critter) then return true end
    end

    return false
end

-- Deep copy table
function Utils:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils:DeepCopy(orig_key)] = Utils:DeepCopy(orig_value)
        end
        setmetatable(copy, Utils:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Round number to decimals
function Utils:Round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end
