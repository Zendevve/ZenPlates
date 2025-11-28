local addonName, ns = ...
local ZenPlates = CreateFrame("Frame")
ns.Main = ZenPlates

ZenPlates:RegisterEvent("ADDON_LOADED")
ZenPlates:RegisterEvent("PLAYER_LOGIN")

ZenPlates:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            ns:InitializeDatabase()
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_LOGIN" then
        if ns.EnableNameplates then
            ns:EnableNameplates()
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
