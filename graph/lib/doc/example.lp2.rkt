#lang scribble/lp2
@(require "../doc.rkt")
@doc-lib-setup

@title[#:style manual-doc-style]{Implementation of structures}

@;Racket is distributed with implementations of many SRFIs, most of
@;which can be implemented as libraries. To import the bindings of SRFI
@;@math{n}, use
@;
@;@racketblock[
@;(require @#,elem{@racketidfont{srfi/}@math{n}})
@;]

@section{A section}

In section @secref{sec:foo} we present, blah blah.

@subsection[#:tag "sec:foo"]{My subsection}

@$${\frac{2x}{x^2}}
@(colorize (filled-ellipse 30 15) "blue")
@; Line comment

Blah @math{n}, as described by M@._ Foo@.__
@racketblock[
 (require @#,elem{@racketidfont{srfi/}@math{n}})]

@CHUNK[<foo>
       (define (foo)
         (syntax-e #`#,"foo"))]

@(define to-insert 42)
@chunk[<*>
       ;(displayln #,to-insert) ;; Should work.
       (provide foo)
       <foo>

       (module* test racket
         (require (submod ".."))
         (require rackunit)
         (check-equal? (foo) "foo")
         
         (require (submod ".." doc)))]

It would be nice to be able to alter existing chunks, by inserting stuff later,
for example:

@chunk[<c>
       (define-syntax-rule (double x)
         (+ x x))]

But we would actually want:

@chunk[<redef-c>
       (define-syntax-rule (double x) -- should be greyed out
         (let ((x-cache x))
           (+ x-cache x-cache))) -- everything except the changed bits should
                                 -- be greyed out]