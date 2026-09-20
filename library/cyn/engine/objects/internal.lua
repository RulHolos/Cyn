---@class cyn.object
local M = {}

---Kills the object
---@param self cyn.object
function M.kill(self)
    if lstg.IsValid(self) then
        lstg.Kill(self)
    end
end

---Deletes the object
---@param self cyn.object
function M.delete(self)
    if lstg.IsValid(self) then
        lstg.Del(self)
    end
end

---@param self cyn.object
---@param obj cyn.object
function M.new_slave(self, obj)
    obj = lstg.New(obj)
    self._slaves = self._slaves or {}
    table.insert(self._slaves, obj)
    return obj
end

---@param self cyn.object
---@param obj cyn.object
function M.link_slave(self, obj)
    self._slaves = self._slaves or {}
    table.insert(self._slaves, obj)
end

---Stops the object's movement instantly.
---@param self cyn.object
function M.stop_mov(self)
    self.vx, self.vy = 0, 0
    self.ax, self.ay = 0, 0
    self.ag = 0
end

return M