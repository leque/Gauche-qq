# Gauche-qq [![Build Status](https://travis-ci.org/leque/Gauche-qq.svg?branch=master)](https://travis-ci.org/leque/Gauche-qq)

convert a list-constructing expression using `list`, `append`, `cons`,
`cons*`, or `list*` to a `quasiqoute` expression.

## Requirement

- [Gauche](http://practical-scheme.net/gauche/) 0.9.4 or later

## Example

    (use qq)
    (quasiquotify '(append (list 1) (* 3 2)))
    ;; => `(1 ,@(* 3 2))
