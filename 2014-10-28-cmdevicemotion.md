---
title: CMDeviceMotion
author: Nate Cook
category: Cocoa
excerpt: "Beneath the smooth glass of each shiny iPhone, nestled on a logic board between touch screen controllers and Apple-designed SoCs, the gyroscope and accelerometer sit largely neglected."
status:
    swift: 1.0
---

Beneath the smooth glass of each shiny iPhone, nestled on a logic board between touch screen controllers and Apple-designed SoCs, the gyroscope and accelerometer sit largely neglected.

Need it be so? The *[Core Motion framework](https://developer.apple.com/library/ios/documentation/coremotion/reference/coremotion_reference/index.html)* makes it surprisingly easy to harness these sensors, opening the door to user interactions above and beyond the tapping and swiping we do every day.

> For devices that include the M7 or M8 motion processor, the Core Motion framework also provides access to stored motion activity, such as step counts, stairs climbed, and movement type (walking, cycling, etc.).

---

Core Motion allows a developer to observe and respond to the motion and orientation of an iOS device by inspecting the raw and processed data from a combination of built-in sensors, including the accelerometer, gyroscope, and magnetometer.

Both accelerometer and gyroscope data are presented in terms of three axes that run through the iOS device. For an iPhone held in portrait orientation, the X-axis runs through the device from left (negative values) to right (positive values), the Y-axis through the device from bottom (-) to top (+), and the Z-axis runs perpendicularly through the screen from the back (-) to the front (+).

The composited device motion data are presented in a few different ways, each with their own uses, as we'll see below.

![Device X-, Y-, and Z-axes](http://nshipster.s3.amazonaws.com/cmdm-axes.png)

## CMMotionManager

The `CMMotionManager` class provides access to all the motion data on an iOS device. Interestingly, Core Motion provides both "pull" and "push" access to motion data. To "pull" motion data, you can access the current status of any sensor or the composited data as read-only properties of `CMMotionManager`. To receive "pushed" data, you start the collection of your desired data with a block or closure that receives updates at a specified interval.

To keep performance at the highest level, Apple recommends using a single shared `CMMotionManager` instance throughout your app.

`CMMotionManager` provides a consistent interface for each of the four motion data types: `accelerometer`, `gyro`, `magnetometer`, and `deviceMotion`. As an example, here are the ways you can interact with the gyroscope—simply replace `gyro` with the motion data type you need.

#### Checking for Availability

```swift
let manager = CMMotionManager()
if manager.gyroAvailable {
     // ...
}
```

> To make things simpler and equivalent between Swift and Objective-C, assume we've declared a `manager` instance as a view controller property for all the examples to come.

#### Setting the Update Interval

```swift
manager.gyroUpdateInterval = 0.1
```

This is an `NSTimeInterval`, so specify your update time in seconds: lower for smoother responsiveness, higher for less CPU usage.

#### Starting Updates to "pull" Data

```swift
manager.startGyroUpdates()
```

After this call, `manager.gyroData` is accessible at any time with the device's current gyroscope data.

#### Starting Updates to "push" Data

```swift
let queue = NSOperationQueue.mainQueue
manager.startGyroUpdatesToQueue(queue) {
    (data, error) in
    // ...
}
```

The handler closure will be called at the frequency given by the update interval.

#### Stopping Updates

```swift
manager.stopGyroUpdates()
```

## Using the Accelerometer

Let's say we want to give the splash page of our app a fun effect, with the background image staying level no matter how the phone is tilted.

Consider the following code:

First, we check to make sure our device makes accelerometer data available, next we specify a very high update rate, and then we begin updates to a closure that will rotate a `UIImageView` property:

```swift
if manager.accelerometerAvailable {
    manager.accelerometerUpdateInterval = 0.01
    manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
        [weak self] (data: CMAccelerometerData!, error: NSError!) in

        let rotation = atan2(data.acceleration.x, data.acceleration.y) - M_PI
        self?.imageView.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
    }
}
```

```objective-c
RotationViewController * __weak weakSelf = self;
if (manager.accelerometerAvailable) {
    manager.accelerometerUpdateInterval = 0.01f;
    [manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                              withHandler:^(CMAccelerometerData *data, NSError *error) {
        double rotation = atan2(data.acceleration.x, data.acceleration.y) - M_PI;
        weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
    }];
}
```

Each packet of `CMAccelerometerData` includes an `x`, `y`, and `z` value—each of these shows the amount of acceleration in Gs (where G is one unit of gravity) for that axis. That is, if your device were stationary and straight up in portrait orientation, it would have acceleration `(0, -1, 0)`; laying flat on its back on the table would be `(0, 0, -1)`; and tilted forty-five degrees to the right would be something like `(0.707, -0.707, 0)`.

We're calculating the rotation by computing the [`arctan2`](http://en.wikipedia.org/wiki/Atan2) of the `x` and `y` components from the accelerometer data and then using that rotation in a `CGAffineTransform`. Our image should stay right-side up no matter how the phone is turned—here it is in a hypothetical app for the *National Air & Space Museum* (my favorite museum as a kid):

![Rotation with accelerometer](http://nshipster.s3.amazonaws.com/cmdm-accelerometer.gif)

The results are not terribly satisfactory—the image movement is jittery, and moving the device in space affects the accelerometer as much as or even more than rotating. These issues *could* be mitigated by sampling multiple readings and averaging them together, but instead let's look at what happens when we involve the gyroscope.



## Adding the Gyroscope

Rather than use the raw gyroscope data that we would get with `startGyroUpdates...`, let's get composited gyroscope *and* accelerometer data from the `deviceMotion` data type. Using the gyroscope, Core Motion separates user movement from gravitational acceleration and presents each as its own property of the `CMDeviceMotion` instance that we receive in our handler. The code is very similar to our first example:

```swift
if manager.deviceMotionAvailable {
    manager.deviceMotionUpdateInterval = 0.01
    manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
        [weak self] (data: CMDeviceMotion!, error: NSError!) in

        let rotation = atan2(data.gravity.x, data.gravity.y) - M_PI
        self?.imageView.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
    }
}
```

```objective-c
RotationViewController * __weak weakSelf = self;
if (manager.deviceMotionAvailable) {
    manager.deviceMotionUpdateInterval = 0.01f;
    [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(CMDeviceMotion *data, NSError *error) {
        double rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
        weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
    }];
}
```

Much better!

![Rotation with gravity](http://nshipster.s3.amazonaws.com/cmdm-gravity.gif)

## UIClunkController

We can also use the other, non-gravity portion of this composited gyro/acceleration data to add new methods of interaction. In this case, let's use the `userAcceleration` property of `CMDeviceMotion` to navigate backward whenever a user taps the left side of her device against her hand.

Remember that the X-axis runs laterally through the device in our hand, with negative values to the left. If we sense a *user* acceleration to the left of more than 2.5 Gs, that will be the cue to pop our view controller from the stack. The implementation is only a couple lines different from our previous example:

```swift
if manager.deviceMotionAvailable {
    manager.deviceMotionUpdateInterval = 0.02
    manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
        [weak self] (data: CMDeviceMotion!, error: NSError!) in

        if data.userAcceleration.x < -2.5 {
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
}
```

```objective-c
ClunkViewController * __weak weakSelf = self;
if (manager.deviceMotionAvailable) {
    manager.deviceMotionUpdateInterval = 0.01f;
    [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(CMDeviceMotion *data, NSError *error) {
        if (data.userAcceleration.x < -2.5f) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
```

And it works like a charm—tapping the device in a detail view immediately takes us back to the list of exhibits:

![Clunk to go back](http://nshipster.s3.amazonaws.com/cmdm-clunk.gif)



## Getting an Attitude

Better acceleration data isn't the only thing we gain by including gyroscope data—we now also know the device's true orientation in space. We find this data in the `attitude` property of `CMDeviceMotion`, an instance of `CMAttitude`. `CMAttitude` contains three different representations of the device's orientation: Euler angles, a quaternion, and a rotation matrix. Each of these is in relation to a given reference frame.

### Finding a Frame of Reference

You can think of a reference frame as the resting orientation of the device from which an attitude is calculated. All four possible reference frames describe the device laying flat on a table, with increasing specificity about the direction it's pointing.

- `CMAttitudeReferenceFrameXArbitraryZVertical` describes a device laying flat (vertical Z-axis) with an "arbitrary" X-axis. In practice, the X-axis is fixed to the orientation of the device when you *first* start device motion updates.
- `CMAttitudeReferenceFrameXArbitraryCorrectedZVertical` is essentially the same but uses the magnetometer to correct possible variation in the gyroscope's measurement over time. Using the magnetometer adds a CPU (and therefore battery) cost.
- `CMAttitudeReferenceFrameXMagneticNorthZVertical` describes a device laying flat, with its X-axis (i.e., the right side of the device) pointed toward magnetic north. This setting may require your user to perform that figure-eight motion with their device to calibrate the magnetometer.
- `CMAttitudeReferenceFrameXTrueNorthZVertical` is the same as the last, but this adjusts for the magnetic/true north discrepancy and therefore requires location data in addition to the magnetometer.

For our purposes, the default "arbitrary" reference frame will be fine - you'll see why in a moment.

### Euler Angles

Of the three attitude representations, Euler angles are the most readily understood, as they simply describe rotation around each of the axes we've already been working with. `pitch` is rotation around the X-axis, increasing as the device tilts toward you, decreasing as it tilts away; `roll` is rotation around the Y-axis, decreasing as the device rotates to the left, increasing to the right; and `yaw` is rotation around the (vertical) Z-axis, decreasing clockwise, increasing counter-clockwise.

> Each of these values follows what's called the "right hand rule": make a cupped hand with your thumb pointing up and point your thumb in the direction of any of the three axes. Turns that move toward your fingertips are positive, turns away are negative.

### Keep It To Yourself

Lastly, let's try using the device's attitude to enable a new interaction for a flash-card app, designed to be used by two study buddies. Instead of manually switching between the prompt and the answer, we'll automatically switch the view as the device turns around, so the quizzer sees the answer while the person being quizzed only sees the prompt.

Figuring out this switch from the reference frame would be tricky. To know which angles to monitor, we would somehow need to take into account the starting orientation of the device and then determine which direction the device is pointing. Instead, we can save a `CMAttitude` instance and use it as the "zero point" for an adjusted set of Euler angles, calling the `multiplyByInverseOfAttitude()` method to translate all future attitude updates.

When the quizzer taps the button to begin the quiz, we first configure the interaction—note the "pull" of the deviceMotion for `initialAttitude`:

```swift
// get magnitude of vector via Pythagorean theorem
func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
    return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
}

// initial configuration
var initialAttitude = manager.deviceMotion.attitude
var showingPrompt = false

// trigger values - a gap so there isn't a flicker zone
let showPromptTrigger = 1.0
let showAnswerTrigger = 0.8
```

```objective-c
// --- class method to get magnitude of vector via Pythagorean theorem
+ (double)magnitudeFromAttitude:(CMAttitude *)attitude {
    return sqrt(pow(attitude.roll, 2.0f) + pow(attitude.yaw, 2.0f) + pow(attitude.pitch, 2.0f));
}

// --- In @IBAction handler
// initial configuration
CMAttitude *initialAttitude = manager.deviceMotion.attitude;
__block BOOL showingPrompt = NO;

// trigger values - a gap so there isn't a flicker zone
double showPromptTrigger = 1.0f;
double showAnswerTrigger = 0.8f;
```

Then, in our now familiar call to `startDeviceMotionUpdates`, we calculate the magnitude of the vector described by the three Euler angles and use that as a trigger to show or hide the prompt view:

```swift
if manager.deviceMotionAvailable {
    manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
        [weak self] (data: CMDeviceMotion!, error: NSError!) in

        // translate the attitude
        data.attitude.multiplyByInverseOfAttitude(initialAttitude)

        // calculate magnitude of the change from our initial attitude
        let magnitude = magnitudeFromAttitude(data.attitude) ?? 0

        // show the prompt
        if !showingPrompt && magnitude > showPromptTrigger {
            if let promptViewController = self?.storyboard?.instantiateViewControllerWithIdentifier("PromptViewController") as? PromptViewController {
                showingPrompt = true

                promptViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                self!.presentViewController(promptViewController, animated: true, completion: nil)
            }
        }

        // hide the prompt
        if showingPrompt && magnitude < showAnswerTrigger {
            showingPrompt = false
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
```

```objective-c
FacingViewController * __weak weakSelf = self;
if (manager.deviceMotionAvailable) {
    [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(CMDeviceMotion *data, NSError *error) {

        // translate the attitude
        [data.attitude multiplyByInverseOfAttitude:initialAttitude];

        // calculate magnitude of the change from our initial attitude
        double magnitude = [FacingViewController magnitudeFromAttitude:data.attitude];

        // show the prompt
        if (!showingPrompt && (magnitude > showPromptTrigger)) {
            showingPrompt = YES;

            PromptViewController *promptViewController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"PromptViewController"];
            promptViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:promptViewController animated:YES completion:nil];
        }

        // hide the prompt
        if (showingPrompt && (magnitude < showAnswerTrigger)) {
            showingPrompt = NO;
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
```

Having implemented all that, let's take a look at the interaction. As the device rotates, the display automatically switches views and the quizee never sees the answer:

![Prompt by turning the device](http://nshipster.s3.amazonaws.com/cmdm-prompt.gif)

### Further Reading

I skimmed over the [quaternion](http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation) and [rotation matrix](http://en.wikipedia.org/wiki/Rotation_matrix) components of `CMAttitude` earlier, but they are not without intrigue. The quaternion, in particular, has [an interesting history](http://en.wikipedia.org/wiki/History_of_quaternions), and will bake your noodle if you think about it long enough.


## Queueing Up

To keep the code examples readable, we've been sending all our `CoreMotionManager` updates to the main queue. As a best practice, it would be better to have these updates on their own queue so they can't slow down user interaction, but then we'll need to get back on the main queue to update user interface elements. [`NSOperationQueue`](http://nshipster.com/nsoperation/) makes this easy with its `addOperationWithBlock` method:

```swift
let queue = NSOperationQueue()
manager.startDeviceMotionUpdatesToQueue(queue) {
    [weak self] (data: CMDeviceMotion!, error: NSError!) in

    // motion processing here

    NSOperationQueue.mainQueue().addOperationWithBlock {
        // update UI here
    }
}
```

```objective-c
NSOperationQueue *queue = [[NSOperationQueue alloc] init];
[manager startDeviceMotionUpdatesToQueue:queue
                             withHandler:
^(CMDeviceMotion *data, NSError *error) {
    // motion processing here

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // update UI here
    }];
}];
```

----

As a final note, clearly not all interactions made possible by Core Motion are good ones. Navigation through motion can be fun but also hard to discover or easy to accidentally trigger; purposeless animations can make it harder to focus on the task at hand. Prudent developers will skip over gimmicks that distract and find ways to use device motion that enrich their apps and delight their users.
