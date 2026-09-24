local player = require("yeva.player")

---@class yeva.player.behavior.animation.imgs.named
---@field normal resource.image[] Neutral cycling frames.
---@field left resource.image[] & { ani: integer? } Left frames: [1..n-ani] transition, [n-ani+1..n] max-lean loop.
---@field right resource.image[] & { ani: integer? } Right frames: [1..n-ani] transition, [n-ani+1..n] max-lean loop.

---@class yeva.player.behavior.animation : yeva.player.behavior
local M = player.behavior.define("animation")

function M:init()
    self.blend = ""
    ---@type resource.image?
    self.img = nil
    ---@type resource.image[] | yeva.player.behavior.animation.imgs.named
    self.imgs = {}
    self.a, self.r, self.g, self.b = 255, 255, 255, 255
    self.ani_interval = 8
    self.max_left = 6
    self.max_right = 6
    self.lean = 0
end

function M:get_deps()
    self.move = self.player:get_behavior("move")
    assert(self.move ~= nil, "A move behavior must be attached for this stock behavior to work.")
end

function M:frame()
    local dx = self.move.dx
    local target =
        dx > 0.5 and 1 or
        dx < -0.5 and -1 or
        0

    self.lean = self.lean + target
    self.lean = math.max(-self.max_left, math.min(self.lean, self.max_right))

    if target == 0 then
        if self.lean > 0 then
            self.lean = math.max(0, self.lean - 1)
        elseif self.lean < 0 then
            self.lean = math.min(0, self.lean + 1)
        end
    end

    local imgs = self.imgs
    local ani = math.floor(self.player.timer / self.ani_interval)
    local lean = self.lean
    local img

    if imgs.normal or imgs.left or imgs.right then
        if lean == 0 then
            local frames = imgs.normal
            img = frames[ani % #frames + 1]
        elseif lean == -self.max_left then
            local frames = imgs.left
            local count = #frames
            local loop = math.floor(count / 2)
            img = frames[ani % loop + (count - loop) + 1]
        elseif lean == self.max_right then
            local frames = imgs.right
            local count = #frames
            local loop = math.floor(count / 2)
            img = frames[ani % loop + (count - loop) + 1]
        elseif lean < 0 then
            img = imgs.left[-lean]
        else
            img = imgs.right[lean]
        end
    else
        if lean == 0 then
            img = imgs[ani % 8 + 1]
        elseif lean < 0 then
            img = imgs[ani % 6 + 11]
        else
            img = imgs[ani % 6 + 19]
        end
    end

    self.img = img
end

function M:render()
    if not self.img then return end
    local blend = self.blend or ""
    local a, r, g, b = self.a or 255, self.r or 255, self.g or 255, self.b or 255

    local color = self.player.protect % 3 == 1 and lstg.Color(a, 0, 0, b) or lstg.Color(a, r, g, b)
    lstg.SetImageState(self.img.name, blend, color)
    lstg.Render(self.img.name, self.player.x, self.player.y, self.player.rot)
end

function M:debug()
    local success, value = ImGui.InputInt("Animation Interval (frames)", self.ani_interval, 1, math.INF)
    if success then
        self.ani_interval = math.clamp(value, 1, math.INF)
    end
end

return M