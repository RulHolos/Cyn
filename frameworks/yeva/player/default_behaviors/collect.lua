local player = require("yeva.player")
local input = require("cyn.engine.input")
local world = require("cyn.engine.viewport.world")
local image_group = require("cyn.engine.resources.image_atlas")
local audio_manager = require("cyn.engine.resources.audio_manager")
local object = require("cyn.engine.objects")
local ease_out_quad = require("cyn.global_scripts.easing").outQuad
local item = require("yeva.objs.items")

---@class yeva.player.behavior.collect : yeva.player.behavior
local M = player.behavior.define("collect")

function M:init()
    self.collect_ring_radius = 180
    self.current_collect_ring_radius = self.collect_ring_radius

    self.collect_line = 96

    ---Easing function for the collect ring radius animation<br>
    ---Defaults to outQuad
    ---@type fun(t: number): number
    self.ease_function = ease_out_quad

    ---@type yeva.player.behavior.move?
    self.move = self.player:get_behavior("move")
    assert(self.move ~= nil, "A move behavior must be attached for this stock behavior to work.")

    ---@type yeva.player.behavior.death?
    self.death = self.player:get_behavior("death")
    assert(self.death ~= nil, "A death behavior must be attached for this stock behavior to work.")
end

---Sets the collect ring radius.
---@param radius number
function M:set_collect_ring_radius(radius)
    self.collect_ring_radius = radius
end

function M:get_collect_ring_radius()
    return self.current_collect_ring_radius
end

function M:update_collect_ring_radius(timer)
    ---Why / 20? I don't remember. This whole class is straight adapted from BerryLib, what was I thinking...
    timer = timer / 20

    self.current_collect_ring_radius = self.ease_function(timer) * self.collect_ring_radius
end

function M:frame()
    if not self.death:has_control() then
        return
    end

    if self.player.y > self.collect_line then
        for _, o in lstg.ObjList(object.group.ITEM) do
            local flag = false
            if o.attract < 8 then
                flag = true
            elseif o.attract == 8 and o.target ~= self.player then
                if (not o.target) or o.target.y < self.player.y then
                    flag = true
                end
            end
            if flag then
                o.attract = 8
                o.target = self.player
            end
        end
    else
        if self.move.is_focus then
            for _, o in lstg.ObjList(object.group.ITEM) do
                if lstg.Dist(self.player, o) < self:get_collect_ring_radius() then
                    if o.attract < 8 then
                        o.attract = math.max(o.attract, 8)
                        o.target = self.player
                    end
                end
            end
        else
            for _, o in lstg.ObjList(object.group.ITEM) do
                if lstg.Dist(self.player, o) < 24 then
                    if o.attract < 3 then
                        o.attract = math.max(o.attract, 3)
                        o.target = self.player
                    end
                end
            end
        end
    end
end

return M