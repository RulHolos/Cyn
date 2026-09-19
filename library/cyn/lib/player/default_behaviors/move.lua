---@class core.player.behavior.move : core.player.behavior
local M = core.player.behavior.define("move")

function M:init()
    self.speed = 4.5
    self.focus_speed = 2
    self.keep_player_in_bounds = true
    self.dx, self.dy = 0, 0
end

function M:frame()
    local is_focus = false
    local dx, dy = 0, 0
    if core.input:is_down("Focus") then
        is_focus = true
    end

    local speed = is_focus and self.focus_speed or self.speed

    if core.input:is_down("Up") then
        dy = dy + 1
    end
    if core.input:is_down("Down") then
        dy = dy - 1
    end
    if core.input:is_down("Left") then
        dx = dx - 1
    end
    if core.input:is_down("Right") then
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
        self.player.x = math.max(math.min(self.player.x, core.screen.world.pr), core.screen.world.pl)
        self.player.y = math.max(math.min(self.player.y, core.screen.world.pt), core.screen.world.pb)
    end
end

function M:render()
end

return M