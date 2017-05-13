# [FunLayout](https://github.com/Sroik/FunLayout)
Funny auto layout

<a href="https://codebeat.co/projects/github-com-sroik-funlayout"><img alt="codebeat badge" src="https://codebeat.co/badges/8939b518-4230-4b79-b7d0-89457a896dee" /></a>

## Introduction
- Are U tired of the Apple's Auto Layout? 
- Yes!

That's is the main reason for creation FunLayout. FunLayout based on swift operators overloading.

##Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C/Swift, which automates and simplifies the process of using 3rd-party libraries like FunLayout in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile

To integrate FunLayout into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

pod 'FunLayout', '~>1.0.3'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

Before use FunLayout, make sure that view.translatesAutoresizingMaskIntoConstraints is false, or set it to false
```swift
view.translatesAutoresizingMaskIntoConstraints = false
```
Alternatively U can use fun_prepareForLayout() function, which also clean all old constraints.
```swift
view.fun_prepareForLayout()
```

####To layout elements use the following formula:
```swift
firstItem.fun_attribute % priority {== or ~, <=, >=} secondItem.fun_attribute {*, /} multiplier {+, -} constant
```

U can use either == or ~, because they are equal.

## Examples

```swift
import FunLayout

class ViewController: UIViewController {

    lazy var box = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.box)
        
        self.box.fun_prepareForLayout()
        self.box.fun_size == self.view
        self.box.fun_center == self.view
        
    }

}
```

- To add fullscreen subview U can use one of the following:

```swift
view.fun_edges == superview // or view.fun_edges == superview.fun_edges
```
or

```swift
view.fun_size == superview  // or view.fun_size ~ superview.fun_edges
view.fun_center == superview //or view.fun_center ~ superview
```

- Another examples

```swift
view.fun_top%750 == anotherView.fun_bottom

view.fun_top%950 ~ anotherView.fun_bottom // don't forget: == equal ~

view.fun_width == anotherView.fun_width*0.5 + 100.0

view.fun_height >= 100.0

view.fun_width <= 100.0

view.fun_edges == antherView.fun_edges\2.0
```

## License

MIT license. See the `LICENSE` file for details.
