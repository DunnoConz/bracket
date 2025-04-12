-- lune.config.luau
return {
	restrict = false, -- Allow modification of standard globals like 'package'
	test_directory = "tests",

	-- Define mock globals and enable standard libraries
	globals = {
		io = true, -- Enable the standard io library
		game = {
			GetService = function(self, serviceName)
				if serviceName == "ReplicatedStorage" then
					-- Return a mock ReplicatedStorage that allows requiring 'Bracket'
					-- Lune + Sourcemap should handle resolving require(mockRs.Bracket)
					local mockRs = {
						-- The key 'Bracket' here needs to match what's used in require()
						Bracket = "Bracket" -- Placeholder value, require resolves based on name/path
					}
					return mockRs
				else
					warn("Mock GetService called for unhandled service: ", serviceName)
					return nil
				end
			end,
		},
	},

	-- Expose the game global only
	expose_globals = {
		"game",
	},

	-- setup_script = "path/to/setup.luau",
	-- teardown_script = "path/to/teardown.luau",

	-- Add 'src' to the module load paths
	require_paths = {
		"?.luau",
		"?/init.luau",
		"src/?.luau",
		"src/?/init.luau"
	},
	
	-- Default task to run when no arguments are provided
	default_task = "run",
	
	-- Tasks define named commands you can run with `lune task_name`
	tasks = {
		-- Example: Run the main script
		run = {
			"src/init.luau"
		},
		
		-- Example: Run all tests using the test runner
		test = {
			"tools/run_tests.luau"
		}
	},
	
	-- Plugin configurations (optional)
	plugins = {
		-- Example: Linting configuration
		-- lint = {
		--     ignore = {
		--         "roblox_packages/",
		--         "lune_packages/"
		--     }
		-- },
		
		-- Example: Formatting configuration
		-- format = {
		--     ignore = {
		--         "roblox_packages/",
		--         "lune_packages/"
		--     }
		-- }
	}
}