---
title: "Quick Look Debugging"
author: Nate Cook
category: "Xcode"
translator: April Peng
excerpt: "调试可能会是一个讽刺的实践。我们创建了各种任务来告诉我们的品脱大小的超级计算机代表我们来完成千差万别和不可估量的任务，但为了理解这些相同的程序，我们告诉计算机等等*我们*"
---

调试可能会是一个讽刺的实践。我们创建了各种任务来告诉我们的品脱大小的超级计算机代表我们来完成千差万别和不可估量的任务，但为了理解这些相同的程序，我们告诉计算机等等*我们*

例如，假设我试图找出为什么我的应用程序里的 `UINavigationBar` 没有按我预计的显示。为了调查清楚，我可能会使用调试器来看看诸如我在导航栏上设置的 `UIColor` 实例，这东西*到底是*什么颜色？

![UIColor in Debug](http://nshipster.s3.amazonaws.com/quicklook-debug.gif)

Hold 住！并没有试图找出如何将这些组件加在一起的办法。*其实有一个更好的办法。*

自从版本 5 开始，Xcode 在调试器已经附带了快速查看显示。正如你可以在桌面上快速点击空格键来查看文件的内容，在 Xcode 中你可以用可视化的快速查看各种数据类型。在我们的 `color` 变量上按空格键立即给出了一个答案，你脑海中应该马上浮现起了需要 RGB 转化计算：

![UIColor Quick Look](http://nshipster.s3.amazonaws.com/quicklook-color.gif)

* * *

同时，你还可以直接从代码的调试中调用快速查看。比如下面的方法，`buildPathWithRadius(_:steps:loopCount:)`。它创造了某种形式的 `UIBezierPath`，但你已经忘了，而这段代码到底是否工作？

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

为了看到结果，你肯定可以为这个 bezier 路径新建一个自定义视图或画成一个 `UIImage`。但更好的是，你可以在方法结尾插入一个断点并把鼠标移上去查看 `path`：

![Spiral UIBezierPath Quick Look](http://nshipster.s3.amazonaws.com/quicklook-spiral.gif)

它是螺旋的！

* * *

### 内置类型

快速查看支持大多数你想要可视化的数据类型。Xcode 已经为你覆盖了以下几种类型：

> - **图片：** `UIImage`，`NSImage`，`UIImageView`，`NSImageView`，`CIImage`，和 `NSBitmapImageRep` 都可以快速查看。
> - **颜色：** `UIColor` 和 `NSColor`。 （抱歉，`CGColor`。）
> - **字符串：** `NSString` 和 `NSAttributedString`。
> - **几何：** `UIBezierPath` 和 `NSBezierPath`，以及 `CGPoint`，`CGRect`，和 `CGSize`。
> - **地区** `CLLocation` 将显示一个很大的，互动的映射位置，并显示高度和精度的细节。
> - **URLs：** `NSURL` 将显示 URL 所指的本地或远程的内容。
> - **光标：** `NSCursor`，为我们中间的光标指示。
> - **SpriteKit：** `SKSpriteNode`，`SKShapeNode`，`SKTexture`，和 `SKTextureAtlas` 都会被显示。
> - **数据：** `NSData` 将漂亮的显示出偏移的十六进制和 ASCII 值。
> - **视图：** 最后但并非最不重要的，任何 `UIView` 子类都将在快速查看弹出框中显示其内容，方便极了。

更重要的是，这些快速查看弹出窗口通常包括一个按钮，用来在相关的应用程序打开该内容。对图像数据（以及视图，光标和 SpriteKit 类型）将提供一个在预览中打开的选项。远程 URL 可以在 Safari 浏览器中打开；本地的可以在相关应用程序中打开。最后，纯文本和格式化字符串数据同样可以在 TextEdit 中打开。


### 自定义类型

对于不在这些内置类型范围内的，Xcode 6 增加了快速查看自定义对象。实现方式简单得不能再简单了，添加一个 `debugQuickLookObject()` 方法到任何 `NSObject` 派生类，就行了。 `debugQuickLookObject()` 可以返回任何上述的内置类型，你需要为自定义类型配置的是：

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

总之，快速查看能够允许我们遍历较小部分功能的数据，让我们能更直观的了解我们的代码。这种直接查看之前模糊的数据类型使得一些 Swift Playground 即时性的加入到我们的主要代码库中。显示图像？可视化数据？绘制文本？计算机已经做得很好了！从现在开始就交给它们来做吧。

