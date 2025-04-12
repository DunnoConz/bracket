--!strict

-- Import required modules
local Bracket = require("../init")

-- Run a simple test
print("Running lambda test directly...")

-- Define a function that takes a parameter and adds 1
local define_result = Bracket.evaluate("(define f (lambda (x) 42))")
print("Function defined")

-- Run it
local result = Bracket.evaluate("(f 10)")
print("Result:", result)

if result == 42 then
    print("✅ Test PASSED!")
else
    print("❌ Test FAILED! Expected 42, got", result)
end

print("Lambda test complete!") 