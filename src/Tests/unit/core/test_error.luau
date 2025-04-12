--!strict

-- Import the Error module
local Error = require("../../../Core/Error")

local function test_error_creation()
    print("\nTesting Error creation")
    
    -- Test basic error creation
    local err = Error.new("Test error message", "TestError")
    print("Basic error creation:", 
        err.message == "Test error message" and 
        err.type == "TestError" and 
        #err.stack == 0)
    
    -- Test with empty message
    local empty_msg_err = Error.new("", "EmptyError")
    print("Empty message error:", 
        empty_msg_err.message == "" and 
        empty_msg_err.type == "EmptyError")
end

local function test_stack_trace()
    print("\nTesting stack trace functionality")
    
    local err = Error.new("Test error", "StackTest")
    
    -- Test adding stack frames
    Error.add_stack_trace(err, "Frame 1")
    print("Stack after adding 1 frame:", #err.stack == 1 and err.stack[1] == "Frame 1")
    
    Error.add_stack_trace(err, "Frame 2")
    print("Stack after adding 2 frames:", #err.stack == 2 and err.stack[2] == "Frame 2")
    
    -- Test adding many frames
    local big_err = Error.new("Big stack", "BigStack")
    for i = 1, 10 do
        Error.add_stack_trace(big_err, "Frame " .. i)
    end
    print("Big stack has correct size:", #big_err.stack == 10)
end

local function test_error_formatting()
    print("\nTesting error formatting")
    
    -- Test formatting with no stack
    local simple_err = Error.new("Simple error", "SimpleError")
    local formatted = Error.format(simple_err)
    print("Simple error formatting:", formatted:find("SimpleError: Simple error"))
    
    -- Test formatting with stack
    local stack_err = Error.new("Stack error", "StackError")
    Error.add_stack_trace(stack_err, "First frame")
    Error.add_stack_trace(stack_err, "Second frame")
    
    local stack_formatted = Error.format(stack_err)
    print("Stack error contains type and message:", 
        stack_formatted:find("StackError: Stack error"))
    print("Stack error contains frames:", 
        stack_formatted:find("1. First frame") and 
        stack_formatted:find("2. Second frame"))
end

-- Run all tests
test_error_creation()
test_stack_trace()
test_error_formatting()

print("\nAll Error tests completed") 