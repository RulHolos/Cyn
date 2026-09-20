local player = require("yeva.player")
local input = require("cyn.engine.input")
local world = require("cyn.engine.viewport.world")

---@class cyn.player.behavior.move : yeva.player.behavior
local M = player.behavior.define("move")

function M:init()
    self.speed = 4.5
    self.focus_speed = 2
    self.keep_player_in_bounds = true
    self.dx, self.dy = 0, 0
end

function M:frame()
    local is_focus = false
    local dx, dy = 0, 0
    if input:is_down("focus") then
        is_focus = true
    end

    local speed = is_focus and self.focus_speed or self.speed

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
end

function M:render()
end

return M