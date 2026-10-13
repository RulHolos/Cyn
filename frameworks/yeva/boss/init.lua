local cls = require("cyn.engine.class")
local behavior = require("yeva.boss.behavior")

---Base class for boss systems.
---
---Inherit this class to create your bosses.
---@class yeva.boss : cyn.class
---@field init fun(self:yeva.boss) Called when the boss system is created.
local M = cls.class()
M.behavior = behavior

--[[
Idea:
Everything is modular.
Timeline is the list of spell-cards, dialogs, ...

A spell-card is a single file. You can attach behaviors to it, like a timer, hp bars...

Closest I can describe this boss system as is that it's the dnh approach.
]]

function M:init()
    self.behaviors = {}

    ---@type yeva.boss.instance[]
    self.instances = {}
end

function M:frame()
    for _, b in ipairs(self.behaviors) do
        b:frame()
    end
end

function M:render()
    for _, b in ipairs(self.behaviors) do
        b:render()
    end
end

function M:del()
    for _, b in ipairs(self.behaviors) do
        b:del()
    end
    self.behaviors = {}
end

-------------------------- Behaviors

---Attaches a behavior to the boss. Calls `init`.
---@generic T : yeva.boss.behavior
---@param behavior { name: string, new: fun(self: any, boss: yeva.boss, ...): T } The behavior class to attach.
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
    if not b then
        return
    end

    b:del()
    self.behaviors[name] = nil
end

---Returns an attached behavior by name or class, or nil if not found.
---@generic T : yeva.boss.behavior
---@param behavior string | { name: string } The behavior name string or class.
---@return T?
function M:get_behavior(behavior)
    local name = type(behavior) == "string" and behavior or behavior.name
    return self.behaviors[name]
end

return M