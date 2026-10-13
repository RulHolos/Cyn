local task = require("cyn.foundation.task")
local cls = require("cyn.engine.class")
local event = require("yeva.boss.default_behaviors.timeline_event")

---@class yeva.boss.behavior.timeline.event.spell_card : yeva.boss.behavior.timeline.event
local spellcard = cls.class(event)

function spellcard:init()
end

function spellcard:frame(boss)
    task.exec(self)
end

function spellcard:is_done(boss)
    return false
end

---Spawns boss instances if they're not already present.
function spellcard:start(boss)
end

return spellcard