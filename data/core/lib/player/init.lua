local Behavior = require("core.lib.player.behavior")

---@class core.player : core.object
---@field behaviors table<string, core.player.behavior>
local M = core.object.define()
core.player = M
core.player.instances = {}
core.player.behavior = Behavior

---@param player_index string e.g "p1". Links to the input system for default indexing.
---@return core.player|nil The player instance for the given index, or nil if not found.
function M.get_instance_at(player_index)
    return core.player.instances[player_index]
end

---@param player_index string e.g "p1". Links to the input system for default indexing.
function M:init(player_index)
    self.pindex = player_index --Player control index. e.g "p1"
    self.x, self.y = 0, 0
    self.a, self.b = 4.5, 4.5
    self.layer = core.object.layer.PLAYER
    self.group = core.object.group.PLAYER
    ---@type table<string, core.player.behavior>
    self.behaviors = {}

    core.player.instances[player_index] = self

    --self:attach_behavior(d)
end

function M:frame()
    for _, b in pairs(self.behaviors) do
        b:frame()
    end
end

function M:render()
    core.view:set("world")
    for _, b in pairs(self.behaviors) do
        b:render()
    end
end

---@param other core.object
function M:colli(other)
    for _, b in pairs(self.behaviors) do
        b:colli(other)
    end
end

function M:del()
    for _, b in pairs(self.behaviors) do
        b:del()
    end
    self.behaviors = {}

    core.player.instances[self.pindex] = nil
end

-------------------------- Behaviors

---Attaches a behavior to the player. Calls `init`.
---@param behavior core.player.behavior The behavior class to attach.
---@return core.player.behavior @The created behavior instance.
function M:attach_behavior(behavior)
    if self.behaviors[behavior.name] then
        self:detach_behavior(behavior.name)
    end
    local instance = behavior:new(self)
    self.behaviors[behavior.name] = instance
    return instance
end

---Detaches a behavior by name. Calls `del`.
---@param name string The name of the behavior to detach.
function M:detach_behavior(name)
    local b = self.behaviors[name]
    if b then
        b:del()
        self.behaviors[name] = nil
    end
end

---Returns an attached behavior by name, or nil if not found.
---@param name string
---@return core.player.behavior?
function M:get_behavior(name)
    return self.behaviors[name]
end

-------------------------- Helpers

local function test_target(p, obj, farthest)
    if obj.colli then
        local dx = p.x - obj.x
        local dy = p.y - obj.y
        local pri = math.abs(dy) / (math.abs(dx) + 0.01)
        if p._target_pri == nil
            or (not farthest and pri > p._target_pri)
            or (farthest and pri < p._target_pri)
        then
            p._target_pri = pri
            p.target = obj
        end
    end
end

---Finds the first possible target enemy/immortal enemy/boss object and returns it.
---
---Also stores it in `self.target`
---@param farthest boolean? If true, returns the farthest target instead of the closest. Defaults to false.
---@return lstg.object @The current target object.
function M:find_target(farthest)
    self.target = nil
    self._target_pri = nil

    for _, o in lstg.ObjList(core.object.group.ENEMY) do
        test_target(self, o, farthest)
    end
    for _, o in lstg.ObjList(core.object.group.IMMORTAL_ENEMY) do
        test_target(self, o, farthest)
    end
    for _, o in lstg.ObjList(core.object.group.BOSS) do
        test_target(self, o, farthest)
    end

    return self.target
end

require("core.lib.player.default_behaviors.death")
require("core.lib.player.default_behaviors.move")