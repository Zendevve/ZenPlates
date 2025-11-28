-- ZenPlates: Update Throttle
-- Performance optimization for plate updates

local _, ZenPlates = ...
local UpdateThrottle = {}

local nextUpdate = 0
local UPDATE_RATE = 0.05  -- 50ms minimum between updates (20 FPS)

-- Main update loop
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    nextUpdate = nextUpdate - elapsed

    if nextUpdate <= 0 then
        nextUpdate = UPDATE_RATE

        -- Update virtual plates
        if ZenPlates.VirtualPlates then
            ZenPlates.VirtualPlates:Update(elapsed)
        end

        -- Update widgets
        if ZenPlates.UpdateWidgets then
            ZenPlates:UpdateWidgets()
        end
    end
end)

-- Force immediate update (for important events)
function UpdateThrottle:ForceUpdate()
    nextUpdate = 0
end

-- Export
ZenPlates.UpdateThrottle = UpdateThrottle
