---@class core.object.group
local groups = {
    GHOST = 0,
    ENEMY_BULLET = 1,
    ENEMY = 2,
    IMMORTAL_ENEMY = 3,
    PLAYER_BULLET = 4,
    PLAYER = 5,
    INDES = 6,
    ITEM = 7,
    SPELL = 8,
    BOSS = 9,
}

---@class core.object.layer
local layers = {
    BACKGROUND = -900,
    ENEMIES = -800,
    PLAYER_BULLETS = -700,
    PLAYER = -600,
    ITEMS = -500,
    ENEMY_BULLETS = -400,
    ENEMY_BULLETS_EF = -300,
    EFFECTS = -200,
    FOREGROUND = -100,
    TOP = 0,
}

return { groups, layers }