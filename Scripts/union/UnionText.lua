-- UnionText.lua
local Text = {}

--- Capitalize the first letter, lowercase the rest
local function CapitalizeWord(word)
    if #word == 0 then return word end
    return word:sub(1,1):upper() .. word:sub(2):lower()
end

--- Convert a string like "HATSUNE MIKU" or "E-STADIUM" into title case.
--- Handles spaces and hyphens separately.
function Text.ToTitleCase(rawtext)
    local str = rawtext:ToString()
    local result = str:gsub("[^%s]+", function(word)
        -- For hyphenated words, split and capitalize each part
        local parts = {}
        for part in word:gmatch("[^-]+") do
            table.insert(parts, CapitalizeWord(part))
        end
        return table.concat(parts, "-")
    end)
    return result
end

return Text