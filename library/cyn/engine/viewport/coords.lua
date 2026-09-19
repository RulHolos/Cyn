local screen = require("cyn.engine.viewport.screen")

---@class cyn.viewport.coords
local M = {}

---@param x number
---@param y number
---@return number, number
function M:world_to_ui(x, y)
    local w = screen.world
    local ux = w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l)
    local uy = w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
    return ux, uy
end

---@param ux number
---@param uy number
---@return number, number
function M:ui_to_world(ux, uy)
    local w = screen.world
    local x = w.l + (ux - w.scrl) * (w.r - w.l) / (w.scrr - w.scrl)
    local y = w.b + (uy - w.scrb) * (w.t - w.b) / (w.scrt - w.scrb)
    return x, y
end

---@param x number
---@param y number
---@return number, number
function M:world_to_screen(x, y)
    local sc = screen
    local w = sc.world
    local settings = cyn.userdata.settings
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
function M:screen_to_world(sx, sy)
    local ox, oy = self:world_to_screen(0, 0)
    return sx - ox, sy - oy
end

return M