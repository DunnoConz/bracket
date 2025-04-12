--!strict

-- Utility functions for handling Bracket syntax (AST, Patterns, Templates)

local Environment = require("../Evaluator/Environment") 
local Parser = require("./init") 
local Error = require("../Core/Error") 
local Pair = require("../Core/Pair") 

-- Types
-- Assuming Environment exports Env type correctly now
-- Assuming Parser exports Ast type correctly now
type Env = Environment.Env 
type Ast = Parser.Ast 

local SyntaxUtils = {}

-- Forward declarations for recursive functions within the module
-- Specify types more precisely if possible
local match_pattern: (pattern: any, value: any, env: Env) -> (boolean, Env?)
local expand_template: (template: any, env: Env) -> any
local ast_to_data_recursive: (ast: Ast, node_index: number) -> any

-- Convert AST node to raw Luau data structure
ast_to_data_recursive = function(ast: Ast, node_index: number): any
	-- Ensure ast fields are accessed correctly
	local node_type = ast.node_types[node_index] 

	if node_type == "NUMBER" or node_type == "BOOLEAN" or node_type == "NIL" then
		return ast.node_values[node_index]
	elseif node_type == "STRING" then
		return ast.node_values[node_index]
	elseif node_type == "SYMBOL" then
		return ast.node_values[node_index]
	elseif node_type == "LIST" then
		local list_range = ast.list_ranges[node_index] -- Check if list_ranges is correct field
		if not list_range or list_range.count == 0 then
			return {} -- Return empty Luau table for empty list node
		end
		local result = {}
		for i = 1, list_range.count do
			local child_index = ast.list_children_indices[list_range.start + i - 1] -- Check field name
			table.insert(result, ast_to_data_recursive(ast, child_index))
		end
		return result
	else
		local err = Error.new(string.format("Unknown AST node type: %s", tostring(node_type)), "InternalError")
		error(Error.format(err))
	end
end

-- Expose the function publicly
function SyntaxUtils.ast_to_data(ast: Ast, node_index: number): any
    return ast_to_data_recursive(ast, node_index)
end

-- Match a pattern (data) against a value (data) using an environment
match_pattern = function(pattern: any, value: any, env: Env): (boolean, Env?)
    if typeof(pattern) == "string" and pattern == "_" then
        return true, env -- Wildcard matches anything
    elseif typeof(pattern) == "string" and pattern:sub(1, 1) == "?" then
        local var_name = pattern:sub(2)
        -- Create a new environment extending the current one
        local new_env: Env = Environment.new(env)
        -- Use the define method from the new environment instance
        new_env.define(new_env, var_name, value)
        return true, new_env
    elseif typeof(pattern) == "table" and typeof(value) == "table" then
        if #pattern ~= #value then
            return false, nil -- Different lengths don't match
        end
        local current_env: Env? = env
        for i = 1, #pattern do
            if not current_env then return false, nil end -- Should not happen if logic is correct
            local success, next_env = match_pattern(pattern[i], value[i], current_env)
            if not success then
                return false, nil -- Sub-pattern failed to match
            end
            current_env = next_env -- Carry over bindings from sub-match
            if not current_env then return false, nil end -- Check again after assignment
        end
        return true, current_env -- Return accumulated environment
    else -- Literal match
        return pattern == value, env -- Return original env if literals match
    end
end

-- Expose the function publicly
function SyntaxUtils.match_pattern(pattern: any, value: any, env: Env): (boolean, Env?)
    return match_pattern(pattern, value, env)
end

-- Expand a template (data) using bindings from an environment
expand_template = function(template: any, env: Env): any
    if typeof(template) == "string" and template:sub(1, 1) == "?" then
        local var_name = template:sub(2)
        -- Use the lookup method from the environment instance
        local value = env.lookup(env, var_name) 
        if value == nil then
            local err = Error.new(string.format("Unbound variable in macro template: %s", var_name), "MacroError")
            error(Error.format(err))
        end
        return value
    elseif typeof(template) == "table" then
        local result = {}
        for _, item in ipairs(template) do
            table.insert(result, expand_template(item, env))
        end
        return result
    else -- Literal value in template
        return template
    end
end

-- Expose the function publicly
function SyntaxUtils.expand_template(template: any, env: Env): any
    return expand_template(template, env)
end


return SyntaxUtils 