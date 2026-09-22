local object = require("cyn.engine.objects")
local image_atlas = require("cyn.engine.resources.image_atlas")
local view = require("cyn.engine.viewport.view")
local player = require("yeva.player")

--#region Behaviors

local patch = "yeva.player.default_behaviors."
local b_death = require(patch .. "death")
local b_collect = require(patch .. "collect")
local b_move = require(patch .. "move")
local b_animation = require(patch .. "animation")
local b_power = require(patch .. "power")
local b_grazer = require(patch .. "grazer")

--#endregion

---@class content.players.reimu : yeva.player
local M = object.define(player)

function M:init()
    self.name = "Reimu"
    self.full_name = "Reimu Hakurei"

    self.atlas = image_atlas.from_file("assets/players/reimu/reimu.png")
    player.init(self)
    self.bound = false

    --Should always be the first behavior attached cuz many depends on it.
    local death = self:attach_behavior(b_death)

    local move = self:attach_behavior(b_move)
    move.speed = 4.5
    move.focus_speed = 2

    self.atlas:set_sampler_state("point+wrap")
    local b_anim = self:attach_behavior(b_animation)
    b_anim.imgs = {
        normal = self.atlas:add_animation_strip("n", 0, 0, 32, 48, 8),
        left = self.atlas:add_animation_strip("l", 0, 48, 32, 48, 8),
        right = self.atlas:add_animation_strip("r", 0, 96, 32, 48, 8),
    }

    local power = self:attach_behavior(b_power)
    local collect = self:attach_behavior(b_collect)
    local grazer = self:attach_behavior(b_grazer)
end

function M:frame()
    player.frame(self)
end

function M:render()
    view:set('world')
    player.render(self)
end

function M:del()
    player.del(self)

    if self.atlas then
        self.atlas:destroy()
        self.atlas = nil
    end
end

player.register_player(M, "Reimu", "Reimu Hakurei")

return M