---
title: "JavaScriptCore"
author: Nate Cook
category: "Cocoa"
excerpt: "Introduced with OS X Mavericks and iOS 7, the JavaScriptCore framework puts an Objective-C wrapper around WebKit's JavaScript engine, providing easy, fast, and safe access to the world's most prevalent language. Love it or hate it, JavaScript's ubiquity has led to an explosion of developers, tools, and resources along with ultra-fast virtual machines like the one built into OS X and iOS."
status:
    swift: 2.0
    reviewed: November 9, 2015
---

An updated ranking of programming language popularity is [out this week](http://redmonk.com/sogrady/category/programming-languages/), showing Swift leaping upward through the ranks from 68th to 22nd, while Objective-C holds a strong lead up ahead at #10. Both, however, are blown away by the only other language allowed to run natively on iOS: the current champion, JavaScript.

Introduced with OS X Mavericks and iOS 7, the JavaScriptCore framework puts an Objective-C wrapper around WebKit's JavaScript engine, providing easy, fast, and safe access to the world's most prevalent language. Love it or hate it, JavaScript's ubiquity has led to an explosion of developers, tools, and resources along with ultra-fast virtual machines like the one built into OS X and iOS.

So come, lay aside bitter debates about dynamism and type safety, and join me for a tour of *JavaScriptCore.*


* * *

### `JSContext` / `JSValue`

`JSContext` is an environment for running JavaScript code. A `JSContext` instance represents the global object in the environment—if you've written JavaScript that runs in a browser, `JSContext` is analogous to `window`. After creating a `JSContext`, it's easy to run JavaScript code that creates variables, does calculations, or even defines functions:

````swift
let context = JSContext()
context.evaluateScript("var num = 5 + 5")
context.evaluateScript("var names = ['Grace', 'Ada', 'Margaret']")
context.evaluateScript("var triple = function(value) { return value * 3 }")
let tripleNum: JSValue = context.evaluateScript("triple(num)")
````
````objective-c
JSContext *context = [[JSContext alloc] init];
[context evaluateScript:@"var num = 5 + 5"];
[context evaluateScript:@"var names = ['Grace', 'Ada', 'Margaret']"];
[context evaluateScript:@"var triple = function(value) { return value * 3 }"];
JSValue *tripleNum = [context evaluateScript:@"triple(num)"];
````

As that last line shows, any value that comes *out* of a `JSContext` is wrapped in a `JSValue` object. A language as dynamic as JavaScript requires a dynamic type, so `JSValue` wraps every possible kind of JavaScript value: strings and numbers; arrays, objects, and functions; even errors and the special JavaScript values `null` and `undefined`.

`JSValue` includes a host of methods for accessing its underlying value as the correct Foundation type, including:

| JavaScript Type | `JSValue` method                   | Objective-C Type    | Swift Type                  
|-----------------|------------------------------------|---------------------|----------------------------------| 
| string          | `toString`                         | `NSString`          | `String!`                           
| boolean         | `toBool`                           | `BOOL`              | `Bool`                         
| number          | `toNumber`<br>`toDouble`<br>`toInt32`<br>`toUInt32` | `NSNumber`<br>`double`<br>`int32_t`<br>`uint32_t` | `NSNumber!`<br>`Double`<br>`Int32`<br>`UInt32`
| Date            | `toDate`                           | `NSDate`            | `NSDate!`                        
| Array           | `toArray`                          | `NSArray`           | `[AnyObject]!`                   
| Object          | `toDictionary`                     | `NSDictionary`      | `[NSObject : AnyObject]!`
| Object          | `toObject`<br>`toObjectOfClass:`   | *custom type*       | *custom type*

To retrieve the value of `tripleNum` from the above example, simply use the appropriate method:

````swift
print("Tripled: \(tripleNum.toInt32())")
// Tripled: 30
````
````objective-c
NSLog(@"Tripled: %d", [tripleNum toInt32]);
// Tripled: 30
````


### Subscripting Values

We can easily access any values we've created in our `context` using subscript notation on both `JSContext` and `JSValue` instances. `JSContext` requires a string subscript, while `JSValue` allows either string or integer subscripts for delving down into objects and arrays:

````swift
let names = context.objectForKeyedSubscript("names")
let initialName = names.objectAtIndexedSubscript(0)
print("The first name: \(initialName.toString())")
// The first name: Grace
````
````objective-c
JSValue *names = context[@"names"];
JSValue *initialName = names[0];
NSLog(@"The first name: %@", [initialName toString]);
// The first name: Grace
````

> Swift shows its youth, here—while Objective-C code can take advantage of subscript notation, Swift currently only exposes the [raw methods](/object-subscripting/) that should make such subscripting possible: `objectForKeyedSubscript()` and `objectAtIndexedSubscript()`.


### Calling Functions

With a `JSValue` that wraps a JavaScript function, we can call that function directly from our Objective-C/Swift code using Foundation types as parameters. Once again, JavaScriptCore handles the bridging without any trouble:

````swift
let tripleFunction = context.objectForKeyedSubscript("triple")
let result = tripleFunction.callWithArguments([5])
print("Five tripled: \(result.toInt32())")
````
````objective-c
JSValue *tripleFunction = context[@"triple"];
JSValue *result = [tripleFunction callWithArguments:@[@5] ];
NSLog(@"Five tripled: %d", [result toInt32]);
````


### Exception Handling

`JSContext` has another useful trick up its sleeve: by setting the context's `exceptionHandler` property, you can observe and log syntax, type, and runtime errors as they happen. `exceptionHandler` is a callback handler that receives a reference to the `JSContext` and the exception itself:

````swift
context.exceptionHandler = { context, exception in
    print("JS Error: \(exception)")
}

context.evaluateScript("function multiply(value1, value2) { return value1 * value2 ")
// JS Error: SyntaxError: Unexpected end of script
````
````objective-c
context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
   NSLog(@"JS Error: %@", exception);
};

[context evaluateScript:@"function multiply(value1, value2) { return value1 * value2 "];
// JS Error: SyntaxError: Unexpected end of script
````



## JavaScript Calling

Now we know how to extract values from a JavaScript environment and call functions defined therein. What about the reverse? How can we get access to our custom objects and methods, defined in Objective-C or Swift, from within the JavaScript realm?

There are two main ways of giving a `JSContext` access to our native client code: blocks and the `JSExport` protocol.

### Blocks

When an Objective-C block is assigned to an identifier in a `JSContext`, JavaScriptCore automatically wraps the block in a JavaScript function. This makes it simple to use Foundation and Cocoa classes from within JavaScript—again, all the bridging happens for you. Witness the full power of Foundation string transformations, now accessible to JavaScript:

````swift
let simplifyString: @convention(block) String -> String = { input in
    let result = input.stringByApplyingTransform(NSStringTransformToLatin, reverse: false)
    return result?.stringByApplyingTransform(NSStringTransformStripCombiningMarks, reverse: false) ?? ""
}
context.setObject(unsafeBitCast(simplifyString, AnyObject.self), forKeyedSubscript: "simplifyString")

print(context.evaluateScript("simplifyString('안녕하새요!')"))
// annyeonghasaeyo!
````
````objective-c
context[@"simplifyString"] = ^(NSString *input) {
   NSMutableString *mutableString = [input mutableCopy];
   CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, NO);
   CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformStripCombiningMarks, NO);
   return mutableString;
};

NSLog(@"%@", [context evaluateScript:@"simplifyString('안녕하새요!')"]);
````

> There's another speedbump for Swift here—note that this only works for *Objective-C blocks*, not Swift closures. To use a Swift closure in a `JSContext`, it needs to be (a) declared with the `@convention(block)` attribute, and (b) cast to `AnyObject` using Swift's knuckle-whitening `unsafeBitCast()` function.

#### Memory Management

Since blocks can capture references to variables and `JSContext`s maintain strong references to all their variables, some care needs to be taken to avoid strong reference cycles. Avoid capturing your `JSContext` or any `JSValue`s inside a block. Instead, use `[JSContext currentContext]` to get the current context and pass any values you need as parameters.


### `JSExport` Protocol

Another way to use our custom objects from within JavaScript code is to add conformance to the `JSExport` protocol. Whatever properties, instance methods, and class methods we declare in our `JSExport`-inherited protocol will *automatically* be available to any JavaScript code. We'll see how in the following section.


## JavaScriptCore in Practice

Let's build out an example that will use all these different techniques—we'll define a `Person` model that conforms to the `JSExport` sub-protocol `PersonJSExports`, then use JavaScript to create and populate instances from a JSON file. Who needs `NSJSONSerialization` when there's an entire JavaScript VM lying around?

### 1) `PersonJSExports` and `Person`

Our `Person` class implements the `PersonJSExports` protocol, which specifies what properties should be available in JavaScript. 

> The `create...` class method is necessary because JavaScriptCore does *not* bridge initializers—we can't simply say `var person = new Person()` the way we would with a native JavaScript type.

````swift
// Custom protocol must be declared with `@objc`
@objc protocol PersonJSExports : JSExport {
    var firstName: String { get set }
    var lastName: String { get set }
    var birthYear: NSNumber? { get set }
    
    func getFullName() -> String

    /// create and return a new Person instance with `firstName` and `lastName`
    static func createWithFirstName(firstName: String, lastName: String) -> Person
}

// Custom class must inherit from `NSObject`
@objc class Person : NSObject, PersonJSExports {
    // properties must be declared as `dynamic`
    dynamic var firstName: String
    dynamic var lastName: String
    dynamic var birthYear: NSNumber?
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

    class func createWithFirstName(firstName: String, lastName: String) -> Person {
        return Person(firstName: firstName, lastName: lastName)
    }

    func getFullName() -> String {
        return "\(firstName) \(lastName)"
    }
}
````
````objective-c
// in Person.h -----------------
@class Person;

@protocol PersonJSExports <JSExport>
    @property (nonatomic, copy) NSString *firstName;
    @property (nonatomic, copy) NSString *lastName;
    @property NSInteger ageToday;

    - (NSString *)getFullName;

    // create and return a new Person instance with `firstName` and `lastName`
    + (instancetype)createWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
@end

@interface Person : NSObject <PersonJSExports>
    @property (nonatomic, copy) NSString *firstName;
    @property (nonatomic, copy) NSString *lastName;
    @property NSInteger ageToday;
@end

// in Person.m -----------------
@implementation Person
- (NSString *)getFullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

+ (instancetype) createWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    Person *person = [[Person alloc] init];
    person.firstName = firstName;
    person.lastName = lastName;
    return person;
}
@end
````

### 2) `JSContext` Configuration

Before we can use the `Person` class we've created, we need to export it to the JavaScript environment. We'll also take this moment to import the [Mustache JS library](http://mustache.github.io/), which we'll use to apply templates to our `Person` objects later.

````swift
// export Person class
context.setObject(Person.self, forKeyedSubscript: "Person")

// load Mustache.js
if let mustacheJSString = String(contentsOfFile:..., encoding:NSUTF8StringEncoding, error:nil) {
    context.evaluateScript(mustacheJSString)
}
````
````objective-c
// export Person class
context[@"Person"] = [Person class];

// load Mustache.js
NSString *mustacheJSString = [NSString stringWithContentsOfFile:... encoding:NSUTF8StringEncoding error:nil];
[context evaluateScript:mustacheJSString];
````


### 3) JavaScript Data & Processing

Here's a look at our simple JSON example and the code that will process it to create new `Person` instances. 

> Note: JavaScriptCore translates Objective-C/Swift method names to be JavaScript-compatible. Since JavaScript doesn't have named parameters, any external parameter names are converted to camel-case and appended to the function name. In this example, the Objective-C method `createWithFirstName:lastName:` becomes `createWithFirstNameLastName()` in JavaScript.

````JavaScript
var loadPeopleFromJSON = function(jsonString) {
    var data = JSON.parse(jsonString);
    var people = [];
    for (i = 0; i < data.length; i++) {
        var person = Person.createWithFirstNameLastName(data[i].first, data[i].last);
        person.birthYear = data[i].year;
        
        people.push(person);
    }
    return people;
}
````
````JSON
[
    { "first": "Grace",     "last": "Hopper",   "year": 1906 },
    { "first": "Ada",       "last": "Lovelace", "year": 1815 },
    { "first": "Margaret",  "last": "Hamilton", "year": 1936 }
]
````


### 4) Tying It All Together

All that remains is to load the JSON data, call into the `JSContext` to parse the data into an array of `Person` objects, and render each `Person` using a Mustache template:

````swift
// get JSON string
let peopleJSON = try! String(contentsOfFile: ..., encoding: NSUTF8StringEncoding)

// get load function
let load = context.objectForKeyedSubscript("loadPeopleFromJSON")
// call with JSON and convert to an Array
if let people = load.callWithArguments([peopleJSON]).toArray() as? [Person] {
    
    // get rendering function and create template
    let mustacheRender = context.objectForKeyedSubscript("Mustache").objectForKeyedSubscript("render")
    let template = "{% raw %}{{getFullName}}, born {{birthYear}}{% endraw %}"

    // loop through people and render Person object as string
    for person in people {
        print(mustacheRender.callWithArguments([template, person]))
    }
}

// Output:
// Grace Hopper, born 1906
// Ada Lovelace, born 1815
// Margaret Hamilton, born 1936
````
````objective-c
// get JSON string
NSString *peopleJSON = [NSString stringWithContentsOfFile:... encoding:NSUTF8StringEncoding error:nil];
    
// get load function
JSValue *load = context[@"loadPeopleFromJSON"];
// call with JSON and convert to an NSArray
JSValue *loadResult = [load callWithArguments:@[peopleJSON]];
NSArray *people = [loadResult toArray];
    
// get rendering function and create template
JSValue *mustacheRender = context[@"Mustache"][@"render"];
NSString *template = @"{% raw %}{{getFullName}}, born {{birthYear}}{% endraw %}";

// loop through people and render Person object as string
for (Person *person in people) {
   NSLog(@"%@", [mustacheRender callWithArguments:@[template, person]]);
}

// Output:
// Grace Hopper, born 1906
// Ada Lovelace, born 1815
// Margaret Hamilton, born 1936
````


* * *


How can you use JavaScript in your apps? JavaScript snippets could be the basis for user-defined plugins that ship alongside yours. If your product started out on the web, you may have existing infrastructure that can be used with only minor changes. Or if *you* started out as a programmer on the web, you might relish the chance to get back to your scripty roots. Whatever the case, JavaScriptCore is too well-built and powerful to ignore.


