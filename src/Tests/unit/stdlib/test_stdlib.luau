--!strict

-- Import required modules
local StandardLibrary = require("../../../Stdlib/StandardLibrary")
local Environment = require("../../../Evaluator/Environment")
local Evaluator = require("../../../Evaluator")
local Parser = require("../../../Parser")
local Pair = require("../../../Core/Pair")

-- Helper function to evaluate code with standard library
local function evaluate_with_stdlib(code: string)
    local env = Environment.new()
    -- Add standard library functions to environment
    env:add_builtins()
    
    -- Add additional StandardLibrary functions
    for name, func in pairs(StandardLibrary) do
        env:define(name, func)
    end
    
    local ast = Parser.parse(code)
    return Evaluator.evaluate(ast, env)
end

local function test_math_functions()
    print("\nTesting Math functions")
    
    -- Test basic math operators
    print("Addition:", evaluate_with_stdlib("(+ 3 4)") == 7)
    print("Subtraction:", evaluate_with_stdlib("(- 10 3)") == 7)
    print("Multiplication:", evaluate_with_stdlib("(* 3 5)") == 15)
    print("Division:", evaluate_with_stdlib("(/ 10 2)") == 5)
    
    -- Test modulo
    print("Modulo:", evaluate_with_stdlib("(modulo 10 3)") == 1)
    
    -- Test abs
    print("Absolute value:", evaluate_with_stdlib("(abs -5)") == 5)
    
    -- Test math with multiple arguments
    print("Addition with multiple args:", evaluate_with_stdlib("(+ 1 2 3 4)") == 10)
    print("Multiplication with multiple args:", evaluate_with_stdlib("(* 2 3 4)") == 24)
end

local function test_comparison_functions()
    print("\nTesting comparison functions")
    
    -- Test equality
    print("Equality (true):", evaluate_with_stdlib("(= 5 5)") == true)
    print("Equality (false):", evaluate_with_stdlib("(= 5 6)") == false)
    print("Equality (multiple, true):", evaluate_with_stdlib("(= 5 5 5)") == true)
    print("Equality (multiple, false):", evaluate_with_stdlib("(= 5 5 6)") == false)
    
    -- Test inequality
    print("Less than:", evaluate_with_stdlib("(< 3 5)") == true)
    print("Greater than:", evaluate_with_stdlib("(> 7 3)") == true)
    print("Less than or equal:", evaluate_with_stdlib("(<= 5 5)") == true)
    print("Greater than or equal:", evaluate_with_stdlib("(>= 5 3)") == true)
    
    -- Test with multiple arguments
    print("Less than (multiple, true):", evaluate_with_stdlib("(< 1 2 3 4)") == true)
    print("Less than (multiple, false):", evaluate_with_stdlib("(< 1 3 2 4)") == false)
end

local function test_logical_functions()
    print("\nTesting logical functions")
    
    -- Test and
    print("And (true):", evaluate_with_stdlib("(and #t #t)") == true)
    print("And (false):", evaluate_with_stdlib("(and #t #f)") == false)
    print("And (short-circuit):", evaluate_with_stdlib("(and #f (/ 1 0))") == false)
    
    -- Test or
    print("Or (true):", evaluate_with_stdlib("(or #f #t)") == true)
    print("Or (false):", evaluate_with_stdlib("(or #f #f)") == false)
    print("Or (short-circuit):", evaluate_with_stdlib("(or #t (/ 1 0))") == true)
    
    -- Test not
    print("Not (true):", evaluate_with_stdlib("(not #f)") == true)
    print("Not (false):", evaluate_with_stdlib("(not #t)") == false)
end

local function test_list_functions()
    print("\nTesting list functions")
    
    -- Test list creation
    local list_result = evaluate_with_stdlib("(list 1 2 3)")
    print("List function creates pairs:", list_result ~= nil and type(list_result) == "table")
    
    if list_result ~= nil and type(list_result) == "table" then
        print("List has correct first element:", Pair.car(list_result) == 1)
    end
    
    -- Test car/cdr
    print("Car extracts first element:", evaluate_with_stdlib("(car (list 1 2 3))") == 1)
    
    local cdr_result = evaluate_with_stdlib("(cdr (list 1 2 3))")
    print("Cdr returns rest of list:", cdr_result ~= nil and type(cdr_result) == "table")
    
    if cdr_result ~= nil and type(cdr_result) == "table" then
        print("Cdr's first element is correct:", Pair.car(cdr_result) == 2)
    end
    
    -- Test list predicates
    local pair_result = evaluate_with_stdlib("(cons 1 2)")
    print("Pair? on pair:", pair_result ~= nil and type(pair_result) == "table" and
          getmetatable(pair_result) == "BracketPair")
    
    print("Pair? on atom:", evaluate_with_stdlib("(pair? 1)") == false)
    print("Null? on empty list:", evaluate_with_stdlib("(null? (list))") == true)
    print("Null? on list:", evaluate_with_stdlib("(null? (list 1))") == false)
    
    -- Test cons
    local cons_result = evaluate_with_stdlib("(cons 1 (list 2 3))")
    print("Cons creates proper structure:", 
        cons_result ~= nil and type(cons_result) == "table" and
        Pair.car(cons_result) == 1)
        
    local cdr_of_cons = Pair.cdr(cons_result)
    if cdr_of_cons ~= nil and type(cdr_of_cons) == "table" then
        print("Cons links correctly:", Pair.car(cdr_of_cons) == 2)
    end
    
    -- Test list length
    print("Length of list:", evaluate_with_stdlib("(length (list 1 2 3 4))") == 4)
    print("Length of empty list:", evaluate_with_stdlib("(length (list))") == 0)
end

local function test_type_predicates()
    print("\nTesting type predicates")
    
    -- Test number?
    print("Number? true:", evaluate_with_stdlib("(number? 42)") == true)
    print("Number? false:", evaluate_with_stdlib("(number? \"42\")") == false)
    
    -- Test string?
    print("String? true:", evaluate_with_stdlib("(string? \"hello\")") == true)
    print("String? false:", evaluate_with_stdlib("(string? 42)") == false)
    
    -- Test boolean?
    print("Boolean? true:", evaluate_with_stdlib("(boolean? #t)") == true)
    print("Boolean? false:", evaluate_with_stdlib("(boolean? 0)") == false)
    
    -- Test procedure?
    print("Procedure? true:", evaluate_with_stdlib("(procedure? (lambda (x) (+ x 1)))") == true)
    print("Procedure? false:", evaluate_with_stdlib("(procedure? 42)") == false)
end

-- Run all tests
test_math_functions()
test_comparison_functions()
test_logical_functions()
test_list_functions()
test_type_predicates()

print("\nAll Standard Library tests completed") 