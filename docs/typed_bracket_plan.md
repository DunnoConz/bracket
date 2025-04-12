# Typed Bracket Implementation Plan

## 1. Define Core Type System

### Basic Types
- `Number`: For numeric values
- `String`: For string values
- `Boolean`: For boolean values (#t and #f)
- `Symbol`: For symbols
- `Void`: For functions that return no value (like `define`)
- `Any`: Universal supertype

### Compound Types
- `(Pair T1 T2)`: For pairs where car is of type T1 and cdr is of type T2
- `(Listof T)`: For proper lists containing elements of type T
- `(Vector T)`: For vectors containing elements of type T
- `(HashTable K V)`: For hash tables with keys of type K and values of type V

### Function Types
- `(-> T1 T2 ... Tn R)`: Function taking arguments of types T1, T2, ..., Tn and returning a value of type R
- `(->* (T1 T2) (T3) R)`: Function with mandatory arguments T1, T2 and optional argument T3, returning R

### Union Types
- `(U T1 T2 ...)`: Union of types T1, T2, ...

### Optional Types
- `(Option T)`: Either T or #f/nil

## 2. Type Annotation Syntax

### Value Type Annotations
```scheme
(: x Number)        ; Variable declaration with type
(: add-numbers (-> Number Number Number))  ; Function type declaration
```

### Inline Type Annotations
```scheme
(define (add-numbers [x : Number] [y : Number]) : Number
  (+ x y))
```

### Structure Type Definitions
```scheme
(define-type-alias Point (Vector Number Number))
(: make-point (-> Number Number Point))
```

## 3. Implementation Steps

### 3.1 Type AST Representation
1. Extend the parser to recognize type annotations
2. Create AST nodes for each type construct
3. Define data structures to represent types internally

### 3.2 Type Checking System
1. Create a type environment to track bindings and their types
2. Implement type inference for expressions without explicit annotations
3. Implement unification for type checking
4. Add subtyping relationships

### 3.3 Type Checking Process
1. Parse code with type annotations into an AST
2. Traverse the AST, building the type environment
3. For each expression, infer or check its type
4. Report type errors with helpful messages

### 3.4 Runtime Type Checking
1. Implement type predicates (is-number? is-string? etc.)
2. Add optional runtime type checking for values passed across typed/untyped boundaries

## 4. Extension to Existing Code

### 4.1 Parser Extensions
- Add recognition of type annotations in define, lambda expressions
- Parse type definition constructs

### 4.2 Evaluator Extensions
- Add type checking before evaluation
- Implement typed lambda and define forms

### 4.3 Standard Library Typing
- Add type definitions for all standard library functions
- Implement typed versions of core operations

## 5. Optimization Opportunities
- Use type information to optimize code generation
- Eliminate runtime checks when types are proven statically
- Specialize generic operations for known types

## 6. Migration Path
- Allow gradual typing with some untyped code
- Provide a mechanism to convert untyped code to typed code
- Include a library of type definitions for common patterns

## 7. Implementation Phases

### Phase 1: Core Type System
- Implement basic type annotations and checking for primitives and simple functions
- Add type errors for mismatched types

### Phase 2: Advanced Types
- Implement compound types, union types
- Add type inference for more complex expressions

### Phase 3: Polymorphism
- Add parametric polymorphism (generic types)
- Implement type abstractions and instantiations

### Phase 4: Optimization
- Use type information to optimize generated code
- Add specialization for known type patterns 