# Bracket

Bracket is a minimal, elegant Lisp dialect heavily inspired by Racket, designed for embedding in Luau environments. It brings the power and expressiveness of functional programming to your Luau projects with a clean, Scheme-like syntax and semantics.

## Philosophy

Bracket embraces the core philosophy of Lisp:

- **Code as Data**: Programs are represented as data structures, making metaprogramming natural.
- **Simplicity**: A small set of powerful primitives that compose to build complex behaviors.
- **Functional Programming**: Emphasis on pure functions, immutability, and higher-order functions.
- **Extensibility**: The language is designed to be extended by users through macros and abstractions.

Like Racket, Bracket aims to be a "batteries-included" dialect that balances a minimal core with practical utilities for real-world programming tasks.

## Features

- **Full Lexical Scoping**: Variables are resolved in the environment where they're defined, enabling proper closures.
- **First-class Functions**: Functions are values that can be passed to and returned from other functions.
- **Rich Data Structures**: Support for lists, pairs, symbols, and more.
- **Tail Call Optimization**: Efficient recursion without stack overflow.
- **Error Handling**: Comprehensive error reporting for debugging.
- **Macro System**: Code transformation capabilities for extending the language.
- **Seamless Luau Integration**: Easy interoperability with the host Luau environment.

## Examples

### Simple Expressions

```scheme
(+ 2 3)  ; => 5

(define x 10)
x  ; => 10

(if (> 5 3)
    "greater"
    "lesser")  ; => "greater"
```

### Functions and Closures

```scheme
(define square 
  (lambda (x) (* x x)))
  
(square 4)  ; => 16

; Creating closures
(define (make-adder n)
  (lambda (x) (+ x n)))
  
(define add5 (make-adder 5))
(add5 10)  ; => 15
```

### List Processing

```scheme
(define my-list (list 1 2 3 4 5))
(car my-list)  ; => 1
(car (cdr my-list))  ; => 2

; Higher-order functions
(define (map func items)
  (if (null? items)
      '()
      (cons (func (car items))
            (map func (cdr items)))))
            
(map square (list 1 2 3 4 5))  ; => (1 4 9 16 25)
```

### Recursion

```scheme
(define (factorial n)
  (if (= n 0)
      1
      (* n (factorial (- n 1)))))
      
(factorial 5)  ; => 120
```

## Getting Started

To use Bracket in your Luau project:

```lua
local Bracket = require("path/to/bracket")

-- Evaluate a Bracket expression
local result = Bracket.evaluate("(+ 2 3)")
print(result)  -- => 5

-- Run a multi-line program
local program = [[
  (define (fibonacci n)
    (if (< n 2)
        n
        (+ (fibonacci (- n 1))
           (fibonacci (- n 2)))))
  (fibonacci 10)
]]

local result = Bracket.evaluate(program)
print(result)  -- => 55
```

## Why Bracket?

Bracket brings the expressive power of Lisp to Luau, enabling:

- **More expressive code**: Do more with less code through functional paradigms
- **Dynamic language features**: Create domain-specific languages within your application
- **Educational value**: Learn functional programming concepts in a simple environment
- **Metaprogramming**: Extend the language to suit your specific needs

Whether you're building games, simulations, or tools, Bracket can enhance your Luau projects with the elegant simplicity of Lisp and the pedagogical focus of Racket.

## Documentation

The documentation for Bracket is organized into several sections:

- **[Getting Started Guide](docs/getting-started.md)**: A tutorial introduction to Bracket
- **[Language Reference](docs/reference.md)**: Complete documentation of Bracket's syntax and semantics
- **[Standard Library](docs/stdlib.md)**: Documentation of built-in functions and utilities
- **[Interoperability](docs/interop.md)**: How to interface between Bracket and Luau
- **[Examples](examples/)**: A collection of example programs demonstrating Bracket's features

## Community Guidelines

We welcome contributions to Bracket! Here's how you can participate:

### Contributing Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Reporting Issues

- Use the issue tracker to report bugs
- Include detailed steps to reproduce the issue
- Mention your environment (Luau version, platform, etc.)

### Style Guidelines

- Follow the existing code style
- Write tests for new features
- Document your code with comments
- Update documentation for user-facing changes

### Community Behavior

- Be respectful and inclusive in all interactions
- Provide constructive feedback
- Help others learn and grow

## License

Bracket is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 DunnoConz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
``` 