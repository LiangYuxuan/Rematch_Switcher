---@type RematchSwitcher, Rematch, table<string, string>
local RS, Rematch, L = unpack((select(2, ...)))
---@class Leveling
local Leveling = {}

-- Lua functions
local _G = _G
local error, format, ipairs, pairs, tinsert = error, format, ipairs, pairs, tinsert
local table_concat = table.concat

-- WoW API / Variables
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_TooltipInfo_GetHyperlink = C_TooltipInfo.GetHyperlink
local C_TooltipInfo_GetSpellByID = C_TooltipInfo.GetSpellByID
local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local SetCVar = SetCVar
local SetOverrideBinding = SetOverrideBinding
local UnitLevel = UnitLevel

local MenuUtil_CreateContextMenu = MenuUtil.CreateContextMenu

local DISABLE = DISABLE
local ENABLE = ENABLE

local enableMap = {
    -- Player Leveling
    [2023] = { -- Ohn'ahran Plains
        197102, -- Bakhushek
    },
    -- Pet Leveling
    [582] = { -- Lunarfall
        79179, -- Squirt
    },
    [634] = { -- Stormheim
        105455, -- Trapper Jarrun
        98270, -- Robert Craig
    },
    [627] = { -- Dalaran
        97804, -- Tiffany Nelson
        99182, -- Sir Galveston
        107489, -- Amalia
    },
    [659] = { -- Stonedark Grotto
        104553, -- Odrogg
    },
}

local stopMacro = '/stopmacro [petbattle]'
local itemMacro = '/use item:184489'
local castMacroTemplate = '/cast %s'
local targetMacroTemplate = '/target %s'
local selectOptionMacro = '/run C_GossipInfo.SelectOptionByIndex(1)'

local spellName
local maxLevel = GetMaxLevelForPlayerExpansion()
local preferTargetIndex = 0
local useSoftTarget = false

local function IsUsingSoftTarget()
    return useSoftTarget
end

local function SetUsingSoftTarget()
    useSoftTarget = not useSoftTarget

    if Leveling.enabled then
        Leveling:EnableHelper()
    end
end

local function IsSelected(index)
    return preferTargetIndex == index
end

local function SetSelected(index)
    preferTargetIndex = index

    if Leveling.enabled then
        Leveling:EnableHelper()
    end
end

local function GeneratorFunction(_, rootDescription)
    rootDescription:CreateTitle("行为")
    rootDescription:CreateCheckbox("启用软目标", IsUsingSoftTarget, SetUsingSoftTarget)

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("目标")
    rootDescription:CreateRadio("全部", IsSelected, SetSelected, 0)

    local uiMapID = C_Map_GetBestMapForUnit('player')
    local npcIDs = enableMap[uiMapID]
    for index, npcID in ipairs(npcIDs) do
        local npcName = Leveling:GetNPCName(npcID)
        if not npcName then
            error('Failed to fetch name of npc ' .. npcID)
        end

        rootDescription:CreateRadio(npcName, IsSelected, SetSelected, index)
    end
end

local function DisplayButtonOnClick(self, button)
    if button == 'LeftButton' then
        Leveling:Toggle()
    elseif button == 'RightButton' then
        MenuUtil_CreateContextMenu(self, GeneratorFunction)
    end
end

function Leveling:GetNPCName(npcID)
    local npcData = C_TooltipInfo_GetHyperlink('unit:Creature-0-0-0-0-' .. npcID)
    return npcData and npcData.lines and npcData.lines[1] and npcData.lines[1].leftText
end

function Leveling:EnableHelper()
    if not spellName then
        local spellData = C_TooltipInfo_GetSpellByID(125439)
        spellName = spellData and spellData.lines and spellData.lines[1] and spellData.lines[1].leftText or spellName
    end

    if not spellName then
        error('Failed to fetch name of spell 125439')
    end

    local uiMapID = C_Map_GetBestMapForUnit('player')
    local npcIDs = enableMap[uiMapID]
    local targetMacros = {}

    if not useSoftTarget then
        if preferTargetIndex > 0 then
            local npcID = npcIDs[preferTargetIndex]
            local npcName = self:GetNPCName(npcID)
            if not npcName then
                error('Failed to fetch name of npc ' .. npcID)
            end

            tinsert(targetMacros, format(targetMacroTemplate, npcName))
        else
            for _, npcID in ipairs(npcIDs) do
                local npcName = self:GetNPCName(npcID)
                if not npcName then
                    error('Failed to fetch name of npc ' .. npcID)
                end

                tinsert(targetMacros, format(targetMacroTemplate, npcName))
            end
        end
    end

    local macroText = format(
        '%s\n%s\n%s\n%s\n%s',
        stopMacro,
        UnitLevel('player') >= 48 and itemMacro or '',
        format(castMacroTemplate, spellName),
        table_concat(targetMacros, '\n'),
        selectOptionMacro
    )

    self.macroButton:SetAttribute('macrotext', macroText)

    ClearOverrideBindings(self.macroButton)
    SetOverrideBinding(self.macroButton, true, '8', 'CLICK RhythmBoxPLHMacro:LeftButton')
    SetOverrideBinding(self.macroButton, true, '9', 'INTERACTTARGET')
    SetOverrideBinding(self.macroButton, true, '0', 'CLICK tdBattlePetScriptAutoButton:LeftButton')

    if UnitLevel('player') >= 48 then
        SetCVar('autoInteract', '0')
    else
        SetCVar('autoInteract', '1')
    end

    if useSoftTarget then
        SetCVar('SoftTargetInteract', '3')
        SetCVar('SoftTargetInteractArc', '2')
    else
        SetCVar('SoftTargetInteract', '1')
        SetCVar('SoftTargetInteractArc', '0')
    end
end

function Leveling:DisableHelper()
    SetCVar('autoInteract', '0')
    SetCVar('SoftTargetInteract', '1')
    SetCVar('SoftTargetInteractArc', '0')
    ClearOverrideBindings(self.macroButton)
end

function Leveling:Toggle()
    if self.enabled then
        self:DisableHelper()
        self.enabled = nil

        self.displayButton.icon:SetDesaturated(true)
        self.displayButton.text:SetTextColor(1, 0, 0, 1)
        self.displayButton.text:SetText(DISABLE)
    else
        self:EnableHelper()
        self.enabled = true

        self.displayButton.icon:SetDesaturated(false)
        self.displayButton.text:SetTextColor(0, 1, 0, 1)
        self.displayButton.text:SetText(ENABLE)
    end
end

function Leveling:UpdateZone(event)
    if InCombatLockdown() then
        return
    end

    if event == 'PLAYER_ENTERING_WORLD' then
        SetCVar('autoInteract', '0')
        SetCVar('SoftTargetInteract', '1')
        SetCVar('SoftTargetInteractArc', '0')
    end

    local uiMapID = C_Map_GetBestMapForUnit('player')
    if enableMap[uiMapID] then
        preferTargetIndex = 0
        self.displayButton:Show()

        if UnitLevel('player') < maxLevel then
            -- Player Leveling: default to enable
            self:EnableHelper()
            self.enabled = true

            self.displayButton.icon:SetDesaturated(false)
            self.displayButton.text:SetTextColor(0, 1, 0, 1)
            self.displayButton.text:SetText(ENABLE)
        else
            -- Pet Leveling: default to disable
            self:DisableHelper()
            self.enabled = nil

            self.displayButton.icon:SetDesaturated(true)
            self.displayButton.text:SetTextColor(1, 0, 0, 1)
            self.displayButton.text:SetText(DISABLE)
        end
    else
        -- not in enable map
        self:DisableHelper()
        self.enabled = nil

        -- hide display button and reset display
        self.displayButton:Hide()
        self.displayButton.icon:SetDesaturated(true)
        self.displayButton.text:SetTextColor(1, 0, 0, 1)
        self.displayButton.text:SetText(DISABLE)
    end
end

function Leveling:Initialize()
    local macroButton = CreateFrame('Button', 'RhythmBoxPLHMacro', _G.UIParent, 'BackdropTemplate,SecureActionButtonTemplate')
    ---@cast macroButton Frame
    macroButton:EnableMouse(true)
    macroButton:RegisterForClicks('AnyUp', 'AnyDown')
    macroButton:SetAttribute('type', 'macro')
    self.macroButton = macroButton

    ---@class PetLevelHelperDisplayButton: Button
    local display = CreateFrame('Button', nil, _G.UIParent)
    display:ClearAllPoints()
    display:SetPoint('CENTER', -300, -350)
    display:SetSize(64, 64)
    display:SetBackdrop({
        bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
        edgeFile = 'Interface\\ChatFrame\\ChatFrameBackground',
        edgeSize = 1,
    })
    display:SetBackdropColor(0, 0, 0, 1)
    display:SetBackdropBorderColor(0, 0, 0, 1)
    display:SetHighlightTexture('Interface\\ChatFrame\\ChatFrameBackground')
    display:SetPushedTexture('Interface\\ChatFrame\\ChatFrameBackground')

    local hover = display:GetHighlightTexture()
    hover:ClearAllPoints()
    hover:SetPoint('TOPLEFT', display, 1, -1)
    hover:SetPoint('BOTTOMRIGHT', display, -1, 1)
    hover:SetBlendMode('ADD')
    hover:SetVertexColor(1, 1, 1, 0.3)

    local pushed = display:GetPushedTexture()
    pushed:ClearAllPoints()
    pushed:SetPoint('TOPLEFT', display, 1, -1)
    pushed:SetPoint('BOTTOMRIGHT', display, -1, 1)
    pushed:SetBlendMode('ADD')
    pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)

    display:EnableMouse(true)
    display:RegisterForClicks('AnyUp')
    display:SetScript('OnClick', DisplayButtonOnClick)
    self.displayButton = display

    display.icon = display:CreateTexture(nil, 'OVERLAY')
    display.icon:ClearAllPoints()
    display.icon:SetPoint('TOPLEFT', display, 2, -2)
    display.icon:SetPoint('BOTTOMRIGHT', display, -2, 2)
    display.icon:SetTexCoord(.1, .9, .1, .9)
    display.icon:SetTexture(644389)
    display.icon:SetDesaturated(true)

    display.text = display:CreateFontString(nil, 'OVERLAY', 'SystemFont_Shadow_Huge2_Outline')
    display.text:SetTextColor(1, 0, 0, 1)
    display.text:SetPoint('TOP', display, 'BOTTOM', 0, -2)
    display.text:SetJustifyH('CENTER')
    display.text:SetText(DISABLE)

    for _, npcIDs in pairs(enableMap) do
        for _, npcID in ipairs(npcIDs) do
            self:GetNPCName(npcID)
        end
    end

    Rematch.events:Register(Leveling, 'PLAYER_ENTERING_WORLD', Leveling.UpdateZone)
    Rematch.events:Register(Leveling, 'ZONE_CHANGED_NEW_AREA', Leveling.UpdateZone)
    Rematch.events:Register(Leveling, 'PLAYER_REGEN_ENABLED', Leveling.UpdateZone)
end

Rematch.events:Register(Leveling, 'PLAYER_LOGIN', Leveling.Initialize)
