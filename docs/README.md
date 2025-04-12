# Bracket Language Documentation

Welcome to the Bracket language documentation! Bracket is a Language Oriented Programming (LOP) solution implemented in Luau, designed to provide a domain-specific language for expressive and powerful programming.

## What is Language Oriented Programming?

Language Oriented Programming is a programming paradigm where:
- The solution is expressed in a language specifically designed for the problem domain
- The language provides abstractions that match the problem's concepts
- The syntax and semantics are tailored to the domain's needs
- The language can be extended and adapted as requirements evolve

Bracket embodies these principles by providing:
- A Lisp-like syntax that's both powerful and flexible
- Domain-specific constructs for testing and evaluation
- Extensible function definitions and custom operators
- A clean separation between the language and its implementation

## Table of Contents

1. [Getting Started](./getting-started.md)
2. [Language Basics](./language-basics.md)
3. [Built-in Functions](./built-in-functions.md)
4. [Testing](./testing.md)
5. [Examples](./examples.md)

## Quick Start

To use Bracket in your project:

```lua
local Bracket = require("path/to/Bracket")

-- Evaluate a simple expression
local result = Bracket.evaluate("(+ 1 2 3)")  -- Returns 6

-- Run tests
local testResult = Bracket.run_tests('(test "Addition" (assert-equal (+ 1 2) 3))')
```

## Features

- Lisp-like syntax with parentheses for clear expression structure
- First-class functions and higher-order programming
- Built-in testing framework as a language feature
- Simple and consistent API for language integration
- Extensible through custom function definitions
- Domain-specific constructs for testing and evaluation

## Contributing

We welcome contributions to Bracket! Please see our [Contributing Guide](./contributing.md) for more information. 