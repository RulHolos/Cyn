--=========================================
-- Screen and viewport management
--
--Screen
--World
--WorldCamera
--Camera3d
--View
--Coords
--=========================================

lstg.CreateRenderTarget("rt:screen-white", 64, 64)
lstg.LoadImage("img:screen-white", "rt:screen-white", 16, 16, 16, 16)

local function refreshWhiteTarget()
    lstg.PushRenderTarget("rt:screen-white")
    lstg.RenderClear(lstg.Color(255, 255, 255, 255))
    lstg.PopRenderTarget()
end

local function drawRect(l, r, b, t, color)
    refreshWhiteTarget()
    lstg.SetImageState("img:screen-white", "", color)
    lstg.RenderRect("img:screen-white", l, r, b, t)
end

-------------------------------------------------------------
--- Screen

---@class core.screen
core.screen = {
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

    ---@type core.world.data
    ---@diagnostic disable-next-line: missing-fields
    world = {},
}
core.screen.__index = core.screen

---Set up the screen params. Call when the window is resized.
---@param resetWorld boolean? If false, skips resetting core.world.
function core.screen:setup(resetWorld)
    local landscape = core.userdata.settings.graphics_system.width > core.userdata.settings.graphics_system.height

    self.width = landscape and self.LANDSCAPE_W or self.PORTRAIT_W
    self.height = landscape and self.LANDSCAPE_H or self.PORTRAIT_H

    local hScale = core.userdata.settings.graphics_system.width / self.width
    local vScale = core.userdata.settings.graphics_system.height / self.height
    self.scale = math.min(hScale, vScale)

    local aspect = core.userdata.settings.graphics_system.width / core.userdata.settings.graphics_system.height
    if aspect >= (self.width / self.height) then
        self.dx = (core.userdata.settings.graphics_system.width - self.width * self.scale) / 2
        self.dy = 0
    else
        self.dx = 0
        self.dy = (core.userdata.settings.graphics_system.height - self.height * self.scale) / 2
    end

    self.scale_3d = 0.007 * self.scale

    if resetWorld ~= false then
        if landscape then
            core.world:reset()
            core.world_camera:reset()
        else
            core.world = {
                l = -192, r = 192, b = -224, t = 224,
                boundl = -224, boundr = 224, boundb = -256, boundt = 256,
                scrl = 6, scrr = 390, scrb = 16, scrt = 464,
                pl = -192, pr = 192, pb = -224, pt = 224,
            }
            lstg.SetBound(core.world.boundl, core.world.boundr, core.world.boundb, core.world.boundt)
            core.world_camera:reset()
        end
    end

    lstg.SetResolution(core.userdata.settings.graphics_system.width, core.userdata.settings.graphics_system.height)

    self.halfW = self.width / 2
    self.halfH = self.height / 2

    lstg.Log(LOG.DEBUG, ("Screen setup: %dx%d(%dx%d) (scale=%.2f, dx=%.2f, dy=%.2f)")
        :format(self.width, self.height, core.userdata.settings.graphics_system.width, core.userdata.settings.graphics_system.height, self.scale, self.dx, self.dy))
end

function core.screen:apply()
    local gs = core.userdata.settings.graphics_system
    local mode = gs.fullscreen and "fullscreen" or "windowed"
    local ok = lstg.ChangeVideoMode(gs.width, gs.height, mode, gs.vsync)
    if ok then
        self:setup(false)
        core.view:set(core.view:get())
    end
end

-------------------------------------------------------------
--- World

---@class core.world.data
---@field l number
---@field r number
---@field b number
---@field t number
---@field boundl number
---@field boundr number
---@field boundb number
---@field boundt number
---@field scrl number
---@field scrr number
---@field scrb number
---@field scrt number
---@field pl number
---@field pr number
---@field pb number
---@field pt number
---@field world integer

---@class core.world
core.world = {
    _default = {
        play = { x = 0, y = 0, w = 384 - 16, h = 448 - 16 },
        bound = 32,
        scroll = { x = 32, y = 16, w = 384, h = 448 },
        mask = 0xFFFF,
    }
}
core.world.__index = core.world

local _WORLD_DEFAULT = {
    play = { x = 0, y = 0, w = 384, h = 448 - 16 },
    bound = 32,
    scroll = { x = 32, y = 16, w = 384, h = 448 },
    mask = 0xFFFF,
}

---Converts a table into raw world.
---@param cfg table { player, bound, scroll, mask }
---@return core.world.data
local function buildWorld(cfg)
    local pw, ph = cfg.play.w, cfg.play.h
    local sw, sh = cfg.scroll.w, cfg.scroll.h
    local b = cfg.bound
    local s = cfg.scroll
    return {
        l = -sw * 0.5, r = sw * 0.5,
        b = -sh * 0.5, t = sh * 0.5,
        boundl = -pw * 0.5 - b, boundr = pw * 0.5 + b,
        boundb = -ph * 0.5 - b, boundt = ph * 0.5 + b,
        scrl = s.x, scrr = s.x + s.w,
        scrb = s.y, scrt = s.y + s.h,
        pl = -pw * 0.5, pr = pw * 0.5,
        pb = -ph * 0.5, pt = ph * 0.5,
        world = cfg.mask,
    }
end

function core.world:reset()
    core.screen.world = buildWorld(self._default)
    lstg.SetBound(core.screen.world.boundl, core.screen.world.boundr, core.screen.world.boundb, core.screen.world.boundt)
end

function core.world:hardReset()
    local d = {}
    for k, v in pairs(_WORLD_DEFAULT) do
        d[k] = type(v) == "table" and (function(t)
            local c = {}
            for kk, vv in pairs(t) do
                c[kk] = vv
            end
            return c
        end)(v) or v
    end
    self._default = d
    self:reset()
end

---Apply a new world layout immediately. (NOTE: Does not change defaults)
---Use `core.world:set_default()` if you want to survive a world reset.
---@param cfg { play:{x:number,y:number,w:number,h:number}, bound:number, scroll:{x:number,y:number,w:number,h:number}, mask:number? }
function core.world:apply(cfg)
    cfg.bound = cfg.bound or 32
    cfg.mask = cfg.mask or 0xFFFF
    cfg.scroll = cfg.scroll or { x = cfg.play.x, y = cfg.play.y, w = cfg.play.w, h = cfg.play.h }
    local w = buildWorld(cfg)
    for k, v in pairs(w) do
        core.screen.world[k] = v
    end
    lstg.SetBound(core.screen.world.boundl, core.screen.world.boundr, core.screen.world.boundb, core.screen.world.boundt)
end

---Changes the default world layout. Survives world resets.
---@param cfg { play:{x:number,y:number,w:number,h:number}, bound:number, scroll:{x:number,y:number,w:number,h:number}, mask:number? }
function core.world:set_default(cfg)
    cfg.bound = cfg.bound or 32
    cfg.mask = cfg.mask or 0xFFFF
    cfg.scroll = cfg.scroll or { x = cfg.play.x, y = cfg.play.y, w = cfg.play.w, h = cfg.play.h }
    core.world._default = cfg
end

---Returns a COPY of the current world data.
---@return core.world.data
function core.world:get()
    local copy = {}
    for k, v in pairs(core.screen.world) do
        copy[k] = v
    end
    return copy
end

function core.world:get_default()
    local copy = {}
    for k, v in pairs(core.world._default) do
        copy[k] = type(v) == "table" and (function(t)
            local c = {}
            for kk, vv in pairs(t) do c[kk] = vv end
            return c
        end)(v) or v
    end
    return copy
end

-------------------------------------------------------------
--- World Camera

---@class core.world_camera
core.world_camera = {
    _state = {
        cx = 0, cy = 0, -- Centre offset (pan)
        sx = 1, sy = 1, -- Scale (zoom)
        dx = 0, dy = 0, -- Translation (shake)
    }
}
core.world_camera.__index = core.world_camera

function core.world_camera:reset()
    self._state = {
        cx = 0, cy = 0,
        sx = 1, sy = 1,
        dx = 0, dy = 0,
    }
end

---Set the camera params. All fields are optional.
---@param cfg { center:{x:number,y:number}?, scale:{x:number,y:number}?, offset:{x:number,y:number}? }
function core.world_camera:set(cfg)
    local s = self._state
    if cfg.center then s.cx, s.cy = cfg.center.x or s.cx, cfg.center.y or s.cy end
    if cfg.scale then s.sx, s.sy = cfg.scale.x or s.sx, cfg.scale.y or s.sy end
    if cfg.offset then s.dx, s.dy = cfg.offset.x or s.dx, cfg.offset.y or s.dy end
end

---Moves the camera to an absolute world-space position (the given point becomes the screen centre).
---@param x number
---@param y number
function core.world_camera:move_to(x, y)
    self:set({ center = { x = x, y = y } })
end

---Pan the camera by a relative amount. Does not affect scale or offset.
---@param dx number
---@param dy number
function core.world_camera:pan(dx, dy)
    self:set({ center = { x = self._state.cx + dx, y = self._state.cy + dy } })
end

---Returns a COPY of the current camera state.
---@return table
function core.world_camera:get()
    local s = self._state
    return { center = { x = s.cx, y = s.cy }, scale = { x = s.sx, y = s.sy }, offset = { x = s.dx, y = s.dy } }
end

---Compute the world-space viewport after applying camera transform. Used by view.
---@return number l, number r, number b, number t
---@private
function core.world_camera:getTransformedBounds()
    local s = self._state
    local w = core.screen.world
    local ww = (w.r - w.l) / s.sx
    local wh = (w.t - w.b) / s.sy
    local ox = s.dx / s.sx
    local oy = s.dy / s.sy
    local l = s.cx - ww * 0.5 + ox
    local r = s.cx + ww * 0.5 + ox
    local b = s.cy - wh * 0.5 + oy
    local t = s.cy + wh * 0.5 + oy
    return l, r, b, t
end

-------------------------------------------------------------
--- 3D Camera
--- Stores perspective and push when core.view:set("3d") is called.

---@class core.camera3d
core.camera3d = {
    _state = {
        eye = { 0, 0, -1 },
        at = { 0, 0, 0 },
        up = { 0, 1, 0 },
        fovy = math.pi / 2,
        depth = { 1, 2 },
        fog = { start = 0, finish = 0, color = lstg.Color(0x00000000) },
    }
}
core.camera3d.__index = core.camera3d

function core.camera3d:reset()
    self._state = {
        eye = { 0, 0, -1 },
        at = { 0, 0, 0 },
        up = { 0, 1, 0 },
        fovy = math.pi / 2,
        depth = { 1, 2 },
        fog = { start = 0, finish = 0, color = lstg.Color(0x00000000) },
    }
end

---Configures camera view. All fields are optional.
---@param cfg { eye:{x:number,y:number,z:number}?, at:{x:number,y:number,z:number}?, up:{x:number,y:number,z:number}?, fov:number?, depth:{near:number,far:number}?, fog:{start:number,finish:number,color:lstg.Color}? }
function core.camera3d:set(cfg)
    local s = self._state
    if cfg.eye then s.eye = { cfg.eye.x, cfg.eye.y, cfg.eye.z } end
    if cfg.at then s.at = { cfg.at.x, cfg.at.y, cfg.at.z } end
    if cfg.up then s.up = { cfg.up.x, cfg.up.y, cfg.up.z } end
    if cfg.fov then s.fovy = cfg.fov end
    if cfg.depth then s.depth = { cfg.depth[1], cfg.depth[2] } end
    if cfg.fog then
        cfg.fog.color.a = 255
        s.fog = cfg.fog
    end
end

---Returns a COPY of the current camera state.
---@return table
function core.camera3d:get()
    local s = self._state
    return {
        eye = { x = s.eye[1], y = s.eye[2], z = s.eye[3] },
        at = { x = s.at[1], y = s.at[2], z = s.at[3] },
        up = { x = s.up[1], y = s.up[2], z = s.up[3] },
        fov = s.fovy,
        depth = { near = s.depth[1], far = s.depth[2] },
        fog = { start = s.fog.start, finish = s.fog.finish, color = s.fog.color },
    }
end

-------------------------------------------------------------
--- View

---@class core.view
core.view = {
    _mode = "world"
}
core.view.__index = core.view

---@alias core.view_mode
---| "world" Game coordinate space (affected by world camera).
---| "ui" Screen-space overlay, origin at bottom-left.
---| "screen" Raw pixels of the screen.
---| "3d" Full 3D perspective mode.

local VALID_MODES = { world = true, ui = true, screen = true, ["3d"] = true }

local function viewport(sl, sr, sb, st)
    local sc = core.screen
    local w = sc.world

    local vl = sl * sc.scale + sc.dx
    local vr = sr * sc.scale + sc.dx
    local vb = sb * sc.scale + sc.dy
    local vt = st * sc.scale + sc.dy
    lstg.SetViewport(vl, vr, vb, vt)
    lstg.SetScissorRect(vl, vr, vb, vt)
end

---Sets the current view mode in a render context.
---@param mode core.view_mode
function core.view:set(mode)
    assert(VALID_MODES[mode], "Invalid view mode: '" .. tostring(mode) .. "'")
    self._mode = mode

    local sc = core.screen
    local w = sc.world

    if mode == "world" then
        local l, r, b, t = core.world_camera:getTransformedBounds()
        lstg.SetOrtho(l, r, b, t)
        viewport(w.scrl, w.scrr, w.scrb, w.scrt)
        lstg.SetFog()
        lstg.SetImageScale(1)
    elseif mode == "ui" then
        lstg.SetOrtho(0, sc.width, 0, sc.height)
        viewport(0, sc.width, 0, sc.height)
        lstg.SetFog()
        lstg.SetImageScale(1)
    elseif mode == "screen" then
        local gw = core.userdata.settings.graphics_system.width
        local gh = core.userdata.settings.graphics_system.height
        lstg.SetOrtho(0, gw, 0, gh)
        lstg.SetViewport(0, sc.width, sc.height, 0)
        lstg.SetScissorRect(0, sc.width, sc.height, 0)
        lstg.SetFog()
        lstg.SetImageScale(1)
    elseif mode == "3d" then
        local cam = core.camera3d._state
        viewport(w.scrl, w.scrr, w.scrb, w.scrt)
        lstg.SetPerspective(
            cam.eye[1], cam.eye[2], cam.eye[3],
            cam.at[1], cam.at[2], cam.at[3],
            cam.up[1], cam.up[2], cam.up[3],
            cam.fovy,
            (w.scrr - w.scrl) / (w.scrt - w.scrb),
            cam.depth[1], cam.depth[2]
        )
        lstg.SetFog(cam.fog.start, cam.fog.finish, cam.fog.color)
        local dx = cam.eye[1] - cam.at[1]
        local dy = cam.eye[2] - cam.at[2]
        local dz = cam.eye[3] - cam.at[3]
        local dist = (dx * dx + dy * dy + dz * dz) ^ 0.5
        lstg.SetImageScale((dist * 2 * math.tan(cam.fovy * 0.5)) / (w.scrr - w.scrl))
    end
end

---Gets the active view mode.
---@return core.view_mode
function core.view:get()
    return self._mode
end

---Clears the entire viewport.
---@param color lstg.Color
function core.view:clear(color)
    local sc = core.screen
    local w = sc.world
    local mode = self._mode
    if mode == "3d" then
        self:set("world")
        drawRect(w.l, w.r, w.b, w.t, color)
        self:set("3d")
    elseif mode == "world" then
        local l, r, b, t = core.world_camera:getTransformedBounds()
        drawRect(l, r, b, t, color)
    elseif mode == "ui" then
        drawRect(0, sc.width, 0, sc.height, color)
    else
        error("View.clear: unsupported in mode '" .. mode .. "'")
    end
end

local function apply(l2, r2, b2, t2, sl, sr, sb, st)
    local sc = core.screen
    lstg.SetOrtho(l2, r2, b2, t2)
    local vl = sl * sc.scale + sc.dx
    local vr = sr * sc.scale + sc.dx
    local vb = sb * sc.scale + sc.dy
    local vt = st * sc.scale + sc.dy
    lstg.SetViewport(vl, vr, vb, vt)
    lstg.SetScissorRect(vl, vr, vb, vt)
    lstg.SetFog()
    lstg.SetImageScale(1)
end

---Applies an ortographic projection. Doesn't survive view mode changes.
---@overload fun(cfg:table)
function core.view:set_rect(l, r, b, t, scrl, scrr, scrb, scrt)
    if type(l) == "table" then
        local c = l
        apply(c.l or c[1], c.r or c[2], c.b or c[3], c.t or c[4],
            c.scrl or c[5], c.scrr or c[6], c.scrb or c[7], c.scrt or c[8])
    else
        apply(l, r, b, t, scrl, scrr, scrb, scrt)
    end
end

-------------------------------------------------------------
--- Coords helpers.

---@class core.coords
core.coords = {}
core.coords.__index = core.coords

---@param x number
---@param y number
---@return number, number
function core.coords:world_to_ui(x, y)
    local w = core.screen.world
    local ux = w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l)
    local uy = w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
    return ux, uy
end

---@param ux number
---@param uy number
---@return number, number
function core.coords:ui_to_world(ux, uy)
    local w = core.screen.world
    local x = w.l + (ux - w.scrl) * (w.r - w.l) / (w.scrr - w.scrl)
    local y = w.b + (uy - w.scrb) * (w.t - w.b) / (w.scrt - w.scrb)
    return x, y
end

---@param x number
---@param y number
---@return number, number
function core.coords:world_to_screen(x, y)
    local sc = core.screen
    local w = sc.world
    local settings = core.userdata.settings
    local sx, sy
    if settings.graphics_system.width > settings.graphics_system.height then
        local margin = (settings.graphics_system.width - settings.graphics_system.height * sc.width / sc.height) * 0.5 / sc.scale
        sx = margin + w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l)
        sy = w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
    else
        local margin = (settings.graphics_system.height - settings.graphics_system.width * sc.height / sc.width) * 0.5 / sc.scale
        sx = w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l)
        sy = margin + w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
    end
    return sx, sy
end

---@param sx number
---@param sy number
---@return number, number
function core.coords:screen_to_world(sx, sy)
    local ox, oy = self:world_to_screen(0, 0)
    return sx - ox, sy - oy
end

core.screen:setup()
core.view:set("world")