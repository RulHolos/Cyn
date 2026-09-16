---@class core.menu.cfg
---@field use_mouse boolean If true, mouse control will be enabled for the entire menu.

local render_target = require("core.engine.resources.render_target")
local image = require("core.engine.resources.image")

---@type core.cdf.file<core.menu.cfg>
local cfg = core.cdf.load_file("data/content/menu/config")

---Base class a menu panel containing widgets.
---@class core.menu.menu_panel : core.object
local menu_panel = core.object.define()

local rt_count = 0

function menu_panel:init(x, y)
    self.x, self.y = x, y
    self.layer = core.object.layer.TOP + 9
    self.group = core.object.group.GHOST
    self.alpha = 0
    self.bound = false
    self.can_manually_exit = false
    self.use_mouse = cfg.data.use_mouse or false

    self.widgets = {}

    self.lock = true

    self.rt = render_target.new("menu_panel" .. rt_count)
    self.img_rt = image.from_texture(self.rt)
    rt_count = rt_count + 1
end

function menu_panel:frame()
    core.tween.Do(self)

    if self.lock then
        return
    end
end

---@param use_rt boolean? If true, will push self's render target. USE self:render_rt() AT THE END OF IT WILL CRASH. (Or equivalent that pops the rt.)
function menu_panel:render(use_rt)
    core.view:set("ui")

    if use_rt then
        self.rt:push(true)
    end
end

---Calls a pop render target and renders on the screen by default.
---
---Override this function if you need a different render behavior.
function menu_panel:render_rt()
    self.rt:pop()

    local ratio = core.screen.width / core.userdata.settings.graphics_system.width
    self.img_rt:set_color(lstg.Color(self.alpha, 255, 255, 255))
    self.img_rt:render(core.screen.width / 2, core.screen.height / 2, ratio * self.hscale, ratio * self.vscale)
end

---Called once when the panel appears.
function menu_panel:enter()
    self.hide = false
    core.tween.New(self, { alpha = 255}, 30):ease("inOutCubic"):onCompleted(function() self.lock = false end)
    for _, widget in ipairs(self.widgets) do
        widget:enter()
    end
end

function menu_panel:del()
    if self.rt then
        self.rt:destroy()
        self.rt = nil
    end
    if self.img_rt then
        self.img_rt:destroy()
        self.img_rt = nil
    end
end