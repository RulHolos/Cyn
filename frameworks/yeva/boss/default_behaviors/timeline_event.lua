local cls = require("cyn.engine.class")

---Base class for a single timeline event (spell-card, dialog, scripted action...).
---
---Subclass this and override the lifecycle methods to implement concrete event kinds.
---@class yeva.boss.behavior.timeline.event : cyn.class
---@field name string Assigned by the owning timeline when the event is added.
---@field transitions { condition: (fun(boss):boolean)?, target: string }[] Assigned by the owning timeline.
---@field _index integer Insertion order within the owning timeline. Assigned by the owning timeline.
local M = cls.class()

function M:init()
end

---Called once when the timeline switches to this event.
---@param boss yeva.boss
function M:enter(boss)
end

---Called every frame while this event is the active one.
---@param boss yeva.boss
function M:frame(boss)
end

---Whether this event has finished running. Defaults to true (instant event).
---@param boss yeva.boss
---@return boolean
function M:is_done(boss)
    return true
end

---Called once when the timeline leaves this event.
---@param boss yeva.boss
function M:leave(boss)
end

return M