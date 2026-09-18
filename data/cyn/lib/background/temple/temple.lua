local object = require("core.engine.objects")
local image = require("core.engine.resources.image")
local camera3d = require("core.engine.viewport.camera3d")
local view = require("core.engine.viewport.view")

---@class core.background.temple : core.background
local M = object.define(core.background)
core.background.temple = M

---@param img resource.image
---@param x number
---@param z number
---@param y1 number
---@param y2 number
---@param r number
local function draw_pillar(img, x, z, y1, y2, r)
    local eye = camera3d._state.eye
    local eyex = eye[1] - x
    local eyez = eye[3] - z
    local d = r * cos(22.5)
    local a = 0

    for _ = 1, 8 do
        if d * cos(a) * eyex + d * sin(a) * eyez - d * d > 0 then
            local blk = 255 * (((1 - cos(a) * math.SQRT2_2 + sin(a) * math.SQRT2_2) * 0.5) + 0.0625)
			img:set_color(lstg.Color(255, blk, blk, blk))
            img:render_4v(
                x + r * cos(a - 22.5), y1, z + r * sin(a - 22.5),
				x + r * cos(a + 22.5), y1, z + r * sin(a + 22.5),
				x + r * cos(a + 22.5), y2, z + r * sin(a + 22.5),
				x + r * cos(a - 22.5), y2, z + r * sin(a - 22.5))
        end
        a = a + 45
    end
end

function M:init()
    core.background.init(self, false)

    self.res_road = image.from_file('core/lib/background/temple/road.png')
    self.res_ground = image.from_file('core/lib/background/temple/ground.png')
    self.res_pillar = image.from_file('core/lib/background/temple/pillar.png')

    camera3d:set({
        eye = { x = 0, y = 2.5, z = -4 },
        at = { x = 0, y = 0, z = 0  },
        up = { x = 0, y = 1, z = 0  },
        fov = 0.6,
        depth = { 1, 10 },
        fog = { start = 5, finish = 10, color = lstg.Color(0xFFFFFFFF) },
    })

    self.speed = 0.01
    self.z = 0
end

function M:frame()
    self.z = self.z + self.speed
end

function M:render()
    view:set("3d")

    for j = 0, 4 do
        local dz = j * 2 - self.z % 2
        self.res_ground:render_4v(0.5,0,dz,  2.5,0,dz,  2.5,0,-2+dz,  0.5,0,-2+dz)
        self.res_ground:render_4v(-0.5,0,dz,  -2.5,0,dz,  -2.5,0,-2+dz,  -0.5,0,-2+dz)
        self.res_road:render_4v(-1,0,dz,  1,0,dz,  1,0,-2+dz,  -1,0,-2+dz)
    end
    for j = 3, -1, -1 do
        local dz = j * 2 - self.z % 2
        draw_pillar(self.res_pillar, 0.85, dz + 0.2, 1.8, 0, 0.15)
        draw_pillar(self.res_pillar, -0.85, dz + 0.2, 1.8, 0, 0.15)
    end

    view:set("world")
end

function M:del()
    self.res_road:destroy()
    self.res_ground:destroy()
    self.res_pillar:destroy()
end

return M
