---@type string, table
local addon, Engine = ...
---@class RematchSwitcher
---@field teamPolicy table<string, TeamPolicy?>
local RS = {}

-- Lua functions

-- WoW API / Variables

-- GLOBALS: RematchSwitcherDB

local L = {}
setmetatable(L, {
    -- Make missing translations available
    __index = function(self, key)
        self[key] = (key or "")
        return key
    end
})

---@type Rematch
local Rematch = _G.Rematch

Engine[1] = RS
Engine[2] = Rematch
Engine[3] = L
_G[addon] = Engine

function RS:Print(...)
    _G.DEFAULT_CHAT_FRAME:AddMessage("Rematch Switcher: " .. format(...))
end

function RS:Initialize()
    if not RematchSwitcherDB then
        ---@class RematchSwitcherDB
        ---@field dbVersion number
        ---@field teamPolicy table<string, TeamPolicy?>
        RematchSwitcherDB = {
            dbVersion = 1,
            teamPolicy = {},
        }
    end

    self.teamPolicy = RematchSwitcherDB.teamPolicy
end

Rematch.events:Register(RS, 'PLAYER_LOGIN', RS.Initialize)
