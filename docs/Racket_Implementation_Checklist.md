# Bracket: Racket Implementation Checklist

This document tracks the progress of implementing Racket features in the Bracket Luau project. Achieving a 1:1 implementation is a vast undertaking; this list focuses on major components, primarily targeting compatibility with `#lang racket/base`.

## Phase 1: Core Language & Data Structures

- [ ] **Pairs (Cons Cells):**
    - [ ] Implement mutable pairs (`cons`, `car`, `cdr`, `set-car!`, `set-cdr!`, `pair?`).
    - [ ] Refactor parser to generate pair-based lists.
    - [ ] Refactor evaluator to handle pair-based lists.
    - [ ] Refactor `StandardLibrary` functions for pair-based lists.
    - [ ] Implement `list?`, `null?`.
- [ ] **Syntax Objects:**
    - [ ] Define `syntax?` type/predicate.
    - [ ] Implement structure to store syntax, including source location and lexical context.
    - [ ] Refactor parser to output syntax objects instead of raw AST/data.
    - [ ] Refactor evaluator to consume syntax objects.
- [ ] **Numbers:**
    - [ ] Implement Racket's numeric tower (integers, rationals, floats, complex numbers).
    - [ ] Implement exact/inexact number concepts.
    - [ ] Update arithmetic operations (`+`, `-`, `*`, `/`, etc.) for the full tower.
    - [ ] Implement comparison predicates (`=`, `<`, `>`, `<=`, `>=`) for the full tower.
    - [ ] Implement type predicates (`number?`, `integer?`, `rational?`, `real?`, `complex?`, `exact?`, `inexact?`).
- [ ] **Other Core Data Types:**
    - [ ] Vectors (`vector`, `vector-ref`, `vector-set!`, `vector-length`, `vector?`).
    - [ ] Strings (ensure proper Unicode handling, immutability).
    - [ ] Characters (`char?`, `char=?`, etc.).
    - [ ] Booleans (`#t`, `#f`, `boolean?`).
    - [ ] Symbols (`symbol?`, `symbol->string`, `string->symbol`).
    - [ ] Keywords (`keyword?`).
    - [ ] `void` (`void`, `void?`).
    - [ ] `eof` object (`eof-object?`).
- [ ] **Reader/Parser Enhancements:**
    - [ ] Support `#lang racket/base` declaration.
    - [ ] Implement Racket comments (`;`, `#|...|#`, `#;`).
    - [ ] Implement quote forms (`'`, `(quote ...)`).
    - [ ] Implement quasiquote forms (``` ` ```, `(quasiquote ...)`).
    - [ ] Implement unquote forms (`,`, `(unquote ...)`).
    - [ ] Implement unquote-splicing forms (`,@`, `(unquote-splicing ...)`).
    - [ ] Implement datum labels (`#N=`, `#N#`).
    - [ ] Implement reader shorthand (`#t`, `#f`, `#\`, `#rx`, `#px`, `#hasheq`, etc.).

## Phase 2: Evaluation & Control Flow

- [ ] **Core Special Forms (Refined for Syntax Objects):**
    - [ ] `if`
    - [ ] `begin`
    - [ ] `define` (top-level, internal)
    - [ ] `set!`
    - [ ] `lambda`
    - [ ] `quote`
    - [ ] `quasiquote`, `unquote`, `unquote-splicing` (operating on syntax)
    - [ ] `let`, `let*`, `letrec` (syntax-aware)
    - [ ] `let-values`, `let*-values`, `letrec-values`
    - [ ] `let-syntax`, `letrec-syntax`
    - [ ] `define-values`, `define-syntaxes`
- [ ] **Continuations:**
    - [ ] `call-with-current-continuation` (`call/cc`).
    - [ ] `call-with-values`.
    - [ ] Dynamic Wind (`dynamic-wind`).
- [ ] **Exception Handling:**
    - [ ] `raise`.
    - [ ] `with-handlers`.
    - [ ] `error`.
    - [ ] Define core exception types (`exn`, `exn:fail`, etc.).
- [ ] **Tail Call Optimization (TCO):**
    - [ ] Verify TCO works correctly across function calls and special forms in Luau.

## Phase 3: Macros & Modules

- [ ] **Macro System:**
    - [ ] `syntax-rules` (complete implementation with `...`, literals).
    - [ ] `syntax-case` (core implementation).
    - [ ] Hygiene (ensure macros respect lexical context via syntax objects).
    - [ ] `identifier?`.
    - [ ] `syntax->datum`, `datum->syntax`.
    - [ ] `generate-temporaries`.
    - [ ] `free-identifier=?`, `bound-identifier=?`.
- [ ] **Module System:**
    - [ ] `module` form.
    - [ ] `require` form (basic, `only-in`, `except-in`, `rename-in`, `prefix-in`).
    - [ ] `provide` form (basic, `all-defined-out`, renaming, struct selectors).
    - [ ] Handle module phases (compile-time vs. run-time).
    - [ ] Implement module path resolution.
    - [ ] `namespace`.

## Phase 4: Standard Library (`#lang racket/base`)

*(This is a non-exhaustive list of key areas)*

- [ ] **Lists:** Full `racket/list` implementation.
- [ ] **Vectors:** Full `racket/vector` implementation.
- [ ] **Hashes:** Full `racket/hash` implementation (`make-hash`, `hash-ref`, `hash-set!`, etc.).
- [ ] **Strings:** Full `racket/string` implementation.
- [ ] **Regexp:** `racket/regexp` (`regexp`, `regexp-match`, etc.).
- [ ] **Matching:** `racket/match` (`match` form).
- [ ] **Contracts:**
    - [ ] Basic contracts (`->`, `any/c`, `integer?`, etc.).
    - [ ] Struct contracts.
    - [ ] Higher-order contracts.
    - [ ] `contract-out`.
- [ ] **Structs:**
    - [ ] `struct` form.
    - [ ] Predicates, accessors, mutators.
    - [ ] Transparent vs. opaque structs.
    - [ ] Prefab structs.
- [ ] **Parameters:** `make-parameter`, `parameterize`.
- [ ] **Input/Output:**
    - [ ] Ports (`port?`, `input-port?`, `output-port?`).
    - [ ] `open-input-file`, `open-output-file`.
    - [ ] `read`, `write`, `display`.
    - [ ] `current-input-port`, `current-output-port`, `current-error-port`.
    - [ ] `with-input-from-file`, `with-output-to-file`.
- [ ] **Filesystem:** `racket/file`, `racket/path`.
- [ ] **System:** `racket/system`.

## Phase 5: Roblox Integration & Beyond

- [ ] **FFI (Foreign Function Interface):**
    - [ ] Mechanism to call Roblox Luau functions/APIs from Bracket.
    - [ ] Mechanism to expose Bracket functions to Luau.
- [ ] **Concurrency:** Map Racket concurrency constructs (threads, channels) to Roblox mechanisms if feasible.
- [ ] **Performance Optimization:** Profile and optimize critical paths for Luau environment.
- [ ] **Tooling:** Debugger, profiler integration (if possible). 