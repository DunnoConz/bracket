--!strict

local Error = require("./Error") -- This should be correct as Error is in the same Core dir

-- Represents a Racket pair (cons cell)
-- REMOVED: export type Pair = { car: any, cdr: any }

-- We will use Luau 'nil' to represent Racket's empty list '().
-- NOTE: This is a slight divergence from Racket which has a distinct 'null' object.
export type List = any -- Changed Pair to any

-- Metatable to identify pairs
local PairMeta = { __metatable = "BracketPair" } -- Protect metatable
PairMeta.__index = PairMeta -- Allow potential future methods via metatable

local PairModule = {}

-- Constructor now returns 'any' (but it's tagged with PairMeta)
function PairModule.cons(a: any, b: any): any
	local p = {}
	p.car = a
	p.cdr = b
	setmetatable(p, PairMeta)
	return p -- No cast needed
end

-- Accessors (parameter type any, return type any)
function PairModule.car(p: any): any
	-- Handle nil input
	if p == nil then
		return nil
	end
	
	-- Check for proper pair
	if typeof(p) ~= "table" or getmetatable(p) ~= "BracketPair" then
		error(Error.format(Error.new("car: expected pair, got " .. typeof(p), "TypeError")))
	end
	
	-- Access the car property (might be nil which is fine)
	return p.car
end

function PairModule.cdr(p: any): any
	-- Handle nil input
	if p == nil then
		return nil
	end
	
	-- Check for proper pair
	if typeof(p) ~= "table" or getmetatable(p) ~= "BracketPair" then
		error(Error.format(Error.new("cdr: expected pair, got " .. typeof(p), "TypeError")))
	end
	
	-- Access the cdr property (might be nil which is fine)
	return p.cdr
end

-- Mutators (parameter type any)
function PairModule.set_car(p: any, value: any)
	if getmetatable(p) ~= "BracketPair" then
		error(Error.format(Error.new("set-car!: expected pair, got " .. typeof(p), "TypeError")))
	end
	-- Assume field exists if metatable matches
	p.car = value -- No cast needed
end

function PairModule.set_cdr(p: any, value: any)
	if getmetatable(p) ~= "BracketPair" then
		error(Error.format(Error.new("set-cdr!: expected pair, got " .. typeof(p), "TypeError")))
	end
	-- Assume field exists if metatable matches
	p.cdr = value -- No cast needed
end

-- Predicates
function PairModule.is_pair(value: any): boolean
	-- Check using the metatable and ensure it has a car property
	if typeof(value) ~= "table" then
		return false
	end
	
	local meta = getmetatable(value)
	-- The metatable itself is set to "BracketPair", so check for that value directly
	-- Note: We only check for car property, not cdr, as some intermediate parse states
	-- may have valid pairs with missing cdr properties that still need to be treated as pairs
	return meta == "BracketPair" and value.car ~= nil
end

function PairModule.is_null(value: any): boolean
	return value == nil
end

-- Check if a value is a proper list (a chain of pairs ending in nil)
function PairModule.is_list(value: any): boolean
	local slow = value
	local fast = value

	while true do
		if PairModule.is_null(fast) then -- End condition: reached nil
			return true
		elseif PairModule.is_pair(fast) then
			local next_fast = PairModule.cdr(fast) -- No cast needed
			if PairModule.is_null(next_fast) then -- End condition: next is nil
				return true
			elseif PairModule.is_pair(next_fast) then -- Check if the step after fast is valid
				-- Move slow and fast
				slow = PairModule.cdr(slow) -- No cast needed
				fast = PairModule.cdr(next_fast) -- Move fast two steps
				if fast == slow then
					return false -- Cycle detected
				end
			else
				return false -- Improper list: cdr of cdr is not a pair or nil
			end
		else
			return false -- Improper list: encountered non-pair, non-nil element
		end
	end
end

return PairModule 