// MOAssertions.h
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOAssertions
 @discussion A replacement for the assertion macros in NSException.h.  This replacement has several improvements.  First, it takes advantage of the fact that vararg macros are now supported by both available preprocessors for gcc on OS X to remove the need for the MOAssert1, MOAssert2, etc...  style of multiple macros.  Second, it provides a funnel function that can be used to set a breakpoint that will catch any assertion prior to it being handed off to the current handler which can be very useful for debugging.  Third, the MOAssertionHandler class allows the current handler to be set (which NSAssertionHan dler has no public API for).  Finally convenience macros for testing certain properties such as isKindOf, conformance to protocol, etc are provided. 
 */

// The header is kind of convoluted, the main primitive macro intended for direct use is:
//     MOAssert(condition, NSString *description, ...) - general form, the primitive assertion macro
//
// In addition there are convenience macros for specific kinds of asserts
//     MOParameterAssert(condition) - uses a boiler-plate "bad argument" description
//     MOPreconditionAssert(condition) - uses a boiler-plate "broken precondition" description
//     MOPostconditionAssert(condition) - uses a boiler-plate "broken postcondition" description
//     MOInvariantAssert(condition) - uses a boiler-plate "broken invariant" description
//
//   (in all the above macros "condition" should be a boolean conditional suitable for use inside
//    the parens of an "if" statement)
//
// Other convenience macros perform common canned tests:
//     MOAssertClass(id object, Class class) - Asserts object is not nil and of type class
//     MOAssertClassOrNil(id object, Class class) - Asserts object is of type class (nil OK)
//     MOAssertString(id object) - Asserts object is not nil and of type NSString
//     MOAssertStringOrNil(id object) - Asserts object is of type NSString (nil OK)
//     MOAssertNonEmptyString(id object) - Asserts object is not nil and of type NSString and is not the empty string
//     MOAssertNonEmptyStringOrNil(id object) - Asserts object is of type NSString and is not the empty string (nil OK)
//     MOAssertRespondsToSelector(id object, SEL selector) - Asserts object is not nil and responds to selector
//     MOAssertRespondsToSelectorOrNil(id object, SEL selector) - Asserts object is responds to selector (nil OK)
//     MOAssertProtocol(id object, Protocol *protocol) - Asserts object is not nil and conforms to protocol
//     MOAssertProtocolOrNil(id object, Protocol *protocol) - Asserts object is conforms to protocol (nil OK)
//     MOAbstractClassError(Class class) - Asserts if self is an instance of class.  class should be the abstract superclass.
//
// Finally a few macros are provided whose conditions always fail and are used to indicate errors.
//     MOSubclassResponsibilityError(Class class) - Always asserts.  class should be the abstract superclass.
//     MOError(NSString *description, ...) - always asserts (no condition), you supply the error message
//     MOWarning(NSString *description, ...) - emits warning message, but does not assert/raise

#if !defined(__MOKIT_MOAssertions__)
#define __MOKIT_MOAssertions__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif

    
/*!
 @function MOHandleAssertionFailure
 @abstract Funnel function for MOAssertion macros.  Good for breakpoints.
 @discussion This is the funnel point for assertion failures.  You never call it directly, but it can be useful for setting breakpoints.  The implementation uses +[MOAssertionHandler currentHandler] to get the current assertion handler and sends it either -handleFailureInMethod:object:file:lineNumber:description:arguments: if selector is non-NULL or -handleFailureInFunction:file:lineNumber:description:arguments: if selector is NULL.
 @param raise If this is YES then the call represents a real assertion.  Otherwise it represent a request for simply logging an error message.
 @param selector If the assertion came from a method, this is the selector of the method (_cmd).  If it came from a function this will be NULL.
 @param object If the assertion came from a method, this is the receiver of the method (self).  If it came from a function this will be nil.
 @param functionName This is the value of the compiler macro __PRETTY_FUNCTION__ in the scope the assertion came from.
 @param fileName This is the value of the compiler macro __FILE__ in the scope the assertion came from.
 @param line This is the value of the compiler macro __LINE__ in the scope the assertion came from.
 @param format An +[NSString stringWithFormat:]-style format string.  The remaining arguments are the replacement arguments for any % directives in the format string.
 */
MOKIT_EXTERN void MOHandleAssertionFailure(BOOL raise, SEL selector, id object, const char *functionName, const char *fileName, unsigned line, NSString *format, ...);


#ifndef MO_BLOCK_ASSERTS

// Define self and _cmd so they will have nil values outside method bodies.
const static id self __attribute__ ((unused)) = nil;
const static SEL _cmd __attribute__ ((unused)) = NULL;

/*!
 @define MOAssert
 @abstract Primitive assertion macro.
 @discussion It is the primitive assertion macro.  All the other assertion macros wind up invoking this macro one or more times.  If MO_BLOCK_ASSERTS is defined, this macro does nothing, otherwise if _condition_ is false it calls MOHandleAssertionFailure().  The macro takes a variable number of arguments:

 _condition_: The conditional expression being asserted.  This can be any expression that is legal within the parens of an if () statement. 

 _desc_: The description or format string for the assertion.  Any additional arguments (_args_) are replacement arguments for % directives in the format string.
 */
#define MOAssert(_condition_, _desc_, _args_...) \
do { \
    if (!(_condition_)) { \
        MOHandleAssertionFailure(YES, _cmd, self, __PRETTY_FUNCTION__, __FILE__, __LINE__, (_desc_), ## _args_); \
    } \
} while(0)

/*!
 @define MOParameterAssert
 @abstract A convenience assertion with a canned message for invalid parameters.
 @discussion This macro simply asserts the given _condition_ with a description that indicates that failure implies a bad parameter being passed to a function or method.  The condition itself is included in the message.  The macro takes one argument:

 _condition_: The conditional expression being asserted.  This can be any expression that is legal within the parens of an if () statement. 
 */
#define MOParameterAssert(_condition_) \
MOAssert((_condition_), @"Invalid parameter not satisfying: %s", #_condition_)

/*!
 @define MOPreconditionAssert
 @abstract A convenience assertion with a canned message for preconditions.
 @discussion This macro simply asserts the given _condition_ with a description that indicates that failure implies a broken precondition.  The condition itself is included in the message.  The macro takes one argument:

 _condition_: The conditional expression being asserted.  This can be any expression that is legal within the parens of an if () statement.
 */
#define MOPreconditionAssert(_condition_) \
MOAssert((_condition_), @"Precondition broken: %s", #_condition_)

/*!
 @define MOPostconditionAssert
 @abstract A convenience assertion with a canned message for postconditions.
 @discussion This macro simply asserts the given _condition_ with a description that indicates that failure implies a broken postcondition.  The condition itself is included in the message.  The macro takes one argument:

 _condition_: The conditional expression being asserted.  This can be any expression that is legal within the parens of an if () statement.
 */
#define MOPostconditionAssert(_condition_) \
MOAssert((_condition_), @"Postcondition broken: %s", #_condition_)

/*!
 @define MOInvariantAssert
 @abstract A convenience assertion with a canned message for invariants.
 @discussion This macro simply asserts the given _condition_ with a description that indicates that failure implies a broken invariant.  The condition itself is included in the message.  The macro takes one argument:

 _condition_: The conditional expression being asserted.  This can be any expression that is legal within the parens of an if () statement.
 */
#define MOInvariantAssert(_condition_) \
MOAssert((_condition_), @"Invariant broken: %s", #_condition_)

/*!
 @define MOAssertClass
 @abstract Assert an object is a kind of class.
 @discussion This macro makes two assertions:  first that _object_ is not nil, and second that [_object_ isKindOfClass:_class_].  The macro takes two arguments:

 _object_: The _object being tested.

 _class_: The class that the object is required to be a kind of.
 */
#define MOAssertClass(_object_, _class_) \
do { \
    Class cls = [_class_ class]; \
    id obj = (_object_); \
    MOAssert((obj != nil), @"%s should be an object of class %@, but it is nil.", #_object_, NSStringFromClass(cls)); \
    MOAssert(([obj isKindOfClass:cls]), @"%s should be an object of class %@, but it is of class %@.", #_object_, NSStringFromClass(cls), NSStringFromClass([obj class])); \
} while(0)

/*!
 @define MOAssertClassOrNil
 @abstract Assert an object is nil or a kind of class.
 @discussion This macro asserts that _object_ is either nil or that [_object_ isKindOfClass:_class_].  The macro takes two arguments:

 _object_: The _object being tested.

 _class_: The class that the object is required to be a kind of.
 */
#define MOAssertClassOrNil(_object_, _class_) \
do { \
    Class cls = [_class_ class]; \
    id obj = (_object_); \
    MOAssert((obj == nil || [obj isKindOfClass:cls]), @"%s should be an object of class %@, but it is of class %@.", #_object_, NSStringFromClass(cls), NSStringFromClass([obj class])); \
} while(0)

/*!
 @define MOAssertString
 @abstract Assert an object is a string.
 @discussion This macro makes two assertions:  first that _object_ is not nil, and second that [_object_ isKindOfClass:[NSString class]].  The macro takes one argument:

 _object_: The _object being tested.
 */
#define MOAssertString(_object_) \
do { \
    Class cls = [NSString class]; \
    id obj = (_object_); \
    MOAssert((obj != nil), @"%s should be an NSString, but it is nil.", #_object_); \
    MOAssert(([obj isKindOfClass:cls]), @"%s should be an NSString, but it is of class %@.", #_object_, NSStringFromClass([obj class])); \
} while(0)

/*!
@define MOAssertStringOrNil
 @abstract Assert an object is nil or a string.
 @discussion This macro asserts that _object_ is either nil, or that [_object_ isKindOfClass:[NSString class]].  The macro takes one argument:

 _object_: The _object being tested.
 */
#define MOAssertStringOrNil(_object_) \
do { \
    Class cls = [NSString class]; \
    id obj = (_object_); \
    MOAssert((obj == nil || [obj isKindOfClass:cls]), @"%s should be an NSString, but it is of class %@.", #_object_, NSStringFromClass([obj class])); \
} while(0)

/*!
 @define MOAssertNonEmptyString
 @abstract Assert an object is a non-empty string.
 @discussion This macro makes three assertions:  first that _object_ is not nil, second that [_object_ isKindOfClass:[NSString class]], and finally that _object_ is not equal to the empty string.  The macro takes one argument:

 _object_: The _object being tested.
 */
#define MOAssertNonEmptyString(_object_) \
do { \
    Class cls = [NSString class]; \
    id obj = (_object_); \
    MOAssert((obj != nil), @"%s should be a non-empty NSString, but it is nil.", #_object_); \
    MOAssert(([obj isKindOfClass:cls]), @"%s should be a non-empty NSString, but it is of class %@.", #_object_, NSStringFromClass([obj class])); \
    MOAssert((![obj isEqualToString:@""]), @"%s should be a non-empty NSString, but it is empty.", #_object_); \
} while(0)

/*!
 @define MOAssertNonEmptyStringOrNil
 @abstract Assert an object is nil or a non-empty string.
 @discussion This macro makes two assertions:  first that _object_ is either nil or [_object_ isKindOfClass:[NSString class]], and second that _object_ is not equal to the empty string (if it is non-nil).  The macro takes one argument:

 _object_: The _object being tested.
 */
#define MOAssertNonEmptyStringOrNil(_object_) \
do { \
    Class cls = [NSString class]; \
    id obj = (_object_); \
    MOAssert((obj == nil || [obj isKindOfClass:cls]), @"%s should be a non-empty NSString, but it is of class %@.", #_object_, NSStringFromClass([obj class])); \
    MOAssert((obj == nil || ![obj isEqualToString:@""]), @"%s should be a non-empty NSString, but it is empty.", #_object_); \
} while(0)

/*!
 @define MOAssertRespondsToSelector
 @abstract Assert an object responds to a selector.
 @discussion This macro makes two assertions:  first that _object_ is not nil, and second that [_object_ respondsToSelector:_selector_].  The macro takes two arguments:

 _object_: The object being tested.

 _selector_: The selector it is being asserted to implement.
 */
#define MOAssertRespondsToSelector(_object_, _selector_) \
do { \
    SEL sel = _selector_; \
    id obj = (_object_); \
    MOAssert((obj != nil), @"%s should be an object responding to %@, but it is nil.", #_object_, NSStringFromSelector(sel)); \
    MOAssert(([obj respondsToSelector:sel]), @"%s should be an object responding to %@, but it does not.", #_object_, NSStringFromSelector(sel)); \
} while(0)

/*!
 @define MOAssertRespondsToSelectorOrNil
 @abstract Assert an object is nil or responds to a selector.
 @discussion This macro asserts that _object_ is either nil or that [_object_ respondsToSelector:_selector_].  The macro takes two arguments:

 _object_: The object being tested.

 _selector_: The selector it is being asserted to implement.
 */
#define MOAssertRespondsToSelectorOrNil(_object_, _selector_) \
do { \
    SEL sel = _selector_; \
    id obj = (_object_); \
    MOAssert((obj == nil || [obj respondsToSelector:sel]), @"%s should be an object responding to %@, but it does not.", #_object_, NSStringFromSelector(sel)); \
} while(0)

/*!
 @define MOAssertProtocol
 @abstract Assert an object conforms to a protocol.
 @discussion This macro makes two assertions:  first that _object_ is not nil, and second that [_object_ conformsToProtocol:_protocol_].  The macro takes two arguments:

 _object_: The object being tested.

 _protocol_: The protocol it is being asserted to conform to.
 */
#define MOAssertProtocol(_object_, _protocol_) \
do { \
    Protocol *proto = (_protocol_); \
    id obj = (_object_); \
    MOAssert((obj != nil), @"%s should be an object conforming to %s, but it is nil.", #_object_, #_protocol_); \
    MOAssert(([obj conformsToProtocol:proto]), @"%s should be an object conforming to %s, but it does not.", #_object_, #_protocol_); \
} while(0)

/*!
 @define MOAssertProtocolOrNil
 @abstract Assert an object is nil or conforms to a protocol.
 @discussion This macro asserts that _object_ is either nil or that [_object_ conformsToProtocol:_protocol_].  The macro takes two arguments:

 _object_: The object being tested.

 _protocol_: The protocol it is being asserted to conform to.
 */
#define MOAssertProtocolOrNil(_object_, _protocol_) \
do { \
    Protocol *proto = (_protocol_); \
    id obj = (_object_); \
    MOAssert((obj == nil || [obj conformsToProtocol:proto]), @"%s should be an object conforming to %s, but it does not.", #_object_, #_protocol_); \
} while(0)

/*!
 @define MOAbstractClassError
 @abstract Used to indicate an attempt to instantiate an abstract class.
 @discussion This macro causes an assertion failure if self is an instance of class.  It is used to indicate that someone is trying to instantiate an abstract class.  Usually it is called from an override of +allocWithZone: after the override has determined that the class being allocated is abstract.  The macro takes one argument:

 _class_: The abstract class.  Generally this is the class whose implementation is invoking the macro.
 */
#define MOAbstractClassError(_class_) \
do { \
    Class cls = [_class_ class]; \
    MOAssert(([self class] != cls), @"Error. Attempt to instantiate abstract class %@.", NSStringFromClass(cls)); \
} while(0)

/*!
 @define MOSubclassResponsibilityError
 @abstract Used to indicate a subclass responsibility that has not been fulfilled.
 @discussion This macro always causes an assertion failure.  It is used to indicate that subclass responsibility that has not been fulfilled.  Usually it is called from an abstract class' implementation of a method that must be overridden by all subclasses.  The macro takes one argument:

 _class_: The abstract class.  Generally this is the class whose implementation is invoking the macro.
 */
#define MOSubclassResponsibilityError(_class_) \
do { \
    Class cls = [_class_ class]; \
    MOAssert(0, @"Error. The method %@ must be overridden by subclasses of %@.", NSStringFromSelector(_cmd), NSStringFromClass(cls)); \
} while(0)

/*!
 @define MOError
 @abstract Used to cause an unconditional assertion failure.
 @discussion This macro always causes an assertion failure.  It takes a format string and printf-style arguments for the format string.  The macro takes a variable number of arguments:

 _desc_: The description or format string for the assertion.  Any additional arguments (_args_) are replacement arguments for % directives in the format string.
 */
#define MOError(_desc_, _args_...) \
do { \
    MOHandleAssertionFailure(YES, _cmd, self, __PRETTY_FUNCTION__, __FILE__, __LINE__, (_desc_), ## _args_); \
} while(0)

/*!
 @define MOWarning
 @abstract Used to indicate a subclass responsibility that has not been fulfilled.
 @discussion This macro never causes an assertion failure.  It simply logs an error message.  The macro takes a variable number of arguments:

 _desc_: The description or format string for the assertion.  Any additional arguments (_args_) are replacement arguments for % directives in the format string.
 */
#define MOWarning(_desc_, _args_...) \
do { \
    MOHandleAssertionFailure(NO, _cmd, self, __PRETTY_FUNCTION__, __FILE__, __LINE__, (_desc_), ## _args_); \
} while(0)

#else

#define MOAssert(_condition_, _desc_, _args_...)
#define MOParameterAssert(_condition_)
#define MOPreconditionAssert(_condition_)
#define MOPostconditionAssert(_condition_)
#define MOInvariantAssert(_condition_)
#define MOAssertClass(_object_, _class_)
#define MOAssertClassOrNil(_object_, _class_)
#define MOAssertString(_object_)
#define MOAssertStringOrNil(_object_)
#define MOAssertNonEmptyString(_object_)
#define MOAssertNonEmptyStringOrNil(_object_)
#define MOAssertRespondsToSelector(_object_, _selector_)
#define MOAssertRespondsToSelectorOrNil(_object_, _selector_)
#define MOAssertProtocol(_object_, _protocol_)
#define MOAssertProtocolOrNil(_object_, _protocol_)
#define MOAbstractClassError(_class_)
#define MOSubclassResponsibilityError(_class_)
#define MOError(_desc_, _args_...)
#define MOWarning(_desc_, _args_...)

#endif

/*!
 @class MOAssertionHandler
 @abstract Handler class for the MOAssertions macros and functions.
 @discussion An instance of MOAssertionHandler is used to implement policy for handling assertion failures. A single shared instance is created when needed, or an instance can be set to be used as the shared instance. The default instance created is directly of the class MOAssertionHandler, but subclasses can be created and instances of them used to alter the default handling policies. The default policy for an assertion failure is to log a message about it and then raise an exception.
 */
@interface MOAssertionHandler : NSObject {
    @private
    void *_reserved;
}

/*!
 @method currentHandler
 @abstract Returns the current assertion handler.
 @discussion Returns the current assertion handler. If no assertion handler has been set using +setCurrentHandler: then this method will create an instance of MOAssertionHandler to use as the current handler and return it.
 @result The current assertion handler.
 */
+ (MOAssertionHandler *)currentHandler;

/*!
 @method setCurrentHandler:
 @abstract Sets the current assertion handler.
 @discussion Sets the current assertion handler. If there was a previous handler it is released and the new one takes its place.
 @param handler The new assertion handler.
 */
+ (void)setCurrentHandler:(MOAssertionHandler *)handler;

/*!
 @method handleFailureWithRaise:inMethod:object:file:lineNumber:description:arguments:
 @abstract Primitive funnel for assertions from method bodies.
 @discussion This method is the primitive funnel for assertions from method bodies.  This is the handler method that ultimately gets called when an assertion fails within an Objective-C method body.  Subclasses wishing to implement a new policy for handling assertion failures should override this method and also -handleFailureInFunction:file:lineNumber:description:arguments:.
 @param raise Whether to actually raise an exception or just log an error.
 @param selector The selector of the method the assertion came from.
 @param object The receiving object of the method the assertion came from.
 @param fileName The source file name containing the method the assertion came from.
 @param line The line number from the source file where the assertion came from.
 @param format A +stringWithFormat: style format string giving the message of the assertion.
 @param args The varargs list of replacement arguments for the format string.
 */
- (void)handleFailureWithRaise:(BOOL)raise inMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format arguments:(va_list)args;

/*!
 @method handleFailureWithRaise:inFunction:file:lineNumber:description:arguments:
 @abstract Primitive funnel for assertions from function bodies.
 @discussion This method is the primitive funnel for assertions from function bodies.  This is the handler method that ultimately gets called when an assertion fails within a C function body (or a C++ method).  Subclasses wishing to implement a new policy for handling assertion failures should override this method and also -handleFailureInMethod:object:file:lineNumber:description:arguments:.
 @param raise Whether to actually raise an exception or just log an error.
 @param functionName The name of the function the assertion came from.
 @param fileName The source file name containing the function the assertion came from.
 @param line The line number from the source file where the assertion came from.
 @param format A +stringWithFormat: style format string giving the message of the assertion.
 @param args The varargs list of replacement arguments for the format string.
 */
- (void)handleFailureWithRaise:(BOOL)raise inFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format arguments:(va_list)args;

/*!
 @method handleFailureWithRaise:inMethod:object:file:lineNumber:description:...
 @abstract Varargs convenience method for assertions from method bodies.
 @discussion Varargs convenience method for assertions from method bodies. This simply does the varargs magic and calls -handleFailureInMethod:object:file:lineNumber:description:arguments:.
 @param raise Whether to actually raise an exception or just log an error.
 @param selector The selector of the method the assertion came from.
 @param object The receiving object of the method the assertion came from.
 @param fileName The source file name containing the method the assertion came from.
 @param line The line number from the source file where the assertion came from.
 @param format A +stringWithFormat: style format string giving the message of the assertion. The rest of the arguments are replacement arguments for the format string.
 */
- (void)handleFailureWithRaise:(BOOL)raise inMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format, ...;

/*!
 @method handleFailureWithRaise:inFunction:file:lineNumber:description:...
 @abstract Varargs convenience method for assertions from function bodies.
 @discussion Varargs convenience method for assertions from function bodies. This simply does the varargs magic and calls -handleFailureInFunction:file:lineNumber:description:arguments:.
 @param raise Whether to actually raise an exception or just log an error.
 @param functionName The name of the function the assertion came from.
 @param fileName The source file name containing the function the assertion came from.
 @param line The line number from the source file where the assertion came from.
 @param format A +stringWithFormat: style format string giving the message of the assertion. The rest of the arguments are replacement arguments for the format string.
 */
- (void)handleFailureWithRaise:(BOOL)raise inFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format, ...;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOAssertions__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
