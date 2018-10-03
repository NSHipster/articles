---
title: Swift Operators
author: Mattt
category: Swift
tags: swift
excerpt: >-
  Operators are what do the work of a program.
  They are the very execution of an executable;
  the teleological driver of every process.
revisions:
  "2014-08-11": First Publication
  "2018-10-03": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: October 3, 2018
---

What would a program be without operators?
A mishmash of classes, namespaces, conditionals, loops, and namespaces
signifying nothing.

Operators are what do the work of a program.
They are the very execution of an executable;
the teleological driver of every process.
Operators are a topic of great importance for developers
and the focus of this week's NSHipster article.

## Operator Precedence and Associativity

If we were to dissect an expression ---
say `1 + 2` ---
and decompose it into constituent parts,
we would find one <dfn>operator</dfn> and two <dfn>operands</dfn>:

|      1       |    +     |       2       |
| :----------: | :------: | :-----------: |
| left operand | operator | right operand |

Expressions are expressed in a single, flat line of code,
from which the compiler constructs an
<abbr title="Abstract Syntax Tree">AST</abbr>,
or abstract syntax tree:

{% asset swift-operators-one-plus-two.svg alt="1 + 2 AST" %}

For compound expressions,
like `1 + 2 * 3`
or `5 - 2 + 3`,
the compiler uses rules for
operator <dfn>precedence</dfn> and <dfn>associativity</dfn>
to resolve the expression into a single value.

Operator precedence rules,
[similar to the ones you learned in primary school](https://en.wikipedia.org/wiki/Order_of_operations),
determine the order in which different kinds of operators are evaluated.
In this case, multiplication has a higher precedence than addition,
so `2 * 3` evaluates first.

|      1       |    +     |   (2 \* 3)    |
| :----------: | :------: | :-----------: |
| left operand | operator | right operand |

{% asset swift-operators-one-plus-two-times-three.svg alt="1 + 2 * 3 AST" %}

Associativity determines the order in which
operators with the same precedence are resolved.
If an operator is <dfn>left-associative</dfn>,
then the operand on the left-hand side is evaluated first: (`(5 - 2) + 3`);
if <dfn>right-associative</dfn>,
then the right-hand side operator is evaluated first: `5 - (2 + 3)`.

Arithmetic operators are left-associative,
so `5 - 2 + 3` evaluates to `6`.

|   (5 - 2)    |    +     |       3       |
| :----------: | :------: | :-----------: |
| left operand | operator | right operand |

{% asset swift-operators-one-plus-two-plus-three.svg alt="5 - 2 + 3 AST" %}

## Swift Operators

The Swift Standard Library includes most of the operators
that a programmer might expect coming from another language in the C family,
as well as a few convenient additions like
the nil-coalescing operator (`??`)
and pattern match operator (`~=`),
as well as operators for
type checking (`is`),
type casting (`as`, `as?`, `as!`)
and forming open or closed ranges (`...`, `..<`).

### Infix Operators

Swift uses <dfn>infix</dfn> notation for binary operators
(as opposed to, say [Reverse Polish Notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation)).
The Infix operators are grouped below
according to their associativity
and precedence level, in descending order:

<table>
    <tr>
        <th colspan="2"><tt>BitwiseShiftPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>&lt;&lt;</tt></td>
            <td>Bitwise left shift</td>
        </tr>
        <tr>
            <td><tt>&gt;&gt;</tt></td>
            <td>Bitwise right shift</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>MultiplicationPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>\*</tt></td>
            <td>Multiply</td>
        </tr>
        <tr>
            <td><tt>/</tt></td>
            <td>Divide</td>
        </tr>
        <tr>
            <td><tt>%</tt></td>
            <td>Remainder</td>
        </tr>
        <tr>
            <td><tt>&amp;\*</tt></td>
            <td>Multiply, ignoring overflow</td>
        </tr>
        <tr>
            <td><tt>&amp;/</tt></td>
            <td>Divide, ignoring overflow</td>
        </tr>
        <tr>
            <td><tt>&amp;%</tt></td>
            <td>Remainder, ignoring overflow</td>
        </tr>
        <tr>
            <td><tt>&amp;</tt></td>
            <td>Bitwise AND</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>AdditionPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>+</tt></td>
            <td>Add</td>
        </tr>
        <tr>
            <td><tt>-</tt></td>
            <td>Subtract</td>
        </tr>
        <tr>
            <td><tt>&amp;+</tt></td>
            <td>Add with overflow</td>
        </tr>
        <tr>
            <td><tt>&amp;-</tt></td>
            <td>Subtract with overflow</td>
        </tr>
        <tr>
            <td><tt>|</tt></td>
            <td>Bitwise OR</td>
        </tr>
        <tr>
            <td><tt>^</tt></td>
            <td>Bitwise XOR</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>RangeFormationPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>..&lt;</tt></td>
            <td>Half-open range</td>
        </tr>
        <tr>
            <td><tt>...</tt></td>
            <td>Closed range</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>CastingPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>is</tt></td>
            <td>Type check</td>
        </tr>
        <tr>
            <td><tt>as</tt></td>
            <td>Type cast</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>NilCoalescingPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>??</tt></td>
            <td><tt>nil</tt> Coalescing</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>ComparisonPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>&lt;</tt></td>
            <td>Less than</td>
        </tr>
        <tr>
            <td><tt>&lt;=</tt></td>
            <td>Less than or equal</td>
        </tr>
        <tr>
            <td><tt>></tt></td>
            <td>Greater than</td>
        </tr>
        <tr>
            <td><tt>>=</tt></td>
            <td>Greater than or equal</td>
        </tr>
        <tr>
            <td><tt>==</tt></td>
            <td>Equal</td>
        </tr>
        <tr>
            <td><tt>!=</tt></td>
            <td>Not equal</td>
        </tr>
        <tr>
            <td><tt>===</tt></td>
            <td>Identical</td>
        </tr>
        <tr>
            <td><tt>!==</tt></td>
            <td>Not identical</td>
        </tr>
        <tr>
            <td><tt>~=</tt></td>
            <td>Pattern match</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>LogicalConjunctionPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>&amp;&amp;</tt></td>
            <td>Logical AND</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>LogicalDisjunctionPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>||</tt></td>
            <td>Logical OR</td>
        </tr>
    </tbody>
    <tr>
        <th colspan="2"><tt>DefaultPrecedence</tt></th>
    </tr>
    <tbody>
    </tbody>
    <tr>
        <th colspan="2"><tt>AssignmentPrecedence</tt></th>
    </tr>
    <tbody>
        <tr>
            <td><tt>=</tt></td>
            <td>Assign</td>
        </tr>
        <tr>
            <td><tt>*=</tt></td>
            <td>Multiply and assign</td>
        </tr>
        <tr>
            <td><tt>/=</tt></td>
            <td>Divide and assign</td>
        </tr>
        <tr>
            <td><tt>%=</tt></td>
            <td>Remainder and assign</td>
        </tr>
        <tr>
            <td><tt>+=</tt></td>
            <td>Add and assign</td>
        </tr>
        <tr>
            <td><tt>-=</tt></td>
            <td>Subtract and assign</td>
        </tr>
        <tr>
            <td><tt>&lt;&lt;=</tt></td>
            <td>Left bit shift and assign</td>
        </tr>
        <tr>
            <td><tt>>>=</tt></td>
            <td>Right bit shift and assign</td>
        </tr>
        <tr>
            <td><tt>&amp;=</tt></td>
            <td>Bitwise AND and assign</td>
        </tr>
        <tr>
            <td><tt>^=</tt></td>
            <td>Bitwise XOR and assign</td>
        </tr>
        <tr>
            <td><tt>|=</tt></td>
            <td>Bitwise OR and assign</td>
        </tr>
        <tr>
            <td><tt>&amp;&amp;=</tt></td>
            <td>Logical AND and assign</td>
        </tr>
        <tr>
            <td><tt>||=</tt></td>
            <td>Logical OR and assign</td>
        </tr>
    </tbody>
</table>

{% info %}

Operator precedence groups were originally defined with numerical precedence.
For example, multiplicative operators defined a precedence value of 150,
so they were evaluated before additive operators,
which defined a precedence value of 140.

In Swift 3,
operators changed to define precedence by partial ordering
to form a <abbr title="Directed Acyclic Graph">DAG</abbr>
or [directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph).
For detailed information about this change,
read Swift Evolution proposal
[SE-0077 "Improved operator declarations"](https://github.com/apple/swift-evolution/blob/master/proposals/0077-operator-precedence.md).

{% endinfo %}

### Unary Operators

In addition to binary operators that take two operands,
there are also <dfn>unary</dfn> operators,
which take a single operand.

#### Prefix Operators

Prefix operators come before the expression they operate on.
Swift defines a handful of these by default:

- `+`: Unary plus
- `-`: Unary minus
- `!`: Logical NOT
- `~`: Bitwise NOT

For example,
the `!` prefix operator
negates a logical value of its operand
and the `-` prefix operator
negates the numeric value of its operand.

```swift
!true // false
-(1.0 + 2.0) // -3.0
```

{% info %}

The increment/decrement (`++` / `--`) operators were removed in Swift 3.
This was one of the first changes to be made as part of the
[Swift Evolution process](https://github.com/apple/swift-evolution)
after the language was released as open source.
In [the proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0004-remove-pre-post-inc-decrement.md),
Chris Lattner describes how these operators can be confusing,
and argues for why they aren't needed in the language.

{% endinfo %}

### Postfix Operators

Unary operators can also come after their operand,
as is the case for the postfix variety.
These are less common;
the Swift Standard Library declares only the
open-ended range postfix operator, `...`.

```swift
let fruits = ["🍎", "🍌", "🍐", "🍊", "🍋"]
fruits[3...] // ["🍊", "🍋"]
```

### Ternary Operators

The ternary `?:` operator is special.
It takes three operands
and functions like a single-line `if-else` statement:
evaluate the logical condition on the left side of the `?`
and produces the expression on the left or right-hand side of the `:`
depending on the result:

```swift
true ? "Yes" : "No" // "Yes"
```

In Swift,
`TernaryPrecedence` is defined lower than `DefaultPrecedence`
and higher than `AssignmentPrecedence`.
But, in general, it's better to keep ternary operator usage simple
(or avoid them altogether).

## Operator Overloading

Once an operator is declared,
it can be associated with a type method or top-level function.
When an operator can resolve different functions
depending on the types of operands,
then we say that the operator is <dfn>overloaded</dfn>.

The most prominent examples of overloading can be found with the `+` operator.
In many languages, `+` can be used to perform
arithmetic addition (`1 + 2 => 3`)
or concatenation for arrays and other collections (`[1] + [2] => [1, 2]` ).

Developers have the ability to overload standard operators
by declaring a new function for the operator symbol with
the appropriate number and type of arguments.

For example, to overload the `*` operator
to repeat a `String` a specified number of times,
you'd declare the following top-level function:

```swift
func * (lhs: String, rhs: Int) -> String {
    guard rhs > 0 else {
        return ""
    }

    return String(repeating: lhs, count: rhs)
}

"hello" * 3 // hellohellohello
```

This kind of language use is, however, controversial.
(Any C++ developer would be all too eager to regale you with horror stories of the non-deterministic havoc this can wreak)

Consider the following statement:

```swift
[1, 2] + [3, 4] // [1, 2, 3, 4]
```

By default, the `+` operator concatenates the elements of both arrays,
and is implemented using a generic function definition.

If you were to declare a specialized function
that overloads the `+` for arrays of `Double` values
to perform member-wise addition,
it would override the previous concatenating behavior:

```swift
// 👿
func + (lhs: [Double], rhs: [Double]) -> [Double] {
    return zip(lhs, rhs).map(+)
}

[1.0, 3.0, 5.0] + [2.0, 4.0, 6.0] // [3.0, 7.0, 11.0]
```

Herein lies the original sin of operator overloading:
**ambiguous semantics**.

It makes sense that `+` would work on numbers --- that's maths.
But if you really think about it,
_why should adding two strings together concatenate them_?
`1 + 2` isn't `12`
([except in Javascript](https://www.destroyallsoftware.com/talks/wat)).
Is this really intuitive? ...or is it just _familiar_.

Something to keep in mind when deciding whether to overload an existing operator.

{% info %}

By comparison,
PHP uses `.` for string concatenation,
whereas SQL uses `||`;
Objective-C doesn't have an operator, per se,
but will append consecutive string literals with whitespace.

{% endinfo %}

## Defining Custom Operators

One of the most exciting features of Swift
(though also controversial)
is the ability to define <dfn>custom operators</dfn>.

Consider the exponentiation operator, `**`,
found in many programming languages,
but missing from Swift.
It raises the left-hand number to the power of the right-hand number.
(The `^` symbol, commonly used for superscripts,
is already used by the
[bitwise XOR](https://en.wikipedia.org/wiki/Bitwise_operation#XOR) operator).

Exponentiation has a higher operator precedence than multiplication,
and since Swift doesn't have a built-in precedence group that we can use,
we first need to declare one ourselves:

```swift
precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}
```

Now we can declare the operator itself:

```swift
infix operator ** : ExponentiationPrecedence
```

Finally,
we implement a top-level function using our new operator:

```swift
import Darwin

func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}

2 ** 3 // 8
```

{% info %}

We need to import the Darwin module
to access the standard math function, `pow(_:_:)`.
(Alternatively, we could import Foundation instead to the same effect.)

{% endinfo %}

When you create a custom operator,
consider providing a mutating variant as well:

```swift
infix operator **= : AssignmentPrecedence
func **= (lhs: inout Double, rhs: Double) {
    lhs = pow(lhs, rhs)
}

var n: Double = 10
n **= 1 + 2 // n = 1000
```

### Use of Mathematical Symbols

A custom operator can use combinations of the characters
`/`, `=`, `-`, `+`, `!`, `*`, `%`, `<`, `>`, `&`, `|`, `^`, or `~`,
and any characters found in the
[Mathematical Operators](https://en.wikipedia.org/wiki/Mathematical_Operators)
Unicode block, among others.

This makes it possible to take the square root of a number
with a single `√` prefix operator:

```swift
import Darwin

prefix operator √
prefix func √ (_ value: Double) -> Double {
    return sqrt(value)
}

√4 // 2
```

Or consider the `±` operator,
which can be used either as an infix or prefix operator
to return a tuple with the sum and difference:

```swift
infix operator ± : AdditionPrecedence
func ± <T: Numeric>(lhs: T, rhs: T) -> (T, T) {
    return (lhs + rhs, lhs - rhs)
}

prefix operator ±
prefix func ± <T: Numeric>(_ value: T) -> (T, T) {
    return 0 ± value
}

2 ± 3 // (5, -1)

±4 // (4, -4)
```

{% info %}

For more examples of functions using mathematical notation in Swift,
check out [Euler](https://github.com/mattt/Euler).

{% endinfo %}

Custom operators are hard to type, and therefore hard to use,
so exercise restraint with exotic symbols.
Code should be typed, not be copy-pasted.

When overriding or defining new operators in your own code,
make sure to follow these guidelines:

1.  Don't create an operator unless its meaning is obvious and undisputed.
    Seek out any potential conflicts to ensure semantic consistency.
2.  Pay attention to the precedence and associativity of custom operators,
    and only define new operator groups as necessary.
3.  If it makes sense, consider implementing assigning variants
    for your custom operator (e.g. `+=` for `+`).
