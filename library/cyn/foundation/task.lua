local max = math.max
local floor = math.floor
local create = coroutine.create
local status = coroutine.status
local resume = coroutine.resume
local yield = coroutine.yield

---Wrapper around coroutine-based tasks.
---@class cyn.task
local task = {}

local field = "__TASKS"
local target_stack = {}
local target_stack_n = 0
---@type thread[]
local co_stack = {}
local co_stack_n = 0

---@param target table
---@param f fun()
---@return thread
function task.New(target, f)
    ---@type table?
    local tasks = rawget(target, field)
    if not tasks then
        tasks = { n = 0, gen = 0 }
        rawset(target, field, tasks)
    end

    local co = create(f)
    local n = tasks.n + 1

    tasks[n] = co
    tasks.n = n

    return co
end

---@param target table
function task.Do(target)
    local tasks = rawget(target, field)
    if not tasks then
        return
    end

    local n = tasks.n
    if n == 0 then
        return
    end

    local gen = tasks.gen
    local write = 1
    local errmsg

    for i = 1, n do
        if tasks.gen ~= gen then
            break
        end

        local co = tasks[i]
        if co == nil then
            break
        end

        if status(co) ~= "dead" then
            target_stack_n = target_stack_n + 1
            target_stack[target_stack_n] = target
            co_stack_n = co_stack_n + 1
            co_stack[co_stack_n] = co

            local result, err = resume(co)

            co_stack[co_stack_n] = nil
            co_stack_n = co_stack_n - 1
            target_stack[target_stack_n] = nil
            target_stack_n = target_stack_n - 1

            if not result and not errmsg then
                errmsg = "Task error:\n"
                .. tostring(err)
                .. "\n========== Coroutine Traceback ==========\n"
                .. debug.traceback(co)
                .. "\n========== C VM Traceback =========="
            end
        end

        if tasks.gen == gen and status(co) ~= "dead" then
            tasks[write] = co
            write = write + 1
        end
    end

    if tasks.gen == gen then
        local total_n = tasks.n

        if total_n > n then
            for i = n + 1, total_n do
                tasks[write] = tasks[i]
                if write ~= i then
                    tasks[i] = nil
                end
                write = write + 1
            end
        end

        for i = write, total_n do
            tasks[i] = nil
        end

        tasks.n = write - 1

        if tasks.n == 0 then
            rawset(target, field, nil)
        end
    end

    if errmsg then
        error(errmsg)
    end
end

---@param target table
---@param reserve_current boolean?
function task.Clear(target, reserve_current)
    local tasks = rawget(target, field)
    if not tasks then
        return
    end

    ---@type thread?
    local co_reserved

    if reserve_current and target_stack[target_stack_n] == target then
        co_reserved = co_stack[co_stack_n]
    end

    for i = 1, tasks.n do
        tasks[i] = nil
    end

    tasks.gen = tasks.gen + 1

    if co_reserved then
        tasks[1] = co_reserved
        tasks.n = 1
    else
        tasks.n = 0
        rawset(target, field, nil)
    end
end

---@param frames number?
function task.Wait(frames)
    frames = max(1, floor(frames or 1))

    for _ = 1, frames do
        yield()
    end
end

return task