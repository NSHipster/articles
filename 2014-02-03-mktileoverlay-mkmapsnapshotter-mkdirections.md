---
title: "MKTileOverlay,<br/>MKMapSnapshotter &<br/>MKDirections"
author: Mattt Thompson
category: Cocoa
excerpt: "Unless you work with MKMapView. on a regular basis, the last you may have heard about the current state of cartography on iOS may not have been under the cheeriest of circumstances. Therefore, it may come as a surprise maps on iOS have gotten quite a bit better in the intervening releases. Quite good, in fact."
status:
    swift: t.b.c.
---

Unless you work with `MKMapView` on a regular basis, the last you may have heard about the current state of cartography on iOS may not have been [under the cheeriest of circumstances](http://www.apple.com/letter-from-tim-cook-on-maps/). Even now, years after the ire of armchair usability experts has moved on to iOS 7's distinct "look and feel", the phrase "Apple Maps" still does not inspire confidence in the average developer.

Therefore, it may come as a surprise maps on iOS have gotten quite a bit better in the intervening releases. Quite good, in fact—especially with the new mapping APIs introduced in iOS 7.  These new APIs not only expose the advanced presentational functionality seen in Maps, but provide workarounds for MapKit's limitations.

This week on NSHipster, we'll introduce `MKTileOverlay`, `MKMapSnapshotter`, and `MKDirections`: three new MapKit APIs introduced in iOS 7 that unlock a new world of possibilities.

* * *

## MKTileOverlay

Don't like the default Apple Maps tiles? [`MKTileOverlay`](https://developer.apple.com/library/ios/documentation/MapKit/Reference/MKTileOverlay_class/Reference/Reference.html) allows you to seamlessly swap out to another tile set in just a few lines of code.

> Just like [OpenStreetMap](http://www.openstreetmap.org) and [Google Maps](https://maps.google.com), MKTileOverlay uses [spherical mercator projection (EPSG:3857)](http://en.wikipedia.org/wiki/Mercator_projection#The_spherical_model).

### Setting Custom Map View Tile Overlay

~~~{objective-c}
static NSString * const template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";

MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:template];
overlay.canReplaceMapContent = YES;

[self.mapView addOverlay:overlay
                   level:MKOverlayLevelAboveLabels];
~~~

MKTileOverlay is initialized with a URL template string, with the `x` & `y` tile coordinates within the specified zoom level. [MapBox has a great explanation for this scheme is used to generate tiles](https://www.mapbox.com/developers/guide/):

> Each tile has a z coordinate describing its zoom level and x and y coordinates describing its position within a square grid for that zoom level. Hence, the very first tile in the web map system is at 0/0/0.

<table style="display:block;width:256px;margin:10px auto">
    <tr>
        <td style="background-image:url(https://a.tiles.mapbox.com/v3/examples.map-9ijuk24y/0/0/0.png);width:256px;height:256px;padding:0;border:1px #fff solid;"><span style="text-align:center;display:block">0/0/0</span></td>
    </tr>
</table>

> Zoom level 0 covers the entire globe. The very next zoom level divides z0 into four equal squares such that 1/0/0 and 1/1/0 cover the northern hemisphere while 1/0/1 and 1/1/1 cover the southern hemisphere.

<table style="display:block;width:514px;margin:10px auto;">
    <tr>
        <td style="background-image:url(https://a.tiles.mapbox.com/v3/examples.map-9ijuk24y/1/0/0.png);width:256px;height:256px;padding:0;border:1px #fff solid;"><span style="text-align:center;display:block">1/0/0</span></td>
        <td style="background-image:url(https://a.tiles.mapbox.com/v3/examples.map-9ijuk24y/1/1/0.png);width:256px;height:256px;padding:0;border:1px #fff solid;"><span style="text-align:center;display:block">1/1/0</span></td>
    </tr>
    <tr>
        <td style="background-image:url(https://a.tiles.mapbox.com/v3/examples.map-9ijuk24y/1/0/1.png);width:256px;height:256px;padding:0;border:1px #fff solid;"><span style="text-align:center;display:block">1/0/1</span></td>
        <td style="background-image:url(https://a.tiles.mapbox.com/v3/examples.map-9ijuk24y/1/1/1.png);width:256px;height:256px;padding:0;border:1px #fff solid;"><span style="text-align:center;display:block">1/1/1</span></td>
    </tr>
</table>

> Zoom levels are related to each other by powers of four - `z0` contains 1 tile, `z1` contains 4 tiles, `z2` contains 16, and so on. Because of this exponential relationship the amount of detail increases at every zoom level but so does the amount of bandwidth and storage required to serve up tiles. For example, a map at `z15` – about when city building footprints first become visible – requires about 1.1 billion tiles to cover the entire world. At `z17`, just two zoom levels greater, the world requires 17 billion tiles.

After setting `canReplaceMapContent` to `YES`, the overlay is added to the `MKMapView`.

In the map view's delegate, `mapView:rendererForOverlay:` is implemented simply to return a new `MKTileOverlayRenderer` instance when called for the `MKTileOverlay` overlay.

~~~{objective-c}
#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }

    return nil;
}
~~~

> Speaking of [MapBox](https://www.mapbox.com), [Justin R. Miller](https://github.com/incanus) maintains [MBXMapKit](https://www.mapbox.com/mbxmapkit/), a MapBox-enabled drop-in replacement for `MKMapView`. It's the easiest way to get up-and-running with this world-class mapping service, and highly recommended for anyone looking to make an impact with maps in their next release.

### Implementing Custom Behavior with MKTileOverlay Subclass

If you need to accommodate a different tile coordinate scheme with your server, or want to add in-memory or offline caching, this can be done by subclassing `MKTileOverlay` and overriding `-URLForTilePath:` and `-loadTileAtPath:result:`:

~~~{objective-c}
@interface XXTileOverlay : MKTileOverlay
@property NSCache *cache;
@property NSOperationQueue *operationQueue;
@end

@implementation XXTileOverlay

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://tile.example.com/%d/%d/%d", path.z, path.x, path.y]];
}

- (void)loadTileAtPath:(MKTileOverlayPath)path
                result:(void (^)(NSData *data, NSError *error))result
{
    if (!result) {
        return;
    }

    NSData *cachedData = [self.cache objectForKey:[self URLForTilePath:path]];
    if (cachedData) {
        result(cachedData, nil);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForTilePath:path]];
        [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            result(data, connectionError);
        }];
    }
}

@end
~~~

## MKMapSnapshotter

Another addition to iOS 7 was [`MKMapSnapshotter`](https://developer.apple.com/library/ios/documentation/MapKit/Reference/MKMapSnapshotter_class/Reference/Reference.html), which formalizes the process of creating an image representation of a map view. Previously, this would involve playing fast and loose with the `UIGraphicsContext`, but now images can reliably be created for any particular region and perspective.

> See [WWDC 2013 Session 309: "Putting Map Kit in Perspective"](https://developer.apple.com/wwdc/videos/?id=309) for additional information on how and when to use `MKMapSnapshotter`.

### Creating a Map View Snapshot

~~~{objective-c}
MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
options.region = self.mapView.region;
options.size = self.mapView.frame.size;
options.scale = [[UIScreen mainScreen] scale];

NSURL *fileURL = [NSURL fileURLWithPath:@"path/to/snapshot.png"];

MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
[snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
    if (error) {
        NSLog(@"[Error] %@", error);
        return;
    }

    UIImage *image = snapshot.image;
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToURL:fileURL atomically:YES];
}];
~~~

First, an `MKMapSnapshotOptions` object is created, which is used to specify the region, size, scale, and [camera](https://developer.apple.com/library/mac/documentation/MapKit/Reference/MKMapCamera_class/Reference/Reference.html) used to render the map image.

Then, these options are passed to a new `MKMapSnapshotter` instance, which asynchronously creates an image with `-startWithCompletionHandler:`. In this example, a PNG representation of the image is written to disk.

### Drawing Annotations on Map View Snapshot

However, this only draws the map for the specified region; annotations are rendered separately.

Including annotations—or indeed, any additional information to the map snapshot—can be done by dropping down into Core Graphics:

~~~{objective-c}
[snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
      if (error) {
          NSLog(@"[Error] %@", error);
          return;
      }

      MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];

      UIImage *image = snapshot.image;
      UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
      {
          [image drawAtPoint:CGPointMake(0.0f, 0.0f)];

          CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
          for (id <MKAnnotation> annotation in self.mapView.annotations) {
              CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
              if (CGRectContainsPoint(rect, point)) {
                  point.x = point.x + pin.centerOffset.x -
                                (pin.bounds.size.width / 2.0f);
                  point.y = point.y + pin.centerOffset.y -
                                (pin.bounds.size.height / 2.0f);
                  [pin.image drawAtPoint:point];
              }
          }

          UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
          NSData *data = UIImagePNGRepresentation(compositeImage);
          [data writeToURL:fileURL atomically:YES];
      }
      UIGraphicsEndImageContext();
}];
~~~

## MKDirections

The final iOS 7 addition to MapKit that we'll discuss is [`MKDirections`](https://developer.apple.com/library/mac/documentation/MapKit/Reference/MKDirections_class/Reference/Reference.html).

> `MKDirections`' spiritual predecessor (of sorts), [`MKLocalSearch`](https://developer.apple.com/library/ios/documentation/MapKit/Reference/MKLocalSearch/Reference/Reference.html) was discussed in [a previous NSHipster article](http://nshipster.com/mklocalsearch/)

As its name implies, `MKDirections` fetches routes between two waypoints. A `MKDirectionsRequest` object is initialized with a `source` and `destination`, and is then passed into an `MKDirections` object, which can calculate several possible routes and estimated travel times.

It does so asynchronously, with `calculateDirectionsWithCompletionHandler:`, which returns either an `MKDirectionsResponse` object or an `NSError` describing why the directions request failed. An `MKDirectionsResponse` object contains an array of `routes`: `MKRoute` objects with an array of `MKRouteStep` `steps` objects, a polyline shape that can be drawn on the map, and other information like estimated travel distance and any travel advisories in effect.

Building on the previous example, here is how `MKDirections` might be used to create an array of images representing each step in a calculated route between two points (which might then be pasted into an email or cached on disk):

### Getting Snapshots for each Step of Directions on a Map View

~~~{objective-c}
NSMutableArray *mutableStepImages = [NSMutableArray array];

MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
request.source = [MKMapItem mapItemForCurrentLocation];
request.destination = nil;//...;

MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
    if (error) {
        NSLog(@"[Error] %@", error);
        return;
    }

    MKRoute *route = [response.routes firstObject];
    for (MKRouteStep *step in route.steps) {
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            if (error) {
                NSLog(@"[Error] %@", error);
                return;
            }

            UIImage *image = snapshot.image;
            UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
            {
                [image drawAtPoint:CGPointMake(0.0f, 0.0f)];

                CGContextRef c = UIGraphicsGetCurrentContext();
                MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:step.polyline];
                if (polylineRenderer.path) {
                    [polylineRenderer applyStrokePropertiesToContext:c atZoomScale:1.0f];
                    CGContextAddPath(c, polylineRenderer.path);
                    CGContextStrokePath(c);
                }

                CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
                for (MKMapItem *mapItem in @[response.source, response.destination]) {
                    CGPoint point = [snapshot pointForCoordinate:mapItem.placemark.location.coordinate];
                    if (CGRectContainsPoint(rect, point)) {
                        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                        pin.pinColor = [mapItem isEqual:response.source] ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;

                        point.x = point.x + pin.centerOffset.x -
                            (pin.bounds.size.width / 2.0f);
                        point.y = point.y + pin.centerOffset.y -
                            (pin.bounds.size.height / 2.0f);
                        [pin.image drawAtPoint:point];
                    }
                }

                UIImage *stepImage = UIGraphicsGetImageFromCurrentImageContext();
                [mutableStepImages addObject:stepImage];
            }
            UIGraphicsEndImageContext();
        }];
    }
}];
~~~

* * *

As the tools used to map the world around us become increasingly sophisticated and ubiquitous, we become ever more capable of uncovering and communicating connections we create between ideas and the spaces they inhabit. With the introduction of several new MapKit APIs, iOS 7 took great strides to expand on what's possible. Although (perhaps unfairly) overshadowed by the mistakes of the past, MapKit is, and remains an extremely capable framework, worthy of further investigation.
