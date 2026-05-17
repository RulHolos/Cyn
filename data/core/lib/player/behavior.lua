---@class core.player.behavior
---@field name string
---@field player core.player
---@field init fun(self) Called when the behavior is attached to a player.
---@field frame fun(self) Called every frame.
---@field render fun(self) Called every render frame.
---@field colli fun(self, other) Called when the player collides with another object.
---@field del fun(self) Called when the behavior is detached from the player.
local Behavior = {}
Behavior.__index = Behavior

local noop = function(self) end

---Defines a new behavior type.
---@param name string The unique name for this behavior.
---@return core.player.behavior
function Behavior.define(name)
    ---@class core.player.behavior
    local b = setmetatable({}, { __index = Behavior })
    b.__index = b
    b.name = name
    b.init = noop
    b.frame = noop
    b.render = noop
    b.colli = noop
    b.del = noop
    return b
end

---@param player core.player
---@return core.player.behavior
function Behavior:new(player)
    ---@type core.player.behavior
    local instance = setmetatable({}, self)
    instance.player = player
    instance:init()
    return instance
end

return Behavior
