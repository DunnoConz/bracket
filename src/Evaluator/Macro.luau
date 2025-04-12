--!strict

local Environment = require("./Environment")
-- local Evaluator = require("./init") -- Avoid cyclic require for now (points to Evaluator/init.luau)
local Pair = require("../Core/Pair") 
local Error = require("../Core/Error") 
local SyntaxUtils = require("../Parser/SyntaxUtils") 
-- local Parser = require("../Parser") -- Avoid cyclic require for now (points to Parser/init.luau)

type Env = Environment.Env
type BracketError = Error.Error

-- Simplified type for rule pairs: {pattern, template}
-- Using 'any' as precise tuple/list-of-tuples is causing issues.
type RulePair = {any}

local Macro = {}

-- Forward declarations using 'any' for complex types to bypass linter issues
-- local match_pattern: (pattern: any, value: any, env: Env) -> (boolean, Env?)
-- local expand_template: (template: any, env: Env) -> any

export type Macro = {
    name: string,
    transformer: (form: any, macroEnv: Env) -> any, -- Transformer receives form data and its definition env
    env: Env -- The environment where the macro was defined
}

-- Create a new macro
function Macro.new(name: string, transformer: (any, Env) -> any, env: Env): Macro
    return {
        name = name,
        transformer = transformer,
        env = env
    }
end

-- Expand a macro: call its transformer with the form data and definition environment
function Macro.expand(macro: Macro, form: any): any
    return macro.transformer(form, macro.env)
end

-- Define a macro in an environment
function Macro.define(env: Env, name: string, transformer: (any, Env) -> any)
    local macro = Macro.new(name, transformer, env)
    env:define(name, macro)
end

-- Check if a value is a macro (basic check)
function Macro.is_macro(value: any): boolean
    return type(value) == "table" and value.transformer ~= nil and value.name ~= nil and value.env ~= nil
end

-- Helper function to create a syntax-rules transformer function
-- Uses simplified RulePair type {any}
function Macro.syntax_rules(literals: {string}, rules: {RulePair}, env: Env): ((any, Env) -> any)
    return function(form: any, macro_env: Env): any -- form is the raw macro call data, e.g., {'my-macro', 1, 2}
        -- Match the form data (excluding macro name) against each rule's pattern
        local form_args = {}
        for i = 2, #form do table.insert(form_args, form[i]) end

        for _, rule in ipairs(rules) do
            -- Assuming RulePair is {pattern, template}
            if #rule ~= 2 then error("InternalError: Invalid RulePair structure") end
            local pattern = rule[1]
            local template = rule[2]
            -- Use SyntaxUtils.match_pattern
            local success, bindings = SyntaxUtils.match_pattern(pattern, form_args, Environment.new(nil))
            if success and bindings then
                -- Use SyntaxUtils.expand_template
                return SyntaxUtils.expand_template(template, bindings)
            end
        end
        -- Use Error module for formatting
        local err = Error.new(string.format("No matching pattern for macro expansion: %s", tostring(form)), "MacroError")
        error(Error.format(err))
    end
end

-- Remove local implementations of match_pattern and expand_template
-- match_pattern = function(...) ... end
-- expand_template = function(...) ... end

return Macro 