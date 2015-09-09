---
title: KVC Collection Operators
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Rubyists laugh at Objective-C’s bloated syntax. Although we lost a few pounds over the summer with our sleek new object literals, those Red-headed bullies still taunt us with their map one-liners and their fancy Symbol#to_proc. Fortunately, Key-Value Coding has an ace up its sleeves."
status:
    swift: t.b.c.
    reviewed: August 12, 2015
---

Rubyists laugh at Objective-C's bloated syntax.

Although we lost a few pounds over the summer with our [sleek new object literals](http://nshipster.com/at-compiler-directives/), those Red-headed bullies still taunt us with their `map` one-liners and their fancy [`Symbol#to_proc`](http://pragdave.me/blog/2005/11/04/symboltoproc/).

Really, a lot of how elegant (or clever) a language is comes down to how well it avoids loops. `for`, `while`; even [fast enumeration expressions](http://nshipster.com/enumerators/) are a drag. No matter how you sugar-coat them, loops will be a block of code that does something that is much simpler to describe in natural language.

"get me the average salary of all of the employees in this array", versus...

~~~{objective-c}
double totalSalary = 0.0;
for (Employee *employee in employees) {
  totalSalary += [employee.salary doubleValue];
}
double averageSalary = totalSalary / [employees count];
~~~

Meh.

Fortunately, [Key-Value Coding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) gives us a much more concise--almost Ruby-like--way to do this:

~~~{objective-c}
[employees valueForKeyPath:@"@avg.salary"];
~~~

[KVC Collection Operators](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/CollectionOperators.html) allows actions to be performed on a collection using key path notation in `valueForKeyPath:`. Any time you see `@` in a key path, it denotes a particular aggregate function whose result can be returned or chained, just like any other key path.

Collection Operators fall into one of three different categories, according to the kind of value they return:

- **Simple Collection Operators** return strings, numbers, or dates, depending on the operator.
- **Object Operators** return an array.
- **Array and Set Operators** return an array or set, depending on the operator.

The best way to understand how these work is to see them in action. Consider a `Product` class, and a `products` array with the following data:

~~~{objective-c}
@interface Product : NSObject
@property NSString *name;
@property double price;
@property NSDate *launchedOn;
@end
~~~

> Key-Value Coding automatically boxes and un-boxes scalars into `NSNumber` or `NSValue` as necessary to make everything work.

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Price</th>
      <th>Launch Date</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>iPhone 5</td>
      <td>$199</td>
      <td>September 21, 2012</td>
    </tr>
    <tr>
      <td>iPad Mini</td>
      <td>$329</td>
      <td>November 2, 2012</td>
    </tr>
    <tr>
      <td>MacBook Pro</td>
      <td>$1699</td>
      <td>June 11, 2012</td>
    </tr>
    <tr>
      <td>iMac</td>
      <td>$1299</td>
      <td>November 2, 2012</td>
    </tr>
  </tbody>
</table>

### Simple Collection Operators

- `@count`: Returns the number of objects in the collection as an `NSNumber`.
- `@sum`: Converts each object in the collection to a `double`, computes the sum, and returns the sum as an `NSNumber`.
- `@avg`: Takes the `double` value of each object in the collection, and returns the average value as an `NSNumber`.
- `@max`: Determines the maximum value using `compare:`. Objects must support comparison with one another for this to work.
- `@min`: Same as `@max`, but returns the minimum value in the collection.

_Example_:

~~~{objective-c}
[products valueForKeyPath:@"@count"]; // 4
[products valueForKeyPath:@"@sum.price"]; // 3526.00
[products valueForKeyPath:@"@avg.price"]; // 881.50
[products valueForKeyPath:@"@max.price"]; // 1699.00
[products valueForKeyPath:@"@min.launchedOn"]; // June 11, 2012
~~~

> Pro Tip: To get the aggregate value of an array or set of `NSNumber`s, you can simply pass `self` as the key path after the operator, e.g. `[@[@(1), @(2), @(3)] valueForKeyPath:@"@max.self"]` (/via [@davandermobile](http://twitter.com/davandermobile), citing [Objective Sea](http://objectivesea.tumblr.com/post/34552840247/max-value-nsset-kvc))

### Object Operators

Let's say we have an `inventory` array, representing the current stock of our local Apple store (which is running low on iPad Mini, and doesn't have the new iMac, which hasn't shipped yet):

~~~{objective-c}
NSArray *inventory = @[iPhone5, iPhone5, iPhone5, iPadMini, macBookPro, macBookPro];
~~~

- `@unionOfObjects` / `@distinctUnionOfObjects`: Returns an array of the objects in the property specified in the key path to the right of the operator. `@distinctUnionOfObjects` removes duplicates, whereas `@unionOfObjects` does not.

_Example_:

~~~{objective-c}
[inventory valueForKeyPath:@"@unionOfObjects.name"]; // "iPhone 5", "iPhone 5", "iPhone 5", "iPad Mini", "MacBook Pro", "MacBook Pro"
[inventory valueForKeyPath:@"@distinctUnionOfObjects.name"]; // "iPhone 5", "iPad Mini", "MacBook Pro"
~~~

### Array and Set Operators

Array and Set Operators are similar to Object Operators, but they work on collections of `NSArray` and `NSSet`.

This would be useful if we were to, for example, compare the inventory of several stores, say `appleStoreInventory`, (same as in the previous example) and `verizonStoreInventory` (which sells iPhone 5 and iPad Mini, and has both in stock).

- `@distinctUnionOfArrays` / `@unionOfArrays`: Returns an array containing the combined values of each array in the collection, as specified by the key path to the right of the operator. As you'd expect, the `distinct` version removes duplicate values.
- `@distinctUnionOfSets`: Similar to `@distinctUnionOfArrays`, but it expects an `NSSet` containing `NSSet` objects, and returns an `NSSet`. Because sets can't contain duplicate values anyway, there is only the `distinct` operator.

_Example_:

~~~{objective-c}
[@[appleStoreInventory, verizonStoreInventory] valueForKeyPath:@"@distinctUnionOfArrays.name"]; // "iPhone 5", "iPad Mini", "MacBook Pro"
~~~

---

## This is Probably a Terrible Idea

Curiously, [Apple's documentation on KVC collection operators](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/CollectionOperators.html) goes out of its way to make the following point:

> **Note**: It is not currently possible to define your own collection operators.

This makes sense to spell out, since that's what most people are thinking about once they see collection operators for the first time.

However, as it turns out, it _is_ actually possible, with a little help from our friend, `objc/runtime`.

[Guy English](https://twitter.com/gte) has a [pretty amazing post](http://kickingbear.com/blog/archives/9) wherein he [swizzles `valueForKeyPath:`](https://gist.github.com/4196641#file_kb_collection_extensions.m) to parse a custom-defined [DSL](http://en.wikipedia.org/wiki/Domain-specific_language), which extends the existing offerings to interesting effect:

~~~{objective-c}
NSArray *names = [allEmployees valueForKeyPath: @"[collect].{daysOff<10}.name"];
~~~

This code would get the names of anyone who has taken fewer than 10 days off (to remind them to take a vacation, no doubt!).

Or, taken to a ridiculous extreme:

~~~{objective-c}
NSArray *albumCovers = [records valueForKeyPath:@"[collect].{artist like 'Bon Iver'}.<NSUnarchiveFromDataTransformerName>.albumCoverImageData"];
~~~

Eat your heart out, Ruby. This one-liner filters a record collection for artists whose name matches "Bon Iver", and initializes an `NSImage` from the album cover image data of the matching albums.

Is this a good idea? Probably not. (`NSPredicate` is rad, and breaking complicated logic up is under-rated)

Is this insanely cool? You bet! This clever example has shown a possible direction for future Objective-C DSLs and meta-programming.

---

KVC Collection Operators are a must-know for anyone who wants to save a few extra lines of code and look cool in the process.

While scripting languages like Ruby boast considerably more flexibility in its one-liner capability, perhaps we should take a moment to celebrate the restraint built into Objective-C and Collection Operators. After all, Ruby is hella slow, amiright? &lt;/troll&gt;
