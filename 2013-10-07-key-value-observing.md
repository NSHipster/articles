title: "Key-Value Observing"
author: Mattt Thompson
translator: change2hao
category: Cocoa
tag: nshipster, popular
excerpt: 问了几次研究NSBlock的人员：Key-Value Observing 在Cocoa框架里有着最不好用的API。它很难对付，啰嗦，令人迷惑。最糟糕的是，它的API掩盖了framework中很引人注目的特性。
---

问了几次研究NSBlock的人员：Key-Value Observing 在Cocoa框架里有着最不好用的API。它很难对付，啰嗦，令人迷惑。最糟糕的是，它的API掩盖了framework中很引人注目的特性。

当处理复杂的，有状态的系统，book-keeping对于保持清晰是很必要的。免的左手不知道右手做的事。随着时间的推移，对象需要一些方法来发布和订阅状态的改变。

在Objective-C和Cocoa中，有许多事件之间进行通信的方式，并且每个都有不同程度的形式和耦合

* NSNotification & NSNotificationCenter 提供了一个中央枢纽，一个应用的任何部分都可能通知或者被通知应用的其他部分的变化。唯一需要做的是要知道在寻找什么，主要是通知的名字。例如，UIApplicationDidReceiveMemoryWarningNotification是给应用发了一个内存不足的信号。
* Key-Value Observing 允许ad-hoc，通过在特定对象之间监听一个特定的keypath的改变进行事件内省。例如：一个 ProgressView 可以观察 网络请求的 numberOfBytesRead 来更新它自己的 progress 属性。
* Delegate 是一个流行的传递事件的设计模式，通过定义一系列的方法来传递给指定的处理对象。例如：UIScrollView每次它的scroll offset改变的时候都会发送 scrollViewDidScroll: 到它的代理
* Callbacks 不管是像 NSOperation里的completionBlock（当isFinished==YES的时候会触发），还是C里边的函数指针，传递一个函数钩子比如SCNetworkReachabilitySetCallback(3)

在所有这些方法里，Key-Value Observing 是最不好理解的，所以这周NSHipster将致力于提供一些最佳实践来解决这一局面。对于一个普通用户，这个练习可能没什么意义，但是对订阅了本博客的人来说确很有用。

<NSKeyValueObserving> 或者 KVO，是一个非正式协议，它定义了对象之间观察和通知状态改变的通用机制的。作为一个非正式协议，你不会看到类的这种引以为豪的一致性(只是隐式的假定了NSObject的所有子类)。

KVO的中心思想其实是相当引人注意的。任意一个对象都可以订阅以便被通知到其他对象状态的改变。这个过程大部分是内建的，自动的，透明的。

> 题外话，这种观察者模式类似的表现是最现代框架的秘诀，比如 Backbone.js 和 Ember.js

####Subscribing

对象可以让观察者添加一个特定的key path，这个在[这篇文章](http://nshipster.com/kvc-collection-operators/)中描述过，其实就是用点符号分隔的key指定了一系列的属性。在大多数情况下，这些都是对象的顶级属性。

添加一个观察者的方法是  –addObserver:forKeyPath:options:context:

```
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
```
* observer:注册KVO通知的对象。观察者必须实现 key-value observing 方法
* keyPath:观察者的属性，值不能是nil
* options:NSKeyValueObservingOptions的组合，它指定了观察通知中包含了什么，可以查看 "NSKeyValueObservingOptions".
* context:传给observer参数的随机数据

让这个API不堪入目的事实就是最后两个参数经常是0和NULL

options 代表 NSKeyValueObservingOptions的位掩码，需要注意NSKeyValueObservingOptionNew & NSKeyValueObservingOptionOld，因为这些是你经常要用到的，可以跳过NSKeyValueObservingOptionInitial & NSKeyValueObservingOptionPrior

#####NSKeyValueObservingOptions

* NSKeyValueObservingOptionNew: 表明变化的字典应该提供新的属性值，如何可以的话。
* NSKeyValueObservingOptionOld: 表明变化的字典应该包含旧的属性值，如何可以的话。
* NSKeyValueObservingOptionInitial: 如果被指定，一个通知会立刻发送到观察者，甚至在观察者注册方法之前就返回，改变的字典需要包含一个 NSKeyValueChangeNewKey入口，如果 NSKeyValueObservingOptionNew也被指定的话，但从来不会包含一个NSKeyValueChangeOldKey入口。（在一个initial notification里，观察者的当前属性可能是旧的，但对观察者来说是新的），你可以使用这个选项代替显式的调用，同时，代码也会被观察者的observeValueForKeyPath:ofObject:change:context: 方法调用，当这个选项被用于addObserver:forKeyPath:options:context:，一个通知将会发送到每个被观察者添加进去的索引对象中
* NSKeyValueObservingOptionPrior:是否各自的通知应该在每个改变前后发送到观察者，而不是在改变之后发送一个单独的通知。一个通知中的可变数组在改变发生之前发送经常包含一个NSKeyValueChangeNotificationIsPriorKey入口且它的值是@YES，但从来不会包含一个NSKeyValueChangeNewKey入口。当这个选项被指定，在改变之后发送的通知中的变化的字典包含了一个与在选项没有被指定的情况下应该包含的同一个入口，当观察者自己的键值观察需要它的时候，你可以使用这个选项来调用-willChange...方法中的一个来观察它自己的某个属性，那个属性的值依赖于被观察的对象的属性（在那种情况，调用-willChange...来对收到的一个observeValueForKeyPath:ofObject:change:context: 消息做出反应可能就太晚了）

这些选项允许一个对象在发生变化的前后获取值。在实践中，这不是必须的，因为从当前属性值获取的新值一般是可用的
也就是说 NSKeyValueObservingOptionInitial 对于在反馈KVO事件的时候减少代码路径是很有好处的。比如你

至于context，它可以被用作区分那些绑定同一个key path的不同对象的观察者。有点复杂，稍后会讨论。

####Responding

导致KVO丑陋的另外一方面是 没有方法指定自定义的selectors来处理观察者，就像控件里使用的Target-Action模式那样，相反地，对于观察者，所有的改变都被聚集到一个单独的方法 observeValueForKeyPath:ofObject:change:context:

```
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
```
这些参数跟我们指定的 –addObserver:forKeyPath:options:context:是一样的，change是个例外，它取决于哪个NSKeyValueObservingOptions 选项被使用

一个典型的方法实现看起来像这样

```
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:@"state"]) {
    // ...
  }
}
```
这取决于多少种类的对象在一个单独的类里被观察，这个方法也可以用来引出-isKindOfObject: 或 -respondsToSelector: 为了明确区分传过来的事件种类。但是最安全的方法是做一个context等式检查。尤其是处理那些继承自同一个父类的子类，并且这些子类有相同的keypath
#####Correct Context Declarations
如何设置一个好的 context值呢？这里有个建议：

```
static void * XXContext = &XXContext;
```
就是这么简单：一个静态变量存着它自己的指针。这意味着它自己什么也没有，使<NSKeyValueObserving>更完美：

```
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if (context == XXContext) {
      if ([keyPath isEqualToString:NSStringFromSelector(@selector(isFinished))]) {

      }
  }
}
```

#####Better Key Paths
传字符串做为key path 比直接使用属性更糟糕，因为任何错字或者拼写错误都不会被编译器察觉，最终导致不能正常工作。
一个聪明的解决方案是使用 NSStringFromSelector 和一个 @selector 字面值:

```
NSStringFromSelector(@selector(isFinished))
```
因为@selector检查目标中的所有可用selector，这并不能阻止所有的错误，但它可用捕获大部分-包括捕获Xcode自动重构带来的改变

```
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[NSOperation class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isFinished))]) {

        }
    } else if (...) {
        // ...
    }
}
```

####Unsubscribing
当一个观察者完成了监听一个对象的改变，需要调用–removeObserver:forKeyPath:context:。它经常在 -observeValueForKeyPath:ofObject:change:context:, 或者-dealloc中被调用。

#####Safe Unsubscribe with @try / @catch
也许KVO最明显的烦恼是它如何在最后获取你，如果你调用–removeObserver:forKeyPath:context: 当这个对象没有被注册为观察者（因为它已经解注册了或者开始没有注册），抛出一个异常。有意思的是，没有一个内建的方式来检查对象是否注册。
这就会导致我们需要用一种相当不好的方式@try和一个没有处理的@catch

```
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isFinished))]) {
        if ([object isFinished]) {
          @try {
              [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished))];
          }
          @catch (NSException * __unused exception) {}
        }
    }
}
```
当然，这个例子中没有处理一个捕获的异常，这其实是一种妥协的方式。因此，只有当面对连续不断的崩溃并且不能通过一般的措施（竞争条件或者来自父类的非法行为）补救才会用这种方式。

####Automatic Property Notifications

KVO很有用并且被广泛采用。正是因为这样，大部分需要得到正确绑定的工作自动被编译和进行时接管。

> Classes可以选择自动退出KVO通过复写：
> 
> +automaticallyNotifiesObserversForKey: 并且返回No

但是如果想复合或者派生values又该怎么办呢？让我告诉你有一个带有@dynamic, readonly address属性，它读取并且格式化它的streetAddress, locality, region, 和 postalCode？

好吧，你可以实现keyPathsForValuesAffectingAddress方法（或者+keyPathsForValuesAffectingValueForKey:）

```
+ (NSSet *)keyPathsForValuesAffectingAddress {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(streetAddress)), NSStringFromSelector(@selector(locality)), NSStringFromSelector(@selector(region)), NSStringFromSelector(@selector(postalCode)), nil];
}
```

现在你知道了：关于KVO的一些一般性意见和最佳实践。作为一个积极的NSHipster，KVO可以看做那些高度灵活和抽象的上层的一个强大的基板。明智的使用它，理解其中的规则和惯例，在你的应用中充分利用这个特性。