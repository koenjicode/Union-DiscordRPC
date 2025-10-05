local Text = {}

-- Capitalize normally, but preserve known acronyms (AI, IA, SI, etc.)
local function CapitalizeWord(word)
    local upper = word:upper()
    -- Preserve acronyms that should stay uppercase
    local acronyms = {
        AI = true,
        IA = true,
        SI = true,
    }

    if acronyms[upper] then
        return upper
    end

    if #word == 0 then return word end
    return word:sub(1,1):upper() .. word:sub(2):lower()
end

-- Detect and normalize AI-like suffixes such as "(AI RACER)", "(CORREDOR IA)", "(KIEROWCA SI)"
local function NormalizeAISuffix(str)
    local prefix, ai_part = str:match("^(.-)%s*%((.-)%)$")
    if ai_part then
        -- Capitalize each word while preserving acronyms
        local parts = {}
        for word in ai_part:gmatch("%S+") do
            table.insert(parts, CapitalizeWord(word))
        end
        return string.format("%s (%s)", prefix, table.concat(parts, " "))
    end
    return str
end

-- Convert strings like "HATSUNE MIKU" or "E-STADIUM" into title case,
-- handling spaces, hyphens, and localized AI suffixes.
function Text.ToTitleCase(rawtext)
    local str = rawtext.ToString and rawtext:ToString() or tostring(rawtext)

    -- Title case each word, handling hyphens separately
    local result = str:gsub("[^%s]+", function(word)
        local parts = {}
        for part in word:gmatch("[^-]+") do
            table.insert(parts, CapitalizeWord(part))
        end
        return table.concat(parts, "-")
    end)

    -- Normalize localized AI suffixes
    result = NormalizeAISuffix(result)

    return result
end

return Text