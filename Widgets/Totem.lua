-- ZenPlates: Totem Icon Widget
-- Displays totem icon for totem nameplates

local _, ZenPlates = ...
local TotemWidget = {}

-- Common totem icons (simplified list)
local TOTEM_ICONS = {
    ["Earthbind Totem"] = "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02",
    ["Grounding Totem"] = "Interface\\Icons\\Spell_Nature_GroundingTotem",
    ["Tremor Totem"] = "Interface\\Icons\\Spell_Nature_TremorTotem",
    ["Cleansing Totem"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["Mana Tide Totem"] = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
}

function TotemWidget:Create(virtual)
    local icon = virtual:CreateTexture(nil, "OVERLAY")
    icon:SetSize(24, 24)
    icon:SetPoint("CENTER", virtual.healthBar, "CENTER", 0, 15)
    return icon
end

function TotemWidget:Update(icon, virtual)
    local name = virtual.nameText and virtual.nameText:GetText()
    if name and TOTEM_ICONS[name] then
        icon:SetTexture(TOTEM_ICONS[name])
        icon:Show()

        -- Hide health bar for totems if desired
        -- virtual.healthBar:SetAlpha(0)
    else
        icon:Hide()
    end
end

ZenPlates.WidgetCore:RegisterWidget("TotemIcon", TotemWidget)
