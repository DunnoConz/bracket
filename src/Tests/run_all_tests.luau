--!strict

-- Import required modules
local fs = require("@lune/fs")
local process = require("@lune/process")

-- Test directories to scan
local TEST_DIRS = {
    "src/Tests/unit/core",
    "src/Tests/unit/parser",
    "src/Tests/unit/evaluator",
    "src/Tests/unit/stdlib",
    "src/Tests/integration"
}

-- Print available tests
print("Available Bracket tests:\n")

for _, dir in ipairs(TEST_DIRS) do
    if fs.isDir(dir) then
        print("Directory: " .. dir)
        local files = fs.readDir(dir)
        
        for _, file in ipairs(files) do
            if file:match("^test_.+%.luau$") then
                print("  - " .. dir .. "/" .. file)
            end
        end
        
        print("")
    end
end

print("\nTo run all tests, execute each test file individually with:")
print("lune run [test_file_path]")
print("\nExample:")
print("lune run src/Tests/unit/core/test_error.luau") 