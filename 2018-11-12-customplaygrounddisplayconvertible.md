---
title: CustomPlaygroundDisplayConvertible
author: Mattt
category: Swift
excerpt: >-
  Playgrounds use a combination of language features and tooling
  to provide a real-time, interactive development environment.
  With the `CustomPlaygroundDisplayConvertible` protocol,
  you can leverage this introspection for your own types.
status:
  swift: "4.2"
---

Playgrounds allow you to see what your Swift code is doing
every step along the way.
Each time a statement is executed,
its result is logged to the sidebar along the right-hand side.
From there, you can open a Quick Look preview of the result in a popover
or display the result inline, directly in the code editor.

The code responsible for providing this feedback
is provided by the PlaygroundLogger framework,
which is part of the open source
[swift-xcode-playground-support](https://github.com/apple/swift-xcode-playground-support/)
project.

Reading through the code,
we learn that the Playground logger distinguishes between
<dfn>structured values</dfn>,
whose state is disclosed by inspecting its internal members,
and <dfn>opaque values</dfn>,
which provide a specialized representation of itself.
Beyond those two,
the logger recognizes <dfn>entry and exit points</dfn> for scopes
(control flow statements, functions, et cetera)
as well as <dfn>runtime errors</dfn>
(caused by implicitly unwrapping nil values, `fatalError()`, and the like)
Anything else ---
imports, assignments, blank lines ---
are considered <dfn>gaps</dfn>

### Built-In Opaque Representations

The Playground logger provides built-in opaque representations
for many of the types you're likely to interact with
in Foundation, UIKit, AppKit, SpriteKit, CoreGraphics, CoreImage, and
the Swift standard library:

{::nomarkdown }

<table id="customplaygrounddisplayconvertible-categories">
    <thead>
        <tr>
            <th colspan="2">Category</th>
            <th>Types</th>
            <th>Result</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th class="icon">
                {% asset playground-icon-string.svg width=24 height=24 @inline %}
            </th>
            <th>Strings</th>
            <td>
                <ul>
                    <li><code>String</code></li>
                    <li><code>NSString</code></li>
                </ul>
            </td>
            <td>
                <samp>"Hello, world!"</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-attributed-string.svg width=24 height=24 @inline %}
            </th>
            <th>Attributed Strings</th>
            <td>
                <ul>
                    <li><code>NSAttributedString</code></li>
                </ul>
            </td>
            <td>
                <samp style="color: orange;">"Hello, world!"</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-number.svg width=24 height=24 @inline %}
            </th>
            <th>Numbers</th>
            <td>
                <ul>
                    <li><code>Int</code>, <code>UInt</code>, …</code></li>
                    <li><code>Double</code>, <code>Float</code>, …</code></li>
                    <li><code>CGFloat</code></li>
                    <li><code>NSNumber</code></li>
                </ul>
            </td>
            <td>
                <samp>42</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-range.svg width=24 height=24 @inline %}
            </th>
            <th>Ranges</th>
            <td>
                <ul>
                   <li><code>NSRange</code></li>
                </ul>
            </td>
            <td>
                <samp>{0, 10}</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-boolean.svg width=24 height=24 @inline %}
            </th>
            <th>Boolean Values</th>
            <td>
                <ul>
                    <li><code>Bool</code></li>
                </ul>
            </td>
            <td>
                <samp>true</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-pointer.svg width=24 height=24 @inline %}
            </th>
            <th>Pointers</th>
            <td>
                <ul>
                    <li><code>UnsafePointer</code></li>
                    <li><code>UnsafeMutablePointer</code></li>
                    <li><code>UnsafeRawPointer</code></li>
                    <li><code>UnsafeMutableRawPointer</code></li>
                </ul>
            </td>
            <td>
                <samp>0x0123456789ABCDEF</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-date.svg width=24 height=24 @inline %}
            </th>
            <th>Dates</th>
            <td>
                <ul>
                    <li><code>Date</code></li>
                    <li><code>NSDate</code></li>
                </ul>
            </td>
            <td>
                <samp>Nov 12, 2018 at 10:00</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-url.svg width=24 height=24 @inline %}
            </th>
            <th>URLs</th>
            <td>
                <ul>
                    <li><code>URL</code></li>
                    <li><code>NSURL</code></li>
                </ul>
            </td>
            <td>
                <samp>https://nshipster.com</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-color.svg width=24 height=24 @inline %}
            </th>
            <th>Colors</th>
            <td>
                <ul>
                    <li><code>CGColor</code></li>
                    <li><code>NSColor</code></li>
                    <li><code>UIColor</code></li>
                    <li><code>CIColor</code></li>
                </ul>
            </td>
            <td>
                <div>
                <samp>🔴 r 1.0 g 0.0 b 0.0 a 1.0</samp>
                <br/>
                {% asset playground-custom-description-color.png %}
                </div>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-geometry.svg width=24 height=24 @inline %}
            </th>
            <th>Geometry</th>
            <td>
                <ul>
                    <li><code>CGPoint</code></li>
                    <li><code>CGSize</code></li>
                    <li><code>CGRect</code></li>
                </ul>
            </td>
            <td>
                <div>
                <samp>{x 0 y 0 w 100 h 100}</samp>
                <br/>
                {% asset playground-custom-description-geometry.png %}
                </div>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-bezier-path.svg width=24 height=24 @inline %}
            </th>
            <th>Bezier Paths</th>
            <td>
                <ul>
                    <li><code>NSBezierPath</code></li>
                    <li><code>UIBezierPath</code></li>
                </ul>
            </td>
            <td>
                <samp>11 path elements</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-image.svg width=24 height=24 @inline %}
            </th>
            <th>Images</th>
            <td>
                <ul>
                    <li><code>CGImage</code></li>
                    <li><code>NSCursor</code></li>
                    <li><code>NSBitmapImageRep</code></li>
                    <li><code>NSImage</code></li>
                    <li><code>UIImage</code></li>
                </ul>
            </td>
            <td>
                <samp>w 50 h 50</samp>
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-sprite-kit.svg width=24 height=24 @inline %}
            </th>
            <th>SpriteKit Nodes</th>
            <td>
                <ul>
                    <li><code>SKShapeNode</code></li>
                    <li><code>SKSpriteNode</code></li>
                    <li><code>SKTexture</code></li>
                    <li><code>SKTextureAtlas</code></li>
                </ul>
            </td>
            <td>
                <samp>SKShapeNode</samp>
                <br/>
                {% asset playground-icon-sprite-kit.svg width=50 height=50 @inline %}
            </td>
        </tr>
        <tr>
            <th class="icon">
                {% asset playground-icon-view.svg width=24 height=24 @inline %}
            </th>
            <th>Views</th>
            <td>
                <ul>
                    <li><code>NSView</code></li>
                    <li><code>UIView</code></li>
                </ul>
            </td>
            <td>
                <samp>NSView</samp>
            </td>
        </tr>
    </tbody>
</table>
{:/}

{% info %}
This list is derived from the
[source code for the `CustomOpaqueLoggable` protocol](https://github.com/apple/swift-xcode-playground-support/tree/master/PlaygroundLogger/PlaygroundLogger/CustomLoggable),
and is subject to change in future releases.
{% endinfo %}

### Structured Values

Alternatively,
the Playground logger provides for values to be represented structurally ---
without requiring an implementation of the
[`CustomReflectable` protocol](https://nshipster.com/mirror/).

This works if the value is a tuple, an enumeration case,
or an instance of a class or structure.
It handles <dfn>aggregates</dfn>, or values bridged from an Objective-C class,
as well as <dfn>containers</dfn>, like arrays and dictionaries.
If the value is an optional,
the logger will implicitly unwrap its value, if present.

## Customizing How Results Are Logged In Playgrounds

Developers can customize how the Playground logger displays results
by extending types to adopt the `CustomPlaygroundDisplayConvertible` protocol
and implement the required `playgroundDescription` computed property.

For example,
let's say you're using Playgrounds
to familiarize yourself with the Contacts framework.
_(Note: the Contacts framework is unavailable in Swift Playgrounds for iPad)_
You create a new `CNMutableContact`,
set the `givenName` and `familyName` properties,
and provide an array of `CNLabeledValue` values
to the `emailAddresses` property:

```swift
import Contacts

let contact = CNMutableContact()
contact.givenName = "Johnny"
contact.familyName = "Appleseed"
contact.emailAddresses = [
    CNLabeledValue(label: CNLabelWork,
                   value: "johnny@apple.com")
]
```

If you were hoping for feedback to validate your API usage,
you'd be disappointed by what shows up in the results sidebar:

<samp>
`<CNMutableContact: 0x7ff727e38bb0: ... />`
</samp>

To improve on this,
we can extend the superclass of `CNMutableContact`,
`CNContact`,
and have it conform to `CustomPlaygroundDisplayConvertible`.
The Contacts framework includes `CNContactFormatter`,
which offers a convenient way to summarize a contact:

```swift
extension CNContact: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return CNContactFormatter.string(from: self, style: .fullName) ?? ""
    }
}
```

By putting this at the top of our Playground
(or in a separate file in the Playground's auxilliary sources),
our `contact` from before now provides a much nicer Quick Look representation:

<samp>
"Johnny Appleseed"
</samp>

To provide a specialized Playground representation,
delegate to one of the value types listed in the table above.
In this case,
the ContactsUI framework provides a `CNContactViewController` class
whose `view` property we can use here
_(annoyingly, the API is slightly different between iOS and macOS,
hence the compiler directives)_:

```swift
import Contacts
import ContactsUI

extension CNContact: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        let viewController: CNContactViewController
        #if os(macOS)
            viewController = CNContactViewController()
            viewController.contact = self
        #elseif os(iOS)
            viewController = CNContactViewController(for: self)
        #else
            #warning("ContactsUI unavailable")
        #endif

        return viewController.view
    }
}
```

After replacing our original `playgroundDescription` implementation,
our contact displays with the following UI:

{% asset playground-custom-description-contact.png %}

{% error %}
At the time of writing,
[the initialization pattern for Playground log entries](https://github.com/apple/swift-xcode-playground-support/blob/master/PlaygroundLogger/PlaygroundLogger/LogEntry%2BReflection.swift#L58-L67)
causes the custom description / debug description of the original result
to be discarded.
As far as we can tell,
there's currently no way to provide a specialized Quick Look representation
that doesn't override the result sidebar representation
to the normalized type name of the value.
{% enderror %}

---

Playgrounds occupy an interesting space in the Xcode tooling ecosystem.
It's neither a primary debugging interface,
nor a mechanism for communicating with the end user.
Rather, it draws upon both low-level and user-facing functionality
to provide a richer development experience.
Because of this,
it can be difficult to understand how Playgrounds fit in with everything else.

Here's a run-down of some related functionality:

## Relationship to CustomStringConvertible and CustomDebugStringConvertible

The Playground logger uses the following criteria
when determining how to represent a value in the results sidebar:

- If the value is a `String`, return that value
- If the value is `CustomStringConvertible` or `CustomDebugStringConvertible`,
  return `String(reflecting:)`
- If the value is an enumeration
  (as determined by `Mirror`),
  return `String(describing:)`
- Otherwise, return the type name,
  normalizing to remove the module from the fully-qualified name

Therefore,
you can customize the Playground description for types
by providing conformance to
`CustomStringConvertible` or `CustomDebugStringConvertible`.

So the question becomes,
_"How do I decide which of these protocols to adopt?"_

Here are some general guidelines:

- Use `CustomStringConvertible` (`description`)
  to represent values in a way that's appropriate for users.
- Use `CustomDebugStringConvertible` (`debugDescription`)
  to represent values in a way that's appropriate for developers.
- Use `CustomPlaygroundDisplayConvertible` (`playgroundDescription`)
  to represent values in a way that's appropriate for developers
  in the context of a Playground.

Within a Playground,
expressiveness is prioritized over raw execution.
So we have some leeway on how much work is required
to generate descriptions.

For example,
the default representation of most sequences
is the type name (often with cryptic generic constraints):

```swift
let evens = sequence(first: 0, next: {$0 + 2})
```

<samp>UnfoldSequence<Int, (Optional<Int>, Bool)>

Iterating a sequence has unknown performance characteristics,
so it would be inappropriate to include that
within a `description` or `debugDescription`.
But in a Playground?
Sure, _go nuts_ ---
by associating it in the Playground itself,
there's little risk in that code making it into production.

So back to our original example,
let's see how `CustomPlaygroundDisplayConvertible`
can help us decipher our sequence:

```swift
extension UnfoldSequence: CustomPlaygroundDisplayConvertible
           where Element: CustomStringConvertible
{
    public var playgroundDescription: Any {
        return prefix(10).map{$0.description}
            .joined(separator: ", ") + "…"
    }
}
```

<samp>
0, 2, 4, 6, 8, 10, 12, 14, 16, 18…
</samp>

## Relationship to Debug Quick Look

When a Playground logs structured values,
it provides an interface
[similar to what you find](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/CustomClassDisplay_in_QuickLook/CH02-std_objects_support/CH02-std_objects_support.html#//apple_ref/doc/uid/TP40014001-CH3-SW19)
when running an Xcode project in debug mode.

{% info %}
For more information,
check out our article about
[Quick Look debugging](https://nshipster.com/quick-look-debugging/).
{% endinfo %}

What this means in practice
is that Playgrounds can approximate a debugger interface
when working with structured types.

For example,
the description of a `Data` value doesn't tell us much:

```swift
let data = "Hello, world!".data(using: .utf8)
```

coming from `description`

<samp>
13 bytes
</samp>

And for good reason!
As we described in the previous section,
we want to keep the implementation of `description` nice and snappy.

By contrast,
the structured representation of the same data object
when viewed from a Playground tells us the size and memory address ---
it even shows an inline byte array
for up to length 64:

<samp>
count 13
pointer "UnsafePointer(7FFCFB609470)"
[72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33]
</samp>

---

Playgrounds use a combination of language features and tooling
to provide a real-time, interactive development environment.
With the `CustomPlaygroundDisplayConvertible` protocol,
you can leverage this introspection for your own types.
