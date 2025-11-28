-- ZenPlates: Widget Framework
-- Modular widget system inspired by TidyPlates

local _, ZenPlates = ...
local WidgetCore = {}

-- Registered widgets
local RegisteredWidgets = {}
local ActiveWidgets = {}  -- [virtualPlate][widgetName] = widget instance

-- Register a new widget
function WidgetCore:RegisterWidget(name, widget)
    if not widget.Create or not widget.Update then
        error("Widget must have Create() and Update() methods")
    end

    RegisteredWidgets[name] = widget
end

-- Enable a widget on a plate
function WidgetCore:EnableWidget(name, virtualPlate)
    local widget = RegisteredWidgets[name]
    if not widget then return end

    -- Initialize active widgets table for this plate
    if not ActiveWidgets[virtualPlate] then
        ActiveWidgets[virtualPlate] = {}
    end

    -- Create widget instance if it doesn't exist
    if not ActiveWidgets[virtualPlate][name] then
        ActiveWidgets[virtualPlate][name] = widget:Create(virtualPlate)
    end

    -- Update the widget
    widget:Update(ActiveWidgets[virtualPlate][name], virtualPlate)
end

-- Disable a widget on a plate
function WidgetCore:DisableWidget(name, virtualPlate)
    if ActiveWidgets[virtualPlate] and ActiveWidgets[virtualPlate][name] then
        ActiveWidgets[virtualPlate][name]:Hide()
        ActiveWidgets[virtualPlate][name] = nil
    end
end

-- Update all active widgets on a plate
function WidgetCore:UpdatePlateWidgets(virtualPlate)
    if not ActiveWidgets[virtualPlate] then return end

    for name, instance in pairs(ActiveWidgets[virtualPlate]) do
        local widget = RegisteredWidgets[name]
        if widget and widget.Update then
            widget:Update(instance, virtualPlate)
        end
    end
end

-- Clean up widgets when plate is hidden
function WidgetCore:CleanupPlate(virtualPlate)
    if ActiveWidgets[virtualPlate] then
        for name, instance in pairs(ActiveWidgets[virtualPlate]) do
            if instance and instance.Hide then
                instance:Hide()
            end
        end
        ActiveWidgets[virtualPlate] = nil
    end
end

-- HideIn helper (for timed widget expiration)
local HideInFrames = {}
local HideInWatcher = CreateFrame("Frame")
local watcherActive = false

local function CheckHideInFrames()
    local currentTime = GetTime()
    local remainingFrames = 0

    for frame, expireTime in pairs(HideInFrames) do
        if currentTime >= expireTime then
            frame:Hide()
            HideInFrames[frame] = nil
        else
            remainingFrames = remainingFrames + 1
        end
    end

    if remainingFrames == 0 then
        HideInWatcher:SetScript("OnUpdate", nil)
        watcherActive = false
    end
end

function WidgetCore:HideIn(frame, seconds)
    HideInFrames[frame] = GetTime() + seconds

    if not watcherActive then
        HideInWatcher:SetScript("OnUpdate", CheckHideInFrames)
        watcherActive = true
    end
end

-- Export
ZenPlates.WidgetCore = WidgetCore
