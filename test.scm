;;;
;;; Test qq
;;;

(use gauche.test)

(test-start "qq")
(use qq)
(test-module 'qq)

(define-syntax test-qq
  (syntax-rules ()
    ((_ expr)
     (let ((q (quasiquotify 'expr)))
       (test* (format "~S => ~S" 'expr q)
              expr
              (eval q (interaction-environment)))))))

(test-qq (* 1 1))
(test-qq 'a)
(test-qq 1)
(test-qq #\a)
(test-qq "a")
(test-qq #f)
(test-qq (cons 1 2))
(test-qq (list 1 2))
(test-qq (cons* 1 2 3))
(test-qq (list* 1 2 3))
(test-qq (append '(1) '()))
(test-qq (append '(1) 2))
(test-qq (cons 'a 'b))
(test-qq (cons (* 1 1) (+ 1 1)))
(test-qq (list (cons 1 2)))
(test-qq (append (cons 1 2)))
(test-qq (list (list 1)))
(test-qq (append (list 1) (list 2)))
(test-qq (append (list 1) (* 3 2)))
(test-qq (list (list (list 1))))
(test-qq (list (append (list 1)) (append (list 2))))
(test-qq (list `(,(* 1 1))))
(test-qq (list (list `(,(* 1 1)))))
(test-qq (car (list 1)))
(test-qq (list (car (list 1 (car (list 1))))))
(test-qq (list 'unquote 2))
(test-qq (list 'unquote-splicing 1 2))
(test-qq (list 'unquote (list 1 2 (* 2 3))))

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
