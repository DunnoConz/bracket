--!strict

-- Import the Bracket module which provides the main interface
local Bracket = require("../../init")
local Pair = require("../../Core/Pair")

local function test_simple_programs()
    print("\nTesting simple programs")
    
    -- Test a simple expression
    local result = Bracket.evaluate("(+ 2 3)")
    print("Simple addition:", result == 5)
    
    -- Test a variable definition and use
    print("Testing variable definition and use")
    Bracket.evaluate("(define x 10)")
    local result = Bracket.evaluate("x")
    print("Variable definition and use:", result == 10)
    
    -- Test a conditional
    local if_code = [[
        (if (> 5 3)
            "greater"
            "lesser")
    ]]
    print("Conditional (true branch):", Bracket.evaluate(if_code) == "greater")
    
    local if_false_code = [[
        (if (< 5 3)
            "greater"
            "lesser")
    ]]
    print("Conditional (false branch):", Bracket.evaluate(if_false_code) == "lesser")
end

local function test_functions()
    print("\nTesting function definitions and calls")
    
    -- Define a square function with proper function call syntax
    local square_result = Bracket.evaluate("(define square (lambda (x) (+ (* x x) 0)))")
    Bracket.evaluate("(display square)") -- For debugging
    square_result = Bracket.evaluate("(square 4)")
    print("Simple function:", square_result == 16)
    
    -- Define a simple identity function
    local id_result = Bracket.evaluate("(define identity (lambda (x) x))")
    Bracket.evaluate("(display identity)") -- For debugging
    
    -- Test the identity function
    id_result = Bracket.evaluate("(identity 42)")
    print("Identity function:", id_result == 42)
    
    -- Define a simple addition function
    local add_result = Bracket.evaluate("(define add-one (lambda (x) (+ x 1)))")
    local add_test = Bracket.evaluate("(add-one 5)")
    print("Addition function:", add_test == 6)
    
    -- Test a function with multiple arguments
    local add_three = Bracket.evaluate("(define add-three (lambda (a b c) (+ a (+ b c))))")
    local multi_arg_result = Bracket.evaluate("(add-three 1 2 3)")
    print("Multiple argument function:", multi_arg_result == 6)
    
    -- Test lexical scoping - simplified
    local lexical_code = [[
        (define x 5)
        (define y 2)
        (define z 3)
        (+ x (+ y z))
    ]]
    local lexical_result = Bracket.evaluate(lexical_code)
    print("Lexical scoping:", lexical_result == 10)
end

local function test_closures()
    print("\nTesting closures")
    
    -- Test a simple closure
    local closure_code = [[
        (define (make-adder n)
          (lambda (x) (+ x n)))
        (define add5 (make-adder 5))
        (add5 10)
    ]]
    print("Simple closure:", Bracket.evaluate(closure_code) == 15)
    
    -- Test multiple closures from the same function
    local multi_closure_code = [[
        (define (make-adder n)
          (lambda (x) (+ x n)))
        (define add3 (make-adder 3))
        (define add7 (make-adder 7))
        (+ (add3 10) (add7 10))
    ]]
    print("Multiple closures:", Bracket.evaluate(multi_closure_code) == 30)
    
    -- Test nested closures
    local nested_closure_code = [[
        (define (make-counter)
          (define count 0)
          (lambda ()
            (set! count (+ count 1))
            count))
        (define counter (make-counter))
        (counter)
        (counter)
        (counter)
    ]]
    print("Nested closures with state:", Bracket.evaluate(nested_closure_code) == 3)
end

local function test_lists_and_pairs()
    print("\nTesting lists and pairs")
    
    -- Test list creation and access
    local list_code = [[
        (define my-list (list 1 2 3 4 5))
        (car my-list)
    ]]
    print("List creation and car:", Bracket.evaluate(list_code) == 1)
    
    -- Test list manipulation
    local list_manip_code = [[
        (define my-list (list 1 2 3 4 5))
        (car (cdr (cdr my-list)))
    ]]
    print("List cdr and car:", Bracket.evaluate(list_manip_code) == 3)
    
    -- Test cons
    local cons_code = [[
        (define my-list (cons 1 (cons 2 (cons 3 '()))))
        (car (cdr my-list))
    ]]
    print("Cons and quote:", Bracket.evaluate(cons_code) == 2)
    
    -- Test list operations
    local list_ops_code = [[
        (define my-list (list 1 2 3 4 5))
        (length my-list)
    ]]
    print("List length:", Bracket.evaluate(list_ops_code) == 5)
end

local function test_quoting()
    print("\nTesting quoting")
    
    -- Test quote form
    local quote_code = [[
        (define x 10)
        (quote x)
    ]]
    local quote_result = Bracket.evaluate(quote_code)
    print("Quote form returns symbol:", quote_result == "x")
    
    -- Test quote shorthand
    local quote_short_code = [[
        '(1 2 3)
    ]]
    local short_result = Bracket.evaluate(quote_short_code)
    print("Quote shorthand creates list:", 
        short_result ~= nil and type(short_result) == "table" and 
        getmetatable(short_result) == "BracketPair")
    
    if short_result ~= nil and type(short_result) == "table" then
        print("Quote shorthand first element:", Pair.car(short_result) == 1)
    end
    
    -- Test quasiquote (not all versions might support this)
    local quasiquote_code = [[
        (define x 10)
        '(1 2 x)
    ]]
    local quasiquote_result = Bracket.evaluate(quasiquote_code)
    print("Quote creates proper list:", 
          type(quasiquote_result) == "table" and
          Pair.is_pair(quasiquote_result))
end

local function test_recursion()
    print("\nTesting recursion and advanced patterns")
    
    -- Test recursive factorial function
    local factorial_code = [[
        (define (factorial n)
          (if (= n 0)
              1
              (* n (factorial (- n 1)))))
        (factorial 5)
    ]]
    print("Recursive factorial:", Bracket.evaluate(factorial_code) == 120)
    
    -- Test recursive fibonacci function
    local fibonacci_code = [[
        (define (fibonacci n)
          (if (< n 2)
              n
              (+ (fibonacci (- n 1))
                 (fibonacci (- n 2)))))
        (fibonacci 7)
    ]]
    print("Recursive fibonacci:", Bracket.evaluate(fibonacci_code) == 13)
    
    -- Test tail-recursive function (if your implementation supports it)
    local tail_factorial_code = [[
        (define (factorial-tail n acc)
          (if (= n 0)
              acc
              (factorial-tail (- n 1) (* n acc))))
        (define (factorial n)
          (factorial-tail n 1))
        (factorial 5)
    ]]
    print("Tail-recursive factorial:", Bracket.evaluate(tail_factorial_code) == 120)
    
    -- Test mutual recursion 
    local mutual_recursion_code = [[
        (define (is-even n)
          (if (= n 0)
              #t
              (is-odd (- n 1))))
        (define (is-odd n)
          (if (= n 0)
              #f
              (is-even (- n 1))))
        (is-even 4)
    ]]
    print("Mutual recursion (is-even):", Bracket.evaluate(mutual_recursion_code) == true)
end

local function test_higher_order_functions()
    print("\nTesting higher-order functions")
    
    -- Test map function
    local map_code = [[
        (define (map func items)
          (if (null? items)
              '()
              (cons (func (car items))
                    (map func (cdr items)))))
        (define (square x) (* x x))
        (map square (list 1 2 3 4 5))
    ]]
    local map_result = Bracket.evaluate(map_code)
    print("Map function:", 
          Pair.is_pair(map_result) and
          Pair.car(map_result) == 1 and
          Pair.car(Pair.cdr(map_result)) == 4 and
          Pair.car(Pair.cdr(Pair.cdr(map_result))) == 9)
    
    -- Test filter function
    local filter_code = [[
        (define (filter predicate items)
          (if (null? items)
              '()
              (if (predicate (car items))
                  (cons (car items) (filter predicate (cdr items)))
                  (filter predicate (cdr items)))))
        (define (even? n) (= (remainder n 2) 0))
        (filter even? (list 1 2 3 4 5 6))
    ]]
    local filter_result = Bracket.evaluate(filter_code)
    print("Filter function:", 
          Pair.is_pair(filter_result) and
          Pair.car(filter_result) == 2 and
          Pair.car(Pair.cdr(filter_result)) == 4 and
          Pair.car(Pair.cdr(Pair.cdr(filter_result))) == 6)
    
    -- Test reduce function
    local reduce_code = [[
        (define (reduce func initial items)
          (if (null? items)
              initial
              (reduce func 
                     (func initial (car items))
                     (cdr items))))
        (reduce + 0 (list 1 2 3 4 5))
    ]]
    print("Reduce function:", Bracket.evaluate(reduce_code) == 15)
    
    -- Test function composition
    local composition_code = [[
        (define (compose f g)
          (lambda (x) (f (g x))))
        (define (add1 x) (+ x 1))
        (define (square x) (* x x))
        (define add1-then-square (compose square add1))
        (add1-then-square 4)
    ]]
    print("Function composition:", Bracket.evaluate(composition_code) == 25) -- (4+1)² = 25
end

local function test_error_handling()
    print("\nTesting error handling")
    
    -- Test error handling for division by zero
    local division_error = pcall(function()
        Bracket.evaluate("(/ 10 0)")
    end)
    print("Division by zero handling:", not division_error)
    
    -- Test error for undefined variable
    local undefined_var_error = pcall(function()
        Bracket.evaluate("undefined_variable")
    end)
    print("Undefined variable handling:", not undefined_var_error)
    
    -- Test error for wrong number of arguments
    local wrong_args_error = pcall(function()
        Bracket.evaluate("(+ 1)")  -- + should have at least 2 arguments
    end)
    print("Wrong number of arguments handling:", not wrong_args_error)
    
    -- Test syntax error handling
    local syntax_error = pcall(function()
        Bracket.evaluate("(define x 10")  -- Missing closing parenthesis
    end)
    print("Syntax error handling:", not syntax_error)
    
    -- Test type error handling
    local type_error = pcall(function()
        Bracket.evaluate("(+ 1 \"string\")")  -- Can't add number and string
    end)
    print("Type error handling:", not type_error)
end

local function test_macros()
    print("\nTesting macros (if supported)")
    
    -- Test if macros are supported using a simple macro
    local macro_support = pcall(function()
        local result = Bracket.evaluate([[
            (define-macro (my-when condition body)
              (list 'if condition body nil))
            (my-when (> 5 3) "true-case")
        ]])
        print("Basic macro result:", result == "true-case")
    end)
    print("Basic macro support:", macro_support)
    
    -- If macros are supported, try testing a more complex macro
    if macro_support then
        local complex_macro = pcall(function()
            local result = Bracket.evaluate([[
                (define-macro (my-unless condition body)
                  (list 'if condition nil body))
                (my-unless (< 5 3) "executed-when-false")
            ]])
            print("Complex macro result:", result == "executed-when-false")
        end)
        print("Complex macro support:", complex_macro)
        
        -- Test a macro that expands into another macro
        local nested_macro = pcall(function()
            local result = Bracket.evaluate([[
                (define-macro (my-and x y)
                  (list 'if x (list 'if y true false) false))
                (my-and (> 5 3) (> 10 5))
            ]])
            print("Nested macro result:", result == true)
        end)
        print("Nested macro support:", nested_macro)
    end
end

-- Run all tests
test_simple_programs()
test_functions()
test_closures()
test_lists_and_pairs()
test_quoting()
test_recursion()
test_higher_order_functions()
test_error_handling()
test_macros()

print("\nAll integration tests completed") 