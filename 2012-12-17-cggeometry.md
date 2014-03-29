---
layout: post
title: CGGeometry
translator: Ricky Tan
ref: "https://developer.apple.com/library/mac/#documentation/graphicsimaging/reference/CGGeometry/Reference/reference.html"
framework: CoreGraphics
rating: 8.0
published: true
description: "除非你是个数学极客或者一个古希腊人，否则几何学应该不是你高中时最喜欢的课程。不过你仍有机会成为那个在课堂上尽职尽责地将所有必要的公式的程序写到你的TI-8X计算器里的那个人。为了保持尽可能少地做数学问题的传统，这里列出了一些半复杂的 CoreGraphics 函数使你的工作更简单。"
---

除非你是一个数学极客或者一个古希腊人，否则几何学应该不是你高中时最喜欢的课程。不过你仍有机会成为那个在课堂上尽职尽责地将所有必要的公式的程序写到你的TI-8X计算器里的那个人。

这里有一个描述[Quartz 2D][1]中的几何，还有 iOS 和 Mac OS X 中的绘制系统如何工作的备忘录，专为那些在学习 TI-BASIC 上花的时间多于欧氏几何的人准备的：

- `CGPoint` 是个表示二维坐标系中的点的结构体。在 iOS中，坐标原点在左上方，所以向右和向下分别表示 `x` 和 `y` 的正方向。相反，在 OS X 中 `(0, 0)` 在左下方， `y` 的正方向朝上。

- `CGSize` 是个表示`长` 和`宽` 的结构体。

- `CGRect` 是个包含一个 `CGPoint` （`原点`）和一个 `CGSize` （`大小`）的结构体，表示一个在 `原点` 处画 `大小` 中表示的 `长` 和 `宽` 的矩形。

正因为 `CGRect` 用于表示屏幕上绘制的所有视图的 `frame`，一个程序员操作矩形几何体的能力决定着他在图形编程上的成功。

Fortunately for us, Quartz comes with a slew of useful functions to reduce the amount of floating point math we have to do ourselves. As central as view programming is to Cocoa, and as useful as these functions are, however, they remain relatively unknown to most iOS developers.

This will not stand! Let's shine some light on the most useful functions and save y'all some typing!

---

Transformations
---------------

First on our list are the geometric transformations. These functions return a `CGRect`, which is the result of performing a particular set of operations on the passed rectangle.

### `CGRectOffset`

> `CGRectOffset`: Returns a rectangle with an origin that is offset from that of the source rectangle.

~~~{objective-c}
CGRect CGRectOffset(
  CGRect rect,
  CGFloat dx,
  CGFloat dy
)
~~~

Consider using this anytime you're changing the origin of a rectangle. Not only can it save a line of code when changing both the horizontal and vertical position, but more importantly, it represents the translation more semantically than manipulating the origin values individually. 

### `CGRectInset`

> `CGRectInset`: Returns a rectangle that is smaller or larger than the source rectangle, with the same center point.

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

> `CGRectIntegral`: Returns the smallest rectangle that results from converting the source rectangle values to integers.

~~~{objective-c}
CGRect CGRectIntegral (
  CGRect rect
)
~~~

It's important that `CGRect` values all are rounded to the nearest whole point. Fractional values cause the frame to be drawn on a _pixel boundary_. Because pixels are atomic units (cannot be subdivided†) a fractional value will cause the drawing to be averaged over the neighboring pixels, which looks blurry.

`CGRectIntegral` will `floor` each origin value, and `ceil` each size value, which will ensure that your drawing code will crisply align on pixel boundaries.

As a rule of thumb, if you are performing any operations that could result in fractional point values (e.g. division, `CGGetMid[X|Y]`, or `CGRectDivide`), use `CGRectIntegral` to normalize rectangles to be set as a view frame.

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

~~~{objective-c}
CGFloat CGRectGet[Min|Mid|Max][X|Y] (
  CGRect rect
)
~~~

These functions will replace code like `frame.origin.x + frame.size.width` with cleaner, more semantically expressive equivalents (especially with the mid and max functions).

### `CGRectGet[Width|Height]`

> `CGRectGetHeight`: Returns the height of a rectangle.

~~~{objective-c}
CGFloat CGRectGetHeight (
   CGRect rect
)
~~~

> `CGRectGetWidth`: Returns the width of a rectangle.

~~~{objective-c}
CGFloat CGRectGetWidth (
   CGRect rect
)
~~~

Much like the previous functions, `CGRectGetWidth` & `CGRectGetHeight` are often preferable to returning the corresponding member of a `CGRect`'s `size`. While it's not extremely competitive in terms of character savings, remember that semantic clarity trumps brevity every time. 

Identities
----------

There are three special rectangle values, each of which have unique properties that are important to know about:

### `CGRectZero`, `CGRectNull`, & `CGRectInfinite`

> - `const CGRect CGRectZero`: A rectangle constant with location (0,0), and width and height of 0. The zero rectangle is equivalent to CGRectMake(0.0f, 0.0f, 0.0f, 0.0f).
> - `const CGRect CGRectNull`: The null rectangle. This is the rectangle returned when, for example, you intersect two disjoint rectangles. **Note that the null rectangle is not the same as the zero rectangle**.
> - `const CGRect CGRectInfinite`: A rectangle that has infinite extent.

`CGRectZero` is perhaps the most useful of all of the special rectangle values. When initializing subviews, their frames are often initialized to `CGRectZero`, deferring their layout to `-layoutSubviews`.

`CGRectNull` is distinct from `CGRectZero`, despite any implied correspondence to `NULL` == `0`. This value is conceptually similar to `NSNotFound`, in that it represents the absence of an expected value. Be aware of what functions can return `CGRectNull`, and be prepared to handle it accordingly, by testing with `CGRectIsNull`.

`CGRectInfinite` is the most exotic of all, and has some of the most interesting properties. It intersects with all points and rectangles, contains all rectangles, and its union with any rectangle is itself. Use `CGRectIsInfinite` to check to see if a rectangle is infinite.

And Finally...
--------------

Behold, the most obscure, misunderstood, and useful of the `CGGeometry` functions: `CGRectDivide`.

## `CGRectDivide`

> `CGRectDivide`: Divides a source rectangle into two component rectangles.

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

That `edge` argument takes a value from the `CGRectEdge` enum:

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

So what if you didn't pay attention in Geometry class--this is the real world, and in the real world, you have `CGGeometry.h`

Know it well, and you'll be on your way to discovering great new user interfaces in your apps. Do good enough of a job with that, and you may run into the greatest arithmetic problem of all: adding up all of the money you'll make with your awesome new app. Mathematical!

[1]: https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html#//apple_ref/doc/uid/TP30001066
