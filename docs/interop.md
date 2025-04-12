# Interoperability between Bracket and Luau

This guide explains how to use Bracket and Luau together, allowing them to communicate and exchange data.

## Evaluating Bracket Code from Luau

The most basic form of interoperability is evaluating Bracket code from Luau:

```lua
local Bracket = require("path/to/bracket")

-- Evaluate a simple expression
local result = Bracket.evaluate("(+ 2 3)")
print(result) -- Outputs: 5
```

## Passing Luau Values to Bracket

You can pass Luau values to Bracket by interpolating them into the code string:

```lua
local x = 10
local y = 20
local result = Bracket.evaluate("(+ " .. x .. " " .. y .. ")")
print(result) -- Outputs: 30
```

For more complex data structures, you might need to serialize them:

```lua
local function serialize_table(t)
    local result = "("
    for i, v in ipairs(t) do
        if i > 1 then result = result .. " " end
        if type(v) == "table" then
            result = result .. serialize_table(v)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
    end
    return result .. ")"
end

local data = {1, 2, 3, 4, 5}
local serialized = serialize_table(data)
local sum = Bracket.evaluate("(apply + " .. serialized .. ")")
print(sum) -- Outputs: 15
```

## Defining Luau Functions for Bracket

You can expose Luau functions to Bracket by registering them:

```lua
-- Define a Luau function
local function luau_sqrt(x)
    return math.sqrt(x)
end

-- Register the function with Bracket
Bracket.register_function("sqrt", luau_sqrt)

-- Now use it in Bracket code
local result = Bracket.evaluate("(sqrt 16)")
print(result) -- Outputs: 4
```

## Executing Bracket Functions from Luau

Once you've defined functions in Bracket, you can call them from Luau:

```lua
-- Define a function in Bracket
Bracket.evaluate([[
    (define (factorial n)
        (if (= n 0)
            1
            (* n (factorial (- n 1)))))
]])

-- Call the function with different arguments
for i = 0, 5 do
    local result = Bracket.call_function("factorial", i)
    print("factorial(" .. i .. ") =", result)
end
```

## Capturing Bracket Output in Luau

You can capture output from Bracket functions:

```lua
-- Define a function that produces output
Bracket.evaluate([[
    (define (print-numbers-up-to n)
        (define (loop i)
            (if (<= i n)
                (begin
                    (display i)
                    (newline)
                    (loop (+ i 1)))))
        (loop 1))
]])

-- Capture the output
local output = Bracket.capture_output(function()
    Bracket.evaluate("(print-numbers-up-to 5)")
end)

print("Captured output:")
print(output)
```

## Creating Data Exchange Bridges

For more complex applications, you might want to create data exchange bridges:

```lua
-- Create a Luau table accessible from Bracket
local shared_data = {count = 0}

-- Expose getter and setter functions
Bracket.register_function("get-count", function()
    return shared_data.count
end)

Bracket.register_function("set-count", function(value)
    shared_data.count = value
    return value
end)

-- In Bracket, increment the counter
Bracket.evaluate([[
    (set-count (+ (get-count) 1))
]])

print("Count:", shared_data.count) -- Outputs: 1
```

## Working with Complex Data Structures

Handling complex data structures between Luau and Bracket requires proper conversion:

```lua
-- Convert Luau tables to Bracket lists
local function table_to_bracket_list(t)
    -- Implementation details depend on your Bracket internals
    -- This is a simplified example
    local code = "(list"
    for _, v in ipairs(t) do
        code = code .. " " .. tostring(v)
    end
    code = code .. ")"
    return Bracket.evaluate(code)
end

-- Convert Bracket lists to Luau tables
local function bracket_list_to_table(list)
    -- Implementation details depend on your Bracket internals
    local result = {}
    local current = list
    
    while Bracket.evaluate("(pair? " .. current .. ")") do
        table.insert(result, Bracket.evaluate("(car " .. current .. ")"))
        current = Bracket.evaluate("(cdr " .. current .. ")")
    end
    
    return result
end
```

## Best Practices

When working with both Bracket and Luau, consider these best practices:

1. **Type Safety**: Always check types when passing values between languages
2. **Error Handling**: Wrap Bracket code in pcall() to catch and handle errors gracefully
3. **Performance**: For performance-critical code, prefer native Luau
4. **Memory Management**: Be aware of how data is shared between environments
5. **Debugging**: Implement proper logging to debug interoperability issues

## Advanced Interoperability

For advanced use cases, consider implementing:

1. **Custom Type Converters**: For specialized data structures
2. **Callback Mechanisms**: For asynchronous operations
3. **Event Systems**: To notify across language boundaries
4. **Serialization Protocols**: For efficient data exchange
5. **Sandboxing**: To limit what Bracket code can access in the Luau environment 