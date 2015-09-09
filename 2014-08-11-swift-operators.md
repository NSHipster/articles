---
title: Swift Operators
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "Operators in Swift are among the most interesting and indeed controversial features of this new language."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

What would a program be without statements? A mish-mash of classes, namespaces, conditionals, loops, and namespaces signifying nothing.

Statements are what do the work of a program. They are the very execution of an executable.

If we were to take apart a statement—say `1 + 2`—decomposing it into its constituent parts, we would find an operator and operands:

|          1          |          +          |          2          |
|:-------------------:|:-------------------:|:-------------------:|
|     left operand    |       operator      |     right operand   |

Although expressions are flat, the compiler will construct a tree representation, or AST:

![1 + 2 AST](http://nshipster.s3.amazonaws.com/swift-operators-one-plus-two.svg)


Compound statements, like `1 + 2 + 3`

|       (1 + 2)       |          +          |          3          |
|:-------------------:|:-------------------:|:-------------------:|
|     left operand    |       operator      |     right operand   |


![1 + 2 + 3 AST](http://nshipster.s3.amazonaws.com/swift-operators-one-plus-two-plus-three.svg)

Or, to take an even more complex statement, `1 + 2 * 3 % 4`, the compiler would use operator precedence to resolve the expression into a single statement:

|          1          |          +          |       ((2 * 3) % 4)       |
|:-------------------:|:-------------------:|:-------------------------:|
|     left operand    |       operator      |      right operand        |


![1 + 2 * 3 % 4 AST](http://nshipster.s3.amazonaws.com/swift-operators-one-plus-two-times-three-mod-four.svg)

Operator precedence rules, similar to the ones [you learned in primary school](http://en.wikipedia.org/wiki/Order_of_operations), provide a canonical ordering for any compound statement:

```
1 + 2 * 3 % 4
1 + ((2 * 3) % 4)
1 + (6 % 4)
1 + 2
```

However, consider the statement `5 - 2 + 3`. Addition and subtraction have the same operator precedence, but evaluating the subtraction first `(5 - 2) + 3` yields 6, whereas evaluating subtraction after addition, `5 - (2 + 3)`, yields `0`. In code, arithmetic operators are left-associative, meaning that the left hand side will evaluate first (`(5 - 2) + 3`).

Operators can be unary and ternary as well. The `!` prefix operator negates a logical value of the operand, whereas the `++` postfix operator increments the operand. The `?:` ternary operator collapses an `if-else` expression, by evaluating the statement to the left of the `?` in order to either execute the statement left of the `:` (statement is `true`) or right of `:` (statement is `false`).

## Swift Operators

Swift includes a set of operators that should be familiar to C or Objective-C developers, with a few additions (notably, the range and nil coalescing operators):

### Prefix

- `++`: Increment
- `--`: Decrement
- `+`: Unary plus
- `-`: Unary minus
- `!`: Logical NOT
- `~`: Bitwise NOT

### Infix

<table>
    <tr>
        <th colspan="2">Exponentiative <tt>{precedence 160}</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>&lt;&lt;</tt></td><td>Bitwise left shift</td></tr>
        <tr><td><tt>&gt;&gt;</tt></td><td>Bitwise right shift</td></tr>
    </tbody>


    <tr>
        <th colspan="2">Multiplicative <tt>{ associativity left precedence 150 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>*</tt></td><td>Multiply</td></tr>
        <tr><td><tt>/</tt></td><td>Divide</td></tr>
        <tr><td><tt>%</tt></td><td>Remainder</td></tr>
        <tr><td><tt>&amp;*</tt></td><td>Multiply, ignoring overflow</td></tr>
        <tr><td><tt>&amp;/</tt></td><td>Divide, ignoring overflow</td></tr>
        <tr><td><tt>&amp;%</tt></td><td>Remainder, ignoring overflow</td></tr>
        <tr><td><tt>&amp;</tt></td><td>Bitwise AND</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Additive <tt>{ associativity left precedence 140 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>+</tt></td><td>Add</td></tr>
        <tr><td><tt>-</tt></td><td>Subtract</td></tr>
        <tr><td><tt>&amp;+</tt></td><td>Add with overflow</td></tr>
        <tr><td><tt>&amp;-</tt></td><td>Subtract with overflow</td></tr>
        <tr><td><tt>|</tt></td><td>Bitwise OR</td></tr>
        <tr><td><tt>^</tt></td><td>Bitwise XOR</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Range <tt>{ precedence 135 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>..&lt;</tt></td><td>Half-open range</td></tr>
        <tr><td><tt>...</tt></td><td>Closed range</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Cast <tt>{ precedence 132 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>is</tt></td><td>Type check</td></tr>
        <tr><td><tt>as</tt></td><td>Type cast</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Comparative <tt>{ precedence 130 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>&lt;</tt></td><td>Less than</td></tr>
        <tr><td><tt>&lt;=</tt></td><td>Less than or equal</td></tr>
        <tr><td><tt>></tt></td><td>Greater than</td></tr>
        <tr><td><tt>>=</tt></td><td>Greater than or equal</td></tr>
        <tr><td><tt>==</tt></td><td>Equal</td></tr>
        <tr><td><tt>!=</tt></td><td>Not equal</td></tr>
        <tr><td><tt>===</tt></td><td>Identical</td></tr>
        <tr><td><tt>!==</tt></td><td>Not identical</td></tr>
        <tr><td><tt>~=</tt></td><td>Pattern match</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Conjunctive <tt>{ associativity left precedence 120 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>&amp;&amp;</tt></td><td>Logical AND</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Disjunctive <tt>{ associativity left precedence 110 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>||</tt></td><td>Logical OR</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Nil Coalescing <tt>{ associativity right precedence 110 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>??</tt></td><td>Nil coalescing</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Ternary Conditional <tt>{ associativity right precedence 100 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>?:</tt></td><td>Ternary conditional</td></tr>
    </tbody>

    <tr>
        <th colspan="2">Assignment <tt>{ associativity right precedence 90 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>=</tt></td><td>Assign</td></tr>
        <tr><td><tt>*=</tt></td><td>Multiply and assign</td></tr>
        <tr><td><tt>/=</tt></td><td>Divide and assign</td></tr>
        <tr><td><tt>%=</tt></td><td>Remainder and assign</td></tr>
        <tr><td><tt>+=</tt></td><td>Add and assign</td></tr>
        <tr><td><tt>-=</tt></td><td>Subtract and assign</td></tr>
        <tr><td><tt>&lt;&lt;=</tt></td><td>Left bit shift and assign</td></tr>
        <tr><td><tt>>>=</tt></td><td>Right bit shift and assign</td></tr>
        <tr><td><tt>&amp;=</tt></td><td>Bitwise AND and assign</td></tr>
        <tr><td><tt>^=</tt></td><td>Bitwise XOR and assign</td></tr>
        <tr><td><tt>|=</tt></td><td>Bitwise OR and assign</td></tr>
        <tr><td><tt>&amp;&amp;=</tt></td><td>Logical AND and assign</td></tr>
        <tr><td><tt>||=</tt></td><td>Logical OR and assign</td></tr>
    </tbody>
</table>

### Postfix


- `++`: Increment
- `--`: Decrement

### Member Functions

In addition to the aforementioned standard operators, there are some _de facto_ operators defined by the language:

- `.`: Member Access
- `?`: Optional
- `!`: Forced-Value
- `[]`: Subscript
- `[]=`: Subscript Assignment

## Overloading

Swift has the ability to overload operators such that existing operators, like `+`, can be made to work with additional types.

To overload an operator, simply define a new function for the operator symbol, taking the appropriate number and type of arguments.

For example, to overload `*` to repeat a string a specified number of times:

```swift
func * (left: String, right: Int) -> String {
    if right <= 0 {
        return ""
    }

    var result = left
    for _ in 1..<right {
        result += left
    }

    return result
}

"a" * 6 
// "aaaaaa"
```

This is, however, a controversial language feature.

Any C++ developer would be all too eager to regale you with horror stories of the non-deterministic havoc this can wreak.

Consider the following statement:

```swift
[1, 2] + [3, 4] // [1, 2, 3, 4]
```

By default, the `+` operator acts on two arrays by appending the right hand to the left hand.

However, when overridden thusly:

```swift
func +(left: [Double], right: [Double]) -> [Double] {
    var sum = [Double](count: left.count, repeatedValue: 0.0)
    for (i, _) in enumerate(left) {
        sum[i] = left[i] + right[i]
    }

    return sum
}
```

The result is now an array with the pairwise sums of each element, expressed as `Double`:

```swift
[1, 2] + [3, 4] // [4.0, 6.0]
```

And if the operator were also overloaded to work with `Int` types, with:

```swift
func +(left: [Int], right: [Int]) -> [Int] {
    var sum = [Int](count: left.count, repeatedValue: 0)
    for (i, _) in enumerate(left) {
        sum[i] = left[i] + right[i]
    }

    return sum
}
```

The result would then be an array of pairwise sums, expressed as `Int`.

```swift
[1, 2] + [3, 4] // [4, 6]
```

Herein lies the original sin of operator overloading: **ambiguous semantics**.

Having been limited to basic arithmetic operators across many years and programming languages, overloading of operators has become commonplace:

- Computing Sum of Integers: `1 + 2 // 3`
- Computing Sum of Floats: `1.0 + 2.0 // 3.0`
- Appending to String: `"a" + "b" // "ab"`
- Appending to Array: `["foo"] + ["bar"] // ["foo", "bar"]`

It makes sense that `+` would work on numbers—that's just math. But think about it: _why should adding two strings together concatenate them_?  `1 + 2` isn't `12` ([except in Javascript](https://www.destroyallsoftware.com/talks/wat)). Is this really intuitive, or is it just familiar.

> PHP uses `.` for string concatenation (which is objectively a terrible idea). Objective-C allows consecutive string literals to be appended with whitespace.

In the run-up to its initial stable release, Swift still has some work to do in resolving ambiguities in operator semantics. Recent changes, such as the addition of the `nil` coalescing operator (`??`), and the decision for optionals not to conform to `BooleanType` (confusing in the case of `Bool?`) are encouraging, and demonstrate the need for us to collectively ask ourselves _"does this really make sense?"_, and file radars appropriately.

> I'm specifically concerned about the semantics of array operators, as demonstrated in the previous example. My 2 cents: arrays should forego the `+` and `-` operators in lieu of `<<`:

```swift
func <<<T> (inout left: [T], right: [T]) -> [T] {
    left.extend(right)
    return left
}

func <<<T> (inout left: [T], right: T) -> [T] {
    left.append(right)
    return left
}
```

## Custom Operators

An even more controversial and exciting feature is the ability to define custom operators.

Consider the arithmetic operator found in many programming languages, but missing in Swift is `**`, which raises the left hand number to the power of the right hand number (the `^` symbol, commonly used for superscripts, is already used to perform a [bitwise XOR](http://en.wikipedia.org/wiki/Bitwise_operation#XOR)).

To add this operator in Swift, first declare the operator:

```swift
infix operator ** { associativity left precedence 160 }
```

- `infix` specifies that it is a binary operator, taking a left and right hand argument
- `operator` is a reserved word that must be preceded with either `prefix`, `infix`, or `postfix`
- `**` is the operator itself
- `associativity left` means that operations are grouped from the left
- `precedence 160` means that it will evaluate with the same precedence as the exponential operators `<<` and `>>` (left and right bitshift).

```swift
func ** (left: Double, right: Double) -> Double {
    return pow(left, right)
}

2 ** 3 
// 8
```

When creating custom operators, make sure to also create the corresponding assignment operator, if appropriate:

```swift
infix operator **= { associativity right precedence 90 }
func **= (inout left: Double, right: Double) {
    left = left ** right
}
```

> Note that `left` is `inout`, which makes sense, since assignment mutates the original value.

### Custom Operators with Protocol and Method

Function definitions for the operators themselves should be extremely simple—a single LOC, really. For anything more complex, some additional setup is warranted.

Take, for example, a custom operator, `=~`, which returns whether the left hand side matches a regular expression on the right hand side:

```swift
protocol RegularExpressionMatchable {
    func match(pattern: String, options: NSRegularExpressionOptions) throws -> Bool
}

extension String: RegularExpressionMatchable {
    func match(pattern: String, options: NSRegularExpressionOptions = []) throws -> Bool {
        let regex = try NSRegularExpression(pattern: pattern, options: options)
        return regex.numberOfMatchesInString(self, options: [], range: NSRange(location: 0, length: 0.distanceTo(utf16.count))) != 0
    }
}

infix operator =~ { associativity left precedence 130 }
func =~<T: RegularExpressionMatchable> (left: T, right: String) -> Bool {
    return try! left.match(right, options: [])
}
```

- First, a `RegularExpressionMatchable` `protocol` is declared, with a single method for matching regular expressions.
- Next, an `extension` adding conformance to this `protocol` to `String` is declared, with a provided implementation of `match`, using `NSRegularExpression`.
- Finally, the `=~` operator is declared and implemented on a generic type conforming to `RegularExpressionMatchable`.

By doing this, a user has the option to use the `match` function instead of the operator. It also has the added benefit of greater flexibility in what options are passed into the method.

```swift
let cocoaClassPattern = "^[A-Z]{2,}[A-Za-z0-9]+$"

try? "NSHipster".match(cocoaClassPattern)       // true
"NSHipster" =~ cocoaClassPattern                // true
```

This is all to say: **a custom operator should only ever be provided as a convenience for an existing function.**

### Use of Mathematical Symbols

Custom operators can begin with one of the ASCII characters /, =, -, +, !, *, %, <, >, &, |, ^, or ~, or any of the Unicode characters in the "Math Symbols" character set.

This makes it possible to take the square root of a number with a single `√` prefix operator (`⌥v`):

```swift
prefix operator √ {}
prefix func √ (number: Double) -> Double {
    return sqrt(number)
}

√4 
// 2
```

Or consider the `±` operator, which can be used either as an `infix` or `prefix` to return a tuple with the sum and difference:

```swift
infix operator ± { associativity left precedence 140 }
func ± (left: Double, right: Double) -> (Double, Double) {
    return (left + right, left - right)
}

prefix operator ± {}
prefix func ± (value: Double) -> (Double, Double) {
    return 0 ± value
}

2 ± 3
// (5, -1)

±4
// (4, -4)
```

> For more examples of functions using mathematical notation in Swift, check out [Euler](https://github.com/mattt/Euler).

Custom operators are hard to type, and therefore hard to use. **Exercise restraint when using custom operators with exotic symbols**. After all, code should not be copy-pasted.

* * *

Operators in Swift are among the most interesting and indeed controversial features of this new language.

When overriding or defining new operators in your own code, make sure to follow these guidelines:

## Guidelines for Swift Operators

1. Don't create an operator unless its meaning is obvious and undisputed. Seek out any potential conflicts to ensure semantic consistency.
2. Custom operators should only be provided as a convenience. Complex functionality should always be implemented in a function, preferably one specified as a generic using a custom protocol.
3. Pay attention to the precedence and associativity of custom operators. Find the closest existing class of operators and use the appropriate precedence value.
4. If it makes sense, be sure to implement assignment shorthand for a custom operator (e.g. `+=` for `+`).

