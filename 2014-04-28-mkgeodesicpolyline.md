---
title: MKGeodesicPolyline
author: Mattt Thompson
category: Cocoa
excerpt: "We knew that the Earth was not flat long before 1492. Early navigators observed the way ships would dip out of view over the horizon many centuries before the Age of Discovery. For many iOS developers, though, a flat MKMapView was a necessary conceit until recently."
status:
    swift: t.b.c.
---

We knew that the Earth was not flat long before 1492. Early navigators observed the way ships would dip out of view over the horizon many centuries before the Age of Discovery.

For many iOS developers, though, a flat `MKMapView` was a necessary conceit until recently.

What changed? The discovery of `MKGeodesicPolyline`, which is the subject of this week's article.

* * *

[`MKGeodesicPolyline`](https://developer.apple.com/library/ios/documentation/MapKit/Reference/MKGeodesicPolyline_class/Reference/Reference.html) was introduced to the Map Kit framework in iOS 7. As its name implies, it creates a [geodesic](http://en.wikipedia.org/wiki/Geodesic)—essentially a straight line over a curved surface.

On the surface of a <del><a href="http://en.wikipedia.org/wiki/Sphere">sphere</a></del> <del><ins><a href="http://en.wikipedia.org/wiki/Oblate_spheroid">oblate spheroid</a></ins></del> <ins><a href="http://en.wikipedia.org/wiki/Geoid">geoid</a></ins>, the shortest distance between two points appears as an arc on a flat projection. Over large distances, this takes a [pronounced, circular shape](http://en.wikipedia.org/wiki/Great-circle_distance).

An `MKGeodesicPolyline` is created with an array of 2 `MKMapPoint`s or `CLLocationCoordinate2D`s:

### Creating an `MKGeodesicPolyline`

~~~{objective-c}
CLLocation *LAX = [[CLLocation alloc] initWithLatitude:33.9424955
                                             longitude:-118.4080684];
CLLocation *JFK = [[CLLocation alloc] initWithLatitude:40.6397511
                                             longitude:-73.7789256];

CLLocationCoordinate2D coordinates[2] =
    {LAX.coordinate, JFK.coordinate};

MKGeodesicPolyline *geodesicPolyline =
    [MKGeodesicPolyline polylineWithCoordinates:coordinates
                                          count:2];

[mapView addOverlay:geodesicPolyline];
~~~

Although the overlay looks like a smooth curve, it is actually comprised of thousands of tiny line segments (true to its `MKPolyline` lineage):

~~~{objective-c}
NSLog(@"%d", geodesicPolyline.pointsCount) // 3984
~~~

Like any object conforming to the `<MKOverlay>` protocol, an `MKGeodesicPolyline` instance is displayed by adding it to an `MKMapView` with `-addOverlay:` and implementing `mapView:rendererForOverlay:`:

### Rendering `MKGeodesicPolyline` on an `MKMapView`

~~~{objective-c}
#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if (![overlay isKindOfClass:[MKPolyline class]]) {
        return nil;
    }

    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
    renderer.lineWidth = 3.0f;
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.5;

    return renderer;
}
~~~

![MKGeodesicPolyline on an MKMapView](http://nshipster.s3.amazonaws.com/mkgeodesicpolyline.jpg)

> For comparison, here's the same geodesic overlaid with a route created from [`MKDirections`](http://nshipster.com/mktileoverlay-mkmapsnapshotter-mkdirections/):

![MKGeodesicPolyline on an MKMapView compared to MKDirections Polyline](http://nshipster.s3.amazonaws.com/mkgeodesicpolyline-with-directions.jpg)

[As the crow flies](http://en.wikipedia.org/wiki/As_the_crow_flies), it's 3,983 km.<br/>
As the wolf runs, it's 4,559 km—nearly 15% longer.<br/>
…and that's just distance; taking into account average travel speed, the total time is ~5 hours by air and 40+ hours by land.

### Animating an `MKAnnotationView` on a `MKGeodesicPolyline`

Since geodesics make reasonable approximations for flight paths, a common use case would be to animate the trajectory of a flight over time.

To do this, we'll make properties for our map view and geodesic polyline between LAX and JFK, and add new properties for the `planeAnnotation` and `planeAnnotationPosition` (the index of the current map point for the polyline):

~~~{objective-c}
@interface MapViewController () <MKMapViewDelegate>
@property MKMapView *mapView;
@property MKGeodesicPolyline *flightpathPolyline;
@property MKPointAnnotation *planeAnnotation;
@property NSUInteger planeAnnotationPosition;
@end
~~~

Next, right below the initialization of our map view and polyline, we create an `MKPointAnnotation` for our plane:

~~~{objective-c}
self.planeAnnotation = [[MKPointAnnotation alloc] init];
self.planeAnnotation.title = NSLocalizedString(@"Plane", nil);
[self.mapView addAnnotation:self.planeAnnotation];

[self updatePlanePosition];
~~~

That call to `updatePlanePosition` in the last line ticks the animation and updates the position of the plane:

~~~{objective-c}
- (void)updatePlanePosition {
    static NSUInteger const step = 5;

    if (self.planeAnnotationPosition + step >= self.flightpathPolyline.pointCount) {
        return;
    }

    self.planeAnnotationPosition += step;
    MKMapPoint nextMapPoint = self.flightpathPolyline.points[self.planeAnnotationPosition];

    self.planeAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint);

    [self performSelector:@selector(updatePlanePosition) withObject:nil afterDelay:0.03];
}
~~~


We'll perform this method roughly 30 times a second, until the plane has arrived at its final destination.

Finally, we implement `mapView:viewForAnnotation:` to have the annotation render on the map view:

~~~{objective-c}
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString * PinIdentifier = @"Pin";

    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
    };

    annotationView.image = [UIImage imageNamed:@"plane"];

    return annotationView;
}
~~~

![MKAnnotationView without Rotation](http://nshipster.s3.amazonaws.com/mkgeodesicpolyline-airplane-animate.gif)

Hmm… close but no [SkyMall Personalized Cigar Case Flask](http://www.skymall.com/personalized-cigar-case-flask/GC900.html).

Let's update the rotation of the plane as it moves across its flightpath.

### Rotating an `MKAnnotationView` along a Path

To calculate the plane's direction, we'll take the slope from the previous and next points:

~~~{objective-c}
MKMapPoint previousMapPoint = self.flightpathPolyline.points[self.planeAnnotationPosition];
self.planeAnnotationPosition += step;
MKMapPoint nextMapPoint = self.flightpathPolyline.points[self.planeAnnotationPosition];

self.planeDirection = XXDirectionBetweenPoints(previousMapPoint, nextMapPoint);
self.planeAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint);
~~~

`XXDirectionBetweenPoints` is a function that returns a `CLLocationDirection` (0 – 360 degrees, where North = 0) given two `MKMapPoint`s.

> We calculate from `MKMapPoint`s rather than converted coordinates, because we're interested in the slope of the line on the flat projection.

~~~{objective-c}
static CLLocationDirection XXDirectionBetweenPoints(MKMapPoint sourcePoint, MKMapPoint destinationPoint) {
    double x = destinationPoint.x - sourcePoint.x;
    double y = destinationPoint.y - sourcePoint.y;

    return fmod(XXRadiansToDegrees(atan2(y, x)), 360.0f) + 90.0f;
}
~~~

That convenience function `XXRadiansToDegrees` (and its partner, `XXDegreesToRadians`) are simply:

~~~{objective-c}
static inline double XXRadiansToDegrees(double radians) {
    return radians * 180.0f / M_PI;
}

static inline double XXDegreesToRadians(double degrees) {
    return degrees * M_PI / 180.0f;
}
~~~

That direction is stored in a new property, `@property CLLocationDirection planeDirection;`, calculated from `self.planeDirection = XXDirectionBetweenPoints(currentMapPoint, nextMapPoint);` in `updatePlanePosition` (ideally renamed to `updatePlanePositionAndDirection` with this addition). To make the annotation rotate, we apply a `transform` on `annotationView`:

~~~{objective-c}
annotationView.transform =
    CGAffineTransformRotate(self.mapView.transform,
                            XXDegreesToRadians(self.planeDirection));
~~~

![MKAnnotationView with Rotation](http://nshipster.s3.amazonaws.com/mkgeodesicpolyline-airplane-animate-rotate.gif)

Ah much better! At last, we have mastered the skies with a fancy visualization, worthy of any travel-related app.

* * *

Perhaps more than any other system framework, MapKit has managed to get incrementally better, little by little with every iOS release [[1]](http://nshipster.com/mktileoverlay-mkmapsnapshotter-mkdirections/) [[2]](http://nshipster.com/mklocalsearch/). For anyone with a touch-and-go relationship to the framework, returning after a few releases is a delightful experience of discovery and rediscovery.

I look forward to seeing what lies on the horizon with iOS 8 and beyond.
