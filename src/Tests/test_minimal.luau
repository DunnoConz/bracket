--!strict

-- Import required modules
local Bracket = require("../init")
local Environment = require("../Evaluator/Environment")
local Parser = require("../Parser/init")
local Pair = require("../Core/pair")

print("Testing parser and lambda issue.")

-- Helper function to print the structure
local function print_ast_structure(ast, prefix)
    prefix = prefix or ""
    if ast == nil then
        print(prefix .. "nil")
        return
    end
    
    if not Pair.is_pair(ast) then
        print(prefix .. tostring(ast))
        return
    end
    
    print(prefix .. "Pair {")
    print(prefix .. "  car: " .. tostring(ast.car or "nil"))
    if ast.car ~= nil then
        print_ast_structure(ast.car, prefix .. "    ")
    end
    print(prefix .. "  cdr: " .. tostring(ast.cdr or "nil"))
    if ast.cdr ~= nil then
        print_ast_structure(ast.cdr, prefix .. "    ")
    end
    print(prefix .. "}")
end

-- Test 1: Parse a simple expression (+ n 1)
print("\nTesting parsing of (+ n 1):")
local parsed_expr = Parser.parse("(+ n 1)")
print_ast_structure(parsed_expr, "")

-- Test 2: Parse a lambda body (lambda (n) (+ n 1))
print("\nTesting parsing of (lambda (n) (+ n 1)):")
local parsed_lambda = Parser.parse("(lambda (n) (+ n 1))")
print_ast_structure(parsed_lambda, "")

print("Testing completed.") 