local boss = require("yeva.boss")

---@class yeva.boss.behavior.timeline.event.definition
---@field name string The unique name of the event.
---@field event yeva.boss.behavior.timeline.event Class to instanciate.
---@field transitions table<{ condition: fun(boss):boolean, target:string }>

---Base class for boss timelines.
---
---This is the equivalent of a spell-card order, dialog order, etc...
---
---This timeline system supports branching paths, conditional events and sequences.
---@class yeva.boss.behavior.timeline : yeva.boss.behavior
local M = boss.behavior.define("timeline")

function M:init()
    ---Array of events in-insert-order (for implicit sequences)
    ---@type table<yeva.boss.behavior.timeline.event.definition>
    self.events = {}

    ---Maps an event name to its instance for conditional access.
    ---@type table<string, yeva.boss.behavior.timeline.event>
    self.events_by_name = {}

    ---@type yeva.boss.behavior.timeline.event? Currently running event.
    self.current_event = nil

    ---Index of current_event in self.events. 0 means not started yet.
    ---@type integer
    self.current_index = 0
end

---@param def yeva.boss.behavior.timeline.event.definition
function M:add_event(def)
    assert(not self.events_by_name[def.name], "duplicate timeline event name: " .. tostring(def.name))

    local instance = def.event()
    instance.name = def.name
    instance.transitions = def.transitions or {}
    instance._index = #self.events + 1

    table.insert(self.events, instance)
    self.events_by_name[def.name] = instance
end

---Picks the event that should follow the current one based on conditions and branches.
---
---Falls back to the next event in insertion order when no transition matches.
---@return yeva.boss.behavior.timeline.event?
function M:_resolve_next()
    local current = self.current_event

    if current then
        for _, transition in ipairs(current.transitions) do
            if not transition.condition or transition.condition(self.boss) then
                local target = self.events_by_name[transition.target]
                assert(target, "unknown timeline event target: " .. tostring(transition.target))
                return target
            end
        end
    end

    return self.events[self.current_index + 1]
end

---Leaves the current event (if any) and enters the next one.
function M:next()
    if self.current_event then
        self.current_event:leave(self.boss)
    end

    local event = self:_resolve_next()
    self.current_event = event
    self.current_index = event and event._index or (self.current_index + 1)

    if event then
        event:enter(self.boss)
    end
end

function M:frame()
    if not self.current_event and self.current_index == 0 and #self.events > 0 then
        self:next()
    end

    local current = self.current_event
    if not current then
        return
    end

    current:frame(self.boss)

    if current:is_done(self.boss) then
        self:next()
    end
end

function M:del()
    if self.current_event then
        self.current_event:leave(self.boss)
        self.current_event = nil
    end
end

return M