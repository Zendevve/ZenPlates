-- ZenPlates: Virtual Plate System
-- Non-destructive overlay on Blizzard nameplates

local _, ZenPlates = ...
local VirtualPlates = {}

-- Storage
local PlatesVisible = {}  -- Active plates: [realPlate] = virtualPlate
local PlateLevels = 3      -- Frame level difference to prevent overlap
local SortOrder, Depths = {}, {}

-- Create a virtual overlay for a nameplate
local function CreateVirtualPlate(realPlate)
    local virtual = CreateFrame("Frame", nil, realPlate)
    virtual:SetPoint("TOP")
    virtual:SetSize(128, 45)  -- Standard nameplate size
    virtual:SetFrameStrata("BACKGROUND")
    virtual:SetFrameLevel(1)

    -- Cross-reference
    realPlate.Virtual = virtual
    virtual.Real = realPlate

    -- Reparent Blizzard children to virtual
    for _, child in ipairs({realPlate:GetChildren()}) do
        if child ~= virtual then
            local offset = child:GetFrameLevel() - realPlate:GetFrameLevel()
            child:SetParent(virtual)
            child:SetFrameLevel(virtual:GetFrameLevel() + offset)
        end
    end

    -- Reparent Blizzard regions to virtual
    for _, region in ipairs({realPlate:GetRegions()}) do
        region:SetParent(virtual)
    end

    return virtual
end

-- Show handler - plate became visible
local function OnPlateShow(realPlate)
    local virtual = realPlate.Virtual
    PlatesVisible[realPlate] = virtual

    -- Apply all widgets and styling
    if ZenPlates.ApplyPlateStyle then
        ZenPlates:ApplyPlateStyle(virtual)
    end

    -- Update immediately
    if ZenPlates.UpdatePlate then
        ZenPlates:UpdatePlate(virtual)
    end
end

-- Hide handler - plate became invisible
local function OnPlateHide(realPlate)
    PlatesVisible[realPlate] = nil

    -- Clear cached data
    if realPlate.Virtual then
        realPlate.Virtual.guid = nil
        realPlate.Virtual.unit = nil
    end
end

-- Update all visible plates (called on timer)
local function UpdateVisiblePlates()
    if not next(PlatesVisible) then return end

    wipe(SortOrder)
    wipe(Depths)

    -- Gather plates and their depths
    for realPlate, virtual in pairs(PlatesVisible) do
        local depth = virtual:GetEffectiveDepth()
        if depth > 0 then
            SortOrder[#SortOrder + 1] = realPlate

            -- Target always on top (depth = -1)
            if virtual.isTarget then
                Depths[realPlate] = -1
            else
                Depths[realPlate] = depth
            end
        end
    end

    -- Sort by depth (further = higher frame level to appear on top)
    if #SortOrder > 0 then
        table.sort(SortOrder, function(a, b)
            return Depths[a] > Depths[b]
        end)

        -- Apply frame levels
        for index, realPlate in ipairs(SortOrder) do
            local virtual = PlatesVisible[realPlate]
            virtual:SetFrameLevel(index * PlateLevels)

            -- Update health bar frame level too
            if virtual.healthBar then
                virtual.healthBar:SetFrameLevel(index * PlateLevels)
            end
        end
    end
end

-- Scan for new nameplates
local numChildren = -1
local function ScanForPlates()
    local count = WorldFrame:GetNumChildren()
    if count ~= numChildren then
        numChildren = count

        for i = 1, count do
            local frame = select(i, WorldFrame:GetChildren())

            -- Identify nameplates (unnamed frames with specific texture)
            if frame and not frame.Virtual and not frame:GetName() then
                local region = select(1, frame:GetRegions())
                if region and region:GetObjectType() == "Texture" then
                    local texture = region:GetTexture()
                    if texture and texture:find("NamePlate") then
                        -- Found a nameplate!
                        local virtual = CreateVirtualPlate(frame)

                        -- Set up show/hide handlers
                        frame:SetScript("OnShow", function(self)
                            OnPlateShow(self)
                        end)

                        frame:SetScript("OnHide", function(self)
                            OnPlateHide(self)
                        end)

                        -- If already visible, trigger show
                        if frame:IsShown() then
                            OnPlateShow(frame)
                        end
                    end
                end
            end
        end
    end
end

-- Main update loop (throttled by Core)
function VirtualPlates:Update(elapsed)
    ScanForPlates()
    UpdateVisiblePlates()
end

-- Get virtual plate from real plate
function VirtualPlates:GetVirtualPlate(realPlate)
    return realPlate and realPlate.Virtual
end

-- Get all visible virtual plates
function VirtualPlates:GetVisiblePlates()
    return PlatesVisible
end

-- Export
ZenPlates.VirtualPlates = VirtualPlates
