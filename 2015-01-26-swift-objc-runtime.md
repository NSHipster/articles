---
title: Swift & the Objective-C Runtime
author: Nate Cook
category: "Swift"
translator: Croath Liu
excerpt: "即使一行 Objective-C 代码也不写，每一个 Swift app 都会在 Objective-C runtime 中运行，开启动态任务分发和运行时对象关联的世界。更确切地说，可能在仅使用 Swift 库的时候只运行 Swift runtime。但 Objective-C runtime 与我们共处了如此长的时间，我们也应该将其发挥到极致。 <br><br>本周的 NShipster 我们将以 Swift 视角来观察这两个运行时中关于关联对象和方法交叉的技术。"
---

即使一行 Objective-C 代码也不写，每一个 Swift app 都会在 Objective-C runtime 中运行，开启动态任务分发和运行时对象关联的世界。更确切地说，可能在仅使用 Swift 库的时候只运行 Swift runtime。但 Objective-C runtime 与我们共处了如此长的时间，我们也应该将其发挥到极致。

本周的 NShipster 我们将以 Swift 视角来观察这两个运行时中关于关联对象([associated objects](/associated-objects/))和方法交叉([method swizzling](/method-swizzling/))的技术。

> *提醒：* 本文主要从 Swift 角度讲这两种技术，如果需要更详细的解释，请参考上述两篇原文。

## 关联对象(Associated Objects)

Swift extension 能对已经存在 Cocoa 类中添加极为丰富的功能，但它的兄弟 Objective-C 的 category 却逊色了不少。比如说 Objective-C 中的 extension 就无法向既有类添加属性。

令人庆幸的是 Objective-C 的 *关联对象* 可以缓解这种局面。例如要向一个工程里所有的 view controllers 中添加一个 `descriptiveName` 属性，我们可以简单的使用  `objc_get/setAssociatedObject()`来填充其 `get` 和 `set` 块：

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
                    UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                )
            }
        }
    }
}
````

> 注意，在私有嵌套 `struct` 中使用 `static var`，这样会生成我们所需的关联对象键，但不会污染整个命名空间。

## 方法交叉(Method Swizzling)

有时为了方便，也有可能是解决某些框架内的 bug，或者别无他法时，需要修改一个已经存在类的方法的行为。方法交叉可以让你交换两个方法的实现，相当于是用你写的方法来重载原有方法，并且还能够是原有方法的行为保持不变。

这个例子中我们交叉 `UIViewController` 的 `viewWillAppear` 方法以打印出每一个在屏幕上显示的 view。方法交叉发生在 `initialize` 类方法调用时(如下代码所示)；替代的实现在 `nsh_viewWillAppear` 方法中：

````swift
extension UIViewController {
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }

        // make sure this isn't a subclass        
        if self !== UIViewController.self {
            return
        }

        dispatch_once(&Static.token) {
            let originalSelector = Selector("viewWillAppear:")
            let swizzledSelector = Selector("nsh_viewWillAppear:")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
    
    // MARK: - Method Swizzling
    
    func nsh_viewWillAppear(animated: Bool) {
        self.nsh_viewWillAppear(animated)
        if let name = self.descriptiveName {
            println("viewWillAppear: \(name)")
        } else {
            println("viewWillAppear: \(self)")
        }
    }
}
````


### load vs. initialize (Swift 版本)

Objective-C runtime 理论上会在加载和初始化类的时候调用两个类方法： `load` and `initialize`。在讲解 [method swizzling](/method-swizzling/) 的原文中 Mattt 老师指出出于安全性和一致性的考虑，方法交叉过程 *永远* 会在 `load()` 方法中进行。每一个类在加载时只会调用一次 `load` 方法。另一方面，一个 `initialize` 方法可以被一个类和它所有的子类调用，比如说 `UIViewController` 的该方法，如果那个类没有被传递信息，那么它的 `initialize` 方法就永远不会被调用了。

不幸的是，在 Swift 中 `load` 类方法永远不会被 runtime 调用，因此方法交叉就变成了不可能的事。但我们还有两个办法：

- **在 `initialize` 中实现方法交叉**
这种做法很安全，你只需要确保相关的方法交叉在一个 `dispatch_once` 中就好了(这也是最推荐的做法)。

- **在 app delegate 中实现方法交叉** 
不像上面通过类扩展进行方法交叉，而是简单地在 app delegate 的 `application(_:didFinishLaunchingWithOptions:)` 方法调用时中执行相关代码也是可以的。基于对类的修改，这种方法应该就足够确保这些代码会被执行到。


* * *


最后，请记住仅在不得已的情况下使用 Objective-C runtime。随便修改基础框架或所使用的三方代码是毁掉你的应用的绝佳方法哦。请务必要小心哦。



