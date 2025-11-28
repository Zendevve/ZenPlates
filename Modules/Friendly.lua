local addonName, ns = ...
local Friendly = CreateFrame("Frame")
ns.Friendly = Friendly

function ns:CheckFriendly(frame)
    if not frame.zen then return end

    -- Check reaction via health bar color
    local healthBar = frame:GetChildren()
    local r, g, b = healthBar:GetStatusBarColor()

    -- Heuristic for friendly: High Green (NPC) or High Blue (Player)
    -- Note: Exact values vary, checking thresholds is safer.
    local isFriendly = false
    if g > 0.9 and r < 0.2 then isFriendly = true end -- Greenish (Friendly NPC)
    if b > 0.9 and r < 0.2 then isFriendly = true end -- Blueish (Friendly Player)

    if isFriendly then
        -- Barless mode
    end
end
