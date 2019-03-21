#lang scribble/manual

@(require racket/sandbox
          scribble/example
          (for-label racket))

@(define kernel-core-evaluator
  (parameterize ([sandbox-output 'string]
                 [sandbox-error-output 'string])
    (make-evaluator 'kernel/core)))

@title{Kernel User Guide}

@section{Introduction}

@hyperlink["https://web.wpi.edu/Pubs/ETD/Available/etd-090110-124904/unrestricted/jshutt.pdf"]{Kernel} is a re-design of the Scheme dialect of Lisp, wherein all objects in the language are first-class. There are a handful of built-in procedures and a single special form @code{$vau}, which suffice to define the rest of the language features. For background on Kernel, see the above dissertation and the @hyperlink["ftp://ftp.cs.wpi.edu/pub/techreports/pdf/05-07.pdf"]{language reference}.

The Kernel design goals are summarized and rationalized in the linked documents, but for our purposes, it is worth explaining a little more about why Kernel is the best language to translate into hardware. Throughout the documentation, the property of smoothness is discussed as a key factor in driving design decisions. Think of smoothness as orthoganality combined with the principle of least suprise. A language where all objects are treated the same--procedures, data, special forms, etc.--is smooth.

This is especially important when we must translate programs in the language to hardware. Programs in the high-level language that our users write must be translated to programs in the low-level hardware language. Every built-in feature of the high-level language must be implemented in the low-level hardware layer. By striving to eliminate unnecessary language features and boil the high-language down to its essence, we are distilling the concepts that we must translate into hardware.

Because the Kernel design goals explicitly seek out smoothness, Kernel is the ideal language for high-level synthesis. There is a practical reason and a philosophical reason. Practically speaking, there are about a half dozen core language features that we have to implement in hardware, and the rest of the language is defined in terms of them. Philosophically, this means Kernel has damn near captured the spirit of computation in its semantics, and by generating machines to execute Kernel programs, we are giving that spirit form.

@section{Core}

The Kernel core consists of the built-in language features that we assume when we write programs in Kernel. For now, the core is implemented in Racket, but we can easily bootstrap and have a fully metacircular evaluator. This implementation is neither robust nor comprehensive, by the language reference's definition. Instead, the core implementation attempts to implement Kernel as smoothly as possible within Racket. All objects within the core implementation are Racket objects, and many Kernel definitions simply delegate to built-in Racket procedures.

There is one notable departure from standard Kernel: all pairs in this implementation of Kernel are immutable @racket[cons] cells. This provides three main benefits:

@itemlist[
  @item{The core implementation can simply use the default Racket S-expression reader, which returns immutable lists. Otherwise, the core implementation would have to read mutable lists, and would be littered with @racket[mcons], @racket[mlist], etc.}
  @item{It avoids all of the complexities that the reference implementation had to deal with around mutable lists and cycles. This will be more evident when we see the definition of @code{map}.}
  @item{Subjectively, a language that is immutable by default will be a more trustworthy companion to its users. A prevelant argument for many of Kernel's design decisions is "dangerous things should be hard to do by default", and the choice of mutable pairs by default seems to violate this.}
]

In the style of the language reference, we will introduce the core Kernel types and built-in procedures one-by-one, building up the core language. Each subsection that follows is encapsulated in its own Racket file in the @code{src/core} directory, and the actual Racket definitions are duplicated here.

Procedures defined by the core implementation have names prefixed with @code{kernel-} so as to avoid confusion by shadowing built-in Racket procedures. The core Kernel procedures are ultimately bound in the ground Kernel environment with the same name, less the @code{kernel-} prefix.

Note that in the examples, we are evaluating Kernel expressions even though many of the names are the same as in Racket. That is, the examples exercising @code{boolean?} are using the Kernel procedure @code{boolean?}, which is implemented by the Racket procedure @code{kernel-boolean?}.

@subsection{Booleans}

@defproc[(kernel-boolean? [object any/c]) boolean?]{
Booleans are represented by the Racket objects @racket[#t] and @racket[#f].

@racketblock[(define kernel-boolean? boolean?)]

@examples[#:eval kernel-core-evaluator
          (boolean? #f)
          (boolean? #t)
          (boolean? 1)]
}

@subsection{Equivalence under mutation}

@defproc[(kernel-eq? [object1 any/c] [object2 any/c]) boolean?]{
Equivalence under mutation simply delegates to Racket's @racket[eq?] procedure.

@racketblock[(define kernel-eq? eq?)]

While the core implementation does not provide any mechanism to mutate @racket[cons] cells, they are nevertheless considered un-equal under mutation.

@examples[#:eval kernel-core-evaluator
          (eq? 1 1)
          (eq? (cons 1 2) (cons 1 2))]
}

@subsection{Equivalence up to mutation}

@defproc[(kernel-equal? [object1 any/c] [object2 any/c]) boolean?]{
Similarly, equivalence up to mutation simply delegates to Racket's @racket[equal?] procedure.

@racketblock[(define kernel-equal? equal?)]

As expected, @racket[cons] cells are considered equal up to mutation.

@examples[#:eval kernel-core-evaluator
          (equal? 1 1)
          (equal? (cons 1 2) (cons 1 2))]
}
