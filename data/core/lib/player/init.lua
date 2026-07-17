local Behavior = require("core.lib.player.behavior")

---@class core.player : core.object
---@field behaviors table<string, core.player.behavior>
local M = core.object.define()
core.player = M
---@type core.player|nil
core.player.instance = nil
core.player.behavior = Behavior
---@type table<{obj:core.player, name:string, full_name:string}>
core.player.selectable_players = {}

core.player.b_move = require("core.lib.player.default_behaviors.move") ---Default movement behavior.
core.player.b_death = require("core.lib.player.default_behaviors.death") ---Default death behavior.
core.player.b_animation = require("core.lib.player.default_behaviors.animation") ---Default animation behavior. Similar to THlib's player walk image.
core.player.b_power = require("core.lib.player.default_behaviors.power") ---Default power level behavior.

function M:init()
    ---TODO: Get those names from selectable_players
    self.name = "Placeholder"
    self.full_name = "Placeholder Full Name"
    self.x, self.y = 0, -192
    self.a, self.b = 4.5, 4.5
    self.layer = core.object.layer.PLAYER
    self.group = core.object.group.PLAYER
    ---@type table<string, core.player.behavior>
    self.behaviors = {}
    self.protect = 0
    self.in_dialog = false

    core.player.instance = self

    --self:attach_behavior(d)
end

function M:frame()
    for _, b in pairs(self.behaviors) do
        b:frame()
    end

    self.protect = math.max(self.protect - 1, 0)
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

    core.player.instance = nil
end

-------------------------- Behaviors

---Attaches a behavior to the player. Calls `init`.
---@generic T : core.player.behavior
---@param behavior { name: string, new: fun(self: any, player: core.player, ...): T } The behavior class to attach.
---@return T Instance The created behavior instance.
function M:attach_behavior(behavior, ...)
    if self.behaviors[behavior.name] then
        self:detach_behavior(behavior.name)
    end
    local instance = behavior:new(self, ...)
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

---Returns an attached behavior by class, or nil if not found.
---@generic T : core.player.behavior
---@param behavior { name: string, new: fun(self: any, player: core.player, ...): T } The behavior class.
---@return T?
function M:get_behavior(behavior)
    return self.behaviors[behavior.name]
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

---Registers a selectable player character. Used for selection screens mainly.
---@param obj core.player Object definition class
---@param name string Short name for the character, e.g "Reimu"
---@param full_name string Full name for the character, e.g "Reimu Hakurei"
function M.register_player(obj, name, full_name)
    if not M.selectable_players then
        M.selectable_players = {}
    end
    table.insert(M.selectable_players, { obj = obj, name = name, full_name = full_name })
end