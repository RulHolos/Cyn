local player = require("yeva.player")
local audio_manager = require("cyn.engine.resources.audio_manager")
local object = require("cyn.engine.objects")
local task = require("cyn.foundation.task")
local img = require("cyn.engine.resources.image")

--#region death_eff

local death_eff = object.define()

---@param type "first"|"second"
function death_eff:init(x, y, type)
    self.x, self.y = x, y
    self.type = type
    self.size, self.size1 = 0, 0
    self.layer = object.layer.TOP - 1
    task.new(self, function()
        local size, size1 = 0, 0
        if self.type == "second" then
            task.wait(30)
        end
        for _ = 1, 360 do
            self.size = size
            self.size1 = size1
            size = size + 12
            size1 = size1 + 8
            task.wait()
        end
    end)

    local white = lstg.Color(255, 255, 255, 255)
    local black = lstg.Color(255, 0, 0, 0)

    self.rev = img.from_file("assets/general/white.png")
    self.rev:set_blendmode("add+sub")
    self.rev:set_color(white, white, black, black)
end
function death_eff:frame()
    task.exec(self)
    if self.timer > 180 then
        lstg.Del(self)
    end
end
function death_eff:render()
    if self.type == "first" then
        self.rev:render_circle(self.x, self.y, self.size, 60)
        self.rev:render_circle(self.x + 35, self.y + 35, self.size1, 60)
        self.rev:render_circle(self.x + 35, self.y - 35, self.size1, 60)
        self.rev:render_circle(self.x - 35, self.y + 35, self.size1, 60)
        self.rev:render_circle(self.x - 35, self.y - 35, self.size1, 60)
    elseif self.type == "second" then
        self.rev:render_circle(self.x, self.y, self.size, 60)
    else
        error("Unknown death effect type: " .. tostring(self.type))
    end
end
function death_eff:del()
    if self.rev then
        self.rev:destroy()
        self.rev = nil
    end
end

--#endregion
--#region Bullet Deleter

local bullet_deleter = object.define()

---@param kill_indes boolean Kill indestructible bullets too
function bullet_deleter:init(x, y, kill_indes)
    self.x, self.y = x, y
    self.kill_indes = kill_indes
    self.group = object.group.GHOST
    self.hide = true
end
function bullet_deleter:frame()
    if self.timer >= 60 then
        lstg.Del(self)
    end
    for _, o in lstg.ObjList(object.group.ENEMY_BULLET) do
        if lstg.Dist(self, o) < self.timer * 20 then
            lstg.Del(o)
        end
    end
    if self.kill_indes then
        for _, o in lstg.ObjList(object.group.INDES) do
            if lstg.Dist(self, o) < self.timer * 20 then
                lstg.Del(o)
            end
        end
    end
end

--#endregion

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

function M:get_deps()
    ---@type yeva.player.behavior.miss?
    self.miss = self.player:get_behavior("miss")
    if not self.miss then
        lstg.Log(LOG.WARN, "Miss behavior not found for the player. Will not trigger a miss when dying.")
    end
end

---@private
function M:on_frame_hit()
    if self.miss then
        self.miss:trigger()
    end
    --TODO: Death weapon

    self.death_eff = {}
    self.death_eff[1] = death_eff:new(self.player.x, self.player.y, "first")
    self.death_eff[2] = death_eff:new(self.player.x, self.player.y, "second")

    --New(player_death_ef, p.x, p.y)
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

    bullet_deleter:new(self.player.x, self.player.y)
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

function M:debug()
    if ImGui.Button("Kill") then
        self:hit()
    end

    local success, value = ImGui.InputInt("Death State", self.death_state, 1, 8)
    if success then
        self.death_state = math.clamp(value, 1, 8)
    end

    success, value = ImGui.InputInt("Grace Frames", self.death_durations[states.DEATHBOMB_WINDOW], 1, math.INF)
    if success then
        self.death_durations[states.DEATHBOMB_WINDOW] = math.clamp(value, 1, 60)
    end
end

return M