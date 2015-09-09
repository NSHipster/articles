---
title: MKLocalSearch
author: Mattt Thompson
category: Cocoa
excerpt: "In all of the hubbub of torch burning and pitchfork raising, you may have completely missed a slew of additions to MapKit in iOS 6.1."
status:
    swift: 1.1
---

Look, we get it: people are upset about Apple Maps.

What should have been a crowning feature for iOS 6 became the subject of an official apology due to its embarrassing inaccuracies and the removal of public transportation information.

In all of the hubbub of torch burning and pitchfork raising, you may have completely missed a slew of additions to MapKit in iOS 6.1. Namely: `MKLocalSearch`.

---

`MKLocalSearch` allows developers to find nearby points of interest within a geographic region.

But before you go and rush into using `MKLocalSearch`, you'll have to know a few things about its friends. You see, `MKLocalSearch` has its functionality divided across `MKLocalSearchRequest` and `MKLocalSearchResponse`:

~~~{swift}
let request = MKLocalSearchRequest()
request.naturalLanguageQuery = "Restaurants"
request.region = mapView.region

let search = MKLocalSearch(request: request)
search.startWithCompletionHandler { (response, error) in
    for item in response.mapItems {
        // ...
    }
}
~~~

~~~{objective-c}
MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
request.naturalLanguageQuery = @"Restaurants";
request.region = mapView.region;
MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
[search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
    NSLog(@"Map Items: %@", response.mapItems);
}];
~~~

`MKLocalSearchRequest` takes a `naturalLanguageQuery`, such as "Taxidermists", and an optional bounding geographic `region` to constrain results. In practice, the `region` is usually passed from an `MKMapView`.

`MKLocalSearchResponse` is returned in the eponymous block handler of `MKLocalSearch -startWithCompletionHandler:`, and returns an array of `MKMapItem` objects. Each `MKMapItem` contains information like `name`, `phoneNumber`, `url` and address information via the `placemark` property.

If you keep a reference to your `MKLocalSearch` object, you can optionally `-cancel` the request, such as on `-viewWillDisappear:` or the like.

## Where's The Beef?

`MKLocalSearch` is a relatively straight-forward API (albeit perhaps worse off for eschewing a simpler single-class interface)... so what's the big deal?

**API limits.** Or rather, the lack of them. Let me explain:

Perhaps the most counter-intuitive things about MapKit in iOS 6 is that _it's still widely used_. Nevermind the "Apple Maps-gate" melodrama, MapKit, even with the introduction of impressive iOS mapping SDKs from [Google](https://developers.google.com/maps/documentation/ios/) and [MapBox](http://mapbox.com/mobile/), [developers are still using MapKit](http://appleinsider.com/articles/13/03/18/developers-prefer-apples-ios-maps-sdk-over-google-maps).

Part of this may be aesthetics, but a lot has to do with a certain level of home-field advantage, too. Because of MapKit's close ties to UIKit, it can be customized more easily and more extensively by third-party developers.

This brings us back to API call limits. When developing with another mapping SDK or geospatial webservice, licensing terms are almost necessarily going to be more limited than what Apple makes available for free. Free is a tough price to beat, and it's all-the-more compelling because there is no worry of going over API limits for tile loading or API calls.

## Where Do We Go From Here?

With the introduction of `MKLocalSearch`, one can be hopeful of more first-party webservices being exposed in a similar fashion. Expanded geospatial search? Or perhaps first-party APIs to iTunes media streaming?

One can dare to dream, after all...

---

`MKLocalSearch` provides a simple way to find local points of interest. Because of its no-hassle webservice integration and tight integration with MapKit, any location-based app would do well to take advantage of it.
