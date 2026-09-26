local object = require("cyn.engine.objects")
local tex = require("cyn.engine.resources.texture")
local img = require("cyn.engine.resources.image")
local signals = require("cyn.foundation.signals")
local view = require("cyn.engine.viewport.view")

local render_tex = tex.from_file("cyn/tools/render_colli.png")
local rect = img.from_texture(render_tex, 0, 0, 128, 128)
local rect1 = img.from_texture(render_tex, 0, 0, 32, 128)
local rect2 = img.from_texture(render_tex, 32, 0, 64, 128)
local rect3 = img.from_texture(render_tex, 96, 0, 32, 128)
local ring = img.from_texture(render_tex, 130, 0, 128, 128)

local function match_base(class, match)
    if class == match then
        return true
    elseif class.base then
        return match_base(class.base, match)
    end
end

local toggle, KeyDown192,
l1, l2, l3, l, w,
x, y, tx, ty, dx, dy, wx, wy,
x1, y1, x2, y2, x3, y3, x4, y4

local M = {}
M.list = {
    { object.group.PLAYER, lstg.Color(255, 50, 255, 50) },
    { object.group.PLAYER_BULLET, lstg.Color(255, 127, 127, 192) },
    { object.group.SPELL, lstg.Color(255, 255, 50, 255) },
    { object.group.IMMORTAL_ENEMY, lstg.Color(255, 128, 255, 255) },
    { object.group.ENEMY, lstg.Color(255, 255, 255, 128) },
    { object.group.ENEMY_BULLET, lstg.Color(255, 255, 50, 50) },
    { object.group.INDES, lstg.Color(255, 255, 165, 10) },
}

function M.init()
    toggle = false
    KeyDown192 = false
end

function M.render()
    view:set("world")
    if lstg.GetKeyState(lstg.Input.Keyboard.Space) then
        if not KeyDown192 then
            KeyDown192 = true
            if toggle == true then
                toggle = false
            else
                toggle = true
            end
        end
    else
        KeyDown192 = false
    end
    if toggle == true then
        for i = 1, #M.list do
            local c = M.list[i][2]
            rect:set_color(c)
            rect1:set_color(c)
            rect2:set_color(c)
            rect3:set_color(c)
            ring:set_color(c)
            local bc = lstg.Color(c.a * 0.6, c.r, c.b, c.g)
            for _, unit in lstg.ObjList(M.list[i][1]) do
                if unit.rect == true then
                    print("rect")
                    rect:render(unit.x, unit.y, unit.rot, unit.a / 64, unit.b / 64)
                else
                    print("ring")
                    ring:render(unit.x, unit.y, unit.rot, unit.a / 64, unit.b / 64)
                end
            end
        end
    end
end

signals:Register("colliders:render", signals.known_signals.RenderFunc, M.render)

M.init()
