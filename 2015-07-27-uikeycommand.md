---
title: UIKeyCommand
author: Nate Cook
category: Cocoa
excerpt: "As part of the push for greater productivity on the iPad, iOS 9 adds *Discoverability*, an overlay showing the currently available key commands inside an app. This small change suddenly makes key commands far more viable on the iPad and, with it, makes `UIKeyCommand` a necessary addition to your app."
status:
    swift: 2.0
---

Adding a new feature to a product is always a tradeoff. Will the added utility of a new feature be enough to offset the added complexity? Shortcuts would seem to side-step this issue—after all, they're simply a quicker alternative for features already in your app. But that creates another dilemma: what if a new feature is added and no one knows it's there?

When key commands for external keyboards debuted in iOS 7, there was no intrinsic way to learn of their existence. Unlike in OS X, where a user can gradually discover shortcuts for the menu items they use most often, an iOS app had few ways to communicate what key commands are available. Initial tours flash by and fade from memory; help screens are hidden out of sight. Without a way to make shortcuts visible in a timely and relevant manner, users were sure to miss out on useful features that developers had taken the time to implement.

No longer. As part of the push for greater productivity on the iPad, iOS 9 adds *Discoverability*, an overlay showing the currently available key commands inside an app. This small change suddenly makes key commands far more viable on the iPad and, with it, makes `UIKeyCommand` a necessary addition to your app.

---

## `UIKeyCommand`

The `UIKeyCommand` class is in fact quite simple, with only four properties to configure:

- `input`: The character of the key you'd like to recognize, or the correct constant for the arrow and escape keys, which do not have characters themselves. The available constants are:
    - `UIKeyInputUpArrow`
    - `UIKeyInputDownArrow`
    - `UIKeyInputLeftArrow`
    - `UIKeyInputRightArrow`
    - `UIKeyInputEscape`

- `modifierFlags`: One or more `UIKeyModifierFlags`, describing the modifier keys that should be pressed in combination with `input`:
    - `.Command`, `.Alternate`, `.Shift`, `.Control`: The Command, Option, Shift, and Control keys, respectively.
    - `.NumericPad`: Indicates that `input` should come from the numeric keypad rather than the top row of the standard keyboard.
    - `.AlphaShift`: Indicates that the CapsLock key should be *pressed* as part of the combination, rather than just engaged.

- `action`: The selector to call when the key command is invoked, called with a `UIKeyCommand` as its only argument. The key event will travel up the responder chain until a matching selector is found.

- `discoverabilityTitle` *(iOS 9 only)*: An optional label to display for the key command in the Discoverability layover. Only key commands with a title set will be listed.




## Responding to Key Commands

Enabling key commands is as simple as providing an array of `UIKeyCommand` instances somewhere in the responder chain. Text inputs are automatically first responders, but perhaps more usefully, a view controller can respond to key commands by implementing `canBecomeFirstResponder()`:

```swift
override func canBecomeFirstResponder() -> Bool {
    return true
}
```
```objective-c
- (BOOL)canBecomeFirstResponder {
    return YES;
}
```

Next, provide a list of available key commands via the `keyCommands` property:

```swift
override var keyCommands: [UIKeyCommand]? {
    return [
        UIKeyCommand(input: "1", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Types"),
        UIKeyCommand(input: "2", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Protocols"),
        UIKeyCommand(input: "3", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Functions"),
        UIKeyCommand(input: "4", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Operators"),
            
        UIKeyCommand(input: "f", modifierFlags: [.Command, .Alternate], action: "search:", discoverabilityTitle: "Find…"),
    ]
}

// ...

func selectTab(sender: UIKeyCommand) {
    let selectedTab = sender.input
    // ...
}
```
```objective-c
- (NSArray<UIKeyCommand *>*)keyCommands {
    return @[
        [UIKeyCommand keyCommandWithInput:@"1" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Types"],
        [UIKeyCommand keyCommandWithInput:@"2" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Protocols"],
        [UIKeyCommand keyCommandWithInput:@"3" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Functions"],
        [UIKeyCommand keyCommandWithInput:@"4" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Operators"],

        [UIKeyCommand keyCommandWithInput:@"f" 
                            modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate 
                                   action:@selector(search:) 
                     discoverabilityTitle:@"Find…"]
    ];
}

// ...

- (void)selectTab:(UIKeyCommand *)sender {
    NSString *selectedTab = sender.input;
    // ...
}
```

In the Discoverability layover, accessed by holding down the Command key, key commands are listed in the order you specified:

![Discoverability Layover]({{ site.asseturl }}/uikeycommand-discoverability.png)

*Voila!* Secrets, revealed!


### Context Sensitivity

The `keyCommands` property is accessed whenever a key pressed, making it possible to provide context-sensitive responses depending on the state of your application. While this is similar to the way a menu item and its active/inactive state are configured in OS X, the recommendation for iOS is to omit inactive commands completely—that is, there are no grayed out commands in the Discoverability layover.

Here, a set of commands that are available to logged in users of an app are included only when appropriate:

```swift
let globalKeyCommands = [UIKeyCommand(input:...), ...]
let loggedInUserKeyCommands = [UIKeyCommand(input:...), ...]

override var keyCommands: [UIKeyCommand]? {
    if isLoggedInUser() {
        return globalKeyCommands + loggedInUserKeyCommands
    } else {
        return globalKeyCommands
    }
}
```

---

Although we don't take shortcuts when creating our apps, that doesn't mean our users won't find shortcuts useful. Adding key commands lets control of your app shift from the screen to the keyboard—your users will love the option.

