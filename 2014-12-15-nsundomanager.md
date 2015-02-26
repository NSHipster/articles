---
title: NSUndoManager
author: Delisa Mason
translator: Croath Liu
category: Cocoa
excerpt: "每个人都会犯错误。多亏了 Foundation 库提供了比拼写错误更强大的功能来解救我们。Cocoa 有一套简单强壮的 NSUndoManager API 管理撤销和重做。"
---

每个人都会犯错误。多亏了 Foundation 库提供了比拼写错误更强大的功能来解救我们。Cocoa 有一套简单强壮的 NSUndoManager API 管理撤销和重做。

默认地，每个应用的 window 都有一个 undo manager，每一个响应链条中的对象都可以管理一个自定义的 undo manager 来管理各自页面上本地操作的撤销和重做操作。`UITextField` 和 `UITextView` 用这个功能自动提供了文本编辑的撤销重做支持。然而，标明哪些动作可以被撤销是留给应用开发工程师的工作。

创建一个可以撤销的动作需要三步：做出改变，注册一个可以逆向的 "撤销操作"，响应撤销改变的动作。

## 撤销操作(undo operations)

为了标明某个动作可以被撤销，需要在执行动作的时候注册一个 "撤销操作"。[撤销架构文档](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UndoArchitecture/Articles/UndoManager.html#//apple_ref/doc/uid/20000205-CJBDJCCJ) 中定义 "undo operation" 为：

> 可以对一个对象进行逆向操作的方法，并且需要传递相应必需的参数。

具体指的是：

- 用于接收撤销操作信息的对象
- 需要传递的信息
- 信息所携带的参数

如果被撤销操作调用的方法也注册了一个撤销操作，那么撤销管理器不需要做额外的工作就可以提供重做(redo)支持，相当于 "撤销撤销的操作"。

共有两种撤销操作，简单的以 selector 为基础的撤销和复杂的以 NSInvocation 为基础的撤销。

### 注册一个简单的撤销操作

注册一个简单的撤销操作，如果目标可进行撤销操作，调用其 `NSUndoManger -registerUndoWithTarget:selector:object:` 方法就可以了。目标不必是那个被改变的对象，通常是管理对象状态的工具或容器。同时调用 `NSUndoManager -setActionName:` 指定撤销操作的名称。撤销对话会展示动作的名称，所以应该进行本地化操作。

```swift
func updateScore(score: NSNumber) {
    undoManager.registerUndoWithTarget(self, selector:Selector("updateScore:"), object:myMovie.score)
    undoManager.setActionName(NSLocalizedString("actions.update", comment: "Update Score"))
    myMovie.score = score
}
```

```objective-c
- (void)updateScore:(NSNumber*)score {
    [undoManager registerUndoWithTarget:self selector:@selector(updateScore:) object:myMovie.score];
    [undoManager setActionName:NSLocalizedString(@"actions.update", @"Update Score")];
    myMovie.score = score;
}
```

### 使用 NSInvocation 注册复杂的撤销操作

简单的撤销操作在某些使用场景下可能太粗糙了，比如说撤销某个动作需要不只一个参数。在这些情况下，我们可以使用 `NSInvocation` 来记录所需 selector 和相应参数。调用 `prepareWithInvocationTarget:` 记录哪些对象会接收哪些发生改变的消息。

```swift
func movePiece(piece: ChessPiece, row:UInt, column:UInt) {
    let undoController : ViewController = undoManager?.prepareWithInvocationTarget(self) as ViewController
    undoController.movePiece(piece, row:piece.row, column:piece.column)
    undoManager?.setActionName(NSLocalizedString("actions.move-piece", "Move Piece"))

    piece.row = row
    piece.column = column
    updateChessboard()
}
```

```objective-c
- (void)movePiece:(ChessPiece*)piece toRow:(NSUInteger)row column:(NSUInteger)column {
    [[undoManager prepareWithInvocationTarget:self] movePiece:piece ToRow:piece.row column:piece.column];
    [undoManager setActionName:NSLocalizedString(@"actions.move-piece", @"Move Piece")];

    piece.row = row;
    piece.column = column;
    [self updateChessboard];
}
```

最有魔力的部分是：`NSUndoManager` 实现了 `forwardInvocation:`。当撤销管理器收到消息去撤销 `-movePiece:row:column:` 时，因为 `NSUndoManager` 没有实现那个方法，于是它将该消息转发至相应对象。

## 实现一次撤销

一旦注册了撤销操作，动作就可以在需要时调用 `NSUndoManager -undo` 和 `NSUndoManager -redo`被撤销和重做。

### 响应 iOS 的摇晃手势

默认情况下，用户通过摇晃设备来触发撤销操作。如果一个 view controller 需要处理一个撤销请求，那么这个 view controller 必须：

1. 能成为 first responder
2. 一旦页面显示(view appears)，即变成 first responder
3. 一旦页面消失(view disappears)，即放弃 first responder

当 view controller 接收到运动事件，当撤销或重做可用时，系统会展示给用户一个会话界面。View controller 的 `undoManager` 属性不需要其他操作就可以响应用户的选择。

```swift
class ViewController: UIViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    // ...
}
```

```objective-c
@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

// ...

@end
```

## 自定义撤销栈

### 将动作组合到一起

在同一 run loop 中被注册的所有的撤销操作可以被一同撤销，除非 "撤销组合(undo groups)" 被单独指定了。撤销组合允许同时进行许多撤销和重做操作。虽然每个动作都可以单独被执行和撤销，但如果用户同时执行了两个动作，同时撤销他们则需要保持一致的用户体验。

```swift
func readAndArchiveEmail(email: Email) {
    undoManager?.beginUndoGrouping()
    markEmail(email, read: true)
    archiveEmail(email)
    undoManager?.setActionName(NSLocalizedString("actions.read-archive", comment:"Mark as Read and Archive"))
    undoManager?.endUndoGrouping()
}

func markEmail(email: Email, read:Bool) {
    let undoController: ViewController = undoManager?.prepareWithInvocationTarget(self) as ViewController
    undoController.markEmail(email, read:email.read)
    undoManager?.setActionName(NSLocalizedString("actions.read", comment:"Mark as Read"))
    email.read = read
}

func archiveEmail(email: Email) {
    let undoController: ViewController = undoManager?.prepareWithInvocationTarget(self) as ViewController
    undoController.moveEmail(email, toFolder:"Inbox")
    undoManager?.setActionName(NSLocalizedString("actions.archive", comment:"Archive"))
    moveEmail(email, toFolder:"All Mail")
}
```

```objective-c
- (void)readAndArchiveEmail:(Email*)email {
    [undoManager beginUndoGrouping];
    [self markEmail:email asRead:YES];
    [self archiveEmail:email];
    [undoManager setActionName:NSLocalizedString(@"actions.read-archive", @"Mark as Read and Archive")];
    [undoManager endUndoGrouping];
}

- (void)markEmail:(Email*)email asRead:(BOOL)isRead {
    [[undoManager prepareWithInvocationTarget:self] markEmail:email asRead:[email isRead]];
    [undoManager setActionName:NSLocalizedString(@"actions.read", @"Mark as Read")];
    email.read = isRead;
}

- (void)archiveEmail:(Email*)email {
    [[undoManager prepareWithInvocationTarget:self] moveEmail:email toFolder:@"Inbox"];
    [undoManager setActionName:NSLocalizedString(@"actions.archive", @"Archive")];
    [self moveEmail:email toFolder:@"All Mail"];
}
```

### 清空栈

有时撤销管理器的动作列表需要被清空来避免导致意外结果迷惑用户。通常情况下当上下文发生戏剧性变化时，比如说 iOS 上改变了显示的 view controller 或一个打开的文档外部发生了变化。此时，撤销管理器的栈可以通过 `NSUndoManager -removeAllActions` 来清空或使用 `NSUndoManager -removeAllActionsWithTarget:` 在更细的力度上清空。

## 警告

如果一个操作的撤销和重做有不同的名字，检查撤销操作是否执行在设置操作名称之前来确保撤销会话的标题能够正确反应哪个动作即将被撤销。一个例子就是一对相反的操作，比如添加和删除对象：

```swift
func addItem(item: NSObject) {
    undoManager?.registerUndoWithTarget(self, selector: Selector("removeItem:"), object:item)
    if undoManager?.undoing == false {
        undoManager?.setActionName(NSLocalizedString("action.add-item", comment: "Add Item"))
    }
    myArray.append(item)
}

func removeItem(item: NSObject) {
    if let index = find(myArray, item) {
        undoManager?.registerUndoWithTarget(self, selector: Selector("addItem:"), object:item)
        if undoManager?.undoing == false {
            undoManager?.setActionName(NSLocalizedString("action.remove-item", comment: "Remove Item"))
        }
        myArray.removeAtIndex(index)
    }
}
```

```objective-c
- (void)addItem:(id)item {
    [undoManager registerUndoWithTarget:self selector:@selector(removeItem:) object:item];
    if (![undoManager isUndoing]) {
        [undoManager setActionName:NSLocalizedString(@"actions.add-item", @"Add Item")];
    }
    [myArray addObject:item];
}

- (void)removeItem:(id)item {
    [undoManager registerUndoWithTarget:self selector:@selector(addItem:) object:item];
    if (![undoManager isUndoing]) {
        [undoManager setActionName:NSLocalizedString(@"actions.remove-item", @"Remove Item")];
    }
    [myArray removeObject:item];
}
```

如果你的测试框架(例如 Kiwi)在同一个 run loop 中运行多个测试，在 `teardown` 中的各个测试中间执行情况撤销栈的操作。否则其他测试在运行中调用 `NSUndoManager -undo` 时会共享同一撤销状态，导致意外的结果。

----

`NSUndoManager` 也有其他更多的可以总结的行为，特别是操作组合和管理方面。苹果为在适当场景下合理使用撤销和重做提供了 [可用性指南](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/UndoRedo.html) 。

我们都希望生活中不犯错，但 Cocoa 给我们的生活提供了能够后悔的机会，可以更简单地做出一些改变。
