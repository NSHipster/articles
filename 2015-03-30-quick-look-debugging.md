---
title: "Quick Look Debugging"
author: Nate Cook
category: "Xcode"
excerpt: "Debugging can be an exercise in irony. We create programs that tell our pint-sized supercomputers to complete infinitely varied and incalculable tasks on our behalf, yet when trying to understand those same programs, we tell the computers to wait for *us.*"
status:
    swift: 1.2
---

Debugging can be an exercise in irony. We create programs that tell our pint-sized supercomputers to complete infinitely varied and incalculable tasks on our behalf, yet when trying to understand those same programs, we tell the computers to wait for *us.* 

For example, suppose I'm trying to figure out why the `UINavigationBar` in my app doesn't appear as I expected. To investigate, I might use the debugger to look at the `UIColor` instance I'm setting on the navigation bar—what color *is* this, exactly?

![UIColor in Debug]({{ site.asseturl }}/quicklook-debug.gif)

Hold on! No more trying to figure out how those components add together. *There's a better way.*

Since version 5, Xcode has shipped with Quick Look display in the debugger. Just as you can inspect the contents of a file on the Desktop with a quick tap of the space bar, in Xcode you can use Quick Look to see a visual representation of a variety of datatypes. Tapping the space bar on our `color` variable gives an instant answer—no off-the-top-of-your-head RGB calculations required:

![UIColor Quick Look]({{ site.asseturl }}/quicklook-color.gif)

* * *

You can also invoke Quick Look while debugging directly from your code. Consider the following method, `buildPathWithRadius(_:steps:loopCount:)`. It creates a `UIBezierPath` of some kind, but you've forgotten which, and does this code even work?

```swift
func buildPathWithRadius(radius: CGFloat, steps: CGFloat, loopCount: CGFloat) -> UIBezierPath {
    let away = radius / steps
    let around = loopCount / steps * 2 * CGFloat(M_PI)
    
    let points = map(stride(from: 1, through: steps, by: 1)) { step -> CGPoint in
        let x = cos(step * around) * step * away
        let y = sin(step * around) * step * away
        
        return CGPoint(x: x, y: y)
    }
    
    let path = UIBezierPath()
    path.moveToPoint(CGPoint.zeroPoint)
    for point in points {
        path.addLineToPoint(point)
    }
    
    return path
}
```
```objective-c
- (UIBezierPath *)buildPathWithRadius:(CGFloat)radius steps:(CGFloat)steps loopCount:(CGFloat)loopCount {
    CGFloat x, y;
    CGFloat away = radius / steps;
    CGFloat around = loopCount / steps * 2 * M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    
    for (int i = 1; i <= steps; i++) {
        x = cos(i * around) * i * away;
        y = sin(i * around) * i * away;
        
        [path addLineToPoint:CGPointMake(x, y)];
    }
    
    return path;
}
```

To see the result, you could surely create a custom view for the bezier path or draw it into a `UIImage`. But better yet, you could insert a breakpoint at the end of the method and mouse over `path`:

![Spiral UIBezierPath Quick Look]({{ site.asseturl }}/quicklook-spiral.gif)

Spiraltastic!

* * *

### Built-In Types

Quick Look can be used with most of the datatypes you'll want to visualize right out of the box. Xcode already has you covered for the following types:

> - **Images:** `UIImage`, `NSImage`, `UIImageView`, `NSImageView`, `CIImage`, and `NSBitmapImageRep` are all visible via Quick Look.
> - **Colors:** `UIColor` and `NSColor`. (Sorry, `CGColor`.)
> - **Strings:** `NSString` and `NSAttributedString`.
> - **Geometry:** `UIBezierPath` and `NSBezierPath` along with `CGPoint`, `CGRect`, and `CGSize`.
> - **Locations:** `CLLocation` gives a large, interactive view of the mapped location, with details about altitude and accuracy in an overlay.
> - **URLs:** `NSURL` is represented by a view showing the local or remote content addressed by the URL.
> - **Cursors:** `NSCursor`, for the cursored among us.
> - **SpriteKit:** `SKSpriteNode`, `SKShapeNode`, `SKTexture`, and `SKTextureAtlas` are all represented.
> - **Data:** `NSData` has a great view showing hex and ASCII values with their offset.
> - **Views:** Last but not least, any `UIView` subclass will display its contents in a Quick Look popup—so convenient.

What's more, these Quick Look popups often include a button that will open the content in a related application. Image data (as well as views, cursors, and SpriteKit types) offer an option to open in Preview. Remote URLs can be opened in Safari; local ones can be opened in the related application. Finally, plain-text and attributed string data can likewise be opened in TextEdit.


### Custom Types

For anything beyond these built-in types, Xcode 6 has added Quick Look for custom objects. The implementation couldn't be simpler—add a single `debugQuickLookObject()` method to any `NSObject`-derived class, and you're set. `debugQuickLookObject()` can then return any of the built-in types described above, configured for your custom type's needs:

```swift
func debugQuickLookObject() -> AnyObject {
    let path = buildPathWithRadius(radius, steps: steps, loopCount: loopCount)
    return path
}
```
```objective-c
- (id)debugQuickLookObject {
    UIBezierPath *path = [self buildPathWithRadius:self.radius steps:self.steps loopCount:self.loopCount];
    return path;
}
```

* * *

In sum, Quick Look enables a more direct relationship with the data we manipulate in our code by allowing us to iterate over smaller pieces of functionality. This direct view into previously obfuscated datatypes brings some of the immediacy of a Swift Playground right into our main codebase. Displaying images? Visualizing data? Rendering text? Computers are so good at all that! Let's let them do it from now on.

