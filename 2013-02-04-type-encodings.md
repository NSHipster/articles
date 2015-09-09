---
title: Type Encodings
author: Mattt Thompson
category: Objective-C
tags: nshipster
excerpt: "From number stations and numerology to hieroglyphics and hobo codes, there is something truly fascinating about finding meaning that hides in plain sight. Though hidden messages in and of themselves are rarely useful or particularly interesting, it's the thrill of the hunt that piques our deepest curiosities."
status:
    swift: n/a
---

From [number stations](http://en.wikipedia.org/wiki/Numbers_station) and [numerology](http://en.wikipedia.org/wiki/Numerology) to [hieroglyphs](http://en.wikipedia.org/wiki/Egyptian_hieroglyphs) and [hobo codes](http://en.wikipedia.org/wiki/Hobo#Hobo_.28sign.29_code), there is something truly fascinating about finding meaning that hides in plain sight. Though hidden messages in and of themselves are rarely useful or particularly interesting, it's the thrill of the hunt that piques our deepest curiosities.

It is in this spirit that we take a look at [Objective-C Type Encodings](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html) in this week's edition of NSHipster.

---

[Last week](http://nshipster.com/nsvalue/), in a discussion about `NSValue`, there was mention of `+valueWithBytes:objCType:`, whose second parameter should be created with the Objective-C `@encode()` compiler directive.

`@encode`, one of the [`@` Compiler Directives](http://nshipster.com/at-compiler-directives/), returns a C string that encodes the internal representation of a given type (e.g., `@encode(int)` → `i`), similar to the ANSI C `typeof` operator. Apple's Objective-C runtime uses type encodings internally to help facilitate message dispatching.

Here's a rundown of all of the different Objective-C Type Encodings:

<table id="type-encodings">
  <caption>Objective-C Type Encodings</caption>
  <thead>
    <tr>
      <th>Code</th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>c</tt></td>
      <td>A <tt>char</tt></td>
    </tr>
    <tr>
      <td><tt>i</tt></td>
      <td>An <tt>int</tt></td></tr>
    <tr>
      <td><tt>s</tt></td>
      <td>A <tt>short</tt></td></tr>
    <tr>
      <td><tt>l</tt></td>
      <td>A <tt>long</tt><tt>l</tt> is treated as a 32-bit quantity on 64-bit programs.</td></tr>
    <tr>
      <td><tt>q</tt></td>
      <td>A <tt>long long</tt></td></tr>
    <tr>
      <td><tt>C</tt></td>
      <td>An <tt>unsigned char</tt></td></tr>
    <tr>
      <td><tt>I</tt></td>
      <td>An <tt>unsigned int</tt></td></tr>
    <tr>
      <td><tt>S</tt></td>
      <td>An <tt>unsigned short</tt></td></tr>
    <tr>
      <td><tt>L</tt></td>
      <td>An <tt>unsigned long</tt></td></tr>
    <tr>
      <td><tt>Q</tt></td>
      <td>An <tt>unsigned long long</tt></td></tr>
    <tr>
      <td><tt>f</tt></td>
      <td>A <tt>float</tt></td></tr>
    <tr>
      <td><tt>d</tt></td>
      <td>A <tt>double</tt></td></tr>
    <tr>
      <td><tt>B</tt></td>
      <td>A C++ <tt>bool</tt> or a C99 <tt>_Bool</tt></td></tr>
    <tr>
      <td><tt>v</tt></td>
      <td>A <tt>void</tt></td></tr>
    <tr>
      <td><tt>*</tt></td>
      <td>A character string (<tt>char *</tt>)</td></tr>
    <tr>
      <td><tt>@</tt></td>
      <td>An object (whether statically typed or typed <tt>id</tt>)</td></tr>
    <tr>
      <td><tt>#</tt></td>
      <td>A class object (<tt>Class</tt>)</td></tr>
    <tr>
      <td><tt>:</tt></td>
      <td>A method selector (<tt>SEL</tt>)</td></tr>
    <tr>
      <td>[<em>array type</em>] </td>
      <td>An array</td></tr>
    <tr>
      <td>{<em>name=type...</em>}</td>
      <td>A structure</td></tr>
    <tr>
      <td>(<em>name</em>=<em>type...</em>)</td>
      <td>A union</td></tr>
    <tr>
      <td><tt>b</tt>num</td>
      <td>A bit field of <em>num</em> bits</td></tr>
    <tr>
      <td><tt>^</tt>type</td>
      <td>A pointer to <em>type</em></td></tr>
    <tr>
      <td><tt>?</tt></td>
      <td>An unknown type (among other things, this code is used for function pointers)</td>
    </tr>
  </tbody>
</table>

Of course, charts are fine, but experimenting in code is even better:

~~~{objective-c}
NSLog(@"int        : %s", @encode(int));
NSLog(@"float      : %s", @encode(float));
NSLog(@"float *    : %s", @encode(float*));
NSLog(@"char       : %s", @encode(char));
NSLog(@"char *     : %s", @encode(char *));
NSLog(@"BOOL       : %s", @encode(BOOL));
NSLog(@"void       : %s", @encode(void));
NSLog(@"void *     : %s", @encode(void *));

NSLog(@"NSObject * : %s", @encode(NSObject *));
NSLog(@"NSObject   : %s", @encode(NSObject));
NSLog(@"[NSObject] : %s", @encode(typeof([NSObject class])));
NSLog(@"NSError ** : %s", @encode(typeof(NSError **)));

int intArray[5] = {1, 2, 3, 4, 5};
NSLog(@"int[]      : %s", @encode(typeof(intArray)));

float floatArray[3] = {0.1f, 0.2f, 0.3f};
NSLog(@"float[]    : %s", @encode(typeof(floatArray)));

typedef struct _struct {
    short a;
    long long b;
    unsigned long long c;
} Struct;
NSLog(@"struct     : %s", @encode(typeof(Struct)));
~~~

Result:

|  Type        | Encoding           |
|--------------|--------------------|
| `int`        | `i`                |
| `float`      | `f`                |
| `float *`    | `^f`               |
| `char`       | `c`                |
| `char *`     | `*`                |
| `BOOL`       | `c`                |
| `void`       | `v`                |
| `void *`     | `^v`               |
| `NSObject *` | `@`                |
| `NSObject`   | `#`                |
| `[NSObject]` | `{NSObject=#}`     |
| `NSError **` | `^@`               |
| `int[]`      | `[5i]`             |
| `float[]`    | `[3f]`             |
| `struct`     | `{_struct=sqQ}`    |

There are some interesting takeaways from this:

- Whereas the standard encoding for pointers is a preceding `^`, `char *` gets its own code: `*`. This makes sense conceptually, as C strings are thought to be entities in and of themselves, rather than a pointer to something else.
- `BOOL` is `c`, rather than `i`, as one might expect. Reason being, `char` is smaller than an `int`, and when Objective-C was originally designed in the 80's, bits (much like the dollar) were more valuable than they are today. `BOOL` is specifically a `signed char` (even if `-funsigned-char` is set), to ensure a consistent type between compilers, since `char` could be either `signed` or `unsigned`.
- Passing `NSObject` directly yields `#`. However, passing `[NSObject class]` yields a struct named `NSObject` with a single class field. That is, of course, the `isa` field, which all `NSObject` instances have to signify their type.

## Method Encodings

As mentioned in Apple's ["Objective-C Runtime Programming Guide"](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html), there are a handful of type encodings that are used internally, but cannot be returned with `@encode`.

These are the type qualifiers for methods declared in a protocol:

<table id="method-encodings">
  <caption>Objective-C Method Encodings</caption>
  <thead>
    <tr>
      <th>Code</th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>r</tt></td>
      <td><tt>const</tt></td>
    </tr>
    <tr>
      <td><tt>n</tt></td>
      <td><tt>in</tt></td>
    </tr>
    <tr>
      <td><tt>N</tt></td>
      <td><tt>inout</tt></td>
    </tr>
    <tr>
      <td><tt>o</tt></td>
      <td><tt>out</tt></td>
    </tr>
    <tr>
      <td><tt>O</tt></td>
      <td><tt>bycopy</tt></td>
    </tr>
    <tr>
      <td><tt>R</tt></td>
      <td><tt>byref</tt></td>
    </tr>
    <tr>
      <td><tt>V</tt></td>
      <td><tt>oneway</tt></td>
    </tr>
  </tbody>
</table>

For anyone familiar with [NSDistantObject](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDistantObject_Class/Reference/Reference.html), you'll doubtless recognize these as a vestige of [Distributed Objects](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DistrObjects/DistrObjects.html#//apple_ref/doc/uid/10000102i).

Although DO has fallen out of fashion in the age of iOS, it was an interprocess messaging protocol used between Cocoa applications--even running on different machines on the network. Under these constraints, there were benefits to be had from the additional context.

For example, parameters in distributed object messages were passed as proxies by default. In situations where proxying would be unnecessarily inefficient, the `bycopy` qualifier could be added to make sure a full copy of the object was sent. Also by default, parameters were `inout`, signifying that objects needed to be sent back and forth when sending the message. By specifying a parameter as `in` or `out` instead, the application could avoid the round-trip overhead.

---

So what do we gain from our newfound understanding of Objective-C Type Encodings?
Honestly, not that much (unless you're doing any crazy metaprogramming).

But as we said from the very outset, there is wisdom in the pursuit of deciphering secret messages.

Looking at type encodings reveals details about Objective-C runtime internals, which is a noble pursuit in and of itself. Going further down the rabbit hole, and we come to the secret history of Distributed Objects, and the obscure parameter qualifiers that [still linger around to this day](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNumberFormatter_Class/Reference/Reference.html%23jumpTo_22).

