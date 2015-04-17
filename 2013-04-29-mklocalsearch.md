---
title: MKLocalSearch
author: Mattt Thompson
category: Cocoa
excerpt: "In all of the hubbub of torch burning and pitchfork raising, you may have completely missed a slew of additions to MapKit in iOS 6.1."
translator: April Peng
excerpt: "在喧闹纷繁的事态下，你可能完全没有发现 iOS 6.1 中的 MapKit 有增加了什么。"
---

Look, we get it: people are upset about Apple Maps.

是的，我们知道的：人们对 Apple 的地图很无所适从。

What should have been a crowning feature for iOS 6 became the subject of an official apology due to its embarrassing inaccuracies and the removal of public transportation information.

本应该是 iOS 6 至高无上的新特性，却由于其尴尬的不准确定位和公共交通信息的移除让官方出来为之道歉。

In all of the hubbub of torch burning and pitchfork raising, you may have completely missed a slew of additions to MapKit in iOS 6.1. Namely: `MKLocalSearch`.

沉浸在这所有的沸沸嚷嚷中，你可能完全没有注意到在 iOS 6.1 的 MapKit 里新增加的一个小部件：`MKLocalSearch`。

---

`MKLocalSearch` allows developers to find nearby points of interest within a geographic region.

`MKLocalSearch` 允许开发者得到一个地理区域内附近的兴趣点。

But before you go and rush into using `MKLocalSearch`, you'll have to know a few things about its friends. You see, `MKLocalSearch` has its functionality divided across `MKLocalSearchRequest` and `MKLocalSearchResponse`:

但在你急于去使用 `MKLocalSearch` 之前，你必须了解一些它的朋友的事情。你看，`MKLocalSearch` 有区别于 `MKLocalSearchRequest` 和 `MKLocalSearchResponse` 的功能：

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

像一个 “动物标本剥制师” 一样，`MKLocalSearchRequest` 需要一个 `naturalLanguageQuery` 和一个可选的边界地域 `region` 来约束结果。在实践中，`region` 通常从一个 `MKMapView` 传进来。

`MKLocalSearchResponse` is returned in the eponymous block handler of `MKLocalSearch -startWithCompletionHandler:`, and returns an array of `MKMapItem` objects. Each `MKMapItem` contains information like `name`, `phoneNumber`, `url` and address information via the `placemark` property.

`MKLocalSearchResponse` 在 `MKLocalSearch -startWithCompletionHandler:` 的同名 block handler 中被返回，并且返回一个 `MKMapItem` 对象的数组。每个 `MKMapItem` 通过 `placemark` 属性包含了诸如 `name`，`phoneNumber`，`url` 和地址这样的信息。

If you keep a reference to your `MKLocalSearch` object, you can optionally `-cancel` the request, such as on `-viewWillDisappear:` or the like.

如果你保持一个 `MKLocalSearch` 对象的引用，你可以选择性的像 `-viewWillDisappear:` 或之类的一样来 `-cancel` 请求。

## Where's The Beef?

## 重点在哪儿？

`MKLocalSearch` is a relatively straight-forward API (albeit perhaps worse off for eschewing a simpler single-class interface)... so what's the big deal?

`MKLocalSearch` 是一种相对直接的 API（尽管也许更糟的是它仅是一个简单的单类接口）......所以有什么大不了的？

**API limits.** Or rather, the lack of them. Let me explain:

**API 的限制。** 或者说，它们的缺陷。让我来解释一下：

Perhaps the most counter-intuitive things about MapKit in iOS 6 is that _it's still widely used_. Nevermind the "Apple Maps-gate" melodrama, MapKit, even with the introduction of impressive iOS mapping SDKs from [Google](https://developers.google.com/maps/documentation/ios/) and [MapBox](http://mapbox.com/mobile/), [developers are still using MapKit](http://appleinsider.com/articles/13/03/18/developers-prefer-apples-ios-maps-sdk-over-google-maps).

或许关于 iOS 6 中 MapKit 最反直觉的事情是_它仍然被广泛的使用_。别去管 “苹果地图门” 的闹剧，即使从 [Google](https://developers.google.com/maps/documentation/ios/) 和 [MapBox](http://mapbox.com/mobile/) 引入了非常棒的 iOS 地图 SDK，[开发者们仍在使用 MapKit](http://appleinsider.com/articles/13/03/18/developers-prefer-apples-ios-maps-sdk-over-google-maps).

Part of this may be aesthetics, but a lot has to do with a certain level of home-field advantage, too. Because of MapKit's close ties to UIKit, it can be customized more easily and more extensively by third-party developers.

有部分原因可能是审美问题，但更多的则是因为主场优势。由于 MapKit 与 UIKit 紧密联系，它可以更容易，更广泛地由第三方开发者定制。

This brings us back to API call limits. When developing with another mapping SDK or geospatial webservice, licensing terms are almost necessarily going to be more limited than what Apple makes available for free. Free is a tough price to beat, and it's all-the-more compelling because there is no worry of going over API limits for tile loading or API calls.

这把我们带回到了 API 调用的限制。当用另一种地图 SDK 或地理空间 Web 服务开发的时候，许可条款几乎必然比苹果公司免费提供的更为有限。免费是一个艰难的问题，而且更没得选的是区域性加载或调用 API 的时候不用担心越过 API 的限制。

## Where Do We Go From Here?

## 我们还能做什么呢？

With the introduction of `MKLocalSearch`, one can be hopeful of more first-party webservices being exposed in a similar fashion. Expanded geospatial search? Or perhaps first-party APIs to iTunes media streaming?

通过引入 `MKLocalSearch`，应用有希望更早的出现在类似趋势的首批网络服务中。扩展的地理空间搜索？或者是 iTunes 流媒体的第一方 API？

One can dare to dream, after all...

毕竟，人们可以敢于梦想...

---

`MKLocalSearch` provides a simple way to find local points of interest. Because of its no-hassle webservice integration and tight integration with MapKit, any location-based app would do well to take advantage of it.

`MKLocalSearch` 提供了一种简单的方法来找到当地景点。由于其无争议的 web 服务集成，以及与 MapKit 的紧密集成，任何基于位置的应用程序都该好好地利用它。
