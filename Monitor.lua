---@type RematchSwitcher, Rematch, table<string, string>
local RS, Rematch, L = unpack((select(2, ...)))
---@class Monitor
---@field data MonitorData
---@field frame Frame
---@field slotFrames SlotFrame[]
local Monitor = {}

-- Lua functions
local _G = _G
local ceil, floor, format, ipairs, min, sort = ceil, floor, format, ipairs, min, sort
local strmatch, tinsert, tonumber, tremove = strmatch, tinsert, tonumber, tremove

-- WoW API / Variables
local C_Item_GetItemCount = C_Item.GetItemCount
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local C_UnitAuras_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitLevel = UnitLevel
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax

local CopyTable = CopyTable

local GRAY_FONT_COLOR = GRAY_FONT_COLOR
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local READY = READY
local UNKNOWN = UNKNOWN

---@class MonitorData
---@field playerLevel number
---@field playerXP number
---@field playerXPMax number
---@field isInBattle boolean
---@field enterBattleTime number?
---@field leaveBattleTime number?
---@field gainExperienceMultiplier number
---@field gainExperienceLastTime number?
---@field gainExperienceTimes number[]
---@field gainExperienceTimeMedian number?
---@field gainExperienceValue number?
---@field predictLevelUpCount number?
---@field predictMaxLevelCount number?

---AUTO_GENERATED LEADING ExperienceData
local experienceData = {
    { battleXP = 170, totalXP = 250 },
    { battleXP = 240, totalXP = 655 },
    { battleXP = 310, totalXP = 1245 },
    { battleXP = 370, totalXP = 2025 },
    { battleXP = 440, totalXP = 2995 },
    { battleXP = 500, totalXP = 4155 },
    { battleXP = 575, totalXP = 5505 },
    { battleXP = 650, totalXP = 7040 },
    { battleXP = 700, totalXP = 8770 },
    { battleXP = 775, totalXP = 10590 },
    { battleXP = 850, totalXP = 11685 },
    { battleXP = 900, totalXP = 12795 },
    { battleXP = 975, totalXP = 13920 },
    { battleXP = 1050, totalXP = 15055 },
    { battleXP = 1100, totalXP = 16210 },
    { battleXP = 1200, totalXP = 17380 },
    { battleXP = 1250, totalXP = 18560 },
    { battleXP = 1300, totalXP = 19755 },
    { battleXP = 1400, totalXP = 20970 },
    { battleXP = 1450, totalXP = 22195 },
    { battleXP = 1500, totalXP = 23435 },
    { battleXP = 1600, totalXP = 24690 },
    { battleXP = 1650, totalXP = 25960 },
    { battleXP = 1700, totalXP = 27245 },
    { battleXP = 1800, totalXP = 28545 },
    { battleXP = 1850, totalXP = 29860 },
    { battleXP = 1950, totalXP = 31190 },
    { battleXP = 2000, totalXP = 32535 },
    { battleXP = 2050, totalXP = 33890 },
    { battleXP = 2150, totalXP = 32075 },
    { battleXP = 2200, totalXP = 32700 },
    { battleXP = 2250, totalXP = 33295 },
    { battleXP = 2350, totalXP = 33865 },
    { battleXP = 2400, totalXP = 34410 },
    { battleXP = 2450, totalXP = 34925 },
    { battleXP = 2550, totalXP = 35415 },
    { battleXP = 2600, totalXP = 35875 },
    { battleXP = 2650, totalXP = 36310 },
    { battleXP = 2750, totalXP = 36720 },
    { battleXP = 2800, totalXP = 37100 },
    { battleXP = 2850, totalXP = 37450 },
    { battleXP = 2950, totalXP = 37780 },
    { battleXP = 3000, totalXP = 38075 },
    { battleXP = 3050, totalXP = 38350 },
    { battleXP = 3150, totalXP = 38595 },
    { battleXP = 3200, totalXP = 38810 },
    { battleXP = 3300, totalXP = 39000 },
    { battleXP = 3350, totalXP = 39165 },
    { battleXP = 3400, totalXP = 39300 },
    { battleXP = 3500, totalXP = 40435 },
    { battleXP = 3550, totalXP = 41590 },
    { battleXP = 3600, totalXP = 42750 },
    { battleXP = 3700, totalXP = 43930 },
    { battleXP = 3750, totalXP = 45120 },
    { battleXP = 3800, totalXP = 46325 },
    { battleXP = 3900, totalXP = 47545 },
    { battleXP = 3950, totalXP = 48775 },
    { battleXP = 4000, totalXP = 50020 },
    { battleXP = 4100, totalXP = 51280 },
    { battleXP = 4150, totalXP = 52555 },
    { battleXP = 4200, totalXP = 53840 },
    { battleXP = 4300, totalXP = 55140 },
    { battleXP = 4350, totalXP = 56455 },
    { battleXP = 4400, totalXP = 57780 },
    { battleXP = 4500, totalXP = 59120 },
    { battleXP = 4550, totalXP = 60475 },
    { battleXP = 4650, totalXP = 61845 },
    { battleXP = 4700, totalXP = 63225 },
    { battleXP = 4750, totalXP = 64620 },
    { battleXP = 4850, totalXP = 58645 },
    { battleXP = 4900, totalXP = 60335 },
    { battleXP = 4950, totalXP = 62045 },
    { battleXP = 5050, totalXP = 63780 },
    { battleXP = 5100, totalXP = 65540 },
    { battleXP = 5150, totalXP = 67325 },
    { battleXP = 5250, totalXP = 69130 },
    { battleXP = 5300, totalXP = 70965 },
    { battleXP = 5350, totalXP = 72820 },
    { battleXP = 5900, totalXP = 74700 },
    { battleXP = 5950, totalXP = 403725 },
    { battleXP = 6000, totalXP = 423390 },
    { battleXP = 6100, totalXP = 443395 },
    { battleXP = 6150, totalXP = 463740 },
    { battleXP = 6200, totalXP = 484430 },
    { battleXP = 6300, totalXP = 505455 },
    { battleXP = 6350, totalXP = 526825 },
    { battleXP = 6450, totalXP = 548535 },
    { battleXP = 6500, totalXP = 570590 },
    { battleXP = 6850, totalXP = 592980 },
}
---AUTO_GENERATED TAILING ExperienceData

---@type { name: string, onUpdate: boolean?, hideMaxLevel: boolean, updateFunc: fun(): string }[]
local displaySlots = {
    {
        name = "战斗时间",
        onUpdate = true,
        updateFunc = function()
            if Monitor.data.isInBattle and Monitor.data.enterBattleTime then
                return format('%d', GetTime() - Monitor.data.enterBattleTime)
            elseif not Monitor.data.isInBattle and Monitor.data.enterBattleTime and Monitor.data.leaveBattleTime then
                return format('%d', Monitor.data.leaveBattleTime - Monitor.data.enterBattleTime)
            else
                return UNKNOWN
            end
        end,
    },
    {
        name = "经验加成",
        updateFunc = function()
            local warModeText = (C_UnitAuras_GetPlayerAuraBySpellID(282559) and GREEN_FONT_COLOR or GRAY_FONT_COLOR):WrapTextInColorCode("战争模式")
            local safariHatText = (C_UnitAuras_GetPlayerAuraBySpellID(158486) and GREEN_FONT_COLOR or GRAY_FONT_COLOR):WrapTextInColorCode("狩猎帽")
            return format('%s %s', warModeText, safariHatText)
        end,
    },
    {
        name = "治疗宠物",
        onUpdate = true,
        updateFunc = function()
            local cooldownInfo = C_Spell_GetSpellCooldown(125439)
            if cooldownInfo and cooldownInfo.startTime > 0 and cooldownInfo.duration > 0 then
                local remaining = cooldownInfo.startTime + cooldownInfo.duration - GetTime()
                return format('(|T133675:12|t %d) %02d:%02d', C_Item_GetItemCount(86143), floor(remaining / 60), remaining % 60)
            else
                return format('(|T133675:12|t %d) %s', C_Item_GetItemCount(86143), READY)
            end
        end,
    },
    {
        name = "升级队列",
        updateFunc = function()
            return format('%d', #Rematch.settings.LevelingQueue)
        end,
    },
    {
        name = "玩家等级",
        hideMaxLevel = true,
        updateFunc = function()
            return format('%d (%.2f%%)', Monitor.data.playerLevel, Monitor.data.playerXP / Monitor.data.playerXPMax * 100)
        end,
    },
    {
        name = "经验获取",
        hideMaxLevel = true,
        updateFunc = function()
            if not Monitor.data.gainExperienceValue then
                return UNKNOWN
            end

            return format('%d (%.2fx)', Monitor.data.gainExperienceValue, Monitor.data.gainExperienceMultiplier)
        end,
    },
    {
        name = "经验间隔",
        hideMaxLevel = true,
        updateFunc = function()
            return Monitor.data.gainExperienceTimeMedian and format('%d', Monitor.data.gainExperienceTimeMedian) or UNKNOWN
        end,
    },
    {
        name = "升级时间",
        onUpdate = true,
        hideMaxLevel = true,
        updateFunc = function()
            if not Monitor.data.predictLevelUpCount or not Monitor.data.gainExperienceTimeMedian then
                return UNKNOWN
            end

            local seconds = Monitor.data.gainExperienceTimeMedian * Monitor.data.predictLevelUpCount
                - min(GetTime() - Monitor.data.gainExperienceLastTime, Monitor.data.gainExperienceTimeMedian)

            return format('(%d) %02d:%02d', Monitor.data.predictLevelUpCount, floor(seconds / 60), seconds % 60)
        end,
    },
    {
        name = "满级时间",
        onUpdate = true,
        hideMaxLevel = true,
        updateFunc = function()
            if not Monitor.data.predictMaxLevelCount or not Monitor.data.gainExperienceTimeMedian then
                return UNKNOWN
            end

            local seconds = Monitor.data.gainExperienceTimeMedian * Monitor.data.predictMaxLevelCount
                - min(GetTime() - Monitor.data.gainExperienceLastTime, Monitor.data.gainExperienceTimeMedian)

            return format('(%d) %02d:%02d:%02d', Monitor.data.predictMaxLevelCount, floor(seconds / 3600), floor(seconds / 60) % 60, seconds % 60)
        end,
    },
}

local function onMonitorUpdate()
    for index, slotFrame in ipairs(Monitor.slotFrames) do
        if displaySlots[index].onUpdate then
            slotFrame.value:SetText(displaySlots[index].updateFunc())
        end
    end
end

function Monitor:UpdateMonitorFrame()
    for index, slotFrame in ipairs(self.slotFrames) do
        slotFrame.value:SetText(displaySlots[index].updateFunc())
    end
end

function Monitor:OnPetBattleStart()
    self.frame:Show()

    self.data.isInBattle = true
    self.data.enterBattleTime = GetTime()
    self.data.leaveBattleTime = nil
    if not self.data.gainExperienceLastTime then
        self.data.gainExperienceLastTime = self.data.enterBattleTime - 1
    end

    self:UpdateMonitorFrame()
end

function Monitor:OnPetBattleEnd()
    if self.data.isInBattle then
        self.data.isInBattle = false
        self.data.leaveBattleTime = GetTime()

        self:UpdateMonitorFrame()

        if self.data.playerLevel > #experienceData then
            self.frame:Hide()
        end
    end
end

do
    local xpGainTemplate = gsub(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED, '%%[ds]', '(.+)')

    ---@param text string
    function Monitor:OnExperienceGain(text)
        local experienceText = strmatch(text, xpGainTemplate)
        local experience = experienceText and tonumber(experienceText)
        if experience then
            self.data.gainExperienceValue = experience
            self.data.gainExperienceMultiplier = experience / experienceData[self.data.playerLevel].battleXP

            self.data.playerXP = self.data.playerXP + experience
            if self.data.playerXP >= self.data.playerXPMax then
                self.data.playerLevel = self.data.playerLevel + 1
                if self.data.playerLevel > #experienceData then
                    self.data.playerXP = 0
                    self.data.playerXPMax = 100000000
                else
                    self.data.playerXP = self.data.playerXP - self.data.playerXPMax
                    self.data.playerXPMax = experienceData[self.data.playerLevel].totalXP
                end
            end

            local now = GetTime()
            if self.data.gainExperienceLastTime then
                local interval = now - self.data.gainExperienceLastTime
                if interval > 1 then
                    -- when pet battle world quest is completed, the interval is lower than 1
                    -- ignore it to avoid the median time is too low

                    tinsert(self.data.gainExperienceTimes, interval)

                    local total = 0
                    for _, value in ipairs(self.data.gainExperienceTimes) do
                        total = total + value
                    end
                    if total > 16 * 60 then
                        tremove(self.data.gainExperienceTimes, 1)
                    end

                    local inOrder = CopyTable(self.data.gainExperienceTimes)
                    sort(inOrder)

                    local length = #inOrder
                    self.data.gainExperienceTimeMedian = length % 2 > 0 and
                        inOrder[ceil(length / 2)] or
                        ((inOrder[length / 2] + inOrder[length / 2 + 1]) / 2)

                    self.data.gainExperienceLastTime = now
                end

                -- intentionally not update the last time when interval is ignored
                -- calc it in next update
            else
                self.data.gainExperienceLastTime = now
            end

            self:UpdateExperiencePrediction()
            self:UpdateMonitorFrame()
        end
    end
end

function Monitor:OnExperienceUpdate()
    local playerLevel = UnitLevel('player')
    local playerXP = UnitXP('player')
    local playerXPMax = UnitXPMax('player')

    if playerLevel > #experienceData then
        self:SetMaxLevelMonitorFrame()
    end

    if (
        playerLevel ~= self.data.playerLevel or
        playerXP ~= self.data.playerXP or
        playerXPMax ~= self.data.playerXPMax
    ) then
        self.data.playerLevel = playerLevel
        self.data.playerXP = playerXP
        self.data.playerXPMax = playerXPMax

        self:UpdateExperiencePrediction()
        self:UpdateMonitorFrame()
    end
end

function Monitor:UpdateExperiencePrediction()
    if not self.data.gainExperienceTimeMedian then return end

    if self.data.playerLevel > #experienceData then
        self.data.predictLevelUpCount = 0
        self.data.predictMaxLevelCount = 0
        return
    end

    self.data.predictLevelUpCount = ceil(
        (self.data.playerXPMax - self.data.playerXP) /
        (experienceData[self.data.playerLevel].battleXP * self.data.gainExperienceMultiplier)
    )

    local currentXP = self.data.playerXP
    local predictMaxLevelCount = 0
    for level = self.data.playerLevel, #experienceData do
        local remaining = experienceData[level].totalXP - currentXP
        local experience = experienceData[level].battleXP * self.data.gainExperienceMultiplier
        local count = ceil(remaining / experience)
        predictMaxLevelCount = predictMaxLevelCount + count
        currentXP = currentXP + count * experience - experienceData[level].totalXP
    end
    self.data.predictMaxLevelCount = predictMaxLevelCount
end

function Monitor:SetMaxLevelMonitorFrame()
    for index, slotFrame in ipairs(self.slotFrames) do
        if displaySlots[index].hideMaxLevel then
            slotFrame:Hide()
        end
    end
end

function Monitor:CreateMonitorFrame()
    local frame = CreateFrame('Frame', 'RematchSwitcherMonitorFrame', _G.UIParent)
    frame:SetSize(300, #displaySlots * 25)
    frame:ClearAllPoints()
    frame:SetPoint('LEFT', _G.UIParent, 'CENTER', 300, 0)
    frame:SetScript('OnUpdate', onMonitorUpdate)

    self.frame = frame

    self.slotFrames = {}
    for index, slot in ipairs(displaySlots) do
        ---@class SlotFrame: Frame
        local slotFrame = CreateFrame('Frame', nil, frame)
        slotFrame:SetSize(300, 25)
        slotFrame:ClearAllPoints()
        slotFrame:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -(index - 1) * 25)

        slotFrame.label = slotFrame:CreateFontString(nil, 'ARTWORK', 'SystemFont_Shadow_Huge1_Outline')
        slotFrame.label:SetText(slot.name)
        slotFrame.label:SetPoint('TOPLEFT', slotFrame, 'TOPLEFT', 0, 0)

        slotFrame.value = slotFrame:CreateFontString(nil, 'ARTWORK', 'SystemFont_Shadow_Huge1_Outline')
        slotFrame.value:SetPoint('TOPLEFT', slotFrame, 'TOPLEFT', 100, 0)

        tinsert(self.slotFrames, slotFrame)
    end
end

function Monitor:Initialize()
    self.data = {
        playerLevel = UnitLevel('player'),
        playerXP = UnitXP('player'),
        playerXPMax = UnitXPMax('player'),
        isInBattle = C_PetBattles_IsInBattle(),
        gainExperienceTimes = {},
        gainExperienceMultiplier = 1,
    }

    self:CreateMonitorFrame()
    self.frame:SetShown(self.data.isInBattle)

    if self.data.playerLevel > #experienceData then
        self:SetMaxLevelMonitorFrame()
    end

    Rematch.events:Register(self, 'PET_BATTLE_OPENING_START', self.OnPetBattleStart)
    Rematch.events:Register(self, 'PET_BATTLE_CLOSE', self.OnPetBattleEnd)
    Rematch.events:Register(self, 'CHAT_MSG_COMBAT_XP_GAIN', self.OnExperienceGain)
    Rematch.events:Register(self, 'PLAYER_XP_UPDATE', self.OnExperienceUpdate)
end

Rematch.events:Register(Monitor, 'PLAYER_LOGIN', Monitor.Initialize)
