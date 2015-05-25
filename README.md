# Gauche-qq

convert a list-constructing expression using `list`, `append`, `cons`,
`cons*`, or `list*` to a `quasiqoute` expression.

## Example

    (use qq)
    (quasiquotify '(append (list 1) (* 3 2)))
    ;; => `(1 ,@(* 3 2))
