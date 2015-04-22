---
title: MKLocalSearch
author: Mattt Thompson
category: Cocoa
translator: April Peng
excerpt: "在喧闹纷繁的事态下，你可能完全没有发现 iOS 6.1 中的 MapKit 增加了什么。"
---

是的，我们知道的：人们对 Apple 的地图很无所适从。

本应该是 iOS 6 至高无上的新特性，却由于其尴尬的不准确定位以及移除了公共交通信息让官方出来为之道歉。

沉浸在这所有的沸沸嚷嚷中，你可能完全没有注意到在 iOS 6.1 的 MapKit 里新增加的一个小部件：`MKLocalSearch`。

---

`MKLocalSearch` 允许开发者得到一个地理区域内附近的兴趣点。

但在你急于去使用 `MKLocalSearch` 之前，你必须了解一些它的朋友的事情。你看，`MKLocalSearch` 是有区别于 `MKLocalSearchRequest` 和 `MKLocalSearchResponse` 的功能的：

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

像一个 “动物标本剥制师” 一样，`MKLocalSearchRequest` 需要一个 `naturalLanguageQuery` 和一个可选的边界地域 `region` 来约束结果。在实践中，`region` 通常从一个 `MKMapView` 传进来。

`MKLocalSearchResponse` 在 `MKLocalSearch -startWithCompletionHandler:` 的同名 block handler 中被返回，并且返回一个 `MKMapItem` 对象的数组。每个 `MKMapItem` 通过 `placemark` 属性包含了诸如 `name`，`phoneNumber`，`url` 和地址这样的信息。

如果你保持一个 `MKLocalSearch` 对象的引用，你可以选择性的像 `-viewWillDisappear:` 或之类的一样来 `-cancel` 请求。

## 重点在哪儿？

`MKLocalSearch` 是一种相对直接的 API（尽管也许更糟的是它仅是一个简单的单类接口）......所以有什么大不了的？

**API 的限制。** 或者说，它们的缺陷。让我来解释一下：

或许关于 iOS 6 中 MapKit 最反直觉的事情是 _它仍然被广泛的使用_。别去管 “苹果地图门” 的闹剧，即使从 [Google](https://developers.google.com/maps/documentation/ios/) 和 [MapBox](http://mapbox.com/mobile/) 引入了非常棒的 iOS 地图 SDK，[开发者们仍在使用 MapKit](http://appleinsider.com/articles/13/03/18/developers-prefer-apples-ios-maps-sdk-over-google-maps).

有部分原因可能是审美问题，但更多的则是因为主场优势。由于 MapKit 与 UIKit 紧密联系，它可以更容易，更广泛地由第三方开发者定制。

这把我们带回到了 API 调用的限制。当用另一种地图 SDK 或地理空间 Web 服务开发的时候，许可条款几乎必然比苹果公司免费提供的更为有限。免费是一个艰难的问题，而且更没得选的是区域性加载或调用 API 的时候不用担心越过 API 的限制。

## 我们还能做什么呢？

通过引入 `MKLocalSearch`，在类似的场景中，苹果提供了越来越多的原生 API。扩展的地理空间搜索？或者是 iTunes 流媒体的第一方 API？

毕竟，人们可以敢于梦想...

---

`MKLocalSearch` 提供了一种简单的方法来找到当地兴趣点。由于其无争议的 web 服务集成，以及与 MapKit 的紧密集成，任何基于位置的应用程序都该好好地利用它。
