---@class yeva.player.behavior
---@field name string
---@field player yeva.player
---@field init fun(self, ...) Called when the behavior is attached to a player.
---@field frame fun(self) Called every frame.
---@field render fun(self) Called every render frame.
---@field colli fun(self, other) Called when the player collides with another object.
---@field del fun(self) Called when the behavior is detached from the player.
---@field debug fun(self) Called when the player debug is rendered in ImGui.
local Behavior = {}

local noop = function(self, ...) end

---Defines a new behavior type.
---@param name string The unique name for this behavior.
---@return yeva.player.behavior
function Behavior.define(name)
    ---@class yeva.player.behavior
    local b = setmetatable({}, { __index = Behavior })
    b.__index = b
    b.name = name
    b.init = noop
    b.frame = noop
    b.render = noop
    b.colli = noop
    b.del = noop
    b.debug = nil -- Nil since it won't trigger if not defined.
    return b
end

---@generic T : yeva.player.behavior
---@param self T
---@param player yeva.player
---@return T
function Behavior:new(player, ...)
    ---@type yeva.player.behavior
    local instance = setmetatable({}, self)
    instance.player = player
    instance:init(...)
    return instance
end

return Behavior
