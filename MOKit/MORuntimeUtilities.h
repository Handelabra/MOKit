// MORuntimeUtilities.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MORuntimeUtilities
 @discussion Some handy functions and methods that deal with the Objective-C runtime.
 */

#if !defined(__MOKIT_MORuntimeUtilities__)
#define __MOKIT_MORuntimeUtilities__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>
#import <objc/Protocol.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @category NSObject(MORuntimeUtilities)
 @abstract NSObject runtime extension methods.
 @discussion NSObject runtime extension methods.
 */
@interface NSObject (MORuntimeUtilities)

/*!
 @method MO_allSubclassesIncludingIndirect:
 @abstract Returns an array of all the subclasses of the receiving class.
 @discussion Given a flag indicating whether all subclasses or only direct subclasses are wanted, this method returns an array of all the subclasses of the receiving class.  If deepFlag is YES then all descendents of the receiving class are returned, if it is NO only direct subclasses are returned.  The receiving class is NOT returned as part of the result.  This method will not work on non-NSObject including NSProxy and its subclasses or the old Object class and its subclasses.
 @param deepFlag Whether to return all descendents or only direct subclasses.
 @result The array of subclasses.
 */
+ (NSArray *)MO_allSubclassesIncludingIndirect:(BOOL)deepFlag;

/*!
 @method MO_replaceInstanceSelector:withMethodForSelector:
 @abstract Replace an instance method of a class.  Like posing for methods.
 @discussion Given a selector to replace (replaceSel) and a selector to replace it with (newSel), this method will take the IMP of the newSel and make the class use it when replaceSel is invoked.  The original IMP for replaceSel is returned.  Instances of the class must respond to both selectors and the methods for them must have identical method signatures.  The returned original IMP can be stored and invoked from the implementation of the replacement method to allow override-like calls to "super" within the replacing method.  Note that a method could be replaced multiple times and, if all the replacements chain by invoking the original IMP returned by this method, all the methods will execute starting with the last replacement method and ending with the original method that was replaced by the first call to this method. Note also that if, previous to calling this method, a category was loaded that replaced the original class' implementation of the method (a normal "category-override"), then it is the category method's IMP that will be returned as the original IMP.  Finally, note that if a bundle is later loaded with a category override of a method that was previously replaced using this method, the newly loaded category method will take effect, with no chaining, as usual.  +initialize or +load are good places to invoke this method.

 An example might be useful.  This example is simplified from a real use of this API in MOKit's NSView(MOSizing) category.  Let's suppose we want to replace NSView's -setFrameSize: method with a new version, implemented under the name -replacementSetFrameSize: as a category on NSView.  -replacementSetFrameSize: could modify the size and then call NSView's original -setFrameSize: through the returned original IMP.

 First, we need a place to store the original IMP.  Not only that, but we should declare the actual type of the IMP so that arguments and return values will work properly (remember that methods have two initial hidden arguments: self and _cmd):
 <pre><tt>&#32;&#32;&#32;&#32;typedef void (*SetFrameSizePrototype)(id self, SEL _cmd, NSSize newSize);
 &#32;&#32;&#32;&#32;static SetFrameSizePrototype _origSetFrameSizeIMP = NULL;</tt></pre>
 Now we need to implement the replacement method.  In this implementation we just make the new size a bit bigger than requested.  Notice that at the end of the replacement method the original IMP is invoked.  This ensures that the original setFrameSize: gets called and is conceptually similar to calling super in a subclass override (invoking the original IMP does not have to happen at the end of the replacement method just as calling super in an override can be done at any point within the override method):
 <pre><tt>&#32;&#32;&#32;&#32;- (void)replacementSetFrameSize:(NSSize)newSize {
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;newSize.width += 10.0;
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;newSize.height += 10.0;
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;if (_origSetFrameSizeIMP) {
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;_origSetFrameSizeIMP(self, _cmd, newSize);
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;}
&#32;&#32;&#32;&#32;}</tt></pre>
 Finally, we need to perform the actual replacement.  In this case, since we are implementing all this in a category on an existing class, we will use +load to do the replacement.  +load is called separately in every class or category that implements it through special magic in the Objective-C runtime, so even if NSView itself has a +load and we "override" it in this category, both will still be called.
 <pre><tt>&#32;&#32;&#32;&#32;+ (void)load {
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;static _hasReplaced = NO;
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;if (!_hasReplaced) {
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;_hasReplaced = YES;
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;_origSetFrameSizeIMP = (SetFrameSizePrototype)
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;[NSView MO_replaceInstanceSelector:&#64selector(setFrameSize:)
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;withMethodForSelector:&#64selector(replacementSetFrameSize:)];
&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;}
&#32;&#32;&#32;&#32;}</tt></pre>
 Admittedly this is all a bit complicated.  Method replacement of this sort, however, should be used very sparingly and one should always consider more straight-forward alternatives before doing it.  Having said that, this mechanism uses only public API and structures from the Objective-C runtime in its implementation and should be relatively safe if used properly.
 @param replaceSel The selector whose IMP is to be replaced.
 @param newSel The selector whose IMP is to replace the original IMP of replaceSel.
 @result The original IMP for replaceSel.
 */
+ (IMP)MO_replaceInstanceSelector:(SEL)replaceSel withMethodForSelector:(SEL)newSel;

/*!
 @method MO_replaceFactorySelector:withMethodForSelector:
 @abstract Replace a factory (class) method of a class.  Like posing for methods.
 @discussion Given a selector to replace (replaceSel) and a selector to replace it with (newSel), this method will take the IMP of the newSel and make the class use it when replaceSel is invoked.  The original IMP for replaceSel is returned.  The class must respond to both selectors and the methods for them must have identical method signatures.  The returned original IMP can be stored and invoked from the implementation of the replacement method to allow override-like calls to "super" within the replacing method.  Note that a method could be replaced multiple times and, if all the replacements chain by invoking the original IMP returned by this method, all the methods will execute starting with the last replacement method and ending with the original method that was replaced by the first call to this method. Note also that if, previous to calling this method, a category was loaded that replaced the original class' implementation of the method (a normal "category-override"), then it is the category method's IMP that will be returned as the original IMP.  Finally, note that if a bundle is later loaded with a category override of a method that was previously replaced using this method, the newly loaded category method will take effect, with no chaining, as usual.  +initialize or +load are good places to invoke this method.

 See the documentation for +MO_replaceInstanceSelector:withMethodForSelector: for an example of how these methods can be used.
 @param replaceSel The selector whose IMP is to be replaced.
 @param newSel The selector whose IMP is to replace the original IMP of replaceSel.
 @result The original IMP for replaceSel.
 */
+ (IMP)MO_replaceFactorySelector:(SEL)replaceSel withMethodForSelector:(SEL)newSel;

@end

/*!
 @category NSBundle(MORuntimeUtilities)
 @abstract NSBundle runtime extension methods.
 @discussion NSBundle runtime extension methods.
 */
@interface NSBundle (MORuntimeUtilities)

/*!
 @method MO_allClasses
 @abstract Returns an array of all the classes which came from a bundle.
 @discussion This method returns an array of all the classes which came from the receiving bundle.  This method will never return _NSZombie or Object or any subclasses of Object.  It will never return any classes that do not implement +retain and +release.  This method will also never return NSProxy or any of its subclasses due to a bug in NSProxy with +conformsToProtocol:.
 @result The array of classes.
 */
- (NSArray *)MO_allClasses;

@end

/*!
 @category Protocol(MORuntimeUtilities)
 @abstract Protocol runtime extension methods.
 @discussion Protocol runtime extension methods.
 */
@interface Protocol (MORuntimeUtilities)

/*!
 @method MO_allConformingClasses
 @abstract Returns an array of all the classes which conform to the receiving protocol.
 @discussion This method returns an array of all the classes which conform to the receiving protocol.  This method will never return _NSZombie or Object or any subclasses of Object.  It will never return any classes that do not implement +retain and +release.
 @result The array of classes.
 */
- (NSArray *)MO_allConformingClasses;

@end

/*!
 @function MOFullMethodName
 @abstract Pretty-formats a method name.
 @discussion Given an object and a selector (usually passed as "self" and "_cmd"), this returns a pretty-formatted method name, suitable for error or log output.  The result is of the form "-[NSString count]".
 @param self The object used to determine the class for the output.
 @param _cmd The selector used to determine the method for the output.
 @result The pretty-formatted string version of the method name.
 */
MOKIT_EXTERN NSString *MOFullMethodName(id self, SEL _cmd);

/*!
 @function MOAllClasses
 @abstract Returns an array of all the classes currently known to the Objective-C runtime.  This function will never return _NSZombie or Object or any subclasses of Object.  It will never return any classes that do not implement +retain and +release.
 @result The array of classes.
 */
MOKIT_EXTERN NSArray *MOAllClasses();

/*!
 @function MOAllClassesImplementingInstanceSelector
 @abstract Returns an array of all the classes whose instances implement a selector.
 @discussion Given a selector, this function returns an array of all the classes whose instances respond to that selector.  This function will never return _NSZombie or Object or any subclasses of Object.  It will never return any classes that do not implement +retain and +release.
 @param selector The selector.
 @result The array of classes.
 */
MOKIT_EXTERN NSArray *MOAllClassesImplementingInstanceSelector(SEL selector);

/*!
 @function MOAllClassesImplementingFactorySelector
 @abstract Returns an array of all the classes whose factories implement a selector.
 @discussion Given a selector, this function returns an array of all the classes whose factories (class objects) respond to that selector.  This function will never return _NSZombie or Object or any subclasses of Object.  It will never return any classes that do not implement +retain and +release.
 @param selector The selector.
 @result The array of classes.
 */
MOKIT_EXTERN NSArray *MOAllClassesImplementingFactorySelector(SEL selector);

/*!
 @function MOKitAllowsMethodReplacement
 @abstract Returns whether MOKit itself should enable features depending of method replacement.
 @discussion Returns whether MOKit itself should enable features depending of method replacement.  Note that this has no affect on the function of the method replacement API itself.  Clients of MOKit may replace methods as they see fit, but any features of MOKit itself that use method replacement check this function.  The function in turn looks at the value of the MOKitAllowsMethodReplacement user default which is YES by default.  If it is set to NO, then MOKit will disable all method replacement features.
 @result YES if method replacement should be allowed, NO if not.
 */
MOKIT_EXTERN BOOL MOKitAllowsMethodReplacement();

/*!
 @function MOKitSetAllowsMethodReplacement
 @abstract Sets whether MOKit itself should enable features depending of method replacement.
 @discussion Sets whether MOKit itself should enable features depending of method replacement.  Note that this has no affect on the function of the method replacement API itself.  Clients of MOKit may replace methods as they see fit, but any features of MOKit itself that use method replacement will obey this setting.  The function sets the value of the MOKitAllowsMethodReplacement user default which is YES by default.  If it is set to NO, then MOKit will disable all method replacement features.

 Note that since method replacement takes place at launch time for applications linked with MOKit and that it is not easily undoable, changes to this setting will take effect only the next time the application is launched.
 @param flag YES if method replacement should be allowed, NO if not.
 */
MOKIT_EXTERN void MOKitSetAllowsMethodReplacement(BOOL flag);

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MORuntimeUtilities__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
