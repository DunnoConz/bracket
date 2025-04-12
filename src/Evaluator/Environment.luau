--!strict

local StandardLibrary = require("../Stdlib/StandardLibrary") -- Updated path
local Error = require("../Core/Error") -- Updated path
local Pair = require("../Core/Pair") -- Updated path

-- Define the Env type
export type Env = {
	vars: { [string]: any },
	outer: Env?,
	define: (env_self: Env, var: string, value: any) -> (), -- Method signature
	lookup: (env_self: Env, var: string) -> any,      -- Method signature
	set: (env_self: Env, var: string, value: any) -> (),
	add_builtins: (env_self: Env) -> ()
}

local Environment = {}

-- Type definition for the structure stored within an environment instance (internal detail)
type EnvironmentInstanceData = {
	bindings: {[string]: any},
	outer: Env?
}

-- **Reverted to original type definition using typeof(setmetatable(...))**
export type Env = typeof(setmetatable({} :: EnvironmentInstanceData, Environment))

-- Now set the __index after the type definition that uses Environment
Environment.__index = Environment

-- Type definitions for built-in functions
type BinaryOp = (any, any) -> any
type UnaryOp = (any) -> any
type VariadicOp = (...any) -> any

-- Function to create a new environment instance
function Environment.new(outer: Env?): Env
	local self: Env = {
		vars = {},
		outer = outer,
	} :: Env -- Explicit cast

	-- Define methods directly on the instance table
	self.define = function(env_self: Env, var: string, value: any)
		env_self.vars[var] = value
	end

	self.lookup = function(env_self: Env, var: string): any
		if env_self.vars[var] ~= nil then
			return env_self.vars[var]
		elseif env_self.outer then
			-- Recursively lookup using the outer env's method
			return env_self.outer.lookup(env_self.outer, var)
		else
			return nil -- Variable not found
		end
	end

	self.set = function(env_self: Env, var: string, value: any)
		if env_self.vars[var] ~= nil then
			env_self.vars[var] = value
		elseif env_self.outer then
			-- Recursively set using the outer env's method
			env_self.outer.set(env_self.outer, var, value)
		else
			-- Variable not defined in any accessible scope
			local err = Error.new(string.format("Cannot set! unbound variable: %s", var), "LookupError")
			error(Error.format(err))
		end
	end

	-- Helper to add standard library functions
	self.add_builtins = function(env_self: Env)
		-- Define builtins directly in the environment's vars table
		env_self.vars["#t"] = true
		env_self.vars["#f"] = false
		env_self.vars["nil"] = nil
		env_self.vars["+"] = function(...)
			local nums = {...}
			local sum = 0
			for _, n in ipairs(nums) do
				if typeof(n) ~= "number" then
					local err = Error.new("Operand must be a number for +", "TypeError")
					error(Error.format(err))
				end
				sum += n
			end
			return sum
		end
		env_self.vars["-"] = function(...)
			local nums = {...}
			if #nums == 0 then
				 local err = Error.new("No arguments provided to -", "ArityError")
				 error(Error.format(err))
			end
			local firstNum = nums[1]
			if typeof(firstNum) ~= "number" then
				local err = Error.new("First operand must be a number for -", "TypeError")
				error(Error.format(err))
			end
			local result = firstNum
			if #nums == 1 then
				return -result
			end
			for i = 2, #nums do
				if typeof(nums[i]) ~= "number" then
					 local err = Error.new("Subsequent operand must be a number for -", "TypeError")
					 error(Error.format(err))
				end
				result -= nums[i]
			end
			return result
		end
		env_self.vars["*"] = function(...)
			local nums = {...}
			local product = 1
			for _, n in ipairs(nums) do
				if typeof(n) ~= "number" then
					 local err = Error.new("Operand must be a number for *", "TypeError")
					 error(Error.format(err))
				end
				product *= n
			end
			return product
		end
		env_self.vars["/"] = function(...): number
			local nums = {...}
			if #nums == 0 then
				local err = Error.new("No arguments provided to /", "ArityError")
				error(Error.format(err))
			end
			local firstNum = nums[1]
			if typeof(firstNum) ~= "number" then
				local err = Error.new("First operand must be a number for /", "TypeError")
				error(Error.format(err))
			end
			local result = firstNum
			if #nums == 1 then
				if result == 0 then
					local err = Error.new("Division by zero", "ArithmeticError")
					error(Error.format(err))
				end
				return 1 / result
			end
			for i = 2, #nums do
				if typeof(nums[i]) ~= "number" then
					local err = Error.new("Subsequent operand must be a number for /", "TypeError")
					error(Error.format(err))
				end
				if nums[i] == 0 then
					local err = Error.new("Division by zero", "ArithmeticError")
					error(Error.format(err))
				end
				result /= nums[i]
			end
			return result
		end
		env_self.vars["="] = function(...)
			local args = {...}
			if #args < 2 then
				 local err = Error.new("= requires at least 2 arguments", "ArityError")
				 error(Error.format(err))
			end
			for i = 1, #args - 1 do
				if args[i] ~= args[i + 1] then
					return false
				end
			end
			return true
		end
		env_self.vars["<"] = function(...)
			local args = {...}
			if #args < 2 then
				 local err = Error.new("< requires at least 2 arguments", "ArityError")
				 error(Error.format(err))
			end
			for i = 1, #args - 1 do
				if typeof(args[i]) ~= "number" or typeof(args[i + 1]) ~= "number" then
					 local err = Error.new("Operands must be numbers for <", "TypeError")
					 error(Error.format(err))
				end
				if not (args[i] < args[i + 1]) then
					return false
				end
			end
			return true
		end
		env_self.vars[">"] = function(...)
			local args = {...}
			if #args < 2 then
				 local err = Error.new("> requires at least 2 arguments", "ArityError")
				 error(Error.format(err))
			end
			for i = 1, #args - 1 do
				if typeof(args[i]) ~= "number" or typeof(args[i + 1]) ~= "number" then
					 local err = Error.new("Operands must be numbers for >", "TypeError")
					 error(Error.format(err))
				end
				if not (args[i] > args[i + 1]) then
					return false
				end
			end
			return true
		end
		env_self.vars["car"] = function(p: any): any
			if not Pair.is_pair(p) then
				 local err = Error.new("car: argument must be a pair", "TypeError")
				 error(Error.format(err))
			end
			return Pair.car(p)
		end
		env_self.vars["cdr"] = function(p: any): any
			if not Pair.is_pair(p) then
				 local err = Error.new("cdr: argument must be a pair", "TypeError")
				 error(Error.format(err))
			end
			return Pair.cdr(p)
		end
		env_self.vars["cons"] = function(a: any, b: any): any
			return Pair.cons(a, b)
		end
		env_self.vars["list"] = function(...): any
			local args = {...}
			local result: any = nil
			for i = #args, 1, -1 do
				result = Pair.cons(args[i], result)
			end
			return result
		end
		env_self.vars["display"] = function(x: any): nil
			print(tostring(x))
			return nil
		end
		env_self.vars["newline"] = function(): nil
			print("")
			return nil
		end
		env_self.vars["modulo"] = function(a: number, b: number): number
			if typeof(a) ~= "number" or typeof(b) ~= "number" then
				local err = Error.new("Operands must be numbers for modulo", "TypeError")
				error(Error.format(err))
			end
			if b == 0 then
				local err = Error.new("Modulo by zero", "ArithmeticError")
				error(Error.format(err))
			end
			return a % b
		end
		env_self.vars["abs"] = function(a: number): number
			if typeof(a) ~= "number" then
				local err = Error.new("Operand must be a number for abs", "TypeError")
				error(Error.format(err))
			end
			return math.abs(a)
		end
		-- Add more built-ins from StandardLibrary here...
	end

	return self
end

-- Method to look up a variable only in the local environment
function Environment:lookup_local(name: string): any
	-- Rely on implicit self typing
	return self.vars[name]
end

-- Add Racket's core built-in functions and values
function Environment:add_builtins()
	-- Cast self explicitly here to potentially resolve linter issues within this function
	local env_self = self :: Env
	-- Boolean values
	env_self:define("#t", true)
	env_self:define("#f", false)

	-- Arithmetic
	env_self:define("+", function(...): number
		local nums = {...}
		local sum = 0
		for _, n in ipairs(nums) do
			if typeof(n) ~= "number" then
				local Error = require("./Error")
				local err = Error.new("Operand must be a number for +", "TypeError")
				error(Error.format(err))
			end
			sum += n
		end
		return sum
	end)

	env_self:define("-", function(...): number
		local nums = {...}
		if #nums == 0 then
			local Error = require("./Error")
			local err = Error.new("No arguments provided to -", "ArityError")
			error(Error.format(err))
		end
		local firstNum = nums[1]
		if typeof(firstNum) ~= "number" then
			local Error = require("./Error")
			local err = Error.new("First operand must be a number for -", "TypeError")
			error(Error.format(err))
		end
		local result = firstNum
		if #nums == 1 then
			return -result
		end
		for i = 2, #nums do
			if typeof(nums[i]) ~= "number" then
				local Error = require("./Error")
				local err = Error.new("Subsequent operand must be a number for -", "TypeError")
				error(Error.format(err))
			end
			result -= nums[i]
		end
		return result
	end)

	env_self:define("*", function(...): number
		local nums = {...}
		local product = 1
		for _, n in ipairs(nums) do
			if typeof(n) ~= "number" then
				local Error = require("./Error")
				local err = Error.new("Operand must be a number for *", "TypeError")
				error(Error.format(err))
			end
			product *= n
		end
		return product
	end)

	env_self:define("/", function(...): number
		local nums = {...}
		if #nums == 0 then
			local Error = require("./Error")
			local err = Error.new("No arguments provided to /", "ArityError")
			error(Error.format(err))
		end
		local firstNum = nums[1]
		if typeof(firstNum) ~= "number" then
			local Error = require("./Error")
			local err = Error.new("First operand must be a number for /", "TypeError")
			error(Error.format(err))
		end
		local result = firstNum
		if #nums == 1 then
			if result == 0 then
				local Error = require("./Error")
				local err = Error.new("Division by zero", "ArithmeticError")
				error(Error.format(err))
			end
			return 1 / result
		end
		for i = 2, #nums do
			if typeof(nums[i]) ~= "number" then
				local Error = require("./Error")
				local err = Error.new("Subsequent operand must be a number for /", "TypeError")
				error(Error.format(err))
			end
			if nums[i] == 0 then
				local Error = require("./Error")
				local err = Error.new("Division by zero", "ArithmeticError")
				error(Error.format(err))
			end
			result /= nums[i]
		end
		return result
	end)

	-- Comparisons
	env_self:define("=", function(...): boolean
		local args = {...}
		if #args < 2 then
			local Error = require("./Error")
			local err = Error.new("= requires at least 2 arguments", "ArityError")
			error(Error.format(err))
		end
		local first = args[1]
		for i = 2, #args do
			if args[i] ~= first then
				return false
			end
		end
		return true
	end)

	env_self:define("<", function(...): boolean
		local args = {...}
		if #args < 2 then
			local Error = require("./Error")
			local err = Error.new("< requires at least 2 arguments", "ArityError")
			error(Error.format(err))
		end
		for i = 1, #args - 1 do
			if typeof(args[i]) ~= "number" or typeof(args[i + 1]) ~= "number" then
				local Error = require("./Error")
				local err = Error.new("Operands must be numbers for <", "TypeError")
				error(Error.format(err))
			end
			if args[i] >= args[i + 1] then
				return false
			end
		end
		return true
	end)

	env_self:define(">", function(...): boolean
		local args = {...}
		if #args < 2 then
			local Error = require("./Error")
			local err = Error.new("> requires at least 2 arguments", "ArityError")
			error(Error.format(err))
		end
		for i = 1, #args - 1 do
			if typeof(args[i]) ~= "number" or typeof(args[i + 1]) ~= "number" then
				local Error = require("./Error")
				local err = Error.new("Operands must be numbers for >", "TypeError")
				error(Error.format(err))
			end
			if args[i] <= args[i + 1] then
				return false
			end
		end
		return true
	end)

	-- List operations (TODO: Update for Pair-based lists)
	env_self:define("cons", Pair.cons) -- Use Pair.cons directly

	env_self:define("car", function(p: any): any
		if not Pair.is_pair(p) then
			local Error = require("./Error")
			local err = Error.new("car: argument must be a pair", "TypeError")
			error(Error.format(err))
		end
		return Pair.car(p :: Pair.Pair) -- Use Pair.car
	end)

	env_self:define("cdr", function(p: any): any
		if not Pair.is_pair(p) then
			local Error = require("./Error")
			local err = Error.new("cdr: argument must be a pair", "TypeError")
			error(Error.format(err))
		end
		return Pair.cdr(p :: Pair.Pair) -- Use Pair.cdr
	end)

	env_self:define("null?", Pair.is_null) -- Use Pair.is_null

	env_self:define("list", function(...): Pair.List -- Return Pair.List
		local args = {...}
		local result: Pair.List = nil
		-- Build list backwards using cons
		for i = #args, 1, -1 do
			result = Pair.cons(args[i], result)
		end
		return result
	end)

	-- Type predicates
	env_self:define("number?", function(x: any): boolean
		return typeof(x) == "number"
	end)

	env_self:define("string?", function(x: any): boolean
		return typeof(x) == "string"
	end)

	env_self:define("boolean?", function(x: any): boolean
		return typeof(x) == "boolean"
	end)

	env_self:define("procedure?", function(x: any): boolean
		return typeof(x) == "function"
	end)

	env_self:define("pair?", Pair.is_pair) -- Use Pair.is_pair
	env_self:define("list?", Pair.is_list) -- Use Pair.is_list

	-- I/O
	env_self:define("display", function(x: any): nil
		-- TODO: Implement proper Racket-style printing for pairs/lists
		-- For now, just use tostring which will show table structure for pairs
		print(tostring(x))
		return nil
	end)

	-- REMOVED TestKit functions from environment

	-- Add more built-ins as needed
end

return Environment 