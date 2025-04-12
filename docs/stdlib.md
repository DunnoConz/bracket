# Bracket Standard Library

This document provides a reference for the built-in functions and utilities available in the Bracket standard library.

## Arithmetic Functions

| Function | Description | Example |
|----------|-------------|---------|
| `+` | Addition | `(+ 1 2 3)` → `6` |
| `-` | Subtraction | `(- 10 5)` → `5` |
| `*` | Multiplication | `(* 2 3 4)` → `24` |
| `/` | Division | `(/ 10 2)` → `5` |
| `remainder` | Remainder (modulo) | `(remainder 10 3)` → `1` |
| `quotient` | Integer division | `(quotient 10 3)` → `3` |
| `abs` | Absolute value | `(abs -5)` → `5` |
| `expt` | Exponentiation | `(expt 2 3)` → `8` |
| `sqrt` | Square root | `(sqrt 16)` → `4` |
| `max` | Maximum value | `(max 1 3 2)` → `3` |
| `min` | Minimum value | `(min 1 3 2)` → `1` |

## Comparison Functions

| Function | Description | Example |
|----------|-------------|---------|
| `=` | Numeric equality | `(= 1 1)` → `#t` |
| `<` | Less than | `(< 1 2)` → `#t` |
| `>` | Greater than | `(> 2 1)` → `#t` |
| `<=` | Less than or equal | `(<= 1 1)` → `#t` |
| `>=` | Greater than or equal | `(>= 2 1)` → `#t` |
| `eq?` | Object identity | `(eq? 'a 'a)` → `#t` |
| `equal?` | Deep equality | `(equal? '(1 2) '(1 2))` → `#t` |

## Logical Functions

| Function | Description | Example |
|----------|-------------|---------|
| `and` | Logical AND | `(and #t #t)` → `#t` |
| `or` | Logical OR | `(or #f #t)` → `#t` |
| `not` | Logical NOT | `(not #t)` → `#f` |

## Type Predicates

| Function | Description | Example |
|----------|-------------|---------|
| `boolean?` | Is it a boolean? | `(boolean? #t)` → `#t` |
| `number?` | Is it a number? | `(number? 42)` → `#t` |
| `string?` | Is it a string? | `(string? "hello")` → `#t` |
| `symbol?` | Is it a symbol? | `(symbol? 'xyz)` → `#t` |
| `list?` | Is it a proper list? | `(list? '(1 2 3))` → `#t` |
| `pair?` | Is it a pair? | `(pair? (cons 1 2))` → `#t` |
| `null?` | Is it the empty list? | `(null? '())` → `#t` |
| `procedure?` | Is it a procedure? | `(procedure? +)` → `#t` |

## List Functions

| Function | Description | Example |
|----------|-------------|---------|
| `cons` | Construct a pair | `(cons 1 '(2 3))` → `(1 2 3)` |
| `car` | First element of pair | `(car '(1 2 3))` → `1` |
| `cdr` | Rest of pair | `(cdr '(1 2 3))` → `(2 3)` |
| `list` | Create a list | `(list 1 2 3)` → `(1 2 3)` |
| `length` | Length of list | `(length '(1 2 3))` → `3` |
| `append` | Concatenate lists | `(append '(1 2) '(3 4))` → `(1 2 3 4)` |
| `reverse` | Reverse a list | `(reverse '(1 2 3))` → `(3 2 1)` |
| `list-ref` | Get element by index | `(list-ref '(a b c) 1)` → `b` |
| `map` | Apply function to each element | `(map (lambda (x) (* x 2)) '(1 2 3))` → `(2 4 6)` |
| `filter` | Select elements that satisfy predicate | `(filter (lambda (x) (> x 2)) '(1 2 3 4))` → `(3 4)` |
| `fold` | Accumulate values (reduce) | `(fold + 0 '(1 2 3))` → `6` |

## String Functions

| Function | Description | Example |
|----------|-------------|---------|
| `string-append` | Concatenate strings | `(string-append "hello" " " "world")` → `"hello world"` |
| `string-length` | Length of string | `(string-length "hello")` → `5` |
| `substring` | Extract substring | `(substring "hello" 1 3)` → `"el"` |
| `string->number` | Convert string to number | `(string->number "42")` → `42` |
| `number->string` | Convert number to string | `(number->string 42)` → `"42"` |
| `string=?` | String equality | `(string=? "hello" "hello")` → `#t` |
| `string<?` | String less than | `(string<? "apple" "banana")` → `#t` |
| `string-split` | Split string by delimiter | `(string-split "a,b,c" ",")` → `("a" "b" "c")` |
| `string-join` | Join strings with delimiter | `(string-join '("a" "b" "c") ",")` → `"a,b,c"` |

## I/O Functions

| Function | Description | Example |
|----------|-------------|---------|
| `display` | Output value | `(display "Hello")` |
| `newline` | Output newline | `(newline)` |
| `read` | Read S-expression | `(read)` |
| `read-line` | Read line of text | `(read-line)` |
| `print` | Display value with newline | `(print "Hello")` |
| `load` | Load and evaluate file | `(load "file.scm")` |

## Environment Functions

| Function | Description | Example |
|----------|-------------|---------|
| `eval` | Evaluate expression | `(eval '(+ 1 2))` → `3` |
| `apply` | Apply procedure to arguments | `(apply + '(1 2 3))` → `6` |
| `error` | Signal an error | `(error "Something went wrong")` |
| `gensym` | Generate unique symbol | `(gensym)` → `g1234` |

## Mathematical Functions

| Function | Description | Example |
|----------|-------------|---------|
| `sin` | Sine | `(sin 0)` → `0` |
| `cos` | Cosine | `(cos 0)` → `1` |
| `tan` | Tangent | `(tan 0)` → `0` |
| `asin` | Arc sine | `(asin 0)` → `0` |
| `acos` | Arc cosine | `(acos 1)` → `0` |
| `atan` | Arc tangent | `(atan 0)` → `0` |
| `exp` | Exponential | `(exp 1)` → `2.718...` |
| `log` | Natural logarithm | `(log 1)` → `0` |
| `floor` | Round down | `(floor 3.7)` → `3` |
| `ceiling` | Round up | `(ceiling 3.2)` → `4` |
| `round` | Round to nearest | `(round 3.5)` → `4` |
| `random` | Random number | `(random 10)` → random number between 0 and 9 |

## Symbol Functions

| Function | Description | Example |
|----------|-------------|---------|
| `symbol->string` | Convert symbol to string | `(symbol->string 'abc)` → `"abc"` |
| `string->symbol` | Convert string to symbol | `(string->symbol "abc")` → `abc` |

## Vector Functions

| Function | Description | Example |
|----------|-------------|---------|
| `vector` | Create a vector | `(vector 1 2 3)` → `#(1 2 3)` |
| `make-vector` | Create vector of given size | `(make-vector 3 0)` → `#(0 0 0)` |
| `vector-length` | Length of vector | `(vector-length #(1 2 3))` → `3` |
| `vector-ref` | Get element by index | `(vector-ref #(a b c) 1)` → `b` |
| `vector-set!` | Set element by index | `(vector-set! v 1 'x)` |

## Hash Table Functions

| Function | Description | Example |
|----------|-------------|---------|
| `make-hash` | Create empty hash table | `(make-hash)` |
| `hash-set!` | Set key-value pair | `(hash-set! h 'key 'value)` |
| `hash-ref` | Get value by key | `(hash-ref h 'key)` → `value` |
| `hash-has-key?` | Check if key exists | `(hash-has-key? h 'key)` → `#t` |
| `hash-remove!` | Remove key | `(hash-remove! h 'key)` |
| `hash-keys` | Get list of keys | `(hash-keys h)` → `(key1 key2 ...)` |

## Control Flow

| Function | Description | Example |
|----------|-------------|---------|
| `when` | Conditional execution (true case only) | `(when (> x 0) (display "positive"))` |
| `unless` | Conditional execution (false case only) | `(unless (> x 0) (display "non-positive"))` |
| `while` | Iteration while condition is true | `(while (> x 0) (set! x (- x 1)))` |

## Additional Utilities

| Function | Description | Example |
|----------|-------------|---------|
| `identity` | Return the argument unchanged | `(identity 42)` → `42` |
| `compose` | Function composition | `((compose square abs) -3)` → `9` |
| `curry` | Partial application | `((curry + 1) 2)` → `3` |
| `delay` | Create a promise | `(delay (+ 1 2))` |
| `force` | Force evaluation of a promise | `(force p)` → `3` |

Note: The actual availability of these functions may vary depending on your specific Bracket implementation. Some functions might need to be loaded from additional libraries. 