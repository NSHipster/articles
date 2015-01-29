---
title: Pay
author: Jack Flintermann
category: ""
translator: Croath Liu
excerpt: "你要在网上买东西的那一刻你会发现有一种现代化带来的独有的焦虑感。那种感觉不能用语言形容，大概是这样的：\"我的信用卡去哪了？卡号是多少？我好想买这个啊卡去哪了！\""
---

**注意：截止 2015 年 1 月，Apple Pay 仅在美国可用。**

你要在网上买东西的那一刻你会发现有一种现代化带来的独有的焦虑感。那种感觉不能用语言形容，大概是这样的："我的信用卡去哪了？卡号是多少？我好想买这个啊卡去哪了！"

当你用 iOS 设备的时候，这种困难又加剧了一层：很有可能你的卡并不在身边，也有可能你会一手拿着信用卡另一手同时在手机上输入，这样的壮举最好还是留给体操运动员和宇航员吧。（开个玩笑，但我打赌苹果应该在某个实验室里面这样实验过了。）

如果你刚好在开发一款能够接受信用卡付款的应用，这种不幸的现象直接会导致你收入的减少。

[Apple Pay](http://apple.com/apple-pay) 改变了这一切。大多数人可能还在关注它发布时提到的在实体店的功用（消费者可以用 iPhone NFC 功能付款），与此同时这也为开发者提升在应用内付款体验的巨大机会。

> 提示：如果你在应用内卖电子化商品或虚拟货币，那么应该用应用内支付而不是 Apple Pay。(请看 App Store Review Guidelines 的这一章 [section 11.2](https://developer.apple.com/app-store/review/guidelines/#purchasing-currencies))。Apple Pay 可以用来销售实体商品和服务。

* * *

## 获取一个 Apple Merchant ID

测试支付之前需要注册一个 Apple Merchant ID。还要先选择一个能够控制信用卡支付流程的服务提供商。苹果提供了一个这类提供商的推荐列表：[Apple Pay Developer Page](http://developer.apple.com/apple-pay) (作者自曝就职于这个推荐列表中的 [Stripe](https://stripe.com/) 公司，但本文涉及到的代码和选择什么服务提供商是无关的)。你的服务提供商会给你一份特别说明指导如何在他们的平台上使用 Apple Pay 来支付，整个流程类似于这样：

- 前往 Apple Developer Center `Certificates, Identifiers, and Profiles` 部分 [创建一个 merchant ID](https://developer.apple.com/account/ios/identifiers/merchant/merchantCreate.action)。
- 接下来，[前往 Certificates 部分](https://developer.apple.com/account/ios/certificate/certificateCreate.action) 新建一个 Apple Pay Certificate。这步需要上传一个 Certificate Signing Request。注册服务提供商的时候他们会给你一个可用的 CSR 文件，你也可以用自己生成的 CSR 文件走完整个流程，但你的服务提供商不能用你生成的 CSR 来完成支付的解谜流程。
- 在 Xcode 里，在工程设置的 "Capabilities" 部分打开 "Apple Pay"。这步可能会要求你选择之前创建的 merchant ID。

## 拿到第一桶金

> Apple Pay 只能在部分 iOS 设备上工作(包括 iPhone6/6+、iPad Mini 3、iPad Air 2)。另外，测试时需要添加 Apple Pay entitlement(在“获取一个 Apple Merchant ID”章节中提到过)。如果想在模拟器中测试，可以用这个库来模拟支付功能(带有测试用的信用卡信息) https://github.com/stripe/ApplePayStubs 。

一旦有了 merchant 账号，使用 Apple Pay 进行收款就近在咫尺了。接下来，需要先检查用户的设备十分支持 Apple Pay 以及用户可使用的信用卡种类：

```swift
let paymentNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(paymentNetworks) {
    // Pay is available!
} else {
    // Show your own credit card form.
}
```
假设此时 Apple Pay 是可使用状态，下一步就是构建一个 `PKPaymentRequest`。这是一个描述用户扣款信息的对象。如果付款行为发生在美国(当然目前 Apple Pay 仅在美国可用)，还有其他一些你需要配置的常量：

```swift
let request = PKPaymentRequest()
request.supportedNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
request.countryCode = "US"
request.currencyCode = "USD"
request.merchantIdentifier = "<#Replace me with your Apple Merchant ID#>"
request.merchantCapabilities = .Capability3DS
```

接下来，用 `paymentSummaryItems` 属性来描述消费者购买的商品。这个属性可以接受一个 `PKPaymentSummaryItem` 数组，`PKPaymentSummaryItem` 有 `label` 和 `amount` 两个属性。这些属性和收据(马上就能看到收据了)上显示的条目相关。

![Payment Authorization](http://nshipster.s3.amazonaws.com/apple-pay-payment-authorization.png)

```swift
let wax = PKPaymentSummaryItem(label: "Mustache Wax", amount: NSDecimalNumber(string: "10.00"))
let discount = PKPaymentSummaryItem(label: "Discount", amount: NSDecimalNumber(string: "-1.00"))

let totalAmount = wax.amount.decimalNumberByAdding(discount.amount)
                            .decimalNumberByAdding(shipping.amount)
let total = PKPaymentSummaryItem(label: "NSHipster", amount: totalAmount)

request.paymentSummaryItems = [wax, discount, shipping, total]
```

注意可以通过给条目价格赋予 0 值或负值来给消费者发放优惠或提示补充信息。然而一个收款的总金额必须大于 0。这里我们用一个 `PKShippingMethod`(继承自 `PKPaymentSummaryItem`)来描述我们发货的商品。之后会加以详述。

然后需要将付款单展示给消费者，通过 `PKPaymentRequest` 创建一个 `PKPaymentAuthorizationViewController` 然后 present 出来。(假设本样例中所有的代码都在一个置于付款页面后面的 `UIViewController` 中编写)。

```swift
let viewController = PKPaymentAuthorizationViewController(paymentRequest: request)
viewController.delegate = self
presentViewController(viewController, animated: true, completion: nil)
```

小提示：

- 这个 View controller 没有占满屏幕 (这时看到的蓝色背景是我们应用中的一部分)。可以在 `PKPaymentAuthorizationViewController` 可见时随时更改背景色。
- 所有的文字信息都是自动大写的。
- 最后横线下的条目和其他的是分开的，这里用来表示总金额。文字会自动以 "PAY" 开头，所以这里用公司名字作为其 `label` 属性开起来会比较合理一些。
- 整套 UI 是通过一个 Remote View Controller present 出来的。这意味着除了传入的 `PKPaymentRequest` 之外是不能修改这个 view 的其他内容或样式的。

## PKPaymentAuthorizationViewControllerDelegate

为了捕获 `PKPaymentAuthorizationViewController` 返回的付款信息需要实现 `PKPaymentAuthorizationViewControllerDelegate` 接口。它有两个必须实现的方法：`-(void)paymentAuthorizationViewController:didAuthorizePayment:completion:` 和 `-(void)paymentAuthorizationViewControllerDidFinish:`。

为了便于理解这些步骤都是如何工作的，我们来看一下 Apple Pay 付款的顺序流程：

- 先像如上所述显示一个 `PKPaymentAuthorizationViewController`。
- 用户通过 Touch ID(如果三次失败之后需要通过密码来验证)授权支付。
- 指纹图案变成一个旋转的加载图案，并且显示 "Processing" 字样。
- Delegate 收到 `paymentAuthorizationViewController:didAuthorizePayment:completion:` 回调。
- 应用同步地和付款服务商以及网站后端进行信息交换，根据付款详情进行扣款。完成之后，你要根据付款结果调用 `completion` 方法并传入 `PKPaymentAuthorizationStatus.Success` 或者 `PKPaymentAuthorizationStatus.Failure` 参数。
- `PKPaymentAuthorizationViewController` 的加载动画变成成功或者失败的图案。如果付款成功了，PassBook 会收到一个通知来对用户的信用卡进行扣款。
- Delegate 收到 `paymentAuthorizationViewControllerDidFinish:` 回调，然后就可以调用 `dismissViewControllerAnimated:completion` 方法来关闭付款页面了。

![Status Indicator](http://nshipster.s3.amazonaws.com/apple-pay-indicators.png)

具体代码如下：

```swift
// MARK: - PKPaymentAuthorizationViewControllerDelegate

func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
    // Use your payment processor's SDK to finish charging your customer.
    // When this is done, call completion(PKPaymentAuthorizationStatus.Success)
}

func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
    dismissViewControllerAnimated(true, completion: nil)
}
```

这里的 `processPayment:payment completion:` 方法是在你自己代码中编写的，这个方法会让扣款服务商的 SDK 结束本次支付。

## 动态显示物流信息和价格

如果用户通过 Apple Pay 购买了实体商品，你可能需要需要提供给他们多种物流选项。这个可以在 `PKPaymentRequest` 的 `shippingMethods` 属性中设置。然后可以通过实现 `PKPaymentAuthorizationViewControllerDelegate` 中的 `paymentAuthorizationViewController:didSelectShippingMethod:completion:` 方法来对用户做出的选择进行反馈。这个方法遵循和 `didAuthorizePayment` 类似的方式，在这个方法里可以同步地做一些事情然后调用回调去更新包含用户付款信息的 `PKPaymentSummaryItem` 数组。(还记得吗我们之前提过由 `PKPaymentSummaryItem` 继承来的 `PKShippingMethod`，这东西能帮上大忙！)

此处对上面的代码做了一点小改动，实现了一个通过计算得出的物流属性：

```swift
var paymentRequest: PKPaymentRequest {
    let request = ... // initialize as before

    let freeShipping = PKShippingMethod(label: "Free Shipping", amount: NSDecimalNumber(string: "0"))
    freeShipping.identifier = "freeshipping"
    freeShipping.detail = "Arrives in 6-8 weeks"

    let expressShipping = PKShippingMethod(label: "Express Shipping", amount: NSDecimalNumber(string: "10.00"))
    expressShipping.identifier = "expressshipping"
    expressShipping.detail = "Arrives in 2-3 days"

    request.shippingMethods = [freeShipping, expressShipping]
    request.paymentSummaryItems = paymentSummaryItemsForShippingMethod(freeShipping)

    return request
}

func paymentSummaryItemsForShippingMethod(shipping: PKShippingMethod) -> ([PKPaymentSummaryItem]) {
    let wax = PKPaymentSummaryItem(label: "Mustache Wax", amount: NSDecimalNumber(string: "10.00"))
    let discount = PKPaymentSummaryItem(label: "Discount", amount: NSDecimalNumber(string: "-1.00"))

    let totalAmount = wax.amount.decimalNumberByAdding(discount.amount)
                                .decimalNumberByAdding(shipping.amount)
    let total = PKPaymentSummaryItem(label: "NSHipster", amount: totalAmount)

    return [wax, discount, shipping, total]
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didSelectShippingMethod shippingMethod: PKShippingMethod!, completion: ((PKPaymentAuthorizationStatus, [AnyObject]!) -> Void)!) {
    completion(PKPaymentAuthorizationStatus.Success, paymentSummaryItemsForShippingMethod(shippingMethod))
}
```

在这个样例中，用户可以选择包邮和 express 发货两种选项，两种方法的费用会根据用户的选择自动调整。

_别急，还有更多的东西呢_

相对于提供一堆统一费率的物流选项，其实你可以让消费者选择运送地址然后动态计算物流费用。这需要设置 `PKPaymentRequest` 的 `requiredShippingAddressFields` 属性。这个属性含有 `PKAddressField.Email`、`PhoneNumber`、`PostalAddress` 信息。

> 如果你不需要用户的具体运送地址但是需要一些联系方式(比如说需要寄送电子发票的邮箱)，也可以通过这个方式来实现。

当设置了这个属性时，新的 "Shipping Address" 就会显示在付款的 UI 界面上，用户可以依次选择他们保存过的寄送地址。每当用户选择一个地址时，`PKPaymentAuthorizationViewControllerDelegate` 中的 `paymentAuthorizationViewController:didSelectShippingAddress:completion:`(顾名思义)方法就会调用。

此时你应当通过用户选择的地址信息计算出物流费用，之后调用 `completion` 回调并携带 3 个参数：

1. 调用结果
    - `PKPaymentAuthorizationStatus.Success` 代表成功
    - `.Failure` 代表网络连接出错
    - `.InvalidShippingPostalAddress` 代表 API 返回了一个空数组(例如填入了一个不可送达的地址)
2. 用 `PKShippingMethod` 类型的数组表示用户的可用物流选项
3. 含有物流信息的新 `PKPaymentSummaryItem` 数组

我写了一个使用 EasyPost API 通过地址能够查询邮费的简单 web 后台。源码见 https://github.com/jflinter/example-shipping-api 。

这里有一个使用 [Alamofire](http://nshipster.com/alamofire/) 查询的样例：

```swift
import AddressBook
import PassKit
import Alamofire

func addressesForRecord(record: ABRecord) -> [[String: String]] {
    var addresses: [[String: String]] = []
    let values: ABMultiValue = ABRecordCopyValue(record, kABPersonAddressProperty).takeRetainedValue()
    for index in 0..<ABMultiValueGetCount(values) {
        if let address = ABMultiValueCopyValueAtIndex(values, index).takeRetainedValue() as? [String: String] {
            addresses.append(address)
        }
    }

    return addresses
}

func fetchShippingMethodsForAddress(address: [String: String], completion: ([PKShippingMethod]?) -> Void) {
    let parameters = [
        "street": address[kABPersonAddressStreetKey] ?? "",
        "city": address[kABPersonAddressCityKey] ?? "",
        "state": address[kABPersonAddressStateKey] ?? "",
        "zip": address[kABPersonAddressZIPKey] ?? "",
        "country": address[kABPersonAddressCountryKey] ?? ""
    ]

    Alamofire.request(.GET, "http://example.com", parameters: parameters)
             .responseJSON { (_, _, JSON, _) in
                if let rates = JSON as? [[String: String]] {
                    let shippingMethods = map(rates) { (rate) -> PKShippingMethod in
                        let identifier = rate["id"]
                        let carrier = rate["carrier"] ?? "Unknown Carrier"
                        let service = rate["service"] ?? "Unknown Service"
                        let amount = NSDecimalNumber(string: rate["amount"])
                        let arrival = rate["formatted_arrival_date"] ?? "Unknown Arrival"

                        let shippingMethod = PKShippingMethod(label: "\(carrier) \(service)", amount: amount)
                        shippingMethod.identifier = identifier
                        shippingMethod.detail = arrival

                        return shippingMethod
                    }
                }
             }
}
```

通过这种方法，可用简单地实现 `PKPaymentAuthorizationViewControllerDelegate`：

```swift
func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didSelectShippingAddress record: ABRecord!, completion: ((PKPaymentAuthorizationStatus, [AnyObject]!, [AnyObject]!) -> Void)!) {
    if let address = addressesForRecord(record).first {
        fetchShippingMethodsForAddress(address) { (shippingMethods) in
            switch shippingMethods?.count {
            case .None:
                completion(PKPaymentAuthorizationStatus.Failure, nil, nil)
            case .Some(0):
                completion(PKPaymentAuthorizationStatus.InvalidShippingPostalAddress, nil, nil)
            default:
                completion(PKPaymentAuthorizationStatus.Success, shippingMethods, self.paymentSummaryItemsForShippingMethod(shippingMethods!.first!))
            }
        }
    } else {
        completion(PKPaymentAuthorizationStatus.Failure, nil, nil)
    }
}
```

![Select a Shipping Method](http://nshipster.s3.amazonaws.com/apple-pay-select-shipping-method.png)

至此，用户可以选择寄送地址以及基于其居住地得到的可用物流方式。用户最终选择的 `shippingAddress` 和 `shippingMethod` 会成为回调到 delegate 方法 `paymentAuthorizationViewController:didAuthorizePayment:completion:` 中 `PKPayment` 对象的某些属性。

> 文中提到的所有源码可以在这个项目中找到：https://github.com/jflinter/ApplePayExample 

* * *

虽然 Apple Pay 只开放了很少的 API，但[很多](https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewFeature?id=927678292&mt=8&ls=1) 应用还是借此实现了多种多样的功能，你可以通过定制化应用到自己的应用中。其实它开启了一个购买的新篇章，比如说，用户根本不用先注册就可以买东西。

随着越来越多的应用开始使用 Apple Pay(也随着越来越多的用户拥有支持 Apple Pay 的设备)，很快这就会成为 iOS 应用中普遍存在的支付方式。我很乐意看一看你们都如何用 Apple Pay 来丰富的你的产品 - 如果你有任何问题，或者想向我展示你的成果，请[联系我](mailto:jack+nshipster@stripe.com)！