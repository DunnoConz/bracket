--!nostrict

-- Tests for new type system features

local Types = require("../Types")
local Error = require("../Core/Error")
local Config = require("../Core/Config")

-- Enable strict mode for testing
Config.enable_strict_mode()

-- Helper function to test subtyping
local function assert_subtype(sub_type, super_type, expected_result)
    local result = Types.is_subtype(sub_type, super_type)
    assert(result == expected_result, 
        "Expected is_subtype(" .. Types.type_to_string(sub_type) .. ", " .. 
        Types.type_to_string(super_type) .. ") to be " .. tostring(expected_result) .. 
        " but got " .. tostring(result))
end

-- Main test function to be called by test runner
local function main()
    -- Test primitive types
    print("Testing primitive types...")
    
    -- Basic subtyping
    assert_subtype(Types.Number, Types.Number, true)
    assert_subtype(Types.Number, Types.String, false)
    assert_subtype(Types.String, Types.Any, true)
    assert_subtype(Types.Any, Types.String, false)
    assert_subtype(Types.Void, Types.Number, true)
    assert_subtype(Types.Number, Types.Void, false)
    
    print("Primitive types test passed!")

    -- Test compound types
    print("Testing compound types...")
    
    -- Pair types
    local pair_nn = Types.Pair(Types.Number, Types.Number)
    local pair_ns = Types.Pair(Types.Number, Types.String)
    local pair_ss = Types.Pair(Types.String, Types.String)
    
    assert_subtype(pair_nn, pair_nn, true)
    assert_subtype(pair_nn, pair_ns, false)
    assert_subtype(pair_ss, pair_ns, false)
    
    -- List types
    local list_n = Types.List(Types.Number)
    local list_s = Types.List(Types.String)
    
    assert_subtype(list_n, list_n, true)
    assert_subtype(list_n, list_s, false)
    assert_subtype(list_n, Types.List(Types.Any), true)
    
    -- Function types
    local fn_n_s = Types.Function({Types.Number}, Types.String)
    local fn_any_s = Types.Function({Types.Any}, Types.String)
    local fn_n_any = Types.Function({Types.Number}, Types.Any)
    
    assert_subtype(fn_n_s, fn_n_s, true)
    assert_subtype(fn_n_s, fn_any_s, true) -- Contravariance on param types
    assert_subtype(fn_any_s, fn_n_s, false)
    assert_subtype(fn_n_s, fn_n_any, true) -- Covariance on return type
    assert_subtype(fn_n_any, fn_n_s, false)
    
    print("Compound types test passed!")

    -- Test union types
    print("Testing union types...")
    
    local union_ns = Types.Union({Types.Number, Types.String})
    local union_nb = Types.Union({Types.Number, Types.Boolean})
    
    assert_subtype(Types.Number, union_ns, true)
    assert_subtype(Types.String, union_ns, true)
    assert_subtype(Types.Boolean, union_ns, false)
    
    assert_subtype(union_ns, Types.Any, true)
    assert_subtype(Types.Any, union_ns, false)
    
    -- Test nested unions and flattening
    local nested_union = Types.Union({Types.Number, Types.Union({Types.String, Types.Boolean})})
    local flattened_union = Types.Union({Types.Number, Types.String, Types.Boolean})
    
    print("DEBUG: Testing union flattening:")
    print("nested_union =", Types.type_to_string(nested_union))
    print("flattened_union =", Types.type_to_string(flattened_union))
    
    local test1 = Types.is_subtype(nested_union, flattened_union)
    local test2 = Types.is_subtype(flattened_union, nested_union)
    print("nested <: flattened =", test1)
    print("flattened <: nested =", test2)
    
    assert_subtype(nested_union, flattened_union, true)
    assert_subtype(flattened_union, nested_union, true)
    
    print("Union types test passed!")

    -- Test struct types
    print("Testing struct types...")
    
    local person_struct = Types.Struct("Person", {
        { name = "name", type = Types.String },
        { name = "age", type = Types.Number }
    })
    
    local employee_struct = Types.Struct("Employee", {
        { name = "name", type = Types.String },
        { name = "age", type = Types.Number },
        { name = "department", type = Types.String }
    })
    
    -- Struct with more fields is a subtype of struct with fewer fields
    assert_subtype(employee_struct, person_struct, true)
    assert_subtype(person_struct, employee_struct, false)
    
    local incompat_struct = Types.Struct("IncompatPerson", {
        { name = "name", type = Types.String },
        { name = "age", type = Types.String } -- Different type for age
    })
    
    assert_subtype(incompat_struct, person_struct, false)
    
    print("Struct types test passed!")

    -- Test intersection types
    print("Testing intersection types...")
    
    local string_or_number = Types.Union({Types.String, Types.Number})
    local boolean_or_number = Types.Union({Types.Boolean, Types.Number})
    
    local intersection = Types.Intersection({string_or_number, boolean_or_number})
    
    print("DEBUG: Intersection type test")
    print("string_or_number =", Types.type_to_string(string_or_number))
    print("boolean_or_number =", Types.type_to_string(boolean_or_number))
    print("intersection =", Types.type_to_string(intersection))
    
    -- Number should be a subtype of the intersection
    print("Testing Number <: intersection:")
    local result1 = Types.is_subtype(Types.Number, intersection)
    print("Result:", result1)
    assert_subtype(Types.Number, intersection, true)
    
    -- This shows that Number is the only type in the intersection
    assert_subtype(intersection, Types.Number, true)
    
    -- String should not be a subtype of the intersection
    print("Testing String <: intersection:")
    local result2 = Types.is_subtype(Types.String, intersection)
    print("Result:", result2)
    assert_subtype(Types.String, intersection, false)
    
    -- Intersection is a subtype of its components
    print("Testing intersection <: string_or_number:")
    local result3 = Types.is_subtype(intersection, string_or_number)
    print("Result:", result3)
    assert_subtype(intersection, string_or_number, true)
    
    print("Testing intersection <: boolean_or_number:")
    local result4 = Types.is_subtype(intersection, boolean_or_number)
    print("Result:", result4)
    assert_subtype(intersection, boolean_or_number, true)
    
    print("Intersection types test passed!")

    -- Test recursive types
    print("Testing recursive types...")
    
    -- Define a List type recursively (Listof T) = (U Void (Pair T Listof(T)))
    local list_of_numbers = Types.Recursive("List", 
        Types.Union({
            Types.Void, 
            Types.Pair(
                Types.Number, 
                -- Here we'd reference the type variable List, but since we're just testing
                -- we'll use Types.Any as a placeholder
                Types.Any
            )
        })
    )
    
    -- A recursive type should be a subtype of its unfolding
    local unfolded_once = Types.Union({
        Types.Void, 
        Types.Pair(
            Types.Number, 
            list_of_numbers
        )
    })
    
    print("DEBUG: Recursive type test")
    print("list_of_numbers =", Types.type_to_string(list_of_numbers))
    print("unfolded_once =", Types.type_to_string(unfolded_once))
    
    print("Testing list_of_numbers <: unfolded_once:")
    local result1 = Types.is_subtype(list_of_numbers, unfolded_once)
    print("Result:", result1)
    
    print("Testing unfolded_once <: list_of_numbers:")
    local result2 = Types.is_subtype(unfolded_once, list_of_numbers)
    print("Result:", result2)
    
    assert_subtype(list_of_numbers, unfolded_once, true)
    assert_subtype(unfolded_once, list_of_numbers, true)
    
    print("Recursive types test passed!")

    -- Test type aliases
    print("Testing type aliases...")
    
    local point_type = Types.Pair(Types.Number, Types.Number)
    local point_alias = Types.TypeAlias("Point", point_type)
    
    -- Register the alias
    Types.register_alias("Point", point_type)
    
    -- An alias is a subtype of its definition and vice versa
    assert_subtype(point_alias, point_type, true)
    assert_subtype(point_type, point_alias, true)
    
    -- Test alias resolution
    local resolved = Types.resolve_alias("Point")
    assert(resolved ~= nil, "Expected to resolve Point alias")
    assert_subtype(resolved, point_type, true)
    
    print("Type aliases test passed!")

    -- Test nominal types
    print("Testing nominal types...")
    
    local user_id_type = Types.Nominal("UserId", Types.String)
    local order_id_type = Types.Nominal("OrderId", Types.String)
    
    print("DEBUG: Nominal type test")
    print("user_id_type =", Types.type_to_string(user_id_type))
    print("order_id_type =", Types.type_to_string(order_id_type))
    
    -- Register the nominal types
    Types.register_nominal_type("UserId", Types.String)
    Types.register_nominal_type("OrderId", Types.String)
    
    -- A nominal type is not a subtype of its base type (no structural compatibility)
    print("Testing user_id_type <: string:")
    local result1 = Types.is_subtype(user_id_type, Types.String)
    print("Result:", result1)
    assert_subtype(user_id_type, Types.String, false)
    
    print("Testing string <: user_id_type:")
    local result2 = Types.is_subtype(Types.String, user_id_type)
    print("Result:", result2)
    assert_subtype(Types.String, user_id_type, false)
    
    -- Different nominal types with the same base are not compatible
    assert_subtype(user_id_type, order_id_type, false)
    assert_subtype(order_id_type, user_id_type, false)
    
    -- But a nominal type is a subtype of itself
    assert_subtype(user_id_type, user_id_type, true)
    
    -- Test nominal type resolution
    local resolved = Types.resolve_nominal_type("UserId")
    assert(resolved ~= nil, "Expected to resolve UserId nominal type")
    -- Instead, check that the resolved value is the base type of the nominal type
    assert(resolved.kind == user_id_type.base_type.kind, "Expected resolved nominal type to be the base type")
    
    print("Nominal types test passed!")

    print("All type system tests passed!")
    return 0
end

return main() 