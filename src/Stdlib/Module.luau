--!strict

local Evaluator = require("../Evaluator")
local Environment = require("../Evaluator/Environment")
local Parser = require("../Parser")
local Error = require("../Core/Error")
local fs = require("@lune/fs") -- Lune filesystem module
local path = require("@lune/path") -- Adding path module for path manipulation

-- Types
type Env = Environment.Env
-- Assuming Parser exports Ast type
type Ast = Parser.Ast

-- Internal type for Module representation (consider if needed)
-- export type Module = {
--     name: string,
--     exports: { [string]: any },
--     env: Env
-- }

local Module = {}

local loaded_modules: { [string]: Env } = {}

function Module.find_module_path(module_name: string, current_path: string?): string?
	local rel_path = module_name .. ".luau" 
	
	-- Check relative to current path
	if current_path then
		local dir = path.dirname(current_path)
		local test_path = path.join(dir, rel_path)
		if fs.isFile(test_path) then return test_path end
	end
	
	-- Check relative to src
	local src_path = path.join("src", rel_path)
	if fs.isFile(src_path) then return src_path end
	
	return nil
end

-- Load a module and return its environment
function Module.load(module_path: string, outer_env: Env?): Env
    if loaded_modules[module_path] then
        return loaded_modules[module_path]
    end

    print("DEBUG - Loading module:", module_path)

    local module_env: Env = Environment.new(outer_env) -- Use Environment.new

    local code: string
    local read_success, read_result = pcall(fs.readFile, module_path)
    if not read_success or typeof(read_result) ~= "string" then
        local err = Error.new(string.format("Could not read module file: %s. Reason: %s", module_path, tostring(read_result or "Unknown error")), "ImportError")
        error(Error.format(err))
    end
    code = read_result :: string
    
    local ast: Ast = Parser.parse(code)
    
    -- Use the main evaluate function which handles the AST structure
    Evaluator.evaluate(ast, module_env)

    loaded_modules[module_path] = module_env
    return module_env
end

-- Function to import specific bindings from a module environment into a target environment
function Module.import(target_env: Env, module_env: Env, bindings: {string}?)
    if bindings then
        -- Import specific bindings
        for _, name in ipairs(bindings) do
            -- Use the lookup method defined on the Env instance
            local value = module_env.lookup(module_env, name) 
            if value == nil then
                local err = Error.new(string.format("Binding '%s' not found in module", name), "ImportError")
                warn(Error.format(err)) 
            else
                -- Use the define method defined on the Env instance
                target_env.define(target_env, name, value) 
            end
        end
    else
        -- Import all bindings
        for name, value in pairs(module_env.vars) do -- Access vars directly
            target_env.define(target_env, name, value)
        end
    end
end

-- Functions below seem related to an older/different module concept (defining exports)
-- Commenting them out for now as they conflict with the load/import logic above.

--[[ 
function Module.new(name: string): Module
    return {
        name = name,
        exports = {},
        env = Environment.new(nil) -- Create fresh env for module
    }
end

function Module.define(module: Module, name: string, value: any)
    module.env.define(module.env, name, value)
    module.exports[name] = value
end

function Module.load_from_string(name: string, code: string): Module
    local module = Module.new(name)
    local ast: Ast = Parser.parse(code)
    Evaluator.evaluate(ast, module.env)
    return module
end

function Module.load_from_file(name: string, path: string): Module
    -- Replace io with fs
    local read_success, code = pcall(fs.readFile, path)
    if not read_success or typeof(code) ~= "string" then
        local err = Error.new(string.format("Could not read module file: %s", path), "FileError")
        error(Error.format(err))
    end
    return Module.load_from_string(name, code :: string)
end

function Module.provide(module: Module, ...: string)
    local names = {...}
    for _, name in ipairs(names) do
        local value = module.env.lookup(module.env, name)
        if value == nil then
            local err = Error.new(string.format("Cannot provide undefined name: %s", name), "NameError")
            error(Error.format(err))
        end
        module.exports[name] = value
    end
end

function Module.require(name: string): Module
    local module_path = Module.find_module_path(name, nil) -- Add mechanism to get current path?
    if not module_path then
        local err = Error.new(string.format("Cannot find module: %s", name), "ImportError")
        error(Error.format(err))
    end
    -- This seems to create a new instance each time, not reuse loaded_modules
    -- Need to reconcile Module.load and this require logic
    return Module.load_from_file(name, module_path)
end
]]

return Module 