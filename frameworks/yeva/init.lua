--[[
This package is the Cyn experience in a nutshell.
It's the "content" part of the Tessa Ecosystem. This framework MUST be used with the Cyn library.

While I'm here, it's probably worth that I explain the Tessa Ecosystem layers a bit.
Tessa is a group of technologies, libraries and software made to work together in harmony.
It's composed of:
- LuaSTG-Flux / LuaSTG-Entropy (Engine layer)
- Cyn Library (middle layer, direct calls to the engine)
- Yeva Framework (content layer, uses the Cyn Library but also talks directly to the engine sometimes.)
- LunaForge / Sharp-X (The editor layer, providing tools to work with the engine, library and content layers.)

Not that the Yeva Framework and editors layer is completely optional, you can have the Cyn Library and the engine layers only and still be able to make a full game.

Now for the Yeva Framework itself:
This does NOT include a preset by default. It's a "bring your own content" framework.
Yeva Framework provides a base for making your game, like players, items, enemies, stages, ...
But, unlike THlib which expects a LOT of things to be structed a very specific way, Yeva Framework doesn't expect anything. You use what you want.
This does mean that Yeva is much harder to use though, as you have to tie everything together yourself.

Note on Yeva's classes names: They're equivalent to the folder/file architecture.
]]

local userdata = require("yeva.db.userdata")
require("yeva.db.settings")
userdata.init_scoredata()

lstg.Log(LOG.INFO, "Cyn initialized")
lstg.Log(LOG.INFO, "Running Yeva Framework")