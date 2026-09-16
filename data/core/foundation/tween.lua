local easing = require("core.global_scripts.easing")

---@class core.tween
local M = {}

local TWEEN_FIELD = "__core_tweens"

---@class core.tween.instance
---@field target table
---@field properties table
---@field duration number
---@field timer number
---@field finished boolean
---@field active boolean
---@field _easing fun(t:number):number
---@field _repeatCount number
---@field _completedCount number
---@field _yoyo boolean
---@field _delay number
---@field _delayTimer number
---@field _onComplete function[]
---@field from table
local TweenInstance = {}
TweenInstance.__index = TweenInstance

---@param target table Usually an object
---@param properties table The properties to tween
---@param duration number The duration of the tween in frames
---@return core.tween.instance
function TweenInstance.new(target, properties, duration)
    ---@type core.tween.instance
    local self = setmetatable({}, TweenInstance)
    self.target = target
    self.properties = properties
    self.duration = math.max(1, duration)
    self.timer = 0
    self.from = {}
    self.id = "default"
    self.finished = false
    self.active = true
    self._easing = easing.linear
    self._repeatCount = 0
    self._completedCount = 0
    self._yoyo = false
    self._delay = 0
    self._delayTimer = 0
    self._onComplete = {}

    for k, _ in pairs(properties) do
        self.from[k] = target[k] or 0
    end

    return self
end

----------------- API

---@param ease EasingType|fun(t: number): number
---@return core.tween.instance
function TweenInstance:ease(ease)
    if type(ease) == "string" then
        self._easing = easing[ease] or easing.linear
    else
        self._easing = ease
    end
    return self
end

---@param frames integer Number of frames before starting the tween.
---@return core.tween.instance
function TweenInstance:delay(frames)
    self._delay = frames
    return self
end

---@param enabled boolean If true, the tween will reverse direction on each repeat.
---@return core.tween.instance
function TweenInstance:yoyo(enabled)
    self._yoyo = enabled ~= false
    return self
end

---@param count integer Number of times to repeat the tween. -1 for infinite.
---@return core.tween.instance
function TweenInstance:loop(count)
    self._repeatCount = count or -1
    return self
end

---@param fn fun()
---@return core.tween.instance
function TweenInstance:onCompleted(fn)
    table.insert(self._onComplete, fn)
    return self
end

---@param name string Label for this tween to find it.
---@return core.tween.instance
function TweenInstance:label(name)
    self.id = name
    return self
end

---Stops this specific tween immediately without onComplete callback execution.
function TweenInstance:stop()
    self.finished = true
    self.active = false
end

---@private
function TweenInstance:update()
    if self.finished or not self.active then return end

    if self._delayTimer < self._delay then
        self._delayTimer = self._delayTimer + 1
        return
    end

    self.timer = self.timer + 1
    local progress = math.min(self.timer / self.duration, 1.0)
    local curve = self._easing(progress)

    for key, targetValue in pairs(self.properties) do
        local startValue = self.from[key]
        local newValue = startValue + (targetValue - startValue) * curve
        self.target[key] = newValue
    end

    if progress >= 1.0 then
        self._completedCount = self._completedCount + 1

        local canRepeat = (self._repeatCount == -1) or (self._completedCount <= self._repeatCount)

        if canRepeat then
            if self._yoyo then
                local oldFrom = self.from
                self.from = self.properties
                self.properties = oldFrom
            end
            self.timer = 0
        else
            self.finished = true
            for _, fn in ipairs(self._onComplete) do fn(self.target) end
        end
    end
end

---@param target table Usually an object
---@param props table The properties to tween
---@param frames number The duration of the tween in frames
---@return core.tween.instance
function M.New(target, props, frames)
    local list = rawget(target, TWEEN_FIELD)
    if not list then
        list = {}
        rawset(target, TWEEN_FIELD, list)
    end

    for i = #list, 1, -1 do
        local existing = list[i]
        if existing.active and not existing.finished then
            for key, _ in pairs(props) do
                if existing.properties[key] ~= nil then
                    existing.properties[key] = nil
                    existing.from[key] = nil
                end
            end

            if next(existing.properties) == nil then
                existing:stop()
                table.remove(list, i)
            end
        end
    end

    local instance = TweenInstance.new(target, props, frames)
    table.insert(list, instance)

    return instance
end

---Stops all tweens for a target, or only tweens animating a specific property.
---@param target table
---@param property string? Optional property name to target
function M.Stop(target, property)
    local list = rawget(target, TWEEN_FIELD)
    if not list then return end

    for i = #list, 1, -1 do
        local existing = list[i]
        if property then
            existing.properties[property] = nil
            existing.from[property] = nil
            if next(existing.properties) == nil then
                existing:stop()
                table.remove(list, i)
            end
        else
            existing:stop()
            table.remove(list, i)
        end
    end
end

function M.Do(target)
    local list = rawget(target, TWEEN_FIELD)
    if not list then
        return
    end

    for i = #list, 1, -1 do
        local t = list[i]
        t:update()
        if t.finished then
            table.remove(list, i)
        end
    end
end

return M