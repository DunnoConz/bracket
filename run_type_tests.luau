--!nostrict

-- Run type system tests

local path = "./" -- Adjust if needed for the current environment
package.path = path .. "?.luau;" .. path .. "?/init.luau;" .. package.path

-- Load the test module
local tests = require("src/Tests/types_test")

-- Run all tests
tests.run_all_tests() 