-- TODO: Remove the task system.

local max = math.max
local floor = math.floor
local create = coroutine.create
local status = coroutine.status
local resume = coroutine.resume
local yield = coroutine.yield

local FIELD = "task"
local function _sweep(g)
    local list, j = g.list, 0
    for i = 1, #list do
        local e = list[i]
        if not e.dead and status(e.co) ~= "dead" then
            j = j + 1
            list[j] = e
        else
            e._g = nil
        end
    end
    for i = j + 1, #list do
        list[i] = nil
    end
    g.dirty = false
end

local function _getOrCreateGroup(target)
    local g = rawget(target, FIELD)
    if not g then
        g = {
            list = {},
            dirty = false,
            depth = 0
        }
        rawset(target, FIELD, g)
    end
    return g
end

local target_stack = {}
local target_stack_n = 0
local co_stack = {}
local co_stack_n = 0

--- Handle

---@class core.task.handle
local Handle = {}
Handle.__index = Handle

function Handle:Cancel()
    local e = self._e
    if not e then return end
    if not e.dead then
        e.dead = true
        local g = e._g
        if g then
            g.dirty = true
            if g.depth == 0 then
                _sweep(g)
            end
        end
    end
    self._e = nil
end

function Handle:IsRunning()
    local e = self._e
    if not e or e.dead then return false end
    return status(e.co) ~= "dead"
end

---@class core.task
local M = {}
core.task = M

---Creates a new task attached to a target.
---
---Returns an handle. Store it in your object and call :Cancel() to cancel it.
---@param target any
---@param f function
---@return core.task.handle
function M.New(target, f)
    local g = _getOrCreateGroup(target)
    local entry = {
        co = create(f),
        dead = false,
        _g = g,
    }
    g.list[#g.list + 1] = entry
    return setmetatable({ _e = entry}, Handle)
end

---Executes all current tasks in a target.
---@param target any
function M.Do(target)
    local g = rawget(target, FIELD)
    if not g then return end

    local list = g.list
    local n = #list

    g.depth = g.depth + 1

    for i = 1, n do
        local e = list[i]
        if not e.dead then
            local co = e.co
            if status(co) ~= "dead" then
                target_stack_n = target_stack_n + 1
                target_stack[target_stack_n] = target
                co_stack_n = co_stack_n + 1
                co_stack[co_stack_n] = co

                local ok, err = resume(co)

                co_stack[co_stack] = nil
                co_stack_n = co_stack_n - 1
                target_stack[target_stack_n] = nil
                target_stack_n = target_stack_n - 1

                if not ok then
                    e.dead = true
                    g.dirty = true
                    g.depth = g.depth - 1
                    error(
                        "task error:\n" .. tostring(err) ..
                        "\n========== coroutine traceback ==========\n" ..
                        debug.traceback(co) ..
                        "\n========== C traceback =========="
                    )
                end

                if status(co) == "dead" then
                    e.dead = true
                    g.dirty = true
                end
            else
                e.dead = true
                g.dirty = true
            end
        end
    end

    g.depth = g.depth - 1

    if g.dirty and g.depth == 0 then
        _sweep(g)
        if #g.list == 0 then
            rawset(target, FIELD, nil)
        end
    end
end

---Waits n number of frames.
---@param frames integer?
function M.Wait(frames)
    local f = floor(max(1, frames or 1))
    for _ = 1, f do
        yield()
    end
end

---Cancels all tasks on target.
---If reserve_current is true, the calling task is kept.
---@param target any
---@param reserve_current boolean?
function M.Clear(target, reserve_current)
    local g = rawget(target, FIELD)
    if not g then return end

    local list     = g.list
    local reserved = nil

    if reserve_current then
        local current_co = co_stack[co_stack_n]
        if current_co then
            for i = 1, #list do
                if list[i].co == current_co then
                    reserved = list[i]
                    break
                end
            end
        end
    end

    -- Mark everything dead (except the reserved entry)
    for i = 1, #list do
        local e = list[i]
        if e ~= reserved then
            e.dead = true
            e._g   = nil
        end
    end

    if g.depth > 0 then
        -- Mid-Do: leave compaction to the deferred sweep
        g.dirty = true
    else
        if reserved then
            for i = 1, #list do list[i] = nil end
            list[1]  = reserved
            g.dirty  = false
        else
            rawset(target, FIELD, nil)
        end
    end
end

---Returns the target of the currently executing task.
---@return any
function M.GetSelf()
    return target_stack[target_stack_n]
end

return M