---@class cyn
---@field signals cyn.signals
---@field task cyn.task
---@field random cyn.random
---@field class cyn.class
---@field tween cyn.tween
---@field userdata cyn.userdata_manager
---@field settings cyn.settings_manager
---@field object cyn.object
---@field input cyn.input
---@field resources cyn.resources
---@field viewport cyn.viewport

local cyn = require("cyn.init")

--Foundation modules

cyn.signals = require("cyn.foundation.signals")
cyn.task = require("cyn.foundation.task")
cyn.random = require("cyn.foundation.random")
cyn.class = require("cyn.engine.class")
cyn.tween = require("cyn.foundation.tween")
cyn.userdata = require("cyn.foundation.userdata_manager")
cyn.settings = require("cyn.foundation.settings_manager")

--Engine modules

cyn.object = require("cyn.engine.objects")
cyn.input = require("cyn.engine.input")
cyn.resources = require("cyn.engine.resources")
cyn.viewport = require("cyn.engine.viewport")

return cyn