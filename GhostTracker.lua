local GHOST_NAME = "The Lost"
local DURATION = 20
local ICON_PATH = "Interface\\Icons\\Spell_Shadow_Haunting"
local WOLF_NAME = "Spirit Protector"
local WOLF_DURATION = 30
local WOLF_ICON_PATH = "Interface\\Icons\\Spell_Nature_SpiritWolf"

local LOST_SET_ITEMS = {
    ["Memento of the Lost"] = true,
    ["Remains of the Lost"] = true,
    ["Loop of the Lost"] = true,
    ["Tome of the Lost"] = true,
}
local WOLF_ITEM = "Girdle of the Faded Primals"

local hasGhostSet = false
local hasWolfItem = false

local function ScanEquipment()
    local lostCount = 0
    hasWolfItem = false
    for slot = 1, 18 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local name = string.gsub(link, "|?|c%x+|?|H[^|]+|?|h%[(.-)%]|?|h|?|r", "%1")
            if LOST_SET_ITEMS[name] then lostCount = lostCount + 1 end
            if name == WOLF_ITEM then hasWolfItem = true end
        end
    end
    hasGhostSet = lostCount >= 3
end


-- 1. Main Anchor (The HUD)
local f = CreateFrame("Frame", "GT_Anchor", UIParent)
f:SetWidth(30) f:SetHeight(68)
f:SetPoint("CENTER", 0, 0)
f:SetMovable(true)
f:EnableMouse(false)
f:SetClampedToScreen(true)
f:SetFrameStrata("HIGH")

-- Ghost icon block
f.iconFrame = CreateFrame("Frame", nil, f)
f.iconFrame:SetWidth(30) f.iconFrame:SetHeight(30)
f.iconFrame:SetPoint("TOP", f, "TOP", 0, 0)

f.icon = f.iconFrame:CreateTexture(nil, "ARTWORK")
f.icon:SetAllPoints(f.iconFrame)
f.icon:SetTexture(ICON_PATH)

f.countText = f.iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.countText:SetPoint("CENTER", f.iconFrame, "CENTER", 0, 0)
f.countText:SetTextColor(1, 1, 1, 1)
f.countText:SetText("0")

-- Wolf icon block
f.wolfIconFrame = CreateFrame("Frame", nil, f)
f.wolfIconFrame:SetWidth(30) f.wolfIconFrame:SetHeight(30)
f.wolfIconFrame:SetPoint("TOP", f.iconFrame, "BOTTOM", 0, -8)

f.wolfIcon = f.wolfIconFrame:CreateTexture(nil, "ARTWORK")
f.wolfIcon:SetAllPoints(f.wolfIconFrame)
f.wolfIcon:SetTexture(WOLF_ICON_PATH)

f.wolfCountText = f.wolfIconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.wolfCountText:SetPoint("CENTER", f.wolfIconFrame, "CENTER", 0, 0)
f.wolfCountText:SetTextColor(1, 1, 1, 1)
f.wolfCountText:SetText("0")

-- Dedicated drag button covering both icons
f.drag = CreateFrame("Button", nil, f)
f.drag:SetAllPoints(f)
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

-- Option 2: Show bars
local showBarsText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
showBarsText:SetPoint("TOP", 0 - 4, startY - optionSpacing)
showBarsText:SetText("Show bars:")
showBarsText:SetTextColor(1, 1, 1, 1)

local showBarsCheck = CreateFrame("CheckButton", nil, config, "UICheckButtonTemplate")
showBarsCheck:SetWidth(24) showBarsCheck:SetHeight(24)
showBarsCheck:SetPoint("TOP", checkboxX - 30, startY - optionSpacing + 5)

-- Option 3: Last bar only
local showWolfBarsText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
showWolfBarsText:SetPoint("TOP", 0 - 4, startY - (optionSpacing * 2))
showWolfBarsText:SetText("Last bar only:")
showWolfBarsText:SetTextColor(1, 1, 1, 1)

local showWolfBarsCheck = CreateFrame("CheckButton", nil, config, "UICheckButtonTemplate")
showWolfBarsCheck:SetWidth(24) showWolfBarsCheck:SetHeight(24)
showWolfBarsCheck:SetPoint("TOP", checkboxX - 30, startY - (optionSpacing * 2) + 5)

-- Option 4: Hide out of combat
local combatOnlyText = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
combatOnlyText:SetPoint("TOP", 0 - 4, startY - (optionSpacing * 3))
combatOnlyText:SetText("Hide out of combat:")
combatOnlyText:SetTextColor(1, 1, 1, 1)

local combatOnlyCheck = CreateFrame("CheckButton", nil, config, "UICheckButtonTemplate")
combatOnlyCheck:SetWidth(24) combatOnlyCheck:SetHeight(24)
combatOnlyCheck:SetPoint("TOP", checkboxX - 30, startY - (optionSpacing * 3) + 5)

-- Option 5: Save & Lock
local btnLock = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
btnLock:SetWidth(60) btnLock:SetHeight(25)
btnLock:SetPoint("TOP", checkboxX - 80, startY - (optionSpacing * 4) + 10)
btnLock:SetText("Save")

-- Dynamic sizing
local function UpdateConfigSize()
    local numOptions = 5
    local width = 160
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

showWolfBarsCheck:SetScript("OnClick", function()
    GT_Settings.lastOnly = this:GetChecked()
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
local activeWolves = {}
local rowPool = {}
local wolfRowPool = {}

local function CreateNewRow(id, duration, r, g, b)
    local row = CreateFrame("Frame", "GT_Row"..id, f)
    row:SetWidth(120) row:SetHeight(14)
    row:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 0)

    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetAllPoints(row)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.bar:SetStatusBarColor(r, g, b, 0.8)
    row.bar:SetMinMaxValues(0, duration)

    row.bg = row.bar:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.bar)
    row.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)

    row.text = row.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("CENTER", 0, 0)
    return row
end

f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
f:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
f:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")


f:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if not GT_Settings then GT_Settings = {x=0, y=0, scale=1.0, showBars=true, lastOnly=false, showCombatOnly=false} end
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER", GT_Settings.x, GT_Settings.y)
        f:SetScale(GT_Settings.scale)
        scaleValue:SetText(string.format("%.1f", GT_Settings.scale))
        showBarsCheck:SetChecked(GT_Settings.showBars)
        showWolfBarsCheck:SetChecked(GT_Settings.lastOnly)
        combatOnlyCheck:SetChecked(GT_Settings.showCombatOnly)
        ScanEquipment()
        UpdateFrameVisibility()
    elseif event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_LOGIN" then
        ScanEquipment()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateFrameVisibility()
    elseif arg1 and string.find(arg1, "Summon The Lost") then
        table.insert(activeGhosts, {expiry = GetTime() + DURATION})
    elseif arg1 and string.find(arg1, "Summon Spirit Protector") then
        table.insert(activeWolves, {expiry = GetTime() + WOLF_DURATION})
    elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" or event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH") then
        if arg1 and string.find(arg1, GHOST_NAME) and table.getn(activeGhosts) > 0 then
            table.remove(activeGhosts, 1)
        elseif arg1 and string.find(arg1, WOLF_NAME) and table.getn(activeWolves) > 0 then
            table.remove(activeWolves, 1)
        end
    end
end)

f:SetScript("OnUpdate", function()
    local now = GetTime()
    for i = table.getn(activeGhosts), 1, -1 do
        if now > activeGhosts[i].expiry then table.remove(activeGhosts, i) end
    end
    for i = table.getn(activeWolves), 1, -1 do
        if now > activeWolves[i].expiry then table.remove(activeWolves, i) end
    end

    local ghostCount = table.getn(activeGhosts)
    local wolfCount = table.getn(activeWolves)

    if hasGhostSet then
        f.iconFrame:Show()
        f.countText:SetText(ghostCount)
    else
        f.iconFrame:Hide()
    end
    if hasWolfItem then
        f.wolfIconFrame:Show()
        f.wolfCountText:SetText(wolfCount)
    else
        f.wolfIconFrame:Hide()
    end

    if ghostCount > table.getn(rowPool) then
        for i = table.getn(rowPool) + 1, ghostCount do
            table.insert(rowPool, CreateNewRow(i, DURATION, 0.4, 0.1, 0.9))
        end
    end
    if wolfCount > table.getn(wolfRowPool) then
        for i = table.getn(wolfRowPool) + 1, wolfCount do
            local offset = table.getn(rowPool) + i
            table.insert(wolfRowPool, CreateNewRow("w"..i, WOLF_DURATION, 0.9, 0.5, 0.1))
        end
    end

    local visibleGhostRows = 0
    for i, row in ipairs(rowPool) do
        local show = activeGhosts[i] and hasGhostSet and GT_Settings.showBars and
            (not GT_Settings.lastOnly or i == ghostCount)
        if show then
            local remain = activeGhosts[i].expiry - now
            row.bar:SetValue(remain)
            row.text:SetText(string.format("%.1fs", remain))
            row:ClearAllPoints()
            if GT_Settings.lastOnly then
                row:SetPoint("LEFT", f.iconFrame, "RIGHT", 4, 0)
            else
                visibleGhostRows = visibleGhostRows + 1
                row:SetPoint("TOPLEFT", f.iconFrame, "BOTTOMLEFT", 0, -(visibleGhostRows * 16))
            end
            row:Show()
        else
            row:Hide()
        end
    end

    if hasWolfItem then
        f.wolfIconFrame:ClearAllPoints()
        if GT_Settings.lastOnly then
            f.wolfIconFrame:SetPoint("TOPLEFT", f.iconFrame, "BOTTOMLEFT", 0, -8)
        else
            f.wolfIconFrame:SetPoint("TOPLEFT", f.iconFrame, "BOTTOMLEFT", 0, -(visibleGhostRows * 16) - 24)
        end
    end

    local visibleWolfRows = 0
    for i, row in ipairs(wolfRowPool) do
        local show = activeWolves[i] and hasWolfItem and GT_Settings.showBars and
            (not GT_Settings.lastOnly or i == wolfCount)
        if show then
            local remain = activeWolves[i].expiry - now
            row.bar:SetValue(remain)
            row.text:SetText(string.format("%.1fs", remain))
            row:ClearAllPoints()
            if GT_Settings.lastOnly then
                row:SetPoint("LEFT", f.wolfIconFrame, "RIGHT", 4, 0)
            else
                visibleWolfRows = visibleWolfRows + 1
                row:SetPoint("TOPLEFT", f.wolfIconFrame, "BOTTOMLEFT", 0, -(visibleWolfRows * 16))
            end
            row:Show()
        else
            row:Hide()
        end
    end
end)

SLASH_GHOSTTRACKER1 = "/gt"
SlashCmdList["GHOSTTRACKER"] = ToggleConfig