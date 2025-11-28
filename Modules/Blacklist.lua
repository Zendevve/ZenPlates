local addonName, ns = ...
local Blacklist = CreateFrame("Frame")
ns.Blacklist = Blacklist

local blacklist = {
    ["Army of the Dead Ghoul"] = true,
    ["Snake Wrap"] = true,
    ["Viper"] = true,
    ["Venomous Snake"] = true,
}

function ns:CheckBlacklist(frame)
    if not frame.zen then return end

    local name = frame.zen.name and frame.zen.name:GetText()
    if name and blacklist[name] then
        frame:SetAlpha(0)
        frame:EnableMouse(false)
    else
        -- Only restore if we are sure we hid it via blacklist
        -- This is tricky because other modules might hide it.
        -- For now, we just ensure mouse is enabled if not blacklisted (and not totem)
        if not frame.isTotem then
            frame:EnableMouse(true)
            -- We don't force SetAlpha(1) here because of distance fading/target fading
        end
    end
end
