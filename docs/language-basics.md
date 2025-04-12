# Bracket Language Basics

This guide covers the fundamental concepts and syntax of the Bracket language, a Language Oriented Programming solution.

## Language Design Principles

Bracket is designed with these principles in mind:
- **Expressiveness**: The syntax should clearly express the intent
- **Consistency**: Similar operations should have similar forms
- **Extensibility**: The language should be easy to extend
- **Integration**: The language should work well with Luau

## Syntax

Bracket uses a Lisp-like syntax with parentheses. Every expression is enclosed in parentheses, with the operator or function name coming first, followed by its arguments. This design choice makes the language:
- Easy to parse and evaluate
- Consistent in its structure
- Clear in its intent

### Basic Syntax Rules

1. **Expressions**: `(operator arg1 arg2 ...)`
2. **Function Calls**: `(function-name arg1 arg2 ...)`
3. **Special Forms**: `(special-form arg1 arg2 ...)`

## Data Types

Bracket supports the following basic data types, chosen for their utility in domain-specific programming:

- **Numbers**: `1`, `2.5`, `-3`
- **Booleans**: `#t` (true), `#f` (false)
- **Nil**: `nil`
- **Symbols**: `x`, `my-var`, `+`
- **Lists**: `(1 2 3)`, `(a b c)`

## Special Forms

Special forms are language constructs that have special evaluation rules:

### `define`

Defines a variable or function, allowing you to extend the language:

```racket
(define x 10)  ; Define a variable
(define (square x) (* x x))  ; Define a function
```

### `if`

Conditional expression, providing control flow:

```racket
(if condition
    then-expression
    else-expression)
```

Example:
```racket
(if (> x 0)
    "positive"
    "negative or zero")
```

### `lambda`

Creates an anonymous function, enabling higher-order programming:

```racket
(lambda (x) (* x x))
```

## Function Calls

Functions are called by placing the function name first, followed by its arguments. This uniform calling convention makes the language predictable and easy to learn:

```racket
(+ 1 2 3)      ; Addition
(* 2 3 4)      ; Multiplication
(and #t #f)    ; Logical AND
(or #t #f)     ; Logical OR
```

## Testing as a Language Feature

Testing is built into the language as a first-class feature:

### `test`

Defines a test case:

```racket
(test "Test name"
    assertion1
    assertion2
    ...)
```

### `assert-equal`

Checks if two expressions are equal:

```racket
(assert-equal expression expected-value)
```

## Examples

### Basic Arithmetic

```racket
(+ 1 2 3)      ; 6
(* 2 3 4)      ; 24
(- 10 5)       ; 5
(/ 20 4)       ; 5
```

### Boolean Operations

```racket
(and #t #f)    ; false
(or #t #f)     ; true
(not #t)       ; false
```

### Function Definition and Usage

```racket
(define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))

(factorial 5)  ; 120
```

## Next Steps

- Learn about [Built-in Functions](./built-in-functions.md)
- Explore [Examples](./examples.md) for more complex usage
- Check out the [Testing](./testing.md) guide for writing tests 