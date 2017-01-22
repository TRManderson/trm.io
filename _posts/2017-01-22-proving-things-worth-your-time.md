---
layout: post
title:  "Why Proving that Addition is Commutative is Worth Your Time"
date:   2017-01-22 20:00:00 +1000
categories: proofs coq mathematics
---

I've recently been working my way through the fantastic book [Software Foundations](https://www.cis.upenn.edu/~bcpierce/sf/current/index.html), primarily written by Benjamin C. Pierce, which focuses on how to build reliable software. To illustrate the content a bit more, here's an excerpt from the preface.

>Building reliable software is hard. The scale and complexity of modern systems, the number of people involved in building them, and the range of demands placed on them render it extremely difficult to build software that is even more-or-less correct, much less 100% correct. At the same time, the increasing degree to which information processing is woven into every aspect of society continually amplifies the cost of bugs and insecurities.
>
>Computer scientists and software engineers have responded to these challenges by developing a whole host of techniques for improving software reliability, ranging from recommendations about managing software projects and organizing programming teams (e.g., extreme programming) to design philosophies for libraries (e.g., model-view-controller, publish-subscribe, etc.) and programming languages (e.g., object-oriented programming, aspect-oriented programming, functional programming, ...) to mathematical techniques for specifying and reasoning about properties of software and tools for helping validate these properties.

I haven't made it that far through the book yet, but what I have done has been working through the basics of [Coq, a formal proof assistant](https://coq.inria.fr/). Most of my progress so far was during a recent work trip, where I made it through the first few chapters. Discussion about what I was up to pretty commonly went as follows:

>Colleauge: What are you up to, Tom?
>
>Me: Right now? Proving that addition is commutative.
>
>C: I would've figured that's true by definition
>
>M: Uh, yeah, but, uh, I guess I still have to prove it?

I started Software Foundations for fun, without really having a goal in sight, but discussions like that made me question what I was doing. Why on earth was I bothering to prove something that's so obvious?

The Answer
----------

In order to use something in a program, you have to implement it. We all know how addition works (I hope), but there are some inherent assumptions about that understanding (addition on real numbers? on 32 bit integers? signed or unsigned?). When using formal methods (like proofs) to verify our program, we are verifying that our implementation is congruent with those implicit assumptions.

Sure, I know that by definition, addition is commutative, but is my specific implementation of addition on inductively defined natural numbers *really* commutative? The standard approach to being confident about something like this is to come up with test cases which give you a lot of benefits, but the only way to be 100% certain is to something stronger and more formal like a proof.

For a lot of simpler cases like this, it's about as much time to write a proof as it is to write enough test cases to cover a reasonable amount of your code, and you can take a lot more certainty from it. As your software gets more complex, it becomes both harder to test, and harder to formally verify, but unlike your test cases which cover less and less of your functionality, proofs are always 100%. When reliability is key, you can't trump formal methods.

The Real-World Answer
---------------------

There's currently an effort underway to [rewrite Software Foundations](https://github.com/idris-hackers/software-foundations) for the [Idris programming language](http://www.idris-lang.org/). Idris is a Haskell-like, dependently typed language with the ability to [state and prove theorems](http://docs.idris-lang.org/en/latest/tutorial/theorems.html). I think it's fantastic that we've got a general purpose programming language based on a language in production usage at companies like Facebook that has formal methods built right in, but I think there's a more immediately useful stepping stone -- dependent types. To quote the Idris homepage...

>Dependent types allow types to be predicated on values, meaning that some aspects of a program’s behaviour can be specified precisely in the type.

Sounds a lot like some sort of formal method for verifying program behaviour, doesn't it? I like to think of dependent types, especially along with other type system magic, as Proofs Lite&trade;. You can be 100% certain that whatever your dependent type says is going to hold at runtime, and it's generally easier and more concise to do verify aspects of your program with your type system than with formal methods or tests.

The reason Idris is worth mentioning is because it allows you to make use of these formal methods when it *is* useful, and in other situations you can just rely on type system features like [higher-kinded types](https://en.wikipedia.org/wiki/Kind_(type_theory)#Kinds_in_Haskell), [algebraic datatypes](https://en.wikipedia.org/wiki/Algebraic_data_type), and [dependent types](https://en.wikipedia.org/wiki/Dependent_type). While I'd love to go into more detail on each of the above, they'd probably need a post of their own, for now I've linked the respective Wikipedia pages.

When reliability is a concern in your software, consider using formal methods before jumping right to tests. Surprisingly enough, you'll probably get more reliability from less code.
