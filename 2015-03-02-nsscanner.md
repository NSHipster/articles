---
title: "NSScanner"
author: Nate Cook
category: "Cocoa"
excerpt: "Being able to pull apart strings and extract particular bits of data is a powerful skill, one that we use over and over building apps and shaping our tools. Cocoa provides a powerful set of frameworks to handle string processing. This week's article focuses on `NSScanner`, a highly configurable tool designed for extracting substrings and numeric values from loosely demarcated strings."
status:
    swift: 1.2
---

Strings are a ubiquitous and diverse part of our computing lives. They comprise emails and essays, poems and novels—and indeed, every article on [nshipster.com](http://nshipster.com), the configuration files that shape the site, and the code that builds it.

Being able to pull apart strings and extract particular bits of data is therefore a powerful skill, one that we use over and over building apps and shaping our tools.  Cocoa provides a powerful set of tools to handle string processing. In particular:

- **`string.componentsSeparatedByCharactersInSet`** / **`string.componentsSeparatedByString`**: Great for splitting a string into constituent pieces. Not so great at anything else.

- **`NSRegularExpression`**: Powerful for validating and extracting string data from an expected format. Cumbersome when dealing with complex serial input and finicky for parsing numeric values.

- **`NSDataDetector`**: Perfect for detecting and extracting dates, addresses, links, and more. Limited to its predefined types.

- **`NSScanner`**: Highly configurable and designed for scanning string and numeric values from loosely demarcated strings.

This week's article focuses on the last of these, `NSScanner`. Read on to learn about its flexibility and power.


* * *


Among Cocoa's tools, `NSScanner` serves as a wrapper around a string, scanning through its contents to efficiently retrieve substrings and numeric values. It offers several properties that modify an `NSScanner` instance's behavior:

> - `caseSensitive` *`Bool`*: Whether to pay attention to the upper- or lower-case while scanning. Note that this property *only* applies to the string-matching methods `scanString:intoString:` and `scanUpToString:intoString:`—character sets scanning is always case-sensitive.
> - `charactersToBeSkipped`  *`NSCharacterSet`*: The characters to skip over on the way to finding a match for the requested value type.
> - `scanLocation` *`Int`*: The current position of the scanner in its string. Scanning can be rewound or restarted by setting this property.
> - `locale` *`NSLocale`*: The locale that the scanner should use when parsing numeric values (see below).

An `NSScanner` instance has two additional read-only properties: `string`, which gives you back the string the scanner is scanning; and `atEnd`, which is true if `scanLocation` is at the end of the string.

> *Note:* `NSScanner` is actually the abstract superclass of a private cluster of scanner implementation classes. Even though you're calling `alloc` and `init` on `NSScanner`, you'll actually receive one of these subclasses, such as `NSConcreteScanner`. No need to fret over this.


## Extracting Substrings and Numeric Values

The *raison d'être* of `NSScanner` is to pull substrings and numeric values from a larger string. It has fifteen methods to do this, *all* of which follow the same basic pattern. Each method takes a reference to an output variable as a parameter and returns a boolean value indicating success or failure of the scan:

````swift
let whitespaceAndPunctuationSet = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
whitespaceAndPunctuationSet.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())

let stringScanner = NSScanner(string: "John & Paul & Ringo & George.")
stringScanner.charactersToBeSkipped = whitespaceAndPunctuationSet

// using the latest Swift 1.2 beta 2 syntax:
var name: NSString?
while stringScanner.scanUpToCharactersFromSet(whitespaceAndPunctuationSet, intoString: &name), 
        let name = name
{
    println(name)
}
// John
// Paul
// Ringo
// George
````

````objective-c
NSMutableCharacterSet *whitespaceAndPunctuationSet = [NSMutableCharacterSet punctuationCharacterSet];
[whitespaceAndPunctuationSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

NSScanner *stringScanner = [[NSScanner alloc] initWithString:@"John & Paul & Ringo & George."];
stringScanner.charactersToBeSkipped = whitespaceAndPunctuationSet;

NSString *name;
while ([stringScanner scanUpToCharactersFromSet:whitespaceAndPunctuationSet intoString:&name]) {
    NSLog(@"%@", name);
}
// John
// Paul
// Ringo
// George
````

The NSScanner API has methods for two use-cases: scanning for strings generally, or for numeric types specifically.

#### 1) String Scanners

<blockquote>
<dl>
<dt><code>scanString:intoString:</code> / <code>scanCharactersFromSet:intoString:</code></dt>
<dd>
Scans to match the string parameter or characters in the <code>NSCharacterSet</code> parameter, respectively. The <code>intoString</code> parameter will return containing the scanned string, if found. These methods are often used to advance the scanner's location—pass <code>nil</code> for the <code>intoString</code> parameter to ignore the output.
</dd>

<dt><code>scanUpToString:intoString:</code> / <code>scanUpToCharactersFromSet:intoString:</code></dt>
<dd>
Scans characters into a string <em>until</em> finding the string parameter or characters in the <code>NSCharacterSet</code> parameter, respectively. The <code>intoString</code> parameter will return containing the scanned string, if any was found. If the given string or character set are <em>not</em> found, the result will be the entire rest of the scanner's string.
</dd>
</dl>
</blockquote>

#### 2) Numeric Scanners

<blockquote>
<dl>
<dt><code>scanDouble:</code> / <code>scanFloat:</code> / <code>scanDecimal:</code></dt>
<dd>
Scans a floating-point value from the scanner's string and returns the value in the referenced <code>Double</code>, <code>Float</code>, or <code>NSDecimal</code> instance, if found.
</dd>

<dt><code>scanInteger:</code> / <code>scanInt:</code> / <code>scanLongLong:</code> / <code>scanUnsignedLongLong:</code></dt>
<dd>
Scans an integer value from the scanner's string and returns the value in the referenced <code>Int</code>, <code>Int32</code>, <code>Int64</code>, or <code>UInt64</code> instance, if found.
</dd>

<dt><code>scanHexDouble:</code> / <code>scanHexFloat:</code></dt>
<dd>
Scans a hexadecimal floating-point value from the scanner's string and returns the value in the referenced <code>Double</code> or <code>Float</code> instance, if found. To scan properly, the floating-point value <em>must</em> have a <code>0x</code> or <code>0X</code> prefix.
</dd>

<dt><code>scanHexInt:</code> / <code>scanHexLongLong:</code></dt>
<dd>
Scans a hexadecimal integer value from the scanner's string and returns the value in the referenced <code>UInt32</code> or <code>UInt64</code> instance, if found. The value may have a <code>0x</code> or <code>0X</code> prefix, but it is not required.
</dd>

</dl>
</blockquote>


* * *


## `localizedScannerWithString / locale`

Because it is a part of Cocoa, `NSScanner` has built-in localization support (of course). An `NSScanner` instance can work with either the user's locale when created via `+ localizedScannerWithString:`, or a specific locale after setting its `locale` property. In particular, the separator for floating-point values will be correctly interpreted based on the given locale:

````swift
var price = 0.0
let gasPriceScanner = NSScanner(string: "2.09 per gallon")
gasPriceScanner.scanDouble(&price)
// 2.09

// use a german locale instead of the default
let benzinPriceScanner = NSScanner(string: "1,38 pro Liter")
benzinPriceScanner.locale = NSLocale(localeIdentifier: "de-DE")
benzinPriceScanner.scanDouble(&price)
// 1.38
````

````objective-c
double price;
NSScanner *gasPriceScanner = [[NSScanner alloc] initWithString:@"2.09 per gallon"];
[gasPriceScanner scanDouble:&price];
// 2.09

// use a german locale instead of the default
NSScanner *benzinPriceScanner = [[NSScanner alloc] initWithString:@"1,38 pro Liter"];
[benzinPriceScanner setLocale:[NSLocale localeWithLocaleIdentifier:@"de-DE"]];
[benzinPriceScanner scanDouble:&price];
// 1.38
````


* * *


## Example: Parsing SVG Path Data

To take `NSScanner` out for a spin, we'll look at parsing the path data from an SVG path. SVG path data are stored as a string of instructions for drawing the path, where "M" indicates a "move-to" step, "L" stands for "line-to", and "C" stands for a curve. Uppercase instructions are followed by points in absolute coordinates; lowercase instructions are followed by coordinates relative to the last point in the path.

Here's an SVG path I happen to have lying around (and a point-offsetting helper we'll use later):

````swift
var svgPathData = "M28.2,971.4c-10,0.5-19.1,13.3-28.2,2.1c0,15.1,23.7,30.5,39.8,16.3c16,14.1,39.8-1.3,39.8-16.3c-12.5,15.4-25-14.4-39.8,4.5C35.8,972.7,31.9,971.2,28.2,971.4z"

extension CGPoint {
    func offset(p: CGPoint) -> CGPoint {
        return CGPoint(x: x + p.x, y: y + p.y)
    }
}
````
````objective-c
static NSString *const svgPathData = @"M28.2,971.4c-10,0.5-19.1,13.3-28.2,2.1c0,15.1,23.7,30.5,39.8,16.3c16,14.1,39.8-1.3,39.8-16.3c-12.5,15.4-25-14.4-39.8,4.5C35.8,972.7,31.9,971.2,28.2,971.4z";

CGPoint offsetPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}
````

Note that the point data are fairly irregular. Sometimes the `x` and `y` values of a point are separated by a comma, sometimes not, and likewise with points themselves. Parsing these data with regular expressions could turn into a mess pretty quickly, but with `NSScanner` the code is clear and straightforward.

We'll define a `bezierPathFromSVGPath` function that will convert a string of path data into an `UIBezierPath`. Our scanner is set up to skip commas and whitespace while scanning for values:

````swift
func bezierPathFromSVGPath(str: String) -> UIBezierPath {
    let scanner = NSScanner(string: str)
    
    // skip commas and whitespace
    let skipChars = NSMutableCharacterSet(charactersInString: ",")
    skipChars.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    scanner.charactersToBeSkipped = skipChars
    
    // the resulting bezier path
    var path = UIBezierPath()
````
````objective-c
- (UIBezierPath *)bezierPathFromSVGPath:(NSString *)str {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    
    // skip commas and whitespace
    NSMutableCharacterSet *skipChars = [NSMutableCharacterSet characterSetWithCharactersInString:@","];
    [skipChars formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    scanner.charactersToBeSkipped = skipChars;
    
    // the resulting bezier path
    UIBezierPath *path = [UIBezierPath bezierPath];
````

With the setup out of the way, it's time to start scanning. We start by scanning for a string made up of characters in the allowed set of instructions:

````swift
    // instructions code can be upper- or lower-case
    let instructionSet = NSCharacterSet(charactersInString: "MCSQTAmcsqta")
    var instruction: NSString?
    
    // scan for an instruction code
    while scanner.scanCharactersFromSet(instructionSet, intoString: &instruction) {
````
````objective-c
    // instructions codes can be upper- or lower-case
    NSCharacterSet *instructionSet = [NSCharacterSet characterSetWithCharactersInString:@"MCSQTAmcsqta"];
    NSString *instruction;
    
    // scan for an instruction code
    while ([scanner scanCharactersFromSet:instructionSet intoString:&instruction]) {
````

The next section scans for two `Double` values in a row, converts them to a `CGPoint`, and then ultimately adds the correct step to the bezier path:

````swift
        var x = 0.0, y = 0.0
        var points: [CGPoint] = []
        
        // scan for pairs of Double, adding them as CGPoints to the points array
        while scanner.scanDouble(&x) && scanner.scanDouble(&y) {
            points.append(CGPoint(x: x, y: y))
        }
        
        // new point for bezier path
        switch instruction ?? "" {
        case "M":
            path.moveToPoint(points[0])
        case "C":
            path.addCurveToPoint(points[2], controlPoint1: points[0], controlPoint2: points[1])
        case "c":
            path.addCurveToPoint(path.currentPoint.offset(points[2]),
                    controlPoint1: path.currentPoint.offset(points[0]),
                    controlPoint2: path.currentPoint.offset(points[1]))
        default:
            break
        }
    }
    
    return path
}
````
````objective-c
        double x, y;
        NSMutableArray *points = [NSMutableArray array];
        
        // scan for pairs of Double, adding them as CGPoints to the points array
        while ([scanner scanDouble:&x] && [scanner scanDouble:&y]) {
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
        
        // new point in path
        if ([instruction isEqualToString:@"M"]) {
            [path moveToPoint:[points[0] CGPointValue]];
        } else if ([instruction isEqualToString:@"C"]) {
            [path addCurveToPoint:[points[2] CGPointValue]
                    controlPoint1:[points[0] CGPointValue]
                    controlPoint2:[points[1] CGPointValue]];
        } else if ([instruction isEqualToString:@"c"]) {
            CGPoint newPoint = offsetPoint(path.currentPoint, [points[2] CGPointValue]);
            CGPoint control1 = offsetPoint(path.currentPoint, [points[0] CGPointValue]);
            CGPoint control2 = offsetPoint(path.currentPoint, [points[1] CGPointValue]);
            
            [path addCurveToPoint:newPoint
                    controlPoint1:control1
                    controlPoint2:control2];
        }
    }
    
    [path applyTransform:CGAffineTransformMakeScale(1, -1)];
    return path;
}
````

Lo and behold, the result:

![NSMustacheScanner]({{ site.asseturl }}/nsscanner-rendered.gif)

The required flipping, resizing, waxing, and twirling are left as an exercise for the reader.


* * *


## Swift-Friendly Scanning

As a last note, working with `NSScanner` in Swift can feel almost silly. Really, `NSScanner`, I need to pass in a pointer just so you can return a `Bool`? I can't use optionals, which are pretty much designed for this exact purpose? *Really?*

With a [simple extension converting the built-in methods to ones returning optional values](https://gist.github.com/natecook1000/59bb0c9117b555f5d40d), scanning becomes far more in sync with Swift's idiom. Our path data scanning example can now use optional binding instead of `inout` variables for a cleaner, easier-to-read implementation:

````swift
// look for an instruction code
while let instruction = scanner.scanCharactersFromSet(instructionSet) {
   var points: [CGPoint] = []
   
   // scan for pairs of Double, adding them as CGPoints to the points array
   while let x = scanner.scanDouble(), y = scanner.scanDouble() {
       points.append(CGPoint(x: x, y: y))
   }
   
   // new point for bezier path
   switch instruction {
       // ...
   }
}
````


* * *


You've gotta have the right tools for every job. `NSScanner` can be the shiny tool to reach for when it's time to parse a user's input or a web service's data. Being able to distinguish which tools are right for which tasks helps us on our way to creating clear and accurate code. 

