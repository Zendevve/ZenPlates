local addonName, ns = ...
local Sorting = CreateFrame("Frame")
ns.Sorting = Sorting

local pairs, table = pairs, table

-- Config
local UPDATE_INTERVAL = 0.1
local timeSinceLast = 0

Sorting:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast > UPDATE_INTERVAL then
        ns:SortNameplates()
        timeSinceLast = 0
    end
end)

function ns:SortNameplates()
    local plates = {}
    for frame in pairs(ns.nameplates) do
        if frame:IsShown() then
            table.insert(plates, frame)
        end
    end

    -- Sort by scale (proxy for distance in 3.3.5a default plates)
    -- Larger scale = Closer = Draw on top (Higher FrameLevel)
    table.sort(plates, function(a, b)
        return a:GetScale() < b:GetScale()
    end)

    local baseLevel = 10
    for i, frame in ipairs(plates) do
        local level = baseLevel + i
        if frame:GetFrameLevel() ~= level then
            frame:SetFrameLevel(level)
        end
    end
end
