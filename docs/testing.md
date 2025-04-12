# Testing in Bracket

Bracket comes with a built-in testing framework that makes it easy to write and run tests for your code.

## Basic Testing

### Writing Tests

Tests are written using the `test` special form:

```racket
(test "Test name"
    assertion1
    assertion2
    ...)
```

### Assertions

The main assertion function is `assert-equal`:

```racket
(assert-equal expression expected-value)
```

Example:
```racket
(test "Basic arithmetic"
    (assert-equal (+ 1 2) 3)
    (assert-equal (* 2 3) 6)
)
```

## Running Tests

### From Luau

To run tests from your Luau code:

```lua
local Bracket = require("path/to/Bracket")

local testCode = [[
(test "Basic arithmetic"
    (assert-equal (+ 1 2) 3)
    (assert-equal (* 2 3) 6)
)
]]

local success = Bracket.run_tests(testCode)
```

### Multiple Tests

You can run multiple tests in sequence:

```racket
(test "Addition"
    (assert-equal (+ 1 2) 3)
    (assert-equal (+ 1 2 3) 6)
)

(test "Multiplication"
    (assert-equal (* 2 3) 6)
    (assert-equal (* 2 3 4) 24)
)
```

## Testing Functions

### Testing Function Definitions

You can test your custom functions:

```racket
(define (square x) (* x x))

(test "Square function"
    (assert-equal (square 2) 4)
    (assert-equal (square 3) 9)
)
```

### Testing Conditional Logic

Test if-else expressions:

```racket
(define (absolute x)
    (if (> x 0)
        x
        (- x)))

(test "Absolute value"
    (assert-equal (absolute 5) 5)
    (assert-equal (absolute -5) 5)
)
```

## Best Practices

1. **Descriptive Test Names**: Use clear, descriptive names for your tests
2. **One Assertion per Concept**: Each assertion should test one specific concept
3. **Group Related Tests**: Keep related tests together
4. **Test Edge Cases**: Don't forget to test edge cases and error conditions

## Example Test Suite

Here's a complete example of a test suite:

```racket
;; Arithmetic tests
(test "Basic arithmetic"
    (assert-equal (+ 1 2) 3)
    (assert-equal (- 5 2) 3)
    (assert-equal (* 2 3) 6)
    (assert-equal (/ 6 2) 3)
)

;; Boolean tests
(test "Boolean operations"
    (assert-equal (and #t #t) #t)
    (assert-equal (and #t #f) #f)
    (assert-equal (or #t #f) #t)
    (assert-equal (not #t) #f)
)

;; Function tests
(define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))

(test "Factorial function"
    (assert-equal (factorial 0) 1)
    (assert-equal (factorial 1) 1)
    (assert-equal (factorial 5) 120)
)
```

## Next Steps

- Review [Language Basics](./language-basics.md) for more context
- Check out [Examples](./examples.md) for more testing examples
- Learn about [Built-in Functions](./built-in-functions.md) you can use in tests 