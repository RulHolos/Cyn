---Wrapper around the core.engine.resources submodules.
---
---Prefer requiring the specific submodule you need directly. Example:
---```lua
---local image_atlas = require("core.engine.resources.image_atlas")
---```
local common = require("core.engine.resources.common")

---@class resources
local M = {}

M.ENUM_RES_TYPE = common.ENUM_RES_TYPE
M.get_typed_name = common.get_typed_name
M.set_default_sampler_state = common.set_default_sampler_state
M.set_active_pool = common.set_active_pool
M.transfer = common.transfer

M.image = require("core.engine.resources.image")
M.image_atlas = require("core.engine.resources.image_atlas")
M.texture = require("core.engine.resources.texture")
M.music = require("core.engine.resources.music")
M.sound = require("core.engine.resources.sound")
M.ninepatch = require("core.engine.resources.ninepatch")
M.video = require("core.engine.resources.video")
M.ttf = require("core.engine.resources.ttf")
M.render_target = require("core.engine.resources.render_target")

M.audio_manager = require("core.engine.resources.audio_manager")

return M
