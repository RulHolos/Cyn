local ttf = require("core.engine.resources.ttf")

local w = core.ui_manager.widget()

local function get_stage_label()
    local sm = core.stage_manager
    if sm.current_group then
        return sm.current_group.name
    end
    if sm.current_stage then
        return sm.current_stage.name
    end
    return "Undefined"
end

function w:init()
    self.font = ttf.from_file("assets/fonts/score2.ttf", 16)

    self.fps = lstg.RichText.createFromPool(self.font.name, 16)
        :setAlignment("center", "top")
        :setFillColor(lstg.Color(255, 200, 200, 200))
        :setOutline(3, lstg.Color(255, 0, 0, 0))
        :setText(get_stage_label())

    local wo = core.screen.world
    self.x1 = -192 + wo.scrr
    self.x2 = 112 + wo.scrr
    self.y1 = 457
    self.y2 = 448
end

function w:frame()
end

function w:render()
    core.view:set("ui")

    local timer = core.stage_manager.current_stage.timer
    local a, t = 255, 1
    local dy = 22
    local g = core.stage_manager.current_group
    local idx = g and (g.current_index - 1) or 1 -- TODO: Fix this. Not sure about the "- 1" here.
    local x, y = self.x2, self.y2

    -- Mhh, code straight from THlib...
    if idx == 1 then
        if timer < 60 then
            x, y = self.x1, self.y1
            dy = 11
            a = math.floor(timer / 4) % 2 * 255
        elseif timer >= 60 and timer < 150 then
            x, y = self.x1, self.y1
            dy = 11
        elseif timer >= 150 and timer < 158 then
            x, y = self.x1, self.y1
            dy = 11
            t = math.max((1 - (timer - 150) / 8), 0)
            a = t * 255
        elseif timer >= 158 and timer < 165 then
            t = math.min((timer - 158) / 9, 1)
            a = t * 255
        end
    end
    if self.fps then
        self.fps:setState("", lstg.Color(a, 255, 255, 255))
        self.fps:render(x, y + dy)
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

core.ui_manager:register_widget("diff_ui", w)