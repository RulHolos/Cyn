local object = require("cyn.engine.objects")
local task = require("cyn.foundation.task")
local tween = require("cyn.foundation.tween")
local audio = require("cyn.engine.resources.audio_manager")
local screen = require("cyn.engine.viewport.screen")

---@class yeva.enemy : cyn.object
local M = object.define()

function M:init(x, y, hp, invincible, auto_delete, style, drop)
    self.x, self.y = x, y
    self.bound = auto_delete
    self.max_hp, self.hp = hp, hp
    self.style = style
    self.drop = drop or {}
    self.invincible = invincible
    ---@type cyn.object[]
    self.servants = {}

    if invincible then
        self.group = object.group.IMMORTAL_ENEMY
    else
        self.group = object.group.ENEMY
    end
end

function M:frame()
    task.exec(self)
    tween.Do(self)
    if self.hp <= 0 then
        lstg.Kill(self)
    end
end

function M:render()
end

---@param other cyn.object
function M:colli(other)
    ---@diagnostic disable-next-line: undefined-field
    local dmg = other.dmg or nil
    ---@diagnostic disable-next-line: undefined-field
    local killflag = other.killflag or nil

    if dmg then
        dmg = math.abs(dmg)
        self:damage(dmg)
    end

    if not killflag then
        lstg.Kill(other)
    end

    if self.hp > 60 then
        if self.hp > self.max_hp * 0.2 then
            audio.play_se("damage00", 0.4, self.x / screen.width)
        else
            audio.play_se("damage01", 0.6, self.x / screen.width)
        end
    else
        audio.play_se("damage00", 0.35, self.x / screen.width)
    end
end

function M:damage(dmg)
    if self.invincible then
        return
    end

    dmg = math.abs(dmg)
    self.hp = math.clamp(self.hp - dmg, 0, self.max_hp)
end

function M:kill()
    for _, unit in ipairs(self.servants) do
        lstg.Kill(unit)
    end
end

function M:del()
    for _, unit in ipairs(self.servants) do
        lstg.Del(unit)
    end
end

return M