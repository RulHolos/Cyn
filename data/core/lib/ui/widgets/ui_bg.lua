---@type core.ui.widget
local w = core.ui_manager.widget()

function w:init()
    --resources.set_default_sampler_state("point+clamp")
    self.bg = resources.image.from_file("assets/ui/ui_bg.png", true)
    self.bg:set_sampler_state("point+clamp")

    self.white = resources.image.from_file("assets/general/white.png", true)
    self.white:set_sampler_state("point+clamp")

    self.rtfd = lstg.RichText.create("assets/fonts/Maple Mono.ttf", 24)
    self.rtfd:setText("Hello [color=ffffff]World![/color] [ruby=test 2]test1 [shake i=3]test3[/shake][/ruby]"  ..
            " [gradient=#5BCEFA,#F5A9B8,#FFFFFF,#F5A9B8,#5BCEFA]TransRights![/gradient] aaaaaaaaaaaaaa")
        :setFillColor(lstg.Color(255, 0, 0, 0))
        :setOutline(2.0, lstg.Color(255, 128, 128, 128))
        :setShadow(0, 0, lstg.Color(255, 0, 0, 0), 3.0)
        :setTextWrap(300)
        --:setMaxWidth(300)
        --:setMaxHeight(40)
        :setAlignment("left", "middle")
end

function w:frame()
    if self.rtfd:hasAnimation() then
        self.rtfd:update()
    end
end

function w:render()
    if self.bg then
        self.bg:render_screen()
    end
    if self.white then
        local sizex, _ = self.rtfd:measure()
        self.white:render_rect(100, 100 + sizex, 50, 200)
    end
    --self.rtfd:setState("", lstg.Color(255, 255, 255, 255))
    self.rtfd:render(100, 100)
    --self.rtfd:render(100, 100, 0.5, 0.5, 0)
end

function w:del()
    if self.white then
        self.white:destroy()
        self.white = nil
    end
    if self.bg then
        self.bg:destroy()
        self.bg = nil
    end
    if self.rtfd then
        self.rtfd:destroy()
        self.rtfd = nil
    end
end

core.ui_manager:new_widget("bg_ui", w)