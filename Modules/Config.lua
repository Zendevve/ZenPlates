-- ZenPlates: Configuration System
-- AceDB-3.0 Integration with Plug-and-Play Defaults

local _, ZenPlates = ...
ZenPlates.Config = {}
local Config = ZenPlates.Config

-- Presets definition
local PRESETS = {
    ["Minimal"] = {
        showCastBars = false,
        showDebuffs = false,
        showClassIcons = false,
        healthTextMode = "NONE",
        showElite = false,
        showRare = false,
    },
    ["Balanced"] = {  -- DEFAULT
        showCastBars = true,
        showDebuffs = true,
        showClassIcons = true,
        healthTextMode = "PERCENT",
        showElite = true,
        showRare = true,
    },
    ["Detailed"] = {
        showCastBars = true,
        showCastTime = true,
        showDebuffs = true,
        showDebuffStacks = true,
        showClassIcons = true,
        healthTextMode = "BOTH",
        showTargetOf = true,
        showElite = true,
        showRare = true,
    }
}

-- Default configuration values
local DEFAULTS = {
    profile = {
        -- Meta settings
        currentPreset = "Balanced",
        autoConfigureForRole = true,

        -- General
        globalScale = 1.0,
        texture = "Interface\\Buttons\\WHITE8X8",
        font = "Fonts\\FRIZQT__.TTF",
        fontSize = 11,
        fontOutline = "THICKOUTLINE",

        -- Colors
        backdropColor = {0.05, 0.05, 0.05, 0.95},
        borderColor = {0, 0, 0, 1},

        -- Health
        useClassColors = true,
        showHealthPercent = true,
        showHealthValue = false,
        healthValueFormat = "smart",

        -- Target
        targetZoom = true,
        targetZoomScale = 1.15,
        targetGlow = true,
        targetGlowColor = {1, 1, 1, 0.8},

        -- Debuffs
        showDebuffs = true,
        debuffsPerRow = 6,
        debuffSize = 20,
        showDebuffDurations = true,
        debuffFilter = "mine",

        -- Combo Points
        showComboPoints = true,
        comboPointSize = 8,

        -- Cast Bars
        showCastBars = true,
        showCastTime = true,
        castBarHeight = 12,

        -- Filtering
        hideTotem = false,
        hideCritter = true,
        hidePets = false,
    }
}

-- Initialize configuration
function Config:Initialize()
    -- Initialize AceDB
    self.db = LibStub("AceDB-3.0"):New("ZenPlatesDB", DEFAULTS, true)

    -- Register callbacks
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

    -- Apply role defaults if enabled (and first load)
    if self.db.profile.autoConfigureForRole then
        self:ApplyDefaultsForRole()
    end

    -- Register options table (if Options module loaded)
    if ZenPlates.Options then
        ZenPlates.Options:RegisterOptions()
    end
end

-- Profile change handler
function Config:OnProfileChanged()
    ZenPlates:RefreshAllPlates()
    print("|cff00ff00ZenPlates:|r Profile updated.")
end

-- Apply defaults based on role
function Config:ApplyDefaultsForRole()
    -- In 3.3.5a, GetSpecializationRole doesn't exist directly like retail
    -- We have to infer from talent points or class
    local _, class = UnitClass("player")

    -- Simple class-based defaults for now
    if class == "WARRIOR" or class == "DEATHKNIGHT" or class == "PALADIN" or class == "DRUID" then
        -- Potential tank
        -- We could check talents here for more accuracy
    end

    -- For now, just stick to Balanced preset as safe default
    self:ApplyPreset("Balanced")
end

-- Apply a preset
function Config:ApplyPreset(presetName)
    local preset = PRESETS[presetName]
    if not preset then return end

    for key, value in pairs(preset) do
        self.db.profile[key] = value
    end

    self.db.profile.currentPreset = presetName
    ZenPlates:RefreshAllPlates()
end

-- Get a config value
function Config:Get(key)
    return self.db.profile[key]
end

-- Set a config value
function Config:Set(key, value)
    self.db.profile[key] = value
    ZenPlates:RefreshAllPlates()
end

-- Reset to defaults
function Config:ResetToDefaults()
    self.db:ResetDB()
    self:ApplyDefaultsForRole()
    print("|cff00ff00ZenPlates:|r Settings reset to defaults.")
end
