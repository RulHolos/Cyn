local player = require("yeva.player")
local input = require("cyn.engine.input")
local world = require("cyn.engine.viewport.world")
local signals = require("cyn.foundation.signals")
local gamestate = require("cyn.foundation.userdata_manager").userdata.gamestate
local scoredata = require("cyn.foundation.userdata_manager"):get()
local audio_manager = require("cyn.engine.resources.audio_manager")

---@class yeva.player.behavior.power : yeva.player.behavior
local M = player.behavior.define("power")

function M:init()
    self.min_power = 0
    self.min_safe_power = 100
    self.max_power = 400

    self.current_power = gamestate.power or 0

    self.lose_power_by_dying = true
    self.lose_power_by_dying_amount = 50
    self.spawn_power_items_on_death = true

    if self.lose_power_by_dying then
        signals:Register("player:lostPower", "player:death", function()
            self.current_power = math.clamp(self.current_power - self.lose_power_by_dying_amount, self.min_safe_power, self.max_power)
            gamestate.power = self.current_power
        end)
    end

    signals:Register("player:getPower", "item.collect:power", function(amount)
        if amount == -1 then
            amount = self.max_power
        end
        local before = math.floor(self.current_power / 100)
        self.current_power = math.clamp(self.current_power + amount, self.min_power, self.max_power)
        gamestate.power = self.current_power
        local after = math.floor(self.current_power / 100)
        if after > before then
            audio_manager.play_se("powerup1", 0.5)
        end
        -- If get more power than max amount possible, add to score.
        if self.current_power >= self.max_power then
            scoredata.player.score = (scoredata.player.score or 0) + amount * 100
        end
    end)
end

function M:frame()
end

function M:render()
end

function M:debug()
    _, self.lose_power_by_dying = ImGui.Checkbox("Lose power by dying", self.lose_power_by_dying)
    _, self.spawn_power_items_on_death = ImGui.Checkbox("Spawn power items on death", self.spawn_power_items_on_death)

    local success, value = ImGui.InputInt("Current power value", self.current_power, 1, math.INF)
    if success then
        self.current_power = math.clamp(value, self.min_power, self.max_power)
        gamestate.power = self.current_power
    end

    local success, value = ImGui.InputInt("Minimum safe power", self.min_safe_power, 1, math.INF)
    if success then
        self.min_safe_power = math.clamp(value, self.min_power, self.max_power)
    end

    local success, value = ImGui.InputInt("Maximum power", self.max_power, 1, math.INF)
    if success then
        self.max_power = math.clamp(value, self.min_power, math.huge)
    end
end

return M