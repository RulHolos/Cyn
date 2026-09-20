---Wrapper around the cyn.engine.resources submodules.
---
---Prefer requiring the specific submodule you need directly. Example:
---```lua
---local image_atlas = require("cyn.engine.resources.image_atlas")
---```
local common = require("cyn.engine.resources.common")

---@class cyn.resources
local M = {}

M.ENUM_RES_TYPE = common.ENUM_RES_TYPE
M.get_typed_name = common.get_typed_name
M.set_default_sampler_state = common.set_default_sampler_state
M.set_active_pool = common.set_active_pool
M.transfer = common.transfer

M.image = require("cyn.engine.resources.image")
M.image_atlas = require("cyn.engine.resources.image_atlas")
M.texture = require("cyn.engine.resources.texture")
M.music = require("cyn.engine.resources.music")
M.sound = require("cyn.engine.resources.sound")
M.ninepatch = require("cyn.engine.resources.ninepatch")
M.video = require("cyn.engine.resources.video")
M.ttf = require("cyn.engine.resources.ttf")
M.render_target = require("cyn.engine.resources.render_target")

M.audio_manager = require("cyn.engine.resources.audio_manager")

return M
