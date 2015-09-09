---
title: NSUndoManager
author: Delisa Mason
category: Cocoa
excerpt: "We all make mistakes. Thankfully, Foundation comes to our rescue for more than just our misspellings. Cocoa includes a simple yet robust API for undoing or redoing actions through NSUndoManager."
status:
    swift: 1.0
---

We all make mistakes. Thankfully, Foundation comes to our rescue for more than just our misspellings. Cocoa includes a simple yet robust API for undoing or redoing actions through `NSUndoManager`.

By default, each application window has an undo manager, and any object in the responder chain can manage a custom undo manager for performing undo and redo operations local to their respective view. `UITextField` and `UITextView` use this functionality to automatically provide support for undoing text edits while first responder. However, indicating whether other actions can be undone is an exercise left for the app developer.

Creating an undoable action requires three steps: performing a change, registering an "undo operation" which can reverse the change, and responding to a request to undo the change.

## Undo Operations

To show an action can be undone, register an "undo operation" while performing the action. The [Undo Architecture](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UndoArchitecture/Articles/UndoManager.html#//apple_ref/doc/uid/20000205-CJBDJCCJ) documentation defines an "undo operation" as:

> A method for reverting a change to an object, along with the arguments needed to revert the change.

The operation specifies:

- The object to receive a message if an undo is requested
- The message to send and
- The arguments to pass with the message

If the method invoked by the undo operation also registers an undo operation, the undo manager provides redo support without extra work, as it is "undoing the undo".

There are two types of undo operations, "simple" selector-based undo and complex "NSInvocation-based undo".

### Registering a Simple Undo Operation

To register a simple undo operation, invoke `NSUndoManger -registerUndoWithTarget:selector:object:` on a target which can undo the action. The target is not necessarily the modified object, and is often a utility or container which manages the object's state. Specify the name of the undo action at the same time, using `NSUndoManager -setActionName:`. The undo dialog shows the name of the action, so it should be localized.

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

### Registering a Complex Undo Operation with NSInvocation

Simple undo operations may be too rigid for some uses, as undoing an action may require more than one argument. In these cases, we can leverage `NSInvocation` to record the selector and arguments required. Calling `prepareWithInvocationTarget:` records which object will receive the message which will make the change.

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

The magic here is that `NSUndoManager` implements `forwardInvocation:`. When the undo manager receives the message to undo `-movePiece:row:column:`, it forwards the message to the target since `NSUndoManager` does not implement this method.

## Performing an Undo

Once undo operations are registered, actions can be undone and redone as needed, using `NSUndoManager -undo` and `NSUndoManager -redo`.

### Responding to the Shake Gesture on iOS

By default, users trigger an undo operation by shaking the device. If a view controller should handle an undo request, the view controller must:

1. Be able to become first responder
2. Become first responder once its view appears,
3. Resign first responder when its view disappears

When the view controller then receives the motion event, the operating system presents a dialog to the user when undo or redo actions are available. The `undoManager` property of the view controller will handle the user's choice without further involvement.

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

## Customizing the Undo Stack

### Grouping Actions Together

All undo operations registered during a single run loop will be undone together, unless "undo groups" are otherwise specified. Grouping allows undoing or redoing many actions at once. Although each action can be performed and undone individually, if the user performs two at once, undoing both at once preserves a consistent user experience.

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

### Clearing the Stack

Sometimes the undo manager's list of actions should be cleared to avoid confusing the user with unexpected results. The most common cases are when the context changes dramatically, like changing the visible view controller on iOS or externally made changes occurring on an open document. When that time comes, the undo manager's stack can be cleared using `NSUndoManager -removeAllActions` or `NSUndoManager -removeAllActionsWithTarget:` if finer granularity is needed.

## Caveats

If an action has different names for undo versus redo, check whether an undo operation is occurring before setting the action name to ensure the title of the undo dialog reflects which action will be undone. An example would be a pair of opposing operations, like adding and removing an object:

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

If your test framework runs many tests as a part of one run loop (like Kiwi), clear the undo stack between tests in `teardown`. Otherwise tests will share undo state and invoking `NSUndoManager -undo` during a test may lead to unexpected results.

----

There are even more ways to refine behavior with `NSUndoManager`, particularly for grouping actions and managing scope. Apple also provides [usability guidelines](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/UndoRedo.html) for making undo and redo accessible in an expected and delightful way.

We all may wish to live without mistakes, but Cocoa gives us a way to let our users live with fewer regrets as it makes some actions easily changeable.
