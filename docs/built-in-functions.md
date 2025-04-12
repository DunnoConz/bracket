# Built-in Functions

This guide covers all the built-in functions available in the Bracket language.

## Arithmetic Functions

### `+`
Adds numbers together.
```racket
(+ 1 2 3)      ; Returns 6
(+ 1.5 2.5)    ; Returns 4.0
```

### `-`
Subtracts numbers.
```racket
(- 10 5)       ; Returns 5
(- 10 5 2)     ; Returns 3
```

### `*`
Multiplies numbers.
```racket
(* 2 3 4)      ; Returns 24
(* 1.5 2)      ; Returns 3.0
```

### `/`
Divides numbers.
```racket
(/ 20 4)       ; Returns 5
(/ 10 3)       ; Returns 3.333...
```

## Comparison Functions

### `=`
Checks if numbers are equal.
```racket
(= 1 1)        ; Returns #t
(= 1 2)        ; Returns #f
```

### `>`
Checks if first number is greater than second.
```racket
(> 5 3)        ; Returns #t
(> 3 5)        ; Returns #f
```

### `<`
Checks if first number is less than second.
```racket
(< 3 5)        ; Returns #t
(< 5 3)        ; Returns #f
```

### `>=`
Checks if first number is greater than or equal to second.
```racket
(>= 5 5)       ; Returns #t
(>= 5 6)       ; Returns #f
```

### `<=`
Checks if first number is less than or equal to second.
```racket
(<= 5 5)       ; Returns #t
(<= 5 4)       ; Returns #f
```

## Boolean Functions

### `and`
Logical AND operation.
```racket
(and #t #t)    ; Returns #t
(and #t #f)    ; Returns #f
```

### `or`
Logical OR operation.
```racket
(or #t #f)     ; Returns #t
(or #f #f)     ; Returns #f
```

### `not`
Logical NOT operation.
```racket
(not #t)       ; Returns #f
(not #f)       ; Returns #t
```

## List Functions

### `list`
Creates a list.
```racket
(list 1 2 3)   ; Returns (1 2 3)
```

### `car`
Returns the first element of a list.
```racket
(car (list 1 2 3))  ; Returns 1
```

### `cdr`
Returns the rest of the list after the first element.
```racket
(cdr (list 1 2 3))  ; Returns (2 3)
```

### `cons`
Adds an element to the front of a list.
```racket
(cons 1 (list 2 3))  ; Returns (1 2 3)
```

## Testing Functions

### `test`
Defines a test case.
```racket
(test "Test name"
    assertion1
    assertion2)
```

### `assert-equal`
Checks if two expressions are equal.
```racket
(assert-equal (+ 1 2) 3)
```

## Special Forms

### `define`
Defines a variable or function.
```racket
(define x 10)
(define (square x) (* x x))
```

### `if`
Conditional expression.
```racket
(if condition
    then-expression
    else-expression)
```

### `lambda`
Creates an anonymous function.
```racket
(lambda (x) (* x x))
```

## Next Steps

- Review [Language Basics](./language-basics.md) for more context
- Check out [Examples](./examples.md) for usage examples
- Learn about [Testing](./testing.md) with these functions 