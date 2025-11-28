local addonName, ns = ...

function ns:InitializeDatabase()
    if not ZenPlatesDB then
        ZenPlatesDB = {}
    end

    for k, v in pairs(ns.defaults) do
        if ZenPlatesDB[k] == nil then
            ZenPlatesDB[k] = v
        end
    end
end
