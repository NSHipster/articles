---
title: "IBInspectable&nbsp;/ IBDesignable"
category: Xcode
author: Nate Cook
excerpt: "Replacing an interface that requires us to memorize and type with one we can see and manipulate can be a enormous improvement. With `IBInspectable` and `IBDesignable`, Xcode 6 makes just such a substitution, building new interactions on top of old technologies."
status:
    swift: 1.0
---

Show, don't tell. Seeing is believing. A picture is worth a thousand <del>emails</del> words. 

Whatever the cliché, replacing an interface that requires us to memorize and type with one we can see and manipulate can be an enormous improvement. Xcode 6 makes just such a substitution, building new interactions on top of old technologies. With `IBInspectable` and `IBDesignable`, it's possible to build a custom interface for configuring your custom controls and have them rendered in real-time while designing your project.


## IBInspectable

`IBInspectable` properties provide new access to an old feature: user-defined runtime attributes. Currently accessible from the identity inspector, these attributes have been available since before Interface Builder was integrated into Xcode. They provide a powerful mechanism for configuring any key-value coded property of an instance in a NIB, XIB, or storyboard:

![User-Defined Runtime Attributes](http://nshipster.s3.amazonaws.com/IBInspectable-runtime-attributes.png)

While powerful, runtime attributes can be cumbersome to work with. The key path, type, and value of an attribute need to be set on each instance, without any autocompletion or type hinting, which requires trips to the documentation or a custom subclass's source code to double-check the settings. `IBInspectable` properties solve this problem outright: in Xcode 6 you can now specify any property as inspectable and get a user interface built just for your custom class.

For example, these properties in a `UIView` subclass update the backing layer with their values:

````swift
@IBInspectable var cornerRadius: CGFloat = 0 {
   didSet {
       layer.cornerRadius = cornerRadius
       layer.masksToBounds = cornerRadius > 0
   }
}
@IBInspectable var borderWidth: CGFloat = 0 {
   didSet {
       layer.borderWidth = borderWidth
   }
}
@IBInspectable var borderColor: UIColor? {
   didSet {
       layer.borderColor = borderColor?.CGColor
   }
}
````

Marked with `@IBInspectable` (or `IBInspectable` in Objective-C), they are easily editable in Interface Builder's inspector panel. Note that Xcode goes the extra mile here—property names are converted from camel- to title-case and related names are grouped together:

![IBInspectable Attribute Inspector](http://nshipster.s3.amazonaws.com/IBInspectable-inspectable.png)

Since inspectable properties are simply an interface on top of user-defined runtime attributes, the same list of types is supported: booleans, strings, and numbers (i.e., `NSNumber` or any of the numeric value types), as well as `CGPoint`, `CGSize`, `CGRect`, `UIColor`, and `NSRange`, adding `UIImage` for good measure.

> Those already familiar with runtime attributes will have noticed a bit of trickery in the example above. `UIColor` is the only color type supported, not the `CGColor` native to a view's backing `CALayer`. The `borderColor` computed property maps the `UIColor` (set via runtime attribute) to the layer's required `CGColor`.

### Making Existing Types Inspectable

Built-in Cocoa types can also be extended to have inspectable properties beyond the ones already in Interface Builder's attribute inspector. If you like rounded corners, you'll love this `UIView` extension:

````swift
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
````

Presto! A configurable border radius on any `UIView` you create.


## IBDesignable

As if that weren't enough, `IBDesignable` custom views also debut in Xcode 6. When applied to a `UIView` or `NSView` subclass, the `@IBDesignable` designation lets Interface Builder know that it should render the view directly in the canvas. This allows seeing how your custom views will appear without building and running your app after each change.

To mark a custom view as `IBDesignable`, prefix the class name with `@IBDesignable` (or the `IB_DESIGNABLE` macro in Objective-C). Your initializers, layout, and drawing methods will be used to render your custom view right on the canvas:

````swift
@IBDesignable
class MyCustomView: UIView {
    ...
}
````

![IBDesignable Live Preview](http://nshipster.s3.amazonaws.com/IBInspectable-designable.png)

The time-savings from this feature can't be overstated. Combined with `IBInspectable` properties, a designer or developer can easily tweak the rendering of a custom control to get the exact result she wants. Any changes, whether made in code or the attribute inspector, are immediately rendered on the canvas.

Moreover, any problems can be debugged without compiling and running the whole project. To kick off a debugging session right in place, simply set a breakpoint in your code, select the view in Interface Builder, and choose **Editor** ➔ **Debug Selected Views**.

Since the custom view won't have the full context of your app when rendered in Interface Builder, you may need to generate mock data for display, such as a default user profile image or generic weather data. There are two ways to add code for this special context:

> - `prepareForInterfaceBuilder()`: This method compiles with the rest of your code but is only executed when your view is being prepared for display in Interface Builder.

> - `TARGET_INTERFACE_BUILDER`: The `#if TARGET_INTERFACE_BUILDER` preprocessor macro will work in either Objective-C or Swift to conditionally compile the right code for the situation:

> ````swift
#if !TARGET_INTERFACE_BUILDER
    // this code will run in the app itself
#else
    // this code will execute only in IB
#endif
````


## IBCalculatorConstructorSet

What can you create with a combination of `IBInspectable` attributes in your `IBDesignable` custom view? As an example, let's update an old classic from [Apple folklore](http://www.folklore.org/StoryView.py?story=Calculator_Construction_Set.txt): the "Steve Jobs Roll Your Own Calculator Construction Set," Xcode 6-style ([gist](https://gist.github.com/natecook1000/4269059121ec247fbb90)):

![Calculator Construction Set](http://nshipster.s3.amazonaws.com/IBInspectable-CCS.gif)

* * *
<br>

That was almost a thousand words—let's see some more pictures. What are *you* creating with these powerful new tools? [Tweet an image](http://twitter.com/share?hashtags=IBInspectable) of your `IBInspectable` or `IBDesignable` creations with the hashtag `#IBInspectable`—we can all learn from seeing what's possible.
