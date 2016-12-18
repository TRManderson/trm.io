---
layout: post
title:  "An Overview of Types in Python"
date:   2016-12-18 21:00:00 +1000
categories: python types
---

While Python is a dynamically typed language, from Python 3.5 onwards there's been an effort to add the ability to use types within the language. Python 3.4 added the ability to add any arbitrary python expression to the arguments in a function with [PEP 3107 (Function Annotations)](https://www.python.org/dev/peps/pep-3107/), and this was expanded upon in Python 3.5 with [PEP 484 (Type Hints)](https://www.python.org/dev/peps/pep-0484/), which aimed to provide a standard syntax for declaring types in Python.

This standardised language for types in Python made the [Mypy project](http://mypy-lang.org/) possible - a static typechecker for Python programs with type annotations. At runtime, these type annotations do absolutely nothing (as checking and coercing have a huge runtime overhead), but provide a way for external programs to type-check Python programs. 


Why Types?
----------

Types give us the ability to reason about our programs more easily, by restricting the inputs and outputs of our functions to only those things our code actually knows how to deal with. The more sophisticated your type system, the more nuanced you can make these restrictions, eventually reaching the point where you can do cool things like type-level programming.


Type checking can eliminate whole classes of type-related bugs, to the point where languages with sophisticated type systems like Haskell can, very much validly, make claims like "if it compiles, it probably runs". Silly mistakes and typos are almost always caught by the typechecker.


The other advantage of types in languages that are statically typed is efficiency gains - if you know what type something is before you use it, you can eliminate a lot of code just to do with getting at the values you need. Unfortunately, this will never be the case for Python, as PEP 484 (Type Hints) explicitly states "Python will remain a dynamically typed language, and the authors have no desire to ever make type hints mandatory, even by convention". If you're desperate for the runtime performance gains that static types bring you, [Cython](http://cython.org/) is the way to go - it allows you to provide specialised annotations that lets some of your Python be compiled into C.


Let's look at some code
------------------------------

If you've used a language like Java, you pretty much know what to expect when it comes to the basics. Generics, classes, etc, etc. Here's two code samples to compare

Java:
```java
class A {
    private int x;
    A(int x){
        this.x = x;
    }
}

class A extends B{  
}

class C {
    <T> static T method(T a){
        return a;
    }

    <T> static List<T> method(T a){
        return Arrays.asList(a);
    }
}
```

Python:
```python
from typing import TypeVar, List

class A(object):
    x # type: int
    def __init__(self, x) -> None:
        self.x = x

class B(A):
    pass

T = TypeVar('T', covariant=True)
class C(object):
    @staticmethod
    def method(a: T) -> T:
        return a

    def method2(a: T) -> List[T]:
        return [a]
```

I've snuck in a bit of Python weirdness without mentioning. As PEP 3107 (Function Annotations) declares that function annotations must be valid Python expressions, we can't use undefined variables etc, so generics become a little bit more verbose. The `T = TypeVar('T')` declares a "type variable", and when used in a method, all usages of `T` as a type annotation are forced to represent the same type. 

Type variables have a concept called "variance", which limits what can be substituted in for them. A "covariant" type variable lets any usages of it be either the same type as, or a "subtype" (subclass) of the type that the variable is standing in for. A "contravairant" type variable makes sure that the type it is standing in for is a subtype/subclass of every usage. An "invariant" type variable must have every usage being exactly the same type as whatever it's standing in for.

Generics in Python, like list, are declared using `Generic[T]` as a base class instead of `object`, where the `T` is a `TypeVar` declared before the class is, and this also limits what a generic type can contain according to the `TypeVar`'s variance.

There's way more info on the [wikipedia page about type variance](https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)), but for now, here's an example for lists, which have an 

```python
from typing import List

class A(object): pass

class B(A): pass

x = [] # type: List[A]

# valid, appending an A to a List[A]
x.append(A())

# errors, lists are invariant over the type they contain, so a subclass of A is
# not valid, even though it would be in Java.
x.append(B())
```

### Other Differences

Because Python is dynamically typed, you get functions that accept inputs with all kinds of weird features, and you get functions that the type system isn't sophisticated enough to accurately represent. For situations like that, Python has two extra type system features you won't find in normal statically typed languages: `Union` and `Any`.

Releatively unsurprisingly, `Any` is considered valid a valid type for absolutely any. It's kind of the active opt-out of the type system, and lets you get out of type checking. When you're starting to add type annotations to a code base, or coming across those weird unrepresentable situations, `Any` gives you an out.

`Union` allows a value to be any one of a given set of types, and type check correctly for any of them. For example both `"abcd"` and `1234` are valid inputs for a function with an argument that takes a type of `Union[int, str]`. I've seen `Union` used to represent types that have a common property before, which is often not the right approach, as there are a bunch of abstract base classes provided by the `typing` module that can be used instead if it's common enough. The main other situation I see `Union` used for is a form of user-controlled dynamic dispatch which you'd get for free in Java. Here's some more code samples to demonstate the difference:

Java:
```java
class A{
    static float halve(int x){
        return x / 2.0;
    }
    static float halve(String x){
        return halve(parseInt(x));
    }
}
```

Python:
```python
from typing import Union
def halve(x: Union[str, int]) -> float:
    if isinstance(x, str):
        x = int(x)
    return x / 2.0;
```

So while Java relies on the language to do type-based dynamic dispatch, Python does the conversion explicitly, by allowing more input types.

## Final Thoughts

While throughout this post I've been using Python 3 examples, this all works on Python 2 (though advanced metaprogramming features aren't going to work out as expected). If you want to start using `typing` in your python code, go check out [the module documentation](https://docs.python.org/3/library/typing.html), and the [`mypy` documentation](http://mypy.readthedocs.io/en/latest/).

Also, if you want to know more about type systems, [the Wikipedia article on them](https://en.wikipedia.org/wiki/Type_system) is a great start. The maths behind type systems gets pretty crazy interesting, you'll likely see some more about it on here in the future.

### (PS)

This is my first ever published blog post. I would absolutely love any feedback, be it positive or horribly negative. Feel free to email me via [me@trm.io](mailto:me@trm.io), or hit me up on [my insufficiently used twitter](https://twitter.com/TRManderson).