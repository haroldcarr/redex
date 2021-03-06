#lang racket/base

(require redex/benchmark
         "util.rkt"
         redex/reduction-semantics)
(provide (all-defined-out))

(define the-error "the classic polymorphic let + references bug")

(define-rewrite bug2
  ([(where N_2 (subst N x v))
    (where y ,(variable-not-in (term N_2) 'l))
    (tc-down Γ ((λ y N_2) v) κ σ_2)
    ------------------------------------------ "let poly"
    (tc-down Γ (let ([x v]) N) κ σ_2)]
  
   [(where #t (not-v? M))
    (tc-down Γ ((λ x N) M) κ σ_2)
    --------------------------------- "let mono"
    (tc-down Γ (let ([x M]) N) κ σ_2)])
  ==>
  ([(where N_2 (subst N x M))
    (where y ,(variable-not-in (term N_2) 'l))
    (tc-down Γ ((λ y N_2) M) κ σ_2)
    ------------------------------------------ "let"
    (tc-down Γ (let ([x M]) N) κ σ_2)])
  #:context (define-judgment-form)
  #:once-only)

(include/rewrite (lib "redex/examples/let-poly.rkt") let-poly bug2)

(include/rewrite "generators.rkt" generators bug-mod-rw)

(define small-counter-example '(let ([a (new nil)])
                                 ((λ b
                                    ((hd (get a)) 0))
                                  ((set a) ((cons 0) nil)))))

(test small-counter-example)
