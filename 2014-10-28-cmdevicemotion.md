---
title: CMDeviceMotion
author: Nate Cook, Mattt
category: Cocoa
excerpt: >
  Beneath the smooth glass of each iPhone
  an array of sensors sits nestled on the logic board,
  sending a steady stream of data to a motion coprocessor.
revisions:
  "2014-10-28": Original publication
  "2018-09-12": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: September 12, 2018
---

Beneath the smooth glass of each iPhone
an array of sensors sits nestled on the logic board,
sending a steady stream of data to a motion coprocessor.

The [Core Motion framework](https://developer.apple.com/documentation/coremotion)
makes it surprisingly easy to harness these sensors,
opening the door to user interactions above and beyond
the tapping and swiping we do every day.

---

Core Motion lets you observe and respond to changes in
the position and orientation of an iOS or watchOS device.
Thanks to their dedicated motion coprocessor,
iPhones, iPads, and Apple Watches can continuously read and process inputs
from built-in sensors without taxing the CPU or draining the battery.

Accelerometer and gyroscope data is projected into a 3D coordinate space,
with the center of the device at the origin.

![Device X-, Y-, and Z-axes]({% asset cmdm-axes.png @path %})

For an iPhone held in portrait orientation:

- The X-axis runs the width of the device
  from left (negative values) to right (positive values),
- The Y-axis runs the height of the device
  from bottom (-) to top (+),
- The Z-axis runs perpendicularly through the screen
  from the back (-) to the front (+).

## CMMotionManager

The `CMMotionManager` class is responsible for
providing data about the motion of the current device.
To keep performance at the highest level,
create and use a single shared `CMMotionManager` instance throughout your app.

`CMMotionManager` provides four different interfaces for sensor information,
each with corresponding properties and methods
to check hardware availability and access measurements.

- The <dfn>accelerometer</dfn> measures <dfn>acceleration</dfn>,
  or changes in velocity over time.
- The <dfn>gyroscope</dfn> measures <dfn>attitude</dfn>,
  or the orientation of the device.
- The <dfn>magnetometer</dfn> is essentially a compass,
  and measures the Earth's magnetic field relative to the device.

In addition to these individual readings,
`CMMotionManager` also provides a unified "device motion" interface,
which uses sensor fusion algorithms to combine readings
from each of these sensors into a unified view of the device in space.

### Checking for Availability

Although most Apple devices these days
come with a standard set of sensors,
it's still a good idea to check for the capabilities of the current device
before attempting to read motion data.

The following examples involve the accelerometer,
but you could replace the word "accelerometer"
for the type of motion data that you're interested in
(such as "gyro", "magnetometer", or "deviceMotion"):

```swift
let manager = CMMotionManager()
guard manager.isAccelerometerAvailable else {
    return
}
```

{% comment %}

> Too keep things concise,
> assume that each of the following examples declares
> a `manager` instance as a view controller property.

{% endcomment %}

### Push vs. Pull

Core Motion provides both "pull" and "push" access to motion data.

To "pull" motion data,
you access the current reading from
using one of the read-only properties of `CMMotionManager`.

To receive "pushed" data,
you start the collection of your desired data
with a closure that receives updates at a specified interval.

#### Starting Updates to "pull" Data

```swift
manager.startAccelerometerUpdates()
```

After this call,
`manager.accelerometerData` is accessible at any time
with the device's current accelerometer data.

```swift
manager.accelerometerData
```

You can also check whether motion data is available by
reading the corresponding "is active" property.

```swift
manager.isAccelerometerActive
```

#### Starting Updates to "push" Data

```swift
manager.startAccelerometerUpdates(to: .main) { (data, error) in
    guard let data = data, error == nil else {
        return
    }

    // ...
}
```

The passed closure is called at the frequency provided by the update interval.
(Actually, Core Motion enforces a minimum and maximum frequency,
so specifying a value outside of that range causes that value to be normalized;
you can determine the effective interval rate of the current device
by checking the timestamps of motion events over time.)

#### Stopping Updates

```swift
manager.stopAccelerometerUpdates()
```

## Accelerometer in Action

Let's say we want to give the splash page of our app a fun effect,
such that the background image remains level no matter how the phone is tilted.

Consider the following code:

```swift
if manager.isAccelerometerAvailable {
    manager.accelerometerUpdateInterval = 0.01
    manager.startAccelerometerUpdates(to: .main) {
        [weak self] (data, error) in
        guard let data = data, error == nil else {
            return
        }

        let rotation = atan2(data.acceleration.x,
                             data.acceleration.y) - .pi
        self?.imageView.transform =
            CGAffineTransform(rotationAngle: CGFloat(rotation))
    }
}
```

First, we check to make sure our device makes accelerometer data available.
Next we specify a high update frequency.
And then finally,
we begin updates to a closure that will rotate a `UIImageView` property:

Each `CMAccelerometerData` object includes an `x`, `y`, and `z` value ---
each of these shows the amount of acceleration in G-forces
(where 1G = the force of gravity on Earth)
for that axis.
If your device were stationary and standing straight up in portrait orientation,
it would have acceleration `(0, -1, 0)`;
laying flat on its back on the table,
it would be `(0, 0, -1)`;
tilted forty-five degrees to the right,
it would be something like `(0.707, -0.707, 0)` _(dat √2 tho)_.

We calculate the rotation with the
[two-argument arctangent function (`atan2`)](https://en.wikipedia.org/wiki/Atan2)
using the `x` and `y` components from the accelerometer data.
We then initialize a `CGAffineTransform` using that calculate rotation.
Our image should stay right-side-up, no matter how the phone is turned ---
here, it is in a hypothetical app for the _National Air & Space Museum_
(my favorite museum as a kid):

![Rotation with accelerometer]({% asset cmdm-accelerometer.gif @path %})

The results are not terribly satisfactory ---
the image movement is jittery,
and moving the device in space affects the accelerometer
as much as or even more than rotating.
These issues _could_ be mitigated by
sampling multiple readings and averaging them together,
but instead let's look at what happens when we involve the gyroscope.

## Adding the Gyroscope

Rather than use the raw gyroscope data that we would get
by calling the `startGyroUpdates...` method,
let's get composited gyroscope _and_ accelerometer data
by requesting the unified "device motion" data.
Using the gyroscope,
Core Motion separates user movement from gravitational acceleration
and presents each as its own property of the `CMDeviceMotion` object.
The code is very similar to our first example:

```swift
if manager.isDeviceMotionAvailable {
    manager.deviceMotionUpdateInterval = 0.01
    manager.startDeviceMotionUpdates(to: .main) {
        [weak self] (data, error) in

        guard let data = data, error == nil else {
            return
        }

        let rotation = atan2(data.gravity.x,
                             data.gravity.y) - .pi
        self?.imageView.transform =
            CGAffineTransform(rotationAngle: CGFloat(rotation))
    }
}
```

_Much better!_

![Rotation with gravity]({% asset cmdm-gravity.gif @path %})

## UIClunkController

We can also use the other, non-gravity portion
of this composited gyro / acceleration data
to add new methods of interaction.
In this case, let's use the `userAcceleration` property of `CMDeviceMotion`
to navigate backward whenever
the user taps the left side of the device against their hand.

Remember that the X-axis runs laterally through the device in our hand,
with negative values to the left.
If we sense a _user_ acceleration to the left of more than 2.5 Gs,
that's our cue to pop the view controller from the stack.
The implementation is only a couple lines different from our previous example:

```swift
if manager.isDeviceMotionAvailable {
    manager.deviceMotionUpdateInterval = 0.01
    manager.startDeviceMotionUpdates(to: .main) {
        [weak self] (data, error) in

        guard let data = data, error == nil else {
            return
        }
        if data.userAcceleration.x < -2.5 {
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
}
```

_Works like a charm!_

Tapping the device in a detail view
immediately takes us back to the list of exhibits:

![Clunk to go back]({% asset cmdm-clunk.gif @path %})

## Getting an Attitude

Better acceleration data isn't the only thing we gain
by including gyroscope data:
we now also know the device's true orientation in space.
This data is accessed via the `attitude` property of a `CMDeviceMotion` object
and encapsulated in a `CMAttitude` object.
`CMAttitude` contains three different representations of the device's orientation:

- Euler angles,
- A quaternion,
- A rotation matrix.

Each of these is in relation to a given reference frame.

### Finding a Frame of Reference

You can think of a reference frame as the resting orientation of the device
from which an attitude is calculated.
All four possible reference frames describe the device laying flat on a table,
with increasing specificity about the direction it's pointing.

- `CMAttitudeReferenceFrameXArbitraryZVertical`
  describes a device laying flat (vertical Z-axis)
  with an "arbitrary" X-axis.
  In practice, the X-axis is fixed to the orientation of the device
  when you _first_ start device motion updates.
- `CMAttitudeReferenceFrameXArbitraryCorrectedZVertical`
  is essentially the same,
  but uses the magnetometer to correct
  possible variation in the gyroscope's measurement over time.
- `CMAttitudeReferenceFrameXMagneticNorthZVertical`
  describes a device laying flat,
  with its X-axis
  (that is, the right side of the device in portrait mode when it's facing you)
  pointed toward magnetic north.
  This setting may require the user to perform
  that figure-eight motion with their device to calibrate the magnetometer.
- `CMAttitudeReferenceFrameXTrueNorthZVertical`
  is the same as the last,
  but it adjusts for magnetic / true north discrepancy
  and therefore requires location data in addition to the magnetometer.

For our purposes,
the default "arbitrary" reference frame will be fine
(you'll see why in a moment).

### Euler Angles

Of the three attitude representations,
Euler angles are the most readily understood,
as they simply describe rotation
around each of the axes we've already been working with.

- `pitch` is rotation around the X-axis,
  increasing as the device tilts toward you,
  decreasing as it tilts away
- `roll` is rotation around the Y-axis,
  decreasing as the device rotates to the left,
  increasing to the right
- `yaw` is rotation around the (vertical) Z-axis,
  decreasing clockwise, increasing counter-clockwise.

> Each of these values follows what's called the "right hand rule":
> make a cupped hand with your thumb pointing up
> and point your thumb in the direction of any of the three axes.
> Turns that move toward your fingertips are positive,
> turns away are negative.

### Keep It To Yourself

Lastly, let's try using the device's attitude to enable a new interaction
for a flash-card app designed to be used by two study buddies.
Instead of manually switching between the prompt and the answer,
we'll automatically flip the view as the device turns around,
so the quizzer sees the answer
while the person being quizzed sees only the prompt.

Figuring out this switch from the reference frame would be tricky.
To know which angles to monitor,
we would somehow need to account for the starting orientation of the device
and then determine which direction the device is pointing.
Instead, we can save a `CMAttitude` instance
and use it as the "zero point" for an adjusted set of Euler angles,
calling the `multiply(byInverseOf:)` method
to translate all future attitude updates.

When the quizzer taps the button to begin the quiz,
we first configure the interaction
(note the "pull" of the deviceMotion for `initialAttitude`):

```swift
// get magnitude of vector via Pythagorean theorem
func magnitude(from attitude: CMAttitude) -> Double {
    return sqrt(pow(attitude.roll, 2) +
            pow(attitude.yaw, 2) +
            pow(attitude.pitch, 2))
}

// initial configuration
var initialAttitude = manager.deviceMotion.attitude
var showingPrompt = false

// trigger values - a gap so there isn't a flicker zone
let showPromptTrigger = 1.0
let showAnswerTrigger = 0.8
```

Then,
in our now familiar call to `startDeviceMotionUpdates`,
we calculate the magnitude of the vector described by the three Euler angles
and use that as a trigger to show or hide the prompt view:

```swift
if manager.isDeviceMotionAvailable {
    manager.startDeviceMotionUpdates(to: .main) {
        // translate the attitude
        data.attitude.multiply(byInverseOf: initialAttitude)

        // calculate magnitude of the change from our initial attitude
        let magnitude = magnitude(from: data.attitude) ?? 0

        // show the prompt
        if !showingPrompt && magnitude > showPromptTrigger {
            if let promptViewController =
                self?.storyboard?.instantiateViewController(
                    withIdentifier: "PromptViewController"
                ) as? PromptViewController
            {
                showingPrompt = true

                promptViewController.modalTransitionStyle = .crossDissolve
                self?.present(promptViewController,
                              animated: true, completion: nil)
            }
        }

        // hide the prompt
        if showingPrompt && magnitude < showAnswerTrigger {
            showingPrompt = false
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
```

Having implemented all that,
let's take a look at the interaction.
As the device rotates,
the display automatically switches views and the quizee never sees the answer:

![Prompt by turning the device]({% asset cmdm-prompt.gif @path %})

### Further Reading

I skimmed over the
[quaternion](https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation) and
[rotation matrix](https://en.wikipedia.org/wiki/Rotation_matrix)
components of `CMAttitude` earlier,
but they are not without intrigue.
The quaternion, in particular,
has [an interesting history](https://en.wikipedia.org/wiki/History_of_quaternions),
and will bake your noodle if you think about it long enough.

## Queueing Up

To keep the code examples readable,
we've been sending all of our motion updates to the main queue.
A better approach would be to schedule these updates on their own queue
and dispatch back to main to update the UI.

```swift
let queue = OperationQueue()
manager.startDeviceMotionUpdates(to: queue) {
    [weak self] (data, error) in

    // motion processing here

    DispatchQueue.main.async {
        // update UI here
    }
}
```

---

Remember that not all interactions made possible by Core Motion are good ones.
Navigation through motion can be fun,
but it can also be
hard to discover,
easy to accidentally trigger,
and may not be accessible to all users.
Similar to purposeless animations,
overuse of fancy gestures can make it harder to focus on the task at hand.

Prudent developers will skip over gimmicks that distract
and find ways to use device motion that enrich apps and delight users.
