---
title: Swift Collection Protocols
author: Nate Cook
category: Swift
tags: swift
excerpt: "Swift's collection protocols act like the steps on a ladder. With each step up, a collection type gains more functionality within the language and the standard library. This week we'll explore these protocols: what they are, how to conform to them, and what benefits they can provide for your own custom collection types."
hiddenlang: "swift"
status:
    swift: 1.2
---


Swift has a well-designed and expansive suite of built-in collection types. Beyond `Array`, `Dictionary`, and the brand new `Set` types, the standard library provides slices, lazy collections, repeated sequences, and more, all with a consistent interface and syntax for operations. A group of built-in collection protocols—`SequenceType`, `CollectionType`, and several others—act like the steps on a ladder. With each step up, a collection type gains more functionality within the language and the standard library.

By conforming to these protocols, custom collection types can gain access to the same language constructs and powerful top-level functions we use with `Array` and `Dictionary`. This week we'll explore these protocols: what they are, how to conform to them, and what benefits they can provide for your own custom collection types.


* * *


To demonstrate the different protocols, along the way we'll build a new collection type, `SortedCollection`, which keeps its elements in ascending order for simple, always-sorted access. The implementation shown here is deliberately kept minimal—you can only create a collection and insert, remove, or find elements:


```swift
struct SortedCollection<T: Comparable> {
    private var contents: [T] = []
    
    init<S : SequenceType where S.Generator.Element == T>(_ sequence: S) {
        contents = sorted(sequence)
    }
    
    func indexOf(value: T) -> Int? {
        let index = _insertionIndex(contents, forValue: value)
        if index >= contents.count {
            return nil
        }
        return contents[index] == value ? index : nil
    }

    mutating func insert(value: T) {
       contents.insert(value, atIndex: _insertionIndex(contents, forValue: value))
    }
    
    mutating func remove(value: T) -> T? {
        if let index = indexOf(value) {
            return contents.removeAtIndex(index)
        }
        return nil
    }
}

// Note: _insertionIndex is a private function that returns the 
// insertion point for a value in a sorted collection.
```

> A complete implementation of `SortedCollection` [is available as a framework](https://github.com/natecook1000/SortedCollection).

Not too much there! Let's see what kind of functionality we can add by conforming to a few of Swift's collection protocols.


* * *


## SequenceType / GeneratorType

The first two collection protocols are inextricably linked: a *sequence* (a type that conforms to `SequenceType` ) represents a series of values, while a *generator* (conforming to `GeneratorType`, of course) provides a way to use the values in a sequence, one at a time, in sequential order. The `SequenceType` protocol only has one requirement: every sequence must provide a generator from its `generate()` method.

A generator works by providing a single method, namely, `next()`, which simply returns the next value from the underlying sequence. `next()` will continue returning values until there are none left (), at which point it will return `nil`. Note that this may never comes to pass, since sequences aren't necessarily finite. 

Whenever you iterate over a sequence, Swift creates a generator and successively calls its `next()` method. The familiar code `for element in myArray { ... }` is in fact just a nice wrapper for this:

```swift
var generator = myArray.generate()
while let element = generator.next() {
    // do something
}
```

The relationship between the two protocols is asymmetrical. That is, every sequence has a generator, but only some generators are themselves also sequences (which they can become by returning themselves from their `generate()` method). Swift includes a whole host of generators, including one that is perfect for our `SortedCollection` case: the type-erasing `GeneratorOf`. `GeneratorOf` is initialized with either the `next` method implemented as a closure, or another generator:

```swift
extension SortedCollection : SequenceType {
    typealias Generator = GeneratorOf<T>
    
    func generate() -> Generator {
        var index = 0
        return GeneratorOf {
            if index < self.contents.count {
                return self.contents[index++]
            }
            return nil
        }
    }
}
```

Ten lines of code later, we can now use `SortedCollection` with a dozen or so top-level functions, including the bedrock of the functional approach in Swift—`reduce`, `map`, and `filter`. 

> - [`contains`][]: Returns true if (1) a particular given element is found in the sequence or (2) an element satisfies the given predicate closure.
> - [`enumerate`][]: Converts a sequence into a sequence of tuples, where each tuple is made up of a zero-based index and the value at that index in the sequence.
> - [`filter`][]: Converts a sequence to an `Array`, keeping only the elements that match the given predicate closure.
> - [`join`][]: Creates a collection from the sequence, with a given initial collection interposed between each element of the sequence. The initial element must be an `ExtensibleCollectionType`, described below.
> - [`lazy`][]: Creates a "lazy sequence" from the given sequence. Subsequent calls to `map`, `filter`, and `reverse` on the sequence will be evaluated lazily—that is, until you access or iterate over the sequence, none of the transformations will be executed.
> - [`map`][]: Converts a sequence to an `Array` after mapping each element with the transforming closure given.
> - [`maxElement`][]: Returns the maximum value of a sequence of `Comparable` elements.
> - [`minElement`][]: Returns the minimum value of a sequence of `Comparable` elements.
> - [`reduce`][]: Given an initial value and a combining closure, this "reduces" a sequence to a single element through repeated calls to the closure.
> - [`sorted`][]: Returns a sorted `Array` of the sequence's elements. Sorting is automatically ascending for sequences of `Comparable` elements, or it can be based on a comparison closure.
> - [`startsWith`][]: Returns true if one sequence starts with another sequence.
> - [`underestimateCount`][]: Returns an *underestimate* of the number of elements in a sequence (`SequenceType`s give no hints about length, so this will be zero for a sequence). Returns the actual count for `CollectionType` instances.
> - [`zip`][]: Converts two sequences into a sequence of tuples, where each tuple is made up of one element from each sequence.



## CollectionType / MutableCollectionType

A *collection* (a type that conforms to the next collection protocol, `CollectionType`) is a step beyond a sequence in that individual elements of a collection can be accessed multiple times via subscript. A type conforms by providing a subscripted getter for elements, then starting and ending index properties. No infinite collections here! A `MutableCollectionType` adds a setter for the same subscript.

Our `SortedCollection` can easily use `Int` for its index, so conforming to `CollectionType` is straightforward:

```swift
extension SortedCollection : CollectionType {
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return count
    }
    
    subscript(i: Int) -> T {
        return contents[i]
    }
}
```

> Subscripting should always be considered an *O(1)* operation. Types that can't provide efficient subscripted lookups should move the time-consuming work to the process of generating.
> 
> Swift's built-in `String`, for example, lost its `Int`-based subscripting in an early beta. Why? Strings in Swift are fully Unicode-aware, so each visible character may be made up of multiple codepoints. Jumping to an arbitrary index in a string as if it were just an array of characters could land you in the middle of a multi-codepoint sequence, requiring the slightly cumbersome but intuitively *O(n)* use of `startIndex`, `endIndex`, and `advance()`.

Like `SequenceType`, there are a host of global functions that can operate on `CollectionType` instances. Now that the start and end of the collection are known, `count`, `sort`, and other finite operations become available as top-level functions:

> - [`count`][]: Returns the number of elements in a collection.
> - [`find`][]: Returns the first index of a given element in the collection, or `nil` if not found.
> - [`first`][]: Returns the first element in the collection, or `nil` if the collection is empty.
> - [`indices`][]: Returns a `Range` of the collection's indices. Equivalent to `c.startIndex..<c.endIndex`.
> - [`isEmpty`][]: Returns true if the collection has no elements.
> - [`last`][]: Returns the last element in the collection, or `nil` if the collection is empty.
> - [`partition`][]: The primary function used in a *quick sort* (a fast, memory-efficient sorting algorithm). `partition` reorders part of a collection and returns a pivot index, where everything below the pivot is equal to or ordered before the pivot, and everything above the pivot is equal to or ordered after. Partitioning can be based on a comparison closure if the collection's elements themselves are not `Comparable`. Requires `MutableCollectionType`.
> - [`reverse`][]: Returns an `Array` with the elements of the collection in reverse order.
> - [`sort`][]: Sorts a collection in place, modifying the order of the existing collection. Requires `MutableCollectionType`.



## Sliceable / MutableSliceable

Next up, `Sliceable` collections promise *efficient* slicing of a subrange of a collection's elements. That is, getting a slice of a collection should not require allocating new memory for the selected elements. Again, the standard library guides us: `Array` and `ContiguousArray` are the two `Sliceable` types (besides, well, `Slice`), and both share their internal storage with their slices until a mutation occurs. This saves both memory and the time needed to allocate new storage for a temporary slice.

For `SortedCollection` to conform to  `Sliceable`, we need to fulfill that same promise.  Happily, we can reuse our embedded `Array`'s sliceability in a new `SortedSlice` type, this time based on a `Slice<T>` instead of an `Array`: 

```swift
extension SortedCollection : Sliceable {
    typealias SubSlice = SortedSlice<T>
    
    subscript(range: Range<Int>) -> SortedSlice<T> {
        return SortedSlice(sortedSlice: contents[range])
    }
}

// MARK: - SortedSlice

struct SortedSlice<T: Comparable> {
    private var contents: Slice<T> = []

    private init(sortedSlice: Slice<T>) {
        self.contents = sortedSlice
    }
    ...
}
```

> For other custom collections, Swift 1.2 provides a `ManagedBufferPointer` type and an `isUniquelyReferenced` function to help implement the copy-on-write behavior needed for efficient slicing.

`Sliceable`'s mutable counterpart, `MutableSliceable`, allows setting a slice's new contents via subscripting a range of values. Again, mutating by index doesn't comport with `SortedCollections`'s requirement to always maintain ascending order. However, none of the `Sliceable`-ready top-level functions requires mutability:

> - [`dropFirst`][]: Returns a slice with all but the first element of the collection.
> - [`dropLast`][]: Returns a slice with all but the last element of the collection.
> - [`prefix`][]: Returns a slice with the first `x` elements of the collection or the whole collection if `x` is greater than the collection's count.
> - [`split`][]: Returns an `Array` of slices separated by elements that match the given `isSeparator` closure. Optional parameters: a maximum number of splits; a boolean indicating whether empty slices are allowed when consecutive separators are found.
> - [`suffix`][]: Returns a slice with the last `x` elements of the collection or the whole collection if `x` is greater than the collection's count.



## ExtensibleCollectionType / RangeReplaceableCollectionType

Finally, collections that conform to `ExtensibleCollectionType` and `RangeReplaceableCollectionType` provide methods to modify the collection. `ExtensibleCollectionType` requires an empty initializer and three methods: `append` and `extend`, which add a single element and a sequence of elements, respectively, and `reserveCapacity`, which (hopefully) expands the collection's internal storage to allow additions to the collection without repeatedly reallocating memory.

`RangeReplaceableCollectionType` requires six methods that replace or remove a range of elements: `replaceRange(:with:)`, `insert(:atIndex:)`, `splice(:atIndex:)`, `removeAtIndex(:)`, `removeRange(:)`, and `removeAll()`. Conforming types have access to top-level functions that do largely the same:

> - [`extend`][]: Appends the elements of a collection to a given range-replaceable collection.
> - [`insert`][]: Inserts a new element into the collection at a particular index.
> - [`removeAll`][]: Removes all elements from a collection, optionally preserving the collection's internal capacity.
> - [`removeLast`][]: Removes a single element from the end of a collection.
> - [`removeRange`][]: Removes a range of elements from a collection.
> - [`splice`][]: Inserts a sequence of elements at a particular index of a range-replaceable collection.


* * *

## Sorting Out the Oscars

So let's put all this to (popcultural) use. We haven't added any methods to `SortedCollection` other than those required to conform to `SequenceType`, `CollectionType`, and `Sliceable`, but yet we've gained access to many powerful top-level functions.

We start with the guest list of an after-party for some of last night's big winners at the Oscars:

```swift
let attendees = SortedCollection(["Julianne", "Eddie", "Patricia", "J.K.", "Alejandro"])
```

How many attendees? Using `count`:

```swift
println("\(count(attendees)) attendees")
// 5 attendees
```

Suppose I'd like the stars to line up alphabetically for a photo—how can I give them instructions? Using `zip` and `dropFirst`:

```swift
for (firstName, secondName) in zip(attendees, dropFirst(attendees)) {
    println("\(firstName) is before \(secondName)")
}
// Alejandro is before Eddie
// Eddie is before J.K.
// J.K. is before Julianne
// Julianne is before Patricia
```

Lastly, I need the names to be reformatted so I can use them as image file names. Using `map`:

```swift
let imageNames = map(attendees) { $0.lowercaseString }
        .map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) }
        .map { "\($0).jpg" }
// alejandro.jpg
// eddie.jpg
// ...
```

*Voila!* A-list party!


* * *


Without a doubt, part of what makes Swift so fascinating to use is that the language seems largely self-defined. Browse through the standard library and you can see how each type is built—from `Int` and `Double` to `Array`, `Dictionary`, and the new `Set`. With an eye toward building more Swift-native types, follow Swift's example in creating your own!




[`contains`]: http://swiftdoc.org/func/contains/
[`enumerate`]: http://swiftdoc.org/func/enumerate/
[`filter`]: http://swiftdoc.org/func/filter/
[`join`]: http://swiftdoc.org/func/join/
[`lazy`]: http://swiftdoc.org/func/lazy/
[`map`]: http://swiftdoc.org/func/map/
[`maxElement`]: http://swiftdoc.org/func/maxElement/
[`minElement`]: http://swiftdoc.org/func/minElement/
[`reduce`]: http://swiftdoc.org/func/reduce/
[`sorted`]: http://swiftdoc.org/func/sorted/
[`startsWith`]: http://swiftdoc.org/func/startsWith/
[`underestimateCount`]: http://swiftdoc.org/func/underestimateCount/
[`zip`]: http://swiftdoc.org/func/zip/
[`count`]: http://swiftdoc.org/func/count/
[`find`]: http://swiftdoc.org/func/find/
[`first`]: http://swiftdoc.org/func/first/
[`indices`]: http://swiftdoc.org/func/indices/
[`isEmpty`]: http://swiftdoc.org/func/isEmpty/
[`last`]: http://swiftdoc.org/func/last/
[`partition`]: http://swiftdoc.org/func/partition/
[`reverse`]: http://swiftdoc.org/func/reverse/
[`sort`]: http://swiftdoc.org/func/sort/
[`dropFirst`]: http://swiftdoc.org/func/dropFirst/
[`dropLast`]: http://swiftdoc.org/func/dropLast/
[`prefix`]: http://swiftdoc.org/func/prefix/
[`split`]: http://swiftdoc.org/func/split/
[`suffix`]: http://swiftdoc.org/func/suffix/
[`extend`]: http://swiftdoc.org/func/extend/
[`insert`]: http://swiftdoc.org/func/insert/
[`removeAll`]: http://swiftdoc.org/func/removeAll/
[`removeLast`]: http://swiftdoc.org/func/removeLast/
[`removeRange`]: http://swiftdoc.org/func/removeRange/
[`splice`]: http://swiftdoc.org/func/splice/




