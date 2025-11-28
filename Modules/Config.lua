-- ZenPlates: Configuration System
-- Manages addon settings and provides defaults

local _, ZenPlates = ...
ZenPlates.Config = {}

local Config = ZenPlates.Config

-- Default configuration values
Config.Defaults = {
    -- General Settings
    texture = "Interface\\Buttons\\WHITE8X8",
    font = "Fonts\\FRIZQT__.TTF",
    fontSize = 10,
    fontOutline = "OUTLINE",
    width = 110,
    height = 12,

    -- Colors (Brutalist aesthetic - high contrast)
    backdropColor = {0.05, 0.05, 0.05, 0.95}, -- Near-black
    borderColor = {0, 0, 0, 1}, -- Pure black

    -- Health Display
    useClassColors = true,
    showHealthPercent = true,
    showHealthValue = false,
    healthValueFormat = "smart", -- "smart", "current", "both"

    -- Elite/Rare
    showElite = true,
    showRare = true,

    -- Target Effects
    targetZoom = true,
    targetZoomScale = 1.15,
    targetGlow = true,
    targetGlowColor = {1, 1, 1, 0.8}, -- White glow

    -- Debuffs
    showDebuffs = true,
    debuffsPerRow = 6,
    debuffSize = 20,
    showDebuffDurations = true,
    debuffFilter = "mine", -- "all", "mine", "important"
    enableDebuffCache = true,

    -- Combo Points
    showComboPoints = true,
    comboPointSize = 8,

    -- Cast Bars
    showCastBars = true,
    showCastTime = true,
    castBarHeight = 12,

    -- Unit Filtering
    hideTotem = false,
    hideCritter = true,
    hidePets = false,
    customHideList = {}, -- Table of unit names to hide

    -- Vanilla Options
    nonBlockingMouseLook = false,
    allowOverlap = false,
}

-- Initialize saved variables
function Config:Initialize()
    -- Create saved variable if it doesn't exist
    if not ZenPlatesDB then
        ZenPlatesDB = ZenPlates.Utils:DeepCopy(self.Defaults)
    else
        -- Merge with defaults (add any new settings)
        for key, value in pairs(self.Defaults) do
            if ZenPlatesDB[key] == nil then
                if type(value) == "table" then
                    ZenPlatesDB[key] = ZenPlates.Utils:DeepCopy(value)
                else
                    ZenPlatesDB[key] = value
                end
            end
        end
    end

    -- Apply CVar settings
    SetCVar("nameplateAllowOverlap", ZenPlatesDB.allowOverlap and 1 or 0)
end

-- Get a config value
function Config:Get(key)
    return ZenPlatesDB[key]
end

-- Set a config value
function Config:Set(key, value)
    ZenPlatesDB[key] = value
end

-- Reset all settings to defaults
function Config:ResetToDefaults()
    ZenPlatesDB = ZenPlates.Utils:DeepCopy(self.Defaults)
    SetCVar("nameplateAllowOverlap", ZenPlatesDB.allowOverlap and 1 or 0)
    print("|cff00ff00ZenPlates:|r Settings reset to defaults. Type /reload to apply changes.")
end

-- Brutalist color scheme
Config.BrutalistColors = {
    bgDark = {0.05, 0.05, 0.05, 0.95},
    bgMedium = {0.15, 0.15, 0.15, 0.95},
    border = {0, 0, 0, 1},
    text = {1, 1, 1, 1},
    accent = {0.9, 0.9, 0.9, 1},
}
