;;;
;;; Copyright (c) 2015 OOHASHI Daichi,
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;;
;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;;
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;;
;;; 3. Neither the name of the authors nor the names of its contributors
;;;    may be used to endorse or promote products derived from this
;;;    software without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;;; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;;

(define-module qq
  (export quasiquotify)
  (use srfi-1)
  (use util.match))

(select-module qq)

(define (quasiquotify xs)
  (define (quote? x)
    (memq x '(quote quasiquote)))
  (define self-evaluated?
    (any-pred boolean? number? string? char?))
  (define (const-value xs)
    (match xs
      [(or ((? quote?) v)
           (? self-evaluated? v))
       v]
      [_ #f]))
  (define (qq? x)
    (memq x '(quasiquote unquote unquote-splicing)))
  (define (wrap-qq xs)
    (match xs
      [((? qq? q) . ys)
       ;; (qq ys ...) -> `(,'qq ys ...)
       `(,'quasiquote ((,'unquote ',q) ,@ys))]
      [ys
       ;; ys -> `ys
       `(,'quasiquote ,ys)]))
  (match xs
    [((? quote?) _) xs]
    [('list . ys)
     (wrap-qq
      (map (lambda (y)
             (let ((qy (quasiquotify y)))
               (cond ((const-value qy) => values)
                     (else
                      (list 'unquote qy)))))
           ys))]
    [('append . ys)
     (wrap-qq
      (append-map (lambda (y)
                    (let ((qy (quasiquotify y)))
                      (cond ((const-value qy) => values)
                            (else
                             (list (list 'unquote-splicing qy))))))
                  ys))]
    [(or (and ('cons _ _)
              (_ . ys))
         ((or 'cons* 'list*) . ys))
     (wrap-qq
      (fold (lambda (y proc unquote-sym zs)
              (let ((qy (quasiquotify y)))
                (cond ((const-value qy)
                       => (cut proc <> zs))
                      (else
                       (cons (list unquote-sym qy) zs)))))
            '()
            (reverse ys)
            (cons (^ (x _) x) (circular-list cons))
            (cons 'unquote-splicing (circular-list 'unquote))))]
    [(ys ...)
     (map quasiquotify ys)]
    [ys ys]))
