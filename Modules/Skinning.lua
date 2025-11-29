local addonName, ns = ...

function ns:SkinNameplate(frame)
    if frame.isSkinned then return end
    frame.isSkinned = true

    local healthBar, castBar = frame:GetChildren()
    local glow, bossIcon, raidIcon, eliteIcon
    local name, level

    -- 1. Identify Regions
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        local objectType = region:GetObjectType()

        if objectType == "Texture" then
            local texture = region:GetTexture()
            if texture and string.find(texture, "UI%-TargetingFrame%-Flash") then
                glow = region
            elseif texture and string.find(texture, "UI%-RaidIcon") then
                raidIcon = region
            end
        elseif objectType == "FontString" then
            if not name then name = region
            elseif not level then level = region end
        end
    end

    -- 2. Hide Default Blizzard Art
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            local texture = region:GetTexture()
            if not (texture and string.find(texture, "RaidIcon")) then
                region:SetTexture(nil)
                region:SetVertexColor(0, 0, 0, 0)
                if texture and string.find(texture, "UI%-TargetingFrame%-Flash") then
                    glow = region
                end
            end
        end
    end

    -- 3. Skin Health Bar
    healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    healthBar:SetHeight(16) -- Thick bar

    -- Backdrop
    local backdrop = CreateFrame("Frame", nil, healthBar)
    backdrop:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -1, 1)
    backdrop:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 1, -1)
    backdrop:SetFrameLevel(healthBar:GetFrameLevel() - 1)
    backdrop:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    backdrop:SetBackdropColor(0, 0, 0, 0.8)
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)

    -- 4. Skin Cast Bar
    if castBar then
        castBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        castBar:SetHeight(12)
        castBar:SetStatusBarColor(1, 0.8, 0)

        -- Castbar Backdrop
        local cBackdrop = CreateFrame("Frame", nil, castBar)
        cBackdrop:SetPoint("TOPLEFT", castBar, "TOPLEFT", -1, 1)
        cBackdrop:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 1, -1)
        cBackdrop:SetFrameLevel(castBar:GetFrameLevel() - 1)
        cBackdrop:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        cBackdrop:SetBackdropColor(0, 0, 0, 0.8)
        cBackdrop:SetBackdropBorderColor(0, 0, 0, 1)

        -- Fix Castbar Icon
        local cIcon = castBar:GetRegions()
        if cIcon and cIcon:GetObjectType() == "Texture" then
            cIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            -- Create a border for the icon
            local iBorder = CreateFrame("Frame", nil, castBar)
            iBorder:SetPoint("TOPLEFT", cIcon, "TOPLEFT", -1, 1)
            iBorder:SetPoint("BOTTOMRIGHT", cIcon, "BOTTOMRIGHT", 1, -1)
            iBorder:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = 1,
            })
            iBorder:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end

    -- 5. Fix Text Positioning
    -- Name: BELOW the bar (centered)
    if name then
        name:ClearAllPoints()
        name:SetPoint("TOP", healthBar, "BOTTOM", 0, -4) -- Slightly lower padding
        name:SetFont(ns.defaults.font, 10, ns.defaults.fontStyle)
        name:SetShadowOffset(1, -1)
    end

    -- Level: Hide it (Reference doesn't emphasize it)
    if level then
        level:Hide()
    end

    -- 6. Store References
    if not frame.zen then
        frame.zen = CreateFrame("Frame", nil, frame)
        frame.zen:SetAllPoints(frame)
    end
    frame.zen.name = name
    frame.zen.level = level
    frame.zen.healthBar = healthBar
    frame.zen.castBar = castBar
    frame.zen.glowRegion = glow
end
