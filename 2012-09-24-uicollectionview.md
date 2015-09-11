---
title: UICollectionView
author: Mattt Thompson
category: Cocoa
excerpt: "UICollectionView single-handedly changes the way we will design and develop iOS apps from here on out. This is not to say that collection views are in any way unknown or obscure. But being an NSHipster isn't just about knowing obscure gems in the rough. Sometimes, it's about knowing about up-and-comers before they become popular and sell out."
status:
    swift: 2.0
    reviewed: September 9, 2015
---

`UICollectionView` is the new `UITableView`. It's that important.

This is not to say that collection views are in any way unknown or obscure--anyone who went to any of the WWDC sessions about it, or got to play with in the iOS 6 beta already know what's up.

Remember, being an NSHipster isn't just about knowing obscure gems in the rough. Sometimes, it's about knowing about up-and-comers before they become popular and sell out. So before everybody else finds out for themselves, here's the skinny on the next big thing:

---

`UICollectionView` takes the familiar patterns of `UITableView` and generalizes them to make any layout possible (and, in many cases, trivial).

Like `UITableView`, `UICollectionView` is a `UIScrollView` subclass that manages a collection of ordered items. Items are managed by a _data source_, which provides a representative cell view at a particular index path.

Unlike `UITableView`, however, `UICollectionView` is not constrained to a vertical, single-column layout. Instead, a collection view has a _layout_ object, which determines the position of each subview, similar to a data source in some respects. More on that later.

### Cell Views

In another departure from the old-school table view way of doing things, the process of recycling views has been significantly improved.

In `-tableView:cellForRowAtIndexPath:`, a developer had to invoke the familiar incantation:

~~~{swift}
let identifier = "Cell"
var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
if cell == nil {
    cell = UITableViewCell(...)
}
~~~
~~~{objective-c}
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:...];
if (!cell) {
  cell = [[UITableViewCell alloc] initWithStyle:... reuseIdentifier:...];
}
~~~

`UICollectionView` thankfully does away with this. `-dequeueReusableCellWithReuseIdentifier:forIndexPath:` is guaranteed to return a valid object, by creating a new cell if there are no cells to reuse. Simply register a `UICollectionReusableView` subclass for a particular reuse identifier, and everything will work automatically.

> Thankfully, this behavior has been backported to `UITableView` as well with iOS 6.

### Supplementary Views

Because collection views aren't relegated to any particular structure, the convention of "header" and "footer" views isn't really applicable. So in its place, collection views have _supplementary views_, which can be associated with each cell.

Each cell can have multiple supplementary views associated with it--one for each named "kind". As such, headers and footers are just the beginning of what can be done with supplementary views.

The whole point is that with supplementary views, even the most complex layout can be accomplished without compromising the semantic integrity of cells. `UITableView` hacks are to [`spacer.gif`](http://en.wikipedia.org/wiki/Spacer_GIF) as `UICollectionView` cells are to [semantic HTML](http://en.wikipedia.org/wiki/Semantic_HTML).

### Decoration Views

In addition to cell views and supplementary views, collections also have _decoration views_. A decoration view, as the name implies, is something that without a functional purpose... other than to perhaps [spurn the hatred of anti-skeuomorphic zealots](http://skeu.it) across the interwebs. But really, if you're resigned to imbue your virtual book collection app with immaculately-textured wood-grained shelves, it might as well be easy to do, _right_?

One thing to remember about decoration views is that they are entirely managed by the layout, unlike cell or supplementary views, which are under the jurisdiction of the collection view data source.

## Layouts and Layout Attributes

Layouts are at the heart of what makes `UICollectionView` so magical. Think of them as the CSS to your semantic HTML of collection cells from before.

`UICollectionViewLayout` is an abstract base class for positioning cell views and their supplementary and decoration views. But rather than subclass this directly, most applications will opt to use or subclass `UICollectionViewFlowLayout`. Flow layouts cover the broad class of layouts with some notion of linearity, whether that's a single row or column or a grid.

Until you're comfortable enough to understand the limitations of flow layouts, it's generally a safe bet to just start with that.

Each cell view, supplemental view, and decoration view have layout attributes. To get an idea of how flexible layouts are, look no further than the properties of an `UICollectionViewLayoutAttributes` object:

- `frame`
- `center`
- `size`
- `transform3D`
- `alpha`
- `zIndex`
- `hidden`

Attributes are specified by the kind of delegate methods you might expect:

- `-layoutAttributesForItemAtIndexPath:`
- `-layoutAttributesForSupplementaryViewOfKind:atIndexPath:`
- `-layoutAttributesForDecorationViewOfKind:atIndexPath:`

What's _extremely_ cool is this method here:

- `-layoutAttributesForElementsInRect:`

Using this, you could, for example, fade out items as they approach the edge of the screen. Or, since all of the layout attribute properties are automatically animated, you could create a poor-man's [cover flow](http://en.wikipedia.org/wiki/Cover_Flow) layout in just a couple lines of code with the right set of 3D transforms.

In fact, collection views can even swap out layouts wholesale, allowing views to transition seamlessly between different modes--all without changing the underlying data.

---

Since the introduction of the iPad, there has been a subtle, yet lingering tension between the original UI paradigms of the iPhone, and the demands of this newer, larger form factor. With the iPhone 5 here, and a rumored "iPad mini" on the way, this tension could have threatened to fracture the entire platform, had it not been for `UICollectionView` (as well as Auto-Layout).

There are a million ways Apple could (or could not) have provided this kind of functionality, but they really knocked it out of the park with how they designed everything.

The clean, logical separation between data source and layout; the clear division between cell, supplementary, and decoration views; the extensive set of layout attributes that are automatically animated... a lot of care and wisdom has been put together with these APIs.

As a result, the entire landscape of iOS apps will be forever changed. With collection views, the aesthetic shift that was kicked off with the iPad will explode into an entire re-definition of how we expect apps to look and behave.

Everyone may not be hip to collection views quite yet, but now you'll be able to say that you knew about them before they were cool.
