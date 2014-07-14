---
layout: post
title: "Clang Diagnostics"
ref: "http://clang.llvm.org/diagnostics.html"
category: Objective-C
rating: 9.3
description: "Diagnostics combine logic with analytics to arrive at a conclusion. It's science and engineering at their purest. It's human reasoning at its most potent. For us developers, our medium of code informs the production of subsequent code, creating a positive feedback loop that has catapulted the development of technology exponentially over the last half century. For us Objective-C developers specifically, the most effective diagnostics come from Clang."
---

Diagnostics combine logic with analytics to arrive at a conclusion. It's science and engineering at their purest. It's human reasoning at its most potent.

Within the medical profession, a diagnosis is made through instinct backed by lab samples. For industrial manufacturing, one diagnoses a product fault through an equal application of statistics and gumption.

For us developers, our medium of code informs the production of subsequent code, creating a positive feedback loop that has catapulted the development of technology exponentially over the last half century. For us Objective-C developers specifically, the most effective diagnostics come from Clang.

Clang is the C / Objective-C front-end to the LLVM compiler. It has a deep understanding of the syntax and semantics of Objective-C, and is much of the reason that Objective-C is such a capable language today.

That amazing readout you get when you "Build & Analyze" (`⌘⇧B`) is a function of the softer, more contemplative side of Clang: its code diagnostics.

In our article about [`#pragma`](http://nshipster.com/pragma/), we quipped:

> Pro tip: Try setting the `-Weverything` flag and checking the "Treat Warnings as Errors" box your build settings. This turns on Hard Mode in Xcode.

Now, we stand by this advice, and encourage other developers to step up their game and treat build warnings more seriously. However, there are some situations in which you and Clang reach an impasse. For example, consider the following `switch` statement:

~~~{objective-c}
switch (style) {
    case UITableViewCellStyleDefault:
    case UITableViewCellStyleValue1:
    case UITableViewCellStyleValue2:
    case UITableViewCellStyleSubtitle:
        // ...
    default:
        return;
}
~~~

When certain flags are enabled, Clang will complain that the "default label in switch which covers all enumeration values". However, if we _know_ that, zooming out into a larger context, `style` is (for better or worse) derived from an external representation (e.g. JSON resource) that allows for unconstrained `NSInteger` values, the `default` case is a necessary safeguard. The only way to insist on this inevitability is to use `#pragma` to ignore a warning flag temporarily:

> `push` & `pop` are used to save and restore the compiler state, similar to Core Graphics or OpenGL contexts.

~~~{objective-c}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
switch (style) {
    case UITableViewCellStyleDefault:
    case UITableViewCellStyleValue1:
    case UITableViewCellStyleValue2:
    case UITableViewCellStyleSubtitle:
        // ...
    default:
        return;
}
#pragma clang diagnostic pop
~~~

> Again, and this cannot be stressed enough, Clang is right at least 99% of the time. Actually fixing an analyzer warning is _strongly_ preferred to ignoring it. Use `#pragma clang diagnostic ignored` as a method of last resort.

This week, as a public service, we've compiled a (mostly) comprehensive list of Clang warning strings and their associated flags:

> Like our article on [NSError](http://nshipster.com/nserror/), this is more of an article for future reference than a formal explanation. Keep this page bookmarked for the next time that you happen to run into this situation.

* * *

## Clang Diagnostic Warning Flags & Messages

### Lex (`liblex`)

| Warning Flag | Message |
|--------------|---------|
| `-W#pragma-messages` | "%0"	 |
| `-W#warnings` | "%0"	 |
| `-Wambiguous-macro`	 | "ambiguous expansion of macro %0"	 |
| `-Wauto-import`	 | "treating #%select{include|import|include_next|__include_macros}0 as an import of module '%1'"	 |
| `-Wbackslash-newline-escape`	 | "backslash and newline separated by space"	 |
| `-Wc++11-compat`	 | "'%0' is a keyword in C++11"	 |
| `-Wc++11-compat`	 | "identifier after literal will be treated as a user-defined literal suffix in C++11"	 |
| `-Wc++98-c++11-compat-pedantic`	 | "binary integer literals are incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | "digit separators are incompatible with C++ standards before C++1y"	 |
| `-Wc++98-compat-pedantic`	 | "#line number greater than 32767 is incompatible with C++98"	 |
| `-Wc++98-compat-pedantic`	 | "C++98 requires newline at end of file"	 |
| `-Wc++98-compat-pedantic`	 | "empty macro arguments are incompatible with C++98"	 |
| `-Wc++98-compat-pedantic`	 | "variadic macros are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'::' is treated as digraph ':' (aka '[') followed by ':' in C++98"	 |
| `-Wc++98-compat`	 | "raw string literals are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "specifying character '%0' with a universal character name is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "unicode literals are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "universal character name referring to a control character is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "using this character in an identifier is incompatible with C++98"	 |
| `-Wc99-compat`	 | "%select{using this character in an identifier|starting an identifier with this character}0 is incompatible with C99"	 |
| `-Wc99-compat`	 | "unicode literals are incompatible with C99"	 |
| `-Wcomment`	 | "'/*' within block comment"	 |
| `-Wcomment`	 | "escaped newline between */ characters at block comment end"	 |
| `-Wdisabled-macro-expansion`	 | "disabled expansion of recursive macro", DefaultIgnore	 |
| `-Wheader-guard`	 | "%0 is used as a header guard here, followed by #define of a different macro"	 |
| `-Wignored-attributes`	 | "unknown attribute '%0'"	 |
| `-Wincomplete-module`	 | "header '%0' is included in module '%1' but not listed in module map"	 |
| `-Wincomplete-umbrella`	 | "umbrella header for module '%0' does not include header '%1'"	 |
| `-Winvalid-token-paste`	 | "pasting formed '%0', an invalid preprocessing token", DefaultError	 |
| `-Wmalformed-warning-check`	 | "__has_warning expected option name (e.g. \"-Wundef\")"	 |
| `-Wnewline-eof`	 | "no newline at end of file"	 |
| `-Wnull-character`	 | "null character ignored"	 |
| `-Wnull-character`	 | "null character(s) preserved in character literal"	 |
| `-Wnull-character`	 | "null character(s) preserved in string literal"	 |
| `-Wtrigraphs`	 | "ignored trigraph would end block comment"	 |
| `-Wtrigraphs`	 | "trigraph ignored"	 |
| `-Wundef, DefaultIgnore`	 | "%0 is not defined, evaluates to 0"	 |
| `-Wunicode`	 | "incomplete universal character name treating as '\\' followed by identifier"	 |
| `-Wunicode`	 | "universal character name refers to a surrogate character"	 |
| `-Wunicode`	 | "universal character names are only valid in C99 or C++ treating as '\\' followed by identifier"	 |
| `-Wunicode`	 | "\\%0 used with no following hex digits treating as '\\' followed by identifier"	 |
| `-Wunknown-pragmas`	 | "pragma STDC FENV_ACCESS ON is not supported, ignoring pragma"	 |
| `-Wunknown-pragmas`	 | "unknown pragma ignored"	 |
| `-Wunused-macros`	 | "macro is not used", DefaultIgnore	 |

### Parse (`libparse`)

| Warning Flag | Message |
|--------------|---------|
| `-Warc-bridge-casts-disallowed-in-nonarc`	 | "'%0' casts have no effect when not using ARC"	 |
| `-Wattributes`	 | "unknown __declspec attribute %0 ignored"	 |
| `-Wavailability`	 | "'unavailable' availability overrides all other availability information"	 |
| `-Wc++11-compat`	 | "'auto' storage class specifier is redundant and incompatible with C++11"	 |
| `-Wc++11-compat`	 | "use of right-shift operator ('') in template argument will require parentheses in C++11"	 |
| `-Wc++98-c++11-compat`	 | "'decltype(auto)' type specifier is incompatible with C++ standards before C++1y"	 |
| `-Wc++98-compat-pedantic`	 | "commas at the end of enumerator lists are incompatible with C++98"	 |
| `-Wc++98-compat-pedantic`	 | "extern templates are incompatible with C++98"	 |
| `-Wc++98-compat-pedantic`	 | "extra '' outside of a function is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'%0' keyword is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'alignas' is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'decltype' type specifier is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'nullptr' is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "alias declarations are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "alignof expressions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "attributes are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "consecutive right angle brackets are incompatible with C++98 (use ' ')"	 |
| `-Wc++98-compat`	 | "defaulted function definitions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "deleted function definitions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "enumeration types with a fixed underlying type are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "generalized initializer lists are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "in-class initialization of non-static data members is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "inline namespaces are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "lambda expressions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "literal operators are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "noexcept expressions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "noexcept specifications are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "range-based for loop is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "reference qualifiers on functions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "rvalue references are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "scoped enumerations are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "static_assert declarations are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "trailing return types are incompatible with C++98"	 |
| `-Wdeprecated-declarations`	 | "use of C-style parameters in Objective-C method declarations is deprecated"	 |
| `-Wdeprecated-register`	 | "'register' storage class specifier is deprecated"	 |
| `-Wdeprecated`	 | "Use of 'long' with '__vector' is deprecated"	 |
| `-Wduplicate-decl-specifier`	 | "duplicate '%0' declaration specifier"	 |
| `-Wextra-semi`	 | "extra '' after member function definition"	 |
| `-Wextra-tokens`	 | "extra tokens at the end of '#pragma omp %0' are ignored"	 |
| `-Wgcc-compat`	 | "GCC does not allow %0 attribute in this position on a function definition"	 |
| `-WiagGroup<"dangling-else`	 | "add explicit braces to avoid dangling else"	 |
| `-Wignored-attributes`	 | "attribute %0 ignored, because it is not attached to a declaration"	 |
| `-Wmicrosoft-exists`	 | "dependent %select{__if_not_exists|__if_exists}0 declarations are ignored"	 |
| `-Wmissing-selector-name`	 | "%0 used as the name of the previous parameter rather than as part of the selector"	 |
| `-Wsemicolon-before-method-body, DefaultIgnore`	 | "semicolon before method body is ignored"	 |
| `-Wsource-uses-openmp`	 | "unexpected '#pragma omp ...' in program"	 |
| `-Wstatic-inline-explicit-instantiation`	 | "ignoring '%select{static|inline}0' keyword on explicit template instantiation"	 |

### Semantic (`libsema`)

| Warning Flag | Message |
|--------------|---------|
| `-Wabstract-vbase-init, DefaultIgnore`	 | "initializer for virtual base class %0 of abstract class %1 will never be used"	 |
| `-Waddress-of-array-temporary`	 | "pointer is initialized by a temporary array, which will be destroyed at the end of the full-expression"	 |
| `-Warc-maybe-repeated-use-of-weak`	 | "weak %select{variable|property|implicit property|instance variable}0 %1 may be accessed multiple times in this %select{function|method|block|lambda}2 and may be unpredictably set to nil assign to a strong variable to keep the object alive"	 |
| `-Warc-non-pod-memaccess`	 | "%select{destination for|source of}0 this %1 call is a pointer to ownership-qualified type %2"	 |
| `-Warc-performSelector-leaks`	 | "performSelector may cause a leak because its selector is unknown"	 |
| `-Warc-repeated-use-of-weak`	 | "weak %select{variable|property|implicit property|instance variable}0 %1 is accessed multiple times in this %select{function|method|block|lambda}2 but may be unpredictably set to nil assign to a strong variable to keep the object alive"	 |
| `-Warc-retain-cycles`	 | "capturing %0 strongly in this block is likely to lead to a retain cycle"	 |
| `-Warc-unsafe-retained-assign`	 | "assigning %select{array literal|dictionary literal|numeric literal|boxed expression|should not happen|block literal}0 to a weak %select{property|variable}1 object will be released after assignment"	 |
| `-Warc-unsafe-retained-assign`	 | "assigning retained object to %select{weak|unsafe_unretained}0 %select{property|variable}1 object will be released after assignment"	 |
| `-Warc-unsafe-retained-assign`	 | "assigning retained object to unsafe property object will be released after assignment"	 |
| `-Warray-bounds-pointer-arithmetic`	 | "the pointer decremented by %0 refers before the beginning of the array"	 |
| `-Warray-bounds-pointer-arithmetic`	 | "the pointer incremented by %0 refers past the end of the array (that contains %1 element%s2)"	 |
| `-Warray-bounds`	 | "'static' has no effect on zero-length arrays"	 |
| `-Warray-bounds`	 | "array argument is too small contains %0 elements, callee requires at least %1"	 |
| `-Warray-bounds`	 | "array index %0 is before the beginning of the array"	 |
| `-Warray-bounds`	 | "array index %0 is past the end of the array (which contains %1 element%s2)"	 |
| `-Wassign-enum, DefaultIgnore`	 | "integer constant not in range of enumerated type %0"	 |
| `-Watomic-property-with-user-defined-accessor`	 | "writable atomic property %0 cannot pair a synthesized %select{getter|setter}1 with a user defined %select{getter|setter}2"	 |
| `-Wattributes`	 | "unknown attribute %0 ignored"	 |
| `-Wauto-var-id`	 | "'auto' deduced as 'id' in declaration of %0"	 |
| `-Wavailability`	 | "availability does not match previous declaration"	 |
| `-Wavailability`	 | "feature cannot be %select{introduced|deprecated|obsoleted}0 in %1 version %2 before it was %select{introduced|deprecated|obsoleted}3 in version %4 attribute ignored"	 |
| `-Wavailability`	 | "overriding method %select{introduced after|deprecated before|obsoleted before}0 overridden method on %1 (%2 vs. %3)"	 |
| `-Wavailability`	 | "overriding method cannot be unavailable on %0 when its overridden method is available"	 |
| `-Wavailability`	 | "unknown platform %0 in availability macro"	 |
| `-Wbad-function-cast`	 | "cast from function call of type %0 to non-matching type %1"	 |
| `-Wbitfield-constant-conversion`	 | "implicit truncation from %2 to bitfield changes value from %0 to %1"	 |
| `-Wbool-conversion`	 | "initialization of pointer of type %0 to null from a constant boolean " "expression"	 |
| `-Wbridge-cast`	 | "%0 bridges to %1, not %2"	 |
| `-Wbridge-cast`	 | "%0 cannot bridge to %1"	 |
| `-Wbuiltin-requires-header`	 | "declaration of built-in function '%0' requires inclusion of the header setjmp.h"	 |
| `-Wbuiltin-requires-header`	 | "declaration of built-in function '%0' requires inclusion of the header stdio.h"	 |
| `-Wbuiltin-requires-header`	 | "declaration of built-in function '%0' requires inclusion of the header ucontext.h"	 |
| `-Wc++11-compat`	 | "explicit instantiation cannot be 'inline'"	 |
| `-Wc++11-compat`	 | "explicit instantiation of %0 must occur at global scope"	 |
| `-Wc++11-compat`	 | "explicit instantiation of %0 not in a namespace enclosing %1"	 |
| `-Wc++11-compat`	 | "explicit instantiation of %q0 must occur in namespace %1"	 |
| `-Wc++11-narrowing`	 | "constant expression evaluates to %0 which cannot be narrowed to type %1 in C++11"	 |
| `-Wc++11-narrowing`	 | "non-constant-expression cannot be narrowed from type %0 to %1 in initializer list in C++11"	 |
| `-Wc++11-narrowing`	 | "type %0 cannot be narrowed to %1 in initializer list in C++11"	 |
| `-Wc++98-c++11-compat`	 | "constexpr function with no return statements is incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | "multiple return statements in constexpr function is incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | "type definition in a constexpr %select{function|constructor}0 is incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | "use of this statement in a constexpr %select{function|constructor}0 is incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | "variable declaration in a constexpr %select{function|constructor}0 is incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | "variable templates are incompatible with C++ standards before C++1y"	 |
| `-Wc++98-c++11-compat`	 | init-captures.def warn_cxx11_compat_init_capture : Warning "initialized lambda captures are incompatible with C++ standards " "before C++1y"	 |
| `-Wc++98-compat-pedantic`	 | "cast between pointer-to-function and pointer-to-object is incompatible with C++98"	 |
| `-Wc++98-compat-pedantic`	 | "implicit conversion from array size expression of type %0 to %select{integral|enumeration}1 type %2 is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "%select{anonymous struct|union}0 member %1 with a non-trivial %select{constructor|copy constructor|move constructor|copy assignment operator|move assignment operator|destructor}2 is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "%select{class template|class template partial|variable template|variable template partial|function template|member function|static data member|member class|member enumeration}0 specialization of %1 outside namespace %2 is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'%0' type specifier is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'auto' type specifier is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "'constexpr' specifier is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "befriending %1 without '%select{struct|interface|union|class|enum}0' keyword is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "befriending enumeration type %0 is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "constructor call from initializer list is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "default template arguments for a function template are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "delegating constructors are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "enumeration type in nested name specifier is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "explicit conversion functions are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "friend declaration naming a member of the declaring class is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "friend function %0 would be implicitly redefined in C++98"	 |
| `-Wc++98-compat`	 | "goto would jump into protected scope in C++98"	 |
| `-Wc++98-compat`	 | "indirect goto might cross protected scopes in C++98"	 |
| `-Wc++98-compat`	 | "inheriting constructors are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "initialization of initializer_list object is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "non-class friend type %0 is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "non-type template argument referring to %select{function|object}0 %1 with internal linkage is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "passing object of trivial but non-POD type %0 through variadic %select{function|block|method|constructor}1 is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "redundant parentheses surrounding address non-type template argument are incompatible with C++98"	 |
| `-Wc++98-compat`	 | "reference initialized from initializer list is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "scalar initialized from empty initializer list is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "static data member %0 in union is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "substitution failure due to access control is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "switch case would be in a protected scope in C++98"	 |
| `-Wc++98-compat`	 | "use of 'template' keyword outside of a template is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "use of 'typename' outside of a template is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "use of non-static data member %0 in an unevaluated context is incompatible with C++98"	 |
| `-Wc++98-compat`	 | "use of null pointer as non-type template argument is incompatible with C++98"	 |
| `-Wcast-align`	 | "cast from %0 to %1 increases required alignment from %2 to %3"	 |
| `-Wcast-of-sel-type`	 | "cast of type %0 to %1 is deprecated use sel_getName instead"	 |
| `-WCFString-literal`	 | "input conversion stopped due to an input byte that does not belong to the input codeset UTF-8"	 |
| `-Wchar-subscripts`	 | "array subscript is of type 'char'"	 |
| `-Wconditional-uninitialized`	 | "variable %0 may be uninitialized when %select{used here|captured by block}1"	 |
| `-Wconstant-logical-operand`	 | "use of logical '%0' with constant operand"	 |
| `-Wconstexpr-not-const`	 | "'constexpr' non-static member function will not be implicitly 'const' in C++1y add 'const' to avoid a change in behavior"	 |
| `-Wconsumed`	 | "argument not in expected state expected '%0', observed '%1'"	 |
| `-Wconsumed`	 | "consumed analysis attribute is attached to member of class '%0' which isn't marked as consumable"	 |
| `-Wconsumed`	 | "invalid invocation of method '%0' on a temporary object while it is in the '%1' state"	 |
| `-Wconsumed`	 | "invalid invocation of method '%0' on object '%1' while it is in the '%2' state"	 |
| `-Wconsumed`	 | "parameter '%0' not in expected state when the function returns: expected '%1', observed '%2'"	 |
| `-Wconsumed`	 | "return state set for an unconsumable type '%0'"	 |
| `-Wconsumed`	 | "return value not in expected state expected '%0', observed '%1'"	 |
| `-Wconsumed`	 | "state of variable '%0' must match at the entry and exit of loop"	 |
| `-Wconversion`	 | "implicit conversion discards imaginary component: %0 to %1"	 |
| `-Wconversion`	 | "implicit conversion loses floating-point precision: %0 to %1"	 |
| `-Wconversion`	 | "implicit conversion loses integer precision: %0 to %1"	 |
| `-Wconversion`	 | "implicit conversion turns floating-point number into integer: %0 to %1"	 |
| `-Wconversion`	 | "implicit conversion turns vector to scalar: %0 to %1"	 |
| `-Wconversion`	 | "non-type template argument value '%0' truncated to '%1' for template parameter of type %2"	 |
| `-Wconversion`	 | "non-type template argument with value '%0' converted to '%1' for unsigned template parameter of type %2"	 |
| `-Wcovered-switch-default`	 | "default label in switch which covers all enumeration values"	 |
| `-Wcustom-atomic-properties`	 | "atomic by default property %0 has a user defined %select{getter|setter}1 (property should be marked 'atomic' if this is intended)"	 |
| `-Wdangling-field`	 | "binding reference %select{|subobject of }1member %0 to a temporary value"	 |
| `-Wdangling-field`	 | "binding reference member %0 to stack allocated parameter %1"	 |
| `-Wdangling-field`	 | "initializing pointer member %0 with the stack address of parameter %1"	 |
| `-Wdangling-initializer-list`	 | "array backing the initializer list will be destroyed at the end of %select{the full-expression|the constructor}0"	 |
| `-Wdelete-incomplete`	 | "deleting pointer to incomplete type %0 may cause undefined behavior"	 |
| `-Wdelete-non-virtual-dtor`	 | "delete called on %0 that has virtual functions but non-virtual destructor"	 |
| `-Wdelete-non-virtual-dtor`	 | "delete called on %0 that is abstract but has non-virtual destructor"	 |
| `-Wdeprecated-increment-bool`	 | "incrementing expression of type bool is deprecated"	 |
| `-Wdeprecated-objc-isa-usage`	 | "assignment to Objective-C's isa is deprecated in favor of object_setClass()"	 |
| `-Wdeprecated-objc-isa-usage`	 | "direct access to Objective-C's isa is deprecated in favor of object_getClass()"	 |
| `-Wdeprecated-objc-pointer-introspection-performSelector`	 | warn_objc_pointer_masking.Text	 |
| `-Wdeprecated-objc-pointer-introspection`	 | "bitmasking for introspection of Objective-C object pointers is strongly discouraged"	 |
| `-Wdeprecated-writable-strings`	 | "dummy warning to enable -fconst-strings"	 |
| `-Wdeprecated`	 | "access declarations are deprecated use using declarations instead"	 |
| `-Wdeprecated`	 | "definition of implicit copy %select{constructor|assignment operator}1 for %0 is deprecated because it has a user-declared %select{copy %select{assignment operator|constructor}1|destructor}2"	 |
| `-Wdeprecated`	 | "dynamic exception specifications are deprecated"	 |
| `-Wdirect-ivar-access, DefaultIgnore`	 | "instance variable %0 is being directly accessed"	 |
| `-Wdistributed-object-modifiers`	 | "conflicting distributed object modifiers on parameter type in implementation of %0"	 |
| `-Wdistributed-object-modifiers`	 | "conflicting distributed object modifiers on return type in implementation of %0"	 |
| `-Wdivision-by-zero`	 | "division by zero is undefined"	 |
| `-Wdivision-by-zero`	 | "remainder by zero is undefined"	 |
| `-Wdocumentation`	 | "not a Doxygen trailing comment"	 |
| `-Wduplicate-enum, DefaultIgnore`	 | "element %0 has been implicitly assigned %1 which another element has been assigned"	 |
| `-Wduplicate-method-match`	 | "multiple declarations of method %0 found and ignored"	 |
| `-Wdynamic-class-memaccess`	 | "%select{destination for|source of|first operand of|second operand of}0 this %1 call is a pointer to dynamic class %2 vtable pointer will be %select{overwritten|copied|moved|compared}3"	 |
| `-Wempty-body`	 | "for loop has empty body"	 |
| `-Wempty-body`	 | "if statement has empty body"	 |
| `-Wempty-body`	 | "range-based for loop has empty body"	 |
| `-Wempty-body`	 | "switch statement has empty body"	 |
| `-Wempty-body`	 | "while loop has empty body"	 |
| `-Wenum-compare`	 | "comparison of two values with different enumeration types%diff{ ($ and $)|}0,1"	 |
| `-Wenum-conversion`	 | "implicit conversion from enumeration type %0 to different enumeration type %1"	 |
| `-Wexit-time-destructors`	 | "declaration requires an exit-time destructor"	 |
| `-Wexplicit-ownership-type, DefaultIgnore`	 | "method parameter of type %0 with no explicit ownership"	 |
| `-Wextern-c-compat`	 | "%select{|empty }0%select{struct|union}1 has size 0 in C, %select{size 1|non-zero size}2 in C++"	 |
| `-Wextern-initializer`	 | "'extern' variable has an initializer"	 |
| `-Wfloat-equal, DefaultIgnore`	 | "comparing floating point with == or != is unsafe"	 |
| `-Wformat-extra-args`	 | "data argument not used by format string"	 |
| `-Wformat-invalid-specifier`	 | "invalid conversion specifier '%0'"	 |
| `-Wformat-nonliteral`	 | "format string is not a string literal"	 |
| `-Wformat-security`	 | "format string is not a string literal (potentially insecure)"	 |
| `-Wformat-zero-length`	 | "format string is empty"	 |
| `-Wformat`	 | "%select{field width|precision}0 used with '%1' conversion specifier, resulting in undefined behavior"	 |
| `-Wformat`	 | "'%select{*|.*}0' specified field %select{width|precision}0 is missing a matching 'int' argument"	 |
| `-Wformat`	 | "cannot mix positional and non-positional arguments in format string"	 |
| `-Wformat`	 | "data argument position '%0' exceeds the number of data arguments (%1)"	 |
| `-Wformat`	 | "field %select{width|precision}0 should have type %1, but argument has type %2"	 |
| `-Wformat`	 | "flag '%0' is ignored when flag '%1' is present"	 |
| `-Wformat`	 | "flag '%0' results in undefined behavior with '%1' conversion specifier"	 |
| `-Wformat`	 | "format specifies type %0 but the argument has type %1"	 |
| `-Wformat`	 | "format string contains '\\0' within the string body"	 |
| `-Wformat`	 | "format string missing"	 |
| `-Wformat`	 | "format string should not be a wide string"	 |
| `-Wformat`	 | "incomplete format specifier"	 |
| `-Wformat`	 | "invalid position specified for %select{field width|field precision}0"	 |
| `-Wformat`	 | "length modifier '%0' results in undefined behavior or no effect with '%1' conversion specifier"	 |
| `-Wformat`	 | "more '%%' conversions than data arguments"	 |
| `-Wformat`	 | "no closing ']' for '%%[' in scanf format string"	 |
| `-Wformat`	 | "position arguments in format strings start counting at 1 (not 0)"	 |
| `-Wformat`	 | "values of type '%0' should not be used as format arguments add an explicit cast to %1 instead"	 |
| `-Wformat`	 | "zero field width in scanf format string is unused"	 |
| `-Wgcc-compat`	 | "GCC does not allow the 'cleanup' attribute argument to be anything other than a simple identifier"	 |
| `-Wglobal-constructors`	 | "declaration requires a global constructor"	 |
| `-Wglobal-constructors`	 | "declaration requires a global destructor"	 |
| `-Wheader-hygiene`	 | "using namespace directive in global context in header"	 |
| `-WiagGroup<"bitwise-op-parentheses`	 | "'&' within '|'"	 |
| `-WiagGroup<"c++-compat`	 | "%select{|empty }0%select{struct|union}1 has size 0 in C, %select{size 1|non-zero size}2 in C++"	 |
| `-WiagGroup<"logical-not-parentheses`	 | "logical not is only applied to the left hand side of this comparison"	 |
| `-WiagGroup<"logical-op-parentheses`	 | "'&&' within '||'"	 |
| `-WiagGroup<"missing-declarations`	 | "'%0' ignored on this declaration"	 |
| `-WiagGroup<"overloaded-shift-op-parentheses`	 | "overloaded operator %select{|}0 has lower precedence than comparison operator"	 |
| `-WiagGroup<"shift-op-parentheses`	 | "operator '%0' has lower precedence than '%1' '%1' will be evaluated first"	 |
| `-Widiomatic-parentheses, DefaultIgnore`	 | "using the result of an assignment as a condition without parentheses"	 |
| `-Wignored-attributes`	 | "#pramga ms_struct can not be used with dynamic classes or structures"	 |
| `-Wignored-attributes`	 | "%0 attribute argument not supported: %1"	 |
| `-Wignored-attributes`	 | "%0 attribute can only be applied to instance variables or properties"	 |
| `-Wignored-attributes`	 | "%0 attribute ignored for field of type %1"	 |
| `-Wignored-attributes`	 | "%0 attribute ignored when parsing type"	 |
| `-Wignored-attributes`	 | "%0 attribute ignored"	 |
| `-Wignored-attributes`	 | "%0 attribute only applies to %select{functions|methods|properties}1 that return %select{an Objective-C object|a pointer|a non-retainable pointer}2"	 |
| `-Wignored-attributes`	 | "%0 attribute only applies to %select{functions|unions|variables and functions|functions and methods|parameters|functions, methods and blocks|functions, methods, and classes|functions, methods, and parameters|classes|variables|methods|variables, functions and labels|fields and global variables|structs|variables, functions and tag types|thread-local variables|variables and fields|variables, data members and tag types|types and namespaces|Objective-C interfaces}1"	 |
| `-Wignored-attributes`	 | "%0 attribute only applies to %select{Objective-C object|pointer}1 parameters"	 |
| `-Wignored-attributes`	 | "%0 calling convention ignored on variadic function"	 |
| `-Wignored-attributes`	 | "%0 only applies to variables with static storage duration and functions"	 |
| `-Wignored-attributes`	 | "%select{alignment|size}0 of field %1 (%2 bits) does not match the %select{alignment|size}0 of the first field in transparent union transparent_union attribute ignored"	 |
| `-Wignored-attributes`	 | "'%0' attribute cannot be specified on a definition"	 |
| `-Wignored-attributes`	 | "'%0' only applies to %select{function|pointer|Objective-C object or block pointer}1 types type here is %2"	 |
| `-Wignored-attributes`	 | "'gnu_inline' attribute requires function to be marked 'inline', attribute ignored"	 |
| `-Wignored-attributes`	 | "'malloc' attribute only applies to functions returning a pointer type"	 |
| `-Wignored-attributes`	 | "'nonnull' attribute applied to function with no pointer arguments"	 |
| `-Wignored-attributes`	 | "'sentinel' attribute only supported for variadic %select{functions|blocks}0"	 |
| `-Wignored-attributes`	 | "'sentinel' attribute requires named arguments"	 |
| `-Wignored-attributes`	 | "attribute %0 after definition is ignored"	 |
| `-Wignored-attributes`	 | "attribute %0 cannot be applied to %select{functions|Objective-C method}1 without return value"	 |
| `-Wignored-attributes`	 | "attribute %0 ignored, because it cannot be applied to a type"	 |
| `-Wignored-attributes`	 | "attribute %0 is already applied with different parameters"	 |
| `-Wignored-attributes`	 | "attribute %0 is already applied"	 |
| `-Wignored-attributes`	 | "attribute %0 is ignored, place it after \"%select{class|struct|union|interface|enum}1\" to apply attribute to type declaration"	 |
| `-Wignored-attributes`	 | "attribute declaration must precede definition"	 |
| `-Wignored-attributes`	 | "calling convention %0 ignored for this target"	 |
| `-Wignored-attributes`	 | "first field of a transparent union cannot have %select{floating point|vector}0 type %1 transparent_union attribute ignored"	 |
| `-Wignored-attributes`	 | "ibaction attribute can only be applied to Objective-C instance methods"	 |
| `-Wignored-attributes`	 | "Objective-C GC does not allow weak variables on the stack"	 |
| `-Wignored-attributes`	 | "transparent union definition must contain at least one field transparent_union attribute ignored"	 |
| `-Wignored-attributes`	 | "transparent_union attribute can only be applied to a union definition attribute ignored"	 |
| `-Wignored-attributes`	 | "unknown visibility %0"	 |
| `-Wignored-attributes`	 | "__declspec attribute %0 is not supported"	 |
| `-Wignored-attributes`	 | "__weak attribute cannot be specified on a field declaration"	 |
| `-Wignored-attributes`	 | "__weak attribute cannot be specified on an automatic variable when ARC is not enabled"	 |
| `-Wignored-qualifiers`	 | "'%0' type qualifier%s1 on return type %plural{1:has|:have}1 no effect"	 |
| `-Wignored-qualifiers`	 | "ARC %select{unused|__unsafe_unretained|__strong|__weak|__autoreleasing}0 lifetime qualifier on return type is ignored"	 |
| `-Wimplicit-atomic-properties`	 | "property is assumed atomic by default"	 |
| `-Wimplicit-atomic-properties`	 | "property is assumed atomic when auto-synthesizing the property"	 |
| `-Wimplicit-fallthrough`	 | "fallthrough annotation does not directly precede switch label"	 |
| `-Wimplicit-fallthrough`	 | "fallthrough annotation in unreachable code"	 |
| `-Wimplicit-fallthrough`	 | "unannotated fall-through between switch labels"	 |
| `-Wimplicit-function-declaration`	 | "implicit declaration of function %0"	 |
| `-Wimplicit-function-declaration`	 | "use of unknown builtin %0"	 |
| `-Wimplicit-retain-self, DefaultIgnore`	 |  "block implicitly retains 'self' explicitly mention 'self' to indicate this is intended behavior"	 |
| `-Wincompatible-library-redeclaration`	 | "incompatible redeclaration of library function %0"	 |
| `-Wincomplete-implementation`	 | "method definition for %0 not found"	 |
| `-Winherited-variadic-ctor`	 | "inheriting constructor does not inherit ellipsis"	 |
| `-Winitializer-overrides`	 | "initializer overrides prior initialization of this subobject"	 |
| `-Winitializer-overrides`	 | "subobject initialization overrides initialization of other fields within its enclosing subobject"	 |
| `-Wint-to-pointer-cast`	 | "cast to %1 from smaller integer type %0"	 |
| `-Wint-to-void-pointer-cast`	 | "cast to %1 from smaller integer type %0"	 |
| `-Winvalid-iboutlet`	 | "%select{instance variable|property}2 with %0 attribute must be an object type (invalid %1)"	 |
| `-Winvalid-iboutlet`	 | "IBOutletCollection properties should be copy/strong and not assign"	 |
| `-Winvalid-noreturn`	 | "function %0 declared 'noreturn' should not return"	 |
| `-Winvalid-noreturn`	 | "function declared 'noreturn' should not return"	 |
| `-Wlarge-by-value-copy`	 | "%0 is a large (%1 bytes) pass-by-value argument pass it by reference instead ?"	 |
| `-Wlarge-by-value-copy`	 | "return value of %0 is a large (%1 bytes) pass-by-value object pass it by reference instead ?"	 |
| `-Wliteral-conversion`	 | "implicit conversion from %0 to %1 changes value from %2 to %3"	 |
| `-Wliteral-range`	 | "magnitude of floating-point constant too large for type %0 maximum is %1"	 |
| `-Wliteral-range`	 | "magnitude of floating-point constant too small for type %0 minimum is %1"	 |
| `-Wloop-analysis`	 | "variable %0 is %select{decremented|incremented}1 both in the loop header and in the loop body"	 |
| `-Wloop-analysis`	 | "variable%select{s| %1|s %1 and %2|s %1, %2, and %3|s %1, %2, %3, and %4}0 used in loop condition not modified in loop body"	 |
| `-Wmethod-signatures`	 | "conflicting parameter types in implementation of %0: %1 vs %2"	 |
| `-Wmethod-signatures`	 | "conflicting return type in implementation of %0: %1 vs %2"	 |
| `-Wmicrosoft`	 | "extra qualification on member %0"	 |
| `-Wmismatched-method-attributes`	 | "attributes on method implementation and its declaration must match"	 |
| `-Wmismatched-parameter-types`	 | "conflicting parameter types in implementation of %0%diff{: $ vs $|}1,2"	 |
| `-Wmismatched-return-types`	 | "conflicting return type in implementation of %0%diff{: $ vs $|}1,2"	 |
| `-Wmissing-braces`	 | "suggest braces around initialization of subobject"	 |
| `-Wmissing-field-initializers`	 | "missing field '%0' initializer"	 |
| `-Wmissing-method-return-type`	 | "method has no return type specified defaults to 'id'"	 |
| `-Wmissing-noreturn`	 | "%select{function|method}0 %1 could be declared with attribute 'noreturn'"	 |
| `-Wmissing-noreturn`	 | "block could be declared with attribute 'noreturn'"	 |
| `-Wmissing-prototypes, DefaultIgnore`	 | "no previous prototype for function %0"	 |
| `-Wmissing-variable-declarations, DefaultIgnore`	 | "no previous extern declaration for non-static variable %0"	 |
| `-Wmultiple-move-vbase`	 | "defaulted move assignment operator of %0 will move assign virtual base class %1 multiple times"	 |
| `-Wnon-literal-null-conversion`	 | "expression which evaluates to zero treated as a null pointer constant of " "type %0"	 |
| `-Wnon-pod-varargs`	 | "cannot pass %select{non-POD|non-trivial}0 object of type %1 to variadic %select{function|block|method|constructor}2 expected type from format string was %3"	 |
| `-Wnon-pod-varargs`	 | "cannot pass object of %select{non-POD|non-trivial}0 type %1 through variadic %select{function|block|method|constructor}2 call will abort at runtime"	 |
| `-Wnon-pod-varargs`	 | "second argument to 'va_arg' is of ARC ownership-qualified type %0"	 |
| `-Wnon-pod-varargs`	 | "second argument to 'va_arg' is of non-POD type %0"	 |
| `-Wnon-virtual-dtor`	 | "%0 has virtual functions but non-virtual destructor"	 |
| `-Wnonnull`	 | "null passed to a callee which requires a non-null argument"	 |
| `-WNSObject-attribute`	 | "__attribute ((NSObject)) may be put on a typedef only, attribute is ignored"	 |
| `-Wnull-arithmetic`	 | "comparison between NULL and non-pointer %select{(%1 and NULL)|(NULL and %1)}0"	 |
| `-Wnull-arithmetic`	 | "use of NULL in arithmetic operation"	 |
| `-Wnull-dereference`	 | "indirection of non-volatile null pointer will be deleted, not trap"	 |
| `-Wobjc-autosynthesis-property-ivar-name-match`	 | "autosynthesized property %0 will use %select{|synthesized}1 instance variable %2, not existing instance variable %3"	 |
| `-Wobjc-forward-class-redefinition`	 | "redefinition of forward class %0 of a typedef name of an object type is ignored"	 |
| `-Wobjc-interface-ivars, DefaultIgnore`	 | "declaration of instance variables in the interface is deprecated"	 |
| `-Wobjc-literal-compare`	 | "direct comparison of %select{an array literal|a dictionary literal|a numeric literal|a boxed expression|}0 has undefined behavior"	 |
| `-Wobjc-literal-missing-atsign`	 | "string literal must be prefixed by '@' "	 |
| `-Wobjc-method-access`	 | "class method %objcclass0 not found (return type defaults to 'id') did you mean %objcclass2?"	 |
| `-Wobjc-method-access`	 | "class method %objcclass0 not found (return type defaults to 'id')"	 |
| `-Wobjc-method-access`	 | "instance method %0 found instead of class method %1"	 |
| `-Wobjc-method-access`	 | "instance method %0 is being used on 'Class' which is not in the root class"	 |
| `-Wobjc-method-access`	 | "instance method %objcinstance0 not found (return type defaults to 'id') did you mean %objcinstance2?"	 |
| `-Wobjc-method-access`	 | "instance method %objcinstance0 not found (return type defaults to 'id')"	 |
| `-Wobjc-missing-property-synthesis, DefaultIgnore`	 |  "auto property synthesis is synthesizing property not explicitly synthesized"	 |
| `-Wobjc-missing-super-calls`	 | "method possibly missing a [super %0] call"	 |
| `-Wobjc-noncopy-retain-block-property`	 | "retain'ed block property does not copy the block " "- use copy attribute instead"	 |
| `-Wobjc-nonunified-exceptions`	 | "can not catch an exception thrown with @throw in C++ in the non-unified exception model"	 |
| `-Wobjc-property-implementation`	 | "property %0 requires method %1 to be defined - use @dynamic or provide a method implementation in this category"	 |
| `-Wobjc-property-implementation`	 | "property %0 requires method %1 to be defined - use @synthesize, @dynamic or provide a method implementation in this class implementation"	 |
| `-Wobjc-property-implicit-mismatch`	 |  "primary property declaration is implicitly strong while redeclaration in class extension is weak"	 |
| `-Wobjc-property-matches-cocoa-ownership-rule`	 | "property's synthesized getter follows Cocoa naming convention for returning 'owned' objects"	 |
| `-Wobjc-property-no-attribute`	 | "default property attribute 'assign' not appropriate for non-GC object"	 |
| `-Wobjc-property-no-attribute`	 | "no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed"	 |
| `-Wobjc-property-synthesis`	 | "auto property synthesis will not synthesize property '%0' because it cannot share an ivar with another synthesized property"	 |
| `-Wobjc-property-synthesis`	 | "auto property synthesis will not synthesize property '%0' because it is 'readwrite' but it will be synthesized 'readonly' via another property"	 |
| `-Wobjc-protocol-method-implementation`	 | "category is implementing a method which will also be implemented by its primary class"	 |
| `-Wobjc-protocol-property-synthesis`	 | "auto property synthesis will not synthesize property declared in a protocol"	 |
| `-Wobjc-redundant-literal-use`	 | "using %0 with a literal is redundant"	 |
| `-Wobjc-root-class`	 | "class %0 defined without specifying a base class"	 |
| `-Wobjc-string-compare`	 | "direct comparison of a string literal has undefined behavior"	 |
| `-Wobjc-string-concatenation`	 | "concatenated NSString literal for an NSArray expression - possibly missing a comma"	 |
| `-Wover-aligned`	 | "type %0 requires %1 bytes of alignment and the default allocator only guarantees %2 bytes"	 |
| `-Woverloaded-virtual`	 | "%q0 hides overloaded virtual %select{function|functions}1"	 |
| `-Woverriding-method-mismatch`	 | "conflicting distributed object modifiers on parameter type in declaration of %0"	 |
| `-Woverriding-method-mismatch`	 | "conflicting distributed object modifiers on return type in declaration of %0"	 |
| `-Woverriding-method-mismatch`	 | "conflicting parameter types in declaration of %0%diff{: $ vs $|}1,2"	 |
| `-Woverriding-method-mismatch`	 | "conflicting parameter types in declaration of %0: %1 vs %2"	 |
| `-Woverriding-method-mismatch`	 | "conflicting return type in declaration of %0%diff{: $ vs $|}1,2"	 |
| `-Woverriding-method-mismatch`	 | "conflicting return type in declaration of %0: %1 vs %2"	 |
| `-Woverriding-method-mismatch`	 | "conflicting variadic declaration of method and its implementation"	 |
| `-Wpacked`	 | "packed attribute is unnecessary for %0"	 |
| `-Wpadded`	 | "padding %select{struct|interface|class}0 %1 with %2 %select{byte|bit}3%select{|s}4 to align %5"	 |
| `-Wpadded`	 | "padding %select{struct|interface|class}0 %1 with %2 %select{byte|bit}3%select{|s}4 to align anonymous bit-field"	 |
| `-Wpadded`	 | "padding size of %0 with %1 %select{byte|bit}2%select{|s}3 to alignment boundary"	 |
| `-Wparentheses-equality`	 | "equality comparison with extraneous parentheses"	 |
| `-Wparentheses`	 | "%0 has lower precedence than %1 %1 will be evaluated first"	 |
| `-Wparentheses`	 | "operator '?:' has lower precedence than '%0' '%0' will be evaluated first"	 |
| `-Wparentheses`	 | "using the result of an assignment as a condition without parentheses"	 |
| `-Wpointer-arith`	 | "subtraction of pointers to type %0 of zero size has undefined behavior"	 |
| `-Wpredefined-identifier-outside-function`	 | "predefined identifier is only valid inside function"	 |
| `-Wprivate-extern`	 | "use of __private_extern__ on a declaration may not produce external symbol private to the linkage unit and is deprecated"	 |
| `-Wprotocol-property-synthesis-ambiguity`	 | "property of type %0 was selected for synthesis"	 |
| `-Wprotocol`	 | "method %0 in protocol not implemented"	 |
| `-Wreadonly-iboutlet-property`	 | "readonly IBOutlet property '%0' when auto-synthesized may not work correctly with 'nib' loader"	 |
| `-Wreadonly-setter-attrs`	 | "property attributes '%0' and '%1' are mutually exclusive"	 |
| `-Wreceiver-expr`	 | "receiver type %0 is not 'id' or interface pointer, consider casting it to 'id'"	 |
| `-Wreceiver-forward-class`	 | "receiver type %0 for instance message is a forward declaration"	 |
| `-Wreceiver-is-weak, DefaultIgnore`	 |  "weak %select{receiver|property|implicit property}0 may be unpredictably set to nil"	 |
| `-Wreinterpret-base-class`	 | "'reinterpret_cast' %select{from|to}3 class %0 %select{to|from}3 its %select{virtual base|base at non-zero offset}2 %1 behaves differently from 'static_cast'"	 |
| `-Wreorder`	 | "%select{field|base class}0 %1 will be initialized after %select{field|base}2 %3"	 |
| `-Wrequires-super-attribute`	 | "%0 attribute cannot be applied to %select{methods in protocols|dealloc}1"	 |
| `-Wreturn-stack-address`	 | "address of stack memory associated with local variable %0 returned"	 |
| `-Wreturn-stack-address`	 | "reference to stack memory associated with local variable %0 returned"	 |
| `-Wreturn-stack-address`	 | "returning address of label, which is local"	 |
| `-Wreturn-stack-address`	 | "returning address of local temporary object"	 |
| `-Wreturn-stack-address`	 | "returning reference to local temporary object"	 |
| `-Wreturn-type-c-linkage`	 | "%0 has C-linkage specified, but returns incomplete type %1 which could be incompatible with C"	 |
| `-Wreturn-type-c-linkage`	 | "%0 has C-linkage specified, but returns user-defined type %1 which is incompatible with C"	 |
| `-Wreturn-type`	 | "control may reach end of non-void function"	 |
| `-Wreturn-type`	 | "control reaches end of non-void function"	 |
| `-Wreturn-type`	 | "non-void %select{function|method}1 %0 should return a value", DefaultError	 |
| `-Wsection`	 | "section does not match previous declaration"	 |
| `-Wselector-type-mismatch`	 | "multiple selectors named %0 found"	 |
| `-Wselector`	 | "creating selector for nonexistent method %0"	 |
| `-Wself-assign-field`	 | "assigning %select{field|instance variable}0 to itself"	 |
| `-Wself-assign`	 | "explicitly assigning a variable of type %0 to itself"	 |
| `-Wsentinel`	 | "missing sentinel in %select{function call|method dispatch|block call}0"	 |
| `-Wsentinel`	 | "not enough variable arguments in %0 declaration to fit a sentinel"	 |
| `-Wshadow-ivar`	 | "local declaration of %0 hides instance variable"	 |
| `-Wshadow`	 | "declaration shadows a %select{" "local variable|" "variable in %2|" "static data member of %2|" "field of %2}1"	 |
| `-Wshift-count-negative`	 | "shift count is negative"	 |
| `-Wshift-count-overflow`	 | "shift count = width of type"	 |
| `-Wshift-overflow`	 | "signed shift result (%0) requires %1 bits to represent, but %2 only has %3 bits"	 |
| `-Wshift-sign-overflow, DefaultIgnore`	 | "signed shift result (%0) sets the sign bit of the shift expression's type (%1) and becomes negative"	 |
| `-Wshorten-64-to-32`	 | "implicit conversion loses integer precision: %0 to %1"	 |
| `-Wsign-compare`	 | "comparison of integers of different signs: %0 and %1"	 |
| `-Wsign-conversion`	 | "implicit conversion changes signedness: %0 to %1"	 |
| `-Wsign-conversion`	 | "operand of ? changes signedness: %0 to %1"	 |
| `-Wsizeof-array-argument`	 | "sizeof on array function parameter will return size of %0 instead of %1"	 |
| `-Wsizeof-array-decay`	 | "sizeof on pointer operation will return size of %0 instead of %1"	 |
| `-Wsizeof-pointer-memaccess`	 | "'%0' call operates on objects of type %1 while the size is based on a " "different type %2"	 |
| `-Wsizeof-pointer-memaccess`	 | "argument to 'sizeof' in %0 call is the same pointer type %1 as the %select{destination|source}2 expected %3 or an explicit length"	 |
| `-Wsometimes-uninitialized`	 | "variable %0 is %select{used|captured}1 uninitialized whenever %select{'%3' condition is %select{true|false}4|'%3' loop %select{is entered|exits because its condition is false}4|'%3' loop %select{condition is true|exits because its condition is false}4|switch %3 is taken|its declaration is reached|%3 is called}2"	 |
| `-Wstatic-local-in-inline`	 | "non-constant static local variable in inline function may be different in different files"	 |
| `-Wstatic-self-init`	 | "static variable %0 is suspiciously used within its own initialization"	 |
| `-Wstrict-selector-match`	 | "multiple methods named %0 found"	 |
| `-Wstring-compare`	 | "result of comparison against %select{a string literal|@encode}0 is unspecified (use strncmp instead)"	 |
| `-Wstring-conversion`	 | "implicit conversion turns string literal into bool: %0 to %1"	 |
| `-Wstring-plus-char`	 | "adding %0 to a string pointer does not append to the string"	 |
| `-Wstring-plus-int`	 | "adding %0 to a string does not append to the string"	 |
| `-Wstrlcpy-strlcat-size`	 | "size argument in %0 call appears to be size of the source expected the size of the destination"	 |
| `-Wstrncat-size`	 | "size argument in 'strncat' call appears " "to be size of the source"	 |
| `-Wstrncat-size`	 | "the value of the size argument in 'strncat' is too large, might lead to a " "buffer overflow"	 |
| `-Wstrncat-size`	 | "the value of the size argument to 'strncat' is wrong"	 |
| `-Wsuper-class-method-mismatch`	 | "method parameter type %diff{$ does not match super class method parameter type $|does not match super class method parameter type}0,1"	 |
| `-Wswitch-enum`	 | "%0 enumeration values not explicitly handled in switch: %1, %2, %3..."	 |
| `-Wswitch-enum`	 | "enumeration value %0 not explicitly handled in switch"	 |
| `-Wswitch-enum`	 | "enumeration values %0 and %1 not explicitly handled in switch"	 |
| `-Wswitch-enum`	 | "enumeration values %0, %1, and %2 not explicitly handled in switch"	 |
| `-Wswitch`	 | "%0 enumeration values not handled in switch: %1, %2, %3..."	 |
| `-Wswitch`	 | "case value not in enumerated type %0"	 |
| `-Wswitch`	 | "enumeration value %0 not handled in switch"	 |
| `-Wswitch`	 | "enumeration values %0 and %1 not handled in switch"	 |
| `-Wswitch`	 | "enumeration values %0, %1, and %2 not handled in switch"	 |
| `-Wswitch`	 | "overflow converting case value to switch condition type (%0 to %1)"	 |
| `-Wtautological-compare`	 | "%select{self-|array }0comparison always evaluates to %select{false|true|a constant}1"	 |
| `-Wtautological-compare`	 | "comparison of %0 unsigned%select{| enum}2 expression is always %1"	 |
| `-Wtautological-compare`	 | "comparison of unsigned%select{| enum}2 expression %0 is always %1"	 |
| `-Wtautological-constant-out-of-range-compare`	 | "comparison of constant %0 with expression of type %1 is always %select{false|true}2"	 |
| `-Wthread-safety-analysis`	 | "%select{reading|writing}1 the value pointed to by '%0' requires locking %select{any mutex|any mutex exclusively}1"	 |
| `-Wthread-safety-analysis`	 | "%select{reading|writing}1 variable '%0' requires locking %select{any mutex|any mutex exclusively}1"	 |
| `-Wthread-safety-analysis`	 | "%select{reading|writing}2 the value pointed to by '%0' requires locking %select{'%1'|'%1' exclusively}2"	 |
| `-Wthread-safety-analysis`	 | "%select{reading|writing}2 variable '%0' requires locking %select{'%1'|'%1' exclusively}2"	 |
| `-Wthread-safety-analysis`	 | "calling function '%0' requires %select{shared|exclusive}2 lock on '%1'"	 |
| `-Wthread-safety-analysis`	 | "cannot call function '%0' while mutex '%1' is locked"	 |
| `-Wthread-safety-analysis`	 | "cannot resolve lock expression"	 |
| `-Wthread-safety-analysis`	 | "expecting mutex '%0' to be locked at start of each loop"	 |
| `-Wthread-safety-analysis`	 | "expecting mutex '%0' to be locked at the end of function"	 |
| `-Wthread-safety-analysis`	 | "locking '%0' that is already locked"	 |
| `-Wthread-safety-analysis`	 | "mutex '%0' is locked exclusively and shared in the same scope"	 |
| `-Wthread-safety-analysis`	 | "mutex '%0' is not locked on every path through here"	 |
| `-Wthread-safety-analysis`	 | "mutex '%0' is still locked at the end of function"	 |
| `-Wthread-safety-analysis`	 | "unlocking '%0' that was not locked"	 |
| `-Wthread-safety-attributes`	 | "%0 attribute can only be applied in a context annotated with 'lockable' attribute"	 |
| `-Wthread-safety-attributes`	 | "%0 attribute only applies to %select{fields and global variables|functions and methods|classes and structs}1"	 |
| `-Wthread-safety-attributes`	 | "%0 attribute requires arguments that are class type or point to class type type here is '%1'"	 |
| `-Wthread-safety-attributes`	 | "%0 attribute requires arguments whose type is annotated with 'lockable' attribute type here is '%1'"	 |
| `-Wthread-safety-attributes`	 | "'%0' only applies to pointer types type here is %1"	 |
| `-Wthread-safety-attributes`	 | "ignoring %0 attribute because its argument is invalid"	 |
| `-Wthread-safety-beta`	 | "Thread safety beta warning."	 |
| `-Wthread-safety-precise`	 | "%select{reading|writing}2 the value pointed to by '%0' requires locking %select{'%1'|'%1' exclusively}2"	 |
| `-Wthread-safety-precise`	 | "%select{reading|writing}2 variable '%0' requires locking %select{'%1'|'%1' exclusively}2"	 |
| `-Wthread-safety-precise`	 | "calling function '%0' requires %select{shared|exclusive}2 lock on '%1'"	 |
| `-Wtype-safety`	 | "argument type %0 doesn't match specified '%1' type tag %select{that requires %3|}2"	 |
| `-Wtype-safety`	 | "specified %0 type tag requires a null pointer"	 |
| `-Wtype-safety`	 | "this type tag was not designed to be used with this function"	 |
| `-Wundeclared-selector`	 | "undeclared selector %0 did you mean %1?"	 |
| `-Wundeclared-selector`	 | "undeclared selector %0"	 |
| `-Wundefined-inline`	 | "inline function %q0 is not defined"	 |
| `-Wundefined-internal`	 | "%select{function|variable}0 %q1 has internal linkage but is not defined"	 |
| `-Wundefined-reinterpret-cast`	 | "dereference of type %1 that was reinterpret_cast from type %0 has undefined behavior"	 |
| `-Wundefined-reinterpret-cast`	 | "reinterpret_cast from %0 to %1 has undefined behavior"	 |
| `-Wuninitialized`	 | "block pointer variable %0 is uninitialized when captured by block"	 |
| `-Wuninitialized`	 | "field %0 is uninitialized when used here"	 |
| `-Wuninitialized`	 | "reference %0 is not yet bound to a value when used here"	 |
| `-Wuninitialized`	 | "reference %0 is not yet bound to a value when used within its own initialization"	 |
| `-Wuninitialized`	 | "variable %0 is uninitialized when %select{used here|captured by block}1"	 |
| `-Wuninitialized`	 | "variable %0 is uninitialized when used within its own initialization"	 |
| `-Wunneeded-internal-declaration`	 | "%select{function|variable}0 %1 is not needed and will not be emitted"	 |
| `-Wunneeded-internal-declaration`	 | "'static' function %0 declared in header file should be declared 'static inline'"	 |
| `-Wunneeded-member-function`	 | "member function %0 is not needed and will not be emitted"	 |
| `-Wunreachable-code, DefaultIgnore`	 | "will never be executed"	 |
| `-Wunsequenced`	 | "multiple unsequenced modifications to %0"	 |
| `-Wunsequenced`	 | "unsequenced modification and access to %0"	 |
| `-Wunsupported-friend`	 | "dependent nested name specifier '%0' for friend class declaration is not supported turning off access control for %1"	 |
| `-Wunsupported-friend`	 | "dependent nested name specifier '%0' for friend template declaration is not supported ignoring this friend declaration"	 |
| `-Wunsupported-visibility`	 | "target does not support 'protected' visibility using 'default'"	 |
| `-Wunused-comparison`	 | "%select{equality|inequality}0 comparison result unused"	 |
| `-Wunused-const-variable`	 | "unused variable %0"	 |
| `-Wunused-exception-parameter`	 | "unused exception parameter %0"	 |
| `-Wunused-function`	 | "unused function %0"	 |
| `-Wunused-label`	 | "unused label %0"	 |
| `-Wunused-member-function`	 | "unused member function %0"	 |
| `-Wunused-parameter`	 | "unused parameter %0"	 |
| `-Wunused-private-field`	 | "private field %0 is not used"	 |
| `-Wunused-property-ivar`	 | "ivar %0 which backs the property is not referenced in this property's accessor"	 |
| `-Wunused-result`	 | "ignoring return value of function declared with warn_unused_result attribute"	 |
| `-Wunused-value`	 | "expression result unused should this cast be to 'void'?"	 |
| `-Wunused-value`	 | "expression result unused"	 |
| `-Wunused-value`	 | "ignoring return value of function declared with %0 attribute"	 |
| `-Wunused-variable`	 | "unused variable %0"	 |
| `-Wunused-volatile-lvalue`	 | "expression result unused assign into a variable to force a volatile load"	 |
| `-Wused-but-marked-unused`	 | "%0 was marked unused but was used"	 |
| `-Wuser-defined-literals`	 | "user-defined literal suffixes not starting with '_' are reserved%select{ no literal will invoke this operator|}0"	 |
| `-Wvarargs`	 | "'va_start' has undefined behavior with reference types"	 |
| `-Wvarargs`	 | "second argument to 'va_arg' is of promotable type %0 this va_arg has undefined behavior because arguments will be promoted to %1"	 |
| `-Wvarargs`	 | "second parameter of 'va_start' not last named argument"	 |
| `-Wvector-conversion`	 | "incompatible vector types "%select{\%diff{assigning to $ from $|assigning to different types}0,1|%diff{passing $ to parameter of type $|passing to parameter of different type}0,1|%diff{returning $ from a function with result type $|returning from function with different return type}0,1|%diff{converting $ to type $|converting between types}0,1|%diff{initializing $ with an expression of type $|initializing with expression of different type}0,1|%diff{sending $ to parameter of type $|sending to parameter of different type}0,1|%diff{casting $ to type $|casting between types}0,1}2"	 |
| `-Wvexing-parse`	 | "empty parentheses interpreted as a function declaration"	 |
| `-Wvexing-parse`	 | "parentheses were disambiguated as a function declaration"	 |
| `-Wvisibility`	 | "declaration of %0 will not be visible outside of this function"	 |
| `-Wvisibility`	 | "redefinition of %0 will not be visible outside of this function"	 |
| `-Wvla`	 | "variable length array used"	 |
| `-Wweak-template-vtables, DefaultIgnore`	 | "explicit template instantiation %0 will emit a vtable in every translation unit"	 |
| `-Wweak-vtables, DefaultIgnore`	 | "%0 has no out-of-line virtual method definitions its vtable will be emitted in every translation unit"	 |

* * *

Corrections? Additions? Open a [Pull Request](https://github.com/nshipster/articles/pulls) to submit your change. Any help would be greatly appreciated.
