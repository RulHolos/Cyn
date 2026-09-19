local ui_manager = require("yeva.ui")
local view = require("cyn.engine.viewport.view")
local world = require("cyn.engine.viewport.world")
local ttf = require("cyn.engine.resources.ttf")

local w = ui_manager.widget()

local function format_score(score)
    score = math.max(0, math.min(score, 99999999999))
    return string.format("[wave amp=0.5]%02d.%03d.%03d.%03d[/wave]",
        math.floor(score / 1e9),
        math.floor(score / 1e6) % 1000,
        math.floor(score / 1e3) % 1000,
        score % 1000)
end

---@param rt lstg.RichText
---@param r number
---@param g number
---@param b number
local function set_common_text(rt, r, g, b)
    rt:setFillColor(lstg.Color(255, r, g, b))
    rt:setAlignment("left", "middle")
    rt:setOutline(3, lstg.Color(255, 0, 0, 0))
end

function w:init()
    self.font = ttf.from_file("assets/fonts/score.ttf", 16)
    self.font2 = ttf.from_file("assets/fonts/score2.ttf", 10)

    self.last_score = -1
    self.last_hiscore = -1

    self.hiscore = lstg.RichText.createFromPool(self.font.name, 14)
    self.hiscore:setText(i18n.get("ui/main", "UI", "highscore"))
    set_common_text(self.hiscore, 200, 200, 200)

    self.hiscore_value = lstg.RichText.createFromPool(self.font2.name, 10)
    set_common_text(self.hiscore_value, 200, 200, 200)
    self.hiscore_value:setAlignment("right", "top")

    self.score = lstg.RichText.createFromPool(self.font.name, 14)
    self.score:setText(i18n.get("ui/main", "UI", "score"))
    set_common_text(self.score, 255, 255, 255)

    self.score_value = lstg.RichText.createFromPool(self.font2.name, 10)
    set_common_text(self.score_value, 255, 255, 255)
    self.score_value:setAlignment("right", "top")

    --Populate text on first frame forced.
    self:frame()
end

function w:frame()
    local score = core.userdata.gamestate.score
    local hiscore = core.userdata.gamestate.hiscore

    if score ~= self.last_score then
        self.last_score = score
        self.score_value:setText(format_score(score))
    end
    self.score_value:update()

    if hiscore ~= self.last_hiscore then
        self.last_hiscore = hiscore
        self.hiscore_value:setText(format_score(hiscore))
    end
    self.hiscore_value:update()
end

function w:render()
    view:set("ui")
    local wo = world.current

    --HiScore
    self.hiscore:render(wo.scrr + 12, wo.scrt - 39)
    self.hiscore_value:render(wo.scrr + 216, wo.scrt - 28)

    --Score
    self.score:render(wo.scrr + 12, wo.scrt - 61)
    self.score_value:render(wo.scrr + 216, wo.scrt - 50)
end

function w:del()
    if self.font then
        self.font:destroy()
        self.font = nil
    end
    if self.font2 then
        self.font2:destroy()
        self.font2 = nil
    end

    if self.score then
        self.score:destroy()
        self.score = nil
    end
    if self.score_value then
        self.score_value:destroy()
        self.score_value = nil
    end
    if self.hiscore then
        self.hiscore:destroy()
        self.hiscore = nil
    end
    if self.hiscore_value then
        self.hiscore_value:destroy()
        self.hiscore_value = nil
    end
end

ui_manager:register_widget("score_ui", w)