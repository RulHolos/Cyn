local signals = require("cyn.foundation.signals")

---@class yeva.db.resource_manager
local M = {
    lives = 2,
    bombs = 2,

    default_lives = 2,
    default_bombs = 2,
    bombs_cap_on_miss = 3,
}

---Resets values to their default state.
---@param tbl table Optional keys/values pair to override default values.
function M:reset(tbl)
    self.lives = self.default_lives
    self.bombs = self.default_bombs

    if tbl then
        for k, v in pairs(tbl) do
            self[k] = v
        end
    end
end

function M:miss()
    self.lives = math.max(self.lives - 1, 0)
    self.bombs = math.max(self.bombs, self.bombs_cap_on_miss)
end

signals:Register("resource_manager:miss", "player:miss", function()
    M:miss()
end)

return M