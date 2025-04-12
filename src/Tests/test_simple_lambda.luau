--!strict

-- Import required modules
local Bracket = require("../init")

print("Starting simple lambda test")

-- Create a very basic lambda that just returns a constant
local result = Bracket.evaluate("(define constant-42 (lambda () 42))")
print("Defined constant function")

-- Try to use the function
local const_result = Bracket.evaluate("(constant-42)")
print("Result of (constant-42):", const_result)

-- Check if the result is correct
if const_result == 42 then
    print("✅ Test PASSED!")
else
    print("❌ Test FAILED! Expected 42, got", const_result)
end

print("Simple lambda test completed") 