---Represents a random number generator object. (WELL512 algorithm)
---@class lstg.random
ran = {}

local well512 = lstg.Rand()

---Returns a randomly generated Integer number.
---@param a number Minimum (inclusive)
---@param b number Maximum (inclusive)
---@return number @Random integer in range [a, b]
function ran:Int(a, b)
    if a > b then
        return well512:Int(b, a)
    else
        return well512:Int(a, b)
    end
end

---Returns a randomly generated Decimal/Float number.
---@param a number Minimum (inclusive)
---@param b number Maximum (inclusive)
---@return number @Random float in range [a, b]
function ran:Float(a, b)
    return well512:Float(a, b)
end

---@return number @Random sign, -1 or 1
function ran:Sign()
    return well512:Sign()
end

---Sets the seed of the random value generator.
---@param v number
function ran:Seed(v)
    well512:Seed(v)
end

---Gets the current seed
---@return number
function ran:GetSeed()
    return well512:GetSeed()
end

---Randomly returns one of the passed arguments.
---@param ... any?
---@return any @One of the passed arguments
function ran:Choose(...)
    local args = { ... }
    if #args == 0 then return end
    if #args == 1 then return args[1] end

    local n = ran:Int(1, #args)
    return args[n]
end