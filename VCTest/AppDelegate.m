// AppDelegate.m
// MOKit
// VCTest
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import "AppDelegate.h"
#import "TestController.h"

@implementation AppDelegate

- (MOTabViewController *)testTabControllerAtOrigin:(NSPoint)origin {
    TestController *testController;
    MOTabViewController *tabController;
    
    NSLog(@"Creating tab controller");
    tabController = [[MOTabViewController alloc] init];

    NSLog(@"Creating tab test controller 1");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Foo"];
    [testController setValue2:@"Foo"];
    [testController setValue3:@"Foo"];
    [testController setValue4:@"Foo"];
    [tabController addSubcontroller:testController];
    [testController release];

    NSLog(@"Setting label on tab test controller 4");
    [testController setLabel:@"Foo"];

    NSLog(@"Creating tab test controller 2");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Bar"];
    [testController setValue2:@"Bar"];
    [testController setValue3:@"Bar"];
    [testController setValue4:@"Bar"];
    [tabController addSubcontroller:testController];
    [testController release];

    NSLog(@"Setting label on tab test controller 4");
    [testController setLabel:@"Bar"];

    NSLog(@"Creating tab test controller 3");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Baz"];
    [testController setValue2:@"Baz"];
    [testController setValue3:@"Baz"];
    [testController setValue4:@"Baz"];
    [tabController addSubcontroller:testController];
    [testController release];

    NSLog(@"Setting label on tab test controller 4");
    [testController setLabel:@"Baz"];

    NSLog(@"Giving tab controller a window");
    [tabController setWantsOwnWindow:YES];
    NSLog(@"Setting label on tab controller");
    [tabController setLabel:@"BAD LABEL"];
    NSLog(@"Showing tab controller window");
    if(!NSEqualPoints(origin, NSZeroPoint))
        [[[tabController windowController] window] setFrameOrigin:origin];
    [[tabController windowController] setShouldCascadeWindows:YES];
    [tabController showWindow:self];

    [tabController setLabel:@"Testing Tab Controller"];
    

    NSLog(@"Creating tab test controller 4");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Boom"];
    [testController setValue2:@"Boom"];
    [testController setValue3:@"Boom"];
    [testController setValue4:@"Boom"];
    [tabController addSubcontroller:testController];
    [testController release];
    
    NSLog(@"Setting label on tab test controller 4");
    [testController setLabel:@"Boom"];

    NSLog(@"Removing tab test controller 2");
    [tabController removeSubcontrollerAtIndex:1];

    [tabController setAllowsSubcontrollerDragging:YES];
    [tabController setAllowsSubcontrollerDropping:YES];
    
    return [tabController autorelease];
}

- (MOSplitViewController *)testSplitControllerAtOrigin:(NSPoint)origin {
    TestController *testController;
    MOSplitViewController *splitController;
    
    NSLog(@"Creating split controller");
    splitController = [[MOSplitViewController alloc] init];

    NSLog(@"Creating split test controller 1");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Foo"];
    [testController setValue2:@"Foo"];
    [testController setValue3:@"Foo"];
    [testController setValue4:@"Foo"];
    [splitController addSubcontroller:testController];
    [testController release];

    NSLog(@"Creating split test controller 2");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Bar"];
    [testController setValue2:@"Bar"];
    [testController setValue3:@"Bar"];
    [testController setValue4:@"Bar"];
    [splitController addSubcontroller:testController];
    [testController release];

    NSLog(@"Giving split controller a window");
    [splitController setWantsOwnWindow:YES];
    NSLog(@"Showing split controller window");
    if(!NSEqualPoints(origin, NSZeroPoint))
        [[[splitController windowController] window] setFrameOrigin:origin];
    [[splitController windowController] setShouldCascadeWindows:YES];
    [splitController showWindow:self];
    NSLog(@"Setting label on split controller");
    [splitController setLabelAsFilename:@"/Applications/TextEdit.app"];

    NSLog(@"Creating split test controller 3");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Baz"];
    [testController setValue2:@"Baz"];
    [testController setValue3:@"Baz"];
    [testController setValue4:@"Baz"];
    [splitController addSubcontroller:testController];
    [testController release];

    NSLog(@"Removing split test controller 2");
    [splitController removeSubcontrollerAtIndex:1];
    
    return [splitController autorelease];
}

- (MOViewListViewController *)testViewListControllerAtOrigin:(NSPoint)origin {
    TestController *testController;
    MOViewListViewController *viewListController;
    
    NSLog(@"Creating view list controller");
    viewListController = [[MOViewListViewController alloc] init];

    NSLog(@"Creating view list test controller 1");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Foo"];
    [testController setValue2:@"Foo"];
    [testController setValue3:@"Foo"];
    [testController setValue4:@"Foo"];
    [viewListController addSubcontroller:testController];
    [testController release];

    NSLog(@"Creating view list test controller 2");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Bar"];
    [testController setValue2:@"Bar"];
    [testController setValue3:@"Bar"];
    [testController setValue4:@"Bar"];
    [viewListController addSubcontroller:testController];
    [testController release];

    NSLog(@"Creating view list test controller 3");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Baz"];
    [testController setValue2:@"Baz"];
    [testController setValue3:@"Baz"];
    [testController setValue4:@"Baz"];
    [viewListController addSubcontroller:testController];
    [testController release];

    NSLog(@"Giving view list controller a window");
    [viewListController setWantsOwnWindow:YES];
    NSLog(@"Setting label on view list controller");
    [viewListController setLabel:@"Testing ViewListView Controller"];
    NSLog(@"Showing view list controller window");
    if(!NSEqualPoints(origin, NSZeroPoint))
        [[[viewListController windowController] window] setFrameOrigin:origin];
    [[viewListController windowController] setShouldCascadeWindows:YES];
    [viewListController showWindow:self];

    NSLog(@"Creating view list test controller 4");
    testController = [[TestController alloc] init];
    [testController setValue1:@"Boom"];
    [testController setValue2:@"Boom"];
    [testController setValue3:@"Boom"];
    [testController setValue4:@"Boom"];
    [viewListController addSubcontroller:testController];
    [testController release];

    NSLog(@"Setting label on view list test controller 4");
    [testController setLabel:@"Hi There"];

    NSLog(@"Removing view list test controller 2");
    [viewListController removeSubcontrollerAtIndex:1];
    
    [viewListController setAllowsSubcontrollerDragging:YES];
    [viewListController setAllowsSubcontrollerDropping:YES];

    return [viewListController autorelease];
}        
        
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self addViewController: [self testTabControllerAtOrigin: NSMakePoint(100.0, 500.0)]];
    //_tabController2 = [[self testTabControllerAtOrigin:NSMakePoint(700.0, 500.0)] retain];
    //_splitController = [[self testSplitControllerAtOrigin:NSMakePoint(100.0, 50.0)] retain];
    //_viewListController = [[self testViewListControllerAtOrigin:NSMakePoint(100.0, 50.0)] retain];
    //_viewListController = [[self testViewListControllerAtOrigin:NSMakePoint(700.0, 50.0)] retain];
}

- (NSArray *)viewControllers
{
    return _viewControllers;
}

- (void)addViewController:(MOViewController *)controller
{
    if(!_viewControllers)
        _viewControllers = [NSMutableArray new];
    [_viewControllers addObject:controller];
}

- (IBAction)testTabController:(id)sender
{
    
    [self addViewController: [self testTabControllerAtOrigin:NSZeroPoint]];
}

- (IBAction)testSplitController:(id)sender
{
    [self addViewController: [self testSplitControllerAtOrigin:NSZeroPoint]];
}

- (IBAction)testViewListController:(id)sender
{
    [self addViewController: [self testViewListControllerAtOrigin:NSZeroPoint]];
}


- (void)applicationWillTerminate:(NSNotification *)notification {
    /*
    if (_tabController) {
        NSLog(@"Releasing tab controller");
        [_tabController release], _tabController = nil;
    }
    if (_tabController2) {
        NSLog(@"Releasing tab controller2");
        [_tabController2 release], _tabController2 = nil;
    }
    if (_splitController) {
        NSLog(@"Releasing split controller");
        [_splitController release], _splitController = nil;
    }
    if (_viewListController) {
        NSLog(@"Releasing view list controller");
        [_viewListController release], _viewListController = nil;
    }
    if (_viewListController2) {
        NSLog(@"Releasing view list controller2");
        [_viewListController2 release], _viewListController2 = nil;
    }
     */
    
    NSLog(@"Releasing window controllers");

    [_viewControllers release];
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
