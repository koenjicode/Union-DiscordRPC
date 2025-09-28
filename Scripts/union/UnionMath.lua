-- UnionMath.lua
local UnionMath = {}

--- Clamp a value between min and max
---@param value number
---@param min number
---@param max number
---@return number
function UnionMath.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

--- Linear interpolation between a and b
---@param a number
---@param b number
---@param t number # 0-1 range
---@return number
function UnionMath.Lerp(a, b, t)
    return a + (b - a) * t
end

--- Round a number to nearest integer
---@param value number
---@return number
function UnionMath.Round(value)
    return math.floor(value + 0.5)
end

return UnionMath