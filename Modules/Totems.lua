local addonName, ns = ...
local Totems = CreateFrame("Frame")
ns.Totems = Totems

-- Simple list of totems to emphasize
local totemList = {
    ["Tremor Totem"] = "Interface\\Icons\\Spell_Nature_TremorTotem",
    ["Grounding Totem"] = "Interface\\Icons\\Spell_Nature_GroundingTotem",
    ["Earthbind Totem"] = "Interface\\Icons\\Spell_Nature_EarthBindTotem",
    ["Cleansing Totem"] = "Interface\\Icons\\Spell_Nature_DiseaseCleansingTotem",
    ["Mana Tide Totem"] = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
}

function ns:CheckTotem(frame)
    if not frame.zen then return end

    local name = frame.zen.name and frame.zen.name:GetText()
    if name and totemList[name] then
        -- It's a totem
        frame.isTotem = true

        -- Hide standard bars
        local healthBar = frame:GetChildren()
        healthBar:SetAlpha(0)
        frame.zen.name:Hide()
        frame.zen.level:Hide()

        -- Show Icon
        if not frame.zen.totemIcon then
            frame.zen.totemIcon = frame.zen:CreateTexture(nil, "OVERLAY")
            frame.zen.totemIcon:SetSize(35, 35)
            frame.zen.totemIcon:SetPoint("CENTER", frame, "CENTER", 0, 10)
        end
        frame.zen.totemIcon:SetTexture(totemList[name])
        frame.zen.totemIcon:Show()

        -- Click-through
        frame:EnableMouse(false)
    else
        if frame.isTotem then
             frame.isTotem = false
             local healthBar = frame:GetChildren()
             healthBar:SetAlpha(1)
             frame.zen.name:Show()
             frame.zen.level:Show()
             if frame.zen.totemIcon then frame.zen.totemIcon:Hide() end
             frame:EnableMouse(true)
        end
    end
end
