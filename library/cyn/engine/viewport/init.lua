---Viewport handlers
---@class cyn.viewport
---@field camera3d cyn.viewport.camera3d
---@field world_camera cyn.viewport.world_camera
---@field world cyn.viewport.world
---@field screen cyn.viewport.screen
---@field view cyn.viewport.view
---@field coords cyn.viewport.coords
local M = {}

M.camera3d = require("cyn.engine.viewport.camera3d")
M.world_camera = require("cyn.engine.viewport.world_camera")
M.world = require("cyn.engine.viewport.world")
M.screen = require("cyn.engine.viewport.screen")
M.view = require("cyn.engine.viewport.view")
M.coords = require("cyn.engine.viewport.coords")

local signals = require("cyn.foundation.signals")

signals:Once("register_screen", signals.known_signals.GameInit, function()
    M.screen:setup(true)
    M.view:set("world")
end, signals.HIGH_PRIORITY + 1)

return M