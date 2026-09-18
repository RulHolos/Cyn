local screen = require("cyn.engine.viewport.screen")
local world = require("cyn.engine.viewport.world")
local world_camera = require("cyn.engine.viewport.world_camera")
local camera3d = require("cyn.engine.viewport.camera3d")

lstg.CreateRenderTarget("rt:screen-white", 64, 64)
lstg.LoadImage("img:screen-white", "rt:screen-white", 16, 16, 16, 16)

local function refresh_white_target()
    lstg.PushRenderTarget("rt:screen-white")
    lstg.RenderClear(lstg.Color(255, 255, 255, 255))
    lstg.PopRenderTarget()
end

local function draw_rect(l, r, b, t, color)
    refresh_white_target()
    lstg.SetImageState("img:screen-white", "", color)
    lstg.RenderRect("img:screen-white", l, r, b, t)
end

---@class cyn.viewport.view
local M = {
    _mode = "world"
}

---@alias cyn.view_mode
---| "world" Game coordinate space (affected by world camera).
---| "ui" Screen-space overlay, origin at bottom-left.
---| "screen" Raw pixels of the screen.
---| "3d" Full 3D perspective mode.

local VALID_MODES = { world = true, ui = true, screen = true, ["3d"] = true }

local function viewport(sl, sr, sb, st)
    local sc = screen

    local vl = sl * sc.scale + sc.dx
    local vr = sr * sc.scale + sc.dx
    local vb = sb * sc.scale + sc.dy
    local vt = st * sc.scale + sc.dy

    lstg.SetViewport(vl, vr, vb, vt)
    lstg.SetScissorRect(vl, vr, vb, vt)
end

---Sets the current view mode in a render context.
---@param mode cyn.view_mode
function M:set(mode)
    assert(VALID_MODES[mode], "Invalid view mode: '" .. tostring(mode) .. "'")
    self._mode = mode

    local sc = screen
    local w = world.data

    if mode == "world" then
        local l, r, b, t = world_camera:get_transformed_bounds()
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
        local gw = screen.width
        local gh = screen.height
        lstg.SetOrtho(0, gw, 0, gh)
        lstg.SetViewport(0, sc.width, sc.height, 0)
        lstg.SetScissorRect(0, sc.width, sc.height, 0)
        lstg.SetFog()
        lstg.SetImageScale(1)
    elseif mode == "3d" then
        local cam = camera3d._state
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
---@return cyn.view_mode
function M:get()
    return self._mode
end

---Clears the entire viewport.
---@param color lstg.Color
function M:clear(color)
    local sc = screen
    local w = world.data
    local mode = self._mode

    if mode == "3d" then
        self:set("world")
        draw_rect(w.l, w.r, w.b, w.t, color)
        self:set("3d")
    elseif mode == "world" then
        local l, r, b, t = world_camera:get_transformed_bounds()
        draw_rect(l, r, b, t, color)
    elseif mode == "ui" then
        draw_rect(0, sc.width, 0, sc.height, color)
    else
        error("View.clear: unsupported in mode '" .. mode .. "'")
    end
end

local function apply(l2, r2, b2, t2, sl, sr, sb, st)
    local sc = screen
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
function M:set_rect(l, r, b, t, scrl, scrr, scrb, scrt)
    if type(l) == "table" then
        local c = l
        apply(c.l or c[1], c.r or c[2], c.b or c[3], c.t or c[4],
            c.scrl or c[5], c.scrr or c[6], c.scrb or c[7], c.scrt or c[8])
    else
        apply(l, r, b, t, scrl, scrr, scrb, scrt)
    end
end

return M