local object = require("cyn.engine.objects")
local atlas = require("cyn.engine.resources.image_atlas")
local ani = require("cyn.engine.resources.animation")
local tex = require("cyn.engine.resources.texture")

---TODO: Allow for LuaLS to recognize this correctly in fire function
---@class yeva.bullet.list : string
local bullet_list = {
    "arrow_big",
    "gun_bullet",
    "butterfly",
    "square",
    "ball_mid",
    "mildew",
    "ellipse",

    "star_small",
    "star_big",
    "ball_big",
    "ball_small",
    "grain_a",
    "grain_b",

    "knife",
    "grain_c",
    "arrow_small",
    "kite",

    "star_big_b",
    "ball_mid_b",
    "arrow_mid",
    "heart",
    "knife_b",
    "ball_mid_c",
    "money",
    "ball_mid_d",

    "music",

    "silence",
}

lstg.IPC.register("list_bullets", function()
    return bullet_list
end)

local res_handler = {}

function res_handler:init()
    --#region bulletNew1
    self.bulletNew1 = atlas.from_file("assets/yeva/bullets/bulletNew1.png", true)
    self.arrow_big_imgs = self.bulletNew1:add_image_group("arrow_big", 0, 0, 129, 132, 1, 16, 2.5, 2.5):set_scale(1/8.25)
    self.gun_bullet_imgs = self.bulletNew1:add_image_group("gun_bullet", 129, 0, 123, 65, 1, 16, 2.5, 2.5):set_scale(1/7.69)
    self.butterfly_imgs = self.bulletNew1:add_image_group("butterfly", 252, 0, 250, 300, 1, 8, 4, 4):set_scale(1/9.38)
    self.square_imgs = self.bulletNew1:add_image_group("square", 502, 0, 179, 156, 1, 16, 3, 3):set_scale(1/11.19)
    self.ball_mid_imgs = self.bulletNew1:add_image_group("ball_mid", 681, 0, 206, 206, 1, 8, 4, 4):set_scale(1/6.44)
    self.mildew_imgs = self.bulletNew1:add_image_group("mildew", 1075, 0, 192, 192, 1, 16, 2, 2):set_scale(1/12)
    self.ellipse_imgs = self.bulletNew1:add_image_group("ellipse", 887, 0, 188, 114, 1, 8, 4.5, 4.5):set_scale(1/5.88)
    --#endregion

    --#region bulletNew3
    self.bulletNew3 = atlas.from_file("assets/yeva/bullets/bulletNew3.png", true)
    self.star_small_imgs = self.bulletNew3:add_image_group("star_small", 300, 0, 172, 173, 1, 16, 3, 3):set_scale(1/10.75)
    self.star_big_imgs = self.bulletNew3:add_image_group("star_big", 472, 0, 177, 180, 1, 8, 5.5, 5.5):set_scale(1/5.53)
    self.ball_big_imgs = self.bulletNew3:add_image_group("ball_big", 1213, 0, 211, 211, 1, 8, 8, 8):set_scale(1/6.59)
    self.ball_small_imgs = self.bulletNew3:add_image_group("ball_small", 1012, 0, 201, 201, 1, 16, 2, 2):set_scale(1/22.5)
    self.grain_a_imgs = self.bulletNew3:add_image_group("grain_a", 832, 0, 180, 99, 1, 16, 2.5, 2.5):set_scale(1/11.25)
    self.grain_b_imgs = self.bulletNew3:add_image_group("grain_b", 649, 0, 183, 84, 1, 16, 2.5, 2.5):set_scale(1/11.44)
    --#endregion

    --#region bulletNew4
    self.bulletNew4 = atlas.from_file("assets/yeva/bullets/bulletNew4.png", true)
    self.knife_imgs = self.bulletNew4:add_image_group("knife", 0, 0, 233, 135, 1, 8, 4, 4):set_scale(1/6)
    self.grain_c_imgs = self.bulletNew4:add_image_group("grain_c", 233, 0, 223, 126, 1, 16, 2.5, 2.5):set_scale(1/13.94)
    self.arrow_small_imgs = self.bulletNew4:add_image_group("arrow_small", 456, 0, 142, 74, 1, 16, 2.5, 2.5):set_scale(1/8)
    self.kite_imgs = self.bulletNew4:add_image_group("kite", 598, 0, 187, 119, 1, 16, 2.5, 2.5):set_scale(1/11.69)
    --#endregion

    --#region bulletNew5
    self.bulletNew5 = atlas.from_file("assets/yeva/bullets/bulletNew5.png", true)
    self.star_big_b_imgs = self.bulletNew5:add_image_group("star_big_b", 0, 0, 146, 146, 1, 8, 6, 6):set_scale(1/4.56)

    self.ball_mid_b_imgs = self.bulletNew5:add_image_group("ball_mid_b", 146, 0, 188, 188, 1, 8, 4, 4):set_scale(1/5.88):set_blendmode("mul+add"):set_color(lstg.Color(200, 200, 200, 200))

    self.arrow_mid_imgs = self.bulletNew5:add_image_group("arrow_mid", 334, 0, 154, 60, 1, 8, 3.5, 3.5):set_scale(1/4.81)
    self.heart_imgs = self.bulletNew5:add_image_group("heart", 488, 0, 158, 158, 1, 8, 9, 9):set_scale(1/4.94)
    self.knife_b_imgs = self.bulletNew5:add_image_group("knife_b", 877, 0, 233, 135, 1, 8, 3.5, 3.5):set_scale(1/6)
    self.ball_mid_c_imgs = self.bulletNew5:add_image_group("ball_mid_c", 1110, 0, 141, 141, 1, 8, 4, 4):set_scale(1/8.81)
    self.money_imgs = self.bulletNew5:add_image_group("money", 646, 0, 145, 145, 1, 8, 4, 4):set_scale(1/9.06)

    self.ball_mid_d_imgs = self.bulletNew5:add_image_group("ball_mid_d", 791, 0, 86, 86, 1, 8, 3, 3):set_scale(1/5.38):set_blendmode("mul+add")
    --#endregion

    --#region bulletNew8
    self.bulletNew8 = tex.from_file("assets/yeva/bullets/bulletNew8.png", true)
    self.music_imgs = {}
    for i = 1, 8 do
        self.music_imgs[i] = ani.from_texture(self.bulletNew8, 157 * (i - 1), 0, 157, 157, 1, 3, 8, 4, 4):set_scale(1/4.91)
    end
    --#endregion

    --#region bulletNew7
    self.bulletNew7 = atlas.from_file("assets/yeva/bullets/bulletNew7.png", true)
    self.silence_imgs = self.bulletNew7:add_image_group("silence", 0, 0, 126, 55, 1, 8, 4.5, 4.5):set_scale(1/3.94)
    --#endregion
end

---@return resource_base
function res_handler:get(name)
    return self[name .. "_imgs"]
end

res_handler:init()

---Objects have two mode: Legacy and New.
---- Legacy is the THlib way (multiple colors without blendmodes)
---- New mode uses blendmodes for more advanced visual effects (but requires more involved sheets).
---@class yeva.bullet : cyn.object
local M = object.define()

---@class yeva.bullet.colors : integer
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

---@param bullet_type yeva.bullet.list
---@param color yeva.bullet.colors|lstg.Color Changes display mode based on the argument's type
---@param x number
---@param y number
---@param vel number
---@param rot number
---@param indes boolean?
function M:init(bullet_type, color, x, y, vel, rot, indes)
    self.group = object.group.ENEMY_BULLET
    self.x = x
    self.y = y
    self.vel = vel
    self.rot = rot
    lstg.SetV(self, vel, rot, true)

    if indes then
        self.group = object.group.INDES
    end

    ---@type "direct"|"blend"
    self.type = nil
    if type(color) == "number" then
        self.type = "direct"

        local bullet_res = res_handler:get(bullet_type)
        if bullet_res.type == "imggrp" then
            bullet_res = bullet_res --[[@as resource.image_group]]
            self.img = bullet_res:get(color).name
        end
    else
        self.type = "blend"
    end
end

function M:frame()

end

function M:kill()

end

function M:del()

end

---@param bullet_type yeva.bullet.list
---@param color yeva.bullet.colors|lstg.Color Changes display mode based on the argument's type
---@param x number
---@param y number
---@param vel number
---@param rot number
---@param indes boolean?
function M.fire(bullet_type, color, x, y, vel, rot, indes)
    M:new(bullet_type, color, x, y, vel, rot, indes or false)
end

return M