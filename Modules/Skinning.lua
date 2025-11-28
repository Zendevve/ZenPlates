local addonName, ns = ...

function ns:SkinNameplate(frame)
    if frame.isSkinned then return end
    frame.isSkinned = true

    local healthBar, castBar = frame:GetChildren()

    -- Identify regions by type instead of assuming order
    local glow, bossIcon, raidIcon, eliteIcon
    local name, level

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
            if not name then
                name = region
            elseif not level then
                level = region
            end
        end
    end

    -- Permanently hide ALL default textures (mouseover highlight, threat glow, etc)
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            -- Don't hide raid icons, but hide everything else
            local texture = region:GetTexture()
            if not (texture and string.find(texture, "RaidIcon")) then
                region:SetTexture(nil)
                region:SetVertexColor(0, 0, 0, 0) -- Fully transparent
                -- Store glow reference before hiding it
                if texture and string.find(texture, "UI%-TargetingFrame%-Flash") then
                    glow = region
                end
            end
        end
    end

    -- Brutalist Health Bar
    -- 3.3.5a healthBar is a StatusBar
    healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    -- Let Blizzard handle threat colors naturally

    -- Create a background for the health bar
    local bg = healthBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(healthBar)
    bg:SetTexture(0, 0, 0, 0.8) -- Black background

    -- Create a border (Brutalist = thick, stark)
    local border = CreateFrame("Frame", nil, healthBar)
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0, 0, 0, 1)

    -- Cast Bar
    if castBar then
        castBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        castBar:SetStatusBarColor(1, 0.8, 0) -- Yellow

        local cbg = castBar:CreateTexture(nil, "BACKGROUND")
        cbg:SetAllPoints(castBar)
        cbg:SetTexture(0, 0, 0, 0.8)

        local cborder = CreateFrame("Frame", nil, castBar)
        cborder:SetPoint("TOPLEFT", -1, 1)
        cborder:SetPoint("BOTTOMRIGHT", 1, -1)
        cborder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        cborder:SetBackdropBorderColor(0, 0, 0, 1)
    end

    -- Font Styling
    if name then
        local font, size, outline = name:GetFont()
        if font then
            name:SetFont(font, 10, "OUTLINE")
        end
    end
    if level then
        local font, size, outline = level:GetFont()
        if font then
            level:SetFont(font, 10, "OUTLINE")
        end
    end

    -- Store references for other modules
    if not frame.zen then
        frame.zen = CreateFrame("Frame", nil, frame)
        frame.zen:SetSize(frame:GetWidth(), frame:GetHeight())
        frame.zen:SetPoint("CENTER", frame, "CENTER")
    end
    frame.zen.name = name
    frame.zen.level = level
    frame.zen.glowRegion = glow -- Store for glow detection
end
