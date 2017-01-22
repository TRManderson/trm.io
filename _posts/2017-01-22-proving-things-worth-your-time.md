---
layout: post
title:  "Why Proving that Addition is Commutative is Worth Your Time"
date:   2017-01-22 21:05:00 +1000
categories: proofs coq mathematics
---

I've recently been working my way through the fantastic book [Software Foundations](https://www.cis.upenn.edu/~bcpierce/sf/current/index.html), primarily written by Benjamin C. Pierce, which focuses on how to build reliable software. To illustrate the content, here's an excerpt from the preface:

>Building reliable software is hard. The scale and complexity of modern systems, the number of people involved in building them, and the range of demands placed on them render it extremely difficult to build software that is even more-or-less correct, much less 100% correct. At the same time, the increasing degree to which information processing is woven into every aspect of society continually amplifies the cost of bugs and insecurities.
>
>Computer scientists and software engineers have responded to these challenges by developing a whole host of techniques for improving software reliability, ranging from recommendations about managing software projects and organizing programming teams (e.g., extreme programming) to design philosophies for libraries (e.g., model-view-controller, publish-subscribe, etc.) and programming languages (e.g., object-oriented programming, aspect-oriented programming, functional programming, ...) to mathematical techniques for specifying and reasoning about properties of software and tools for helping validate these properties.


The Question
------------

I haven't made it that far through the book yet, but what I been working through is the basics of [Coq, a formal proof assistant](https://coq.inria.fr/), which is the tool the book uses to teach concepts. I made my start during a recent work trip, where I made it through the first few chapters. Discussion about what I was up to pretty commonly went as follows:

>Colleague: What are you up to, Tom?
>
>Me: Right now? Proving that addition is [commutative](https://en.wikipedia.org/wiki/Commutative_property).
>
>C: I would've figured that's true by definition
>
>M: Uh, yeah, but, uh, I guess I still have to prove it?

I started Software Foundations for fun, without really having a goal in sight, but discussions like that made me question what I was doing. Why on earth was I bothering to prove something that's so obvious?

The Answer
----------

In order to use something in a program, you have to implement it. We all know how addition works (I hope), but there are some inherent assumptions about that understanding (addition on real numbers? on 32 bit integers? signed or unsigned?). When using formal methods to verify our program (like proofs), we are verifying that our implementation is congruent with those inherent assumptions.

Sure, I know that, by definition, addition is commutative, but is my specific implementation of addition on inductively defined natural numbers *really* commutative? The standard approach to being confident about something like this is to come up with test cases. This gives you a lot of benefits, but the only way to be sure that what you're trying to verify works for 100% of cases is to use formal methods.

Do we really need 100% certainty for addition being commutative? I'd wager that it's not really the case for most uses, but in order to prove that your webapp does what you think it does, you'll almost definitely build your functionality from smaller functions. Correspondingly, you'd also be building up your proofs from smaller proofs (like a proof of the commutativity of addition, for example). While you'll likely have the proof of commutativity of addition provided to you, it's a valuable learning exercise to work through it yourself.

Often, it's about as much time to write a proof as it is to write enough test cases to cover a reasonable amount of your code, and you can take a lot more certainty from it. As your software gets more complex, it becomes both harder to test, and harder to formally verify, but unlike your test cases which cover less and less of your functionality, proofs are always 100%. When reliability is key, you can't trump formal methods.

The Real-World Answer
---------------------

There's currently an effort underway to [rewrite Software Foundations](https://github.com/idris-hackers/software-foundations) for the [Idris programming language](http://www.idris-lang.org/). Idris is a Haskell-like, dependently typed language with the ability to [state and prove theorems](http://docs.idris-lang.org/en/latest/tutorial/theorems.html). I think it's fantastic that we've got a general purpose programming language with formal methods built right in, but what I think is more immediately useful for the average programmer is dependent types.

>Dependent types allow types to be predicated on values, meaning that some aspects of a program’s behaviour can be specified precisely in the type.

Sounds a lot like some sort of method for verifying program behaviour, doesn't it? Funnily enough, there's a proof that proofs of program behaviour are mathematically equivalent to dependent types, called the [Curry-Howard Isomorphism](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence). In practice, however, you can be a little bit more piecemeal with dependent types, and slowly add more details as you go. You can be 100% certain that whatever your dependent type says is going to hold at runtime, and it's generally easier and more concise to do verify aspects of your program with your type system than with formal methods or tests.

The reason Idris is worth mentioning is because it allows you to make use of proofs when it *is* useful, and in other situations you can just rely on type system features like [higher-kinded types](https://en.wikipedia.org/wiki/Kind_(type_theory)#Kinds_in_Haskell), [algebraic datatypes](https://en.wikipedia.org/wiki/Algebraic_data_type), and [dependent types](https://en.wikipedia.org/wiki/Dependent_type), which all let you get just a little bit extra certainty in your program. While I'd love to go into more detail on each of the above, they'd probably need a post of their own, for now I've linked the respective Wikipedia pages.

When reliability is a concern in your software, consider using formal methods before jumping right to tests. Surprisingly enough, you'll probably get more reliability from less code. If you're interested in learning more, I wholeheartedly recommend Software Foundations, and feel free to send me an email or get in touch via twitter.