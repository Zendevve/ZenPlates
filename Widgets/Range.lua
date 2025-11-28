-- ZenPlates: Range Widget
-- Range indicator for healers/ranged

local _, ZenPlates = ...
local RangeWidget = {}

function RangeWidget:Create(virtual)
    -- No visual element, just modifies alpha
    return { plate = virtual }
end

function RangeWidget:Update(widget, virtual)
    -- Only works if we have a unit (target/mouseover) or if we scan nameplates
    -- For now, simple alpha check based on target

    if virtual.isTarget then
        local inRange = IsSpellInRange("Shoot", "target") == 1 -- Hunter check, generic fallback needed
        -- Better: CheckInteractDistance

        if CheckInteractDistance("target", 4) then -- 28 yards
            virtual:SetAlpha(1.0)
        else
            virtual:SetAlpha(0.8)
        end
    end
end

ZenPlates.WidgetCore:RegisterWidget("Range", RangeWidget)
