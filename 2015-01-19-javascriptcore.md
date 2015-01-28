---
title: "JavaScriptCore"
author: Nate Cook
category: "Cocoa"
excerpt: "Introduced with OS X Mavericks and iOS 7, the JavaScriptCore framework puts an Objective-C wrapper around WebKit's JavaScript engine, providing easy, fast, and safe access to the world's most prevalent language. Love it or hate it, JavaScript's ubiquity has led to an explosion of developers, tools, and resources along with ultra-fast virtual machines like the one built into OS X and iOS."
translator: April Peng
excerpt: "JavaScriptCore 库在 OS X Mavericks 和 iOS 7 被引入，把 WebKit 的 JavaScript 引擎用 Objective-C 封装，提供了简单，快速以及安全的方式接入世界上最流行的语言。不管你爱它还是恨它，JavaScript 的普遍存在使得程序员，工具以及融合到 OS X 和 iOS 里这样超快的虚拟机都大幅增长。"
---

An updated ranking of programming language popularity is [out this week](http://redmonk.com/sogrady/category/programming-languages/), showing Swift leaping upward through the ranks from 68th to 22nd, while Objective-C holds a strong lead up ahead at #10. Both, however, are blown away by the only other language allowed to run natively on iOS: the current champion, JavaScript.

[这个星期]（http://redmonk.com/sogrady/category/programming-languages/）流行编程语言的最新排名结果是，Swift 迅速从第68位跃升到22位，而 Objective-C 仍然稳固的占据在第 10 位。但是，说到允许在 iOS 上运行的其他语言 上，这两个都被甩的很远：当前的冠军是 JavaScript。

Introduced with OS X Mavericks and iOS 7, the JavaScriptCore framework puts an Objective-C wrapper around WebKit's JavaScript engine, providing easy, fast, and safe access to the world's most prevalent language. Love it or hate it, JavaScript's ubiquity has led to an explosion of developers, tools, and resources along with ultra-fast virtual machines like the one built into OS X and iOS.

JavaScriptCore 库在 OS X Mavericks 和 iOS 7 被引入，把 WebKit 的 JavaScript 引擎用 Objective-C 封装，提供了简单，快速以及安全的方式接入世界上最流行的语言。不管你爱它还是恨它，JavaScript 的普遍存在使得程序员，工具以及融合到 OS X 和 iOS 里这样超快的虚拟机都大幅增长。

So come, lay aside bitter debates about dynamism and type safety, and join me for a tour of *JavaScriptCore.*

这样一来，先抛开动态和类型安全的痛苦辩论，让我带你一起来做一个 *JavaScriptCore 的观光。*

* * *

### `JSContext` / `JSValue`

`JSContext` is an environment for running JavaScript code. A `JSContext` instance represents the global object in the environment—if you've written JavaScript that runs in a browser, `JSContext` is analogous to `window`. After creating a `JSContext`, it's easy to run JavaScript code that creates variables, does calculations, or even defines functions:

`JSContext` 是运行 JavaScript 代码的环境。一个 `JSContext` 是一个全局环境的实例，如果你写过一个在浏览器内运行的 JavaScript，`JSContext` 类似于 `window`。创建一个 `JSContext` 后，可以很容易地运行 JavaScript 代码来创建变量，做计算，甚至定义方法：

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

代码的最后一行，任何*出自* `JSContext` 的值都被包裹在一个 `JSValue` 对象中。像 JavaScript 这样的动态语言需要一个动态类型，所以 `JSValue` 包装了每一个可能的 JavaScript 值：字符串和数字；数组，对象和方法；甚至错误和特殊的 JavaScript 值诸如 `null` 和 `undefined`。

`JSValue` includes a host of methods for accessing its underlying value as the correct Foundation type, including:

`JSValue` 包括一系列方法用于访问其可能的值以保证有正确的 Foundation 类型，包括：

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

从上面的例子中得到 `tripleNum` 的值，只需使用适当的方法：

````swift
println("Tripled: \(tripleNum.toInt32())")
// Tripled: 30
````
````objective-c
NSLog(@"Tripled: %d", [tripleNum toInt32]);
// Tripled: 30
````


### Subscripting Values

### 下标值

We can easily access any values we've created in our `context` using subscript notation on both `JSContext` and `JSValue` instances. `JSContext` requires a string subscript, while `JSValue` allows either string or integer subscripts for delving down into objects and arrays:

对 `JSContext` 和 `JSValue` 实例使用下标的方式我们可以很容易地访问我们之前创建的 `context` 的任何值。`JSContext` 需要一个字符串下标，而 `JSValue` 允许使用字符串或整数标来得到里面的对象和数组：

````swift
let names = context.objectForKeyedSubscript("names")
let initialName = names.objectAtIndexedSubscript(0)
println("The first name: \(initialName.toString())")
// The first name: Grace
````
````objective-c
JSValue *names = context[@"names"];
JSValue *initialName = names[0];
NSLog(@"The first name: %@", [initialName toString]);
// The first name: Grace
````

> Swift shows its youth, here—while Objective-C code can take advantage of subscript notation, Swift currently only exposes the [raw methods](/object-subscripting/) that should make such subscripting possible: `objectAtKeyedSubscript()` and `objectAtIndexedSubscript()`.

> Swift 展示了它的青涩，在这里，Objective-C 代码可以利用下标表示法，Swift 目前只公开[原始方法]（/object-subscripting/）来让下标成为可能：`objectAtKeyedSubscript()` 和 `objectAtIndexedSubscript()`。


### Calling Functions

### 调用方法

With a `JSValue` that wraps a JavaScript function, we can call that function directly from our Objective-C/Swift code using Foundation types as parameters. Once again, JavaScriptCore handles the bridging without any trouble:

`JSValue` 包装了一个 JavaScript 函数，我们可以从 Objective-C / Swift 代码中使用 Foundation 类型作为参数来直接调用该函数。再次，JavaScriptCore 很轻松的处理了这个桥接：

````swift
let tripleFunction = context.objectForKeyedSubscript("triple")
let result = tripleFunction.callWithArguments([5])
println("Five tripled: \(result.toInt32())")
````
````objective-c
JSValue *tripleFunction = context[@"triple"];
JSValue *result = [tripleFunction callWithArguments:@[@5] ];
NSLog(@"Five tripled: %d", [result toInt32]);
````


### Exception Handling

### 错误处理

`JSContext` has another useful trick up its sleeve: by setting the context's `exceptionHandler` property, you can observe and log syntax, type, and runtime errors as they happen. `exceptionHandler` is a callback handler that receives a reference to the `JSContext` and the exception itself:

`JSContext` 还有另外一个有用的招数：通过设置上下文的 `exceptionHandler` 属性，你可以观察和记录语法，类型以及运行时错误。 `exceptionHandler` 是一个接收一个 `JSContext` 引用和异常本身的回调处理：

````swift
context.exceptionHandler = { context, exception in
    println("JS Error: \(exception)")
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

## JavaScript 调用

Now we know how to extract values from a JavaScript environment and call functions defined therein. What about the reverse? How can we get access our custom objects and methods, defined in Objective-C or Swift, from within the JavaScript realm?

现在我们知道了如何从 JavaScript 环境中提取值以及如何调用其中定义的函数。那么反向呢？我们怎样才能从 JavaScript 访问我们在 Objective-C 或 Swift 定义的对象和方法？

There are two main ways of giving a `JSContext` access to our native client code: blocks and the `JSExport` protocol.

让 'JSContext` 访问我们的本地客户端代码的方式主要有两种：block 和 `JSExport` 协议。

### Blocks

When an Objective-C block is assigned to an identifier in a `JSContext`, JavaScriptCore automatically wraps the block in a JavaScript function. This makes it simple to use Foundation and Cocoa classes from within JavaScript—again, all the bridging happens for you. Witness the full power of `CFStringTransform`, now accessible to JavaScript:

当一个 Objective-C block
被赋给 `JSContext` 里的一个标识符，JavaScriptCore 会自动的把 block 封装在 JavaScript 函数里。这使得在 JavaScript 中可以简单的使用 Foundation 和 Cocoa 类，所有的桥接都为你做好了。见证了 `CFStringTransform` 的强大威力，现在让我们来看看 JavaScript：

````swift
let simplifyString: @objc_block String -> String = { input in
    var mutableString = NSMutableString(string: input) as CFMutableStringRef
    CFStringTransform(mutableString, nil, kCFStringTransformToLatin, Boolean(0))
    CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, Boolean(0))
    return mutableString
}
context.setObject(unsafeBitCast(simplifyString, AnyObject.self), forKeyedSubscript: "simplifyString")

println(context.evaluateScript("simplifyString('안녕하새요!')"))
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

> There's another speedbump for Swift here—note that this only works for *Objective-C blocks*, not Swift closures. To use a Swift closure in a `JSContext`, it needs to be (a) declared with the `@objc_block` attribute, and (b) cast to `AnyObject` using Swift's knuckle-whitening `unsafeBitCast()` function.

> 在这儿，Swfit 还有一个坑，请注意，这仅适用于 *Objective-C 的 block*，而不是Swift 的闭包。要在 `JSContext` 中使用 Swift 闭包，它需要（a）与 `@ objc_block` 属性一起声明，以及（b）使用 Swift 那个令人恐惧的 `unsafeBitCast()` 函数转换为 `AnyObject` 。

#### Memory Management

####  内存管理

Since blocks can capture references to variables and `JSContext`s maintain strong references to all their variables, some care needs to be taken to avoid strong reference cycles. Avoid capturing your `JSContext` or any `JSValue`s inside a block. Instead, use `[JSContext currentContext]` to get the current context and pass any values you need as parameters.

由于 block 可以保有变量引用，而且 `JSContext` 也强引用它所有的变量，为了避免强引用循环需要特别小心。避免保有你的 `JSContext` 或一个 block 里的任何 `JSValue`。相反，使用 `[JSContext currentContext]` 得到当前上下文，并把你需要的任何值用参数传递。


### `JSExport` Protocol

### `JSExport` 协议

Another way to use our custom objects from within JavaScript code is to add conformance to the `JSExport` protocol. Whatever properties, instance methods, and class methods we declare in our `JSExport`-inherited protocol will *automatically* be available to any JavaScript code. We'll see how in the following section.

另一种在 JavaScript 代码中使用我们的自定义对象的方法是添加 `JSExport` 协议。无论我们在 'JSExport` 里声明的属性，实例方法还是类方法，继承的协议都会*自动的*提供给任何 JavaScript 代码。我们将在下一节看到。

## JavaScriptCore in Practice

## JavaScriptCore 实战

Let's build out an example that will use all these different techniques—we'll define a `Person` model that conforms to the `JSExport` sub-protocol `PersonJSExports`, then use JavaScript to create and populate instances from a JSON file. Who needs `NSJSONSerialization` when there's an entire JVM lying around?

让我们做一个使用了所有这些不同的技术的示例 - 我们将定义一个 `Person` 模型符合 `JSExport` 子协议 `PersonJSExports` 的例子，然后使用 JavaScript 从 JSON 文件中创建并填充实例。都有一个完整的 JVM 在那儿了，谁还需要 `NSJSONSerialization`？

### 1) `PersonJSExports` and `Person`

### 1) `PersonJSExports` 和 `Person`

Our `Person` class implements the `PersonJSExports` protocol, which specifies what properties should be available in JavaScript. 

我们的 `Person` 类实现了 `PersonJSExports` 协议，该协议规定哪些属性在 JavaScript 中可用。

> The `create...` class method is necessary because JavaScriptCore does *not* bridge initializers—we can't simply say `var person = new Person()` the way we would with a native JavaScript type.

> 由于 JavaScriptCore *没有* 初始化，所以 `create...` 类方法是必要的，我们不能像原生的 JavaScript 类型那样简单地用 'var person = new Person()`。

````swift
// Custom protocol must be declared with `@objc`
@objc protocol PersonJSExports : JSExport {
    var firstName: String { get set }
    var lastName: String { get set }
    var birthYear: NSNumber? { get set }
    
    func getFullName() -> String

    /// create and return a new Person instance with `firstName` and `lastName`
    class func createWithFirstName(firstName: String, lastName: String) -> Person
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

### 2) `JSContext` 配置

Before we can use the `Person` class we've created, we need to export it to the JavaScript environment. We'll also take this moment to import the [Mustache JS library](http://mustache.github.io/), which we'll use to apply templates to our `Person` objects later.

之前，我们可以用我们已经创建的 `Person` 类，我们需要将其导出到 JavaScript 环境。我们也将借此导入 [Mustache JS library]（http://mustache.github.io/），我们将应用模板到我们的 `Person` 对象。

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

### 3) JavaScript 数据和进程

Here's a look at our simple JSON example and the code that will process it to create new `Person` instances.

下面就来看看我们简单的 JSON 例子，这段代码将创建新的 `Person` 实例。 

> Note: JavaScriptCore translates Objective-C/Swift method names to be JavaScript-compatible. Since JavaScript doesn't have named parameters, any external parameter names are converted to camel-case and appended to the function name. In this example, the Objective-C method `createWithFirstName:lastName:` becomes `createWithFirstNameLastName()` in JavaScript.

> 注意：JavaScriptCore 转换的 Objective-C / Swift 方法名是 JavaScript 兼容的。由于 JavaScript 没有参数 名称，任何外部参数名称都会被转换为驼峰形式并且附加到函数名后。在这个例子中，Objective-C 的方法 `createWithFirstName:lastName:` 变成了在JavaScript中的 `createWithFirstNameLastName()`。

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

### 4) 加到一起

All that remains is to load the JSON data, call into the `JSContext` to parse the data into an array of `Person` objects, and render each `Person` using a Mustache template:

剩下的就是加载 JSON 数据，调用 `JSContext` 将数据解析成 `Person` 对象的数组，并用 Mustache 模板呈现每个`Person`：

````swift
// get JSON string
if let peopleJSON = NSString(contentsOfFile:..., encoding: NSUTF8StringEncoding, error: nil) {

    // get load function
    let load = context.objectForKeyedSubscript("loadPeopleFromJSON")
    // call with JSON and convert to an array of `Person`
    if let people = load.callWithArguments([peopleJSON]).toArray() as? [Person] {
  
        // get rendering function and create template
        let mustacheRender = context.objectForKeyedSubscript("Mustache").objectForKeyedSubscript("render")
        let template = "{% raw %}{{getFullName}}, born {{birthYear}}{% endraw %}"
      
        // loop through people and render Person object as string
        for person in people {
            println(mustacheRender.callWithArguments([template, person]))
        }
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

在你的应用程序如何使用 JavaScript？JavaScript 代码段可能是附带应用一起发布的基本的用户定义的插件。如果你的产品开始在 web 上发布，你可能将现有的代码稍加改动即可适应需求。或者，如果*你*开始成为一个 web 程序员，你可能会享受追溯脚本根源的机会。无论是哪种情况，JavaScriptCore 都是精心打造和强大的，不容忽视。


