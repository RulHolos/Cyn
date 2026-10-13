---@class yeva.boss.behavior
---@field name string The name of the behavior.
---@field boss yeva.boss The boss to which this behavior is attached.
---@field init fun(self, ...) Called when the behavior is attached to a boss.
---@field frame fun(self) Called every frame.
---@field render fun(self) Called every render frame.
---@field del fun(self) Called when the behavior is detached from the boss.
---@field debug fun(self)? Called when the boss debug is rendered in ImGui.
local Behavior = {}

local noop = function(self, ...) end

---Defines a new behavior type.
---@param name string The unique name for this behavior.
---@return yeva.boss.behavior
function Behavior.define(name)
    ---@class yeva.boss.behavior
    local b = setmetatable({}, { __index = Behavior })
    b.__index = b
    b.name = name
    b.boss = nil
    b.init = noop
    b.frame = noop
    b.render = noop
    b.del = noop
    b.debug = nil
    return b
end

---@generic T : yeva.boss.behavior
---@param self T
---@param boss yeva.boss
---@return T
function Behavior:new(boss, ...)
    ---@type yeva.boss.behavior
    local instance = setmetatable({}, self)
    instance.boss = boss
    instance:init(...)
    return instance
end

return Behavior
