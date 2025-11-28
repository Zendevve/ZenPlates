-- ZenPlates: Core Module
-- Main initialization and nameplate scanning system

local addonName, ZenPlates = ...
_G.ZenPlates = ZenPlates

ZenPlates.Core = {}
local Core = ZenPlates.Core

-- Frame tracking
local numChildren = -1
local WorldFrame = WorldFrame
local trackedFrames = {}
Core.targetGUID = nil

-- Main skinning function - applies all modules to a nameplate
local function SkinPlate(frame)
    if not frame or frame.isSkinned then return end

    local healthBar, castBar = frame:GetChildren()
    if not healthBar or not castBar then return end

    -- Get nameplate regions
    local regions = {frame:GetRegions()}
    local nameText, levelText, raidIcon, eliteIcon

    for _, region in pairs(regions) do
        if region.GetObjectType then
            local objType = region:GetObjectType()
            if objType == "Texture" then
                local tex = region:GetTexture()
                if tex then
                    -- Detect elite dragon
                    if string.find(tex, "Elite") then eliteIcon = region end

                    -- Hide default clutter
                    if string.find(tex, "Border") or string.find(tex, "Flash") or
                       string.find(tex, "Glow") or string.find(tex, "Elite") or
                       string.find(tex, "Highlight") then
                        region:SetTexture("")
                        region:SetAlpha(0)
                    elseif string.find(tex, "RaidTargetingIcons") then
                        raidIcon = region
                    end
                end
            elseif objType == "FontString" then
                if not nameText then
                    nameText = region
                else
                    levelText = region
                end
            end
        end
    end

    -- Apply unit filters first
    if ZenPlates.Filters:ApplyFilters(frame, nameText) then
        return -- Frame is hidden, don't skin it
    end

    -- Apply all module styling
    ZenPlates.Health:StyleHealthBar(frame, healthBar, nameText, levelText, eliteIcon)
    ZenPlates.CastBar:StyleCastBar(frame, castBar)
    ZenPlates.Combat:CreateComboPoints(frame, healthBar)

    -- Position raid icon
    if raidIcon then
        raidIcon:ClearAllPoints()
        raidIcon:SetPoint("RIGHT", healthBar, "LEFT", -18, 0)
    end

    -- Mark as skinned
    frame.isSkinned = true
    frame.healthBar = healthBar
    frame.castBar = castBar
    frame.nameText = nameText
    frame.guid = nil -- Will be set when we can identify it

    -- Store frame for tracking
    trackedFrames[frame] = true

    -- OnShow handler
    frame:SetScript("OnShow", function(self)
        -- Don't resize - WoW handles that
        -- Just update if this is the target
        if UnitExists("target") and self.guid == Core.targetGUID then
            ZenPlates.Debuffs:UpdateDebuffs(self, "target")
            ZenPlates.Combat:UpdateComboPoints(self)
        end
    end)
end

-- Scanner loop - detects new nameplates
local function OnUpdate(self, elapsed)
    local count = WorldFrame:GetNumChildren()
    if count ~= numChildren then
        numChildren = count

        for i = 1, select("#", WorldFrame:GetChildren()) do
            local frame = select(i, WorldFrame:GetChildren())
            if frame and not frame.isSkinned and frame:GetName() == nil then
                local regions = {frame:GetRegions()}
                if regions and regions[1] and regions[1].GetObjectType and
                   regions[1]:GetObjectType() == "Texture" then
                    local tex = regions[1]:GetTexture()
                    if tex and string.find(tex, "Flash") then
                        SkinPlate(frame)
                    end
                end
            end
        end
    end
end

-- Update target nameplate (called on target change)
function Core:UpdateTargetNameplate()
    -- Get target GUID
    if UnitExists("target") then
        Core.targetGUID = UnitGUID("target")
    else
        Core.targetGUID = nil
    end

    -- Remove effects from all frames first
    for frame in pairs(trackedFrames) do
        if frame.guid ~= Core.targetGUID then
            ZenPlates.Target:RemoveTargetEffects(frame)
        end
    end

    -- Find and mark the target frame
    -- Best effort: check mouseover first (most reliable when targeting)
    if UnitExists("mouseover") and UnitGUID("mouseover") == Core.targetGUID then
        -- Try to find the frame by name matching
        local mouseoverName = UnitName("mouseover")
        for frame in pairs(trackedFrames) do
            if frame.nameText and frame.nameText:GetText() == mouseoverName then
                frame.guid = Core.targetGUID
                ZenPlates.Target:ApplyTargetEffects(frame, frame.healthBar)
                ZenPlates.Debuffs:UpdateDebuffs(frame, "target")
                ZenPlates.Combat:UpdateComboPoints(frame)
                return
            end
        end
    end

    -- Fallback: use name matching with target
    if UnitExists("target") then
        local targetName = UnitName("target")
        for frame in pairs(trackedFrames) do
            if frame:IsShown() and frame.nameText and frame.nameText:GetText() == targetName then
                frame.guid = Core.targetGUID
                ZenPlates.Target:ApplyTargetEffects(frame, frame.healthBar)
                ZenPlates.Debuffs:UpdateDebuffs(frame, "target")
                ZenPlates.Combat:UpdateComboPoints(frame)
                break
            end
        end
    end
end

-- Initialize addon
function Core:Initialize()
    print("|cff00ff00ZenPlates|r v2.0 loaded. Type |cffFFFF00/zenplates|r to configure.")

    -- Initialize config
    ZenPlates.Config:Initialize()
    -- ZenPlates.Options:CreatePanel()  -- Disabled: API incompatible with 3.3.5a


    -- Register combat events
    ZenPlates.Combat:RegisterEvents()

    -- Create scanner frame
    local scanner = CreateFrame("Frame")
    scanner:SetScript("OnUpdate", OnUpdate)

    -- Register target change event
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT" then
            Core:UpdateTargetNameplate()
        end
    end)

    -- Periodic cleanup for debuff cache
    local cleanupTimer = 0
    local cleanupFrame = CreateFrame("Frame")
    cleanupFrame:SetScript("OnUpdate", function(self, elapsed)
        cleanupTimer = cleanupTimer + elapsed
        if cleanupTimer >= 10 then -- Clean every 10 seconds
            ZenPlates.Debuffs:CleanCache()
            cleanupTimer = 0
        end
    end)

    -- Slash command
    SLASH_ZENPLATES1 = "/zenplates"
    SlashCmdList["ZENPLATES"] = function(msg)
        if msg == "reset" then
            ZenPlates.Config:ResetToDefaults()
        else
            InterfaceOptionsFrame_OpenToCategory("ZenPlates")
        end
    end
end

-- Start the addon
Core:Initialize()
