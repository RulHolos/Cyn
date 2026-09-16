local signals = require("core.foundation.signals")
local groups = require("core.engine.objects.groups")[1]
local game_loader = require("core.engine.game_loader")
local objects = require("core.engine.objects")

---Global debug flag. Will enable debugging on all systems. Set this to false for release builds.
DEBUG = true

---@type boolean Put this flag to `true` to make the game quit.
QuitFlag = false

function GameInit()
    game_loader.load()
    objects.init_all()

    signals:Emit("GameInit")
    --core.screen:apply()
end

function GameExit()
    signals:Emit("GameExit")
end

--local screen_set = false

local function frame_objects()
    if DEBUG then
        lstg.PartialObjFrame(debug_data.frame_groups, debug_data.frame_world)
    else
        lstg.ObjFrame()
    end

    lstg.BoundCheck()
    local g = groups
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
end

local function render_objects()
    if DEBUG then
        lstg.PartialObjRender(debug_data.frame_groups, debug_data.render_layers, debug_data.frame_world)
    else
        lstg.ObjRender()
    end
end

function FrameFunc()
    --[[if not screen_set then -- Debug thing because GlazeWM doesn't like it another way.
        lstg.ChangeVideoMode(core.userdata.settings.graphics_system.width, core.userdata.settings.graphics_system.height, "windowed", true)
        screen_set = true
    end

    lstg.SetTitle(("%s | %.2f FPS | %d OBJs"):format(core.userdata.settings.game, lstg.GetFPS(), lstg.GetnObj()))
    core.imgui_manager:frame()

    core.signals:Emit("Frame")

    core.imgui_manager:layout()

    return core.quit_flag]]

    frame_objects()
    signals:Emit("FrameFunc")

    return QuitFlag
end

function RenderFunc()
    lstg.BeginScene()

    render_objects()
    signals:Emit("RenderFunc")

    lstg.AfterFrame()

    lstg.EndScene()
end

function FocusGainFunc()
    signals:Emit("FocusGain")
end

function FocusLoseFunc()
    signals:Emit("FocusLose")
end