---
title: Type Encodings
author: Mattt
category: Objective-C
tags: nshipster
excerpt: "From number stations and numerology to hieroglyphics and hobo codes, there is something truly fascinating about finding meaning that hides in plain sight. Though hidden messages in and of themselves are rarely useful or particularly interesting, it's the thrill of the hunt that piques our deepest curiosities."
status:
    swift: n/a
---

From [number stations](https://en.wikipedia.org/wiki/Numbers_station) and [numerology](https://en.wikipedia.org/wiki/Numerology) to [hieroglyphs](https://en.wikipedia.org/wiki/Egyptian_hieroglyphs) and [hobo codes](https://en.wikipedia.org/wiki/Hobo#Hobo_.28sign.29_code), there is something truly fascinating about finding meaning that hides in plain sight. Though hidden messages in and of themselves are rarely useful or particularly interesting, it's the thrill of the hunt that piques our deepest curiosities.

It is in this spirit that we take a look at [Objective-C Type Encodings](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html) in this week's edition of NSHipster.

---

[Last week](https://nshipster.com/nsvalue/), in a discussion about `NSValue`, there was mention of `+valueWithBytes:objCType:`, whose second parameter should be created with the Objective-C `@encode()` compiler directive.

`@encode`, one of the [`@` Compiler Directives](https://nshipster.com/at-compiler-directives/), returns a C string that encodes the internal representation of a given type (e.g., `@encode(int)` → `i`), similar to the ANSI C `typeof` operator. Apple's Objective-C runtime uses type encodings internally to help facilitate message dispatching.

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
      <td><code>c</code></td>
      <td>A <code>char</code></td>
    </tr>
    <tr>
      <td><code>i</code></td>
      <td>An <code>int</code></td></tr>
    <tr>
      <td><code>s</code></td>
      <td>A <code>short</code></td></tr>
    <tr>
      <td><code>l</code></td>
      <td>A <code>long</code><code>l</code> is treated as a 32-bit quantity on 64-bit programs.</td></tr>
    <tr>
      <td><code>q</code></td>
      <td>A <code>long long</code></td></tr>
    <tr>
      <td><code>C</code></td>
      <td>An <code>unsigned char</code></td></tr>
    <tr>
      <td><code>I</code></td>
      <td>An <code>unsigned int</code></td></tr>
    <tr>
      <td><code>S</code></td>
      <td>An <code>unsigned short</code></td></tr>
    <tr>
      <td><code>L</code></td>
      <td>An <code>unsigned long</code></td></tr>
    <tr>
      <td><code>Q</code></td>
      <td>An <code>unsigned long long</code></td></tr>
    <tr>
      <td><code>f</code></td>
      <td>A <code>float</code></td></tr>
    <tr>
      <td><code>d</code></td>
      <td>A <code>double</code></td></tr>
    <tr>
      <td><code>B</code></td>
      <td>A C++ <code>bool</code> or a C99 <code>_Bool</code></td></tr>
    <tr>
      <td><code>v</code></td>
      <td>A <code>void</code></td></tr>
    <tr>
      <td><code>*</code></td>
      <td>A character string (<code>char *</code>)</td></tr>
    <tr>
      <td><code>@</code></td>
      <td>An object (whether statically typed or typed <code>id</code>)</td></tr>
    <tr>
      <td><code>#</code></td>
      <td>A class object (<code>Class</code>)</td></tr>
    <tr>
      <td><code>:</code></td>
      <td>A method selector (<code>SEL</code>)</td></tr>
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
      <td><code>b</code>num</td>
      <td>A bit field of <em>num</em> bits</td></tr>
    <tr>
      <td><code>^</code>type</td>
      <td>A pointer to <em>type</em></td></tr>
    <tr>
      <td><code>?</code></td>
      <td>An unknown type (among other things, this code is used for function pointers)</td>
    </tr>
  </tbody>
</table>

Charts are fine, 
but experimenting in code is even better:

```objc
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
```

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
- Passing `NSObject` directly yields `#`. However, passing `[NSObject class]` yields a struct named `NSObject` with a single class field: `isa`, which `NSObject` instances have to signify their type.

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
      <td><code>r</code></td>
      <td><code>const</code></td>
    </tr>
    <tr>
      <td><code>n</code></td>
      <td><code>in</code></td>
    </tr>
    <tr>
      <td><code>N</code></td>
      <td><code>inout</code></td>
    </tr>
    <tr>
      <td><code>o</code></td>
      <td><code>out</code></td>
    </tr>
    <tr>
      <td><code>O</code></td>
      <td><code>bycopy</code></td>
    </tr>
    <tr>
      <td><code>R</code></td>
      <td><code>byref</code></td>
    </tr>
    <tr>
      <td><code>V</code></td>
      <td><code>oneway</code></td>
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

