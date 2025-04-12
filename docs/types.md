# Bracket Language Type System

## Overview

Bracket features a static type system inspired by typed functional languages like Typed Racket and TypeScript. The type system allows for optional type checking with a rich set of type features.

## Basic Types

### Primitive Types

- `Number`: Represents numeric values
- `String`: Represents text values
- `Boolean`: Represents true/false values
- `Symbol`: Represents symbols/identifiers
- `Void`: Represents absence of value (similar to `null` or `nil`)
- `Any`: The top type that accepts any value

### Compound Types

- `Pair`: A pair of two values (car and cdr) - `(Pair T1 T2)`
- `List`: A homogeneous list of elements - `(Listof T)`
- `Vector`: A fixed-size homogeneous vector - `(Vectorof T)`
- `HashTable`: A key-value mapping - `(HashTable K V)`
- `Function`: A function with typed parameters and return value - `(-> (T1 T2...) R)`

## Advanced Type Features

### Union Types

Union types represent values that can be one of several types.

```bracket
(U Number String)  ; Either a number or a string
```

Union types can be nested and the type system automatically flattens them and removes duplicates.

### Intersection Types

Intersection types represent values that must satisfy multiple types simultaneously.

```bracket
(∩ (-> (Number) String) (-> (Number) (Listof String)))  ; A function returning both a string and a list of strings
```

### Recursive Types

Recursive types allow for defining self-referential types, such as tree structures.

```bracket
(μ TreeNode (U Number (Pair TreeNode TreeNode)))  ; A tree node that can be a number or a pair of tree nodes
```

### Type Aliases

Type aliases provide a way to name complex types for easier reuse.

```bracket
(define-type Point (Pair Number Number))
(define-type Line (Pair Point Point))
```

Type aliases are expanded at use sites and do not affect the subtyping relationship.

### Nominal Types

Nominal types provide branding to create distinct types that are incompatible with other types with the same structure.

```bracket
(define-nominal-type UserId String)
(define-nominal-type OrderId String)

; UserId and OrderId are incompatible with each other and with plain strings
```

### Struct Types

Struct types represent record-like data structures with named fields.

```bracket
(define-struct Person
  [name : String]
  [age : Number]
  [address : (Optional String)])
```

## Type Checking

### Subtyping Rules

1. `Any` is a supertype of all types
2. `Void` is a subtype of all types except `Any`
3. Primitive types are only subtypes of themselves and `Any`
4. Pair, list, and vector types are covariant in their element types
5. Function types are contravariant in parameter types and covariant in return types
6. HashTable types are invariant in key types and covariant in value types
7. Union types follow standard set-theoretic subtyping
8. Intersection types follow standard set-theoretic subtyping
9. Struct types follow structural subtyping rules (a struct is a subtype of another if it has all the fields of the other with compatible types)
10. Nominal types are only subtypes of themselves and their declared base type

### Type Inference

The language attempts to infer types when possible, without requiring explicit type annotations.

### Type Assertions

Explicit type assertions can be used to upcast or downcast values:

```bracket
(: value TypeName)  ; Assert that value has type TypeName
```

### Optional Type Checking

Type checking can be enabled or disabled:

- Use `#lang bracket` for dynamic typing with optional type checking
- Use `#lang bracket/typed` for strict type checking

## Usage Examples

### Basic Function with Type Annotations

```bracket
(define (add [a : Number] [b : Number]) : Number
  (+ a b))
```

### Union Types and Pattern Matching

```bracket
(define (process-value [val : (U Number String)]) : String
  (match val
    [(? number?) (number->string val)]
    [(? string?) (string-append "String: " val)]))
```

### Recursive Types for Data Structures

```bracket
(define-type BinaryTree (μ Tree (U Void (struct Node [value : Number] [left : Tree] [right : Tree]))))

(define (sum-tree [tree : BinaryTree]) : Number
  (match tree
    [#void 0]
    [(Node value left right) (+ value (sum-tree left) (sum-tree right))]))
```

### Type Aliases for Complex Types

```bracket
(define-type UserData (HashTable String (U String Number Boolean)))

(define (get-user-name [data : UserData]) : (Optional String)
  (hash-ref data "name" #void))
```

### Nominal Types for Type Safety

```bracket
(define-nominal-type Email String)
(define-nominal-type Password String)

(define (create-user [email : Email] [password : Password])
  ; Email and Password can't be accidentally switched because they're distinct types
  (make-user email password))
```

## Error Messages

The type system provides clear error messages when type checking fails:

```
Type error: Expected Number, got value "hello" (type String)
```

## Implementation Details

The type system is implemented in Luau (a Lua variant) and provides runtime type checking capabilities. Type information can also be used for optimizations in the runtime. 