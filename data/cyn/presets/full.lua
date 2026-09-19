---@class cyn
---@field plugins cyn.plugins

local cyn = require("cyn.presets.interface")

--Sets it directly in the init.lua. Just for safety
require("cyn.tools.debug")

require("cyn.tools.ipc") --Doesn't expose anything
cyn.plugins = require("cyn.tools.plugins")

return cyn