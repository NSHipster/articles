---
title: Pay
author: Jack Flintermann
category: ""
translator: "Croath Liu"
excerpt: "你要在网上买东西的那一刻你会发现有一种现代化带来的独有的焦虑感。那种感觉不能用语言形容，大概是这样的：\"我的信用卡去哪了？卡号是多少？我好想买这个啊卡去哪了！\""
---

你要在网上买东西的那一刻你会发现有一种现代化带来的独有的焦虑感。那种感觉不能用语言形容，大概是这样的："我的信用卡去哪了？卡号是多少？我好想买这个啊卡去哪了！"

当你用 iOS 设备的时候，这种困难又加剧了一层：身为运动员或宇航员的你很适合采用一手拿着信用卡一手拿着手机输入的优美姿势。（开个玩笑，但我打赌苹果应该在某个实验室里面这样实验过了。）

如果你刚好在开发一款能够接受信用卡付款的应用，这种状况将直接影响你的收入。

[Apple Pay](http://apple.com/apple-pay) 改变了这一切。大多数人可能还在关注它发布时提到的在实体店的功用（消费者可以用 iPhone NFC 功能付款），与此同时这也为开发者提升在应用内付款体验的巨大机会。

> 提示：如果你在应用内卖电子化商品或虚拟货币，那么应该用应用内支付而不是 Apple Pay。(请看 App Store Review Guidelines 的这一章 [section 11.2](https://developer.apple.com/app-store/review/guidelines/#purchasing-currencies))。Apple Pay 可以用来销售实体商品和服务。

* * *

## 获取一个 Apple Merchant ID

测试支付之前需要注册一个 Apple Merchant ID。还要先选择一个能够控制信用卡支付流程的服务提供商。苹果提供了一个这类提供商的推荐列表：[Apple Pay Developer Page](http://developer.apple.com/apple-pay) (作者自曝就职于这个推荐列表中的 [Stripe](https://stripe.com/) 公司，但本文涉及到的代码和选择什么服务提供商是无关的)。你的服务提供商会给你一份特别说明指导如何在他们的平台上使用 Apple Pay 来支付，整个流程类似于这样：

- 前往 Apple Developer Center `Certificates, Identifiers, and Profiles` 部分 [创建一个 merchant ID](https://developer.apple.com/account/ios/identifiers/merchant/merchantCreate.action)。
- 接下来，[前往 Certificates 部分](https://developer.apple.com/account/ios/certificate/certificateCreate.action) 新建一个 Apple Pay Certificate。这步需要上传一个 Certificate Signing Request。注册服务提供商的时候他们会给你一个可用的 CSR 文件，你也可以用自己生成的 CSR 文件走完整个流程，但你的服务提供商不能用你生成的 CSR 来完成支付的解谜流程。
- 在 Xcode 里，在工程设置的 "Capabilities" 部分打开 "Apple Pay"。这步可能会要求你选择之前创建的 merchant ID。

## 拿到第一桶金

> Apple Pay will only work on an iOS device capable of using Apple Pay (e.g. iPhone 6/6+, iPad Mini 3, iPad Air 2). In addition, you have to have successfully added the Apple Pay entitlement (described in "Obtaining an Apple Merchant ID") in order to test it in your app. If you'd like to approximate its behavior on the simulator, you can find a testing library that mimics its functionality (with test credit card details) at https://github.com/stripe/ApplePayStubs.

Once you're up and running with a merchant account, getting started with Apple Pay is really straightforward. When it's time to check out, you'll first need to see if Apple Pay is supported on the device you're running and your customer has added any cards to Passbook:

```swift
let paymentNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(paymentNetworks) {
    // Pay is available!
} else {
    // Show your own credit card form.
}
```

Assuming Apple Pay is available, the next step is to assemble a `PKPaymentRequest`. This object describes the charge you're requesting from your customer. If you're requesting payment in the U.S. (reasonable, as Apple Pay is currently US-only), here's some default options you'll need to set that'll likely stay constant:

```swift
let request = PKPaymentRequest()
request.supportedNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]
request.countryCode = "US"
request.currencyCode = "USD"
request.merchantIdentifier = "<#Replace me with your Apple Merchant ID#>"
request.merchantCapabilities = .Capability3DS
```

Next, describe the things the customer is actually buying with the `paymentSummaryItems` property. This takes an array of `PKPaymentSummaryItem`s, which have a `label` and `amount`. They're analogous to line items on a receipt (which we'll see momentarily).

![Payment Authorization](http://nshipster.s3.amazonaws.com/apple-pay-payment-authorization.png)

```swift
let wax = PKPaymentSummaryItem(label: "Mustache Wax", amount: NSDecimalNumber(string: "10.00"))
let discount = PKPaymentSummaryItem(label: "Discount", amount: NSDecimalNumber(string: "-1.00"))

let totalAmount = wax.amount.decimalNumberByAdding(discount.amount)
                            .decimalNumberByAdding(shipping.amount)
let total = PKPaymentSummaryItem(label: "NSHipster", amount: totalAmount)

request.paymentSummaryItems = [wax, discount, shipping, total]
```

Note that you can specify zero or negative amounts here to apply coupons or communicate other information. However, the total amount requested must be greater than zero. You'll note we use a `PKShippingMethod` (inherits from `PKPaymentSummaryItem`) to describe our shipping item. More on this later.

Next, to display the actual payment sheet to the customer, we create an instance of `PKPaymentAuthorizationViewController` with our `PKPaymentRequest` and present it. (Assume for this example that all this code is inside a `UIViewController` that will sit behind the payment screen).

```swift
let viewController = PKPaymentAuthorizationViewController(paymentRequest: request)
viewController.delegate = self
presentViewController(viewController, animated: true, completion: nil)
```

A few style nits to be aware of:

- The view controller doesn't fully obscure the screen (in this case the blue background is part of our application). You can update the background view controller while the `PKPaymentAuthorizationViewController` is visible if you want.
- All text is automatically capitalized.
- The final line item is separated from the rest, and is intended to display the total amount you're charging. The label will be prepended with the word "PAY", so it usually makes sense to put your company name for the payment summary item's `label`.
- The entire UI is presented via a Remote View Controller. This means that outside the `PKPaymentRequest` you give it, it's impossible to otherwise style or modify the contents of this view.

## PKPaymentAuthorizationViewControllerDelegate

In order to actually handle the payment information returned by the `PKPaymentAuthorizationViewController`, you need to implement the `PKPaymentAuthorizationViewControllerDelegate` protocol. This has 2 required methods, `-(void)paymentAuthorizationViewController:didAuthorizePayment:completion:` and `-(void)paymentAuthorizationViewControllerDidFinish:`.

To understand how each of these components work, let's check out a timeline of how an Apple Pay purchase works:

- You present a `PKPaymentAuthorizationViewController` as described above.
- The customer approves the purchase using Touch ID (or, if that fails 3 times, by entering their passcode).
- The thumbprint icon turns into a spinner, with the label "Processing"
- Your delegate receives the `paymentAuthorizationViewController:didAuthorizePayment:completion:` callback.
- Your application communicates asynchronously with your payment processor and website backend to actually make a charge with those payment details. Once this complete, you invoke the `completion` handler that you're given as a parameter with either `PKPaymentAuthorizationStatus.Success` or `PKPaymentAuthorizationStatus.Failure` depending on the result.
- The `PKPaymentAuthorizationViewController` spinner animates into a success or failure icon. If successful, a notification will arrive from PassBook indicating a charge on the customer's credit card.
- Your delegate receives the `paymentAuthorizationViewControllerDidFinish:` callback. It is then responsible for calling `dismissViewControllerAnimated:completion` to dismiss the payment screen.

![Status Indicator](http://nshipster.s3.amazonaws.com/apple-pay-indicators.png)

Concretely, this comes out looking like this:

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

Here, the `processPayment:payment completion:` method is your own code, and would leverage your payment processor's SDK to finish the charge.

## Dynamic Shipping Methods and Pricing

If you're using Apple Pay to let your customer buy physical goods, you might want to offer them different shipping options. You can do this by setting the `shippingMethods` property on `PKPaymentRequest`. Then, you can respond to your customer's selection by implementing the optional `PKPaymentAuthorizationViewControllerDelegate` method, `paymentAuthorizationViewController:didSelectShippingMethod:completion:`. This method follows a similar pattern to the `didAuthorizePayment` method described above, where you're allowed to do asynchronous work and then call a callback with an updated array of `PKPaymentSummaryItem`s that includes the customer's desired shipping method. (Remember from earlier that `PKShippingMethod` inherits from `PKPaymentSummaryItem`? This is really helpful here!)

Here's a modified version of our earlier example, implemented as a computed property on the view controller and helper function:

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

In this example, the customer will get the option to choose either free or express shipping—and the price they're quoted will adjust accordingly as they change their selection.

_But wait, there's more!_

Instead of having to provide a bunch of flat-rate shipping options, you can let your customer choose their shipping address and then calculate shipping rates dynamically based on that. To do that, you'll first need to set the `requiredShippingAddressFields` property on your `PKPaymentRequest`. This can represent any combination of `PKAddressField.Email` , .`PhoneNumber`, and .`PostalAddress`.

> Alternatively, if you don't need the user's full mailing address but need to collect some contact information (like an email address to send receipts to), this is a good way to do it.

When this field is set, a new "Shipping Address" row appears in the payment UI that allows the customer to choose one of their saved addresses. Every time they choose one, the (aptly named) `paymentAuthorizationViewController:didSelectShippingAddress:completion:` message will be sent to your `PKPaymentAuthorizationViewControllerDelegate`.

Here, you should calculate the shipping rates for the selected address and then call the `completion` callback with 3 arguments:

1. The result of the call
    - `PKPaymentAuthorizationStatus.Success` if successful
    - ``PKPaymentAuthorizationStatus.`Failure` if a connection error occurs
    - `.InvalidShippingPostalAddress` if the API returns an empty array (i.e. shipping to that address is impossible).
2. An array of `PKShippingMethod`s representing the customer's available shipping options
3. A new array of `PKPaymentSummaryItem`s that contains one of the shipping methods

I've set up a really simple web backend that queries the EasyPost API for shipping rates to a given address. The source is available at https://github.com/jflinter/example-shipping-api.

Here's a function to query it, using [Alamofire](http://nshipster.com/alamofire/):

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

With this, it's simple to implement `PKPaymentAuthorizationViewControllerDelegate`:

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

Now, the customer can select an address and receive a different set of shipping options depending on where they live. Both the `shippingAddress` and `shippingMethod` they ultimately select will be available as properties on the `PKPayment` that is given to your delegate in the `paymentAuthorizationViewController:didAuthorizePayment:completion:` method.

> You can find all of the source code in this article at https://github.com/jflinter/ApplePayExample.

* * *

Even though Apple Pay only exposes a small number of public APIs,  its possible applications are [wide-ranging](https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewFeature?id=927678292&mt=8&ls=1) and you can customize your checkout flow to fit your app. It even enables you to build new types of flows, such as letting your customers buy stuff without having to create an account first.

As more apps start using Apple Pay (and as more customers own devices that support it), it'll become a ubiquitous way of paying for things in iOS apps. I'm excited to hear what you build with Apple Pay— if you have any questions, or want to show anything off, please [get in touch](mailto:jack+nshipster@stripe.com)!
