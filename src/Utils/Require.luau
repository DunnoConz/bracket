-- src/Util/Require.luau
local module = {}

local function findPackageRoot(startScript)
	local current = startScript
	while current do
		if current:FindFirstChild("_PACKAGEROOT.luau") then
			return current
		end
		current = current.Parent
	end
	return nil
end

function module.require(callingScript, modulePath)
	local success, result = pcall(require, modulePath)
	if success then
		return result
	else
		-- Standard require failed, try resolving relative to package root
		local packageRoot = findPackageRoot(callingScript)
		if packageRoot then
			local pathSegments = string.split(modulePath, ".")
			local target = packageRoot
			for _, segment in ipairs(pathSegments) do
				target = target:FindFirstChild(segment)
				if not target then
					error(string.format("Could not find module segment '%s' in path '%s' starting from %s", segment, modulePath, packageRoot:GetFullName()))
					return nil
				end
			end
			
			success, result = pcall(require, target)
			if success then
				return result
			else
				-- Log the second error for more context
				warn("Custom require failed after standard require failed for path: ", modulePath)
				warn("Second error: ", result)
				error(string.format("Failed to require module '%s' from %s using both standard and custom resolution.", modulePath, callingScript:GetFullName()), 0)
			end
		else
			-- Package root not found, re-throw original error
			warn("Could not find _PACKAGEROOT.luau starting from: ", callingScript:GetFullName())
			error(string.format("Failed to require module '%s': %s", modulePath, tostring(result)), 0)
		end
	end
end

return module 