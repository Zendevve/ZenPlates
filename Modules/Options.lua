-- ZenPlates: Options Module
-- AceConfig-3.0 Options Table

local _, ZenPlates = ...
ZenPlates.Options = {}
local Options = ZenPlates.Options
local L = ZenPlates.L

function Options:RegisterOptions()
    local config = LibStub("AceConfig-3.0")
    local dialog = LibStub("AceConfigDialog-3.0")

    local options = {
        type = "group",
        name = "ZenPlates",
        args = {
            presets = {
                type = "group",
                name = L["Quick Setup"],
                order = 1,
                args = {
                    description = {
                        type = "description",
                        name = L["Choose a preset to get started quickly"],
                        order = 1,
                    },
                    preset = {
                        type = "select",
                        name = "Preset",
                        order = 2,
                        values = {
                            ["Minimal"] = L["Minimal - Just the essentials"],
                            ["Balanced"] = L["Balanced - Recommended (Default)"],
                            ["Detailed"] = L["Detailed - Show everything"],
                        },
                        get = function() return ZenPlates.Config:Get("currentPreset") end,
                        set = function(_, val) ZenPlates.Config:ApplyPreset(val) end,
                    },
                    autoRole = {
                        type = "toggle",
                        name = L["Auto-configure for my role"],
                        order = 3,
                        get = function() return ZenPlates.Config:Get("autoConfigureForRole") end,
                        set = function(_, val) ZenPlates.Config:Set("autoConfigureForRole", val) end,
                    },
                }
            },
            general = {
                type = "group",
                name = L["General"],
                order = 2,
                args = {
                    scale = {
                        type = "range",
                        name = "Global Scale",
                        min = 0.5, max = 2.0, step = 0.05,
                        get = function() return ZenPlates.Config:Get("globalScale") end,
                        set = function(_, val) ZenPlates.Config:Set("globalScale", val) end,
                    },
                }
            },
            -- Add more groups here
        }
    }

    -- Add profiles
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(ZenPlates.Config.db)

    config:RegisterOptionsTable("ZenPlates", options)
    dialog:AddToBlizOptions("ZenPlates", "ZenPlates")
end
