local item = require("yeva.objs.items")
local signals = require("cyn.foundation.signals")

---@class yeva.objs.item.full_power : yeva.objs.item
local M = item:define()

---@param x number X position
---@param y number Y position
---@param v integer Initial vertical upward velocity
---@param a number Initial angle
function M:init(x, y, v, a)
    item.init(self, x, y, 4, v, a)
end

function M:collect()
    signals:Emit("item.collect:power", -1) --Treated as full power in default power player behavior (since you can have more than 400 of max power)
end

return M