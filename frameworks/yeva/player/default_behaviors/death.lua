local player = require("yeva.player")
local audio_manager = require("cyn.engine.resources.audio_manager")

---@class yeva.player.behavior.death : yeva.player.behavior
local M = player.behavior.define("death")

---@enum yeva.player.behavior.death.states
local states = {
    ALIVE = 1,
    DEATHBOMB_WINDOW = 2,
    HIT = 3,
    HIDDEN_WAIT = 4,
    HIDE = 5,
    RESPAWN_WAIT = 6,
    RESPAWN = 7,
    ENTERING = 8,
}

function M:init()
    self.death_state = states.ALIVE
    self.death_timer = 0

    ---@private
    ---@type table<yeva.player.behavior.death.states, fun(self:yeva.player.behavior.death)>
    self.state_on_frame = {
        [states.HIT] = self.on_frame_hit,
        [states.HIDE] = self.on_frame_hide,
        [states.RESPAWN] = self.on_frame_respawn,
        [states.ENTERING] = self.on_frame_entering,
    }

    ---@private
    self.death_durations = {
        [states.DEATHBOMB_WINDOW] = 10,
        [states.HIT] = 1,
        [states.HIDDEN_WAIT] = 5,
        [states.HIDE] = 1,
        [states.RESPAWN_WAIT] = 33,
        [states.RESPAWN] = 1,
        [states.ENTERING] = 49,
    }

    ---@private
    self.next_state = {
        [states.DEATHBOMB_WINDOW] = states.HIT,
        [states.HIT] = states.HIDDEN_WAIT,
        [states.HIDDEN_WAIT] = states.HIDE,
        [states.HIDE] = states.RESPAWN_WAIT,
        [states.RESPAWN_WAIT] = states.RESPAWN,
        [states.RESPAWN] = states.ENTERING,
        [states.ENTERING] = states.ALIVE,
    }
end

---@private
function M:on_frame_hit()
    --self.miss:trigger() --Replaces item.PlayerMiss(p)
    --TODO: Death weapon

   --[[
    p.deathee = {}
    p.deathee[1] = New(deatheff, p.x, p.y, "first")
    p.deathee[2] = New(deatheff, p.x, p.y, "second")
 
    New(player_death_ef, p.x, p.y)]]
end

---@private
function M:on_frame_hide()
    self.player.hide = true
end

---@private
function M:on_frame_respawn()
    self.player.x = 0
    --self.player.support.x = 0
    --self.player.support.y = 0
    self.player.y = -236
    self.player.hide = false

    --New(bullet_deleter, self.player.x, self.player.y)
end

---@private
function M:on_frame_entering()
    self.player.y = -192 - 1.2 * (self.death_timer - 1)
end

---@private
function M:transition(state)
    self.death_state = state
    self.death_timer = self.death_durations[state] or 0
end

function M:frame()
    if self.player.time_stop then
        return
    end

    local state = self.death_state
    local on_frame = self.state_on_frame[state]

    if on_frame then
        on_frame(self)
    end

    local duration = self.death_durations[state]

    if not duration then
        return
    end

    self.death_timer = self.death_timer - 1

    if self.death_timer <= 0 then
        self:transition(self.next_state[state])
    end
end

---Kills the player the normal way.
---
---Starts the deathbomb window immediately.
function M:hit()
    audio_manager.play_se("pldead00", 0.5)
    self:transition(states.DEATHBOMB_WINDOW)
end

---Cancels a pending death if the player is still inside the deathbomb window, otherwise is no-op.
function M:cancel()
    if self.death_state ~= states.DEATHBOMB_WINDOW then
        return
    end

    self:transition(states.ALIVE)
end

---Checks if the player is currently alive (alive state, so not in death-bomb window).
---@return boolean is_alive
function M:is_alive()
    return self.death_state == states.ALIVE
end

---Checks if the player can act (move, shoot, bomb, special, ...) or is inside the deathbomb window.
---
---Blocked while locked or time-stopped.
function M:has_control()
    if self.player.lock or self.player.time_stop then
        return false
    end

    local state = self.death_state
    return state == states.ALIVE or state == states.DEATHBOMB_WINDOW
end

return M