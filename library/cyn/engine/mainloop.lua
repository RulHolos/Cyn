local signals = require("cyn.foundation.signals")
local groups = require("cyn.engine.objects.groups")[1]
local game_loader = require("cyn.engine.game_loader")
local objects = require("cyn.engine.objects")

---Global debug flag. Will enable debugging on all systems. Set this to false for release builds.
DEBUG = true

---@type boolean Put this flag to `true` to make the game quit.
QuitFlag = false

function GameInit()
    game_loader.load()
    objects.init_all()

    signals:Emit(signals.known_signals.GameInit)
end

function GameExit()
    signals:Emit(signals.known_signals.GameExit)
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
        lstg.ChangeVideoMode(cyn.userdata.settings.graphics_system.width, cyn.userdata.settings.graphics_system.height, "windowed", true)
        screen_set = true
    end

    lstg.SetTitle(("%s | %.2f FPS | %d OBJs"):format(cyn.userdata.settings.game, lstg.GetFPS(), lstg.GetnObj()))
    cyn.imgui_manager:frame()

    cyn.signals:Emit("Frame")

    cyn.imgui_manager:layout()

    return cyn.quit_flag]]

    frame_objects()
    signals:Emit(signals.known_signals.BeforeFrameFunc)
    signals:Emit(signals.known_signals.FrameFunc)
    signals:Emit(signals.known_signals.AfterFrameFunc)

    return QuitFlag
end

function RenderFunc()
    lstg.BeginScene()

    render_objects()
    signals:Emit(signals.known_signals.RenderFunc)

    lstg.AfterFrame()

    lstg.EndScene()
end

function FocusGainFunc()
    signals:Emit(signals.known_signals.FocusGain)
end

function FocusLoseFunc()
    signals:Emit(signals.known_signals.FocusLose)
end