local object = require("core.engine.objects")
local image_atlas = require("core.engine.resources.image_atlas")
local view = require("core.engine.viewport.view")

---@class content.players.reimu : core.player
local M = object.define(core.player)

function M:init()
    self.atlas = image_atlas.from_file("assets/players/reimu/reimu.png")
    core.player.init(self)
    self.bound = false

    local move = self:attach_behavior(core.player.b_move)
    move.speed = 4.5
    move.focus_speed = 2

    self.atlas:set_sampler_state("point+wrap")
    local b_anim = self:attach_behavior(core.player.b_animation)
    b_anim.imgs = {
        normal = self.atlas:add_animation_strip("n", 0, 0, 32, 48, 8),
        left = self.atlas:add_animation_strip("l", 0, 48, 32, 48, 8),
        right = self.atlas:add_animation_strip("r", 0, 96, 32, 48, 8),
    }

    local power = self:attach_behavior(core.player.b_power)
end

function M:frame()
    core.player.frame(self)
end

function M:render()
    view:set('world')
    core.player.render(self)
end

function M:del()
    core.player.del(self)

    if self.atlas then
        self.atlas:destroy()
        self.atlas = nil
    end
end

return M