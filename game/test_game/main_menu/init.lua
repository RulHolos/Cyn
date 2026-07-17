local entry = core.stage_manager:new_stage("loading", { entry_point = true })
function entry:init()
    print("Hello from loading stage")

    lstg.New(core.background.temple)

    lstg.New(core.player.selectable_players[1].obj)
end