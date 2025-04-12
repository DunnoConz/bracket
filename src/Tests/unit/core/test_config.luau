--!strict

-- Import the Config module
local Config = require("../../../Core/Config")

local function test_default_configuration()
    print("\nTesting default configuration")
    
    -- Check default values
    print("Default strict_mode is false:", Config.strict_mode == false)
    print("Default warn_on_type_error is true:", Config.warn_on_type_error == true)
    print("Default allow_implicit_conversion is true:", Config.allow_implicit_conversion == true)
    print("Default infer_return_types is true:", Config.infer_return_types == true)
    print("Default optimize_known_types is false:", Config.optimize_known_types == false)
    print("Default check_assertions is true:", Config.check_assertions == true)
    print("Default strict_syntax is false:", Config.strict_syntax == false)
end

local function test_strict_mode()
    print("\nTesting strict mode configuration")
    
    -- Enable strict mode
    Config.enable_strict_mode()
    
    print("After enable, strict_mode is true:", Config.strict_mode == true)
    print("After enable, strict_syntax is true:", Config.strict_syntax == true)
    print("After enable, allow_implicit_conversion is false:", Config.allow_implicit_conversion == false)
    
    -- Disable strict mode
    Config.disable_strict_mode()
    
    print("After disable, strict_mode is false:", Config.strict_mode == false)
    print("After disable, strict_syntax is false:", Config.strict_syntax == false)
    print("After disable, allow_implicit_conversion is true:", Config.allow_implicit_conversion == true)
end

local function test_lang_directive()
    print("\nTesting language directive parsing")
    
    -- Reset to default state
    Config.disable_strict_mode()
    
    -- Test standard directive
    local standard_code = "#lang bracket\n(define x 5)"
    local standard_result = Config.parse_lang_directive(standard_code)
    print("Standard directive detected:", standard_result == true)
    print("Standard directive keeps strict_mode false:", Config.strict_mode == false)
    
    -- Test typed directive
    local typed_code = "#lang bracket/typed\n(define x 5)"
    local typed_result = Config.parse_lang_directive(typed_code)
    print("Typed directive detected:", typed_result == true)
    print("Typed directive enables strict_mode:", Config.strict_mode == true)
    
    -- Test with no directive
    local no_directive = "(define x 5)"
    local no_directive_result = Config.parse_lang_directive(no_directive)
    print("No directive detected correctly:", no_directive_result == false)
    
    -- Test with comment but not directive
    local comment = "; This is a comment\n(define x 5)"
    local comment_result = Config.parse_lang_directive(comment)
    print("Comment without directive handled correctly:", comment_result == false)
    
    -- Test with spaces before directive
    local spaced_directive = "  #lang bracket/typed\n(define x 5)"
    local spaced_result = Config.parse_lang_directive(spaced_directive)
    print("Directive with leading spaces detected:", spaced_result == true)
end

-- Run the tests
test_default_configuration()
test_strict_mode()
test_lang_directive()

print("\nAll Config tests completed") 