local object = require("cyn.engine.objects")
local view = require("cyn.engine.viewport.view")

local behavior = require("yeva.player.behavior")

---@class yeva.player : cyn.object
---@field behaviors table<string, yeva.player.behavior>
---@field behavior_order yeva.player.behavior[]
local M = object.define()
M.behavior = behavior

---@type yeva.player|nil
M.instance = nil

---@alias yeva.player.selectable_player_data { obj: yeva.player, name: string, full_name: string }

---@type yeva.player.selectable_player_data[]
M.selectable_players = {}

function M:init()
    ---TODO: Get those names from CDF
    self.name = "Placeholder"
    self.full_name = "Placeholder Full Name"
    self.x, self.y = 0, -192
    self.a, self.b = 4.5, 4.5
    self.layer = object.layer.PLAYER
    self.group = object.group.PLAYER
    ---@type table<string, yeva.player.behavior>
    self.behaviors = {}
    ---@type yeva.player.behavior[]
    self.behavior_order = {}

    self.lock = false
    self.protect = 0
    self.time_stop = false
    self.in_dialog = false

    M.instance = self

    --self:attach_behavior(d)
end

function M:frame()
    for _, b in ipairs(self.behavior_order) do
        b:frame()
    end

    self.protect = math.max(self.protect - 1, 0)
end

function M:render()
    view:set("world")
    for _, b in ipairs(self.behavior_order) do
        if not b.hide then
            b:render()
        end
    end
end

---@param other cyn.object
function M:colli(other)
    for _, b in ipairs(self.behavior_order) do
        b:colli(other)
    end
end

function M:del()
    for _, b in ipairs(self.behavior_order) do
        b:del()
    end
    self.behaviors = {}
    self.behavior_order = {}

    M.instance = nil
end

-------------------------- Behaviors

local function sort_behaviors_by_layer(a, b)
    return (a.layer or 0) < (b.layer or 0)
end

---Attaches a behavior to the player. Calls `init`.
---@generic T : yeva.player.behavior
---@param behavior { name: string, new: fun(self: any, player: yeva.player, ...): T } The behavior class to attach.
---@return T Instance The created behavior instance.
function M:attach_behavior(behavior, ...)
    if self.behaviors[behavior.name] then
        self:detach_behavior(behavior.name)
    end

    local instance = behavior:new(self, ...)
    self.behaviors[behavior.name] = instance
    table.insert(self.behavior_order, instance)
    table.sort(self.behavior_order, sort_behaviors_by_layer)

    return instance
end

---Detaches a behavior by name. Calls `del`.
---@param name string The name of the behavior to detach.
function M:detach_behavior(name)
    local b = self.behaviors[name]
    if not b then
        return
    end

    b:del()
    self.behaviors[name] = nil

    for i, entry in ipairs(self.behavior_order) do
        if entry == b then
            table.remove(self.behavior_order, i)
            break
        end
    end
end

---Returns an attached behavior by name or class, or nil if not found.
---@generic T : yeva.player.behavior
---@param behavior string | { name: string } The behavior name string or class.
---@return T?
function M:get_behavior(behavior)
    local name = type(behavior) == "string" and behavior or behavior.name
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

    for _, o in lstg.ObjList(object.group.ENEMY) do
        test_target(self, o, farthest)
    end
    for _, o in lstg.ObjList(object.group.IMMORTAL_ENEMY) do
        test_target(self, o, farthest)
    end
    for _, o in lstg.ObjList(object.group.BOSS) do
        test_target(self, o, farthest)
    end

    return self.target
end

---Registers a selectable player character. Used for selection screens mainly.
---@param obj yeva.player Object definition class
---@param name string Short name for the character, e.g "Reimu"
---@param full_name string Full name for the character, e.g "Reimu Hakurei"
function M.register_player(obj, name, full_name)
    if not M.selectable_players then
        M.selectable_players = {}
    end

    for _, entry in ipairs(M.selectable_players) do
        if entry.name == name then
            entry.obj = obj
            entry.full_name = full_name
            return
        end
    end

    ---@type yeva.player.selectable_player_data
    local player_data = {
        obj = obj,
        name = name,
        full_name = full_name
    }

    table.insert(M.selectable_players, player_data)
end

return M