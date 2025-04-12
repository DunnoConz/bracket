--!strict

-- Simple TestKit for Bracket

local Error = require("../Core/Error")

local TestKit = {}

local test_count = 0
local fail_count = 0

-- Basic assertion (now a regular function)
function TestKit.assert(condition: boolean, message: string?)
    test_count += 1
    if not condition then
        fail_count += 1
        -- Use error formatting for consistency
        local err = Error.new("Assertion Failed: " .. (message or ""), "AssertionError")
        error(Error.format(err)) -- Still errors to halt test run
    end
end

-- Equality assertion (now a regular function)
function TestKit.assert_equal(actual: any, expected: any, message: string?)
    test_count += 1
    if actual ~= expected then
        fail_count += 1
        local base_msg = message or ""
        local detail_msg = string.format("%s Expected %s, got %s", base_msg, tostring(expected), tostring(actual))
        local err = Error.new("Assertion Failed: " .. detail_msg, "AssertionError")
        error(Error.format(err)) -- Still errors to halt test run
    end
end

-- Test grouping (still does nothing special, could be removed)
function TestKit.test(name: string, func: () -> ())
    -- Just call the function containing the assertions
    func()
end

function TestKit.get_results(): {total: number, failed: number}
    return { total = test_count, failed = fail_count }
end

function TestKit.reset_results()
    test_count = 0
    fail_count = 0
end

return TestKit 