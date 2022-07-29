---
title: UIStackView
author: Reda Lemeden
category: Cocoa
excerpt: >-
  Many of us reserve stack views for only the most mundane layouts in iOS.
  But learn of their myriad capabilities, 
  and you'll come to scoff at the idea of 
  fiddling with Auto Layout constraints yourself ever again.
status:
  swift: 5.0
---

When I was a student in Japan,
I worked part-time at a restaurant ---
<ruby lang="ja">
<rb>アルバイト</rb>
<rp>(</rp><rt>arubaito</rt><rp>)</rp>
</ruby> as the locals call it ---
where I was tasked with putting away dishes during downtime.
Every plate had to be stacked neatly,
ready to serve as the canvas for the next gastronomic creation.
Lucky for me,
the universal laws of physics came in quite handy ---
all I had to do was pile things up, rather indiscriminately, and move on to the next task.

In contrast,
iOS developers often have to jump through several conceptual hoops when laying out user interfaces.
After all,
placing things in an upside-down 2D coordinate system is not intuitive for anyone but geometry geeks;
for the rest of us, it's not that cut and dried.

But wait ---
_what if we could take physical world concepts like gravity and elasticity
and appropriate them for UI layouts?_

As it turns out,
there has been no shortage of attempts to do so since the early years of
<abbr title="Graphical User Interfaces">GUIs</abbr>
and personal computing ---
Motif's [`XmPanedWindow`](http://www.vaxination.ca/motif/XmPanedWind_3X.html) and Swing's [`BoxLayout`](https://docs.oracle.com/javase/tutorial/uiswing/layout/box.html) are notable early specimens.
These widgets are often referred to as _stack-based layouts_,
and three decades later,
they are alive and well on all major platforms,
including Android's `LinearLayout` and CSS _flexbox_,
as well as Apple's own `NSStackView`, `UIStackView`, and ---
new in SwiftUI ---
`HStack`, `VStack`, and `ZStack`.

This week on NSHipster,
we invite you to enjoy a multi-course course
detailing the most delicious morsels
of this most versatile of layout APIs: `UIStackView`.

---

## <small><em lang="fr">Hors-d'œuvres</em> 🍱</small> Conceptual Overview

Stacking layout widgets come in a wide variety of flavors.
Even so, they all share one common ingredient:
leaning on our intuition of the physical world to keep the configuration layer as thin as possible.
The result is a _declarative_ API that doesn't concern the developer with the minutiæ of view placement and sizing.

If stacking widgets were stoves,
they'd have two distinct sets of knobs:

- Knobs that affect the _items it contains_
- Knobs that affect the _stack container itself_

Together, these knobs describe how the available space is allotted;
whenever a new item is added,
the stack container recalculates the size and placement of all its contained items,
and then lets the rendering pipeline take care of the rest.
In short,
the <em lang="fr">raison d’être</em> of any stack container is to ensure that all its child items get a slice of the two-dimensional,
rectangular pie.

{% info %}

Despite what their name might imply,
stack views don't exhibit any conventional stacking behaviors (push, pop, etc.).
Items can be inserted in and removed from any position.
To avoid this potential misrepresentation, other platforms often talk about _packing_ or _aligning_, instead of _stacking_.

{% endinfo %}

---

## <small>Appetizer 🥗</small> UIStackView Essentials

Introduced in iOS 9,
`UIStackView` is the most recent addition to the UI control assortment in Cocoa Touch.
On the surface,
it looks similar to its older AppKit sibling, the `NSStackView`,
but upon closer inspection,
the differences between the two become clearer.

{% info %}

Throughout this article,
we occasionally mention other implementations to highlight some of `UIStackView`'s own features and limitations.
While the APIs may differ, the underlying concepts are the same.

{% endinfo %}

### Managing Subviews

In iOS, the subviews managed by the stack view are referred to as the _arranged subviews_.
You can initialize a stack view with an array of arranged subviews,
or add them one by one after the fact. Let's imagine that you have a set of magical plates, the kind that can change their size at will:

```swift
let saladPlate = UIView(<#...#>)
let appetizerPlate = UIView(<#...#>)

let plateStack = UIStackView(arrangedSubviews: [saladPlate, appetizerPlate])

// or

let sidePlate = UIView(<#...#>)
let breadPlate = UIView(<#...#>)

let anotherPlateStack = UIStackView(<#...#>)

anotherPlateStack.addArrangedSubview(sidePlate)
anotherPlateStack.addArrangedSubview(breadPlate)

// Use the `arrangedSubviews` property to retrieve the plates
anotherPlateStack.arrangedSubviews.count // 2
```

You can also insert subviews at a specific index:

```swift
let chargerPlate = UIView(<#...#>)
anotherPlateStack.insertArrangedSubview(chargerPlate, at: 1)
anotherPlateStack.arrangedSubviews.count // 3
```

{% warning %}
Stack views don't have an intrinsic content size, so you must set it either implicitly with Auto Layout constraints or explicitly via its `intrinsicContentSize` property. When nested in a scroll view,
constraints between the stack view and the view containing the scroll view are necessary for things to work as expected.
{% endwarning %}

Adding an arranged view using any of the methods above also makes it a subview of the stack view.
To remove an arranged subview that you no longer want around,
you need to call `removeFromSuperview()` on it.
The stack view will automatically remove it from the arranged subview list.
In contrast,
calling `removeArrangedSubview(_ view: UIView)` on the stack view will only remove the view passed as a parameter from the arranged subview list,
without removing it from the subview hierarchy.
Keep this distinction in mind if you are modifying the stack view content during runtime.

```swift
plateStack.arrangedSubviews.contains(saladPlate) // true
plateStack.subviews.contains(saladPlate) // true

plateStack.removeArrangedSubview(saladPlate)

plateStack.arrangedSubviews.contains(saladPlate) // false
plateStack.subviews.contains(saladPlate) // true

saladPlate.removeFromSuperview()

plateStack.arrangedSubviews.contains(saladPlate) // false
plateStack.subviews.contains(saladPlate) // false
```

### Toggling Subview Visibility

One major benefit of using stack views over custom layouts is their built-in support for toggling subview visibility without causing layout ambiguity;
whenever the `isHidden` property is toggled for one of the arranged subviews,
the layout is recalculated,
with the possibility to animate the changes inside an animation block:

```swift
UIView.animate(withDuration: 0.5, animations: {
  plateStack.arrangedSubviews[0].isHidden = true
})
```

This feature is particularly useful when the stack view is part of a reusable view such as table and collection view cells;
not having to keep track of which constraints to toggle is a bliss.

Now, let's resume our plating work, shall we?
With everything in place, let's see what can do with our arranged plates.

### Arranging Subviews Horizontally and Vertically

The first stack view property you will likely interact with is the `axis` property.
Through it you can specify the orientation of the <dfn>main axis</dfn>,
that is the axis along which the arranged subviews will be stacked.
Setting it to either `horizontal` or `vertical` will force all subviews to fit into a single row or a single column,
respectively.
This means that stack views in iOS do not allow overflowing subviews to wrap into a new row or column,
unlike other implementations such CSS _flexbox_ and its `flex-wrap` property.

{% info %}

This property is often called `orientation` in other platforms,
including Apple's own `NSStackView`.
Notwithstanding,
both iOS and macOS use `vertical`/`horizontal` for the values,
instead of the less intuitive `row`/`column` that you may come across elsewhere.

{% endinfo %}

The orientation that is _perpendicular_ to the main axis is often referred to as the <dfn>cross axis</dfn>.
Even though this distinction is not explicit in the official documentation,
it is one of the main ingredients in any stacking algorithm ---
without it, any attempt at explaining how stack views work will be half-baked.

{::nomarkdown}

<figure>
{% asset uistackview-axes.svg @inline %}
<figcaption hidden>Stack view axes in horizontal and vertical orientations.</figcaption>
</figure>

{:/}

The default orientation of the main axis in iOS is _horizontal_;
not ideal for our dishware, so let's fix that:

```swift
plateStack.axis = .vertical
```

<em lang="fr">Et voilà</em>!

---

## <small><em lang="fr">Entrée</em> 🍽</small> Configuring the Layout

When we layout views,
we're accustomed to thinking in terms of _origin_ and _size_.
Working with stack views, however, requires us to instead think in terms of _main axis_ and _cross axis_.

Consider how a horizontally-oriented stack view works.
To determine the width _and_ the `x` coordinate of the origin for each of its arranged subviews,
it refers to a set of properties that affect layout across the horizontal axis.
Likewise, to determine the height and the `y` coordinate,
it refers to another set of properties that affects the vertical axis.

The `UIStackView` class provides axis-specific properties to define the layout: `distribution` for the main axis, and `alignment` for the cross axis.

{% info %}

This pattern is shared among many modern implementations of stacking layouts.
For instance,
CSS _flexbox_ uses `justify-content` for the main axis and `align-items` for the cross axis.
Though not all implementations follow this axis-based paradigm; Android's `LinearLayout`, for example, uses `gravity` for item positioning and `layout_weight` for item sizing along both axes.

{% endinfo %}

### The Main Axis: Distribution

The position and size of arranged subviews along the main axis is affected in part by the value of the `distribution` property,
and in part by the sizing properties of the subviews themselves.

In practice, each distribution option will determine how space along the main axis is _distributed_ between the subviews.
With all distributions,
save for `fillEqually`, the stack view attempts to find an optimal layout based on the intrinsic sizes of the arranged subviews.
When it can't fill the available space, it stretches
the arranged subview with the the lowest _content hugging priority_.
When it can't fit all the arranged subviews,
it shrinks the one with the lowest _compression resistance priority_.
If the arranged subviews share the same value for content hugging and compression resistance,
the algorithm will determine their priority based on their indices.

{% info %}

Some implementations such as CSS _flexbox_ allow setting the weights for each subview manually,
using the `flex-basis` property.
In iOS, setting a custom proportional distribution requires additional constraints between the subviews.

{% endinfo %}

With that out of the way, let's take a look at the possible outcomes,
starting with the distributions that prioritize preserving the intrinsic content size of each arranged subview:

- `equalSpacing`: The stack view gives every arranged subview its intrinsic size alongside the main axis, then introduces equally-sized paddings if there is extra space.
- `equalCentering`: Similar to `equalSpacing`, but instead of spacing subviews equally, a variably sized padding is introduced in-between so as the center of each subview alongside the axis is equidistant from the two adjacent subview centers.

{::nomarkdown}

<figure>
{% asset uistackview-intrinsic-size-distribution.svg @inline %}
<figcaption hidden>Examples of <code>equalSpacing</code> and <code>equalCentering</code> in both horizontal and vertical orientations. The dashed lines and values between parentheses represent the intrinsic sizes of each subview.</figcaption>
</figure>

{:/}

In contrast, the following distributions prioritize filling the stack container, regardless of the intrinsic content size of its subviews:

- `fill` (default): The stack view ensures that the arranged subviews fill _all_ the available space. The rules mentioned above apply.
- `fillProportionally`: Similar to `fill`, but instead of resizing a single view to fill the remaining space, the stack view proportionally resizes all subviews based on their intrinsic content size.
- `fillEqually`: The stack view ensures that the arranged views fill all the available space _and_ are all the same size along the main axis.

{::nomarkdown}

<figure>
{% asset uistackview-fill-distribution.svg @inline %}
<figcaption hidden>Examples of fill distributions in both horizontal and vertical orientations.</figcaption>
</figure>

{:/}

{% info %}

Unlike `NSStackView`, `UIStackView` doesn't support gravity-based distribution.
This solution works by defining gravity areas along the main axis, and placing arranged items in any of them.
One obvious upside of this approach is the ability to have multiple alignment rules within the same axis.
On the downside,
it introduces unnecessary complexity for most use cases.

Without gravity areas,
there is effectively no way for a `UIStackview` to stack its arranged subviews towards one end of the main axis ---
a feature that is fairly common elsewhere,
as is the case with the `flex-start` and `flex-end` values in _flexbox_.

{% endinfo %}

### The Cross Axis: Alignment

The third most important property of `UIStackView` is `alignment`.
Its value affects the positioning and sizing of arranged subviews along the cross axis.
That is, the Y axis for horizontal stacks,
and X axis for vertical stacks.
You can set it to one of the following values for both vertical and horizontal stacks:

- `fill` (default): The stack view ensures that the arranged views fill _all_ the available space on the cross axis.
- `leading`/`trailing`: All subviews are aligned to the leading or trailing edge of the stack view along the cross axis. For horizontal stacks, these correspond to the top edge and bottom edge respectively. For vertical stacks, the language direction will affect the outcome: in left-to-right languages the leading edge will correspond to the left, while the trailing one will correspond to the right. The reverse is true for right-to-left languages.
- `center`: The arranged subviews are centered along the cross axis.

For horizontal stacks, four additional options are available, two of which are redundant:

- `top`: Behaves exactly like `leading`.
- `firstBaseline`: Behaves like `top`, but uses the first baseline of the subviews instead of their top anchor.
- `bottom`: Behaves exactly like `trailing`.
- `lastBaseline`: Behaves like `bottom`, but uses the last baseline of the subviews instead of their bottom anchor.

{% error %}
Using `firstBaseline` and `lastBaseline` on vertical stacks produces unexpected results. This is a clear shortcoming of the API and a direct result of introducing orientation-specific values to an otherwise orientation-agnostic property.
{% enderror %}

Coming back to our plates,
let's make sure that they fill the available vertical space, all while saving the unused horizontal space for other uses ---
remember, these can shape-shift!

```swift
plateStack.distribution = .fill
plateStack.alignment = .leading
```

## <small>Palate Cleanser 🍧</small> Background Color

Another quirk of stack views in iOS is that they don't directly support setting a background color. You have to go through their backing layer to do so.

```swift
plateStack.layer.backgroundColor = UIColor.white.cgColor
```

Alright, we've come quite far,
but have a couple of things to go over before our <em lang="fr">dégustation</em> is over.

---

## <small>Dessert 🍮</small> Spacing & Auto Layout

By default,
a stack view sets the spacing between its arranged subviews to zero.
The value of the `spacing` property is treated as an _exact value_ for distributions that attempt to fill the available space
(`fill`, `fillEqually`, `fillProportionally`),
and as a _minimum value_ otherwise (`equalSpacing`, `equalCentering`).
With fill distributions, negative spacing values cause the subviews to overlap and the last subview to stretch, filling the freed up space.
Negative `spacing` values have no effect on equal centering or spacing distributions.

```swift
plateStack.spacing = 2 // These plates can float too!
```

The spacing property applies equally between each pair of arranged subviews.
To set an explicit spacing between two particular subviews,
use the `setCustomSpacing(:after:)` method instead.
When a custom spacing is used alongside the `equalSpacing` distribution,
it will be applied on all views,
not just the one specified in the method call.

To retrieve the custom space later on, `customSpacing(after:)` gives that to you on a silver platter.

```swift
plateStack.setCustomSpacing(4, after: saladPlate)
plateStack.customSpacing(after: saladPlate) // 4
```

{% info %}

When trying to retrieve a non-existent custom spacing, the method will peculiarly return `Float.greatestFiniteMagnitude` (3.402823e+38) instead.

{% endinfo %}

You can apply insets to your stack view
by setting its `isLayoutMarginsRelativeArrangement` to `true` and assigning a new value to `layoutMargins`.

```swift
plateStack.isLayoutMarginsRelativeArrangement = true
plateStack.layoutMargins = UIEdgeInsets(<#...#>)
```

Sometimes you need more control over the sizing and placement of an arranged subview.
In those cases,
you may add custom constraints on top of the ones generated by the stack view.
Since the latter come with a priority of 1000,
make sure all of your custom constraints use a priority of 999 or less to avoid unsatisfiable layouts.

```swift
let constraint = saladPlate.widthAnchor.constraint(equalToConstant: 200)
constraint.priority = .init(999)
constraint.isActive = true
```

For vertical stack views,
the API lets you calculate distances from the subviews' baselines,
in addition to their top and bottom edges.
This comes in handy when trying to maintain a vertical rhythm in text-heavy UIs.

```swift
plateStack.isBaselineRelativeArrangement = true // Spacing will be measured from the plates' lips, not their wells.
```

### <em lang="fr">L’addition s’il vous plaît!</em>

The automatic layout calculation that stack views do for us come with a performance cost.
In most cases,
it is negligible.
But when stack views are nested more than two layers deep,
the hit could become noticeable.

To be on the safe side,
avoid using deeply nested stack views,
especially in reusable views such as table and collection view cells.

## <small>After Dinner Mint 🍬</small> SwiftUI Stacks

With the introduction of SwiftUI during last month's WWDC,
Apple gave us a sneak peek at how we will be laying out views in the months and years to come:
`HStack`, `VStack`, and `ZStack`.
In broad strokes,
these views are specialized stacking views where the main axis is pre-defined for each subtype and the alignment configuration is restricted to the corresponding cross axis.
This is a welcome change that alleviates the `UIStackView` API shortcomings highlighted towards the end of cross axis section above.
There are more interesting tidbits to go over, but we will leave that for another banquet.

---

Stack views are a lot more versatile than they get credit for.
Their API on iOS isn't always the most self-explanatory,
nor is it the most coherent,
but once you overcome these hurdles,
you can bend them to your will to achieve non-trivial feats ---
nothing short of a Michelin star chef boasting their plating prowess.
