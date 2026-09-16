--- Class system inspired by Cyanlib (because I love your way of doing it)

---@class core.object
local M = {}

local pair = require("core.engine.objects.groups")
M.group, M.layer = pair[1], pair[2]

---@param self core.object
local noop = function(self) end
local all_classes = {}

---@class core.object : lstg.object
local object = {
    0, 0, 0, 0, 0, 0;
    is_class = true,
    init = noop,
    del = noop,
    frame = noop,
    render = lstg.DefaultRenderFunc,
    colli = noop,
    kill = noop,
}
table.insert(all_classes, object)

M.base = object

local function class_sort(class)
    class[1] = class.init
    class[2] = class.del
    class[3] = class.frame
    class[4] = class.render
    class[5] = class.colli
    class[6] = class.kill
end

---@param base core.object?
---@param define core.object?
---@param sort boolean? If true, will re-arrange class functions to be compatible with luastg's internals. Usually not needed.
---@return core.object
function M.define(base, define, sort)
    base = base or object
    local result = { noop, noop, noop, lstg.DefaultRenderFunc, noop, noop, is_class = true, base = base }

    setmetatable(result, { __index = base })

    if type(define) == "table" then
        for k, v in pairs(define) do
            result[k] = v
        end
    end

    if sort then
        class_sort(result)
    else
        table.insert(all_classes, result)
    end
    return result
end

function M.init_all()
    for _, v in pairs(all_classes) do
        class_sort(v)
    end
    all_classes = {}
end

---Yeah luastg is a wonderful engine...
---@param class core.object
function M.resync(class)
    class_sort(class)
end

internals = require("core.engine.objects.internal")

setmetatable(M, {
    __index = function(k, v)
        local internal = internals[v]
        if internal then
            rawset(k, v, internal)
            return internal
        end
    end
})

return M