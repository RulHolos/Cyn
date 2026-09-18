--[[
This package is a close recreation of THlib as it is in its more stable older version.
This is intended to provide the cleanest possible switch to thlib as possible.

It is NOT a direct port of thlib but more like a re-imagination with modularity in mind (but disregarding the Cyn philosophy a bit.)

If you use this package, the "Core" module will be populated with the "Full" library preset by default.
]]

Core = require("core.presets.full")

--TODO: Create other modules

lstg.Log(LOG.INFO, "Cyn initialized")
lstg.Log(LOG.INFO, "Running THlib Framework")