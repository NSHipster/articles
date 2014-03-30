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

幸运地是，Quartz 带来了一批好用的函数，减少了本应该我们自己做的浮点数学运算。即使 Cocoa 中视图编程非常重要，即使这些函数都非常有用，但它们对于大部分 iOS 开发者说来仍是相对陌生的。

这个情况不会持续太久！让我们来让这些有用的函数绽放光芒，并减少你敲键的次数！

---

变换
---------------

我们的列表中的第一个是几何变换。这些函数返回在传入的矩形中做某些特定操作后的 `CGRect` 

### `CGRectOffset`

> `CGRectOffset`: 返回一个原点在源矩形基础上进行了偏移的矩形。

~~~{objective-c}
CGRect CGRectOffset(
  CGRect rect,
  CGFloat dx,
  CGFloat dy
)
~~~

注意，用这个你只改变了矩形的原点。它不仅能让你在同时改变水平和垂直位置的时候减少一行代码，更重要的是，它所表示的平移比直接分开操作原点的值更具有几何意义。

### `CGRectInset`

> `CGRectInset`: 返回一个与源矩形共中心点的，或大些或小些的新矩形。

~~~{objective-c}
CGRect CGRectInset(
  CGRect rect,
  CGFloat dx,
  CGFloat dy
)
~~~

想一个视图中的视图更好看吗？用`CGRectInset`给它设置一个 10pt 的边距吧。需要记住的是，矩形将围绕它的中心点进行缩放，左右分别增减`dx`（总共`2 x dx`），上下分别增减 `dy`（总共 `2 x dy`）。

如果你用 `CGRectInset` 作为缩放矩形的快捷方法，一般通用的做法是嵌套调用`CGRectOffset`，把`CGRectInset`的返回值作为`CGRectOffset`的参数。

### `CGRectIntegral`

> `CGRectIntegral`: 返回包围源矩形的最小整数矩形。

~~~{objective-c}
CGRect CGRectIntegral (
  CGRect rect
)
~~~

将`CGRect` 取整到最近的完整点是非常重要的。小数值会让边框画在_像素边界_处。因为像素已经是最小单元（不能再细分），小数值会使绘制时取周围几个像素的平均值，这样看起来就模糊了。

`CGRectIntegral` 将表示原点的值向下取整，表示大小的值向上取整，这样就保证了你的绘制代码平整地对齐到像素边界。

作为一个经验性的原则，如果你在执行任何一个可能产生小数值的操作（例如除法，`CGGetMid[X|Y]`，或是 `CGRectDivide`），在把一矩形作为视图的边框之前应该用`CGRectIntegral`正则化它。

> 从技术上讲，坐标系讲的是点，而视网膜屏一个点中有四个像素，所以它在奇数像素`± 0.5f`处绘制也不会产生模糊。

取值辅助函数
----------------------

这些函数提供了取特定`CGRect`的有意思的尺寸值的便捷方法。

### `CGRectGet[Min|Mid|Max][X|Y]`

- `CGRectGetMinX`
- `CGRectGetMinY`
- `CGRectGetMidX`
- `CGRectGetMidY`
- `CGRectGetMaxX`
- `CGRectGetMaxY`

这六个函数返回矩形`x`或`y`的最小、中间或最大值，原型如下：

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

综上所述，如果你不重视 Geometry 类的话将会怎样——这就是真实的世界，在这个真实世界里，你有 `CGGeometry.h`。

很好地了解它之后，你将启程在你的应用中发掘出超棒的新界面。Know it well, and you'll be on your way to discovering great new user interfaces in your apps. Do good enough of a job with that, and you may run into the greatest arithmetic problem of all: adding up all of the money you'll make with your awesome new app. Mathematical!

[1]: https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html#//apple_ref/doc/uid/TP30001066
