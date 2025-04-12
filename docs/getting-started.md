# Getting Started with Bracket

This guide will walk you through the basics of using Bracket in your Luau projects.

## Installation

To install Bracket, simply copy the Bracket source files to your project:

```bash
# Clone the repository
git clone https://github.com/your-username/bracket.git

# Or simply download and extract the files to your project directory
```

## Basic Usage

### Requiring Bracket

```lua
-- Require the Bracket module
local Bracket = require("path/to/bracket")
```

### Evaluating Expressions

The most basic way to use Bracket is to evaluate simple expressions:

```lua
-- Evaluate a simple arithmetic expression
local result = Bracket.evaluate("(+ 2 3)")
print(result) -- Outputs: 5

-- String operations
local greeting = Bracket.evaluate("(string-append \"Hello, \" \"world!\")")
print(greeting) -- Outputs: "Hello, world!"
```

### Defining Variables

You can define variables that persist between evaluations:

```lua
-- Define a variable
Bracket.evaluate("(define x 10)")

-- Use the variable
local result = Bracket.evaluate("(* x 2)")
print(result) -- Outputs: 20
```

## Writing Bracket Programs

### Defining Functions

Functions are defined using the `define` form, either with the shorthand syntax or using `lambda`:

```lua
-- Shorthand syntax
Bracket.evaluate([[
  (define (square x)
    (* x x))
]])

-- Lambda syntax
Bracket.evaluate([[
  (define square
    (lambda (x) (* x x)))
]])

-- Use the function
local result = Bracket.evaluate("(square 4)")
print(result) -- Outputs: 16
```

### Control Structures

Bracket provides several control structures:

```lua
-- Conditionals with if
local max_value = Bracket.evaluate([[
  (define (max a b)
    (if (> a b)
        a
        b))
  (max 5 10)
]])
print(max_value) -- Outputs: 10

-- Conditionals with cond
local abs_value = Bracket.evaluate([[
  (define (abs x)
    (cond
      ((> x 0) x)
      ((= x 0) 0)
      (else (- x))))
  (abs -5)
]])
print(abs_value) -- Outputs: 5
```

### Lists and Recursion

Lists are fundamental data structures in Bracket:

```lua
-- Create a list
Bracket.evaluate("(define my-list (list 1 2 3 4 5))")

-- Define a recursive function to sum a list
Bracket.evaluate([[
  (define (sum-list lst)
    (if (null? lst)
        0
        (+ (car lst) (sum-list (cdr lst)))))
]])

-- Calculate the sum
local sum = Bracket.evaluate("(sum-list my-list)")
print(sum) -- Outputs: 15
```

## Interoperating with Luau

Bracket can be easily integrated with your Luau code:

```lua
-- Define a function in Bracket
Bracket.evaluate([[
  (define (fibonacci n)
    (if (< n 2)
        n
        (+ (fibonacci (- n 1))
           (fibonacci (- n 2)))))
]])

-- Use the function from Luau
for i = 0, 10 do
    local fib = Bracket.evaluate("(fibonacci " .. i .. ")")
    print("Fibonacci " .. i .. " = " .. fib)
end
```

## Next Steps

Now that you're familiar with the basics, you can:

- Explore the [Language Reference](reference.md) for more details on Bracket's syntax and features
- Check out the [Standard Library](stdlib.md) to see the built-in functions available
- Look at the [Examples](../examples/) directory for more complex usage patterns
- Learn about advanced [Interoperability](interop.md) between Bracket and Luau

Happy coding with Bracket! 