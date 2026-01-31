local GHOST_NAME = "The Lost"
local DURATION = 20
local ICON_PATH = "Interface\\Icons\\Spell_Shadow_Haunting"


-- 1. Main Anchor (The HUD)
local f = CreateFrame("Frame", "GT_Anchor", UIParent)
f:SetWidth(40) f:SetHeight(40)
f:SetPoint("CENTER", 0, 0)
f:SetMovable(true)
f:EnableMouse(false)
f:SetClampedToScreen(true)
f:SetFrameStrata("HIGH")

f.icon = f:CreateTexture(nil, "ARTWORK")
f.icon:SetWidth(30) f.icon:SetHeight(30)
f.icon:SetPoint("CENTER", f, "CENTER", 0, 0)
f.icon:SetTexture(ICON_PATH)

f.countText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.countText:SetPoint("LEFT", f.icon, "RIGHT", 8, 0)
f.countText:SetText("0")

-- Dedicated drag button
f.drag = CreateFrame("Button", nil, f)
f.drag:SetAllPoints(f.icon)
f.drag:SetFrameLevel(f:GetFrameLevel() + 10)
f.drag:SetNormalTexture("") 
f.drag:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
f.drag:Hide()

f.drag:RegisterForDrag("LeftButton")
f.drag:SetScript("OnDragStart", function() f:StartMoving() end)
f.drag:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

-- 2. Configuration Panel
local config = CreateFrame("Frame", "GT_Config", UIParent)
config:SetPoint("CENTER", 0, 150)
config:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
config:SetBackdropColor(0, 0, 0, 0.9)
config:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
config:EnableMouse(true) config:SetMovable(true)
config:RegisterForDrag("LeftButton")
config:SetScript("OnDragStart", function() this:StartMoving() end)
config:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
config:Hide()

-- Functions --
local function UpdateFrameVisibility()
    if not GT_Settings then return end
    if config:IsShown() then
        f:Show()
    elseif GT_Settings.showCombatOnly then
        if UnitAffectingCombat("player") then
            f:Show()
        else
            f:Hide()
        end
    else
        f:Show()
    end
end

local title = config:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -12)
title:SetText("GhostTracker Settings")
title:SetTextColor(1, 1, 1, 1)

-- Dynamic options layout
local optionSpacing = 40
local startY = -50
local checkboxX = 80

-- Option 1: Scale
local scaleText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
scaleText:SetPoint("TOP", 0 - 30, startY)
scaleText:SetText("Scale")
scaleText:SetTextColor(1, 1, 1, 1)

local scaleValue = config:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scaleValue:SetPoint("TOP", checkboxX - 30 - 30, startY)
scaleValue:SetTextColor(1, 1, 1, 1)

local btnMinus = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
btnMinus:SetWidth(20) btnMinus:SetHeight(20)
btnMinus:SetPoint("TOP", checkboxX - 50 - 30, startY + 5)
btnMinus:SetText("-")

local btnPlus = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
btnPlus:SetWidth(20) btnPlus:SetHeight(20)
btnPlus:SetPoint("TOP", checkboxX - 10 - 30, startY + 5)
btnPlus:SetText("+")

-- Option 2: Show Progress Bars
local showBarsText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
showBarsText:SetPoint("TOP", 0 - 4, startY - optionSpacing)
showBarsText:SetText("Show ghost timers:")
showBarsText:SetTextColor(1, 1, 1, 1)

local showBarsCheck = CreateFrame("CheckButton", nil, config, "UICheckButtonTemplate")
showBarsCheck:SetWidth(24) showBarsCheck:SetHeight(24)
showBarsCheck:SetPoint("TOP", checkboxX - 30, startY - optionSpacing + 5)

-- Option 3: Hide out of combat
local combatOnlyText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
combatOnlyText:SetPoint("TOP", 0 - 4, startY - (optionSpacing * 2))
combatOnlyText:SetText("Hide out of combat:")
combatOnlyText:SetTextColor(1, 1, 1, 1)

local combatOnlyCheck = CreateFrame("CheckButton", nil, config, "UICheckButtonTemplate")
combatOnlyCheck:SetWidth(24) combatOnlyCheck:SetHeight(24)
combatOnlyCheck:SetPoint("TOP", checkboxX - 30, startY - (optionSpacing * 2) + 5)

-- Option 4: Save & Lock
-- local lockText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
-- lockText:SetPoint("TOP", 0, startY - (optionSpacing * 3))
-- lockText:SetText("Save & Lock Position")
-- lockText:SetTextColor(1, 1, 1, 1)

local btnLock = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
btnLock:SetWidth(60) btnLock:SetHeight(25)
btnLock:SetPoint("TOP", checkboxX - 80, startY - (optionSpacing * 3) + 10)
btnLock:SetText("Save")

-- Dynamic sizing
local function UpdateConfigSize()
    local numOptions = 4
    local width = 150
    local height = 40 + (numOptions * optionSpacing)
    config:SetWidth(width)
    config:SetHeight(height)
end

UpdateConfigSize()

-- 3. Minimap Button
local mm = CreateFrame("Button", "GT_MinimapButton", Minimap)
mm:SetWidth(31) mm:SetHeight(31)
mm:SetFrameStrata("LOW")
mm:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

mm.tex = mm:CreateTexture(nil, "BACKGROUND")
mm.tex:SetTexture(ICON_PATH)
mm.tex:SetWidth(20) mm.tex:SetHeight(20)
mm.tex:SetPoint("CENTER", 0, 0)

mm.border = mm:CreateTexture(nil, "OVERLAY")
mm.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
mm.border:SetWidth(52) mm.border:SetHeight(52)
mm.border:SetPoint("TOPLEFT", 0, 0)

mm:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("Ghost Tracker")
    GameTooltip:Show()
end)
mm:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- 4. Toggle & Scale Logic
local function ToggleConfig()
    if config:IsShown() then
        config:Hide()
        f.drag:Hide()
        UpdateFrameVisibility()
    else
        config:Show()
        f.drag:Show()
        f:Show()
    end
end

mm:SetScript("OnClick", ToggleConfig)

local function UpdateScale(delta)
    if not GT_Settings then GT_Settings = {x=0, y=0, scale=1.0, showBars=true} end
    GT_Settings.scale = GT_Settings.scale + delta
    if GT_Settings.scale < 0.5 then GT_Settings.scale = 0.5 end
    if GT_Settings.scale > 2.5 then GT_Settings.scale = 2.5 end
    f:SetScale(GT_Settings.scale)
    scaleValue:SetText(string.format("%.1f", GT_Settings.scale))
end

btnPlus:SetScript("OnClick", function() UpdateScale(0.1) end)
btnMinus:SetScript("OnClick", function() UpdateScale(-0.1) end)

showBarsCheck:SetScript("OnClick", function()
    GT_Settings.showBars = this:GetChecked()
end)


combatOnlyCheck:SetScript("OnClick", function()
    GT_Settings.showCombatOnly = this:GetChecked()
    UpdateFrameVisibility()
end)

btnLock:SetScript("OnClick", function() 
    local _, _, _, x, y = f:GetPoint()
    GT_Settings.x, GT_Settings.y = x, y
    ToggleConfig()
end)

-- 5. Ghost Tracking Logic
local activeGhosts = {}
local rowPool = {}

local function CreateNewRow(id)
    local row = CreateFrame("Frame", "GT_Row"..id, f)
    row:SetWidth(120) row:SetHeight(14)
    row:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, - (id * 16))
    
    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetAllPoints(row)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.bar:SetStatusBarColor(0.4, 0.1, 0.9, 0.8)
    row.bar:SetMinMaxValues(0, DURATION)
    
    -- Add background
    row.bg = row.bar:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.bar)
    row.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    
    row.text = row.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("CENTER", 0, 0)
    return row
end

f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
f:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
f:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")


f:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if not GT_Settings then GT_Settings = {x=0, y=0, scale=1.0, showBars=true, showCombatOnly=false} end
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER", GT_Settings.x, GT_Settings.y)
        f:SetScale(GT_Settings.scale)
        scaleValue:SetText(string.format("%.1f", GT_Settings.scale))
        showBarsCheck:SetChecked(GT_Settings.showBars)
        combatOnlyCheck:SetChecked(GT_Settings.showCombatOnly)
        UpdateFrameVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateFrameVisibility()
    elseif arg1 and string.find(arg1, "Summon The Lost") then
        table.insert(activeGhosts, {expiry = GetTime() + DURATION})
    elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" or event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH") then
        if arg1 and string.find(arg1, GHOST_NAME) and table.getn(activeGhosts) > 0 then 
            table.remove(activeGhosts, 1) 
        end
    end
end)

f:SetScript("OnUpdate", function()
    local now = GetTime()
    for i = table.getn(activeGhosts), 1, -1 do
        if now > activeGhosts[i].expiry then table.remove(activeGhosts, i) end
    end
    f.countText:SetText("x" .. table.getn(activeGhosts))
    if table.getn(activeGhosts) > table.getn(rowPool) then
        for i = table.getn(rowPool) + 1, table.getn(activeGhosts) do
            table.insert(rowPool, CreateNewRow(i))
        end
    end
    for i, row in ipairs(rowPool) do
        if activeGhosts[i] and GT_Settings.showBars then
            local remain = activeGhosts[i].expiry - now
            row.bar:SetValue(remain)
            row.text:SetText(string.format("%.1fs", remain))
            row:Show()
        else 
            row:Hide() 
        end
    end
end)

SLASH_GHOSTTRACKER1 = "/gt"
SlashCmdList["GHOSTTRACKER"] = ToggleConfig