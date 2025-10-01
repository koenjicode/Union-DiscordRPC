-- UnionMath.lua
local UnionMath = {}

--- Clamp a value between min and max
function UnionMath.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

--- Linear interpolation between a and b
function UnionMath.Lerp(a, b, t)
    return a + (b - a) * t
end

--- Round a number to nearest integer
function UnionMath.Round(value)
    return math.floor(value + 0.5)
end

return UnionMath