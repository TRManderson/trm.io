---
layout: post
title:  "A Python-esque Type System for Python: Duck Typing Statically"
date:   2017-01-29 20:55:00 +1000
categories: python types mypy
---

I think the mypy static type checker is a fantastic initiative, and absolutely love it. My one complaint is that it relies a little too much on subclassing for determining compatibility. This post discusses nominal vs. structural subtyping, duck typing and how it relates to structural subtyping, subtyping in mypy, and using abstract base classes in lieu of a structural subtyping system. (Can you say "structural subtyping"?)

Nominative and Structural Subtyping
-----------------------------------

In OOP languages with type systems, we've got this notion of "subtyping" or "supertyping", that's pretty much exclusively based on inheritance. If you're comfortable with inheritance in OOP, you're comfortable with the idea of a "subclass" (pretty much by definition). I'll use Java as an example for this. In the following code example, `B` is a subclass, and thus a subtype, of `A`.

```java
class A {
    int x(int y){
        return y;
    }
}

class B extends A{
    
}
```

The idea of a subtyping relation has to deal with all the constructs in a type system though, which (in Java at least) also includes interfaces and abstract classes. For abstract classes, subtyping is still exactly subclassing. Whether or not you can instantiate your abstract class, it's still a class, and at type level, you can still subclass it. With interfaces, it's still fairly intuitive. A class `A` is a subtype of interface `I` if `A implements I`. Nothing particularly complex.

```java
interface I {
    int x(int);
}

class A implements I{
    int x(int y){
        return y;
    }
}   
```

The subtyping relation in Java is what's described as "nominative" (name-based) subtyping, forming a "nominal type system". Subtypes are determined by names and explicit declarations of compatibility or inheritance, but it's not the only option. There's also "structural" subtyping, where `A` being a subtype of `B` is determined by the structure of both `A` and `B`. The best example I could come up with of a language with structural subtyping is Go, and I've shamelessly stolen the following example from [Go By Example](https://gobyexample.com/interfaces).

```go
import "fmt"
import "math"

    
type geometry interface {
    area() float64
    perim() float64
}

type rect struct {
    width, height float64
}
type circle struct {
    radius float64
}

func (r rect) area() float64 {
    return r.width * r.height
}
func (r rect) perim() float64 {
    return 2*r.width + 2*r.height
}


func (c circle) area() float64 {
    return math.Pi * c.radius * c.radius
}
func (c circle) perim() float64 {
    return 2 * math.Pi * c.radius
}

func measure(g geometry) {
    fmt.Println(g)
    fmt.Println(g.area())
    fmt.Println(g.perim())
}

func main() {
    r := rect{width: 3, height: 4}
    c := circle{radius: 5}
    measure(r)
    measure(c)
}
```

In the above code snippet, we've defined an interface `geometry`, and two types `rect` and `circle`. While Go likes to claim it doesn't actually have a subtype relation, for all intents and purposes `rect` and `circle` are subtypes of `geometry` because there is a defined `area` and `perim` method for both of them, both of which match the type signature of `geometry` for their respective types. Because `rect` and `circle` implement the necessary methods to match the *structure* of `geometry`, they can be used in the `measure` method, which accepts `geometry` values.

Put simply, because `rect` and `circle` match the structure of `geometry`, they are a subtype of it, and this is structural subtyping. You might find it worthwhile to read more about structural subtyping on the [Wikipedia page about "Structural Type Systems"](https://en.wikipedia.org/wiki/Structural_type_system).

Because Go doesn't provide generics, people make use of Go's structural type system to do nifty generic-like tricks. The most common such trick you'll see is `type interface {}` which is sometimes called the "top type" in Go, because everything is a structural subtype of it. When there's no necessary structure for a type, everything implements the necessary structure.

Duck Typing
-----------

Duck typing is relatively poorly defined, but there's a [common saying](https://en.wikipedia.org/wiki/Duck_test) used to describe how this works.
> "If it looks like a duck, swims like a duck, and quacks like a duck, then it probably is a duck."

My interpretation of duck typing is that you shouldn't check the type of what's passed into your functions -- at most check that what's passed in has the methods and attributes that are necessary to do what you need, but you probably don't need to do that, as trying to use those things will error anyway if they're not there.

Due to the informal definition of duck typing, a lot of people mix it up with structural subtyping. Both are talking about the structure of a type, checking the necessary methods and attributes are present, etc, but duck typing tends to have connotations of dynamic types ("shouldn't check the type"), whereas structural type systems specifically talk about subtyping relations, which implies static typing.

The philosophy of duck typing is fairly heavily encouraged in Python-land. The most clear-cut example I could find of this is when looking for tips on "checking if an object is file-like". If you go to StackOverflow or the official Python docs, you'll see something along the lines of...

> Don't check if an object is file-like, check if it has methods like `read` or `write` using `hasattr(obj, "read")`.

If it looks like a duck, swims like a duck, and quacks like a duck, then it probably is a duck.

Structural Subtyping in the mypy Type-checker
---------------------------------------------
The subtype relation in mypy as it stands is basically just a nominative checker. You have to explicitly inherit from a superclass to be considered a subtype of it, pretty much like Java. However, there's been an [outstanding issue](https://github.com/python/typing/issues/11) discussing approaches to structural subtyping (which they call "Protocols") since the early days of mypy. The meat of the proposed approach is in [this comment](https://github.com/python/typing/issues/11#issuecomment-138133867), but I'll summarise here.

Protocols will be declared as separate classes, inheriting from a magic `Protocol` base class. Rather than using `isinstance` to check if something implements a protocol (read: "is a structural subtype of"), there'll be some separate checker function like `implements`. Runtime implementation checks are performance expensive, and Protocols are intended to make static checking easier, not necessarily as a runtime representation of an API (though that functionality is still useful), hence the separate method.

Protocols will be extensible via subclassing (though you'll have to redeclare that you're subclassing the `Protocol` base class, or it'll be assumed you're just implementing the given protocol), will be allowed to be generic, will support declaring both methods and attributes to implement. Here's an example of the syntax:

Protocols:
```python
from typing import Protocol # not actually there yet

class FooProtocol(Protocol):
    attr: int
    def foo(self, x: int) -> int: ...

class FooConcrete(object):
    def __init__(self, attr: int) -> None:
        self.attr = attr

    def foo(self, x):
        return x

def fn_on_foo(foo_obj: FooProtocol):
    return foo_obj.foo(1)

foo = FooConcrete(1)

fn_on_foo(foo)
```

Unfortunately, none of this is concrete and certain, so the above syntax is a combination of my best guess and what I'd like the syntax to end up like.

The Stop-gap Measure
--------------------

While I wait for protocols to be firmed up in the form of a PEP, I've come up with a stop-gap measure that I'm relatively happy with. I've been making use of [abstract base classes](https://docs.python.org/3/library/abc.html), which provide the ability to register classes that don't directly inherit from them (better than nominative subtyping, not quite as good as structural subtyping). As an example, I've included below an example of how I'd write the protocol from above as an abstract base class.

Abstract Base Classes:
```python
from abc import ABC, abstractmethod

class FooBase(ABC):
    attr = None # type: int
    @abstractmethod
    def foo(self, x: int) -> int: ...

class FooConcrete(object):
    def __init__(self, attr: int) -> None:
        self.attr = attr

    def foo(self, x):
        return x

FooBase.register(FooConcrete) # error: "FooBase" has no attribute "register"

def fn_on_foo(foo_obj: FooBase):
    return foo_obj.foo(1)

foo = FooConcrete(1)

fn_on_foo(foo)  # error: Argument 1 to "fn_on_foo" has incompatible type "FooConcrete"; expected "FooBase"
```

Very similar code, just with a different base class, an extra decorator, and explicit registration. While these work just as well as runtime, I've included the error output from mypy as comments. Not quite as type-checker-friendly. This case is a little contrived, seeing as I could've just inherited from `FooBase` to start with and everything would've been lovely, but you can see why I'm calling this a stop-gap solution and nothing more.

Final Thoughts
--------------

In general, you can pretty comfortably get away with the nominal subtyping that mypy happily type checks right now, but it does push you in a direction that's slightly less Pythonic. Given Python's emphasis on duck typing, it makes a lot of sense to provide some sort of structural subtyping too. There's been a little bit of interest lately on the [mypy gitter chat](https://gitter.im/python/mypy) to do with structural subtyping, so hopefully the situation will start improving soon.