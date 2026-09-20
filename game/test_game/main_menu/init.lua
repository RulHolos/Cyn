local temple = require("yeva.backgrounds.temple")
local stage_manager = require("cyn.gameplay.scene_manager")

local entry = stage_manager:new_stage("loading", { entry_point = true })
function entry:init()
    lstg.Log(LOG.DEBUG, "Hello from loading stage")

    temple:new()

    --lstg.New(core.player.selectable_players[1].obj)
end