--!strict

export type List<T> = { [number]: T }
export type Number = number
export type String = string
export type Boolean = boolean
export type Any = any

local Pair = require("../Core/Pair")
local Error = require("../Core/Error")

local StandardLibrary = {}

-- Math functions
StandardLibrary["+"] = function(...: Number): Number
    local args = {...}
    local sum = 0
    for _, v in ipairs(args) do
        sum += v
    end
    return sum
end

StandardLibrary["-"] = function(a: Number, b: Number?, ...: Number): Number
    if not b then
        return -a
    end
    local result = a - b
    local args = {...}
    for _, v in ipairs(args) do
        result -= v
    end
    return result
end

StandardLibrary["*"] = function(...: Number): Number
    local args = {...}
    local product = 1
    for _, v in ipairs(args) do
        product *= v
    end
    return product
end

StandardLibrary["/"] = function(a: Number, b: Number, ...: Number): Number
    local result = a / b
    local args = {...}
    for _, v in ipairs(args) do
        result /= v
    end
    return result
end

StandardLibrary["modulo"] = function(a: Number, b: Number): Number
    return a % b
end

StandardLibrary["abs"] = function(a: Number): Number
    return math.abs(a)
end

-- Comparison functions
StandardLibrary["="] = function(a: Any, b: Any): Boolean
    return a == b
end

StandardLibrary["<"] = function(a: Number, b: Number): Boolean
    return a < b
end

StandardLibrary[">"] = function(a: Number, b: Number): Boolean
    return a > b
end

StandardLibrary["<="] = function(a: Number, b: Number): Boolean
    return a <= b
end

StandardLibrary[">="] = function(a: Number, b: Number): Boolean
    return a >= b
end

-- List functions
StandardLibrary["list"] = function(...: Any): Any
    local args = {...}
    local result = nil
    -- Build list from right to left using cons
    for i = #args, 1, -1 do
        result = Pair.cons(args[i], result)
    end
    return result
end

StandardLibrary["car"] = function(lst: Any): Any
    if not Pair.is_pair(lst) then
        local err = Error.new("car: expected pair, got " .. typeof(lst), "TypeError")
        error(Error.format(err))
    end
    return Pair.car(lst)
end

StandardLibrary["cdr"] = function(lst: Any): Any
    if not Pair.is_pair(lst) then
        local err = Error.new("cdr: expected pair, got " .. typeof(lst), "TypeError")
        error(Error.format(err))
    end
    return Pair.cdr(lst)
end

StandardLibrary["cons"] = function(x: Any, lst: Any): Any
    return Pair.cons(x, lst)
end

StandardLibrary["length"] = function(lst: Any): Number
    local len = 0
    local current = lst
    while Pair.is_pair(current) do
        len += 1
        current = Pair.cdr(current)
    end
    
    if not Pair.is_null(current) then
        local err = Error.new("length: argument not a proper list", "TypeError")
        error(Error.format(err))
    end
    
    return len
end

StandardLibrary["append"] = function(...: Any): Any
    local args = {...}
    local result = nil
    local last_list = nil
    
    -- Handle special case of no arguments
    if #args == 0 then
        return nil -- Empty list
    end
    
    -- Handle the last argument separately (doesn't need copying)
    local last_arg = args[#args]
    
    -- If only one argument, return it as-is
    if #args == 1 then
        return last_arg
    end
    
    -- Process all but the last argument (need to be copied)
    for i = 1, #args - 1 do
        local current_list = args[i]
        
        -- Traverse current list and build result
        while Pair.is_pair(current_list) do
            local new_pair = Pair.cons(Pair.car(current_list), nil)
            
            if result == nil then
                result = new_pair
                last_list = new_pair
            else
                Pair.set_cdr(last_list, new_pair)
                last_list = new_pair
            end
            
            current_list = Pair.cdr(current_list)
        end
        
        -- Error if any list except the last is improper
        if not Pair.is_null(current_list) and i < #args then
            local err = Error.new("append: argument not a proper list", "TypeError")
            error(Error.format(err))
        end
    end
    
    -- Connect the last list
    if last_list then
        Pair.set_cdr(last_list, last_arg)
    else
        result = last_arg
    end
    
    return result
end

-- String functions
StandardLibrary["string-append"] = function(...: String): String
    local args = {...}
    local result = ""
    for _, str in ipairs(args) do
        result ..= str
    end
    return result
end

StandardLibrary["string-length"] = function(str: String): Number
    return #str
end

StandardLibrary["string-ref"] = function(str: String, index: Number): String
    return string.sub(str, index + 1, index + 1)
end

StandardLibrary["substring"] = function(str: String, start: Number, finish: Number): String
    return string.sub(str, start + 1, finish)
end

-- Type conversion
StandardLibrary["number->string"] = function(num: Number): String
    return tostring(num)
end

StandardLibrary["string->number"] = function(str: String): Number?
    return tonumber(str)
end

-- Boolean functions
StandardLibrary["not"] = function(x: Any): Boolean
    return not x
end

StandardLibrary["and"] = function(...: Any): Boolean
    local args = {...}
    for _, v in ipairs(args) do
        if not v then
            return false
        end
    end
    return true
end

StandardLibrary["or"] = function(...: Any): Boolean
    local args = {...}
    for _, v in ipairs(args) do
        if v then
            return true
        end
    end
    return false
end

-- I/O functions
StandardLibrary["display"] = function(x: Any): nil
    print(x)
    return nil
end

StandardLibrary["newline"] = function(): nil
    print()
    return nil
end

-- Higher-order functions
StandardLibrary["map"] = function(f: (Any) -> Any, lst: List<Any>): List<Any>
    local result = {}
    for _, v in ipairs(lst) do
        table.insert(result, f(v))
    end
    return result
end

StandardLibrary["filter"] = function(pred: (Any) -> Boolean, lst: List<Any>): List<Any>
    local result = {}
    for _, v in ipairs(lst) do
        if pred(v) then
            table.insert(result, v)
        end
    end
    return result
end

StandardLibrary["foldl"] = function(f: (Any, Any) -> Any, init: Any, lst: List<Any>): Any
    local result = init
    for _, v in ipairs(lst) do
        result = f(result, v)
    end
    return result
end

StandardLibrary["foldr"] = function(f: (Any, Any) -> Any, init: Any, lst: List<Any>): Any
    local result = init
    for i = #lst, 1, -1 do
        result = f(lst[i], result)
    end
    return result
end

-- Type predicates
StandardLibrary["pair?"] = function(x: Any): Boolean
    return Pair.is_pair(x)
end

StandardLibrary["null?"] = function(x: Any): Boolean
    return Pair.is_null(x)
end

StandardLibrary["list?"] = function(x: Any): Boolean
    return Pair.is_list(x)
end

StandardLibrary["number?"] = function(x: Any): Boolean
    return typeof(x) == "number"
end

StandardLibrary["string?"] = function(x: Any): Boolean
    return typeof(x) == "string"
end

StandardLibrary["boolean?"] = function(x: Any): Boolean
    return typeof(x) == "boolean"
end

StandardLibrary["procedure?"] = function(x: Any): Boolean
    return typeof(x) == "function"
end

return StandardLibrary 