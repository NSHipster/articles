---
title: NSIndexSet
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "NSIndexSet (like its mutable counterpart, NSMutableIndexSet) is a sorted collection of unique unsigned integers. Think of it like an NSRange that supports non-contiguous series. It has wicked fast operations for finding indexes in ranges or set intersections, and comes with all of the convenience methods you'd expect in a Foundation collection class."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

`NSIndexSet` (like its mutable counterpart, `NSMutableIndexSet`) is a sorted collection of unique unsigned integers. Think of it like an `NSRange` that supports non-contiguous series. It has wicked fast operations for finding indexes in ranges or set intersections, and comes with all of the convenience methods you'd expect in a Foundation collection class.

You'll find `NSIndexSet` used throughout the Foundation framework. Anytime a method gets multiple elements from a sorted collection, such as an array or a table view's data source, you can be sure that an `NSIndexSet` parameter will be somewhere in the mix.

If you look hard enough, you may start to find aspects of your data model that could be represented with `NSIndexSet`. For example, AFNetworking uses an index set to represent HTTP response status codes: the user defines a set of "acceptable" codes (in the `2XX` range, by default), and the response is checked by using `containsIndex:`.

---

The Swift standard library includes `PermutationGenerator`, an often-overlooked type that dovetails nicely with `NSIndexSet`. `PermutationGenerator` wraps a collection and a sequence of indexes (sound familiar?) to allow easy iteration:

```swift
let streetscape = ["Ashmead", "Belmont", "Clifton", "Douglas", "Euclid", "Fairmont", 
						"Girard", "Harvard", "Irving", "Kenyon", "Lamont", "Monroe", 
						"Newton", "Otis", "Perry", "Quincy"]

let selectedIndices = NSMutableIndexSet(indexesInRange: NSRange(0...2))
selectedIndices.addIndex(5)
selectedIndices.addIndexesInRange(NSRange(11...13))

for street in PermutationGenerator(elements: streetscape, indices: selectedIndices) {
    print(street)
}
// Ashmead, Belmont, Clifton, Fairmont, Monroe, Newton, Otis
```

Here are a few more ideas to get you thinking in terms of index sets:

- Have a list of user preferences, and want to store which ones are switched on or off? Use a single `NSIndexSet` in combination with an `enum` `typedef`.
- Filtering a list of items by a set of composable conditions? Ditch the `NSPredicate`; instead, cache the indexes of objects that fulfill each condition, and then get the union or intersection of those indexes as conditions are added and removed.

---

Overall, `NSIndexSet` is a solid class. A fair bit nerdier than its collection class siblings, but it has its place. At the very least, it's a prime example of the great functionality that you find by paying attention to what Foundation uses in its own APIs.
