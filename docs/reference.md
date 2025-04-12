# Bracket Language Reference

This document provides a comprehensive reference to the Bracket language syntax and core features.

## Syntax

### S-Expressions

Bracket uses S-expressions (Symbolic Expressions) as the primary syntax:

```scheme
(operator operand1 operand2 ...)
```

Examples:
```scheme
(+ 1 2 3)         ; Addition: 1 + 2 + 3
(* 2 3 4)         ; Multiplication: 2 * 3 * 4
(< 5 10)          ; Comparison: 5 < 10
```

### Data Types

Bracket supports the following basic data types:

| Type | Examples | Description |
|------|----------|-------------|
| Numbers | `1`, `3.14`, `-42` | Integer and floating-point numbers |
| Strings | `"hello"`, `"world"` | Text enclosed in double quotes |
| Booleans | `#t`, `#f` | Truth values (true and false) |
| Symbols | `x`, `+`, `my-var` | Identifiers |
| Lists | `(1 2 3)`, `()` | Ordered collections |
| Pairs | `(cons 1 2)` | Basic building blocks for lists |
| Procedures | `(lambda (x) (* x x))` | Function values |
| Nil | `'()`, `nil` | Empty list or null value |

### Quoting

Quoting prevents evaluation of an expression:

```scheme
(quote (1 2 3))    ; Creates a list without evaluating it
'(1 2 3)           ; Shorthand for quote
```

### Comments

Comments begin with a semicolon and continue to the end of the line:

```scheme
; This is a comment
(+ 1 2) ; Adds 1 and 2
```

## Core Forms

### define

Define variables and functions:

```scheme
; Variable definition
(define x 10)

; Function definition (shorthand)
(define (square x)
  (* x x))

; Function definition (lambda)
(define factorial
  (lambda (n)
    (if (= n 0)
        1
        (* n (factorial (- n 1))))))
```

### lambda

Create anonymous functions:

```scheme
; Anonymous function that adds its two arguments
(lambda (x y) (+ x y))

; Create and immediately call a function
((lambda (x) (* x x)) 5)  ; Returns 25
```

### if

Conditional expression:

```scheme
(if condition
    true-expression
    false-expression)
```

Example:
```scheme
(if (> x 0)
    "positive"
    (if (< x 0)
        "negative"
        "zero"))
```

### cond

Multi-branch conditional:

```scheme
(cond
  (test-1 result-1)
  (test-2 result-2)
  ...
  (else default-result))
```

Example:
```scheme
(cond
  ((> x 0) "positive")
  ((< x 0) "negative")
  (else "zero"))
```

### let

Local variable bindings:

```scheme
(let ((var1 value1)
      (var2 value2)
      ...)
  body-expression)
```

Example:
```scheme
(let ((x 5)
      (y 10))
  (* x y))  ; Returns 50
```

### begin

Evaluate expressions in sequence:

```scheme
(begin
  expression-1
  expression-2
  ...
  expression-n)
```

Example:
```scheme
(begin
  (display "Computing...")
  (+ 2 3))  ; Returns 5, after displaying "Computing..."
```

### set!

Mutate a variable:

```scheme
(set! variable-name new-value)
```

Example:
```scheme
(define counter 0)
(set! counter (+ counter 1))  ; Increments counter
```

## Core Procedures

### Arithmetic Operators

```scheme
(+ a b ...)        ; Addition
(- a b ...)        ; Subtraction
(* a b ...)        ; Multiplication
(/ a b ...)        ; Division
(remainder a b)    ; Remainder (modulo)
```

### Comparison Operators

```scheme
(= a b)            ; Equal
(< a b)            ; Less than
(> a b)            ; Greater than
(<= a b)           ; Less than or equal
(>= a b)           ; Greater than or equal
```

### Logical Operators

```scheme
(and expr ...)     ; Logical AND
(or expr ...)      ; Logical OR
(not expr)         ; Logical NOT
```

### List Operations

```scheme
(cons a b)         ; Create a pair
(car p)            ; First element of pair
(cdr p)            ; Second element of pair
(list a b ...)     ; Create a list
(null? l)          ; Check if list is empty
(length l)         ; Length of list
```

### Type Predicates

```scheme
(number? x)        ; Is x a number?
(string? x)        ; Is x a string?
(symbol? x)        ; Is x a symbol?
(pair? x)          ; Is x a pair?
(procedure? x)     ; Is x a procedure?
```

### String Operations

```scheme
(string-append s1 s2 ...)   ; Concatenate strings
(string-length s)           ; Length of string
(substring s start end)     ; Extract substring
```

## Advanced Features

### Macros

Bracket supports a macro system for code transformation:

```scheme
(define-macro (my-when condition body)
  (list 'if condition body nil))

(my-when (> 5 3) "true-case")  ; Expands to (if (> 5 3) "true-case" nil)
```

### Tail Call Optimization

Bracket implements proper tail call optimization, allowing for efficient recursion:

```scheme
(define (tail-factorial n acc)
  (if (= n 0)
      acc
      (tail-factorial (- n 1) (* n acc))))
```

## Error Handling

Bracket provides mechanisms for handling errors:

```scheme
(try
  expression
  (catch (error-type)
    handler-expression))
```

## Interoperability with Luau

Bracket provides mechanisms for calling Luau functions and accessing Luau values. See the [Interoperability](interop.md) guide for details. 