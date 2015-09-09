---
title: CGGeometry
author: Mattt Thompson
category: Cocoa
excerpt: "Unless you were a Math Geek or an Ancient Greek, Geometry was probably not your favorite subject in high school. No, chances are that you were that kid in class who dutifully programmed all of the necessary formulae into your TI-8X calculator. Keeping in the tradition of doing the least amount of math possible, here are some semi-obscure CoreGraphics functions to make your job easier."
revisions:
    "2015-02-17": Added Swift examples and information about how `Swift + CGRect == awesome`; added section for `CGRectIntersect` and `CGRectUnion`.
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Unless you were a Math Geek or an Ancient Greek, Geometry was probably not your favorite subject in high school. No, chances are that you were that kid in class who dutifully programmed all of the necessary formulæ into your TI-8X calculator.

So for those of you who spent more time learning TI-BASIC than Euclidean geometry, here's the cheat-sheet for how geometry works in [Quartz 2D][1], the drawing system used in iOS and OS X:

- A `CGPoint` is a struct that represents a point in a two-dimensional coordinate system. For iOS, the origin is at the top-left, so points move right and down as their `x` and `y` values, respectively, increase. OS X, by contrast, is oriented with `(0, 0)` in the bottom left, with `y` moving up as it increases.

- A `CGSize` is a struct that represents the dimensions of `width` and `height`.

- A `CGRect` is a struct with both a `CGPoint` (`origin`) and a `CGSize` (`size`), representing a rectangle drawn from its `origin` point with the `width` and `height` of its `size`.

Because `CGRect` is used to represent the `frame` of every view drawn on screen, a programmer's success in graphical programming is contingent on their ability to effectively manipulate rectangle geometry.

Fortunately for us, Quartz comes with a slew of useful functions to reduce the amount of floating point math we have to do ourselves. As central as view programming is to Cocoa, and as useful as these functions are, however, they remain relatively unknown to most iOS developers.

This will not stand! Let's shine some light on the most useful functions and save y'all some typing!

> In Swift, the CoreGraphics framework augments `CGRect` by adding all this functionality as static properties, instance properties, and both mutating and non-mutating functions where appropriate. For idiomatic Swift code, prefer properties and nonmutating instance methods whenever possible.

---

Transformations
---------------

First on our list are the geometric transformations. These functions return a `CGRect`, which is the result of performing a particular set of operations on the passed rectangle.

### `CGRectOffset`

> `offsetBy` / `CGRectOffset`: Returns a rectangle with an origin that is offset from that of the source rectangle.

~~~{swift}
// methods:
extension CGRect {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGRect
    mutating func offsetInPlace(dx: CGFloat, dy: CGFloat)
}
// function:
func CGRectOffset(rect: CGRect, dx: CGFloat, dy: CGFloat) -> CGRect
~~~
~~~{objective-c}
CGRect CGRectOffset(
  CGRect rect,
  CGFloat dx,
  CGFloat dy
)
~~~

Consider using this anytime you're changing the origin of a rectangle. Not only can it save a line of code when changing both the horizontal and vertical position, but more importantly, it represents the translation more semantically than manipulating the origin values individually.

### `CGRectInset`

> `rectByInsetting` / `CGRectInset`: Returns a rectangle that is smaller or larger than the source rectangle, with the same center point.

~~~{swift}
// methods:
extension CGRect {
    func insetBy(dx: CGFloat, dy: CGFloat) -> CGRect
    mutating func insetInPlace(dx: CGFloat, dy: CGFloat)
}
// function:
func CGRectInset(rect: CGRect, dx: CGFloat, dy: CGFloat) -> CGRect
~~~
~~~{objective-c}
CGRect CGRectInset(
  CGRect rect,
  CGFloat dx,
  CGFloat dy
)
~~~

Want to make a view-within-a-view look good? Give it a nice 10pt padding with `CGRectInset`. Keep in mind that the rectangle will be resized around its center by ± `dx` on its left and right edge (for a total of `2 × dx`), and ± `dy` on its top and bottom edge (for a total of `2 × dy`).

If you're using `CGRectInset` as a convenience function for resizing a rectangle, it is common to chain this with `CGRectOffset` by passing the result of `CGRectInset` as the `rect` argument in `CGRectOffset`.

### `CGRectIntegral`

> `integral` / `CGRectIntegral`: Returns the smallest rectangle that results from converting the source rectangle values to integers.

~~~{swift}
// methods:
extension CGRect {
    var integral: CGRect { get }
    mutating func makeIntegralInPlace()
}
// function:
func CGRectIntegral(rect: CGRect) -> CGRect
~~~
~~~{objective-c}
CGRect CGRectIntegral (
  CGRect rect
)
~~~

It's important that `CGRect` values all are rounded to the nearest whole point. Fractional values cause the frame to be drawn on a _pixel boundary_. Because pixels are atomic units (cannot be subdivided†) a fractional value will cause the drawing to be averaged over the neighboring pixels, which looks blurry.

`CGRectIntegral` will `floor` each origin value, and `ceil` each size value, which will ensure that your drawing code will crisply align on pixel boundaries.

As a rule of thumb, if you are performing any operations that could result in fractional point values (e.g. division, `CGRectGetMid[X|Y]`, or `CGRectDivide`), use `CGRectIntegral` to normalize rectangles to be set as a view frame.

> † Technically, since the coordinate system operates in terms of points, Retina screens, which have 4 pixels for every point, can draw `± 0.5f` point values on odd pixels without blurriness.


Value Helper Functions
----------------------

These functions provide a shorthand way to calculate interesting dimensional values about a particular `CGRect`.

### `CGRectGet[Min|Mid|Max][X|Y]`

- `CGRectGetMinX`
- `CGRectGetMinY`
- `CGRectGetMidX`
- `CGRectGetMidY`
- `CGRectGetMaxX`
- `CGRectGetMaxY`

These six functions return the minimum, middle, or maximum `x` or `y` value for a rectangle, taking the form:

~~~{swift}
func CGRectGet[Min|Mid|Max][X|Y](rect: CGRect) -> CGPoint
~~~
~~~{objective-c}
CGFloat CGRectGet[Min|Mid|Max][X|Y] (
  CGRect rect
)
~~~

These functions will replace code like `frame.origin.x + frame.size.width` with cleaner, more semantically expressive equivalents (especially with the mid and max functions).

### `CGRectGet[Width|Height]`

~~~{swift}
// Returns the height of a rectangle.
func CGRectGetHeight(rect: CGRect) -> CGFloat

// Returns the width of a rectangle.
func CGRectGetWidth(rect: CGRect) -> CGFloat
~~~
~~~{objective-c}
// Returns the height of a rectangle.
CGFloat CGRectGetHeight (
   CGRect rect
)

// Returns the width of a rectangle.
CGFloat CGRectGetWidth (
   CGRect rect
)
~~~

Much like the previous functions, `CGRectGetWidth` & `CGRectGetHeight` are often preferable to returning the corresponding member of a `CGRect`'s `size`. While it's not extremely competitive in terms of character savings, remember that semantic clarity trumps brevity every time.

### Swift Additions

~~~{swift}
extension CGRect {
    var minX: CGFloat { get }
    var minY: CGFloat { get }
    var midX: CGFloat { get }
    var midY: CGFloat { get }
    var maxX: CGFloat { get }
    var maxY: CGFloat { get }
    var width: CGFloat { get }
    var height: CGFloat { get }
}
~~~

The `CGRect` Swift extensions for dimensional values make a huge difference in code readability, as each of the value helper functions is mapped to individual computed properties.

~~~{swift}
// instead of calling the function
let rightEdge = CGRectMaxX(view.frame)

// simply access the property
let leftEdge = view.frame.minX
~~~


Identities
----------

There are three special rectangle values, each of which have unique properties that are important to know about:

### `CGRectZero`, `CGRectNull`, & `CGRectInfinite`

> - `CGRect.zero` / `const CGRect CGRectZero`: A rectangle constant with location (0,0), and width and height of 0. The zero rectangle is equivalent to CGRectMake(0.0f, 0.0f, 0.0f, 0.0f).
> - `CGRect.null` / `const CGRect CGRectNull`: The null rectangle. This is the rectangle returned when, for example, you intersect two disjoint rectangles. **Note that the null rectangle is not the same as the zero rectangle**.
> - `CGRect.infinite` / `const CGRect CGRectInfinite`: A rectangle that has infinite extent.

`CGRectZero` is perhaps the most useful of all of the special rectangle values. When initializing subviews, their frames are often initialized to `CGRectZero`, deferring their layout to `-layoutSubviews`.

`CGRectNull` is distinct from `CGRectZero`, despite any implied correspondence to `NULL` == `0`. This value is conceptually similar to `NSNotFound`, in that it represents the absence of an expected value. Be aware of what functions can return `CGRectNull`, and be prepared to handle it accordingly, by testing with `CGRectIsNull`.

`CGRectInfinite` is the most exotic of all, and has some of the most interesting properties. It intersects with all points and rectangles, contains all rectangles, and its union with any rectangle is itself. Use `CGRectIsInfinite` to check to see if a rectangle is infinite.


Relationships
-------------

Moving from one rectangle to two, a pair of rectangles can be either intersected or combined to create a new `CGRect`:

### `CGRectIntersection`

> `intersect` / `CGRectIntersection`: Returns the intersection of two rectangles.

~~~{swift}
// methods:
extension CGRect {
    func intersect(withRect: CGRect) -> CGRect
    mutating func intersectInPlace(withRect: CGRect)
}
// function:
func CGRectIntersection(rect1: CGRect, rect2: CGRect) -> CGRect
~~~
~~~{objective-c}
CGRect CGRectIntersection (
  CGRect rect1,
  CGRect rect2
)
~~~

`CGRectIntersection` is a fast way to find the overlapping region between two views. The intersection of two non-overlapping rectangles is a null rect, but if you need to simply check for intersection or containment, use `intersects` / `CGRectIntersectsRect` or `contains` / `CGRectContainsRect` instead.


### `CGRectUnion`

> `union` / `CGRectUnion`: Returns the smallest rectangle that contains the two source rectangles.

~~~{swift}
// methods:
extension CGRect {
    func union(rect: CGRect) -> CGRect
    mutating func unionInPlace(rect: CGRect)
}
// function:
func CGRectUnion(rect1: CGRect, rect2: CGRect) -> CGRect
~~~
~~~{objective-c}
CGRect CGRectUnion (
  CGRect rect1,
  CGRect rect2
)
~~~

Need a rectangle that can wrap two separate regions in your view? Remember that you can chain together different methods to produce the rectangle you need. Use `CGRectUnion` and negative values with `CGRectInset` to find a padded rectangle around two items:

~~~{swift}
let combinedRect = imageRect.union(textRect).insetBy(dx: -10, dy: -10)
~~~
~~~{objective-c}
CGRect combinedRect = CGRectInset(CGRectUnion(imageRect, textRect), -10, -10);
~~~

And Finally...
--------------

Behold, the most obscure, misunderstood, and useful of the `CGGeometry` functions: `CGRectDivide`.

### `CGRectDivide`

> `CGRectDivide`: Divides a source rectangle into two component rectangles.

~~~{swift}
// method:
extension CGRect {
    func divide(atDistance: CGFloat, fromEdge: CGRectEdge) -> (slice: CGRect, remainder: CGRect)
}
// function:
CGRectDivide(rect: CGRect, 
            slice: UnsafeMutablePointer<CGRect>,
        remainder: UnsafeMutablePointer<CGRect>,
           amount: CGFloat,
             edge: CGRectEdge)
~~~
~~~{objective-c}
void CGRectDivide(
  CGRect rect,
  CGRect *slice,
  CGRect *remainder,
  CGFloat amount,
  CGRectEdge edge
)
~~~

`CGRectDivide` divides a rectangle into two components in the following way:

- Take a rectangle and choose an `edge` (left, right, top, or bottom).
- Measure out an `amount` from that edge.
- Everything from the `edge` to the measured `amount` is stored in the rectangle referenced in the `slice` argument.
- The rest of the original rectangle is stored in the `remainder` out argument.

> Don't fret about the `UnsafeMutablePointer<CGRect>` in the Swift version; those pointers act just like `inout` properties in this case. Create your slice and remainder instances up-front, and prefix with an `&` in the call. Or better yet, use the instance method on an existing `CGRect`:
>
> `let (slice, remainder) = frame.divide(120, fromEdge: .MinXEdge)`

That `edge` argument takes a value from the `CGRectEdge` enum:

~~~{swift}
enum CGRectEdge {
   case MinXEdge
   case MinYEdge
   case MaxXEdge
   case MaxYEdge
}
~~~
~~~{objective-c}
enum CGRectEdge {
   CGRectMinXEdge,
   CGRectMinYEdge,
   CGRectMaxXEdge,
   CGRectMaxYEdge
}
~~~

`CGRectDivide` is perfect for dividing up available space among several views (call it on subsequent `remainder` amounts to accommodate more than two views). Give it a try next time you're manually laying-out a `UITableViewCell`.

---

So what if you didn't pay attention in Geometry class—this is the real world, and in the real world, you have `CGGeometry.h`.

Know it well, and you'll be on your way to discovering great new user interfaces in your apps. Do good enough of a job with that, and you may run into the greatest arithmetic problem of all: adding up all of the money you'll make with your awesome new app. Mathematical!

[1]: https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html#//apple_ref/doc/uid/TP30001066
