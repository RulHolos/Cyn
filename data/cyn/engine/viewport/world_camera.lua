local world = require("cyn.engine.viewport.world")

---@class cyn.viewport.world_camera
local M = {
    ---@private
    _state = {
        cx = 0, cy = 0, -- Centre offset (pan)
        sx = 1, sy = 1, -- Scale (zoom)
        dx = 0, dy = 0, -- Translation (shake)
    }
}

function M:reset()
    self._state = {
        cx = 0, cy = 0,
        sx = 1, sy = 1,
        dx = 0, dy = 0,
    }
end

---Set the camera params. All fields are optional.
---@param cfg { center:{x:number,y:number}?, scale:{x:number,y:number}?, offset:{x:number,y:number}? }
function M:set(cfg)
    local s = self._state

    if cfg.center then
        s.cx, s.cy = cfg.center.x or s.cx, cfg.center.y or s.cy
    end

    if cfg.scale then
        s.sx, s.sy = cfg.scale.x or s.sx, cfg.scale.y or s.sy
    end

    if cfg.offset then
        s.dx, s.dy = cfg.offset.x or s.dx, cfg.offset.y or s.dy
    end
end

---Moves the camera to an absolute world-space position (the given point becomes the screen centre).
---@param x number
---@param y number
function M:move_to(x, y)
    self:set({ center = { x = x, y = y } })
end

---Pan the camera by a relative amount. Does not affect scale or offset.
---@param dx number
---@param dy number
function M:pan(dx, dy)
    self:set({ center = { x = self._state.cx + dx, y = self._state.cy + dy } })
end

---Returns a COPY of the current camera state.
---@return table
function M:get_state()
    local s = self._state
    return { center = { x = s.cx, y = s.cy }, scale = { x = s.sx, y = s.sy }, offset = { x = s.dx, y = s.dy } }
end

---Compute the world-space viewport after applying camera transform. Used by the cyn.viewport.view class.
---@return number l, number r, number b, number t
function M:get_transformed_bounds()
    local s = self._state
    local w = world.data

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

return M