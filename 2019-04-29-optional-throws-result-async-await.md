---
title: Optional, throws, Result, and async/await
author: jemmons
category: Swift
excerpt: "An exploration of error handling in Swift: then, now, and soon."
status:
  swift: 5.0
---

Back in the early days of Swift 1, we didn't have much in the way of error handling.
But we _did_ have `Optional`,
and it felt awesome!
By making null checks explicit and enforced,
bombing out of a function by returning `nil` suddenly felt less like a code smell
and more like a language feature.

Here's how we might write a little utility to grab Keychain data returning `nil` for any errors:

```swift
func keychainData(service: String) -> Data? {
  let query: NSDictionary = [
    kSecClass: kSecClassGenericPassword,
    kSecAttrService: service,
    kSecReturnData: true
  ]
  var ref: CFTypeRef? = nil

  switch SecItemCopyMatching(query, &ref) {
  case errSecSuccess:
    return ref as? Data
  default:
    return nil
  }
}
```

We set up a query,
pass an an empty `inout` reference to `SecItemCopyMatching` and then,
depending on the status code we get back,
either return the reference as data
or `nil` if there was an error.

At the call site,
we can tell if something has exploded by unwrapping the optional:

```swift
if let myData = keychainData(service: "My Service") {
  <#do something with myData...#>
} else {
  fatalError("Something went wrong with... something?")
}
```

## Getting Results

There's a certain binary elegance to the above,
but it conceals an achilles heel.
[At its heart](https://github.com/apple/swift/blob/swift-5.0-RELEASE/stdlib/public/core/Optional.swift#L122),
`Optional` is just an enum that holds either some wrapped value or nothing:

```swift
enum Optional<Wrapped> {
  case some(Wrapped)
  case none
}
```

This works just fine for our utility when everything goes right — we just return our value.
But most operations that involve I/O can go wrong
(`SecItemCopyMatching`, in particular, can go wrong [many, many ways](https://developer.apple.com/documentation/security/1542001-security_framework_result_codes)),
and `Optional` ties our hands when it comes to signaling something's gone sideways.
Our only option is to return nothing.

Meanwhile, at the call site, we're wondering what the issue is and all we've got to work with is this empty `.none`.
It's difficult to write robust software when every non-optimal condition is essentially reduced to `¯\_(ツ)_/¯`.
How could we improve this situation?

One way would be to add some language-level features that let functions throw errors in addition to returning values.
And this is, in fact, exactly what Swift did in version 2 with its `throws/throw` and `do/catch` syntax.

But let's stick with our `Optional` line of reasoning for just a moment. If the issue is that `Optional` can only hold a value or `nil`, and in the event of an error `nil` isn't expressive enough, maybe we can address the issue simply by making a new `Optional` that holds either a value _or an error?_

Well, congratulations are in order:
change a few names, and we see we just invented the new `Result` type,
[now available in the Swift 5 standard library](https://github.com/apple/swift/blob/swift-5.0-RELEASE/stdlib/public/core/Result.swift#L16)!

```swift
enum Result<Success, Failure: Error> {
  case success(Success)
  case failure(Failure)
}
```

`Result` holds either a successful value _or_ an error.
And we can use it to improve our little keychain utility.

First,
let's define a custom `Error` type with some more descriptive cases than a simple `nil`:

```swift
enum KeychainError: Error {
  case notData
  case notFound(name: String)
  case ioWentBad
  <#...#>
}
```

Next we change our `keychainData` definition to return `Result<Data, Error>` instead of `Data?`.
When everything goes right we return our data as the [associated value](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html#ID148) of a `.success`.
What happens if any of `SecItemCopyMatching`'s many and varied disasters strike?
Rather than returning `nil` we return one of our specific errors wrapped in a `.failure`:

```swift
func keychainData(service: String) -> Result<Data, Error> {
  let query: NSDictionary = [...]
  var ref: CFTypeRef? = nil

  switch SecItemCopyMatching(query, &ref) {
  case errSecSuccess:
    guard let data = ref as? Data else {
      return .failure(KeychainError.notData)
    }
    return .success(data)
  case errSecItemNotFound:
    return .failure(KeychainError.notFound(name: service))
  case errSecIO:
    return .failure(KeychainError.ioWentBad)
  <#...#>
  }
}

```

Now we have a lot more information to work with at the call site! We can, if we choose, `switch` over the result, handling both success _and_ each error case individually:

```swift
switch keychainData(service: "My Service") {
case .success(let data):
  <#do something with data...#>
case .failure(KeychainError.notFound(let name)):
  print(""\(name)" not found in keychain.")
case .failure(KeychainError.io):
  print("Error reading from the keychain.")
case .failure(KeychainError.notData):
  print("Keychain is broken.")
<#...#>
}
```

All things considered, `Result` seems like a pretty useful upgrade to `Optional`. How on earth did it take it five years to be added to the standard library?

## Three's a Crowd

Alas, `Result` is _also_ cursed with an achilles heel — we just haven't noticed it yet because, up until now, we've only been working with a single call to a single function. But imagine we add two more error-prone operations to our list of `Result`-returning utilities:

```swift
func makeAvatar(from user: Data) -> Result<UIImage, Error> {
  <#Return avatar made from user's initials...#>
  <#or return failure...#>
}

func save(image: UIImage) -> Result<Void, Error> {
  <#Save image and return success...#>
  <#or returns failure...#>
}
```

{% info %}
Note the return type of `save(image:)` — its success type is defined as `Void`.
We don't always have to return a value with our successes.
Sometimes just knowing it succeeded is enough.
{% endinfo %}

In our example,
the first function generates an avatar from user data,
and the second writes an image to disk.
The implementations don't matter so much for our purposes,
just that they return a `Result` type.

Now, how would we write something that fetches user data from the keychain, uses it to create an avatar, saves that avatar to disk, _and_ handles any errors that might occur along the way?

We might try something like:

```swift
switch keychainData(service: "UserData") {
case .success(let userData):

  switch makeAvatar(from: userData) {
  case .success(let avatar):

    switch save(image: avatar) {
    case .success:
      break // continue on with our program...

    case .failure(FileSystemError.readOnly):
      print("Can't write to disk.")

    <#...#>
    }

  case .failure(AvatarError.invalidUserFormat):
    print("Unable to generate avatar from given user.")

  <#...#>
  }

case .failure(KeychainError.notFound(let name)):
  print(""\(name)" not found in keychain.")

<#...#>
}
```

But whooo boy. Adding just two functions has led to an explosion of nesting, dislocated error handling, and woe.

## Falling Flat

Thankfully, we can clean this up by taking advantage of the fact that,
like `Optional`,
[`Result` implements `flatMap`](https://github.com/apple/swift/blob/swift-5.0-RELEASE/stdlib/public/core/Result.swift#L96).
Specifically, `flatMap` on a `Result` will,
in the case of `.success`,
apply the given transform to the associated value and return the newly produced `Result`.
In the case of a `.failure`, however,
`flatMap` simply passes the `.failure` and its associated error along without modification.

{% info %}
Things that implement `flatMap` like this are [sometimes called "monads"](http://chris.eidhof.nl/post/monads-in-swift/).
This can be a useful sobriquet to know as monads all share some common properties.
But if the term is unfamiliar or scary, don't sweat it.
`flatMap` is the only thing we need to understand, here.
{% endinfo %}
{% warning %}
There's a common misconception that `flatMap` has been replaced by `compactMap` as of Swift 4.1.
Not so!
[Only the specific case of calling `flatMap` on a `Sequence` with `Optional` elements is deprecated.](https://github.com/apple/swift-evolution/blob/master/proposals/0187-introduce-filtermap.md#motivation)
{% endwarning %}

Because it passes errors through in this manner, we can use `flatMap` to combine our operations together without checking for `.failure` each step of the way. This lets us minimize nesting and keep our error handling and operations distinct:

```swift
let result = keychainData(service: "UserData")
             .flatMap(makeAvatar)
             .flatMap(save)

switch result {
case .success:
  break // continue on with our program...

case .failure(KeychainError.notFound(let name)):
  print(""\(name)" not found in keychain.")
case .failure(AvatarError.invalidUserFormat):
  print("Unable to generate avatar from given user.")
case .failure(FileSystemError.readOnly):
  print("Can't write to disk.")
<#...#>
}
```

This is, without a doubt, an improvement. But it requires us (and anyone reading our code) to be familiar enough with `.flatMap` to follow its somewhat unintuitive semantics.

{% warning %} And this is a best case scenario of perfect composability (the resulting value of the first operation being the required parameter of the next, and so on). What if an operation takes no parameters? Or requires more than one? Or takes a parameter of a different type than we're returning? `flatMap`ing across those sorts of beasts is… less elegant. {% endwarning %}

Compare this to the `do/catch` syntax from all the way back in Swift 2 that we alluded to a little earlier:

```swift
do {
  let userData = try keychainData(service: "UserData")
  let avatar = try makeAvatar(from: userData)
  try save(image: avatar)

} catch KeychainError.notFound(let name) {
  print(""\(name)" not found in keychain.")

} catch AvatarError.invalidUserFormat {
  print("Not enough memory to create avatar.")

} catch FileSystemError.readOnly {
  print("Could not save avatar to read-only media.")
} <#...#>
```

The first thing that might stand out is how similar these two pieces of code are. They both have a section up top for executing our operations. And both have a section down below for matching errors and handling them.

{% info %} This similarity is not accidental. Much of Swift's error handling [is sugar around returning and unwrapping `Result`-like types](https://twitter.com/jckarter/status/608137115545669632). As we'll see more of in a bit… {% endinfo %}

Whereas the `Result` version has us piping operations through chained calls to `flatMap`,
we write the `do/catch` code more or less exactly as we would if no error handling were involved.
While the `Result` version requires we understand the internals of its enumeration
and explicitly `switch` over it to match errors,
the `do/catch` version lets us focus on the part we actually care about:
the errors themselves.

By having language-level syntax for error handling, Swift effectively masks all the `Result`-related complexities it took us the first half of this post to digest: enumerations, associated values, generics, flatMap, monads… In some ways, Swift added error-handling syntax back in version 2 specifically so we wouldn't have to deal with `Result` and its eccentricities.

Yet here we are, five years later, learning all about it. Why add it now?

## Error's Ups and Downs

Well, as it should happen, `do/catch` has this little thing we might call an achilles heel…

See, `throw`, like `return`, only works in one direction; up. We can `throw` an error "up" to the _caller_, but we can't `throw` an error "down" as a parameter to another function _we_ call.

This "up"-only behavior is typically what we want.
Our keychain utility,
rewritten once again with error handling,
is all `return`s and `throw`s because its only job is passing either our data or an error
back up to the thing that called it:

```swift
func keychainData(service: String) throws -> Data {
  let query: NSDictionary = [...]
  var ref: CFTypeRef? = nil

  switch SecItemCopyMatching(query, &ref) {
  case errSecSuccess:
    guard let data = ref as? Data else {
      throw KeychainError.notData
    }
    return data
  case errSecItemNotFound:
    throw KeychainError.notFound(name: service)
  case errSecIO:
    throw KeychainError.ioWentBad
  <#...#>
  }
}
```

But what if,
instead of fetching user data from the keychain,
we want to get it from a cloud service?
Even on a fast, reliable connection,
loading data over a network can take a long time compared to reading it from disk.
We don't want to block the rest of our application while we wait, of course,
so we'll make it asynchronous.

But that means we're no longer returning _anything_ "up".
Instead we're calling "down" into a closure on completion:

```swift
func userData(for userID: String, completion: (Data) -> Void) {
  <#get data from the network#>
  // Then, sometime later:
  completion(myData)
}
```

Now network operations can fail with [all sorts of different errors](https://developer.apple.com/documentation/foundation/urlerror),
but we can't `throw` them "down" into `completion`.
So the next best option is to pass any errors along as a second (optional) parameter:

```swift
func userData(for userID: String, completion: (Data?, Error?) -> Void) {
  <# Fetch data over the network... #>
  guard myError == nil else {
    completion(nil, myError)
  }
  completion(myData, nil)
}
```

But now the caller, in an effort to make sense of this cartesian maze of possible parameters, has to account for many impossible scenarios in addition to the ones we actually care about:

```swift
userData(for: "jemmons") { maybeData, maybeError in
  switch (maybeData, maybeError) {
  case let (data?, nil):
    <#do something with data...#>
  case (nil, URLError.timedOut?):
    print("Connection timed out.")
  case (nil, nil):
    fatalError("🤔Hmm. This should never happen.")
  case (_?, _?):
    fatalError("😱What would this even mean?")
  <#...#>
  }
}
```

It'd be really helpful if, instead of this mishmash of "data or nil _and_ error or nil" we had some succinct way to express simply "data _or_ error".

## Stop Me If You've Heard This One…

Wait, data or error?
That sounds familiar.
What if we used a `Result`?

```swift
func userData(for userID: String, completion: (Result<Data, Error>) -> Void) {
  // Everything went well:
  completion(.success(myData))

  // Something went wrong:
  completion(.failure(myError))
}
```

And at the call site:

```swift
userData(for: "jemmons") { result in
  switch (result) {
  case (.success(let data)):
    <#do something with data...#>
  case (.failure(URLError.timedOut)):
    print("Connection timed out.")
  <#...#>
}
```

Ah ha!
So we see that the `Result` type can serve as a concrete [reification](https://en.wikipedia.org/wiki/Reification_%28computer_science%29) of Swift's abstract idea of
_"that thing that's returned when a function is marked as `throws`."_
And as such, we can use it to deal with asynchronous operations that require concrete types for parameters passed to their completion handlers.

{% info %}
This duality between
the abstract "error handling thing"
and concrete "`Result` thing"
is more than just skin deep — they're two sides of the same coin,
as illustrated by how trivial it is to convert between them:

```swift
Result { try somethingThatThrows() }
```

…turns an abstract catchable thing into a concrete result type that can be passed around.

```swift
try someResult.get()
```

…turns a concrete result into an abstract thing capable of being caught.
{% endinfo %}

So, while the shape of `Result` has been implied by error handling since Swift 2
(and, indeed, quite a few developers have created [their own versions of it](https://github.com/search?o=desc&q=result+language%3Aswift&s=&type=Repositories) in the intervening years),
it's now officially added to the standard library in Swift 5 — primarily as a way to deal with asynchronous errors.

Which is undoubtedly better than passing the double-optional `(Value?, Error?)` mess we saw earlier.
But didn't we just get finished making the case that `Result` tended to be overly verbose, nesty, and complex
when dealing with more than one error-capable call?
Yes we did.

And, in fact, this is even more of an issue in the async space
since `flatMap` expects its transform to return _synchronously_.
So we can't use it to compose _asynchronous_ operations:

```swift
userData(for: "jemmons") { userResult in
  switch userResult {
  case .success(let user):
    fetchAvatar(for: user) { avatarResult in

      switch avatarResult {
      case .success(let avatar):
        cloudSave(image: avatar) { saveResult in

          switch saveResult {
          case .success:
            // All done!

          case .failure(URLError.timedOut)
            print("Operation timed out.")
          <#...#>
        }
      }

      case .failure(AvatarError.invalidUserFormat):
        print("User not recognized.")
      <#...#>
    }
  }

  case .failure(URLError.notConnectedToInternet):
    print("No internet detected.")
  <#...#>
}
```

{% info %} There is, actually, a `flatMap`-like way of handling this called the [Continuation Monad](https://en.wikipedia.org/wiki/Monad_%28functional_programming%29#Continuation_monad). It's complicated enough, though, that it probably warrants a few blog posts all unto itself. {% endinfo %}

## Awaiting the Future

In the near term, we just have to lump it.
It's better than the other alternatives native to the language,
and chaining asynchronous calls isn't as common as for synchronous calls.

But in the future, just as Swift used `do/catch` syntax to define away `Result` nesting problems in synchronous error handling, there are many proposals being considered to do the same for asynchronous errors (and asynchronous processing, generally).

[The async/await proposal](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619) is one such animal. If adopted it would reduce the above to:

```swift
do {
  let user = try await userData(for: "jemmons")
  let avatar = try await fetchAvatar(for: user)
  try await cloudSave(image: avatar)

} catch AvatarError.invalidUserFormat {
  print("User not recognized.")

} catch URLError.timedOut {
  print("Operation timed out.")

} catch URLError.notConnectedToInternet {
    print("No internet detected.")
} <#...#>
```

Which, holy moley! As much as I love `Result`, I, for one, cannot wait for it to be made completely irrelevant by our glorious async/await overlords.

Meanwhile? Let us rejoice!
For we finally have a concrete `Result` type in the standard library to light the way through these, the middle ages of async error handling in Swift.
