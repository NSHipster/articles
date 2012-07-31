---
layout: post
title: NSIndexSet

ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSSet_Class/Reference/Reference.html"
framework: Foundation
rating: 7.8
---

`NSIndexSet` (and its mutable counterpart, `NSMutableIndexSet`) represents a sorted collection of unique unsigned integers--think of it like an `NSRange` that supports non-contiguous series. It has wicked fast operations to find indexes in ranges or set intersections, and all of the convenience methods you'd expect in a Foundation collection class.

You'll find `NSIndexSet` all throughout the Foundation framework. Anytime a method gets multiple elements from a sorted collection, like an array or a table view, you can be sure that an `NSIndexSet` parameter is in the mix.

If you look hard enough, you may start to find aspects of your data model that could be represented with `NSIndexSet`. For example AFNetworking uses an index set to represent HTTP response status codes: the user defines a set of "acceptable" codes (in the 2XX range, by default), and the response is checked by using `containsIndex:`.

- List of user preference switches to toggle? You could replace that with a single `NSIndexSet` and an `enum`.
- Table view with a dynamic number of pre-defined sections? Same as before: `NSIndexSet` & `enum`, along with a giant `switch` statement.
- Filtering a list of items by a set of composable conditions? Ditch the `NSPredicate`; instead, cache the indexes of objects that fulfill each condition, and then get the union of those indexes as conditions are added and removed.

Overall, `NSIndex` is a solid class. A fair bit nerdier than its collection class siblings, but it has its place. It's at least a good reminder the useful things that you find by paying attention to what Foundation uses in its own APIs.

