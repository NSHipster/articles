---
title: NSExpression
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Cocoa is the envy of other standard libraries when it comes to querying and arranging information. With NSPredicate, NSSortDescriptor, and an occasional NSFetchRequest, even the most complex data tasks can be reduced into just a few, extremely-understandable lines of code."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Cocoa is the envy of other standard libraries when it comes to querying and arranging information. With `NSPredicate`, [`NSSortDescriptor`](http://nshipster.com/nssortdescriptor/), and an occasional `NSFetchRequest`, even the most complex data tasks can be reduced into just a few, _extremely-understandable_ lines of code.

Now, NSHipsters are no doubt already familiar with `NSPredicate` (and if you aren't, be sure to tune in next week!), but if we take a closer look at `NSPredicate`, we see that `NSPredicate` is actually made up of smaller, atomic parts: two `NSExpression`s (a left-hand value & a right-hand value), compared with an operator (e.g. `<`, `IN`, `LIKE`, etc.).

Because most developers only use `NSPredicate` by means of `+predicateWithFormat:`, `NSExpression` is a relatively obscure class. Which is a shame, because `NSExpression` is quite an incredible piece of functionality in its own right.

So allow me, dear readers, to express my respect and fascination with `NSExpression`:

## Evaluating Math

The first thing you should know about `NSExpression` is that it lives to reduce terms. If you think about the process of evaluating an `NSPredicate`, there are two terms and a comparator, so those two terms need to simplify into something that the operator can handle—very much like the process of compiling a line of code.

Which leads us to `NSExpression`'s first trick: **doing math**.

```swift
let mathExpression = NSExpression(format: "4 + 5 - 2**3")
let mathValue = mathExpression.expressionValueWithObject(nil, context: nil) as? Int 
// 1
```
~~~ objective-c
NSExpression *expression = [NSExpression expressionWithFormat:@"4 + 5 - 2**3"];
id value = [expression expressionValueWithObject:nil context:nil]; // => 1
~~~

It's no [Wolfram Alpha](http://www.wolframalpha.com/input/?i=finn+the+human+like+curve), but if your app does anything where evaluating mathematical expressions would be useful, well... there you go.

## Functions

But we've only just scratched the surface with `NSExpression`. Not impressed by a computer doing primary-school maths? How about high school statistics, then?

```swift
let numbers = [1, 2, 3, 4, 4, 5, 9, 11]
let statsExpression = NSExpression(forFunction:"stddev:", arguments:[NSExpression(forConstantValue: numbers)])
let statsValue = statsExpression.expressionValueWithObject(nil, context: nil) as? Double
// 3.21859...
```
~~~ objective-c
NSArray *numbers = @[@1, @2, @3, @4, @4, @5, @9, @11];
NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
id value = [expression expressionValueWithObject:nil context:nil]; // => 3.21859...
~~~

> `NSExpression` functions take a given number of sub-expression arguments. For instance, in the above example, to get the standard deviation of the collection, the array of numbers had to be wrapped with `+expressionForConstantValue:`. A minor inconvenience (which ultimately allows `NSExpression` to be incredibly flexible), but enough to trip up anyone trying things out for the first time.

If you found the [Key-Value Coding Simple Collection Operators](http://nshipster.com/kvc-collection-operators/) (`@avg`, `@sum`, et al.) lacking, perhaps `NSExpression`'s built-in statistical, arithmetic, and bitwise functions will pique your interest.

> **A word of caution**: [according to this table in Apple's documentation for `NSExpression`](http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSExpression_Class/Reference/NSExpression.html), there is apparently no overlap between the availability of functions between OS X & iOS. It would appear that recent versions of iOS do, indeed, support functions like `stddev:`, but this is not reflected in headers or documentation. Any details [in the form of a pull request](https://github.com/NSHipster/articles/pulls) would be greatly appreciated.

### Statistics

- `average:`
- `sum:`
- `count:`
- `min:`
- `max:`
- `median:`
- `mode:`
- `stddev:`

### Basic Arithmetic

These functions take two `NSExpression` objects representing numbers.

- `add:to:`
- `from:subtract:`
- `multiply:by:`
- `divide:by:`
- `modulus:by:`
- `abs:`

### Advanced Arithmetic

- `sqrt:`
- `log:`
- `ln:`
- `raise:toPower:`
- `exp:`

### Bounding Functions

- `ceiling:` - _(the smallest integral value not less than the value in the array)_
- `trunc:` - _(the integral value nearest to but no greater than the value in the array)_

### Functions Shadowing `math.h` Functions

So mentioned, because `ceiling` is easily confused with `ceil(3)`. Whereas `ceiling` acts on an array of numbers, while `ceil(3)` takes a `double` (and doesn't have a corresponding built-in `NSExpression` function). `floor:` here acts the same as `floor(3)`.

- `floor:`

### Random Functions

Two variations—one with and one without an argument. Taking no argument, `random` returns an equivalent of `rand(3)`, while `random:` takes a random element from the `NSExpression` of an array of numbers.

- `random`
- `random:`

### Binary Arithmetic

- `bitwiseAnd:with:`
- `bitwiseOr:with:`
- `bitwiseXor:with:`
- `leftshift:by:`
- `rightshift:by:`
- `onesComplement:`

### Date Functions

- `now`

### String Functions

- `lowercase:`
- `uppercase:`

### No-op

- `noindex:`

## Custom Functions

In addition to these built-in functions, it's possible to invoke custom functions in an `NSExpression`. [This article by Dave DeLong](http://funwithobjc.tumblr.com/post/2922267976/using-custom-functions-with-nsexpression) describes the process.

First, define the corresponding method in a category:

```swift
extension NSNumber {
    func factorial() -> NSNumber {
        return tgamma(self.doubleValue + 1)
    }
}
```
~~~ objective-c
@interface NSNumber (Factorial)
- (NSNumber *)factorial;
@end

@implementation NSNumber (Factorial)
- (NSNumber *)factorial {
    return @(tgamma([self doubleValue] + 1));
}
@end
~~~

Then, use the function thusly (the `FUNCTION()` macro in `+expressionWithFormat:` is shorthand for the process of building out with `-expressionForFunction:`, et al.):

```swift
let functionExpression = NSExpression(format:"FUNCTION(4.2, 'factorial')")
let functionValue = functionExpression.expressionValueWithObject(nil, context: nil) as? Double
// 32.578...
```
~~~ objective-c
NSExpression *expression = [NSExpression expressionWithFormat:@"FUNCTION(4.2, 'factorial')"];
id value = [expression expressionValueWithObject:nil context:nil]; // 32.578...
~~~

The advantage here, over calling `-factorial` directly is the ability to invoke the function in an `NSPredicate` query. For example, a `location:withinRadius:` method might be defined to easily query managed objects nearby a user's current location.

As Dave mentions in his article, the use cases are rather marginal, but it's certainly an interesting trick to have in your repertoire.

---

Next week, we'll build on what we just learned about `NSExpression` to further explore `NSPredicate`, and everything it has hidden up its sleeves. Stay tuned!
