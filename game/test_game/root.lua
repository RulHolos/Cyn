lstg.Log(LOG.DEBUG, "Starting to load root.lua")
Core = require("cyn.presets.full")
require("frameworks.yeva")

--#region UI widgets

require("yeva.ui")
require("yeva.ui.widgets.ui_bg")
require("yeva.ui.widgets.diff")
require("yeva.ui.widgets.fps")
require("yeva.ui.widgets.score")

--#endregion

require("game.test_game.main_menu")

lstg.Log(LOG.DEBUG, "Finished loading root.lua")