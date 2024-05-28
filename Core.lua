---@type RematchSwitcher, Rematch, table<string, string>
local RS, Rematch, L = unpack((select(2, ...)))
---@class RematchSwitcherCore
local Core = {}

---@class PetPolicy
---@field noSearch boolean?
---@field preferMaxHealth boolean?
---@field preferMinHealth boolean?
---@field ignoreStats boolean?
---@field useLevel boolean?
---@field maxLevel number?
---@field minLevel number?
---@field modifyPercent boolean?
---@field maxPercent number?
---@field minPercent number?
---@field useHealth boolean?
---@field maxHealth number?
---@field minHealth number?
---@field usePower boolean?
---@field maxPower number?
---@field minPower number?
---@field useSpeed boolean?
---@field maxSpeed number?
---@field minSpeed number?

---@class TeamPolicy
---@field disabled boolean?
---@field pets { [1]: PetPolicy?, [2]: PetPolicy?, [3]: PetPolicy? }?

---@param petID RematchPetID
---@param policy PetPolicy
function Core:IsPetMatchPolicy(petID, policy)
    local petInfo = Rematch.petInfo:Fetch(petID)

    if policy.modifyPercent then
        local percent = petInfo.health / petInfo.maxHealth * 100
        if policy.minPercent and percent < policy.minPercent then
            return false
        elseif policy.maxPercent and percent > policy.maxPercent then
            return false
        end
    elseif petInfo.isInjured then
        return false
    end

    if policy.useLevel then
        if policy.minLevel and petInfo.level < policy.minLevel then
            return false
        elseif policy.maxLevel and petInfo.level > policy.maxLevel then
            return false
        end
    end

    if policy.useHealth then
        if policy.minHealth and petInfo.health < policy.minHealth then
            return false
        elseif policy.maxHealth and petInfo.health > policy.maxHealth then
            return false
        end
    end

    if policy.usePower then
        if policy.minPower and petInfo.power < policy.minPower then
            return false
        elseif policy.maxPower and petInfo.power > policy.maxPower then
            return false
        end
    end

    if policy.useSpeed then
        if policy.minSpeed and petInfo.speed < policy.minSpeed then
            return false
        elseif policy.maxSpeed and petInfo.speed > policy.maxSpeed then
            return false
        end
    end

    return true
end

---@param petID RematchPetID
---@param policy PetPolicy
function Core:FindBestPet(petID, policy)
    if policy.noSearch then
        if self:IsPetMatchPolicy(petID, policy) then
            return petID
        else
            return
        end
    end

    local bestPetID = self:IsPetMatchPolicy(petID, policy) and petID or nil
    local petInfo = Rematch.petInfo:Fetch(petID)
    if (not bestPetID or policy.preferMaxHealth or policy.preferMinHealth) and petInfo.count > 1 then
        local bestHealth = bestPetID and petInfo.health or nil
        local speciesID = petInfo.speciesID
        local maxHealth, power, speed = petInfo.maxHealth, petInfo.power, petInfo.speed
        for ownedPetID in Rematch.roster:AllSpeciesPetIDs(speciesID) do
            if self:IsPetMatchPolicy(ownedPetID, policy) then
                local petInfo = Rematch.petInfo:Fetch(ownedPetID)
                if policy.ignoreStats or (petInfo.maxHealth == maxHealth and petInfo.power == power and petInfo.speed == speed) then
                    if not bestPetID then
                        bestPetID = ownedPetID
                        bestHealth = petInfo.health

                        if not policy.preferMaxHealth and not policy.preferMinHealth then
                            break
                        end
                    else
                        if policy.preferMaxHealth then
                            if petInfo.health > bestHealth then
                                bestPetID = ownedPetID
                                bestHealth = petInfo.health
                            end
                        elseif policy.preferMinHealth then
                            if petInfo.health < bestHealth then
                                bestPetID = ownedPetID
                                bestHealth = petInfo.health
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPetID
end

---@param teamID string
---@param pets { [1]: RematchPetID, [2]: RematchPetID, [3]: RematchPetID }
function Core:LoadTeam(teamID, pets)
    local teamInfo = Rematch.savedTeams[teamID]
    for slot = 1, 3 do
        local petID = pets[slot]
        local ability1, ability2, ability3 = Rematch.petTags:GetAbilities(teamInfo.tags[slot])

        Rematch.loadouts:SlotPet(slot, petID)
        if ability1 then
            C_PetJournal.SetAbility(slot, 1, ability1)
        end
        if ability2 then
            C_PetJournal.SetAbility(slot, 2, ability2)
        end
        if ability3 then
            C_PetJournal.SetAbility(slot, 3, ability3)
        end
    end

    Rematch.settings.currentTeamID = teamID
    Rematch.events:Fire('REMATCH_TEAM_LOADED', teamID)

    RS:Print("已加载%s", teamInfo.name)
end

---@param teamID string
function Core:IsTeamValid(teamID)
    for slot = 1, 3 do
        -- TODO: support random & leveling pets
        local petID = Rematch.savedTeams[teamID].pets[slot]
        if not petID then
            return false
        end

        local petInfo = Rematch.petInfo:Fetch(petID)
        if not petInfo.isOwned then
            return false
        end
    end
    return true
end

function Core:OnTargetChanged()
    local npcID = Rematch.targetInfo:GetUnitNpcID('target')
    local teams, index = Rematch.savedTargets:GetTeams(npcID)
    if not teams then return end

    if select(2, GetSpellCooldown(125439)) == 0 then
        RS:Print("复活战斗宠物准备就绪")
        -- Revive Battle Pets is ready
        for _, teamID in ipairs(teams) do
            if self:IsTeamValid(teamID) then
                self:LoadTeam(teamID, Rematch.savedTeams[teamID].pets)
                return
            end
        end

        -- all teams are invalid, fallback to default Rematch interact
        RS:Print("所有队伍失效")
        if index and teams[index] then
            Rematch.interact:LoadTeamID(teams[index])
        end
        return
    end

    for _, teamID in ipairs(teams) do
        local teamPolicy = RS.teamPolicy[teamID]
        if teamPolicy and not teamPolicy.disabled and self:IsTeamValid(teamID) then
            local teamInfo = Rematch.savedTeams[teamID]
            local petSlots = {}
            local isTeamReady = true
            for slot = 1, 3 do
                local petID = teamInfo.pets[slot]
                local petPolicy = teamPolicy and teamPolicy.pets and teamPolicy.pets[slot]
                local bestPetID = self:FindBestPet(petID, petPolicy or {})
                if not bestPetID then
                    isTeamReady = false
                    break
                end

                tinsert(petSlots, bestPetID)
            end

            if isTeamReady then
                self:LoadTeam(teamID, petSlots)
                return
            end
        end
    end

    -- all teams are invalid, fallback to default Rematch interact
    RS:Print("所有队伍失效")
    if index and teams[index] then
        Rematch.interact:LoadTeamID(teams[index])
    end
end

function Core:Initialize()
    -- disable Rematch interact
    local noop = function() end
    Rematch.interact.REMATCH_TARGET_CHANGED = noop
    Rematch.interact.UPDATE_MOUSEOVER_UNIT = noop
    Rematch.interact.PLAYER_SOFT_INTERACT_CHANGED = noop

    Rematch.events:Register(self, 'PLAYER_TARGET_CHANGED', self.OnTargetChanged)
end

Rematch.events:Register(Core, 'PLAYER_LOGIN', Core.Initialize)
