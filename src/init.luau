--!strict

-- NOTE: Linter errors like "Unknown require: unsupported path" or "Unknown type" are expected 
-- when using cross-environment require mechanisms. These won't cause runtime errors.

-- Check environment using BRACKET_ENV variable (set in run_tests.sh for Lune)
local process = require("@lune/process")
local isLuneTest = process.env.BRACKET_ENV == "LUNE"

-- Import Util.Require differently based on environment
local Require
if not isLuneTest then
	-- Assume Roblox environment if not explicitly Lune test
	Require = require(script.Parent.Util.Require) -- Roblox path
else
	-- Use Lune path if BRACKET_ENV is set
	Require = require("Util/Require") -- Lune path (relative to src)
end

-- Import dependencies using the environment-agnostic require
local Environment = Require.require("Evaluator.Environment")
local Evaluator = Require.require("Evaluator")
local Parser = Require.require("Parser")
local StandardLibrary = Require.require("Stdlib.StandardLibrary")
local Error = Require.require("Core.Error")
-- local Config = require("./Core/Config") -- Not used directly here, but good to keep track
-- local Types = require("./Types") -- Will be used when implementing typing

local Bracket = {}

-- Create a new environment with built-in functions
function Bracket.create_env(outer: any?): any
	local env = Environment.new(outer)
	env:add_builtins() -- This function likely needs path updates too
	return env
end

-- Global environment for top-level evaluation
local global_env = Bracket.create_env()

-- Main entry point for running Bracket code
function Bracket.run(code: string): any
	local ast = Parser.parse(code)
	return Evaluator.evaluate(ast, global_env)
end

-- Run with a specific environment
function Bracket.run_with_env(code: string, env: Environment.Env): any
	local ast = Parser.parse(code)
	return Evaluator.evaluate(ast, env)
end

-- Export the environment type
export type Env = Environment.Env

-- Run tests in the given string (This might be deprecated if using the test runner)
function Bracket.run_tests(test_string: string): any
	local ast = Parser.parse(test_string)
	local env = Bracket.create_env()
	
	-- Add test functions to the environment
	env:define("test", function(name: any, body: any)
		-- Print name if it's a string
		if type(name) == "string" then
			print("Running test:", name)
		end
		return body
	end)
	
	env:define("assert-equal", function(actual: any, expected: any)
		if actual ~= expected then
			local err = Error.format(Error.new(
				string.format("Assertion Failed: Expected %s, got %s", 
					tostring(expected), tostring(actual)),
				"AssertionError"
			))
			error(err)
		end
		return true
	end)
	
	return Evaluator.evaluate(ast, env)
end

-- Evaluate a string of Bracket code
function Bracket.evaluate(code: string): any
	local ast = Parser.parse(code)
	return Evaluator.evaluate(ast, global_env)
end

return Bracket 