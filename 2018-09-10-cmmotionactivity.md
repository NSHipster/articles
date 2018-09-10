---
title: CMMotionActivity
author: Mattt
category: Cocoa
excerpt: >
  Today's iPhones are packed with a full complement of sensors that includes
  cameras, barometers, gyroscopes, magnetometers, and accelerometers.
  Like humans, they use permutations of different sensory information
  to make determinations about their position and orientation,
  often by means quite similar to our own biomechanical processes.
status:
  swift: 4.2
---

Humans perceive self-motion using a combination of
sensory information from their visual, proprioceptive, and vestibular systems.
Of these,
the primary determination is made by the vestibular system,
comprising the
<dfn>semicircular canals</dfn>,
which sense changes in rotation,
and the <dfn>otoliths</dfn>,
which are sensitive to horizontal and vertical forces.

Today's iPhones are packed with a full complement of sensors that includes
cameras, barometers, gyroscopes, magnetometers, and accelerometers.
Like humans, they use permutations of different sensory information
to make determinations about their position and orientation,
often by means quite similar to our own biomechanical processes.

Making sense of sensory inputs ---
no matter their origin ---
is challenging.
There's just so much information to consider.
(Heck, it took our species a few million years to get that right,
and we're still confused by newfangled inventions like
elevators, planes, and roller coasters.)

After several major OS releases and hardware versions,
Apple devices have become adroit at differentiating between different
means of locomotion.
But before you run off and try to write your own implementation,
stop and consider using the built-in APIs discussed in this week's article.

---

On iOS and watchOS,
`CMMotionActivityManager` takes raw sensor data from the device
and tells you (to what degree of certainty)
whether the user is currently moving,
and if they're walking, running, biking, or driving in an automobile.

To use this API,
you create an activity manager
and start listening for activity updates
using the `startActivityUpdates` method.
Each time the device updates the motion activity,
it executes the specified closure,
passing a `CMMotionActivity` object.

```swift
let manager = CMMotionActivityManager()
manager.startActivityUpdates(to: .main) { (activity) in
    guard let activity = activity else {
        return
    }

    var modes: Set<String> = []
    if activity.walking {
        modes.insert("🚶‍")
    }

    if activity.running {
        modes.insert("🏃‍")
    }

    if activity.cycling {
        modes.insert("🚴‍")
    }

    if activity.automotive {
        modes.insert("🚗")
    }

    print(modes.joined(separator: ", "))
}
```

`CMMotionActivityManager` is provided by the Core Motion framework.
Devices that support Core Motion are equipped with a motion coprocessor.
By using dedicated hardware,
the system can offload all sensor processing from the CPU
and minimize energy usage.

The first of the _M-series_ coprocessors was the M7,
which arrived in September 2013 with the iPhone 5S.
This coincided with the release of iOS 7 and the Core Motion APIs.

## Feature Drivers

Possibly the most well-known use of motion activities is
["Do Not Disturb While Driving"](https://support.apple.com/en-us/HT208090),
added in iOS 11.
Automotive detection got much better with the introduction of this feature.

> At low speeds, it's hard to distinguish automobile travel from other means
> using accelerometer data alone.
> Although we can only speculate as to how this works,
> it's possible that the iPhone uses magnetometer data from the device compass.
> Because cars and other vehicles are often enclosed in metal,
> electromagnetic flux is reduced.

Beyond safety concerns,
some apps might change their behavior
according to the current mode of transportation.
For example,
a delivery service app might relay changes in motion activity to a server
to recalculate estimated ETA or change the UI to communicate
that the courier has parked their vehicle and are now approaching by foot.

## Traveling Without Moving

`CMMotionActivity` has Boolean properties
for each of the different types of motion
as well as one for whether the device is stationary.
This seems counter-intuitive,
as logic dictates that
you can either be walking or driving a car at a given moment,
but not both.

This point is clarified by the [`CMMotionActivity` documentation](https://developer.apple.com/documentation/coremotion/cmmotionactivity):

> The motion-related properties of this class are not mutually exclusive.
> In other words, it is possible for more than one of the
> motion-related properties to contain the value `true`.
> For example, if the user was **driving in a car**
> and the car stopped at a red light,
> the update event associated with that change in motion would have both
> the `cycling` and `stationary` properties set to true.

Wait, did I say clarified?
I meant... whatever the opposite is.
(I'm pretty sure this should be `automotive`)
Fortunately, the header docs tell us more about what we might expect.
Here are some concrete examples of how this API behaves in different situations:

**Scenario 1**:
You're in a car stopped at a red light

| 🚶‍ `walking` | 🏃‍ `running` | 🚴‍`cycling` | 🚗 `automotive` | 🛑 `stationary` |
| ------------- | ------------- | ------------ | --------------- | --------------- |
| `false`       | `false`       | `false`      | `true`          | `true`          |

**Scenario 2**:
You're in a moving vehicle

| 🚶‍ `walking` | 🏃‍ `running` | 🚴‍`cycling` | 🚗 `automotive` | 🛑 `stationary` |
| ------------- | ------------- | ------------ | --------------- | --------------- |
| `false`       | `false`       | `false`      | `true`          | `false`         |

**Scenario 3**:
The device is in motion, but you're neither walking nor in a moving vehicle

| 🚶‍ `walking` | 🏃‍ `running` | 🚴‍`cycling` | 🚗 `automotive` | 🛑 `stationary` |
| ------------- | ------------- | ------------ | --------------- | --------------- |
| `false`       | `false`       | `false`      | `false`         | `false`         |

**Scenario 4**:
You're a world-famous detective, who,
in the process of chasing a suspect down the corridors of a moving train,
has reached the last car and has stopped to look around
to surmise where they're hiding
_(perhaps that conspicuous, person-sized box in the corner?)_

| 🚶‍ `walking` | 🏃‍ `running` | 🚴‍`cycling` | 🚗 `automotive` | 🛑 `stationary` | 🕵️‍🇧🇪 `poirot` |
| ------------- | ------------- | ------------ | --------------- | --------------- | --------------- |
| `false`       | `true`        | `false`      | `true`          | `true`          | `true`          |

(We're actually not sure what would happen in that last scenario...)

The overall guidance from the documentation is that
you should treat `stationary` to be orthogonal from
all of the other `CMMotionActivity` properties
and that you should be prepared to handle all other combinations.

Each `CMMotionActivity` object also includes a `confidence` property
with possible values of `.low`, `.medium`, and `.high`.
Unfortunately, not much information is provided by the documentation
about what any of these values mean, or how they should be used.
As is often the case,
an empirical approach is recommended;
test your app in the field to
see when different confidence values are produced
and use that information to determine the correct behavior for your app.

## Combining with Location Queries

Depending on your use case,
it might make sense to coordinate Core Motion readings with
[Core Location](https://nshipster.com/core-location-in-ios-8/) data.

You can combine changes in location over time
with low-confidence motion activity readings
to increase accuracy.
Here are some general guidelines for typical ranges of speeds
for each of the modes of transportation:

- Walking speeds typically peak at 2.5 meters per second (5.6 mph, 9 km/h)
- Running speeds range from 2.5 to 7.5 meters per second (5.6 – 16.8 mph, 9 – 27 km/h)
- Cycling speeds range from 3 to 12 meters per second (6.7 – 26.8 mph, 10.8 – 43.2 km/h)
- Automobile speeds can exceed 100 meters per second (220 mph, 360 km/h)

Alternatively, you might use location data to change the UI
depending on whether the current location is in a body of water.

```swift
if currentLocation.intersects(waterRegion) {
    if activity.walking {
        print("🏊‍")
    } else if activity.automotive {
        print("🚢")
    }
}
```

However, location data should only be consulted if absolutely necessary ---
and when you do, it should be done as sparingly as possible,
such as by monitoring for only significant location changes.
Reason being,
location data requires turning on the GPS and/or cellular radio,
which are both energy intensive.

---

`CMMotionActivityManager` is one of many great APIs in Core Motion
that you can use to build immersive, responsive apps.

If you haven't considered the potential of
incorporating device motion into your app
(or maybe haven't looked at Core Motion for a while),
you might be surprised at what's possible.
