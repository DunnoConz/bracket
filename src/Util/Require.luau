--!strict
-- The Unknown require: unsupported path linter errors are expected when using dynamic paths
-- They won't cause runtime errors and can be ignored

-- Cross-environment require utility
local module = {}

-- Detect environment (Roblox or Lune)
local isRoblox = false
pcall(function() 
    isRoblox = typeof(game) == "Instance" and game ~= nil
end)

function module.require(modulePath: string): any
    -- In Lune mode, just use standard require
    if not isRoblox then
        return require(modulePath) 
    end
    
    -- In Roblox mode
    -- This code is only executed in a Roblox environment where script exists
    if script == nil then
        error("Script is nil in Roblox environment")
        return nil
    end
    
    -- Find src directory
    local current = script
    while current and current.Name ~= "src" do
        current = current.Parent
    end
    
    if current == nil then
        error("Could not find src directory")
        return nil
    end
    
    -- Navigate to the module
    for _, part in ipairs(string.split(modulePath, ".")) do
        current = current:FindFirstChild(part)
        if current == nil then
            error("Could not find module component: " .. part)
            return nil
        end
    end
    
    -- Require the module
    return require(current)
end

return module 