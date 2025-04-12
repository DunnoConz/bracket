--!strict

-- Path relative to the current file location
local Pair = require("../../../Core/Pair")

-- Attempt 1: Relative to test file
-- local Pair = require("../../src/Core/Pair") 

-- Attempt 2: Relative to project root (if src is in path)
-- local Pair = require("src/Core/Pair")

-- Attempt 3: Relative to src (if src is in path)
-- local Pair = require("Core/Pair")

-- Test the is_pair function
local function test_is_pair()
    -- Test 1: Basic proper pair
    local proper_pair = Pair.cons(1, 2)
    print("Test 1 - Basic pair:", Pair.is_pair(proper_pair))
    
    -- Test 2: Pair with only car property (no cdr)
    local car_only = {}
    car_only.car = "test"
    -- Need to set the metatable directly here for testing
    setmetatable(car_only, { __metatable = "BracketPair" })
    print("Test 2 - Pair with only car:", Pair.is_pair(car_only))
    
    -- Test 3: Not a table
    print("Test 3 - Not a table:", Pair.is_pair(123))
    
    -- Test 4: Table without metatable
    local no_meta = { car = "test", cdr = nil }
    print("Test 4 - No metatable:", Pair.is_pair(no_meta))
    
    -- Test 5: Wrong metatable
    local wrong_meta = { car = "test", cdr = nil }
    setmetatable(wrong_meta, { __metatable = "WrongMeta" })
    print("Test 5 - Wrong metatable:", Pair.is_pair(wrong_meta))
    
    -- Test 6: Pair with nil car
    local nil_car = Pair.cons(nil, nil)
    print("Test 6 - Nil car:", Pair.is_pair(nil_car))
end

test_is_pair() 