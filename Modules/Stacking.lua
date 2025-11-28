local addonName, ns = ...
local Stacking = CreateFrame("Frame")
ns.Stacking = Stacking

local UPDATE_INTERVAL = 0.05 -- Fast update for smooth movement
local timeSinceLast = 0

Stacking:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast > UPDATE_INTERVAL then
        ns:StackNameplates()
        timeSinceLast = 0
    end
end)

function ns:StackNameplates()
    local plates = {}
    for frame in pairs(ns.nameplates) do
        if frame:IsShown() and frame.zen then
            table.insert(plates, frame)
            -- Reset offset for calculation
            -- We don't reset to 0 immediately to avoid jitter,
            -- but we need a base.
            -- For simple stacking, we recalculate from 0 each frame.
            frame.zen.offsetY = 0
        end
    end

    -- Sort by Y position (screen space)
    table.sort(plates, function(a, b)
        local yA = select(2, a:GetCenter()) or 0
        local yB = select(2, b:GetCenter()) or 0
        return yA < yB
    end)

    -- Simple overlap check
    local PLATE_HEIGHT = 25 -- Approximate height of our bars + spacing
    local VERTICAL_SPACING = 2

    for i = 1, #plates do
        local current = plates[i]
        local cx, cy = current:GetCenter()
        if not cx then cx, cy = 0, 0 end

        -- Check against previous plates (which are below 'current' in Y)
        for j = 1, i - 1 do
            local prev = plates[j]
            local px, py = prev:GetCenter()
            if not px then px, py = 0, 0 end

            -- If horizontally overlapping
            if ns:IsHorizontallyOverlapping(current, prev) then
                -- Check vertical overlap
                -- We use the *visual* position of prev (which might have been pushed up)
                -- vs the *base* position of current.

                local prevTop = py + (prev.zen.offsetY or 0) + (PLATE_HEIGHT/2)
                local currentBottom = cy + (current.zen.offsetY or 0) - (PLATE_HEIGHT/2)

                if currentBottom < prevTop + VERTICAL_SPACING then
                    local overlap = (prevTop + VERTICAL_SPACING) - currentBottom
                    -- Push current up
                    current.zen.offsetY = (current.zen.offsetY or 0) + overlap
                end
            end
        end
    end

    -- Apply offsets
    for _, frame in ipairs(plates) do
        frame.zen:ClearAllPoints()
        if frame.zen.offsetY and frame.zen.offsetY ~= 0 then
            frame.zen:SetPoint("CENTER", frame, "CENTER", 0, frame.zen.offsetY)
        else
            frame.zen:SetPoint("CENTER", frame, "CENTER", 0, 0)
        end
    end
end

function ns:IsHorizontallyOverlapping(a, b)
    local xA = select(1, a:GetCenter()) or 0
    local xB = select(1, b:GetCenter()) or 0
    local width = a:GetWidth() * a:GetScale() -- Use actual width

    return math.abs(xA - xB) < width
end
