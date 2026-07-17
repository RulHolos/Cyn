--- Class system inspired by Cyanlib (because I love your way of doing it)

---@class core.object
local M = {}
core.object = M

require("core.lib.objects.groups")

---@generic C
---@param class_type C
---@return C
function makeInstance(class_type)
    class_type.__index = class_type
    local instance = {}
    setmetatable(instance, class_type)
    return instance
end

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

local function equivalent(self, target)
    for k, v in pairs(target) do
        if type(k) ~= "number" and k ~= "is_class" and k ~= "base" and k:sub(1, 2) ~= "__" then
            self[k] = v
        end
    end
end

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
    local result = { noop, noop, noop, DefaultRenderFunc, noop, noop, is_class = true, base = base }
    equivalent(result, base)
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
        local class = v
        local base_init = v[1]
        v[1] = function(self, ...)
            for k, fn in pairs(class) do
                if type(k) == "string" and type(fn) == "function" and k:sub(1, 2) ~= "__" then
                    rawset(self, k, fn)
                end
            end
            return base_init(self, ...)
        end
    end
    all_classes = {}
end

internals = require("core.lib.objects.internal")

setmetatable(M, {
    __index = function(k, v)
        local internal = internals[v]
        if internal then
            rawset(k, v, internal)
            return internal
        end
    end
})