local player = require("yeva.player")
local signals = require("cyn.foundation.signals")

---@class yeva.player.behavior.miss : yeva.player.behavior
local M = player.behavior.define("miss")

function M:init()
    ---Frames of protection to apply to the player when dying.<br>Defaults to 6 seconds (360 frames).
    self.protect_timer = 360
end

function M:get_deps()
    ---@type yeva.player.behavior.power?
    self.power = self.player:get_behavior("power")
    if not self.power then
        lstg.Log(LOG.WARN, "Power behavior not found for the player. Will not lose power by dying.")
    end
end

function M:trigger()
    self.player.protect = self.protect_timer
    signals:Emit("player:miss")
end

return M
