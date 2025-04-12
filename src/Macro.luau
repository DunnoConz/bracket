--!strict

local Types = require(script.Parent.Types)
local Ast = require(script.Parent.Ast)
local Environment = require(script.Parent.Environment)

type Env = Environment.Env

-- Define the type for macro transformer functions
export type MacroTransformer = (node: Ast.ListNode, env: Env) -> Ast.Node

export type Macro = typeof(setmetatable({} :: {
	name: string,
	transformer: MacroTransformer,
	defining_env: Env,
}, {} :: Types.ClassMetatable<Macro>))

local Macro: Types.Class<Macro> = {} :: any
Macro.__index = Macro

function Macro.new(name: string, transformer: MacroTransformer, env: Env): Macro
	local self = setmetatable({} :: any, Macro)
	self.name = name
	self.transformer = transformer
	self.defining_env = env
	return self
end

-- Placeholder for parsing syntax-rules
-- TODO: Implement the actual parsing logic
function Macro.parse_syntax_rules(syntax_rules_node: Ast.ListNode, env: Env): MacroTransformer
	print("Parsing syntax-rules:", syntax_rules_node)
	-- Placeholder implementation: returns a dummy transformer
	return function(node: Ast.ListNode, expansion_env: Env): Ast.Node
		print("Dummy transformer called for", node)
		-- Return the original node unchanged for now
		return node
	end
end

function Macro.get_name(self: Macro): string
	return self.name
end

function Macro.get_transformer(self: Macro): MacroTransformer
	return self.transformer
end

function Macro.get_definition_env(self: Macro): Env
	return self.defining_env
end

return Macro 