// MOAssertionTest.m
// MOKit
// AssertionTest
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOKit.h>

int testsRun = 0;
int testsPassed = 0;

void doCTests() {
    BOOL gotAssertion;
    
    // First test the simple C macro
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssert((2==2), @"%d does not equal %@!", 2, @"2");
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssert((2==3), @"%d does not equal %@!", 2, @"3");
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

}

@interface TestA : NSObject {}

- (void)test1;
- (void)test2;

@end

@implementation TestA

+ (id)allocWithZone:(NSZone *)zone {
    MOAbstractClassError(TestA);
    return [super allocWithZone:zone];
}

- (void)test1 {
    MOSubclassResponsibilityError(TestA);
}

- (void)test2 {
    MOSubclassResponsibilityError(TestA);
}

@end

@interface TestB : TestA {}

@end

@implementation TestB

- (void)test1 {
    return;
}

@end

@interface Foo : NSObject {}

- (void)test;

@end

@implementation Foo

- (void)test {
    BOOL gotAssertion;
    NSArray *array = [NSArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *emptyString = @"";
    NSString *nonEmptyString = @"Fred";

    // First test the simple ObjC macro
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssert((2==2), @"%d does not equal %@!", 2, @"2");
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssert((2==3), @"%d does not equal %@!", 2, @"3");
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    // Now the fancier stuff

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertClass(array, NSDictionary /* NSMutableArray */);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertClass(nil, NSMutableArray);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }
    
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertClass(dict, NSDictionary);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertClassOrNil(dict, NSMutableDictionary);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertClassOrNil(nil, NSMutableArray);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertClassOrNil(array, NSDictionary /* NSMutableArray */);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }
    
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertString(nonEmptyString);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertString(nil);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertString(dict);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertStringOrNil(nonEmptyString);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertStringOrNil(nil);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }
    
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertStringOrNil(dict);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyString(nonEmptyString);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyString(nil);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }
    
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyString(dict);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyString(emptyString);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }


    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyStringOrNil(nonEmptyString);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyStringOrNil(nil);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }
    
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyStringOrNil(dict);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertNonEmptyStringOrNil(emptyString);
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertRespondsToSelector(emptyString, @selector(length));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertRespondsToSelector(emptyString, @selector(count));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertRespondsToSelector(nil, @selector(count));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }


    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertRespondsToSelectorOrNil(emptyString, @selector(length));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertRespondsToSelectorOrNil(emptyString, @selector(count));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertRespondsToSelectorOrNil(nil, @selector(count));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertProtocol(emptyString, @protocol(NSCopying));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertProtocol(emptyString, @protocol(NSURLHandleClient));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertProtocol(nil, @protocol(NSURLHandleClient));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertProtocolOrNil(emptyString, @protocol(NSCopying));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertProtocolOrNil(emptyString, @protocol(NSURLHandleClient));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        MOAssertProtocolOrNil(nil, @protocol(NSURLHandleClient));
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    // Now test the abstract errors
    TestA *testerObject = nil;
    
    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        testerObject = [[TestA alloc] init];
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        testerObject = [[TestB alloc] init];
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        [testerObject test1];
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (gotAssertion) {
        NSLog(@"ERROR. Got assertion, but did not expect to on test %d.", testsRun);
    } else {
        testsPassed++;
    }

    gotAssertion = NO;
    testsRun++;
    NS_DURING {
        [testerObject test2];
    } NS_HANDLER {
        gotAssertion = YES;
    } NS_ENDHANDLER
    if (!gotAssertion) {
        NSLog(@"ERROR. Failed to get assertion, but expected to on test %d.", testsRun);
    } else {
        testsPassed++;
    }
    
}

@end

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // First test the simple C macro
    doCTests();
    
    // Now get inside a method impl so we can test the rest.
    Foo *foo = [[Foo alloc] init];
    [foo test];

    NSLog(@"Ran %d tests.  %d passed, %d failed.", testsRun, testsPassed, testsRun - testsPassed);

    [pool release];
    
    return 0;
}


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
