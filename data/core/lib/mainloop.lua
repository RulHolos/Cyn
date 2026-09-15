---Global debug flag. Will enable debugging on all systems. Set this to false for release builds.
DEBUG = true

local function load_game()
    lstg.FileManager.CreateDirectory("game")
    local game = core.userdata.settings.game
    local zip_path = string.format("game/%s.zip", game)
    local dir_path = string.format("game/%s/", game)
    local dir_root_script = string.format("game/%s/root.lua", game)
    if lstg.FileManager.FileExist(zip_path) then
        lstg.LoadPack(zip_path)
        lstg.DoFile("root.lua")
    elseif lstg.FileManager.FileExist(dir_root_script) then
        lstg.FileManager.AddSearchPath(dir_path)
        lstg.DoFile("root.lua")
    end
end

function GameInit()
    core.object.init_all()
    load_game()

    core.signals:Emit("Init")
    core.screen:apply()

    lstg.IPC.start("LuaSTGFlux")
end

function GameExit()
    core.signals:Emit("Quit")
end

local screen_set = false

function FrameFunc()
    if not screen_set then -- Debug thing because GlazeWM doesn't like it another way.
        lstg.ChangeVideoMode(core.userdata.settings.graphics_system.width, core.userdata.settings.graphics_system.height, "windowed", true)
        screen_set = true
    end

    lstg.SetTitle(("%s | %.2f FPS | %d OBJs"):format(core.userdata.settings.game, lstg.GetFPS(), lstg.GetnObj()))
    core.input:refresh()
    core.imgui_manager:frame()

    core.signals:Emit("Frame")

    core.imgui_manager:layout()

    return core.quit_flag
end

function RenderFunc()
    lstg.BeginScene()

    core.signals:Emit("Render")

    lstg.AfterFrame()
    core.imgui_manager:render()
    lstg.EndScene()
end

function FocusGainFunc()
    core.signals:Emit("FocusGain")
end

function FocusLoseFunc()
    core.signals:Emit("FocusLose")
end

---Events

core.signals:Register("Object Frame", "Frame", function()
    if DEBUG then
        lstg.PartialObjFrame(debug_data.frame_groups, debug_data.frame_world)
    else
        lstg.ObjFrame()
    end

    lstg.BoundCheck()
    local g = core.object.group
    lstg.CollisionCheck(g.PLAYER, g.ENEMY_BULLET)
    lstg.CollisionCheck(g.PLAYER, g.ENEMY)
    lstg.CollisionCheck(g.PLAYER, g.BOSS)
    lstg.CollisionCheck(g.PLAYER, g.INDES)
    lstg.CollisionCheck(g.ENEMY, g.PLAYER_BULLET)
    lstg.CollisionCheck(g.BOSS, g.PLAYER_BULLET)
    lstg.CollisionCheck(g.IMMORTAL_ENEMY, g.PLAYER_BULLET)
    lstg.CollisionCheck(g.ITEM, g.PLAYER)

    if not DEBUG then
        lstg.UpdateXY()
    end
    lstg.AfterFrame()
end, 1000)

core.signals:Register("Object Render", "Render", function()
    if DEBUG then
        lstg.PartialObjRender(debug_data.frame_groups, debug_data.render_layers, debug_data.frame_world)
    else
        lstg.ObjRender()
    end
end, 1000)