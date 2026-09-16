local core = require("core")

--Foundation modules

core.signals = require("core.foundation.signals")
core.task = require("core.foundation.task")
core.random = require("core.foundation.random")
core.class = require("core.engine.class")
core.tween = require("core.foundation.tween")

--Engine modules

core.object = require("core.engine.objects")
core.input = require("core.engine.input")
core.resources = require("core.engine.resources")

return core