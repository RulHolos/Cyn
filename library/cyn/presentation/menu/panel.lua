local object = require("cyn.engine.objects")
local view = require("cyn.engine.viewport.view")
local task = require("cyn.foundation.task")
local tween = require("cyn.foundation.tween")
local menu_node = require("cyn.presentation.menu")
local input = require("cyn.engine.input")
local rt = require("cyn.engine.resources.render_target")
local img = require("cyn.engine.resources.image")
local screen = require("cyn.engine.viewport.screen")
local settings = require("cyn.foundation.settings_manager")

local cfg = require("cyn.presentation.menu.config")

---@class cyn.menu_panel : cyn.menu_node
local panel = object.define(menu_node)

local rt_count = 0

function panel:init(x, y, parent)
    menu_node.init(self, x, y, parent)

    self.can_manually_exit = true

    self.rt_name = "cyn_menu_panel:" .. rt_count
    self.img_rt_name = "cyn_menu_panel:" .. rt_count
    rt_count = rt_count + 1

    lstg.CreateRenderTarget(self.rt_name)
    self.rt = rt.new(self.rt_name)
    self.img = img.from_texture(self.rt)
end

function panel:frame()
    menu_node.frame(self)

    if self.lock then
        return
    end

    local exit_pressed = input:is_pressed(cfg.exit_key) or (self.use_mouse and input:mouse_is_pressed(cfg.exit_mouse_button))

    if exit_pressed and self.can_manually_exit then
        self:exit("back")
    end
end

---@param use_rt boolean? If true, pushes this panel's render target. Must be paired with :render_rt() at the end, or it will crash.
function panel:render(use_rt)
    menu_node.render(self)

    if use_rt == true then
        self.rt:push(true)
    end
end

function panel:render_rt()
    self.rt:pop()

    local ratio = screen.width / settings:get().graphics_system.width
    self.img:set_color(lstg.Color(self.alpha, 255, 255, 255))
    self.img:render(screen.width / 2, screen.height / 2, 0, ratio * self.hscale, ratio * self.vscale)
end

function panel:del()
    menu_node.del(self)

    if self.rt then
        self.rt:destroy()
        self.rt = nil
    end
    if self.img then
        self.img:destroy()
        self.img = nil
    end
end

return panel