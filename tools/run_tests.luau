--!strict

-- Test runner for Bracket language tests

-- Use Lune standard libraries
local fs = require("@lune/fs")
local process = require("@lune/process")
-- console is not available, use print

-- Configuration
local DIRECT_RUN_DIRS = {
    "src/Tests/unit/core",
    "src/Tests/unit/parser",
    "src/Tests/unit/evaluator",
    "src/Tests/unit/stdlib",
    "test/unit/core",
    "test/unit/parser",
}
local BRACKET_RUN_DIRS = {
    "src/Tests/integration",
    "test/unit/evaluator",
    "test/unit/stdlib",
    "test/integration",
    "test/examples"
} 