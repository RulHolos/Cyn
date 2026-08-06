---@class content.bullet : core.object
local Bullet = core.object.define(core.object)

Bullet.Colors = {
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

function Bullet:init(bullet_type, color, indes)
    self.group = core.object.group.ENEMY_BULLET
    if indes then
        self.grouo = core.object.group.INDES
    end

    local idx
end

function Bullet:frame()

end

function Bullet:kill()

end

function Bullet:del()

end

function Bullet.fire()

end