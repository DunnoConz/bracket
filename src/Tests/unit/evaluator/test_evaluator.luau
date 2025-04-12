--!strict

-- Import required modules
local Evaluator = require("../../../Evaluator")
local Parser = require("../../../Parser")
local Environment = require("../../../Evaluator/Environment")
local Pair = require("../../../Core/Pair")

-- Helper function to parse and evaluate code
local function evaluate(code: string, env: Environment.Env?)
    print("Parsing: ", code)
    local ast = Parser.parse(code)
    print("Parse result type:", type(ast))
    if type(ast) == "table" then
        print("Is pair:", Pair.is_pair(ast))
        if Pair.is_pair(ast) then
            print("Car type:", type(Pair.car(ast)))
            print("Car value:", Pair.car(ast))
            
            -- Deep print for critical expressions
            if code == "(define (add x y) (+ x y))" then
                print("DEEP DEBUG for function define:")
                local define_expr = Pair.car(ast)
                print("  Define expr:", define_expr)
                if Pair.is_pair(define_expr) then
                    print("  Define car:", define_expr.car)
                    print("  Define cdr:", define_expr.cdr)
                    
                    if Pair.is_pair(define_expr.cdr) then
                        local func_sig = define_expr.cdr.car
                        local body = define_expr.cdr.cdr
                        print("  Function signature:", func_sig)
                        print("  Function body:", body)
                        
                        if Pair.is_pair(func_sig) then
                            print("  Function name:", func_sig.car)
                            print("  Function params:", func_sig.cdr)
                        end
                        
                        if Pair.is_pair(body) then
                            print("  Body first expr:", body.car)
                            if Pair.is_pair(body.car) then
                                print("  Body first expr car:", body.car.car)
                                print("  Body first expr cdr:", body.car.cdr)
                            end
                        end
                    end
                end
            end
        end
    end
    
    if env == nil then
        -- Create a new environment if one wasn't provided
        local new_env = Environment.new()
        new_env:add_builtins()
        return Evaluator.evaluate(ast, new_env)
    end
    return Evaluator.evaluate(ast, env)
end

local function test_simple_expressions()
    print("\nTesting simple expression evaluation")
    
    -- Create an environment
    local env = Environment.new()
    env:add_builtins()
    
    -- Test evaluating literals
    print("Number literal:", evaluate("42", env) == 42)
    
    -- Debug for string literal evaluation
    print("Testing string literal \"hello\":")
    local str_result = evaluate("\"hello\"", env)
    print("Type of result:", type(str_result))
    print("Value of result:", str_result)
    print("Comparison result:", str_result == "hello")
    print("String literal:", str_result == "hello")
    
    print("Boolean literal true:", evaluate("#t", env) == true)
    print("Boolean literal false:", evaluate("#f", env) == false)
    
    -- Test evaluating a symbol (variable)
    env:define("x", 10)
    print("Symbol lookup:", evaluate("x", env) == 10)
end

local function test_special_forms()
    print("\nTesting special forms")
    
    local env = Environment.new()
    env:add_builtins()
    
    -- Test quote
    local quoted_result = evaluate("(quote (1 2 3))", env)
    print("Quote preserves list structure:", quoted_result ~= nil and type(quoted_result) == "table")
    if quoted_result ~= nil and type(quoted_result) == "table" then
        print("Quote first element:", Pair.car(quoted_result) == 1)
    end
    
    -- Test if (true branch)
    print("If true branch:", evaluate("(if #t 1 2)", env) == 1)
    
    -- Test if (false branch)
    print("If false branch:", evaluate("(if #f 1 2)", env) == 2)
    
    -- Test define
    evaluate("(define y 20)", env)
    print("Define creates binding:", evaluate("y", env) == 20)
    
    -- Test define with function shorthand
    evaluate("(define (add x y) (+ x y))", env)
    print("Define function works:", evaluate("(add 5 10)", env) == 15)
    
    -- Test begin
    print("Begin returns last value:", evaluate("(begin 1 2 3)", env) == 3)
    
    -- Test set!
    evaluate("(define z 5)", env)
    evaluate("(set! z 25)", env)
    print("Set! changes value:", evaluate("z", env) == 25)
    
    -- Test lambda
    print("\nDEBUG: Examining lambda parsing")
    local lambda_code = "(lambda (x) (* x x))"
    print("Lambda expression:", lambda_code)
    
    -- Tokenize the lambda expression
    local tokens = Parser.tokenize(lambda_code)
    print("Tokens:")
    for i, token in ipairs(tokens) do
        print("  Token", i, "=", token)
    end
    
    -- Parse the lambda expression and examine structure
    local ast = Parser.parse(lambda_code)
    print("AST type:", type(ast))
    print("AST is pair:", Pair.is_pair(ast))
    if Pair.is_pair(ast) then
        print("AST.car type:", type(Pair.car(ast)))
        print("AST.car value:", Pair.car(ast))
        local list = Pair.car(ast)
        if Pair.is_pair(list) then
            print("List.car (operator):", list.car)
            print("List.cdr type:", type(list.cdr))
            local args = list.cdr
            if Pair.is_pair(args) then
                print("Args.car (params):", args.car)
                print("Args.cdr (body):", args.cdr)
                if Pair.is_pair(args.cdr) then
                    print("Body.car:", args.cdr.car)
                    if Pair.is_pair(args.cdr.car) then
                        print("Body.car is a pair with car:", args.cdr.car.car)
                        print("Body.car.cdr:", args.cdr.car.cdr)
                    end
                end
            end
        end
    end
    
    evaluate("(define square (lambda (x) (* x x)))", env)
    print("Lambda function works:", evaluate("(square 4)", env) == 16)
end

local function test_built_in_procedures()
    print("\nTesting built-in procedures")
    
    local env = Environment.new()
    env:add_builtins()
    
    -- Test arithmetic operators
    print("Addition:", evaluate("(+ 2 3)", env) == 5)
    print("Subtraction:", evaluate("(- 10 4)", env) == 6)
    print("Multiplication:", evaluate("(* 3 4)", env) == 12)
    print("Division:", evaluate("(/ 10 2)", env) == 5)
    
    -- Test comparison operators
    print("Equality (true):", evaluate("(= 5 5)", env) == true)
    print("Equality (false):", evaluate("(= 5 6)", env) == false)
    print("Less than:", evaluate("(< 3 5)", env) == true)
    print("Greater than:", evaluate("(> 7 2)", env) == true)
    
    -- Test list operations
    evaluate("(define my-list (list 1 2 3))", env)
    print("List creation works:", Pair.is_pair(evaluate("my-list", env)))
    print("Car works:", evaluate("(car my-list)", env) == 1)
    print("Cdr works:", Pair.car(evaluate("(cdr my-list)", env)) == 2)
end

local function test_complex_programs()
    print("\nTesting complex programs")
    
    local env = Environment.new()
    env:add_builtins()
    
    -- Test factorial function
    local factorial_code = [[
        (define (factorial n)
          (if (= n 0)
              1
              (* n (factorial (- n 1)))))
        (factorial 5)
    ]]
    
    print("Factorial of 5:", evaluate(factorial_code, env) == 120)
    
    -- Test recursive Fibonacci
    local fib_code = [[
        (define (fib n)
          (if (< n 2)
              n
              (+ (fib (- n 1)) (fib (- n 2)))))
        (fib 7)
    ]]
    
    print("Fibonacci of 7:", evaluate(fib_code, env) == 13)
    
    -- Test lexical scoping
    local scope_code = [[
        (define x 10)
        (define (f y)
          (define (g z) (+ x y z))
          (g 3))
        (f 2)
    ]]
    
    print("Lexical scoping:", evaluate(scope_code, env) == 15)
end

-- Run all tests
test_simple_expressions()
test_special_forms()
test_built_in_procedures()
test_complex_programs()

print("\nAll Evaluator tests completed") 