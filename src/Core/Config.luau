--!nostrict

-- Configuration options for the Bracket language

local Config = {
    -- Type checking options
    strict_mode = false,         -- When true, enforce all type checks
    warn_on_type_error = true,   -- When true but not in strict mode, warn on type errors without failing
    
    -- Language features
    allow_implicit_conversion = true,   -- Allow implicit conversion between compatible types
    infer_return_types = true,          -- Attempt to infer return types when not specified
    
    -- Runtime options
    optimize_known_types = false,       -- Use type information for optimizations
    check_assertions = true,            -- Enable runtime assertion checking
    
    -- Parsing options
    strict_syntax = false,              -- Enforce strict syntax rules

    -- Development options
    development_mode = true,           -- Used for testing and development of the language itself
}

-- Function to enable strict mode (enables all type checking features)
function Config.enable_strict_mode()
    Config.strict_mode = true
    Config.strict_syntax = true
    Config.allow_implicit_conversion = false
end

-- Function to disable strict mode
function Config.disable_strict_mode()
    Config.strict_mode = false
    Config.strict_syntax = false
    Config.allow_implicit_conversion = true
end

-- Parse a directive comment at the top of a file to determine mode
-- Accepts `#lang bracket` or `#lang bracket/typed`
function Config.parse_lang_directive(code: string)
    local first_line = code:match("^[^\n]*")
    if first_line and first_line:match("^%s*#lang%s+bracket/typed") then
        Config.enable_strict_mode()
        return true
    elseif first_line and first_line:match("^%s*#lang%s+bracket") then
        Config.disable_strict_mode()
        return true
    end
    return false
end

return Config 