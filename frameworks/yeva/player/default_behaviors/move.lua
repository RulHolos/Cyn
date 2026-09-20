local player = require("yeva.player")
local input = require("cyn.engine.input")
local world = require("cyn.engine.viewport.world")

---@class yeva.player.behavior.move : yeva.player.behavior
local M = player.behavior.define("move")

function M:init()
    self.speed = 4.5
    self.focus_speed = 2
    self.keep_player_in_bounds = true
    self.dx, self.dy = 0, 0
    self.slow_lh = 0
    self.is_focus = false
end

function M:frame()
    local dx, dy = 0, 0
    if input:is_down("focus") then
        self.is_focus = true
    else
        self.is_focus = false
    end

    local speed = self.is_focus and self.focus_speed or self.speed

    if input:is_down("up") then
        dy = dy + 1
    end
    if input:is_down("down") then
        dy = dy - 1
    end
    if input:is_down("left") then
        dx = dx - 1
    end
    if input:is_down("right") then
        dx = dx + 1
    end

    if dx * dy ~= 0 then
        speed = speed * math.SQRT2_2
    end

    dx = speed * dx
    dy = speed * dy
    self.dx, self.dy = dx, dy
    self.player.x = self.player.x + dx
    self.player.y = self.player.y + dy
    if self.keep_player_in_bounds then
        self.player.x = math.max(math.min(self.player.x, world.current.pr), world.current.pl)
        self.player.y = math.max(math.min(self.player.y, world.current.pt), world.current.pb)
    end

    self.slow_lh = self.slow_lh + ((self.is_focus and 1 or 0) - 0.5) * 0.3
    if self.slow_lh < 0 then
        self.slow_lh = 0
    elseif self.slow_lh > 1 then
        self.slow_lh = 1
    end
end

function M:render()
end

return M