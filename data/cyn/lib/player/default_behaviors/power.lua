local audio_manager = require("core.engine.resources.audio_manager")

---@class core.player.behavior.power : core.player.behavior
local M = core.player.behavior.define("power")

function M:init()
    self.min_power = 0
    self.min_safe_power = 100
    self.max_power = 400

    self.current_power = core.userdata.gamestate.power or 0

    self.lose_power_by_dying = true
    self.lose_power_by_dying_amount = 50
    self.spawn_power_items_on_death = true

    if self.lose_power_by_dying then
        core.signals:Register("player:lostPower", "player:death", function()
            self.current_power = math.clamp(self.current_power - self.lose_power_by_dying_amount, self.min_safe_power, self.max_power)
            core.userdata.gamestate.power = self.current_power
        end)
    end

    core.signals:Register("player:getPower", "item:getPower", function(amount)
        if amount == -1 then
            amount = self.max_power
        end
        local before = math.floor(self.current_power / 100)
        self.current_power = math.clamp(self.current_power + amount, self.min_power, self.max_power)
        core.userdata.gamestate.power = self.current_power
        local after = math.floor(self.current_power / 100)
        if after > before then
            audio_manager.play_se("powerup1", 0.5)
        end
        -- If get more power than max amount possible, add to score.
        if self.current_power >= self.max_power then
            core.userdata.gamestate.score = (core.userdata.gamestate.score or 0) + amount * 100
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

    local success, value = ImGui.InputInt("Current power value", self.current_power, 1, 5)
    if success then
        self.current_power = math.clamp(value, self.min_power, self.max_power)
        core.userdata.gamestate.power = self.current_power
    end
end

return M