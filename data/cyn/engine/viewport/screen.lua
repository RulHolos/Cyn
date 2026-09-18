local world = require("cyn.engine.viewport.world")
local world_camera = require("cyn.engine.viewport.world_camera")
local settings = require("cyn.foundation.settings_manager")

---@class cyn.viewport.screen
local M = {
    LANDSCAPE_W = 640,
    LANDSCAPE_H = 480,
    PORTRAIT_W = 396,
    PORTRAIT_H = 528,

    width = 0,
    height = 0,
    scale = 0,
    dx = 0,
    dy = 0,

    scale_3d = 0,

    halfW = 0,
    halfH = 0,

    ---@type cyn.viewport.world.data
    ---@diagnostic disable-next-line: missing-fields
    world = {},
}

---Set up the screen params. Call when the window is resized.
---@param resetWorld boolean? If false, skips resetting cyn.world.
function M:setup(resetWorld)
    local settings = settings:get()
    local landscape = settings.graphics_system.width > settings.graphics_system.height

    self.width = landscape and self.LANDSCAPE_W or self.PORTRAIT_W
    self.height = landscape and self.LANDSCAPE_H or self.PORTRAIT_H

    local hScale = settings.graphics_system.width / self.width
    local vScale = settings.graphics_system.height / self.height
    self.scale = math.min(hScale, vScale)

    local aspect = settings.graphics_system.width / settings.graphics_system.height
    if aspect >= (self.width / self.height) then
        self.dx = (settings.graphics_system.width - self.width * self.scale) / 2
        self.dy = 0
    else
        self.dx = 0
        self.dy = (settings.graphics_system.height - self.height * self.scale) / 2
    end

    self.scale_3d = 0.007 * self.scale

    if resetWorld == true then
        if landscape then
            world:reset()
            world_camera:reset()
        else
            self.world = {
                l = -192, r = 192, b = -224, t = 224,
                boundl = -224, boundr = 224, boundb = -256, boundt = 256,
                scrl = 6, scrr = 390, scrb = 16, scrt = 464,
                pl = -192, pr = 192, pb = -224, pt = 224,
                world = 0xFFFF,
            }
            lstg.SetBound(self.world.boundl, self.world.boundr, self.world.boundb, self.world.boundt)
            world_camera:reset()
        end
    end

    lstg.SetResolution(settings.graphics_system.width, settings.graphics_system.height)

    self.halfW = self.width / 2
    self.halfH = self.height / 2

    lstg.Log(LOG.DEBUG, ("Screen setup: %dx%d(%dx%d) (scale=%.2f, dx=%.2f, dy=%.2f)")
        :format(self.width, self.height, settings.graphics_system.width, settings.graphics_system.height, self.scale, self.dx, self.dy))
end

---Applies the current screen settings, including resolution and video mode.
function M:apply()
    local settings = settings:get()
    local gs = settings.graphics_system
    local mode = gs.fullscreen and "fullscreen" or "windowed"
    local ok = lstg.ChangeVideoMode(gs.width, gs.height, mode, gs.vsync)

    --TODO: Should be good enough to avoid cyclic references. Check if it's really correct
    local view = require("cyn.engine.viewport.view")

    if ok then
        self:setup(false)
        view:set(view:get())
    end
end

return M