local temple = require("yeva.backgrounds.temple")
local stage_manager = require("cyn.gameplay.scene_manager")
local reimu = require("yeva.players.reimu")
local task = require("cyn.foundation.task")
local power = require("yeva.objs.items.power")
local large_power = require("yeva.objs.items.large_power")

local entry = stage_manager:new_stage("loading", { entry_point = true })
function entry:init()
    lstg.Log(LOG.DEBUG, "Hello from loading stage")

    temple:new()

    reimu:new()

    task.new(self, function()
        for _ = 1, math.INF do
            power:new(-100, 220)
            large_power:new(100, 220)
            task.wait(30)
        end
    end)
end