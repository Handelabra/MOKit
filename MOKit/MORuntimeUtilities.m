// MORuntimeUtilities.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MORuntimeUtilities.h>
#import <MOKit/MOAssertions.h>
#import <objc/objc-runtime.h>

// This function is like Foundation's +isSubclassOfClass:, but is used by various runtime utilities instead to avoid sending messages to the test class in case it is not descended from NSObject...
static BOOL _MO_ClassInheritsFromClass(Class descendent, Class ancestor) {
    Class curClass = descendent;

    while (curClass) {
        if (curClass == ancestor) {
            return YES;
        }
        curClass = curClass->super_class;
    }
    return NO;
}

typedef BOOL (*_MOClassTestFunction)(Class c, void *context1, void *context2);

static NSArray *_MOAllClassesSatisfyingTest(_MOClassTestFunction testFunc, void *context1, void *context2) {
    static Class zombieClass = nil;
    static Class oldObjectClass = nil;
    
    NSMutableArray *matchingClasses = [NSMutableArray array];
    int i, numClasses = 0, newNumClasses = objc_getClassList(NULL, 0);
    Class *allClasses = NULL;
    while (numClasses < newNumClasses) {
        numClasses = newNumClasses;
        allClasses = realloc(allClasses, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(allClasses, numClasses);
    }

    if (!zombieClass) {
        zombieClass = NSClassFromString(@"_NSZombie");
    }
    if (!oldObjectClass) {
        oldObjectClass = NSClassFromString(@"Object");
    }
    
    for (i=0; i<numClasses; i++) {
        if (!_MO_ClassInheritsFromClass(allClasses[i], zombieClass) && !_MO_ClassInheritsFromClass(allClasses[i], oldObjectClass)) {
            if (testFunc(allClasses[i], context1, context2)) {
                if ((class_getClassMethod(allClasses[i], @selector(retain)) != NULL) && (class_getClassMethod(allClasses[i], @selector(release)) != NULL)) {
                    [matchingClasses addObject:allClasses[i]];
                }
            }
        }
    }

    free(allClasses);

    return matchingClasses;
}

@implementation NSObject (MORuntimeUtilities)

static BOOL _MOSubclassOfClass(Class theClass, void *ancestorPtr, void *deepPtr) {
    Class ancestor = (Class)ancestorPtr;
    if (theClass == ancestor) {
        return NO;
    }
    if ((unsigned)deepPtr) {
        return _MO_ClassInheritsFromClass(theClass, (Class)ancestorPtr);
    } else {
        return ((theClass->super_class == ancestor) ? YES : NO);
    }
}

+ (NSArray *)MO_allSubclassesIncludingIndirect:(BOOL)deepFlag {
    return _MOAllClassesSatisfyingTest(_MOSubclassOfClass, (void *)self, (void *)((unsigned)deepFlag));
}

+ (IMP)_MO_replaceSelector:(SEL)replaceSel withMethodForSelector:(SEL)newSel isFactory:(BOOL)factoryFlag {
    // Get the existing IMP for the selector to be replaced and the new selector.
    Method origMethod = (factoryFlag ? class_getClassMethod(self, replaceSel) : class_getInstanceMethod(self, replaceSel));
    Method newMethod = (factoryFlag ? class_getClassMethod(self, newSel) : class_getInstanceMethod(self, newSel));

    // Sanity check
    MOAssert((origMethod != NULL), @"%@ - replaceSel must be implemented in order to replace it, but class %@ does not implement selector %s", (factoryFlag ? @"MO_replaceFactorySelector:withMethodForSelector:" : @"MO_replaceInstanceSelector:withMethodForSelector:"), self, replaceSel);
    MOAssert((newMethod != NULL), @"%@ - newSel must be implemented in order to replace another selector with it, but class %@ does not implement selector %s", (factoryFlag ? @"MO_replaceFactorySelector:withMethodForSelector:" : @"MO_replaceInstanceSelector:withMethodForSelector:"), self, newSel);
    // !!!:mferris:20030825 This fails on Panther.  It seems that the Obj-C method signatures have changed.  I suspect maybe Cocoa was built with an earlier (pre-3.3) compiler in the seeds I have been using.  Maybe when Panther is released, this can be re-enabled.  For now, I am simply turning off this test.
    //MOAssert((strcmp(newMethod->method_types, origMethod->method_types) == 0), @"%@ - replaceSel and newSel must have the same signature, but the selectors %s and %s in class %@ have different signatures (%s and %s respectively)", (factoryFlag ? @"MO_replaceFactorySelector:withMethodForSelector:" : @"MO_replaceInstanceSelector:withMethodForSelector:"), replaceSel, newSel, self, origMethod->method_types, newMethod->method_types);

    if (origMethod && newMethod) {
        // Construct a new method list
        struct objc_method_list *newMethodList = NSZoneMalloc(NULL, sizeof(struct objc_method_list));

        newMethodList->method_count = 1;
        newMethodList->method_list[0].method_name = replaceSel;
        newMethodList->method_list[0].method_types = origMethod->method_types;
        newMethodList->method_list[0].method_imp = newMethod->method_imp;

        // Add the new method list (to the meta-class if we're adding factory methods, else to the class itself)
        class_addMethods((factoryFlag ? ((Class)self)->isa : self), newMethodList);
    }

    return (origMethod ? origMethod->method_imp : NULL);
}

+ (IMP)MO_replaceInstanceSelector:(SEL)replaceSel withMethodForSelector:(SEL)newSel {
    return [self _MO_replaceSelector:replaceSel withMethodForSelector:newSel isFactory:NO];
}

+ (IMP)MO_replaceFactorySelector:(SEL)replaceSel withMethodForSelector:(SEL)newSel {
    return [self _MO_replaceSelector:replaceSel withMethodForSelector:newSel isFactory:YES];
}

@end

@implementation NSBundle (MORuntimeUtilities)

static BOOL _MOClassComesFromBundle(Class theClass, void *bundlePtr, void *unused) {
    NSBundle *bundle = (NSBundle *)bundlePtr;
    return (([NSBundle bundleForClass:theClass] == bundle) ? YES : NO);
}

- (NSArray *)MO_allClasses {
    return _MOAllClassesSatisfyingTest(_MOClassComesFromBundle, (void *)self, NULL);
}

@end

@implementation Protocol (MORuntimeUtilities)

static BOOL _MOClassConformsTo(Class theClass, void *protocolPtr, void *unused) {
    Protocol *protocol = (Protocol *)protocolPtr;

    if (_MO_ClassInheritsFromClass(theClass, [NSProxy class])) {
        // NSProxy has a bug.  It does not implement +comformsToProtocol, but it does implement -conformsToProtocol, and since it is a root class -conformsToProtocol therefore acts as a class method as well.  The problem is that the implementation of -conformsToProtocol: on NSProxy is not suitable as a class method.  Returning NO may be a lie, but it is the best we can do...
        return NO;
    }
    return ((class_getClassMethod(theClass, @selector(conformsToProtocol:)) != NULL) && [theClass conformsToProtocol:protocol]);
}

- (NSArray *)MO_allConformingClasses {
    return _MOAllClassesSatisfyingTest(_MOClassConformsTo, (void *)self, NULL);
}

@end

NSString *MOFullMethodName(id self, SEL _cmd) {
    MOParameterAssert(self);
    MOParameterAssert(_cmd);
    if (self == [self class]) {
        return [NSString stringWithFormat:@"+[%@ %@]", self, NSStringFromSelector(_cmd)];
    } else {
        return [NSString stringWithFormat:@"-[%@ %@]", [self class], NSStringFromSelector(_cmd)];
    }
}

static BOOL _MOAllClasses(Class theClass, void *unused1, void *unused2) {
    return YES;
}

NSArray *MOAllClasses() {
    return _MOAllClassesSatisfyingTest(_MOAllClasses, NULL, NULL);
}

static BOOL _MOClassInstancesImplements(Class theClass, void *selectorPtr, void *unused) {
    SEL selector = (SEL)selectorPtr;
    return (class_getInstanceMethod(theClass, selector) != NULL);
}

NSArray *MOAllClassesImplementingInstanceSelector(SEL selector) {
    return _MOAllClassesSatisfyingTest(_MOClassInstancesImplements, (void *)selector, NULL);
}

static BOOL _MOClassFactoryImplements(Class theClass, void *selectorPtr, void *unused) {
    SEL selector = (SEL)selectorPtr;
    return (class_getClassMethod(theClass, selector) != NULL);
}

NSArray *MOAllClassesImplementingFactorySelector(SEL selector) {
    return _MOAllClassesSatisfyingTest(_MOClassFactoryImplements, (void *)selector, NULL);
}

BOOL MOKitAllowsMethodReplacement() {
    static BOOL registered = NO;
    // ---:mferris:20021120 Since this function is likely to be called from +load and therefore be outside of autorelease pool scopes, we'll use our own pool.
    NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if (!registered) {
        NSDictionary *dict = [[NSDictionary allocWithZone:NULL] initWithObjectsAndKeys:@"YES", @"MOKitAllowsMethodReplacement", nil];
        [ud registerDefaults:dict];
        [dict release];
    }
    BOOL result = [ud boolForKey:@"MOKitAllowsMethodReplacement"];
    [pool release];
    
    return result;
}

void MOKitSetAllowsMethodReplacement(BOOL flag) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [ud setObject:(flag ? @"YES" : @"NO") forKey:@"MOKitAllowsMethodReplacement"];
}


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
