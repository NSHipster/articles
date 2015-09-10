---
title: NSCalendarUnitYear
author: Mattt Thompson
category: Swift
excerpt: "NSHipster.com was launched 2 years ago to the day. Each week since has featured a new article on some obscure topic in Objective-C or Cocoa (with only a couple gaps). Let's celebrate with some cake."
status:
    swift: 2.0
    reviewed: September 9, 2015
---

NSHipster.com was launched 2 years ago to the day, with [a little article about NSIndexSet](http://nshipster.com/nsindexset/). Each week since has featured a new article on some obscure topic in Objective-C or Cocoa (with only a couple gaps), which have been read by millions of visitors in over 180 different countries.

> This is actually the 101st article, which means that [by television industry standards](http://en.wikipedia.org/wiki/100_episodes), this site is now suitable for broadcast syndication. (Coming soon to TBS!)

Let's celebrate with some cake:

<svg version="1.1" id="birthday-cake" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
     viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve" style="width:300px; height: 300px; margin: 1em auto;">
    <path d="M27.5,32.5c0,0-24.6,13.8-25,33.6c0,0.1,0,0.2,0,0.4V95c0,1.1,0.9,2,2,1.9L88,93.1c1.1-0.1,2.1-0.1,2.2-0.1
        c0.1,0,0.2-0.9,0.2-2c0,0,0-25.5,0-26.5c0-2-2-3-2-3 M88.5,89.4c0,1-0.9,1.9-2,2L6.5,94.9c-1.1,0-2-0.8-2-1.8c0,0,0-4.7,0-10.1
        l84-3.9C88.5,84.5,88.5,89.4,88.5,89.4z M88.5,76L4.5,80c0-5.8,0-11.3,0-11.8c0-0.9,1-1.1,1-1.1l82-3.6c0,0,1,0,1,0.9
        C88.5,64.9,88.5,70.3,88.5,76z"/>
    <path d="M41.8,8.4c0,4.1-1.8,5.6-4.1,5.6c-2.3,0-4.1-1.5-4.1-5.6S37.8,1,37.8,1S41.8,4.3,41.8,8.4z"/>
    <path fill="#FFFFFF" stroke="#000000" stroke-miterlimit="10" d="M42,47.5c0,2.5-2,4.5-4.5,4.5l0,0c-2.5,0-4.5-2-4.5-4.5V19.8
        c0-2.5,2-4.5,4.5-4.5l0,0c2.5,0,4.5,2,4.5,4.5V47.5z"/>
</svg>

Cute, right? Let's see what this looks like in code:

~~~{swift}
var cakePath = UIBezierPath()
cakePath.moveToPoint(CGPointMake(31.5, 32.5))
cakePath.addCurveToPoint(CGPointMake(6.5, 66.1), controlPoint1: CGPointMake(31.5, 32.5), controlPoint2: CGPointMake(6.9, 46.3))
cakePath.addCurveToPoint(CGPointMake(6.5, 66.5), controlPoint1: CGPointMake(6.5, 66.2), controlPoint2: CGPointMake(6.5, 66.3))
cakePath.addLineToPoint(CGPointMake(6.5, 95))

...
~~~

Wait, hold up. What is this, Objective-C? Manipulating `UIBezierPath`s isn't exactly ground-breaking stuff, but with a few dozen more lines to go, we can make this a bit easier for ourselves.

How about we put some syntactic icing on this cake with some [custom operators](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AdvancedOperators.html#//apple_ref/doc/uid/TP40014097-CH27-XID_28)?

~~~{swift}
infix operator ---> { associativity left }
func ---> (left: UIBezierPath, right: (CGFloat, CGFloat)) -> UIBezierPath {
    let (x, y) = right
    left.moveToPoint(CGPointMake(x, y))

    return left
}

infix operator +- { associativity left }
func +- (left: UIBezierPath, right: (CGFloat, CGFloat)) -> UIBezierPath {
    let (x, y) = right
    left.addLineToPoint(CGPointMake(x, y))

    return left
}

infix operator +~ { associativity left }
func +~ (left: UIBezierPath, right: ((CGFloat, CGFloat), (CGFloat, CGFloat), (CGFloat, CGFloat))) -> UIBezierPath {
    let ((x1, y1), (x2, y2), (x3, y3)) = right
    left.addCurveToPoint(CGPointMake(x1, y1), controlPoint1: CGPointMake(x2, y2), controlPoint2: CGPointMake(x3, y3))

    return left
}
~~~

> Get it? `--->` replaces `moveToPoint`, while `+-` replaces `addLineToPoint`, and `+~` replaces `addCurveToPoint`. This declaration also does away with all of the redundant calls to `CGPointMake`, opting instead for simple coordinate tuples.

Swift offers a great deal of flexibility in how a programmer structures their code. One feature that exemplifies this mantra of minimal constraints is the ability to add custom prefix, infix, and postfix operators. Swift's syntax limits custom operators to be one or more of any of the following characters (provided an operator does not conflict with a reserved symbols, such as the `?` or `!` used for optional values):

`/ = - + * % < > ! & | ^ . ~.`

Custom operators offer a powerful tool for cutting through cruft, redundancy, unnecessary repetition, and so on and so forth, et cetera. Combine them with other language features like patterns or chaining to craft DSLs perfectly suited to the task at hand.

Just... you know, don't let this power go to your head.

After full Emoji support (`let 🐶🐮`), custom operators are perhaps the shiniest new feature for anyone coming from Objective-C. And like any shiny new feature, it is destined to provide the most snark fodder for the "get off my lawn" set.

### A Dramatization of the Perils of Shiny Swift Features


> `SCENE: SAN FRANCISCO, THE YEAR IS 2017`
>
> `GREYBEARD:` So I inherited an old Swift codebase today, and I found this line of code—I swear to `$DEITY`—it just reads `😾 |--~~> 💩`.
>
> `BROGRAMMER`: _shakes head_
>
> `GREYBEARD`: What the hell am I supposed to make of that? Is, like, the piece of poo throwing a <abbr title="↓↘︎→P">Hadouken</abbr>, or is it about to get the business end of a corkscrew?
>
> `BROGRAMMER`: Truly, a philosophical quandary if ever there was one.
>
> `GREYBEARD`: Anyway, turns out, that statement just reloads nearby restaurants.
>
> `BROGRAMMER:` Dude, AFNetworking got weird with its 4.0 release.
>
> `GREYBEARD:` Indeed.

The moral of that cautionary tale: **use custom operators and emoji sparingly**.

(Or whatever, the very next code sample totally ignores that advice)

~~~{swift}
// Happy 2nd Birthday, NSHipster
// 😗💨🎂✨2️⃣

var 🍰 = UIBezierPath()
🍰 ---> ((31.5, 32.5))
     +~ ((6.5, 66.1), (31.5, 32.5), (6.9, 46.3))
     +~ ((6.5, 66.5), (6.5, 66.2), (6.5, 66.3))
     +- ((6.5, 95))
     +~ ((8.5, 96.9), (6.5, 96.1), (7.4, 97))
     +- ((92, 93.1))
     +~ ((94.2, 93), (93.1, 93), (94.1, 93))
     +~ ((94.4, 91), (94.3, 93), (94.4, 92.1))
     +~ ((94.4, 64.5), (94.4, 91), (94.4, 65.5))
     +~ ((92.4, 61.5), (94.4, 62.5), (92.4, 61.5))
   ---> ((92.5, 89.4))
     +~ ((90.5, 91.4), (92.5, 90.4), (91.6, 91.3))
     +- ((10.5, 94.9))
     +~ ((8.5, 93.1), (9.4, 94.9), (8.5, 94.1))
     +~ ((8.5, 83), (8.5, 93.1), (8.5, 88.4))
     +- ((92.5, 79.1))
     +~ ((92.5, 89.4), (92.5, 84.5), (92.5, 89.4))
🍰.closePath()

🍰 ---> ((92.5, 76))
     +- ((8.5, 80))
     +~ ((8.5, 68.2), (8.5, 74.2), (8.5, 68.7))
     +~ ((9.5, 67.1), (8.5, 67.3), (9.5, 67.1))
     +- ((91.5, 63.5))
     +~ ((92.5, 64.4), (91.5, 63.5), (92.5, 63.5))
     +~ ((92.5, 76), (92.5, 64.9), (92.5, 70.3))
🍰.closePath()


var 📍 = UIBezierPath()
📍 ---> ((46, 47.5))
     +~ ((41.5, 52), (46, 50), (44, 52))
     +- ((41.5, 52))
     +~ ((37, 47.5), (39, 52), (37, 50))
     +- ((37, 19.8))
     +~ ((41.5, 15.3), (37, 17.3), (39, 15.3))
     +- ((41.5, 15.3))
     +~ ((46, 19.8), (44, 15.3), (46, 17.3))
     +- ((46, 47.5))
📍.closePath()


var 🔥 = UIBezierPath()
🔥.miterLimit = 4

🔥 ---> ((45.8, 8.4))
     +~ ((41.7, 14), (45.8, 12.5), (44, 14))
     +~ ((37.6, 8.4), (39.4, 14), (37.6, 12.5))
     +~ ((41.8, 1), (37.6, 4.3), (41.8, 1))
     +~ ((45.8, 8.4), (41.8, 1), (45.8, 4.3))
🔥.closePath()


UIColor.blackColor().setFill()
🍰.fill()
🔥.fill()

UIColor.whiteColor().setFill()
UIColor.blackColor().setStroke()
📍.fill()
📍.stroke()
~~~

I'm as amazed as anyone that this actually compiles.

Everything is terrible.

* * *

Anyway, Happy 2nd Birthday, NSHipster!

Thank you for helping to make these last couple years the insanely great experience it's been. I'll do my part to keep things up for years to come.
