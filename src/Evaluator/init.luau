--!strict

local Environment = require("./Environment")
local Pair = require("../Core/Pair")
local Error = require("../Core/Error")
local Macro = require("./Macro")
local LambdaModule = require("./lambda")

-- Export the Evaluator module
local Evaluator = {}

-- Forward declaration 
local eval

-- Export the eval function so it can be used by other modules
function Evaluator.eval(expr: any, env: Environment.Env): any
    return eval(expr, env)
end

-- Helper function to print a pair for debugging
local function debug_print_pair(prefix, pair, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    prefix = prefix or ""
    
    if not Pair.is_pair(pair) then
        if pair == nil then
            print(prefix .. indentStr .. "nil")
        elseif typeof(pair) == "string" then
            print(prefix .. indentStr .. "Symbol: " .. pair)
        elseif typeof(pair) == "number" then
            print(prefix .. indentStr .. "Number: " .. pair)
        elseif typeof(pair) == "function" then
            print(prefix .. indentStr .. "Function: " .. tostring(pair))
        else
            print(prefix .. indentStr .. "Value: " .. tostring(pair))
        end
        return
    end
    
    print(prefix .. indentStr .. "Pair {")
    print(prefix .. indentStr .. "  car: ")
    debug_print_pair(prefix, pair.car, indent + 1)
    print(prefix .. indentStr .. "  cdr: ")
    debug_print_pair(prefix, pair.cdr, indent + 1)
    print(prefix .. indentStr .. "}")
end

-- Core evaluation function (handles all forms)
local function eval(expr: any, env: Environment.Env): any
    -- Handle atoms (strings = symbols, numbers, booleans, etc.)
    if typeof(expr) == "number" or typeof(expr) == "boolean" then
        -- Numbers and booleans evaluate to themselves
        return expr
    elseif typeof(expr) == "string" then
        -- Symbol lookup in environment
        if expr:sub(1, 7) == "STRING:" then
            -- String literal (strip prefix)
            return expr:sub(8)
        else
            -- Symbol lookup in environment
            local value = env:lookup(expr)
            if value == nil then
                local err = Error.new(string.format("Unbound variable: %s", expr), "LookupError")
                error(Error.format(err))
            end
            return value
        end
    elseif Pair.is_null(expr) then
        -- Empty list/nil value evaluates to nil
        return nil
    end
    
    -- Not an atom, must be a pair (from here, expr should be table with metatable "BracketPair")
    if not Pair.is_pair(expr) then
        -- Not a proper pair
        local err = Error.new("Invalid expression: expected pair", "SyntaxError")
        error(Error.format(err))
    end
    
    -- Lists (function calls, special forms, etc.)
    -- We now know expr is a pair with car/cdr fields
    if Pair.is_null(expr) then -- Empty list '()
        return nil -- Empty list evaluates to nil
    end
    
    -- Non-empty list - check for special forms
    local list_expr = expr
    
    -- Check for the empty list first - cannot apply empty list
    if Pair.is_null(list_expr) then
        local err = Error.new("Cannot apply empty list '()", "TypeError")
        error(Error.format(err))
    end

    -- Evaluate the operator (car of the list)
    -- Special forms are identified by their *name* (string) *before* evaluation
    local operator_expr = list_expr.car
    local operator_name = nil
    if typeof(operator_expr) == "string" then
        operator_name = operator_expr
    end

    local args = list_expr.cdr -- Arguments are the rest of the list

    -- Handle Special Forms (identified by symbol in operator position)
    if operator_name == "quote" then
        if not Pair.is_pair(args) or not Pair.is_null(Pair.cdr(args)) then
            local err = Error.new("'quote' requires exactly one argument", "SyntaxError")
            error(Error.format(err))
        end
        return args.car -- Return the argument unevaluated
    elseif operator_name == "if" then
        -- (if condition then-expr else-expr)
        if not Pair.is_pair(args) or not Pair.is_pair(Pair.cdr(args)) then
            local err = Error.new("'if' requires at least condition and then expression", "SyntaxError")
            error(Error.format(err))
        end

        local condition_expr = args.car
        local then_expr = Pair.cdr(args).car
        local else_expr = nil

        -- Else expression is optional in reality, but treat as nil if missing
        local else_args = Pair.cdr(Pair.cdr(args))
        if Pair.is_pair(else_args) then
            else_expr = else_args.car
            if not Pair.is_null(Pair.cdr(else_args)) then
                local err = Error.new("'if' takes at most 3 arguments", "SyntaxError")
                error(Error.format(err))
            end
        end

        -- Evaluate condition
        local condition_result = eval(condition_expr, env)
        if condition_result ~= false and condition_result ~= nil then
            -- Anything except #f and nil is considered true
            return eval(then_expr, env)
        else
            if else_expr ~= nil then
                return eval(else_expr, env)
            else
                return nil -- No else expression provided
            end
        end
    elseif operator_name == "define" then
        -- Check for proper list structure
        if not Pair.is_pair(args) then
            local err = Error.new("'define' requires variable name and value", "SyntaxError")
            error(Error.format(err))
        end

        local var_or_func = args.car
        
        -- Handle function shorthand: (define (name params...) body...)
        if Pair.is_pair(var_or_func) then
            -- Format: (define (func-name args...) body...)
            local func_name = var_or_func.car
            if typeof(func_name) ~= "string" then
                local err = Error.new("Function name must be a symbol", "SyntaxError")
                error(Error.format(err))
            end
            
            local params_list = var_or_func.cdr -- Parameters list
            local body_list = args.cdr -- Function body

            if not Pair.is_pair(body_list) then
                local err = Error.new("'define' function requires body expressions", "SyntaxError")
                error(Error.format(err))
            end
            
            -- Create a lambda expression equivalent
            local lambda_expr = Pair.cons("lambda", Pair.cons(params_list, body_list))
            
            -- Evaluate the lambda and define it with the function name
            local lambda_func = eval(lambda_expr, env)
            env:define(func_name, lambda_func)
            
            return lambda_func
        else
            -- Simple variable definition: (define var value)
            if typeof(var_or_func) ~= "string" then
                local err = Error.new("Variable name must be a symbol", "SyntaxError")
                error(Error.format(err))
            end
            
            -- Ensure we have a value
            if not Pair.is_pair(args.cdr) then
                local err = Error.new("'define' requires a value", "SyntaxError")
                error(Error.format(err))
            end
            
            local val_expr = args.cdr.car
            
            -- Check for proper list in args
            if not Pair.is_null(Pair.cdr(args.cdr)) then
                local err = Error.new("'define' takes exactly 2 arguments", "SyntaxError")
                error(Error.format(err))
            end
            
            -- Evaluate the value
            print("Evaluating define for:", var_or_func)
            local value = eval(val_expr, env)
            print("Value is:", value, "of type:", typeof(value))
            
            -- Define the variable in the environment
            print("Defining", var_or_func, "to be value:", value)
            env:define(var_or_func, value)
            
            return value
        end
    elseif operator_name == "set!" then
        -- Set existing variables
        if not Pair.is_pair(args) then
            local err = Error.new("'set!' requires variable name and value", "SyntaxError")
            error(Error.format(err))
        end
        
        local var_name = args.car
        if typeof(var_name) ~= "string" then
            local err = Error.new("Variable name must be a symbol", "SyntaxError")
            error(Error.format(err))
        end
        
        -- Ensure we have a value
        if not Pair.is_pair(args.cdr) then
            local err = Error.new("'set!' requires a value", "SyntaxError")
            error(Error.format(err))
        end
        
        local val_expr = args.cdr.car
        
        -- Check for proper list in args
        if not Pair.is_null(Pair.cdr(args.cdr)) then
            local err = Error.new("'set!' takes exactly 2 arguments", "SyntaxError")
            error(Error.format(err))
        end
        
        -- Evaluate the value
        local value = eval(val_expr, env)
        
        -- Set the variable in the environment
        if not env:set(var_name, value) then
            local err = Error.new(string.format("Unbound variable: %s", var_name), "LookupError")
            error(Error.format(err))
        end
        
        return value
    elseif operator_name == "lambda" or operator_name == "λ" then
        -- Use the LambdaModule for lambda handling
        print("DEBUG: Creating lambda with args:")
        debug_print_pair("Lambda args: ", args, 1)
        local lambda_fn = LambdaModule.create_lambda(args, env)
        print("DEBUG: Lambda function created:", lambda_fn)
        return lambda_fn
    elseif operator_name == "begin" then
        -- (begin expr1 expr2 ...)
        local result = nil
        local current_expr_node = args
        
        if Pair.is_null(current_expr_node) then
            return nil -- (begin) evaluates to nil/void
        end

        while Pair.is_pair(current_expr_node) do
            local expr_to_eval = current_expr_node.car
            local next_node = current_expr_node.cdr
            
            if Pair.is_null(next_node) then
                -- Last expression, its value becomes the value of the begin form
                return eval(expr_to_eval, env)
            else
                -- Intermediate expression, evaluate for side effects
                result = eval(expr_to_eval, env)
            end
            
            current_expr_node = next_node
        end
        
        -- Check for improper list
        if not Pair.is_null(current_expr_node) then
            local err = Error.new("'begin' sequence contains an improper list", "SyntaxError")
            error(Error.format(err))
        end
        
        -- Should not reach here if sequence is proper
        return result
    else
        -- Not a special form, treat as function application
        print("DEBUG: Function application for operator:", operator_expr, "of type:", typeof(operator_expr))
        local operator_val = eval(operator_expr, env)
        print("DEBUG: Operator value after eval:", operator_val, "of type:", typeof(operator_val))

        if typeof(operator_val) ~= "function" then
            print("DEBUG: Function application error on operator:", operator_expr)
            debug_print_pair("Expression: ", expr, 1)
            local err = Error.new(string.format("Not a procedure; cannot apply: %s", tostring(operator_expr)), "TypeError")
            error(Error.format(err))
        end

        -- Evaluate arguments
        local args_array = {}
        local arg_count = 0
        local current_arg_node = args
        
        while Pair.is_pair(current_arg_node) do
            local arg_val = eval(current_arg_node.car, env)
            arg_count += 1
            args_array[arg_count] = arg_val
            current_arg_node = current_arg_node.cdr
        end
        
        -- Handle improper list in function arguments - this could be a direct value instead of nil
        if not Pair.is_null(current_arg_node) and current_arg_node ~= nil then
            -- If it's not the standard nil terminator, treat it as a final argument
            if typeof(current_arg_node) ~= "nil" then
                local arg_val = eval(current_arg_node, env)
                arg_count += 1
                args_array[arg_count] = arg_val
            else
                local err = Error.new("Improper list in function arguments", "SyntaxError")
                error(Error.format(err))
            end
        end

        -- Apply the function with a pcall for safety
        local success, result = pcall(function()
            return operator_val(unpack(args_array, 1, arg_count))
        end)
        
        if success then
            return result
        else
            -- Convert Lua errors to more helpful Bracket errors
            local error_msg = result
            if typeof(error_msg) == "string" and error_msg:match("attempt to call a nil value") then
                error_msg = "Function application failed: procedure returned nil"
            end
            local err = Error.new(tostring(error_msg), "RuntimeError")
            error(Error.format(err))
        end
    end
end

-- Top-level evaluation function
function Evaluator.evaluate(program: any, env: Environment.Env): any
    -- Handle simple case first - if the program is just a simple atom or empty list
    if Pair.is_null(program) then 
        return nil
    elseif typeof(program) ~= "table" or getmetatable(program) ~= "BracketPair" then
        -- If it's not a Pair structure at all, just return it as is
        return program
    end
    
    -- Helper function to check if something is pair-like (might be missing cdr)
    local function is_pair_like(value)
        return typeof(value) == "table" and
               getmetatable(value) == "BracketPair" and
               value.car ~= nil
    end
    
    -- Special case - single expression might be returned as a table with just car property
    if program.car ~= nil and (program.cdr == nil or Pair.is_null(program.cdr)) then
        -- Handle the case where we just have a single expression without a proper list
        return eval(program.car, env)
    end
    
    -- Regular case - process a sequence of expressions
    local result = nil
    local current_expr_node = program
    
    -- Check if the program is a proper list
    while is_pair_like(current_expr_node) do
        result = eval(current_expr_node.car, env)
        current_expr_node = current_expr_node.cdr or nil -- Handle missing cdr property
        
        -- If we've reached the end, break
        if current_expr_node == nil or Pair.is_null(current_expr_node) then
            break
        end
    end
    
    -- Ensure proper list (should end with nil for proper lists)
    if not Pair.is_null(current_expr_node) and current_expr_node ~= nil then
        -- We reached the end but it wasn't a proper list
        if is_pair_like(current_expr_node) then
            -- If it's just a terminal node with car but no cdr, that's fine
            -- This could happen with weird parse trees
            -- Process this last node
            result = eval(current_expr_node.car, env)
        elseif typeof(current_expr_node) == "string" or 
               typeof(current_expr_node) == "number" or
               typeof(current_expr_node) == "boolean" then
            -- If it's a primitive type, just return it directly
            result = current_expr_node
        else
            -- Only error if it's a truly invalid structure
            local err = Error.new("Program structure returned by parser was not a proper list.", "InternalError")
            error(Error.format(err))
        end
    end
    
    return result
end

-- Now that we've defined all the evaluation functions, register the evaluator with the lambda module
LambdaModule.set_evaluator(eval)

return Evaluator 