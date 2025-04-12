--!strict

-- Import the Parser module
local Parser = require("../../../Parser")
local Pair = require("../../../Core/Pair")

local function test_simple_parsing()
    print("\nTesting simple expression parsing")
    
    -- Test parsing symbols
    local symbol_result = Parser.parse("symbol")
    print("Symbol parsed correctly:", 
        Pair.car(symbol_result) == "symbol" and 
        Pair.cdr(symbol_result) == nil)
    
    -- Test parsing numbers
    local number_result = Parser.parse("42")
    print("Number parsed correctly:", 
        Pair.car(number_result) == 42 and 
        Pair.cdr(number_result) == nil)
    
    -- Test parsing strings
    local string_result = Parser.parse("\"hello world\"")
    print("String parsed correctly:", 
        Pair.car(string_result) == "hello world" and 
        Pair.cdr(string_result) == nil)
    
    -- Test parsing booleans
    local true_result = Parser.parse("#t")
    print("Boolean true parsed correctly:", 
        Pair.car(true_result) == true and 
        Pair.cdr(true_result) == nil)
    
    local false_result = Parser.parse("#f")
    print("Boolean false parsed correctly:", 
        Pair.car(false_result) == false and 
        Pair.cdr(false_result) == nil)
end

local function test_list_parsing()
    print("\nTesting list parsing")
    
    -- Test empty list
    local empty_list = Parser.parse("()")
    print("Empty list parsed correctly:", 
        Pair.is_pair(empty_list) and 
        Pair.is_pair(Pair.car(empty_list)) and
        Pair.car(Pair.car(empty_list)) == nil and
        Pair.cdr(Pair.car(empty_list)) == nil and
        Pair.cdr(empty_list) == nil)
    
    -- Test simple list
    local simple_list = Parser.parse("(1 2 3)")
    local list_head = Pair.car(simple_list)
    print("Simple list first element:", Pair.car(list_head) == 1)
    print("Simple list second element:", Pair.car(Pair.cdr(list_head)) == 2)
    print("Simple list third element:", Pair.car(Pair.cdr(Pair.cdr(list_head))) == 3)
    print("Simple list properly terminated:", Pair.cdr(Pair.cdr(Pair.cdr(list_head))) == nil)
    
    -- Test nested list
    local nested_list = Parser.parse("(1 (2 3) 4)")
    local nested_head = Pair.car(nested_list)
    print("Nested list first element:", Pair.car(nested_head) == 1)
    
    local inner_list = Pair.car(Pair.cdr(nested_head))
    print("Nested list contains inner list:", Pair.is_pair(inner_list))
    print("Inner list first element:", Pair.car(inner_list) == 2)
    print("Inner list second element:", Pair.car(Pair.cdr(inner_list)) == 3)
    
    print("Nested list third element:", Pair.car(Pair.cdr(Pair.cdr(nested_head))) == 4)
end

local function test_multiple_expressions()
    print("\nTesting multiple expressions")
    
    -- Test multiple top-level expressions
    local multiple = Parser.parse("42 symbol (1 2)")
    
    print("First expression is number:", Pair.car(multiple) == 42)
    print("Second expression is symbol:", Pair.car(Pair.cdr(multiple)) == "symbol")
    
    local third_expr = Pair.car(Pair.cdr(Pair.cdr(multiple)))
    print("Third expression is list:", Pair.is_pair(third_expr))
    print("Third expression first element:", Pair.car(third_expr) == 1)
    print("Third expression second element:", Pair.car(Pair.cdr(third_expr)) == 2)
end

local function test_complex_parsing()
    print("\nTesting complex expressions")
    
    -- Test a more complex Scheme-like expression
    local complex = Parser.parse("(define (factorial n) (if (= n 0) 1 (* n (factorial (- n 1)))))")
    local expr = Pair.car(complex)
    
    print("Complex expression is list:", Pair.is_pair(expr))
    print("First symbol is 'define':", Pair.car(expr) == "define")
    
    local func_def = Pair.car(Pair.cdr(expr))
    print("Function definition is list:", Pair.is_pair(func_def))
    print("Function name is 'factorial':", Pair.car(func_def) == "factorial")
    print("Parameter is 'n':", Pair.car(Pair.cdr(func_def)) == "n")
    
    -- Testing the full recursive nature would be too complex for simple assertions
    print("Complex expression parsed without errors")
end

-- Run the tests
test_simple_parsing()
test_list_parsing()
test_multiple_expressions()
test_complex_parsing()

print("\nAll Parser tests completed") 