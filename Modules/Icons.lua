local addonName, ns = ...
local Icons = CreateFrame("Frame")
ns.Icons = Icons

local classCache = {}
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

-- Listen for mouseover/target to cache class
Icons:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
Icons:RegisterEvent("PLAYER_TARGET_CHANGED")
Icons:SetScript("OnEvent", function(self, event)
    local unit = "mouseover"
    if event == "PLAYER_TARGET_CHANGED" then unit = "target" end

    if UnitExists(unit) and UnitIsPlayer(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if name and class then
            classCache[name] = class
        end
    end
end)

function ns:UpdateIcons()
    for frame in pairs(ns.nameplates) do
        if frame:IsShown() and frame.zen then
            ns:CheckIcon(frame)
        end
    end
end

-- Hook into the main update loop or call from Nameplates.lua
-- For now we'll add a timer here, but ideally we merge loops.
local UPDATE_INTERVAL = 0.2
local timeSinceLast = 0
Icons:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast > UPDATE_INTERVAL then
        ns:UpdateIcons()
        timeSinceLast = 0
    end
end)

function ns:CheckIcon(frame)
    if not frame.zen or not frame.zen.name then return end

    if not frame.zen.icon then
        frame.zen.icon = frame.zen:CreateTexture(nil, "OVERLAY")
        frame.zen.icon:SetSize(20, 20)
        frame.zen.icon:SetPoint("RIGHT", frame.zen, "LEFT", -2, 0)
        frame.zen.icon:Hide()
    end

    -- Get name text from stored reference
    local name = frame.zen.name:GetText()

    if name and classCache[name] then
        local coords = CLASS_ICON_TCOORDS[classCache[name]]
        frame.zen.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
        frame.zen.icon:SetTexCoord(unpack(coords))
        frame.zen.icon:Show()
    else
        frame.zen.icon:Hide()
    end

    ns:CheckArenaParty(frame, name)
end

function ns:CheckArenaParty(frame, name)
    if not name then return end

    if not frame.zen.idText then
        frame.zen.idText = frame.zen:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.zen.idText:SetPoint("LEFT", frame.zen, "RIGHT", 2, 0)
        frame.zen.idText:SetTextColor(1, 1, 1)
    end

    local idText = ""
    local instanceType = select(2, IsInInstance())

    if instanceType == "arena" then
        for i = 1, 5 do
            if UnitName("arena"..i) == name then
                idText = i
                break
            end
        end
    elseif instanceType == "party" or instanceType == "raid" then
        -- Check Party (Friendly)
        for i = 1, 4 do
            if UnitName("party"..i) == name then
                idText = "P"..i
                break
            end
        end
    end

    frame.zen.idText:SetText(idText)
end
