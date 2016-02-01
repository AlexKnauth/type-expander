#lang scribble/lp2
@(require "../lib/doc.rkt")
@doc-lib-setup

@title[#:style manual-doc-style]{Syntactic sugar for @racket[graph]: named
 constructors}

@(table-of-contents)

@section{Introduction}

We define a wrapper around the @tc[graph] macro, which 

@chunk[<signature>
       (define-graph/multi-ctor name:id
         ((~commit [node:id <field-signature> …])
          …)
         (~commit <mapping-declaration>)
         …)]

Where @tc[<field-signature>] is:

@chunk[<field-signature>
       (~describe "[field : type]"
                  [field:id c:colon field-type:expr])]

And @tc[<mapping-declaration>] is:

@chunk[<mapping-declaration>
       (~describe "[(mapping [param : type] …) : result . body]"
                  [(mapping:id [param:id :colon param-type:expr] …)
                   cm:colon result-node:id
                   . body])]

@chunk[<graph-multi-ctor>
       (define-syntax/parse <signature>
         (define-temp-ids "~a/wrapped" name)
         (define-temp-ids "~a/mapping" (node …))
         (define-temp-ids "~a/arg" (node …))
         (define-temp-ids "~a/function" (mapping …))
         (define-temp-ids "~a/hide" (node …))
         (define-temp-ids "~a/hide" (result-node …))
         (define/with-syntax ([(grouped-mapping
                                grouped-mapping/function
                                [(grouped-param . grouped-param-type) …]
                                grouped-result-node
                                grouped-body) …] …)
           (stx-map (λ (n)
                      (multiassoc-syntax n #'((result-node
                                               mapping
                                               mapping/function
                                               [(param . param-type) …]
                                               result-node
                                               body) …)))
                    #'(node …)))
         (define/with-syntax (mapping/grouped …)
           (stx-map (λ (mr) (cdr-assoc-syntax mr #'([node . node/mapping] …)))
                    #'(result-node …)))
         (define/with-syntax all-nodes #'(node …))
         (define/with-syntax (root-node . _) #'(result-node …))
         (define/with-syntax (root-mapping . _) #'(mapping …))
         
         ; TODO: we should order the graph's nodes so that the root is
         ; the first one! (or add a #:root)
         (define/with-syntax ((root-param …) . _) #'((param …) …))
         (define/with-syntax ((root-param-type …) . _) #'((param-type …) …))
         
         #`(debug
            (begin
              (define-graph name/wrapped
                #:definitions
                ((define-multi-id name
                   #:type-expander
                   (λ (stx)
                     (syntax-case stx ()
                       [(_ . rest) #'(name/wrapped . rest)]))
                   #:call (λ (stx)
                            (syntax-parse stx
                              [(_ . rest)
                               (syntax/loc stx
                                 (name/constructor . rest))]))
                   #:id (λ (stx)
                          (syntax/loc stx name/constructor)))
                 (define (name/constructor [root-param : root-param-type] …)
                   (name/wrapped #:root root-node (list 'root-mapping
                                                        root-param …)))
                 <define-mappings>)
                [node [field c field-type] …
                 ((node/mapping [node/arg : <node-arg-type>])
                  <mapping-body>)]
                …))))]

Where the type for the merged mapping is:

@chunk[<node-arg-type>
       (U (List 'grouped-mapping grouped-param-type …) …)]

@chunk[<define-mappings>
       (define (mapping/function node/hide … ; nodes
                                 result-node/hide ; self
                                 [param : param-type] …)
         : (name result-node)
         (let ([node node/hide] …)
           (let ([result-node result-node/hide])
             (? '<bdy>))))
       …]

@chunk[<bdy>
       (let ([node-names… node_]
             ;[mapping mapping/grouped] …
             [node-name_ node_])
         body)]

We then select in the grouped mapping which one to call.

@chunk[<mapping-body>
       (let ((a node/arg))
         (cond
           [(eq? (car a) 'grouped-mapping)
            (apply grouped-mapping/function
                   #,@#'(node …)
                   grouped-result-node
                   (cdr a))]
           …))]

TODO: At the call site, use a macro and annotate the function (given by its
name) with the right type, so that the user doesn't see all the types in the
(U …). 

@chunk[<test-graph-multi-ctor>
       (check-equal? 42 42)]

@section{Conclusion}

@chunk[<module-main>
       (module main typed/racket
         (require (for-syntax syntax/parse
                              racket/syntax
                              syntax/stx
                              "../lib/low-untyped.rkt"
                              "../lib/low/multiassoc-syntax.rkt")
                  "../lib/low.rkt"
                  "graph.lp2.rkt"
                  "get.lp2.rkt"
                  "../type-expander/type-expander.lp2.rkt"
                  "../type-expander/multi-id.lp2.rkt")
         (provide define-graph/multi-ctor)
         
         (require (for-syntax racket/pretty))
         (define-syntax (debug stx)
           (syntax-case stx ()
             [(_ body)
              ;; syntax->string
              (pretty-print (syntax->datum #'body))
              #'body]))
         
         <graph-multi-ctor>)]

@chunk[<module-test>
       (module* test typed/racket
         (require (submod "..")
                  typed/rackunit)
         
         <test-graph-multi-ctor>)]

@chunk[<*>
       (begin
         <module-main>
         
         (require 'main)
         (provide (all-from-out 'main))
         
         <module-test>)]