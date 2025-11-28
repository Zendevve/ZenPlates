--[[
    ZenPlates v2.0
    Hyperminimalist brutalist nameplates for WoW 3.3.5a

    All functionality has been moved to modular files in /Modules/
    This file only creates the addon namespace.
]]--

local addonName = "ZenPlates"
local ZenPlates = {}

-- Create global namespace for access across modules
_G[addonName] = ZenPlates

-- Version info
ZenPlates.version = "2.0"
ZenPlates.loaded = false

-- The Core module (loaded last in .toc) will handle all initialization
