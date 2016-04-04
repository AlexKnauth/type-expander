#lang typed/racket

(provide in)

(require racket/stxparam)

(define-syntax-parameter in
  (λ (stx)
    (raise-syntax-error
     'in
     "used out of context. It can only be used in some forms."
     stx)))