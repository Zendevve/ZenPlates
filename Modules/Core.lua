-- ZenPlates: Main Core Initialization
-- Connects all systems and initializes the addon

local _, ZenPlates = ...

-- Apply styling to a virtual plate
function ZenPlates:ApplyPlateStyle(virtual)
    local real = virtual.Real
    if not real then return end

    -- Get Blizzard nameplate elements (they are children of virtual now)
    local healthBar, castBar
    for _, child in ipairs({virtual:GetChildren()}) do
        local objType = child:GetObjectType()
        if objType == "StatusBar" then
            if not healthBar then
                healthBar = child
            else
                castBar = child
            end
        end
    end

    if not healthBar then return end

    -- Helper to hide regions
    local function HideRegions(object, regionType)
        if not object then return end
        local regions = {object:GetRegions()}
        for _, region in ipairs(regions) do
            if region:GetObjectType() == "Texture" then
                local tex = region:GetTexture()
                if tex then
                    if tex:find("Border") or tex:find("Glow") or tex:find("Nameplate-Border") or tex:find("Shield") then
                        region:SetTexture("")
                        region:SetAlpha(0)
                    elseif tex:find("Elite") then
                        eliteIcon = region
                    elseif tex:find("RaidTargetingIcons") then
                        raidIcon = region
                    elseif tex:find("Highlight") then
                        region:SetTexture("")
                    end
                end
            elseif region:GetObjectType() == "FontString" then
                if not nameText then nameText = region
                elseif not levelText then levelText = region end
            end
        end
    end

    -- Hide clutter on all frames
    HideRegions(real)
    HideRegions(healthBar)
    HideRegions(castBar)

    -- Store references on virtual
    virtual.healthBar = healthBar
    virtual.castBar = castBar
    virtual.nameText = nameText
    virtual.levelText = levelText
    virtual.raidIcon = raidIcon
    virtual.eliteIcon = eliteIcon

    -- Apply filters
    if ZenPlates.Filters and ZenPlates.Filters.ApplyFilters then
        if ZenPlates.Filters:ApplyFilters(virtual, nameText) then
            return  -- Plate is hidden
        end
    end

    -- Apply module styling
    if ZenPlates.Health and ZenPlates.Health.StyleHealthBar then
        ZenPlates.Health:StyleHealthBar(virtual, healthBar, nameText, levelText, eliteIcon)
    end

    if ZenPlates.CastBar and ZenPlates.CastBar.StyleCastBar then
        ZenPlates.CastBar:StyleCastBar(virtual, castBar)
    end

    if ZenPlates.Combat and ZenPlates.Combat.CreateComboPoints then
        ZenPlates.Combat:CreateComboPoints(virtual, healthBar)
    end

    -- Position raid icon
    if raidIcon then
        raidIcon:ClearAllPoints()
        raidIcon:SetPoint("RIGHT", healthBar, "LEFT", -18, 0)
    end
end

-- Update a single plate
function ZenPlates:UpdatePlate(virtual)
    -- Check if this is the target
    if self.state.hasTarget and virtual.Real then
        local nameText = virtual.nameText
        if nameText then
            local plateName = nameText:GetText()
            local targetName = UnitName("target")

            if plateName == targetName then
                virtual.guid = self.state.targetGUID
                virtual.isTarget = true

                -- Apply target effects
                if self.Target and self.Target.ApplyTargetEffects then
                    self.Target:ApplyTargetEffects(virtual, virtual.healthBar)
                end

                -- Update debuffs
                if self.Debuffs and self.Debuffs.UpdateDebuffs then
                    self.Debuffs:UpdateDebuffs(virtual, "target")
                end

                -- Update combo points
                if self.Combat and self.Combat.UpdateComboPoints then
                    self.Combat:UpdateComboPoints(virtual)
                end

                return
            end
        end
    end

    -- Not the target - remove effects
    virtual.isTarget = false
    if self.Target and self.Target.RemoveTargetEffects then
        self.Target:RemoveTargetEffects(virtual)
    end
end

-- Update all visible plates
function ZenPlates:UpdateAllPlates()
    if not self.VirtualPlates then return end

    local plates = self.VirtualPlates:GetVisiblePlates()
    for _, virtual in pairs(plates) do
        self:UpdatePlate(virtual)
    end
end

-- Update target plate specifically
function ZenPlates:UpdateTargetPlate()
    self:UpdateAllPlates()

    -- Force immediate update
    if self.UpdateThrottle then
        self.UpdateThrottle:ForceUpdate()
    end
end

-- Event callbacks
function ZenPlates:OnCombatStart()
    -- Combat-specific updates
end

function ZenPlates:OnCombatEnd()
    -- Process queued updates
end

function ZenPlates:RefreshAllPlates()
    self:UpdateAllPlates()
end

function ZenPlates:UpdateComboPoints()
    if self.Combat and self.Combat.UpdateAllComboPoints then
        self.Combat:UpdateAllComboPoints()
    end
end

-- Apply settings from database
function ZenPlates:ApplySettings()
    -- Settings will be applied by individual modules
    -- based on ZenPlatesDB values
end

-- Main initialization (called by PLAYER_LOGIN)
function ZenPlates:Initialize()
    -- Config was already initialized by Config module

    -- Register combo points event if needed
    if self.Combat then
        self.Combat:RegisterEvents()
    end

    -- Start the update loop
    print("|cff00ff00ZenPlates v" .. self.version .. "|r Plug-and-Play mode active!")

    -- Slash command
    SLASH_ZENPLATES1 = "/zenplates"
    SlashCmdList["ZENPLATES"] = function(msg)
        if msg == "reset" then
            if ZenPlates.Config then
                ZenPlates.Config:ResetToDefaults()
            end
        else
            InterfaceOptionsFrame_OpenToCategory("ZenPlates")
        end
    end
end

-- Hook into EventHandler callbacks
ZenPlates.EventHandler:SetScript("OnEvent", function(self, event, ...)
    -- Call original handler
    if self[event] then
        self[event](self, event, ...)
    end

    -- Additional logic for PLAYER_LOGIN
    if event == "PLAYER_LOGIN" then
        ZenPlates:Initialize()
    end
end)
