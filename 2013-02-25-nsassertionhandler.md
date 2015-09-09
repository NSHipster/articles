---
title: NSAssertionHandler
author: Mattt Thompson
category: Cocoa
excerpt: "Programming incorporates numerous disciplines of human reasoning, from high-level discourse and semantics—the story we tell each other to explain how a system works—to the mathematical and philosophical machinery that underpins everything."
status:
    swift: n/a
---

"When at first you don't succeed, use an object-oriented injection point to override default exception handling." This is the sort of advice you would have learned at mother's knee if you were raised by `NSAssertionHandler`.

Programming incorporates numerous disciplines of human reasoning, from high-level discourse and semantics—the "story" we tell each other to explain how a system works—to the mathematical and philosophical machinery that underpins everything.

Assertions are a concept borrowed from classical logic. In logic, assertions are statements about propositions within a proof. In programming, assertions denote assumptions the programmer has made about the application at the place where they are declared.

When used in the capacity of preconditions and postconditions, which describe expectations about the state of the code at the beginning and end of execution of a method or function, assertions form a [contract](http://en.wikipedia.org/wiki/Design_by_contract). Assertions can also be used to enforce conditions at run-time, in order to prevent execution when certain preconditions fail.

Assertions are similar to [unit testing](http://en.wikipedia.org/wiki/Unit_testing) in that they define expectations about the way code will execute. Unlike unit tests, assertions exist inside the program itself, and are thereby constrained to the context of the program. Because unit tests are fully independent, they have a much greater capacity to isolate and test certain behaviors, using tools like methods stubs and mock objects. Developers should use assertions and unit tests in combination and in reasonable quantity to test and define behavior in an application.

## Foundation Assertion Handling

Objective-C combines C-style assertion macros with an object-oriented approach to intercepting and handling assertion failures. Namely, `NSAssertionHandler`:

> Each thread has its own assertion handler, which is an object of class `NSAssertionHandler`. When invoked, an assertion handler prints an error message that includes the method and class names (or the function name). It then raises an `NSInternalInconsistencyException` exception.

Foundation [defines](https://gist.github.com/mattt/5031388#file-nsassertionhandler-m-L50-L56) two pairs of assertion macros:

- `NSAssert` / `NSCAssert`
- `NSParameterAssert` / `NSCParameterAssert`

Foundation makes two distinctions in their assertion handler APIs that are both semantic and functional.

The first distinction is between a general assertion (`NSAssert`) and a parameter assertion (`NSParameterAssert`). As a rule of thumb, methods / functions should use `NSParameterAssert` / `NSCParameterAssert` statements at the top of methods to enforce any preconditions about the input values; in all other cases, use `NSAssert` / `NSCAssert`.

The second is the difference between C and Objective-C assertions: `NSAssert` should only be used in an Objective-C context (i.e. method implementations), whereas `NSCAssert` should only be used in a C context (i.e. functions).

- When a condition in `NSAssert` or `NSParameterAssert` fails, `-handleFailureInMethod:object:file:lineNumber:description:` is called in the assertion handler.
- When a condition in `NSCAssert` or `NSCParameterAssert` fails, `-handleFailureInFunction:file:lineNumber:description:` is called in the assertion handler.

Additionally, there are variations of `NSAssert` / `NSCAssert`, from `NSAssert1` ... `NSAssert5`, which take their respective number of arguments to use in a `printf`-style format string.

## Using NSAssertionHandler

It's important to note that as of Xcode 4.2, [assertions are turned off by default for release builds](http://stackoverflow.com/questions/6445222/ns-block-assertions-in-objective-c), which is accomplished by defining the `NS_BLOCK_ASSERTIONS` macro. That is to say, when compiled for release, any calls to `NSAssert` & co. are effectively removed.

And while Foundation assertion macros are extremely useful in their own right—even when just used in development—the fun doesn't have to stop there. `NSAssertionHandler` provides a way to gracefully handle assertion failures in a way that preserves valuable real-world usage information.

> That said, many seasoned Objective-C developers caution against actually using `NSAssertionHandler` in production applications. Foundation assertion handlers are something to understand and appreciate from a safe distance. **Proceed with caution if you decide to use this in a shipping application.**

`NSAssertionHandler` is a straightforward class, with two methods to implement in your subclass: `-handleFailureInMethod:...` (called on a failed `NSAssert` / `NSParameterAssert`) and `-handleFailureInFunction:...` (called on a failed `NSCAssert` / `NSCParameterAssert`).

`LoggingAssertionHandler` simply logs out the assertion failures, but those failures could also be logged to an external web service to be aggregated and analyzed, for example.

### LoggingAssertionHandler.h

~~~{objective-c}
@interface LoggingAssertionHandler : NSAssertionHandler
@end
~~~

### LoggingAssertionHandler.m

~~~{objective-c}
@implementation LoggingAssertionHandler

- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ...
{
  NSLog(@"NSAssert Failure: Method %@ for object %@ in %@#%i", NSStringFromSelector(selector), object, fileName, line);
}

- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format, ...
{
  NSLog(@"NSCAssert Failure: Function (%@) in %@#%i", functionName, fileName, line);
}

@end
~~~

Each thread has the option of specifying an assertion handler. To have the `NSAssertionHandler` subclass start handling failed assertions, set it as the value for the `NSAssertionHandlerKey` key in the thread's `threadDictionary`.

In most cases, it will make sense to set your assertion handler on the current thread inside `-application:
didFinishLaunchingWithOptions:`.

### AppDelegate.m

~~~{objective-c}
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSAssertionHandler *assertionHandler = [[LoggingAssertionHandler alloc] init];
  [[[NSThread currentThread] threadDictionary] setValue:assertionHandler
                                                 forKey:NSAssertionHandlerKey];
  // ...

  return YES;
}
~~~

---

`NSAssertionHandler` reminds us of the best practices around articulating our expectations as programmers through assert statements.

But if we look deeper into `NSAssertionHandler`—and indeed, into our own hearts, there are lessons to be learned about our capacity for kindness and compassion; about our ability to forgive others, and to recover from our own missteps. We can't be right all of the time. We all make mistakes. By accepting limitations in ourselves and others, only then are we able to grow as individuals.

Or whatever.
