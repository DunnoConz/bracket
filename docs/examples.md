# Bracket Examples

This guide provides comprehensive examples of Bracket code, from basic to advanced usage.

## Basic Examples

### Arithmetic Operations

```racket
;; Basic arithmetic
(+ 1 2 3)      ; 6
(- 10 5)       ; 5
(* 2 3 4)      ; 24
(/ 20 4)       ; 5

;; Nested operations
(+ 1 (* 2 3))  ; 7
(* 2 (+ 3 4))  ; 14
```

### Boolean Operations

```racket
;; Basic boolean operations
(and #t #t)    ; #t
(and #t #f)    ; #f
(or #t #f)     ; #t
(not #t)       ; #f

;; Complex boolean expressions
(and (> 5 3) (< 2 4))  ; #t
(or (= 1 2) (= 2 2))   ; #t
```

## Function Examples

### Basic Functions

```racket
;; Square function
(define (square x) (* x x))
(square 5)     ; 25

;; Cube function
(define (cube x) (* x x x))
(cube 3)       ; 27
```

### Recursive Functions

```racket
;; Factorial
(define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))

(factorial 5)  ; 120

;; Fibonacci
(define (fib n)
    (if (< n 2)
        n
        (+ (fib (- n 1))
           (fib (- n 2)))))

(fib 6)        ; 8
```

### Higher-Order Functions

```racket
;; Map function
(define (map f lst)
    (if (null? lst)
        '()
        (cons (f (car lst))
              (map f (cdr lst)))))

(map square (list 1 2 3 4))  ; (1 4 9 16)

;; Filter function
(define (filter pred lst)
    (if (null? lst)
        '()
        (if (pred (car lst))
            (cons (car lst)
                  (filter pred (cdr lst)))
            (filter pred (cdr lst)))))

(filter (lambda (x) (> x 2)) (list 1 2 3 4))  ; (3 4)
```

## List Operations

```racket
;; Basic list operations
(list 1 2 3)           ; (1 2 3)
(car (list 1 2 3))     ; 1
(cdr (list 1 2 3))     ; (2 3)
(cons 1 (list 2 3))    ; (1 2 3)

;; List manipulation
(define (reverse lst)
    (if (null? lst)
        '()
        (append (reverse (cdr lst))
                (list (car lst)))))

(reverse (list 1 2 3))  ; (3 2 1)
```

## Testing Examples

```racket
;; Testing arithmetic
(test "Basic arithmetic"
    (assert-equal (+ 1 2) 3)
    (assert-equal (* 2 3) 6)
)

;; Testing functions
(define (square x) (* x x))

(test "Square function"
    (assert-equal (square 2) 4)
    (assert-equal (square 3) 9)
)

;; Testing recursive functions
(define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))

(test "Factorial"
    (assert-equal (factorial 0) 1)
    (assert-equal (factorial 1) 1)
    (assert-equal (factorial 5) 120)
)
```

## Complete Program Example

Here's a complete example that combines multiple concepts:

```racket
;; A program to calculate the sum of squares of even numbers in a list

(define (even? n)
    (= (mod n 2) 0))

(define (square x)
    (* x x))

(define (sum-of-squares-of-evens lst)
    (if (null? lst)
        0
        (if (even? (car lst))
            (+ (square (car lst))
               (sum-of-squares-of-evens (cdr lst)))
            (sum-of-squares-of-evens (cdr lst)))))

;; Test the program
(test "Sum of squares of evens"
    (assert-equal (sum-of-squares-of-evens (list 1 2 3 4)) 20)
    (assert-equal (sum-of-squares-of-evens (list 2 4 6)) 56)
)

;; Run the program
(sum-of-squares-of-evens (list 1 2 3 4 5 6))  ; Returns 56
```

## Next Steps

- Review [Language Basics](./language-basics.md) for more context
- Learn about [Built-in Functions](./built-in-functions.md)
- Check out the [Testing](./testing.md) guide for more examples 