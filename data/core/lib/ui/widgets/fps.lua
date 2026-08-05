local w = core.ui_manager.widget()

function w:init()
    self.font = resources.ttf.from_file("assets/fonts/score2.ttf", 5)

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
    core.view:set("ui")

    if self.fps then
        self.fps:render(core.screen.width - 2, 2)
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

core.ui_manager:register_widget("fps_ui", w)