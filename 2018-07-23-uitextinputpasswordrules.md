---
title: "Password Rules / UITextInputPasswordRules"
author: Mattt
category: "Cocoa"
excerpt: Unless it's the title of a hacker movie from the 90's
  or the solution to an escape room puzzle,
  a password should be utterly devoid of meaning.
hiddenlang: ""
status:
  swift: "4.2"
---

It's no wonder why hipsters obsess over artisanal _this_ and handcrafted _that_.
Whether it's a thick slice of avocado toast,
a bottle of small batch (nondairy) golden milk,
or a perfect cup of pour-over coffee ---
there's no replacement for a human touch.

In stark contrast,
good passwords are the opposite of artisanal.
Unless it's the title of a hacker movie from the 90's
or the solution to an escape room puzzle,
a password should be utterly devoid of meaning.

With Safari in iOS 12 and macOS Mojave,
it'll be easier than ever to generate
the strongest,
most meaningless,
most impossible-to-guess passwords imaginable ---
all thanks to a few new features.

---

An ideal password policy is simple:
Enforce a minimum number of characters (at least 8)
and allow for longer passwords (64 or more).

Anything more elaborate, be it
pre-selected security questions,
periodic password expiration,
or arcane character requirements
do little more than annoy the people these policies try to protect.

{% warning do %}

But don't take my word for it ---
I'm not a security expert.

Instead,
check out the latest
[Digital Identity Guidelines](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-63b.pdf)
from
<abbr title="National Institute of Standards and Technology">NIST</abbr>
(published June 2017).

{% endwarning %}

The good news is that more companies and organizations
are starting to pay attention to security best practices.
The bad news is that it took
a series of massive data breaches affecting millions of people
in order for things to change.
And the ugly truth is that
because corporations and governments take forever to do anything,
many of the aforementioned security anti-patterns aren't going away anytime soon.

## Automatic Strong Passwords

Safari AutoFill has been able to generate passwords since iOS 8,
but one of its shortcomings was that it couldn't guarantee
that a generated password satisfied the requirements of a particular service.

Apple aims to solve this problem with a new Automatic Strong Passwords feature
in Safari, iOS 12, and macOS Mojave.

WebKit engineer Daniel Bates submitted
[this proposal](https://github.com/whatwg/html/issues/3518)
for consideration to the
<abbr title="Web Hypertext Application Technology Working Group">WHATWG</abbr>
on March 1st.
On June 6th,
the WebKit team
[announced Safari Technology Preview Release 58](https://webkit.org/blog/8327/safari-technology-preview-58-with-safari-12-features-is-now-available/),
with support for strong password generation
using the new `passwordrules` attribute.
This announcement coincided with the release iOS 12 beta SDKs at WWDC,
which included a new `UITextInputPasswordRules` API,
along with a number of other password management features,
including Security Code AutoFill and federated authentication.

## Password Rules

Password rules are like a recipe for password generators.
By following a few simple rules,
the password generator can randomly generate new, secure passwords
that comply with the particular requirements of the service provider.

Password rules consist of one or more key-value pairs
in the following form:

`required: lower; required: upper; required: digit; allowed: ascii-printable; max-consecutive: 3;`

### Keys

Each rule may specify one of the following keys:

- `required`: The kinds of characters that are required
- `allowed`: The kinds of characters that are allowed
- `max-consecutive`: The maximum number of consecutive characters allowed
- `minlength`: The minimum password length
- `maxlength`: The maximum password length

The `required` and `allowed` keys
have one of the character classes listed below as their value.
The `max-consecutive`, `minlength`, and `maxlength` keys
have a nonnegative integer as their value.

### Character Classes

The `required` and `allowed` keys
may have any one of the following named character classes
as their value.

- `upper` (`A-Z`)
- `lower` (`a-z`)
- `digits` (`0-9`)
- `special` (`` -~!@#$%^&\*\_+=`|(){}[:;"'<>,.? ] `` and space)
- `ascii-printable` (U+0020 — 007f)
- `unicode` (U+0 — 10FFFF)

In addition to these presets,
you may specify a custom character class
with ASCII characters surrounded by square brackets
(for example, `[abc]`).

---

Apple's
[Password Rules Validation Tool](https://developer.apple.com/password-rules/)
allows you to experiment with different rules
and get real-time feedback of their results.
You can even generate and download passwords by the thousands
to use during development and testing!

{% asset password-rules-validation-tool.png alt="Password Rules Validation Tool" %}

For more information about Password Rules syntax,
check out Apple's
["Customizing Password AutoFill Rules"](https://developer.apple.com/documentation/security/password_autofill/customizing_password_autofill_rules).

---

## Specifying Password Rules

On iOS,
you set the `passwordRules` property of a `UITextField`
with a `UITextInputPasswordRules` object
(you should also set the `textContentType` to `.newPassword` while you're at it):

```swift
let newPasswordTextField = UITextField()
newPasswordTextField.textContentType = .newPassword
newPasswordTextField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; required: digit; max-consecutive: 2; minlength: 8;")
```

On the web,
you set the `passwordrules` attribute
to an `<input>` element with `type="password"`:

```html
<input type="password" passwordrules="required: upper; required: lower; required: special; max-consecutive: 3;"/>
```

{% info do %}

If unspecified,
the default password rule is
`allowed: ascii-printable`.
Though if your form has a password confirmation field,
it will automatically follow the rules from the preceding field.

{% endinfo %}

## Generating Password Rules in Swift

If the thought of working with a string-based format
without a proper abstraction gives you the heebie-jeebies,
you're not alone.

Here's one way to encapsulate Password Rules in a Swift API
([also available as a Swift package](https://github.com/NSHipster/PasswordRules)):

```swift
enum PasswordRule {
    enum CharacterClass {
        case upper, lower, digits, special, asciiPrintable, unicode
        case custom(Set<Character>)
    }

    case required(CharacterClass)
    case allowed(CharacterClass)
    case maxConsecutive(UInt)
    case minLength(UInt)
    case maxLength(UInt)
}

extension PasswordRule: CustomStringConvertible {
    var description: String {
        switch self {
        case .required(let characterClass):
            return "required: \(characterClass)"
        case .allowed(let characterClass):
            return "allowed: \(characterClass)"
        case .maxConsecutive(let length):
            return "max-consecutive: \(length)"
        case .minLength(let length):
            return "minlength: \(length)"
        case .maxLength(let length):
            return "maxlength: \(length)"
        }
    }
}

extension PasswordRule.CharacterClass: CustomStringConvertible {
    var description: String {
        switch self {
        case .upper: return "upper"
        case .lower: return "lower"
        case .digits: return "digits"
        case .special: return "special"
        case .asciiPrintable: return "ascii-printable"
        case .unicode: return "unicode"
        case .custom(let characters):
            return "[" + String(characters) + "]"
        }
    }
}
```

With this in place,
we can now specify a series of rules in code
and use them to generate a string with valid password rules syntax:

```swift
let rules: [PasswordRule] = [ .required(.upper),
                              .required(.lower),
                              .required(.special),
                              .minLength(20) ]

let descriptor = rules.map{ "\($0.description);" }
                      .joined(separator: " ")

// "required: upper; required: lower; required: special; max-consecutive: 3;"
```

If you feel so inclined,
you could even extend `UITextInputPasswordRules`
to provide a convenience initializer
that takes an array of `PasswordRule` values:

```swift
extension UITextInputPasswordRules {
    convenience init(rules: [PasswordRule]) {
        let descriptor = rules.map{ $0.description }
                              .joined(separator: "; ")

        self.init(descriptor: descriptor)
    }
}
```

---

If you're the sentimental type when it comes to personal credentials,
and enjoy name dropping your college or dog or favorite sports team
behind the anonymous bullets of password input fields,
please consider reforming your ways.

Speaking personally,
I can't imagine going about my day-to-day without my password manager.
It's hard to overstate the peace of mind you get
by knowing that any information you ever needed
is accessible to you --- and only you --- whenever you need it.

By taking this step now,
you'll be able to take full advantage of these improvements
coming to Safari when iOS 12 and macOS Mojave arrive later this year.
