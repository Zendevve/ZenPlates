-- ZenPlates: Cast Bar Module
-- Enhanced cast bar styling and functionality

local _, ZenPlates = ...
ZenPlates.CastBar = {}

local CastBar = ZenPlates.CastBar
local Config = ZenPlates.Config

-- Backdrop for cast bars (brutalist design)
local backdrop = {
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Style a cast bar
function CastBar:StyleCastBar(frame, castBar)
    if not castBar or not ZenPlatesDB.showCastBars then return end

    local cfg = ZenPlatesDB

    -- Set texture and dimensions
    castBar:SetStatusBarTexture(cfg.texture)
    castBar:SetHeight(cfg.castBarHeight or cfg.height)
    castBar:SetWidth(cfg.width)

    -- Create background
    if not castBar.bg then
        castBar.bg = CreateFrame("Frame", nil, castBar)
        castBar.bg:SetPoint("TOPLEFT", castBar, "TOPLEFT", -1, 1)
        castBar.bg:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 1, -1)
        castBar.bg:SetFrameLevel(castBar:GetFrameLevel() - 1)
        castBar.bg:SetBackdrop(backdrop)
        castBar.bg:SetBackdropBorderColor(0, 0, 0, 1)

        castBar.bg.fill = castBar.bg:CreateTexture(nil, "BACKGROUND")
        castBar.bg.fill:SetAllPoints(castBar)
        castBar.bg.fill:SetTexture(cfg.texture)
        castBar.bg.fill:SetVertexColor(0.15, 0.15, 0.15, 0.95) -- Dark brutalist bg
    end

    -- Style spell icon
    local cbRegions = {castBar:GetRegions()}
    for _, region in pairs(cbRegions) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            local tex = region:GetTexture()
            if tex then
                -- Hide nameplate borders and clutter
                if string.find(tex, "Nameplate") or string.find(tex, "Border") then
                    region:SetTexture("")
                    region:SetAlpha(0)
                -- Style spell icon
                elseif not string.find(tex, "Bar") then
                    region:ClearAllPoints()
                    region:SetPoint("RIGHT", castBar, "LEFT", -4, 0)
                    region:SetWidth(cfg.castBarHeight + 6)
                    region:SetHeight(cfg.castBarHeight + 6)
                    region:SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    -- Icon border
                    if not region.border then
                        region.border = castBar:CreateTexture(nil, "OVERLAY")
                        region.border:SetTexture(cfg.texture)
                        region.border:SetPoint("TOPLEFT", region, -1, 1)
                        region.border:SetPoint("BOTTOMRIGHT", region, 1, -1)
                        region.border:SetVertexColor(0, 0, 0, 1)
                    end
                end
            end
        end
    end

    -- Create cast time text (if enabled)
    if cfg.showCastTime and not castBar.time then
        castBar.time = castBar:CreateFontString(nil, "OVERLAY")
        castBar.time:SetFont(cfg.font, cfg.fontSize - 2, cfg.fontOutline)
        castBar.time:SetPoint("RIGHT", castBar, "RIGHT", -2, 0)
        castBar.time:SetTextColor(1, 1, 1)
        castBar.time:SetShadowOffset(1, -1)
    end

    -- TODO: Add interrupt detection and visual feedback
end
