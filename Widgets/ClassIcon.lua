-- ZenPlates: Class Icon Widget
-- Displays class icon for players

local _, ZenPlates = ...
local ClassIconWidget = {}

function ClassIconWidget:Create(virtual)
    local icon = virtual:CreateTexture(nil, "OVERLAY")
    icon:SetSize(20, 20)
    icon:SetPoint("LEFT", virtual.healthBar, "RIGHT", 4, 0)
    return icon
end

function ClassIconWidget:Update(icon, virtual)
    -- Only show for players
    -- In 3.3.5, we need to guess or use cached data
    -- For now, hide unless we have target data

    if virtual.isTarget then
        if UnitIsPlayer("target") then
            local _, class = UnitClass("target")
            if class then
                local coords = CLASS_ICON_TCOORDS[class]
                if coords then
                    icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
                    icon:SetTexCoord(unpack(coords))
                    icon:Show()
                    return
                end
            end
        end
    end

    icon:Hide()
end

ZenPlates.WidgetCore:RegisterWidget("ClassIcon", ClassIconWidget)
