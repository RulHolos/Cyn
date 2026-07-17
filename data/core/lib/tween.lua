local Easing = require("core.global_scripts.easing")

---@class core.tween
local M = {}
core.tween = M

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
    self._easing = Easing.linear
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
        self._easing = Easing[ease] or Easing.linear
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

        if self._yoyo and (self._completedCount % 2 ~= 0) then
            local oldFrom = self.from
            self.from = self.properties
            self.properties = oldFrom
            self.timer = 0
        elseif self._repeatCount == -1 or self._completedCount <= self._repeatCount then
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
    local instance = TweenInstance.new(target, props, frames)

    local list = rawget(target, TWEEN_FIELD)
    if not list then
        list = {}
        rawset(target, TWEEN_FIELD, list)
    end
    table.insert(list, instance)

    return instance
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

---Convenience generator for a fade-in tween on an object's `_a` property.
---@param time number Duration of the fade in effect in frames.
---@return core.tween.instance
function M.FadeIn(target, time)
    return M.New(target, { _a = 255 }, time)
end

---Convenience generator for a fade-out tween on an object's `_a` property.
---@param time number Duration of the fade out effect in frames.
---@return core.tween.instance
function M.FadeOut(target, time)
    return M.New(target, { _a = 0 }, time)
end

return M
