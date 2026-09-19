local ui_manager = require("yeva.ui")
local view = require("cyn.engine.viewport.view")
local world = require("cyn.engine.viewport.world")
local image = require("cyn.engine.resources.image")
local image_atlas = require("cyn.engine.resources.image_atlas")

local w = ui_manager.widget()

function w:init()
    self.bg = image.from_file("assets/ui/ui_bg.png", true)
    self.bg:set_sampler_state("point+clamp")

    self.lines = image_atlas.from_file("assets/ui/line.png", true)
    self.lines:set_sampler_state("point+wrap")
    self.lines:add_image_group("line_", 0, 0, 200, 8, 1, 7)

    local wo = world.current
    self.line_list = {
        { "line_1", 109 + wo.scrr, wo.scrt - 45, 0, 1, 1 },
        { "line_2", 109 + wo.scrr, wo.scrt - 67, 0, 1, 1 },
        { "line_3", 109 + wo.scrr, wo.scrt - 115, 0, 1, 1 },
        { "line_4", 109 + wo.scrr, wo.scrt - 153, 0, 1, 1 },
        { "line_5", 109 + wo.scrr, wo.scrt - 217, 0, 1, 1 },
        { "line_6", 109 + wo.scrr, wo.scrt - 240, 0, 1, 1 },
        { "line_7", 109 + wo.scrr, wo.scrt - 262, 0, 1, 1 },
    }
end

function w:frame()
end

function w:render()
    view:set("ui")
    if self.bg then
        self.bg:render_screen()
    end

    for i = 1, #self.line_list do
        local line = self.line_list[i]
        local img = self.lines:get_image(line[1])
        if img then
            img:render(line[2], line[3], line[4], line[5], line[6])
        end
    end
end

function w:del()
    if self.bg then
        self.bg:destroy()
        self.bg = nil
    end
    if self.lines then
        self.lines:destroy()
        self.lines = nil
    end
end

ui_manager:register_widget("bg_ui", w)