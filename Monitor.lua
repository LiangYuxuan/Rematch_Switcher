---@type RematchSwitcher, Rematch, table<string, string>
local RS, Rematch, L = unpack((select(2, ...)))
---@class Monitor
---@field data MonitorData
---@field frame Frame
---@field slotFrames SlotFrame[]
local Monitor = {}

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

local experienceData = {
    { battleXP = 170, totalXP = 250 },
    { battleXP = 240, totalXP = 590 },
    { battleXP = 310, totalXP = 1065 },
    { battleXP = 370, totalXP = 1675 },
    { battleXP = 440, totalXP = 2420 },
    { battleXP = 500, totalXP = 3305 },
    { battleXP = 575, totalXP = 4325 },
    { battleXP = 650, totalXP = 5485 },
    { battleXP = 700, totalXP = 6775 },
    { battleXP = 775, totalXP = 8205 },
    { battleXP = 850, totalXP = 9765 },
    { battleXP = 900, totalXP = 11030 },
    { battleXP = 975, totalXP = 12360 },
    { battleXP = 1050, totalXP = 13755 },
    { battleXP = 1100, totalXP = 15220 },
    { battleXP = 1200, totalXP = 16750 },
    { battleXP = 1250, totalXP = 18345 },
    { battleXP = 1300, totalXP = 20005 },
    { battleXP = 1400, totalXP = 21730 },
    { battleXP = 1450, totalXP = 23525 },
    { battleXP = 1500, totalXP = 25385 },
    { battleXP = 1600, totalXP = 27310 },
    { battleXP = 1650, totalXP = 29305 },
    { battleXP = 1700, totalXP = 31365 },
    { battleXP = 1800, totalXP = 33490 },
    { battleXP = 1850, totalXP = 35680 },
    { battleXP = 1950, totalXP = 37935 },
    { battleXP = 2000, totalXP = 40260 },
    { battleXP = 2050, totalXP = 42650 },
    { battleXP = 2150, totalXP = 45105 },
    { battleXP = 2200, totalXP = 45590 },
    { battleXP = 2250, totalXP = 46005 },
    { battleXP = 2350, totalXP = 46360 },
    { battleXP = 2400, totalXP = 46655 },
    { battleXP = 2450, totalXP = 46880 },
    { battleXP = 2550, totalXP = 47045 },
    { battleXP = 2600, totalXP = 47145 },
    { battleXP = 2650, totalXP = 47185 },
    { battleXP = 2750, totalXP = 47160 },
    { battleXP = 2800, totalXP = 47070 },
    { battleXP = 2850, totalXP = 46915 },
    { battleXP = 2950, totalXP = 46700 },
    { battleXP = 3000, totalXP = 46420 },
    { battleXP = 3050, totalXP = 46075 },
    { battleXP = 3150, totalXP = 45670 },
    { battleXP = 3200, totalXP = 45200 },
    { battleXP = 3300, totalXP = 44670 },
    { battleXP = 3350, totalXP = 44070 },
    { battleXP = 3400, totalXP = 43410 },
    { battleXP = 3500, totalXP = 42690 },
    { battleXP = 3550, totalXP = 47565 },
    { battleXP = 3600, totalXP = 52600 },
    { battleXP = 3700, totalXP = 57785 },
    { battleXP = 3750, totalXP = 63135 },
    { battleXP = 3800, totalXP = 68635 },
    { battleXP = 3900, totalXP = 74295 },
    { battleXP = 3950, totalXP = 80110 },
    { battleXP = 4000, totalXP = 86085 },
    { battleXP = 4550, totalXP = 92215 },
    { battleXP = 4600, totalXP = 194815 },
    { battleXP = 4700, totalXP = 214540 },
    { battleXP = 4750, totalXP = 234805 },
    { battleXP = 4850, totalXP = 255610 },
    { battleXP = 4900, totalXP = 276945 },
    { battleXP = 5000, totalXP = 298820 },
    { battleXP = 5050, totalXP = 321235 },
    { battleXP = 5150, totalXP = 344185 },
    { battleXP = 5200, totalXP = 367675 },
    { battleXP = 4750, totalXP = 391700 },
}

---@type { name: string, onUpdate: boolean?, hideMaxLevel: boolean, updateFunc: fun(): string }[]
local displaySlots = {
    {
        name = '战斗时间',
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
        name = '经验加成',
        updateFunc = function()
            local warModeText = (C_UnitAuras.GetPlayerAuraBySpellID(282559) and GREEN_FONT_COLOR or GRAY_FONT_COLOR):WrapTextInColorCode('战争模式')
            local safariHatText = (C_UnitAuras.GetPlayerAuraBySpellID(158486) and GREEN_FONT_COLOR or GRAY_FONT_COLOR):WrapTextInColorCode('狩猎帽')
            return format('%s %s', warModeText, safariHatText)
        end,
    },
    {
        name = '治疗宠物',
        onUpdate = true,
        updateFunc = function()
            local start, duration = GetSpellCooldown(125439)
            if start > 0 and duration > 0 then
                local remaining = start + duration - GetTime()
                return format('(|T133675:12|t %d) %02d:%02d', C_Item.GetItemCount(86143), floor(remaining / 60), remaining % 60)
            else
                return format('(|T133675:12|t %d) %s', C_Item.GetItemCount(86143), READY)
            end
        end,
    },
    {
        name = '升级队列',
        updateFunc = function()
            return format('%d', #Rematch.settings.LevelingQueue)
        end,
    },
    {
        name = '玩家等级',
        hideMaxLevel = true,
        updateFunc = function()
            return format('%d (%.2f%%)', Monitor.data.playerLevel, Monitor.data.playerXP / Monitor.data.playerXPMax * 100)
        end,
    },
    {
        name = '经验获取',
        hideMaxLevel = true,
        updateFunc = function()
            if not Monitor.data.gainExperienceValue then
                return UNKNOWN
            end

            return format('%d (%.2fx)', Monitor.data.gainExperienceValue, Monitor.data.gainExperienceMultiplier)
        end,
    },
    {
        name = '经验间隔',
        hideMaxLevel = true,
        updateFunc = function()
            return Monitor.data.gainExperienceTimeMedian and format('%d', Monitor.data.gainExperienceTimeMedian) or UNKNOWN
        end,
    },
    {
        name = '升级时间',
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
        name = '满级时间',
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
        isInBattle = C_PetBattles.IsInBattle(),
        gainExperienceTimes = {},
        gainExperienceMultiplier = 1,
    }

    self:CreateMonitorFrame()
    self.frame:SetShown(C_PetBattles.IsInBattle())

    if self.data.playerLevel > #experienceData then
        self:SetMaxLevelMonitorFrame()
    end

    Rematch.events:Register(self, 'PET_BATTLE_OPENING_START', self.OnPetBattleStart)
    Rematch.events:Register(self, 'PET_BATTLE_CLOSE', self.OnPetBattleEnd)
    Rematch.events:Register(self, 'CHAT_MSG_COMBAT_XP_GAIN', self.OnExperienceGain)
    Rematch.events:Register(self, 'PLAYER_XP_UPDATE', self.OnExperienceUpdate)
end

Rematch.events:Register(Monitor, 'PLAYER_LOGIN', Monitor.Initialize)
