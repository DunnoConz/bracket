--!strict
-- Simple Calculator Example for Bracket
-- This example demonstrates how to use Bracket to create a simple calculator

local Bracket = require("../src/init")

print("Bracket Simple Calculator Example")
print("================================")

-- Define the calculator operations in Bracket
Bracket.evaluate([[
  ; Define basic calculator operations
  (define (add a b) (+ a b))
  (define (subtract a b) (- a b))
  (define (multiply a b) (* a b))
  (define (divide a b) (/ a b))
  
  ; Define a more complex operation
  (define (average . nums)
    (/ (apply + nums) (length nums)))
    
  ; Define a calculator memory
  (define memory 0)
  
  ; Store in memory
  (define (store-result result)
    (set! memory result)
    result)
    
  ; Recall from memory
  (define (recall)
    memory)
    
  ; Clear memory
  (define (clear-memory)
    (set! memory 0)
    'memory-cleared)
]])

-- Function to run calculations
local function calculate(operation: string, ...)
  local args = {...}
  local argsStr = ""
  
  for i, arg in ipairs(args) do
    argsStr = argsStr .. " " .. tostring(arg)
  end
  
  local result = Bracket.evaluate("(" .. operation .. argsStr .. ")")
  return result
end

-- Test the calculator
print("\nBasic Operations:")
print("2 + 3 =", calculate("add", 2, 3))
print("10 - 4 =", calculate("subtract", 10, 4))
print("6 * 7 =", calculate("multiply", 6, 7))
print("20 / 5 =", calculate("divide", 20, 5))

print("\nComplex Operations:")
print("Average of 1, 2, 3, 4, 5 =", calculate("average", 1, 2, 3, 4, 5))

-- Test memory operations
print("\nMemory Operations:")
print("Storing result of 10 * 5:", calculate("store-result", calculate("multiply", 10, 5)))
print("Recalling from memory:", calculate("recall"))
print("Clearing memory:", calculate("clear-memory"))
print("Memory after clearing:", calculate("recall"))

-- Create a more complex expression using Bracket's flexibility
print("\nComplex Expression:")
local complexExpression = [[
  (let ((x 10)
        (y 5))
    (if (> x y)
        (+ (square x) (square y))
        (- (square x) (square y))))
]]
print("Result of complex expression:", Bracket.evaluate(complexExpression))

-- Interactive mode (disabled in Luau which may not have io)
-- Use this section if running with Lua instead of Luau

--[[
print("\nInteractive Calculator (type 'exit' to quit):")
while true do
  io.write("> ")
  local input = io.read()
  
  if input == "exit" then
    break
  end
  
  -- Try to evaluate the input as a Bracket expression
  local success, result = pcall(function()
    return Bracket.evaluate(input)
  end)
  
  if success then
    print("Result:", result)
  else
    print("Error:", result)
  end
end
print("Calculator closed.")
--]]

print("Example completed.") 