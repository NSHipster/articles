---
title: UIFieldBehavior
author: Jordan Morgan
category: Cocoa
excerpt: >
  With the design refresh of iOS in its 7th release,
  skeuomorphic design was famously sunset.
  In its place,
  a new paradigm emerged,
  in which UI controls were made to _feel_ like physical objects
  rather than simply look like them.
status:
  swift: 4.2
---

The decade mark for iOS has come and gone.
Once a nascent craft,
iOS development today has a well-worn, broken-in feel to it.

And yet, when I step outside my comfort zone of
table views, labels, buttons, and the like,
I often find myself stumbling upon pieces of Cocoa Touch
that I'd either overlooked or completely forgotten about.
When I do, it's like picking an old book from a shelf;
the anticipation of what might be tucked away in its pages
invariably swells up within you.

Recently, `UIFieldBehavior` has been my dust-covered tome
sitting idly inside UIKit.
An API built to model complex field physics for UI elements
isn’t a typical use case,
nor is it likely to be the hot topic among fellow engineers.
But, when you need it, you _need_ it, and not much else will do.
And as purveyors of the oft-forgotten or seldom used,
it serves as an excellent topic for this week’s NSHipster article.

---

With the design refresh of iOS in its 7th release,
skeuomorphic design was famously sunset.
In its place,
a new paradigm emerged,
in which UI controls were made to _feel_ like physical objects
rather than simply look like them.
New APIs would be needed to usher in this new era of UI design,
and so we were introduced to
[UIKit Dynamics](https://developer.apple.com/documentation/uikit/animation_and_haptics/uikit_dynamics).

Examples of this reach out across the entire OS:
the bouncy lock screen,
the flickable photos,
those oh-so-bubbly message bubbles ---
these and many other interactions leverage some flavor of UIKit Dynamics
(of which there are several).

- `UIAttachmentBehavior`:
  Creates a relationship between two items,
  or an item and a given anchor point.
- `UICollisionBehavior`:
  Causes one or more objects to bounce off of one another
  instead of overlapping without interaction.
- `UIFieldBehavior`:
  Enables an area or item to participate in field-based physics.
- `UIGravityBehavior`:
  Applies a gravitational force, or pull.
- `UIPushBehavior`:
  Creates an instantaneous or continuous force.
- `UISnapBehavior`:
  Produces a motion that dampens over time.

For this article,
let's take a look at `UIFieldBehavior`,
which our good friends in Cupertino used to build the
<abbr title="picture-in-picture">PiP</abbr> functionality
seen in FaceTime calls.

{% asset facetime-picture-in-picture.png alt="FaceTime" title="Image: Apple Inc. All Rights reserved." %}

## Understanding Field Behaviors

Apple mentions that `UIFieldBehavior` applies "field-based" physics,
but what does that mean, exactly?
Thankfully, it's more relatable that one might think.

There are plenty of examples of field-based physics in the real world,
whether it's
the pull of a magnet,
the \*sproing\* of a spring,
the force of gravity pulling you down to earth.
Using `UIFieldBehavior`,
we can designate areas of our view to apply certain physics effects
whenever an item enters into them.

Its approachable API design allows us to complex physics
without much more than a factory method:

```swift
let drag = UIFieldBehavior.dragField()
```

```objective-c
UIFieldBehavior *drag = [UIFieldBehavior dragField];
```

Once we have a field force at our disposal,
it's a matter of placing it on the screen
and defining its area of influence.

```swift
drag.position = view.center
drag.region = UIRegion(size: bounds.size)
```

```objective-c
drag.position = self.view.center;
drag.region = [[UIRegion alloc] initWithSize:self.view.bounds.size];
```

If you need more granular control over a field's behavior,
you can configure its `strength` and `falloff`,
as well as any additional properties specific to that field type.

---

All UIKit Dynamics behaviors require some setup to take effect,
and `UIFieldBehavior` is no exception.
The flow looks generally something like this:

- Create an instance of a `UIDynamicAnimator`
  to provide the context for any animations affecting its dynamic items.
- Initialize the desired behaviors to use.
- Add the views you wish to be involved with each behavior.
- Add those behaviors to the dynamic animator from step one.

```swift
lazy var animator:UIDynamicAnimator = {
    return UIDynamicAnimator(referenceView: view)
}()

let drag = UIFieldBehavior.dragField()

// viewDidLoad:
drag.addItem(anotherView)
animator.addBehavior(drag)
```

```objective-c
@property (strong, nonatomic, nonnull) UIDynamicAnimator *animator;
@property (strong, nonatomic, nonnull) UIFieldBehavior *drag;

// viewDidLoad:
self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
self.drag = [UIFieldBehavior dragField];

[self.drag addItem:self.anotherView];
[self.animator addBehavior:self.drag];
```

> Take care to keep a strong reference to you `UIKitDynamicAnimator` object.
> You don't typically need to do this for behaviors
> because the animator takes ownership to a behavior once it's added.

For a _bona fide_ example of `UIFieldBehavior`,
let's take a look at how FaceTime leverages it
to make the small rectangular view of the front-facing camera
stick to each corner of the view's bounds.

## Face to Face with Spring Fields

During a FaceTime call,
you can flick your picture-in-picture
to one of the corners of the screen.
How do we get it to move fluidly but still stick?

One approach might entail
checking a gesture recognizer's end state,
calculating which corner to settle into,
and animating as necessary.
The problem here is that we likely would lose the "secret sauce"
that Apple painstakingly applies to these little interactions,
such as the interpolation and dampening that occurs
as the avatar settles into a corner.

This is a textbook situation for `UIFieldBehavior`'s spring field.
If we think about how a literal spring works,
it exerts a linear force equal to the amount of strain that's put on it.
So, if we push down on a coiled spring
we expect it to snap back into place once we let go.

This is also why spring fields
can help contain items within a particular part of your UI.
You could think of a boxing ring
and how its elastic rope keeps contestants within the ring.
With springs, though, the rope would originate from the center of the ring
and be pulled back to each edge.

A spring field works a lot like this.
Imagine if our view's bounds were divided into four rectangles,
and we had these springs hanging out around the edges of each one.
The springs would be "pushed" down from the center of the rectangle
to the edge of its corner.
When the avatar enters any of the corners,
the spring is "let go" and gives us that nice little push that we're after.

> The spring field is created by replicating
> [Hooke's Law](https://phys.org/news/2015-02-law.html)
> to calculate how much force should be applied to the objects within the field.

To take care of the avatar settling into each corner,
we can create a loop that does something like this:

```swift
let topLeftCornerField = UIFieldBehavior.springField()

// Top left corner
topLeftCornerField.position =
    CGPoint(x: layoutMargins.left,
            y: layoutMargins.top)
topLeftCornerField.region =
    UIRegion(size: CGSize(width: bounds.size.width / 2,
                          height: bounds.size.height / 2))

animator.addBehavior(topLeftCornerField)
topLeftCornerField.addItem(facetimeAvatar)

// Continue to create a spring field for each corner...
```

```objective-c
UIFieldBehavior *topLeftCornerField = [UIFieldBehavior springField];

// Top left corner
topLeftCornerField.position = CGPointMake(self.layoutMargins.left, self.layoutMargins.top);
topLeftCornerField.region = [[UIRegion alloc] initWithSize:CGSizeMake(self.bounds.size.width/2, self.bounds.size.height/2)];

[self.animator addBehavior:topLeftCornerField];
[self.topLeftCornerField addItem:self.facetimeAvatar];

// Continue to create a spring field for each corner...
```

## Debugging Physics

It's not easy to conceptualize the interactions of invisible field forces.
Thankfully, Apple anticipated as much
and provides a somewhat out-of-the-box way to solve this problem.

Tucked away inside of `UIDynamicAnimator` is a Boolean property, `debugEnabled`.
Setting it to `true` paints the interface with red lines
to visualize field-based effects and their influence.
This can go quite a long way to help you
make sense of how their dynamics are working.

This API isn't exposed publicly,
but you can unlock its potential through a category
or using key-value coding:

```objective-c
@import UIKit;

#if DEBUG

@interface UIDynamicAnimator (Debugging)
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;
@end

#endif
```

or

````swift
animator.setValue(true, forKey: "debugEnabled")
```~
```objective-c
[self.animator setValue:@1 forKey:@"debugEnabled"];
````

Although creating a category involves a bit more legwork, it's the safer option.
The slippery slope of key-value coding can rear its exception-laden head
with any iOS release in the future,
as the price of convenience is typically anything but free.

With debugging enabled,
it appears as though each corner has a spring effect attached to it.
Running and using our fledgling app, however,
reveals that it's not enough to complete the effect we're seeking.

{% asset uidynamicanimator-debug.png %}

## Aggregating Behaviors

Let's take stock of our current situation
to deepen our understanding of field physics.
Currently, we've got a few issues:

1. The avatar could fly off the screen with nothing to keep it constrained
   aside from spring fields
2. It has a knack for rotating in circles.
3. Also, it's a tad slow.

UIKit Dynamics simulates physics ---
perhaps too well.

Fortunately, we can mitigate all of these undesirable side effects.
To wit, they are rather trivial fixes,
but it's the _reason_ why they're needed that's key.

The first issue is solved in a rather trivial fashion
with what is likely UIKit Dynamics most easily understood behavior:
the collision.
To better hone in on how the avatar view should react
once it's acted upon by a spring field,
we need to describe its physical properties in a more intentional manner.
Ideally, we'd want it to behave like it would in real life,
with gravity and friction acting to slow down its momentum.

For such occasions,
`UIDynamicItemBeavior` is ideal.
It lets us attach physical properties to what would otherwise be mere
abstract view instances interacting with a physics engine.
Though UIKit does provide default values for each of these properties
when interacting with the physics engine,
they are likely not tuned to your specific use case.
And UIKit Dynamics almost always falls into the "specific use case" bucket.

It's not hard to foresee how the lack of such an API
could quickly turn problematic.
If we want to model things like a push, pull or velocity
but have no way to specify the object's mass or density,
we'd be omitting a critical piece of the puzzle.

```swift
let avatarPhysicalProperties= UIDynamicItemBehavior(items: [facetimeAvatar])
avatarPhysicalProperties.allowsRotation = false
avatarPhysicalProperties.resistance = 8
avatarPhysicalProperties.density = 0.02
```

```objective-c
UIDynamicItemBehavior *avatarPhysicalProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.facetimeAvatar]];
avatarPhysicalProperties.allowsRotation = NO;
avatarPhysicalProperties.resistance = 8;
avatarPhysicalProperties.density = 0.02;
```

Now the avatar view more closely mirrors real-world physics
in that it slows down a tinge after pushed by a spring field.
The configurations available from `UIDynamicItemBehavior` are impressive,
as support for elasticity, charge and anchoring are also available
to ensure you can continuing tweaking things until they feel right.

Further, it also includes out-of-the-box support
for attaching linear or angular velocity to an object.
This serves as the perfect bookend to our journey with `UIDynamicItemBeavior`,
as we probably want to give our FaceTime avatar a friendly nudge
at the end of the gesture recognizer
to send it off to its nearest corner,
thus letting the relevant spring field take over:

```swift
// Inside a switch for a gesture recognizer...
case .canceled, .ended:
let velocity = panGesture.velocity(in: view)
facetimeAvatarBehavior.addLinearVelocity(velocity, for: facetimeAvatar)
```

```objective-c
// Inside a switch for a gesture recognizer...
case UIGestureRecognizerStateCancelled:
case UIGestureRecognizerStateEnded:
{
CGPoint velocity = [panGesture velocityInView:self.view];
[facetimeAvatarBehavior addLinearVelocity:velocity forItem:self.facetimeAvatar];
break;
}
```

We're almost finished creating our faux FaceTime UI.

To pull the entire experience together,
we need to account for what our FaceTime avatar should do
when it reaches the corners of the animator's view.
We want it to stay contained within it,
and currently,
nothing is keeping it from flying off the screen.
UIKit Dynamics offers us such behavior
to account for these situations by way of `UICollisionBehavior`.

Creating a collision follows a similar pattern
as with using any other UIKit Dynamics behavior,
thanks to consistent API design:

```swift
let parentViewBoundsCollision = UICollisionBehavior(items: [facetimeAvatar])
parentViewBoundsCollision.translatesReferenceBoundsIntoBoundary = true
```

```objective-c
UICollisionBehavior *parentViewBoundsCollision = [[UICollisionBehavior alloc] initWithItems:@[self.facetimeAvatar]];
parentViewBoundsCollision.translatesReferenceBoundsIntoBoundary = YES;
```

Take note of `translatesReferenceBoundsIntoBoundary`.
When `true`,
it treats our animator view's bounds as its collision boundaries.
Recall that this was our initial step in setting up our dynamics stack:

```swift
lazy var animator:UIDynamicAnimator = {
    return UIDynamicAnimator(referenceView: view)
}()
```

```objective-c
self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
```

By aggregating several behaviors to work as one,
we can now bask in our work:

{% asset uifieldbehavior-demo.gif %}

If you want to stray from the FaceTime "sticky" corners,
you are in an ideal position to do so.
`UIFieldBehavior` has many more field physics to offer other than just a spring.
You could experiment by replacing it with a magnetism effect,
or constantly have the avatar rotate around a given point.

---

iOS has largely parted ways with skeuomorphism,
and user experience has come a long way as a result.
We no longer necessarily require
[green felt]({% asset game-center-felt.png @path %})
to know that Game Center represents games and how we can manage them.

Instead, UIKit Dynamics introduces an entirely new way
for users to interact and connect with iOS.
Making UI components behave as they do in the real world
instead of simply looking like them
is a good illustration of how far user experience has evolved since 2007.

Stripping away this layer across the OS
opened the door for UIKit Dynamics to connect
our expectations of how visual elements should react to our actions.
These little connections may seem inconsequential at first glance,
but take them away,
and you'll likely start to realize that things would feel "off."

UIKit Dynamics offers up many flavors of physical behaviors to leverage,
and its field behaviors are perhaps some of the most interesting and versatile.
The next time you see an opportunity to create a connection in your app,
`UIFieldBehavior` might give you the start you need.
