local addonName, ns = ...

local select, pairs, type = select, pairs, type
local WorldFrame = WorldFrame

local numChildren = -1
ns.nameplates = {} -- Exposed to other modules

function ns:EnableNameplates()
    local updater = CreateFrame("Frame")
    updater:SetScript("OnUpdate", function(self, elapsed)
        if WorldFrame:GetNumChildren() ~= numChildren then
            numChildren = WorldFrame:GetNumChildren()
            ns:ScanNameplates(WorldFrame:GetChildren())
        end
    end)
end

function ns:ScanNameplates(...)
    for i = 1, select("#", ...) do
        local frame = select(i, ...)
        if not ns.nameplates[frame] and ns:IsNameplate(frame) then
            ns.nameplates[frame] = true
            ns:StyleNameplate(frame)
        end
    end
end

function ns:IsNameplate(frame)
    -- Check if frame has exactly 2 children (healthbar, castbar)
    if frame:GetNumChildren() ~= 2 then
        return false
    end

    -- Check if it has the threat glow texture
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            local texture = region:GetTexture()
            if texture and string.find(texture, "UI%-TargetingFrame%-Flash") then
                return true
            end
        end
    end

    return false
end

function ns:StyleNameplate(frame)
    if ns.SkinNameplate then
        ns:SkinNameplate(frame)
    end

    -- Hook OnShow to update dynamic elements (Totems, Blacklist, Icons)
    frame:HookScript("OnShow", function(self)
        ns:UpdatePlate(self)
    end)

    -- Initial update
    ns:UpdatePlate(frame)
end

function ns:UpdatePlate(frame)
    if ns.CheckTotem then ns:CheckTotem(frame) end
    if ns.CheckBlacklist then ns:CheckBlacklist(frame) end
    if ns.CheckIcon then ns:CheckIcon(frame) end
    if ns.CheckFriendly then ns:CheckFriendly(frame) end
    if ns.UpdateHealthText then ns:UpdateHealthText(frame) end
    if ns.UpdateThreat then ns:UpdateThreat(frame) end
    if ns.UpdateAuras then ns:UpdateAuras(frame) end
end

