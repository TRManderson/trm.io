---
layout: post
title:  "Python and Structural Subtyping"
date:   2017-01-29 21:00:00 +1000
categories: python types
---


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

The subtyping relation in Java is what's described as "nominative" (name-based) subtyping, forming a "nominal type system". Subtypes are determined by names and explicit declarations of compatability or inheritance, but it's not the only option. There's also "structural" subtyping, where `A` being a subtype of `B` is determined by the structure of both `A` and `B`. The best example I could come up with of a language with structural subtyping is Go, and I've shamelessly stolen the following example from [Go By Example](https://gobyexample.com/interfaces).

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