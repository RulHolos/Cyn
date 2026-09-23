local image_atlas = require("cyn.engine.resources.image_atlas")
local audio_manager = require("cyn.engine.resources.audio_manager")
local object = require("cyn.engine.objects")
local world = require("cyn.engine.viewport.world")
local player = require("yeva.player")

---@class yeva.objs.item : cyn.object
---@field target cyn.object Most likely always the player
---@field collect fun(self:yeva.objs.item, other)? Called when the item is collected by the player. `other` is the player instance.
local item = object.define()

---Note: This item atlas is never deleted anywhere in code. See if this becomes an issue later. Probably not.
local item_atlas = image_atlas.from_file("assets/yeva/items/item.png")
item_atlas:set_sampler_state("point+wrap")

local item_img = item_atlas:add_image_group("item_", 0, 0, 32, 32, 2, 6, 8, 8)
local item_img_up = item_atlas:add_image_group("item_up_", 64, 0, 32, 32, 2, 6)

---Defines an empty item object.
---@param x number X coords
---@param y number Y coords
---@param t integer Index of the item type. Used for rendering the image.
---@param v number? Initial speed of the item. Default to 1.5.
---@param angle number? Initial angle of the item. Default to 90.
function item:init(x, y, t, v, angle)
    x = math.clamp(x, world.current.l + 8, world.current.r - 8)
    self.x, self.y = x, y
    angle = angle or 90
    v = v or 1.5
    lstg.SetV(self, v, angle)
    self.v = v
    self.group = object.group.ITEM
    self.layer = object.layer.ITEMS
    self.bound = false
    self.index = t
    self.attract = 0
end

function item:frame()
    --local player = self.target
    if self.timer < 24 then
        self.rot = self.rot + 45
        self.hscale = (self.timer + 25) / 48
        self.vscale = self.hscale
        if self.timer == 22 then
            self.vy = math.min(self.v, 2)
            self.vx = 0
        end
    elseif self.attract > 0 then
        --local a = lstg.Angle(self, player)
        --self.vx = self.attract * cos(a) + player.dx * 0.5
        --self.vy = self.attract * sin(a) + player.dy * 0.5
    elseif self.attract == 0 then
        self.vy = math.max(self.dy - 0.03, -1.7)
        --TODO: Is on graze: self.vy = max(self.vy, -0.5)
    else
        self.vy = math.max(self.dy - 0.03, -0.05)
    end
    if self.y < world.current.boundb then
        lstg.Del(self)
    end
    if self.attract >= 8 then
        self.collected = true
    end
end

function item:render()
    if self.y > world.current.t then
        item_img_up[self.index]:render(self.x, world.current.t - 8)
    else
        item_img[self.index]:render(self.x, self.y, self.rot)
    end
end

---Handles collision with player. Calls the item's collect function.
---
---Usually, item's "collect" functions define a signal group as `item.collect:power` for example. `item.collect:` followed by the object's file or class name. Easily searchable.
---@param other cyn.object
function item:colli(other)
    if other == player.instance then
        if self.class.collect then
            self.class.collect(self, other)
        end
        lstg.Kill(self)
        audio_manager.play_se("item00", 0.3, self.x / (world._default.play.w / 2))
    end
end

return item