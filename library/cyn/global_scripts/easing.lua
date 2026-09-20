local Easing = {}

---@alias EasingType
---| "linear"
---| "inQuad"
---| "outQuad"
---| "inOutQuad"
---| "inCubic"
---| "outCubic"
---| "inOutCubic"
---| "inQuart"
---| "outQuart"
---| "inOutQuart"
---| "inQuint"
---| "outQuint"
---| "inOutQuint"
---| "inSine"
---| "outSine"
---| "inOutSine"
---| "inExpo"
---| "outExpo"
---| "inOutExpo"
---| "inCirc"
---| "outCirc"
---| "inOutCirc"
---| "inBack"
---| "outBack"
---| "inOutBack"
---| "inElastic"
---| "outElastic"
---| "inOutElastic"
---| "inBounce"
---| "outBounce"
---| "inOutBounce"

-- linear
---@param t number
---@return number
function Easing.linear(t) return t end

-- quadratic
---@param t number
---@return number
function Easing.inQuad(t) return t * t end

---@param t number
---@return number
function Easing.outQuad(t) return t * (2 - t) end

---@param t number
---@return number
function Easing.inOutQuad(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end

-- cubic
---@param t number
---@return number
function Easing.inCubic(t) return t * t * t end

---@param t number
---@return number
function Easing.outCubic(t) return 1 + (t - 1) ^ 3 end

---@param t number
---@return number
function Easing.inOutCubic(t) return t < 0.5 and 4 * t ^ 3 or (t - 1) * (2 * t - 2) ^ 2 + 1 end

-- quartic
---@param t number
---@return number
function Easing.inQuart(t) return t ^ 4 end

---@param t number
---@return number
function Easing.outQuart(t) return 1 - (t - 1) ^ 4 end

---@param t number
---@return number
function Easing.inOutQuart(t) return t < 0.5 and 8 * t ^ 4 or 1 - 8 * (t - 1) ^ 4 end

-- quintic
---@param t number
---@return number
function Easing.inQuint(t) return t ^ 5 end

---@param t number
---@return number
function Easing.outQuint(t) return 1 + (t - 1) ^ 5 end

---@param t number
---@return number
function Easing.inOutQuint(t) return t < 0.5 and 16 * t ^ 5 or 1 + 16 * (t - 1) ^ 5 end

-- sine
---@param t number
---@return number
function Easing.inSine(t) return 1 - math.cos(t * math.pi / 2) end

---@param t number
---@return number
function Easing.outSine(t) return math.sin(t * math.pi / 2) end

---@param t number
---@return number
function Easing.inOutSine(t) return -0.5 * (math.cos(math.pi * t) - 1) end

-- exponential
---@param t number
---@return number
function Easing.inExpo(t) return (t == 0) and 0 or 2 ^ (10 * (t - 1)) end

---@param t number
---@return number
function Easing.outExpo(t) return (t == 1) and 1 or 1 - 2 ^ (-10 * t) end

---@param t number
---@return number
function Easing.inOutExpo(t)
    if t == 0 or t == 1 then return t end
    if t < 0.5 then return 0.5 * 2 ^ (20 * t - 10) end
    return 1 - 0.5 * 2 ^ (-20 * t + 10)
end

-- circular
---@param t number
---@return number
function Easing.inCirc(t) return 1 - math.sqrt(1 - t * t) end

---@param t number
---@return number
function Easing.outCirc(t) return math.sqrt((2 - t) * t) end

---@param t number
---@return number
function Easing.inOutCirc(t)
    if t < 0.5 then return 0.5 * (1 - math.sqrt(1 - 4 * t * t)) end
    return 0.5 * (math.sqrt(-((2 * t - 3) * (2 * t - 1))) + 1)
end

-- back
---@param t number
---@return number
function Easing.inBack(t)
    local c1, c3 = 1.70158, 1.70158 + 1
    return c3 * t * t * t - c1 * t * t
end

---@param t number
---@return number
function Easing.outBack(t)
    local c1, c3 = 1.70158, 1.70158 + 1
    return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

---@param t number
---@return number
function Easing.inOutBack(t)
    local c1, c2 = 1.70158, 1.70158 * 1.525
    if t < 0.5 then
        return (2 * t) ^ 2 * ((c2 + 1) * 2 * t - c2) / 2
    else
        return ((2 * t - 2) ^ 2 * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
    end
end

-- elastic
---@param t number
---@return number
function Easing.inElastic(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    return -2 ^ (10 * (t - 1)) * math.sin((t - 1.1) * 5 * math.pi)
end

---@param t number
---@return number
function Easing.outElastic(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    return 2 ^ (-10 * t) * math.sin((t - 0.1) * 5 * math.pi) + 1
end

---@param t number
---@return number
function Easing.inOutElastic(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    if t < 0.5 then
        return -0.5 * 2 ^ (20 * t - 10) * math.sin((20 * t - 11.125) * (2 * math.pi / 4.5))
    else
        return 0.5 * 2 ^ (-20 * t + 10) * math.sin((20 * t - 11.125) * (2 * math.pi / 4.5)) + 1
    end
end

-- bounce helpers
---@param t number
---@return number
local function outBounce(t)
    local n1, d1 = 7.5625, 2.75
    if t < 1 / d1 then
        return n1 * t * t
    elseif t < 2 / d1 then
        t = t - 1.5 / d1
        return n1 * t * t + 0.75
    elseif t < 2.5 / d1 then
        t = t - 2.25 / d1
        return n1 * t * t + 0.9375
    else
        t = t - 2.625 / d1
        return n1 * t * t + 0.984375
    end
end

---@param t number
---@return number
function Easing.inBounce(t) return 1 - outBounce(1 - t) end

---@param t number
---@return number
function Easing.outBounce(t) return outBounce(t) end

---@param t number
---@return number
function Easing.inOutBounce(t)
    if t < 0.5 then return (1 - outBounce(1 - 2 * t)) / 2 end
    return (1 + outBounce(2 * t - 1)) / 2
end

return Easing
