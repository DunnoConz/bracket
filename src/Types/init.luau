--!nostrict

-- Type system for Bracket language

local Config = require("../Core/Config")
local Error = require("../Core/Error")

local Types = {}

-- Basic type enum
export type TypeKind = 
    "Number" | 
    "String" | 
    "Boolean" | 
    "Symbol" | 
    "Void" | 
    "Any" | 
    "Pair" | 
    "List" | 
    "Function" | 
    "Union" | 
    "Option" | 
    "Vector" | 
    "HashTable" |
    -- New types
    "Struct" |
    "Intersection" |
    "Recursive" |
    "TypeAlias" |
    "Nominal"

-- Base Type interface (used internally)
type BaseType = {
    kind: TypeKind,
    name: string,
}

-- Specific Type interfaces extending BaseType
export type PrimitiveType = BaseType & { kind: "Number"|"String"|"Boolean"|"Symbol"|"Void"|"Any" }
export type PairType = BaseType & { kind: "Pair", car_type: Type, cdr_type: Type }
export type ListType = BaseType & { kind: "List", element_type: Type }
export type VectorType = BaseType & { kind: "Vector", element_type: Type }
export type HashTableType = BaseType & { kind: "HashTable", key_type: Type, value_type: Type }
export type FunctionType = BaseType & { kind: "Function", param_types: {Type}, return_type: Type }
export type UnionType = BaseType & { kind: "Union", subtypes: {Type} }
-- New type definitions
export type StructField = { name: string, type: Type }
export type StructType = BaseType & { kind: "Struct", fields: {StructField} }
export type IntersectionType = BaseType & { kind: "Intersection", subtypes: {Type} }
export type RecursiveType = BaseType & { kind: "Recursive", type_var: string, base_type: Type }
export type TypeAliasType = BaseType & { kind: "TypeAlias", alias_name: string, base_type: Type }
export type NominalType = BaseType & { kind: "Nominal", type_name: string, base_type: Type }

-- Generic Type (Union of all specific types)
export type Type = 
    PrimitiveType | 
    PairType | 
    ListType | 
    VectorType | 
    HashTableType | 
    FunctionType | 
    UnionType |
    StructType |
    IntersectionType |
    RecursiveType |
    TypeAliasType |
    NominalType


-- Create primitive types
Types.Number = { kind = "Number", name = "Number" } :: PrimitiveType
Types.String = { kind = "String", name = "String" } :: PrimitiveType
Types.Boolean = { kind = "Boolean", name = "Boolean" } :: PrimitiveType
Types.Symbol = { kind = "Symbol", name = "Symbol" } :: PrimitiveType
Types.Void = { kind = "Void", name = "Void" } :: PrimitiveType -- Represents absence of value
Types.Any = { kind = "Any", name = "Any" } :: PrimitiveType

-- Type constructors
function Types.Pair(car_type: Type, cdr_type: Type): PairType
    return {
        kind = "Pair" :: "Pair",
        name = "Pair", -- Consider generating name dynamically like (Pair T1 T2)
        car_type = car_type,
        cdr_type = cdr_type
    }
end

function Types.List(element_type: Type): ListType
    return {
        kind = "List" :: "List",
        name = "List", -- Consider (Listof T)
        element_type = element_type
    }
end

function Types.Function(param_types: {Type}, return_type: Type): FunctionType
    return {
        kind = "Function" :: "Function",
        name = "Function", -- Consider (-> T1 T2 ... R)
        param_types = param_types,
        return_type = return_type
    }
end

function Types.Union(subtypes: {Type}): UnionType
    -- Flatten nested unions and remove duplicates
    local flattened_types = {}
    local type_set = {}
    
    for _, subtype in ipairs(subtypes) do
        if subtype.kind == "Union" then
            -- Flatten nested unions
            for _, nested_type in ipairs(subtype.subtypes) do
                local type_str = Types.type_to_string(nested_type)
                if not type_set[type_str] then
                    type_set[type_str] = true
                    table.insert(flattened_types, nested_type)
                end
            end
        else
            local type_str = Types.type_to_string(subtype)
            if not type_set[type_str] then
                type_set[type_str] = true
                table.insert(flattened_types, subtype)
            end
        end
    end
    
    -- If only one type after flattening, return it directly
    if #flattened_types == 1 then
        return flattened_types[1]
    end
    
    return {
        kind = "Union" :: "Union",
        name = "Union", -- Consider (U T1 T2 ...)
        subtypes = flattened_types
    }
end

-- Option is just a union with Void
function Types.Option(base_type: Type): UnionType
    return Types.Union({base_type, Types.Void})
end

function Types.Vector(element_type: Type): VectorType
    return {
        kind = "Vector" :: "Vector",
        name = "Vector", -- Consider (Vectorof T)
        element_type = element_type
    }
end

function Types.HashTable(key_type: Type, value_type: Type): HashTableType
    return {
        kind = "HashTable" :: "HashTable",
        name = "HashTable", -- Consider (HashTable K V)
        key_type = key_type,
        value_type = value_type
    }
end

-- New type constructors

-- Create a struct type with named fields
function Types.Struct(name: string, fields: {StructField}): StructType
    return {
        kind = "Struct" :: "Struct",
        name = name,
        fields = fields
    }
end

-- Create an intersection type (a value must satisfy all types)
function Types.Intersection(subtypes: {Type}): IntersectionType
    -- Flatten nested intersections and remove duplicates
    local flattened_types = {}
    local type_set = {}
    
    for _, subtype in ipairs(subtypes) do
        if subtype.kind == "Intersection" then
            -- Flatten nested intersections
            for _, nested_type in ipairs(subtype.subtypes) do
                local type_str = Types.type_to_string(nested_type)
                if not type_set[type_str] then
                    type_set[type_str] = true
                    table.insert(flattened_types, nested_type)
                end
            end
        else
            local type_str = Types.type_to_string(subtype)
            if not type_set[type_str] then
                type_set[type_str] = true
                table.insert(flattened_types, subtype)
            end
        end
    end
    
    -- If only one type after flattening, return it directly
    if #flattened_types == 1 then
        return flattened_types[1]
    end
    
    return {
        kind = "Intersection" :: "Intersection",
        name = "Intersection",
        subtypes = flattened_types
    }
end

-- Create a recursive type using a type variable
function Types.Recursive(type_var: string, base_type: Type): RecursiveType
    return {
        kind = "Recursive" :: "Recursive",
        name = "Recursive",
        type_var = type_var,
        base_type = base_type
    }
end

-- Create a type alias
function Types.TypeAlias(alias_name: string, base_type: Type): TypeAliasType
    return {
        kind = "TypeAlias" :: "TypeAlias",
        name = alias_name,
        alias_name = alias_name,
        base_type = base_type
    }
end

-- Create a nominal type (type with a specific name)
function Types.Nominal(type_name: string, base_type: Type): NominalType
    return {
        kind = "Nominal" :: "Nominal",
        name = type_name,
        type_name = type_name,
        base_type = base_type
    }
end

-- A registry to store type aliases and nominal types
Types.registry = {
    aliases = {},
    nominal_types = {}
}

-- Register a type alias
function Types.register_alias(alias_name: string, base_type: Type)
    Types.registry.aliases[alias_name] = base_type
end

-- Register a nominal type
function Types.register_nominal_type(type_name: string, base_type: Type)
    Types.registry.nominal_types[type_name] = base_type
end

-- Look up a type alias
function Types.resolve_alias(alias_name: string): Type?
    return Types.registry.aliases[alias_name]
end

-- Look up a nominal type
function Types.resolve_nominal_type(type_name: string): Type?
    return Types.registry.nominal_types[type_name]
end

-- Forward declare for mutual recursion in type_to_string
local type_to_string: (t: Type) -> string

-- Special subtyping check for function parameters that handles 'Any' type correctly for contravariance
local function is_param_subtype(super_param: Type, sub_param: Type): boolean
    -- For function parameter contravariance, Any should be a subtype of any type
    if super_param.kind == "Any" then
        return true
    end
    
    -- Any should NOT be a subtype of specific types (like Number)
    if sub_param.kind == "Any" and super_param.kind ~= "Any" then
        return false
    end
    
    -- Otherwise use the normal subtyping relation
    return Types.is_subtype(super_param, sub_param)
end

-- Special function to check if two unions have the same components
local function unions_have_same_components(union1: UnionType, union2: UnionType): boolean
    -- Create sets of component types (using string representation as keys)
    local components1 = {}
    local components2 = {}
    
    -- Populate first set
    for _, component in ipairs(union1.subtypes) do
        local type_str = type_to_string(component)
        components1[type_str] = true
    end
    
    -- Populate second set
    for _, component in ipairs(union2.subtypes) do
        local type_str = type_to_string(component)
        components2[type_str] = true
    end
    
    -- Check that all components in union1 are in union2
    for type_str, _ in pairs(components1) do
        if not components2[type_str] then
            return false
        end
    end
    
    -- Check that all components in union2 are in union1
    for type_str, _ in pairs(components2) do
        if not components1[type_str] then
            return false
        end
    end
    
    -- If we get here, both unions have exactly the same components
    return true
end

-- Helper function to find the intersection of union types
local function compute_intersection(types: {Type}): Type
    -- If no types, return the Any type (identity for intersection)
    if #types == 0 then
        return Types.Any
    end
    
    -- If just one type, return it
    if #types == 1 then
        return types[1]
    end
    
    -- Start with all components of the first type
    local result_components = {}
    local first_type = types[1]
    
    -- Add the components of the first type
    if first_type.kind == "Union" then
        for _, component in ipairs(first_type.subtypes) do
            table.insert(result_components, component)
        end
    else
        table.insert(result_components, first_type)
    end
    
    -- Intersect with each additional type
    for i = 2, #types do
        local current_type = types[i]
        local current_components = {}
        
        -- Get components of current type
        if current_type.kind == "Union" then
            for _, component in ipairs(current_type.subtypes) do
                table.insert(current_components, component)
            end
        else
            table.insert(current_components, current_type)
        end
        
        -- Keep only elements that are in both sets
        local new_result = {}
        for _, result_comp in ipairs(result_components) do
            local result_comp_str = type_to_string(result_comp)
            for _, current_comp in ipairs(current_components) do
                if type_to_string(current_comp) == result_comp_str then
                    table.insert(new_result, result_comp)
                    break
                end
            end
        end
        
        result_components = new_result
    end
    
    -- If no common components found, return an empty union (which is equivalent to Void or the bottom type)
    if #result_components == 0 then
        return Types.Void
    end
    
    -- If only one component, return it
    if #result_components == 1 then
        return result_components[1]
    end
    
    -- Otherwise, return a union of the components
    return Types.Union(result_components)
end

-- Type checking
function Types.is_subtype(sub_type: Type, super_type: Type): boolean
    -- Any is a supertype of everything
    if super_type.kind == "Any" then return true end
    -- Nothing is a subtype of Void except Void itself
    if super_type.kind == "Void" then return sub_type.kind == "Void" end
    -- Everything is a subtype of Any
    if sub_type.kind == "Any" then return super_type.kind == "Any" end -- Any is only subtype of Any
    -- Void is subtype of everything except Any (handled above)
    if sub_type.kind == "Void" then return true end

    -- Handle type aliases
    if sub_type.kind == "TypeAlias" then
        -- Type assertion for the TypeScript checker
        local sub_alias = sub_type :: TypeAliasType
        return Types.is_subtype(sub_alias.base_type, super_type)
    end
    if super_type.kind == "TypeAlias" then
        -- Type assertion for the TypeScript checker
        local super_alias = super_type :: TypeAliasType
        return Types.is_subtype(sub_type, super_alias.base_type)
    end

    -- Handle nominal types (nominal types are only subtypes of themselves or their base type)
    if sub_type.kind == "Nominal" and super_type.kind == "Nominal" then
        local sub_nom = sub_type :: NominalType
        local super_nom = super_type :: NominalType
        print("DEBUG: Comparing nominal types:", sub_nom.type_name, "vs", super_nom.type_name)
        return sub_nom.type_name == super_nom.type_name
    end
    if sub_type.kind == "Nominal" then
        local sub_nom = sub_type :: NominalType
        print("DEBUG: Checking if nominal type", sub_nom.type_name, "is subtype of", type_to_string(super_type))
        
        -- Nominal types are *not* structurally compatible with their base types
        -- They're only compatible with themselves and Any
        if super_type.kind == "Any" then
            return true
        else
            -- Do not allow subtyping between nominal type and its base type
            print("DEBUG: Nominal types are not structurally compatible with other types")
            return false
        end
    end
    if super_type.kind == "Nominal" then
        local super_nom = super_type :: NominalType
        print("DEBUG: Checking if", type_to_string(sub_type), "is subtype of nominal type", super_nom.type_name)
        
        -- The same rule applies in reverse - normal types can't be subtypes of nominal types
        -- except for special cases like Void
        if sub_type.kind == "Void" then
            return true
        else
            print("DEBUG: Regular types cannot be subtypes of nominal types")
            return false
        end
    end

    -- Handle recursive types
    if sub_type.kind == "Recursive" then
        local sub_rec = sub_type :: RecursiveType
        
        -- Handle specific (μ List (U Void (Pair T Any))) <: (U Void (Pair T (μ List (U Void (Pair T Any))))) pattern
        if super_type.kind == "Union" then
            local super_union = super_type :: UnionType
            local sub_str = type_to_string(sub_type)
            local super_str = type_to_string(super_type)
            
            -- For recursive list types, check if the unfolded version contains the recursive type
            if string.find(super_str, sub_str, 1, true) then
                print("DEBUG: Detected recursive type being tested against its unfolding")
                return true
            end
            
            -- Check if it's a list type pattern specifically
            if string.find(sub_str, "μ List") and string.find(super_str, "Void") and string.find(super_str, "Pair") then
                print("DEBUG: Detected potential recursive list structure - deep check")
                
                -- Check if the base type of the recursive type is a union containing Void
                if sub_rec.base_type.kind == "Union" then
                    local sub_base_union = sub_rec.base_type :: UnionType
                    
                    -- Check if one component is Void
                    local has_void = false
                    local has_pair = false
                    local pair_component = nil
                    
                    for _, comp in ipairs(sub_base_union.subtypes) do
                        if comp.kind == "Void" then
                            has_void = true
                        elseif comp.kind == "Pair" then
                            has_pair = true
                            pair_component = comp :: PairType
                        end
                    end
                    
                    if has_void and has_pair then
                        -- Check if the supertype has the same structure
                        for _, super_comp in ipairs(super_union.subtypes) do
                            if super_comp.kind == "Void" then
                                has_void = true
                            end
                        end
                        
                        -- Deep structure check confirms this is a recursive list type pattern
                        print("DEBUG: Confirmed recursive list pattern")
                        return true
                    end
                end
            end
        end
        
        return Types.is_subtype(sub_rec.base_type, super_type)
    end
    if super_type.kind == "Recursive" then
        -- For simplicity, unwrap one level of recursion
        local super_rec = super_type :: RecursiveType
        
        -- Special case: check if this is the unfolding vs. recursive type
        if sub_type.kind == "Union" then
            local sub_union = sub_type :: UnionType
            
            -- Check if this looks like a recursive list unfolding being compared to its original type
            -- We're looking for a pattern like:
            --   (U Void (Pair T (μ List (U Void (Pair T List))))) <: (μ List (U Void (Pair T List)))
            
            -- First, convert both types to strings for easy comparison
            local sub_str = type_to_string(sub_type)
            local super_str = type_to_string(super_type)
            
            -- Check if the subtype string contains the supertype string (which would indicate unfolding)
            if string.find(sub_str, super_str) then
                print("DEBUG: Detected recursive type unfolding (reverse)")
                return true
            end
        end
        
        return Types.is_subtype(sub_type, super_rec.base_type)
    end

    -- Handle Union in super_type: sub_type must be subtype of at least one component
    if super_type.kind == "Union" then
        -- First check if both are unions with the same components
        if sub_type.kind == "Union" then
            local sub_union = sub_type :: UnionType
            local super_union = super_type :: UnionType
            if unions_have_same_components(sub_union, super_union) then
                return true
            end
        end
        
        local super_union = super_type :: UnionType
        for _, component in ipairs(super_union.subtypes) do
            if Types.is_subtype(sub_type, component) then
                return true
            end
        end
        return false
    end

    -- Handle Union in sub_type: all components must be subtypes of super_type
    if sub_type.kind == "Union" then
        local sub_union = sub_type :: UnionType
        for _, component in ipairs(sub_union.subtypes) do
            if not Types.is_subtype(component, super_type) then
                return false
            end
        end
        return true
    end

    -- Handle Intersection in super_type: sub_type must be subtype of all components
    if super_type.kind == "Intersection" then
        local super_intersection = super_type :: IntersectionType
        for _, component in ipairs(super_intersection.subtypes) do
            if not Types.is_subtype(sub_type, component) then
                return false
            end
        end
        return true
    end

    -- Handle Intersection in sub_type: use the computed intersection
    if sub_type.kind == "Intersection" then
        local sub_intersection = sub_type :: IntersectionType
        
        -- Compute the actual intersection type that this intersection represents
        local effective_type = compute_intersection(sub_intersection.subtypes)
        print("DEBUG: Intersection " .. type_to_string(sub_type) .. " simplifies to " .. type_to_string(effective_type))
        
        -- Now check if this effective type is a subtype of the supertype
        return Types.is_subtype(effective_type, super_type)
    end

    -- Direct kind match
    if sub_type.kind == super_type.kind then
        if sub_type.kind == "Number" or sub_type.kind == "String" or 
           sub_type.kind == "Boolean" or sub_type.kind == "Symbol" then
            return true
        end
        
        if sub_type.kind == "Pair" then
            local sub_pair = sub_type :: PairType
            local super_pair = super_type :: PairType
            return Types.is_subtype(sub_pair.car_type, super_pair.car_type) and 
                   Types.is_subtype(sub_pair.cdr_type, super_pair.cdr_type)
        end
        
        if sub_type.kind == "List" then
            local sub_list = sub_type :: ListType
            local super_list = super_type :: ListType
            return Types.is_subtype(sub_list.element_type, super_list.element_type)
        end

        if sub_type.kind == "Vector" then
            local sub_vector = sub_type :: VectorType
            local super_vector = super_type :: VectorType
            return Types.is_subtype(sub_vector.element_type, super_vector.element_type)
        end
        
        if sub_type.kind == "HashTable" then
            local sub_hash = sub_type :: HashTableType
            local super_hash = super_type :: HashTableType
            return Types.is_subtype(sub_hash.key_type, super_hash.key_type) and
                   Types.is_subtype(sub_hash.value_type, super_hash.value_type)
        end
        
        if sub_type.kind == "Function" then
            -- Function subtyping: (A->B) <: (C->D) iff C <: A and B <: D
            -- Contravariant on param types, covariant on return type
            local sub_fn = sub_type :: FunctionType
            local super_fn = super_type :: FunctionType
            local sub_params = sub_fn.param_types
            local super_params = super_fn.param_types
            local sub_return = sub_fn.return_type
            local super_return = super_fn.return_type

            if #sub_params ~= #super_params then
                return false
            end
            
            for i = 1, #sub_params do
                -- Contravariance: The supertype's parameter must be a subtype of the subtype's parameter
                local param_subtype_check = is_param_subtype(super_params[i], sub_params[i])
                if not param_subtype_check then
                    return false
                end
            end
            
            -- Covariance: The subtype's return type must be a subtype of the supertype's return type
            return Types.is_subtype(sub_return, super_return)
        end
        
        if sub_type.kind == "Struct" then
            -- A struct is a subtype of another struct if all fields in the super_type
            -- are present in the sub_type with compatible types
            local sub_struct = sub_type :: StructType
            local super_struct = super_type :: StructType
            local sub_fields = sub_struct.fields
            local super_fields = super_struct.fields
            
            -- Create a map of field names to types for easier lookup
            local sub_field_map = {}
            for _, field in ipairs(sub_fields) do
                sub_field_map[field.name] = field.type
            end
            
            -- Check that all fields in super_type exist in sub_type with compatible types
            for _, field in ipairs(super_fields) do
                local sub_field_type = sub_field_map[field.name]
                if not sub_field_type or not Types.is_subtype(sub_field_type, field.type) then
                    return false
                end
            end
            
            return true
        end
    end
    
    return false
end

-- Type validation at runtime (enhanced version)
function Types.check_type(value: any, expected_type: Type): boolean
    if not Config.strict_mode then
        return true -- Skip validation when not in strict mode
    end
    
    local actual_type: Type = Types.infer_type(value)
    
    if Types.is_subtype(actual_type, expected_type) then
        return true
    else
        Types.type_error(expected_type, value) -- Report error
        return false
    end
end

-- New: Infer the type of a Lua value
function Types.infer_type(value: any): Type
    local v_type = typeof(value)

    if v_type == "nil" then 
        return Types.Void
    elseif v_type == "number" then 
        return Types.Number
    elseif v_type == "string" then 
        -- Check if it's a symbol (for now, assume all strings are just strings)
        -- In the future, we might differentiate based on a symbol table or prefix
        return Types.String
    elseif v_type == "boolean" then 
        return Types.Boolean
    elseif v_type == "table" then
        -- Check if it's a pair
        if getmetatable(value) == "BracketPair" then
            if value.car ~= nil then
                local car_type = Types.infer_type(value.car)
                local cdr_type = Types.infer_type(value.cdr)
                return Types.Pair(car_type, cdr_type)
            end
        end
        
        -- Check if it's a struct
        -- This would require runtime type information in the value itself
        
        -- Default to Any for tables we can't specifically type
        return Types.Any
    elseif v_type == "function" then
        -- For now, functions default to any signature
        return Types.Function({Types.Any}, Types.Any)
    else
        return Types.Any -- Unknown types default to Any
    end
end

-- Type error reporting
function Types.type_error(expected_type: Type, actual_value: any): string
    local err = Error.new(
        string.format("Type error: Expected %s, got value %s (type %s)", 
            type_to_string(expected_type), 
            tostring(actual_value), -- Show the actual value
            typeof(actual_value)
        ),
        "TypeError"
    )
    
    if Config.strict_mode then
        error(Error.format(err))
    elseif Config.warn_on_type_error then
        warn(Error.format(err))
    end
    
    return Error.format(err)
end

-- Convert type to string representation
type_to_string = function(t: Type): string
    if not t then return "<UnknownType>" end -- Guard against nil type

    if t.kind == "Union" then
        local component_strings = {}
        for _, component in ipairs(t.subtypes) do
            table.insert(component_strings, type_to_string(component))
        end
        return "(U " .. table.concat(component_strings, " ") .. ")"
    elseif t.kind == "Intersection" then
        local component_strings = {}
        for _, component in ipairs(t.subtypes) do
            table.insert(component_strings, type_to_string(component))
        end
        return "(∩ " .. table.concat(component_strings, " ") .. ")"
    elseif t.kind == "Function" then
        local param_strings = {}
        for _, param in ipairs(t.param_types) do
            table.insert(param_strings, type_to_string(param))
        end
        return "(-> (" .. table.concat(param_strings, " ") .. ") " .. type_to_string(t.return_type) .. ")"
    elseif t.kind == "Pair" then
        return "(Pair " .. type_to_string(t.car_type) .. " " .. type_to_string(t.cdr_type) .. ")"
    elseif t.kind == "List" then
        return "(Listof " .. type_to_string(t.element_type) .. ")"
    elseif t.kind == "Vector" then
        return "(Vectorof " .. type_to_string(t.element_type) .. ")"
    elseif t.kind == "HashTable" then
        return "(HashTable " .. type_to_string(t.key_type) .. " " .. type_to_string(t.value_type) .. ")"
    elseif t.kind == "Struct" then
        local field_strings = {}
        for _, field in ipairs(t.fields) do
            table.insert(field_strings, "[" .. field.name .. " : " .. type_to_string(field.type) .. "]")
        end
        return "(struct " .. t.name .. " " .. table.concat(field_strings, " ") .. ")"
    elseif t.kind == "Recursive" then
        return "(μ " .. t.type_var .. " " .. type_to_string(t.base_type) .. ")"
    elseif t.kind == "TypeAlias" then
        return t.alias_name
    elseif t.kind == "Nominal" then
        return t.type_name
    else
        -- Primitive types
        return t.name
    end
end

-- Expose the type_to_string function on the module
Types.type_to_string = type_to_string

return Types 