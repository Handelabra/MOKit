// MOSplitViewController.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOSplitViewController.h>
#import <MOKit/MODebug_Private.h>

@implementation MOSplitViewController

- (void)dealloc {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if ([self isViewLoaded]) {
        [[self contentView] setDelegate:nil];
    }
    [super dealloc];
    METHOD_TRACE_OUT;
}

- (NSSplitView *)splitView {
    return [self contentView];
}

- (void)_MO_insertViewForSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOViewController *child = [[self subcontrollers] objectAtIndex:index];
    NSView *childView = [child view];
    NSSplitView *splitView = [self contentView];
    if (index >= [[splitView subviews] count]) {
        [splitView addSubview:childView];
    } else {
        [splitView addSubview:childView positioned:NSWindowBelow relativeTo:[[splitView subviews] objectAtIndex:index]];
    }
    [child viewWasInstalled];
    METHOD_TRACE_OUT;
}

- (void)_MO_removeViewForSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOViewController *child = [[self subcontrollers] objectAtIndex:index];
    NSView *childView = [child view];
    [child viewWillBeUninstalled];
    [childView removeFromSuperview];
    METHOD_TRACE_OUT;
}

- (void)insertSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super insertSubcontroller:subcontroller atIndex:index];
    if ([self isViewLoaded]) {
        [self _MO_insertViewForSubcontrollerAtIndex:index];
    }
    METHOD_TRACE_OUT;
}

- (void)removeSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if ([self isViewLoaded]) {
        [self _MO_removeViewForSubcontrollerAtIndex:index];
    }
    [super removeSubcontrollerAtIndex:index];
    METHOD_TRACE_OUT;
}

- (void)loadView {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSSplitView *splitView = [[NSSplitView allocWithZone:[self zone]] initWithFrame:MOViewControllerDefaultFrame];
    [self setContentView:splitView];
    [self setFirstKeyView:splitView];
    [splitView release];
    [splitView setDelegate:self];
    METHOD_TRACE_OUT;
}

- (void)viewDidLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super viewDidLoad];

    [[self splitView] setVertical:[self isVertical]];
    [[self splitView] setIsPaneSplitter:[self isPaneSplitter]];
    
    // Create items for any children we already have.
    NSArray *children = [self subcontrollers];
    unsigned i, c = [children count];
    for (i=0; i<c; i++) {
        [self _MO_insertViewForSubcontrollerAtIndex:i];
    }
    METHOD_TRACE_OUT;
}

- (void)setVertical:(BOOL)flag {
    if (_svcFlags.vertical != flag) {
        _svcFlags.vertical = flag;
        if ([self isViewLoaded]) {
            [[self splitView] setVertical:flag];
        }
    }
}

- (BOOL)isVertical {
    return _svcFlags.vertical;
}

- (void)setPaneSplitter:(BOOL)flag {
    if (_svcFlags.paneSplitter != flag) {
        _svcFlags.paneSplitter = flag;
        if ([self isViewLoaded]) {
            [[self splitView] setIsPaneSplitter:flag];
        }
    }
}

- (BOOL)isPaneSplitter {
    return _svcFlags.paneSplitter;
}

static NSString * const MOVerticalSplitKey = @"MOVerticalSplit";
static NSString * const MOPaneSplitterKey = @"MOPaneSplitter";

- (NSMutableDictionary *)stateDictionaryIgnoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSMutableDictionary *dict = [super stateDictionaryIgnoringContentState:ignoreContentFlag];
    BOOL flag;

    // Save vertical and pane splitter attributes
    flag = [self isVertical];
    if (flag) {
        [dict setObject:[NSNumber numberWithBool:flag] forKey:MOVerticalSplitKey];
    }
    flag = [self isPaneSplitter];
    if (flag) {
        [dict setObject:[NSNumber numberWithBool:flag] forKey:MOPaneSplitterKey];
    }

    METHOD_TRACE_OUT;
    return dict;
}

- (void)takeStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super takeStateDictionary:dict ignoringContentState:ignoreContentFlag];

    NSNumber *flagNum;
    BOOL flag;
    
    flagNum = [dict objectForKey:MOVerticalSplitKey];
    flag = (flagNum ? [flagNum boolValue] : NO);
    [self setVertical:flag];
    flagNum = [dict objectForKey:MOPaneSplitterKey];
    flag = (flagNum ? [flagNum boolValue] : NO);
    [self setPaneSplitter:flag];

    METHOD_TRACE_OUT;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
