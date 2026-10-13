local object = require("cyn.engine.objects")
local image_atlas = require("cyn.engine.resources.image_atlas")
local img = require("cyn.engine.resources.image")
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
local b_miss = require(patch .. "miss")
local b_supports = require(patch .. "supports")

---@param self yeva.player.behavior.supports.support
local function default_supports_frame(self)
    self.rot = self.parent.player.timer * 3
end

--#endregion

---@class content.players.reimu : yeva.player
local M = object.define(player)

function M:init()
    player.init(self)
    self.name = "Reimu"
    self.full_name = "Reimu Hakurei"

    self.atlas = image_atlas.from_file("assets/players/reimu/reimu.png")
    self.atlas:set_sampler_state("point+wrap")
    self.bound = false

    local death = self:attach_behavior(b_death)

    local move = self:attach_behavior(b_move)
    move.speed = 4.5
    move.focus_speed = 2

    local b_anim = self:attach_behavior(b_animation)
    b_anim.imgs = {
        normal = self.atlas:add_animation_strip("n", 0, 0, 32, 48, 8),
        left = self.atlas:add_animation_strip("l", 0, 48, 32, 48, 8),
        right = self.atlas:add_animation_strip("r", 0, 96, 32, 48, 8),
    }

    local power = self:attach_behavior(b_power)
    local collect = self:attach_behavior(b_collect)
    local grazer = self:attach_behavior(b_grazer)
    local miss = self:attach_behavior(b_miss)

    --#region Supports
    ---@type yeva.player.behavior.supports
    local supports = self:attach_behavior(b_supports)

    local orb_img = self.atlas:add_image("orb", 64, 144, 16, 16)

    --Each entry is { ux, uy, fx, fy }.
    local orb_positions = {
        nil,
        { { 0, 36, 0, 24 } },
        { { -32, 0, -12, 24 }, { 32, 0, 12, 24 } },
        { { -32, -8, -16, 20 }, { 0, -32, 0, 28 }, { 32, -8, 16, 20 } },
        { { -36, -12, -16, 20 }, { -16, -32, -6, 28 }, { 16, -32, 6, 28 }, { 36, -12, 16, 20 } },
    }

    supports:make_formation(
        { { power = 0, count = 0 }, { power = 100, count = 1 }, { power = 200, count = 2 }, { power = 300, count = 3 }, { power = 400, count = 4 } },
        function(index, count, focused)
            local entry = orb_positions[count + 1][index]
            if focused then
                return { x = entry[3], y = entry[4] }
            else
                return { x = entry[1], y = entry[2] }
            end
        end,
        function(inst)
            inst.img = orb_img
            inst.frame = default_supports_frame
        end
    )

    --#endregion

    self:set_behavior_deps()
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