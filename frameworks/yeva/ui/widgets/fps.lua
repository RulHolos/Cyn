local ui_manager = require("yeva.ui")
local view = require("cyn.engine.viewport.view")
local screen = require("cyn.engine.viewport.screen")
local ttf = require("cyn.engine.resources.ttf")

local w = ui_manager.widget()

function w:init()
    self.font = ttf.from_file("assets/fonts/score2.ttf", 5)

    self.fps = lstg.RichText.createFromPool(self.font.name, 5)
    self.fps:setAlignment("right", "bottom")
    self.fps:setFillColor(lstg.Color(255, 200, 200, 200))
    self.fps:setOutline(1, lstg.Color(255, 0, 0, 0))
    self.fps:setText("FPS: 0")
end

function w:frame()
    self.fps:setText(string.format("%.1f FPS", lstg.GetFPS()))
    self.fps:update()
end

function w:render()
    view:set("ui")

    if self.fps then
        self.fps:render(screen.width - 2, 2)
    end
end

function w:del()
    if self.font then
        self.font:destroy()
        self.font = nil
    end
    if self.fps then
        self.fps:destroy()
        self.fps = nil
    end
end

ui_manager:register_widget("fps_ui", w)