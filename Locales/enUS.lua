-- ZenPlates: Localization
-- Metatable-based localization with automatic fallbacks

local _, ZenPlates = ...

local L = setmetatable({}, {
    __index = function(self, key)
        return key  -- Fallback to English key
    end
})

-- Format helper
function L:F(text, ...)
    return string.format(L[text], ...)
end

-- English (base locale)
L["ZenPlates loaded. Type /zenplates to configure."] = true
L["Settings reset to defaults. Reload to apply changes."] = true

-- Quick Setup
L["Quick Setup"] = true
L["Choose a preset to get started quickly"] = true
L["Minimal - Just the essentials"] = true
L["Balanced - Recommended (Default)"] = true
L["Detailed - Show everything"] = true
L["Auto-configure for my role"] = true

-- General Settings
L["General"] = true
L["Health Bars"] = true
L["Cast Bars"] = true
L["Widgets"] = true
L["Filters"] = true

-- Health Bar
L["Use Class Colors"] = true
L["Show Health Percent"] = true
L["Show Health Value"] = true
L["Value Format"] = true

-- Target
L["Target Zoom"] = true
L["Target Glow"] = true
L["Zoom Scale"] = true

-- Debuffs
L["Show Debuffs"] = true
L["Debuff Filter"] = true
L["All Debuffs"] = true
L["My Debuffs Only"] = true
L["Important Debuffs"] = true
L["Debuffs Per Row"] = true
L["Debuff Size"] = true
L["Show Durations"] = true

-- Combo Points
L["Show Combo Points"] = true
L["Combo Point Size"] = true

-- Cast Bars
L["Show Cast Bars"] = true
L["Show Cast Time"] = true
L["Cast Bar Height"] = true

-- Filters
L["Hide Totems"] = true
L["Hide Critters"] = true
L["Hide Pets"] = true

-- Presets
L["Configured for %s"] = true
L["TANK"] = "Tank"
L["HEALER"] = "Healer"
L["DAMAGER"] = "DPS"

-- Export
ZenPlates.L = L
