local object = require("cyn.engine.objects")

---Objects have two mode: Legacy and New.
---- Legacy is the THlib way (multiple colors without blendmodes)
---- New mode uses blendmodes for more advanced visual effects.
---@class yeva.bullet : cyn.object
local M = object.define(object)

M.colors = {
    DEEP_RED = 1,
    RED = 2,
    DEEP_PURPLE = 3,
    PURPLE = 4,
    DEEP_BLUE = 5,
    BLUE = 6,
    ROYAL_BLUE = 7,
    CYAN = 8,
    DEEP_GREEN = 9,
    GREEN = 10,
    CHARTREUSE = 11,
    YELLOW = 12,
    GOLDEN_YELLOW = 13,
    ORANGE = 14,
    DEEP_GRAY = 15,
    GRAY = 16,
}

function M:init(bullet_type, color, indes)
    self.group = object.group.ENEMY_BULLET
    if indes then
        self.group = object.group.INDES
    end

    local idx
end

function M:frame()

end

function M:kill()

end

function M:del()

end

function M.fire()

end