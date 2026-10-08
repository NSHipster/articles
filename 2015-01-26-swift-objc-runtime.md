---
title: Swift & the Objective-C Runtime
author: Nate Cook
category: "Swift"
tags: swift
excerpt: "Even when written without a single line of Objective-C code, every Swift app executes inside the Objective-C runtime, opening up a world of dynamic dispatch and associated runtime manipulation. To be sure, this may not always be the case—Swift-only frameworks, whenever they come, may lead to a Swift-only runtime. But as long as the Objective-C runtime is with us, let's use it to its fullest potential."
status:
    swift: 4.2
    reviewed: September 19, 2015
---

Even when written without a single line of Objective-C code, every Swift app executes inside the Objective-C runtime, opening up a world of dynamic dispatch and associated runtime manipulation. To be sure, this may not always be the case—Swift-only frameworks, whenever they come, may lead to a Swift-only runtime. But as long as the Objective-C runtime is with us, let's use it to its fullest potential.

This week we take a new, Swift-focused look at two runtime techniques covered on NSHipster back when Objective-C was the only game in town: [associated objects](/associated-objects/) and [method swizzling](/method-swizzling/).

> *Note:* This post primarily covers the use of these techniques in Swift—for the full run-down, please refer to the original articles.


## Associated Objects

Swift extensions allow for great flexibility in adding to the functionality of existing Cocoa classes, but they're limited in the same way as their Objective-C brethren, categories. Namely, you can't add a property to an existing class via an extension.

Happily, Objective-C *associated objects* come to the rescue. For example, to add a `descriptiveName` property to all the view controllers in a project, we simply add a computed property using `objc_get/setAssociatedObject()` in the backing `get` and `set` blocks:

````swift
extension UIViewController {
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }

    var descriptiveName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
````

> Note the use of `static var` in a private nested `struct`—this pattern creates the static associated object key we need but doesn't muck up the global namespace.


## Method Swizzling

Sometimes for convenience, sometimes to work around a bug in a framework, or sometimes because there's just no other way, you need to modify the behavior of an existing class's methods. Method swizzling lets you swap the implementations of two methods, essentially overriding an existing method with your own while keeping the original around.

In this example, we swizzle `UIViewController`'s `viewWillAppear` method to print a message any time a view is about to appear on screen. The swizzling happens in the initializer of the static property `swizzleViewWillAppear`, which runs only once (see note below); the replacement implementation is in the `nsh_viewWillAppear` method:

````swift
extension UIViewController {
    static let swizzleViewWillAppear: Void = {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.nsh_viewWillAppear(_:))

        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
        else {
            return
        }

        let didAddMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(UIViewController.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()

    // MARK: - Method Swizzling

    @objc dynamic func nsh_viewWillAppear(_ animated: Bool) {
        self.nsh_viewWillAppear(animated)
        if let name = self.descriptiveName {
            print("viewWillAppear: \(name)")
        } else {
            print("viewWillAppear: \(self)")
        }
    }
}
````


### load vs. initialize (Swift Edition)

The Objective-C runtime typically calls two class methods automatically when loading and initializing classes in your app's process: `load` and `initialize`. In the full article on [method swizzling](/method-swizzling/), Mattt writes that swizzling should *always* be done in `load()`, for safety and consistency. `load` is called only once per class and is called on each class that is loaded. On the other hand, a single `initialize` method can be called on a class and all its subclasses, which are likely to exist for `UIViewController`, or not called at all if that particular class isn't ever messaged.

Unfortunately, Swift doesn't allow either one: overriding `load` or `initialize` in a Swift class or extension is a compile-time error. Instead, the swizzling must be triggered explicitly, as early as possible, such as from `application(_:didFinishLaunchingWithOptions:)` in the app delegate:

````swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    _ = UIViewController.swizzleViewWillAppear
    return true
}
````

Because a `static let` is initialized lazily and exactly once, even when accessed from multiple threads, the implementations can't accidentally be swapped back by a second call. Depending on the classes you're modifying, swizzling at launch may be sufficient and should guarantee your code is executed every time.


* * *


In closing, remember that tinkering with the Objective-C runtime should be much more of a last resort than a place to start. Modifying the frameworks that your code is based upon, as well as any third-party code you run, is a quick way to destabilize the whole stack. Tread softly!
