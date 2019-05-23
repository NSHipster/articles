---
title: CoreGraphics Geometry Primitives
author: Mattt
category: Cocoa
excerpt: >-
  Unless you were a Math Geek or an Ancient Greek,
  Geometry probably wasn't your favorite subject in school.
  More likely, you were that kid in class
  who dutifully programmed all of those necessary formulæ
  into your TI-8X calculator to avoid rote memorization.
revisions:
  "2012-12-17": Original publication
  "2015-02-17": Updated for Swift 2
  "2019-04-22": Updated for Swift 5
status:
  swift: 5.0
  reviewed: April 22, 2019
---

Unless you were a Math Geek or an Ancient Greek,
Geometry probably wasn't your favorite subject in school.
More likely, you were that kid in class
who dutifully programmed all of those necessary formulæ
into your TI-8X calculator to avoid rote memorization.

So for those of you who spent more time learning TI-BASIC than Euclid,
here's the cheat-sheet for how geometry works in [Quartz 2D][quartz-2d],
the drawing system used by Apple platforms:

{::nomarkdown}

<figure>
{% asset core-graphics-primitives.svg width=900 %}
<figcaption hidden>CoreGraphics Primitives (iOS)</figcaption>
</figure>
{:/}

- A <dfn>`CGFloat`</dfn>
  represents a scalar quantity.
- A <dfn>`CGPoint`</dfn>
  represents a location in a two-dimensional coordinate system
  and is defined by `x` and `y` scalar components.
- A <dfn>`CGVector`</dfn>
  represents a change in position in 2D space
  and is defined by `dx` and `dy` scalar components.
- A <dfn>`CGSize`</dfn>
  represents the extent of a figure in 2D space
  and is defined by `width` and `height` scalar components.
- A <dfn>`CGRect`</dfn>
  represents a rectangle
  and is defined by an origin point (`CGPoint`) and a size (`CGSize`).

```swift
import CoreGraphics

let float: CGFloat = 1.0
let point = CGPoint(x: 1.0, y: 2.0)
let vector = CGVector(dx: 4.0, dy: 3.0)
let size = CGSize(width: 4.0, height: 3.0)
var rectangle = CGRect(origin: point, size: size)
```

{% info %}
`CGVector` isn't widely used in view programming;
instead, `CGSize` values are typically used to express positional vectors.
Unfortunately, this can result in awkward semantics,
because sizes may have negative `width` and / or `height` components
(in which case a rectangle is extended
in the opposite direction along that dimension).
{% endinfo %}

{::nomarkdown}

<figure>
{% asset core-graphics-coordinate-systems.svg width=500 %}
<figcaption hidden>CoreGraphics Coordinates Systems (iOS)</figcaption>
</figure>
{:/}

On iOS, the origin is located at the top-left corner of a window,
so `x` and `y` values increase as they move down and to the right.
macOS, by default, orients `(0, 0)` at the bottom left corner of a window,
such that `y` values increase as they move up.

{% info %}
You can configure views on macOS to use the same coordinate system as iOS
by overriding the
[`isFlipped`](https://developer.apple.com/documentation/appkit/nsview/1483532-isflipped) property
on subclasses of `NSView`.
{% endinfo %}

---

Every view in an iOS or macOS app
has a `frame` represented by a `CGRect` value,
so one would do well to learn the fundamentals
of these geometric primitives.

In this week's article,
we'll do a quick run through the APIs
with which every app developer should be familiar.

---

## Introspection

_"First, know thyself."_
So goes the philosophical aphorism.
And it remains practical guidance as we begin our survey of CoreGraphics API.

As structures,
you can access the member values of geometric types
directly through their stored properties:

```swift
point.x // 1.0
point.y // 2.0

size.width // 4.0
size.height // 3.0

rectangle.origin // {x 1 y 2}
rectangle.size // {w 4 h 3}
```

You can mutate variables by reassignment
or by using mutating operators like `*=` and `+=`:

```swift
var mutableRectangle = rectangle // {x 1 y 2 w 4 h 3}
mutableRectangle.origin.x = 7.0
mutableRectangle.size.width *= 2.0
mutableRectangle.size.height += 3.0
mutableRectangle // {x 7 y 2 w 8 h 6}
```

For convenience,
rectangles also expose `width` and `height`
as top-level, computed properties;
(`x` and `y` coordinates must be accessed through the intermediary `origin`):

```swift
rectangle.origin.x
rectangle.origin.y
rectangle.width
rectangle.height
```

{% info %}
However, you can't use these convenience accessors
to change the underlying rectangle like in the preceding example:

```swift
mutableRectangle.width *= 2.0 // {x 1 y 2 w 8 h 3} // ⚠️ Left side of mutating operator isn't mutable: 'width' is a get-only property
```

{% endinfo %}

### Accessing Minimum, Median, and Maximum Values

Although a rectangle can be fully described by
a location (`CGPoint`) and an extent (`CGSize`),
that's just one side of the story.

For the other 3 sides,
use the built-in convenience properties
to get the minimum (`min`), median (`mid`), and maximum (`max`) values
in the `x` and `y` dimensions:

{::nomarkdown}

<figure>
{% asset core-graphics-cgrect-min-mid-max.svg width=500 %}
<figcaption hidden>CoreGraphics CGRect Properties (iOS)</figcaption>
</figure>
{:/}

```swift
rectangle.minX // 1.0
rectangle.midX // 3.0
rectangle.maxX // 5.0

rectangle.minY // 2.0
rectangle.midY // 3.5
rectangle.maxY // 5.0
```

#### Computing the Center of a Rectangle

It's often useful to compute the center point of a rectangle.
Although this isn't provided by the framework SDK,
you can easily extend `CGRect` to implement it
using the `midX` and `midY` properties:

```swift
extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
```

## Normalization

Things can get a bit strange when you use
non-integral or negative values in geometric calculations.
Fortunately,
CoreGraphics has just the APIs you need
to keep everything in order.

### Standardizing Rectangles

We expect that a rectangle's origin is situated at its top-left corner.
However,
if its size has a negative width or height,
the origin could become any of the other corners instead.

For example,
consider the following _bizarro_ rectangle
that extends leftwards and upwards from its origin.

```swift
let ǝןƃuɐʇɔǝɹ = CGRect(origin: point,
                         size: CGSize(width: -4.0, height: -3.0))
ǝןƃuɐʇɔǝɹ // {x 1 y 2 w -4 h -3}
```

We can use the `standardized` property
to get the equivalent rectangle
with non-negative width and height.
In the case of the previous example,
the standardized rectangle
has a width of `4` and height of `3`
and is situated at the point `(-3, -1)`:

```swift
ǝןƃuɐʇɔǝɹ.standardized // {x -3 y -1 w 4 h 3}
```

### Integrating Rectangles

It's generally a good idea for all `CGRect` values
to be rounded to the nearest whole point.
Fractional values can cause the frame to be drawn on a <dfn>pixel boundary</dfn>.
Because pixels are atomic units,
a fractional value causes drawing to be averaged over the neighboring pixels.
The result: blurry lines that don't look great.

The `integral` property takes the `floor` each origin value
and the `ceil` each size value.
This ensures that your drawing code aligns on pixel boundaries crisply.

```swift
let blurry = CGRect(x: 0.1, y: 0.5, width: 3.3, height: 2.7)
blurry // {x 0.1 y 0.5 w 3.3 h 2.7}
blurry.integral // {x 0 y 0 w 4 h 4}
```

{% info %}
Though keep in mind that CoreGraphics coordinates
operate in terms of <dfn>points</dfn> not pixels.
So, for example,
a Retina screen with pixel density of 2
represents each point with 4 pixels
and can draw `± 0.5f` point values on odd pixels without blurriness.
{% endinfo %}

## Transformations

While it's possible to mutate a rectangle
by performing member-wise operations on its origin and size,
the CoreGraphics framework offers better solutions
by way of the APIs discussed below.

### Translating Rectangles

<dfn>Translation</dfn> describes the geometric operation of
moving a shape from one location to another.

Use the `offsetBy` method (or `CGRectOffset` function in Objective-C)
to translate a rectangle's origin by a specified `x` and `y` distance.

```swift
rectangle.offsetBy(dx: 2.0, dy: 2.0) // {x 3 y 4 w 4 h 3}
```

Consider using this method whenever you shift a rectangle's position.
Not only does it save a line of code,
but it more semantically represents intended operation
than manipulating the origin values individually.

### Contracting and Expanding Rectangles

Other common transformations for rectangles
include contraction and expansion around a center point.
The `insetBy(dx:dy:)` method can accomplish both.

When passed a positive value for either component,
this method returns a rectangle that
_shrinks_ by the specified amount from each side
as computed from the center point.
For example,
when inset by `1.0` horizontally (`dy = 0.0`),
a rectangle originating at `(1, 2)`
with a width of `4` and `height` equal to `3`,
produces a new rectangle originating at `(2, 2)`
with width equal to `2` and height equal to `3`.
Which is to say:
**the result of insetting a rectangle by `1` point horizontally
is a rectangle whose `width` is `2` points _smaller_ than the original.**

```swift
rectangle // {x 1 y 2 w 4 h 3}
rectangle.insetBy(dx: 1.0, dy: 0.0) // {x 2 y 2 w 2 h 3}
```

When passed a negative value for either component,
the rectangle _grows_ by that amount from each side.
When passed a non-integral value,
this method may produce a rectangle with non-integral components.

```swift
rectangle.insetBy(dx: -1.0, dy: 0.0) // {x 0 y 2 w 6 h 3}
rectangle.insetBy(dx: 0.5, dy: 0.0) // {x 1.5 y 2 w 3 h 3}
```

{% info %}
For more complex transformations,
another option is [`CGAffineTransform`](https://developer.apple.com/documentation/coregraphics/cgaffinetransform),
which allows you to translate, scale, and rotate geometries ---
all at the same time!
_(We'll cover affine transforms in a future article)_
{% endinfo %}

## Identities and Special Values

Points, sizes, and rectangles each have a `zero` property,
which defines the <dfn>identity</dfn> value for each respective type:

```swift
CGPoint.zero // {x 0 y 0}
CGSize.zero // {w 0 h 0}
CGRect.zero // {x 0 y 0 w 0 h 0}
```

Swift shorthand syntax allows you to pass `.zero` directly
as an argument for methods and initializers,
such as `CGRect.init(origin:size:)`:

```swift
let square = CGRect(origin: .zero,
                    size: CGSize(width: 4.0, height: 4.0))
```

{% info %}
To determine whether a rectangle is empty (has zero size),
use the `isEmpty` property
rather than comparing its `size` to `CGSize.zero`.

```swift
CGRect.zero.isEmpty // true
```

{% endinfo %}

---

`CGRect` has two additional special values: `infinite` and `null`:

```swift
CGRect.infinite // {x -∞ y -∞ w +∞ h +∞}
CGRect.null // {x +∞ y +∞ w 0 h 0}
```

`CGRect.null` is conceptually similar to `NSNotFound`,
in that it represents the absence of an expected value,
and does so using the largest representable number to exclude all other values.

`CGRect.infinite` has even more interesting properties,
as it intersects with all points and rectangles,
contains all rectangles,
and its union with any rectangle is itself.

```swift
CGRect.infinite.contains(<#any point#>) // true
CGRect.infinite.intersects(<#any other rectangle#>) // true
CGRect.infinite.union(<#any other rectangle#>) // CGRect.infinite
```

Use `isInfinite` to determine whether a rectangle is, indeed, infinite.

```swift
CGRect.infinite.isInfinite // true
```

But to fully appreciate why these values exist and how they're used,
let's talk about geometric relationships:

## Relationships

Up until this point,
we've been dealing with geometries in isolation.
To round out our discussion,
let's consider what's possible when evaluating two or more rectangles.

### Intersection

Two rectangles <dfn>intersect</dfn> if they overlap.
Their <dfn>intersection</dfn> is the smallest rectangle
that encompasses all points contained by both rectangles.

{::nomarkdown}

<figure>
{% asset core-graphics-intersection.svg width=400 %}
<figcaption hidden>CoreGraphics CGRect Intersection (iOS)</figcaption>
</figure>
{:/}

In Swift,
you can use the `intersects(_:)` and `intersection(_:)` methods
to efficiently compute the intersection of two `CGRect` values:

```swift
let square = CGRect(origin: .zero,
                    size: CGSize(width: 4.0, height: 4.0))
square // {x 0 y 0 w 4 h 4}

rectangle.intersects(square) // true
rectangle.intersection(square) // {x 1 y 2 w 3 h 2}
```

If two rectangles _don't_ intersect,
the `intersection(_:)` method produces `CGRect.null`:

```swift
rectangle.intersects(.zero) // false
rectangle.intersection(.zero) // CGRect.null
```

### Union

The <dfn>union</dfn> of two rectangles
is the smallest rectangle that encompasses all of the points
contained by either rectangle.

{::nomarkdown}

<figure>
{% asset core-graphics-union.svg width=400 %}
<figcaption hidden>CoreGraphics CGRect Union (iOS)</figcaption>
</figure>
{:/}

In Swift,
the aptly-named `union(_:)` method does just this for two `CGRect` values:

```swift
rectangle.union(square) // {x 0 y 0 w 5 h 5}
```

---

So what if you didn't pay attention in Geometry class ---
this is the real world.
And in the real world,
you have `CGGeometry.h`
and all of the types and functions it provides.

Know it well,
and you'll be on your way to discovering great new user interfaces in your apps.
Do a good enough job with that,
and you may encounter the best arithmetic problem of all:
adding up all the money you've made with your awesome new app.
_Mathematical!_

[quartz-2d]: https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html#//apple_ref/doc/uid/TP30001066
