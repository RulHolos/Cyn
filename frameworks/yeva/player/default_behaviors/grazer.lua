local player = require("yeva.player")
local input = require("cyn.engine.input")
local world = require("cyn.engine.viewport.world")
local view = require("cyn.engine.viewport.view")
local image_group = require("cyn.engine.resources.image_atlas")
local img = require("cyn.engine.resources.image")

---@class yeva.player.behavior.grazer : yeva.player.behavior
local M = player.behavior.define("grazer")

function M:init()
    self.layer = 100

    self.aura = 0
    self.aura_d = 0
    self._slow_timer = 0
    self._pause = 0
    self._collectCounter = 0

    ---@type yeva.player.behavior.move?
    self.move = self.player:get_behavior("move")
    assert(self.move ~= nil, "A move behavior must be attached for this stock behavior to work.")

    ---@type yeva.player.behavior.death?
    self.death = self.player:get_behavior("death")
    assert(self.death ~= nil, "A death behavior must be attached for this stock behavior to work.")

    ---@type yeva.player.behavior.collect?
    self.collect = self.player:get_behavior("collect")
    assert(self.collect ~= nil, "A collect behavior must be attached for this stock behavior to work.")

    local alpha80 = lstg.Color(0x80FFFFFF)

    --This is a default visual. You can change that no problem.
    self.collect_ring = image_group.from_file("general/white.png", true)
    self.collect_ring:add_image_group("item_collect_ring", 0, 0, 110, 62, 1, 10)
    for i = 1, 10 do
        local img = self.collect_ring:get_image("item_collect_ring" .. i)
        if img then
            img:set_color(alpha80)
        end
    end

    self.player_aura = img.from_file("assets/yeva/players/player_aura.png", true)
    --self.player_aura:set_sampler_state("point+clamp")
end

function M:frame()
    if not lstg.IsValid(self.player) then
        lstg.MsgBoxWarn("Player invalid. Grazer initialized before player. How.")
        return
    end

    local alive = self.death:has_control()
    if alive then
        self.hide = self.player.hide
    end
    if self.move.is_focus then
        self._slow_timer = math.min(self._slow_timer + 1, 30)
        self._collectCounter = math.min(self._collectCounter + 1, 20)
    else
        self._slow_timer = 0
        self._collectCounter = math.max(self._collectCounter - 1, 0)
    end
    self.collect:update_collect_ring_radius(self._collectCounter)

    if self._pause == 0 then
        self.aura = self.aura + 1.5
    end
    self._pause = math.max(0, self._pause - 1)
    self.aura_d = 180 * cos(90 * self._slow_timer / 30) ^ 2
end

local semi_transparent = lstg.Color(0xC0FFFFFF)
local transparent = lstg.Color(0x00FFFFFF)

function M:render()
    if not lstg.IsValid(self.player) then
        return
    end

    self.player_aura:set_color(semi_transparent)
    self.player_aura:render(self.player.x, self.player.y, -self.aura + self.aura_d, self.move.slow_lh)
    self.player_aura:set_color(semi_transparent * self.move.slow_lh + transparent * (1 - self.move.slow_lh))
    self.player_aura:render(self.player.x, self.player.y, self.aura, 2 - self.move.slow_lh)

    if self.collect:get_collect_ring_radius() >= 8 then
        self.collect_ring:render_ring("item_collect_ring", self.player.x, self.player.y,
            self.collect:get_collect_ring_radius() - 8,
            self.collect:get_collect_ring_radius(),
            -self.player.timer,
            50, 10
        )
    end
end

function M:del()
    if self.collect_ring then
        self.collect_ring:destroy()
        self.collect_ring = nil
    end

    if self.player_aura then
        self.player_aura:destroy()
        self.player_aura = nil
    end
end

return M