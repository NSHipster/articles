---
title: Documentation
author: Mattt Thompson
category: Objective-C
excerpt: "There's an adage among Cocoa developers that Objective-C's verbosity lends its code to being effectively self-documenting. Between longMethodNamesWithNamedParameters: and the explicit typing of those parameters, Objective-C methods don't leave much to the imagination."
status:
    swift: n/a
---

There's an adage among Cocoa developers that Objective-C's verbosity lends its code to being effectively self-documenting. Between `longMethodNamesWithNamedParameters:` and the explicit typing of those parameters, Objective-C methods don't leave much to the imagination.

But even self-documenting code can be improved with documentation, and just a small amount of effort can yield significant benefit to others.

**Listen**—I know programmers don't like to be told what to do, and prescriptive arguments of "thou shalt" and "thou shalt not" have the [rhetorical impact of a trombone](http://www.youtube.com/watch?v=ss2hULhXf04), so I'll cut to the chase:

Do you like Apple's documentation? Don't you want that [for your own libraries?](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html) Follow just a few simple conventions, and your code can get the documentation it deserves.

---

Every modern programming language has comments: non-executable natural language annotations denoted by a special character sequence, such as `//`, `/* */`, `#`, and `--`. Documentation provides auxiliary explanation and context to code using specially-formatted comments, which can be extracted and parsed by a build tool.

In Objective-C, the documentation tool of choice is [`appledoc`](https://github.com/tomaz/appledoc). Using a [Javadoc](http://en.wikipedia.org/wiki/Javadoc)-like syntax, `appledoc` is able to generate HTML and Xcode-compatible `.docset` docs from `.h` files that [look nearly identical](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html) to [Apple's official documentation](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSArray_Class/NSArray.html).

> [Doxygen](http://www.stack.nl/~dimitri/doxygen/), used primarily for C++, is another viable option for Objective-C, but is generally dispreffered by the iOS / OS X developer community.

Here are some examples from well-documented Objective-C projects:

- [`AFHTTPSessionManager.h`](https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFHTTPSessionManager.h)
- [`MRBrew.h`](https://github.com/marcransome/MRBrew/blob/master/MRBrew/MRBrew.h)
- [`GRMustache.h`](https://github.com/groue/GRMustache/blob/master/src/classes/GRMustache.h)
- [`TTTAddressFormatter.h`](https://github.com/mattt/FormatterKit/blob/master/FormatterKit/TTTAddressFormatter.h)

## Guidelines for Writing Objective-C Documentation

Objective-C documentation is designated by a `/** */` comment block (note the extra initial star), which precedes any `@interface` or `@protocol`, as well as any method or `@property` declarations.

For classes, categories, and protocols, documentation should describe the purpose of that particular component, offering suggestions and guidelines for how it should be used. Structure it like a news article: start with a top-level "tweet-sized" overview, and then explore further topics in more detail as necessary. Concerns like how a class should (or should not) be subclassed, or any caveats in behavior for standard protocols (like `NSCopying`) should always be documented.

Each method should similarly begin with a concise description of its functionality, followed by any caveats or additional details. Method documentation also contains Javadoc-style `@` labels for common fields like parameters and return value:

- `@param [param] [Description]`: Describes what value should be passed for this parameter
- `@return [Description]`: Describes the return value of the method
- `@see [selector]`: Provide "see also" reference to related method
- `@warning [description]`: Call out exceptional or potentially dangerous behavior

Properties are often described in a single sentence, and should include what its default value is.

Related properties and methods should be grouped by an `@name` declaration, which functions similarly to a [`#pragma mark`](http://nshipster.com/pragma/), and can be used with the triple-slash (`///`) comment variant.

Try reading other documentation before writing some yourself, in order to get a sense of the correct tone and style. When in doubt about terminology or verbiage, follow the lead of the closest thing you can find from Apple's official docs.

> To help speed up the process of documenting your project, you may want to check out the [VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode) project, which [automatically adds `@param` and `@return` labels](https://raw.github.com/onevcat/VVDocumenter-Xcode/master/ScreenShot.gif) for methods according to their signature.

---

Just by following these simple guidelines, you can add great-looking, informative documentation to your own project. Once you get the hang of it, you'll find yourself cranking docs out in no time.

> Thanks to [@orta](https://github.com/orta) for suggesting this week's topic, and for his ongoing work on [CocoaDocs](http://cocoadocs.org) which provides automatically-generated documentation for projects published on [CocoaPods](http://cocoapods.org).
