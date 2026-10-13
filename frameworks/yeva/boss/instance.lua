local object = require("cyn.engine.objects")
local enemy = require("yeva.objs.enemy")

---Yeah that's just a boss object.

---@class yeva.boss.instance : yeva.enemy
local M = object.define(enemy)

function M:init()
    enemy.init(self)
    self.group = object.group.BOSS

    --[[
    In spell cards, have a function to spawn instances if they DON'T already exist.
    If they don't exist, spawn them out of bounds and move to the screen.]]
end

function M:frame()
    enemy.frame(self)
end

return M