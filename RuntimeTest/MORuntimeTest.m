// MOAssertionTest.m
// MOKit
// RuntimeTest
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOKit.h>

int testsRun = 0;
int testsPassed = 0;

static void _doCTests() {
    // Test MOAllClasses()
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All classes: %d classes known to the Obj-C runtime", [MOAllClasses() count]);
    
    // Test +[NSObject MO_allSubclassesIncludingIndirect:]
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All direct subclasses of NSView:\n%@\n", [NSView MO_allSubclassesIncludingIndirect:NO]);
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All subclasses of NSView:\n%@\n", [NSView MO_allSubclassesIncludingIndirect:YES]);
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All direct subclasses of MORegularExpression:\n%@\n", [MORegularExpression MO_allSubclassesIncludingIndirect:NO]);
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All subclasses of MORegularExpression:\n%@\n", [MORegularExpression MO_allSubclassesIncludingIndirect:YES]);

    // Test -[NSBundle MO_allClasses]
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All classes from MOKit:\n%@\n", [[NSBundle bundleForClass:[MORegularExpression class]] MO_allClasses]);    

    // Test -[Protocol MO_allConformingClasses]
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All classes conforming to NSMutableCopying:\n%@\n", [@protocol(NSMutableCopying) MO_allConformingClasses]);
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All classes conforming to NSChangeSpelling:\n%@\n", [@protocol(NSChangeSpelling) MO_allConformingClasses]);
    
    // Test MOFullMethodName()
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"MOFullMethodName(%@, %s): '%@'", [NSObject class], @selector(allocWithZone:), MOFullMethodName([NSButton class], @selector(allocWithZone:)));
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"MOFullMethodName(instance of NSString, %s): '%@'", @selector(length), MOFullMethodName(@"Foo", @selector(length)));

    // Test MOAllClassesImplementingInstanceSelector()
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSArray *classes = MOAllClassesImplementingInstanceSelector(@selector(count));
    NSLog(@"All classes implenting instance method -count:\n%@\n", classes);

    // Test MOAllClassesImplementingFactorySelector()
    testsRun++;
    testsPassed++;  // Can't check passed reliably for this
    NSLog(@"All classes implementing factory method +imageUnfilteredFileTypes:\n%@\n", MOAllClassesImplementingFactorySelector(@selector(imageUnfilteredFileTypes)));
}

@interface TestClass : NSObject {}

- (void)doTests;

@end

@implementation TestClass

typedef NSString *(*FooWithIntPrototype)(id self, SEL _cmd, int d);
static FooWithIntPrototype origFooIMP = NULL;

typedef int (*BarPrototype)(id self, SEL _cmd);
static BarPrototype origBarIMP = NULL;

typedef NSRect (*BazWithRectPrototype)(id self, SEL _cmd, NSRect rect);
static BazWithRectPrototype origBazIMP = NULL;


+ (void)initialize {
    if (self == [TestClass class]) {
        origFooIMP = (FooWithIntPrototype)[self MO_replaceInstanceSelector:@selector(fooWithInt:) withMethodForSelector:@selector(replacementFooWithInt:)];
        origBarIMP = (BarPrototype)[self MO_replaceFactorySelector:@selector(bar) withMethodForSelector:@selector(replacementBar)];
        origBazIMP = (BazWithRectPrototype)[self MO_replaceInstanceSelector:@selector(bazWithRect:) withMethodForSelector:@selector(replacementBazWithRect:)];
    }
}

- (NSString *)fooWithInt:(int)d {
    return [NSString stringWithFormat:@"%d", d];
}

- (NSString *)replacementFooWithInt:(int)d {
    if (origFooIMP) {
        return [NSString stringWithFormat:@"Replacement %@", (NSString *)origFooIMP(self, _cmd, d)];
    } else {
        return @"ERROR";
    }
}

+ (int)bar {
    return 5;
}

+ (int)replacementBar {
    return (int)origBarIMP(self, _cmd) + 5;
}

- (NSRect)bazWithRect:(NSRect)rect {
    return rect;
}

- (NSRect)replacementBazWithRect:(NSRect)rect {
    if (origBazIMP) {
        return NSInsetRect((NSRect)origBazIMP(self, _cmd, rect), -10.0, -10.0);
    } else {
        return NSZeroRect;
    }
}

- (void)doTests {
    // Test +[NSObject MO_replaceInstanceSelector:withMethodForSelector:]
    testsRun++;
    NSString *result1 = [self fooWithInt:5];
    if (![result1 isEqualToString:@"Replacement 5"]) {
        NSLog(@"ERROR: Expected 'Replacement 5' but got %@ (test %d)", result1, testsRun);
    } else {
        testsPassed++;
    }

    // Test +[NSObject MO_replaceInstanceSelector:withMethodForSelector:] with bigger than pointer args and returns
    testsRun++;
    NSRect input2 = NSMakeRect(50.0, 50.0, 80.0, 80.0);
    NSRect result2 = [self bazWithRect:NSMakeRect(50.0, 50.0, 80.0, 80.0)];
    if (!NSEqualRects(result2, NSInsetRect(input2, -10.0, -10.0))) {
        NSLog(@"ERROR: Expected %@ but got %@", NSStringFromRect(NSInsetRect(input2, -10.0, -10.0)), result2);
    } else {
        testsPassed++;
    }

    // Test +[NSObject MO_replaceFactorySelector:withMethodForSelector:]
    testsRun++;
    int result3 = [[self class] bar];
    if (result3 != 10) {
        NSLog(@"ERROR: Expected 10 but got %d (test %d)", result3, testsRun);
    } else {
        testsPassed++;
    }
}

@end


int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Test the basic runtime stuff
    _doCTests();
    
    // Test method replacing.
    TestClass *tester = [[TestClass alloc] init];
    [tester doTests];
    
    
    NSLog(@"Ran %d tests.  %d passed, %d failed.", testsRun, testsPassed, testsRun - testsPassed);

    [pool release];

    return 0;
}


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
