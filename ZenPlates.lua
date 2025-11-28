--[[
    ZenPlates v3.0 - Plug and Play Nameplates

    A feature-rich nameplate addon with smart defaults that works
    perfectly out of the box. Zero configuration needed!
]]--

local addonName, ZenPlates = ...

-- Create global namespace for external access
_G[addonName] = ZenPlates

-- Version
ZenPlates.version = "3.0"
ZenPlates.loaded = false

-- All modules will be loaded via .toc before this point
-- This file just creates the addon namespace and sets base properties
