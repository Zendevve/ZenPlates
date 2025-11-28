-- ZenPlates: Event Handler
-- Centralized event management system

local _, ZenPlates = ...
local EventHandler = CreateFrame("Frame")

-- State tracking
ZenPlates.state = {
    inCombat = false,
    hasTarget = false,
    targetGUID = nil,
    playerLevel = UnitLevel("player"),
}

-- Event handlers
function EventHandler:PLAYER_LOGIN()
    print("|cff00ff00ZenPlates|r loaded. Type |cffFFFF00/zenplates|r to configure.")

    -- Initialize database
    if ZenPlates.Database then
        ZenPlates.Database:Initialize()
    end

    -- Apply saved settings
    if ZenPlates.ApplySettings then
        ZenPlates:ApplySettings()
    end
end

function EventHandler:PLAYER_REGEN_DISABLED()
    ZenPlates.state.inCombat = true

    -- Notify widgets
    if ZenPlates.OnCombatStart then
        ZenPlates:OnCombatStart()
    end
end

function EventHandler:PLAYER_REGEN_ENABLED()
    ZenPlates.state.inCombat = false

    -- Process queued updates
    if ZenPlates.OnCombatEnd then
        ZenPlates:OnCombatEnd()
    end
end

function EventHandler:PLAYER_TARGET_CHANGED()
    -- Update target state
    if UnitExists("target") then
        ZenPlates.state.hasTarget = true
        ZenPlates.state.targetGUID = UnitGUID("target")
    else
        ZenPlates.state.hasTarget = false
        ZenPlates.state.targetGUID = nil
    end

    -- Update all plates
    if ZenPlates.UpdateTargetPlate then
        ZenPlates:UpdateTargetPlate()
    end
end

function EventHandler:UPDATE_MOUSEOVER_UNIT()
    -- Help identify target plate more accurately
    if ZenPlates.state.hasTarget and ZenPlates.UpdateTargetPlate then
        ZenPlates:UpdateTargetPlate()
    end
end

function EventHandler:PLAYER_LEVEL_UP(_, newLevel)
    ZenPlates.state.playerLevel = newLevel
end

function EventHandler:PLAYER_ENTERING_WORLD()
    -- Refresh all plates when zoning
    if ZenPlates.RefreshAllPlates then
        ZenPlates:RefreshAllPlates()
    end
end

function EventHandler:UNIT_COMBO_POINTS(_, unit)
    if unit == "player" or unit == "vehicle" then
        if ZenPlates.UpdateComboPoints then
            ZenPlates:UpdateComboPoints()
        end
    end
end

-- Main event dispatcher
function EventHandler:OnEvent(event, ...)
    if self[event] then
        self[event](self, event, ...)
    end
end

-- Register events
EventHandler:SetScript("OnEvent", EventHandler.OnEvent)
EventHandler:RegisterEvent("PLAYER_LOGIN")
EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
EventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
EventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
EventHandler:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
EventHandler:RegisterEvent("PLAYER_LEVEL_UP")
EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:RegisterEvent("UNIT_COMBO_POINTS")

-- Export
ZenPlates.EventHandler = EventHandler
