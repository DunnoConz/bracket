--!strict

-- Check environment using BRACKET_ENV variable (set in run_tests.sh for Lune)
local process = require("@lune/process")
local isLuneTest = process.env.BRACKET_ENV == "LUNE"

-- Import Util.Require differently based on environment
local Require
if not isLuneTest then
	-- Assume Roblox environment if not explicitly Lune test
	Require = require(script.Parent.Parent.Util.Require) -- Roblox path
else
	-- Use Lune path if BRACKET_ENV is set
	Require = require("../Util/Require") -- Lune path (relative to src/Parser)
end

-- Import dependencies using the environment-agnostic require
local Pair = Require.require("Core.Pair")
local Error = Require.require("Core.Error")

-- Type definitions for DOD AST
type NodeType = "SYMBOL" | "NUMBER" | "STRING" | "BOOLEAN" | "LIST" | "NIL"
type NodeValue = string | number | boolean | nil
type ListRange = { start: number, count: number }

export type Ast = {
	-- Node Data (Parallel Arrays)
	node_types: { NodeType },
	node_values: { NodeValue }, -- Value for atoms, nil for lists

	-- List Structure
	list_children_indices: { number }, -- Flat array of all child indices for all lists
	list_ranges: { ListRange },        -- Maps list node index -> range in list_children_indices

	-- Root node index (usually 1)
	root_node_index: number,
}

-- Type definition for the output S-Expression structure
export type SExpression = any -- Changed Pair.Pair to any

local Parser = {}

-- Forward declaration for the conversion function
local convert_ast_node_to_sexpr: (ast: Ast, node_index: number) -> SExpression

-- Simple Tokenizer
local function tokenize(code: string): {string}
	local tokens = {}
	-- Replace parentheses with spaces around them for easier splitting
	local spaced_code = code:gsub("%(", " ( "):gsub("%)", " ) ")
	
	-- Handle string literals by preserving spaces within quotes
	local in_string = false
	local current_token = ""
	
	for i = 1, #spaced_code do
		local char = spaced_code:sub(i, i)
		if char == '"' then
			in_string = not in_string
			current_token ..= char
		elseif in_string then
			current_token ..= char
		elseif char:match("%s") then
			if #current_token > 0 then
				table.insert(tokens, current_token)
				current_token = ""
			end
		else
			current_token ..= char
		end
	end
	
	if #current_token > 0 then
		table.insert(tokens, current_token)
	end
	
	-- Debug print the tokens for function definitions
	if code:match("define%s+%(add%s+") then
		print("DEBUG: Tokenized function definition:")
		for i, token in ipairs(tokens) do
			print(string.format("  Token %d: %s", i, token))
		end
	end
	
	return tokens
end

-- AST Builder Helpers
local function add_node(ast: Ast, node_type: NodeType, value: NodeValue): number
	table.insert(ast.node_types, node_type)
	table.insert(ast.node_values, value)
	return #ast.node_types -- Return the index of the newly added node
end

local function add_list_node(ast: Ast, children_indices: {number}): number
	local list_node_index = add_node(ast, "LIST", nil)

	local start_index = #ast.list_children_indices + 1
	local count = #children_indices
	for _, child_index in ipairs(children_indices) do
		table.insert(ast.list_children_indices, child_index)
	end

	-- Store the range for this list's children
	ast.list_ranges[list_node_index] = { start = start_index, count = count }

	return list_node_index
end

-- Recursive Parsing function
local function parse_expression(tokens: {string}, index: number, ast: Ast): (number, number)
	local token = tokens[index]
	print("DEBUG: Parsing token:", token, "at index", index, "of", #tokens)
	index += 1

	if token == "(" then
		local children_indices = {}
		while tokens[index] ~= ")" do
			if index > #tokens then
				error("Syntax error: Unexpected end of input, missing ')'")
			end
			local child_node_index
			child_node_index, index = parse_expression(tokens, index, ast)
			table.insert(children_indices, child_node_index)
			print("DEBUG: Added child node index", child_node_index, "current index=", index)
		end
		index += 1 -- Consume ')'
		local list_node_index = add_list_node(ast, children_indices)
		print("DEBUG: Created list node index", list_node_index, "with", #children_indices, "children")
		return list_node_index, index
	elseif token == ")" then
		error("Syntax error: Unexpected ')'")
	elseif token == "#t" then
		return add_node(ast, "BOOLEAN", true), index
	elseif token == "#f" then
		return add_node(ast, "BOOLEAN", false), index
	elseif token == "nil" then
		return add_node(ast, "NIL", nil), index
	else
		-- Handle string literals
		if token:sub(1, 1) == '"' and token:sub(-1) == '"' then
			-- Add as a string node but with quotes removed and a special prefix to distinguish from symbols
			-- Use a unique prefix that's unlikely to be used in normal symbols
			local str_value = "STRING:" .. token:sub(2, -2)
			return add_node(ast, "STRING", str_value), index
		end
		
		local num = tonumber(token)
		if num ~= nil then
			return add_node(ast, "NUMBER", num), index
		else
			-- Anything else is a symbol
			return add_node(ast, "SYMBOL", token), index
		end
	end
end

-- Recursive function to convert DOD AST node to S-Expression (Pair-based lists)
convert_ast_node_to_sexpr = function(ast: Ast, node_index: number): SExpression
	local node_type = ast.node_types[node_index]
	local node_value = ast.node_values[node_index]

	print("DEBUG: Converting node", node_index, "type =", node_type, "value =", node_value)

	if node_type == "SYMBOL" or node_type == "STRING" or node_type == "NUMBER" or node_type == "BOOLEAN" then
		return node_value :: any
	elseif node_type == "NIL" then
		return nil
	elseif node_type == "LIST" then
		local list_range = ast.list_ranges[node_index]
		if not list_range then
			local err = Error.new(string.format("Internal Parser Error: Missing list range for node %d", node_index), "InternalError")
			error(Error.format(err))
		end

		print("DEBUG: List range start =", list_range.start, "count =", list_range.count)

		-- Build the list from right to left using cons
		local current_list: any = nil -- Use 'any' for Pair.List
		for i = list_range.count, 1, -1 do
			local child_index = ast.list_children_indices[list_range.start + i - 1]
			print("DEBUG: Processing list item", i, "child_index =", child_index)
			local child_sexpr = convert_ast_node_to_sexpr(ast, child_index)
			current_list = Pair.cons(child_sexpr, current_list)
			print("DEBUG: After cons, current_list =", current_list)
		end
		return current_list
	else
		local err = Error.new(string.format("Internal Parser Error: Unknown node type '%s' during conversion", tostring(node_type)), "InternalError")
		error(Error.format(err))
	end
end

-- Main parse function - Now returns 'any' (representing Pair.List)
function Parser.parse(code: string): any -- Return type changed
	local tokens = tokenize(code)
	if #tokens == 0 then
		return nil
	end

	-- Build the internal DOD AST
	local ast: Ast = {
		node_types = {},
		node_values = {},
		list_children_indices = {},
		list_ranges = {},
		root_node_index = 0, -- Will be set after parsing
	}

	-- Create a top-level list node to hold multiple expressions internally
	local children_indices = {}
	local index = 1
	while index <= #tokens do
		local child_node_index
		child_node_index, index = parse_expression(tokens, index, ast)
		table.insert(children_indices, child_node_index)
	end
	local root_node_index = add_list_node(ast, children_indices)
	ast.root_node_index = root_node_index

	-- Now, convert the *children* of the internal root list node
	-- into the final Pair-based list of SExpressions.
	local final_sexpr_list: any = nil -- Use 'any' for Pair.List
	local root_range = ast.list_ranges[ast.root_node_index]
	if root_range then
		for i = root_range.count, 1, -1 do
			local child_node_index = ast.list_children_indices[root_range.start + i - 1]
			local child_sexpr = convert_ast_node_to_sexpr(ast, child_node_index)
			final_sexpr_list = Pair.cons(child_sexpr, final_sexpr_list)
		end
	else
        return nil
    end

	return final_sexpr_list
end

-- Make the tokenize function public
Parser.tokenize = tokenize

return Parser 