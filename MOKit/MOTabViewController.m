// MOTabViewController.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOTabViewController.h>
#import <MOKit/MOTabView.h>
#import <MOKit/MORuntimeUtilities.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/MODebug_Private.h>

@implementation MOTabViewController

+ (Class)tabViewItemClass {
    return [NSTabViewItem class];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        [self setTabViewType:NSTopTabsBezelBorder];
        [self setAllowsTruncatedLabels:NO];
        [self setDrawsBackground:YES];
        [self setControlTint:NSDefaultControlTint];
        [self setControlSize:NSRegularControlSize];
        _selectedItemIndex = 0;
    }
    return self;
}

- (void)dealloc {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if ([self isViewLoaded]) {
        [[self contentView] setDelegate:nil];
    }
    [_font release], _font = nil;
    [super dealloc];
    METHOD_TRACE_OUT;
}

- (id)tabView {
    return [self contentView];
}

- (int)indexOfSelectedSubcontroller {
    if ([self isViewLoaded]) {
        NSTabView *tabView = [self tabView];
        NSTabViewItem *selectedItem = [tabView selectedTabViewItem];
        if (selectedItem) {
            return [tabView indexOfTabViewItem:selectedItem];
        } else {
            return -1;
        }
    } else {
        return _selectedItemIndex;
    }
}

- (void)selectSubcontrollerAtIndex:(int)selIndex {
    if ([self isViewLoaded]) {
        if ((selIndex >= 0) && (selIndex < [[self tabView] numberOfTabViewItems])) {
            [[self tabView] selectTabViewItemAtIndex:selIndex];
        }
    } else {
        _selectedItemIndex = selIndex;
    }
}

- (id)selectedSubcontroller {
    int i = [self indexOfSelectedSubcontroller];
    if (i < 0) {
        return nil;
    } else {
        return [[self subcontrollers] objectAtIndex:i];
    }
}

- (void)selectSubcontroller:(MOViewController *)subcontroller {
    unsigned i = [[self subcontrollers] indexOfObjectIdenticalTo:subcontroller];
    if (i != NSNotFound) {
        [self selectSubcontrollerAtIndex:i];
    }
}

- (void)_MO_insertItemForSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOViewController *child = [[self subcontrollers] objectAtIndex:index];
    NSTabViewItem *item = [[[[self class] tabViewItemClass] allocWithZone:[self zone]] initWithIdentifier:child];
    [item setLabel:[child label]];

    NSTabView *tabView = [self contentView];
    if ((int)index >= [tabView numberOfTabViewItems]) {
        [tabView addTabViewItem:item];
    } else {
        [tabView insertTabViewItem:item atIndex:index];
    }
    [item release];
    METHOD_TRACE_OUT;
}

- (void)_MO_removeItemForSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSTabView *tabView = [self contentView];
    [tabView removeTabViewItem:[tabView tabViewItemAtIndex:index]];
    METHOD_TRACE_OUT;
}

- (void)insertSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super insertSubcontroller:subcontroller atIndex:index];
    if ([self isViewLoaded]) {
        [self _MO_insertItemForSubcontrollerAtIndex:index];
    }
    METHOD_TRACE_OUT;
}

- (void)removeSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if ([self isViewLoaded]) {
        [self _MO_removeItemForSubcontrollerAtIndex:index];
    }
    [super removeSubcontrollerAtIndex:index];
    METHOD_TRACE_OUT;
}

- (void)loadView {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOTabView *tabView = [[MOTabView allocWithZone:[self zone]] initWithFrame:MOViewControllerDefaultFrame];
    [self setContentView:tabView];
    [self setFirstKeyView:tabView];
    [tabView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [tabView release];
    [tabView setDelegate:self];
    METHOD_TRACE_OUT;
}

- (void)viewDidLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super viewDidLoad];

    // Set cover attributes
    NSTabView *tv = [self tabView];
    [tv setFont:[self font]];
    [tv setTabViewType:[self tabViewType]];
    [tv setAllowsTruncatedLabels:[self allowsTruncatedLabels]];
    [tv setDrawsBackground:[self drawsBackground]];
    [tv setControlTint:[self controlTint]];
    [tv setControlSize:[self controlSize]];
    if ([self allowsSubcontrollerDropping]) {
        [tv registerForDraggedTypes:[NSArray arrayWithObject:MOViewControllerPboardType]];
    }
    
    // Create items for any children we already have.
    NSArray *children = [self subcontrollers];
    unsigned i, c = [children count];
    for (i=0; i<c; i++) {
        [self _MO_insertItemForSubcontrollerAtIndex:i];
    }
    
    if ((_selectedItemIndex >= 0) && (_selectedItemIndex < [tv numberOfTabViewItems])) {
        [tv selectTabViewItemAtIndex:_selectedItemIndex];
    }
    _selectedItemIndex = -1;

    METHOD_TRACE_OUT;
}

- (void)controllerDidChangeLabel:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super controllerDidChangeLabel:controller];
    if ([controller supercontroller] == self) {
        // This is one of ours, update the tab
        if ([self isViewLoaded]) {
            NSArray *subcontrollers = [self subcontrollers];
            unsigned i = [subcontrollers indexOfObjectIdenticalTo:controller];
            if (i != NSNotFound) {
                [[[self contentView] tabViewItemAtIndex:i] setLabel:[controller label]];
                
            }
        }
    }
    METHOD_TRACE_OUT;
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    // Send viewWillBeUninstalled to current subcontroller
    NSTabViewItem *curItem = [tabView selectedTabViewItem];
    if (curItem) {
        [[curItem identifier] viewWillBeUninstalled];
    }

    if (tabViewItem) {
        // Make sure the view is loaded and set in the item.
        MOViewController *child = [tabViewItem identifier];
        [tabViewItem setView:[child view]];
        [tabViewItem setInitialFirstResponder:[child firstKeyView]];
    }
    METHOD_TRACE_OUT;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    // Send viewWasInstalled to new subcontroller
    if (tabViewItem) {
        [[tabViewItem identifier] viewWasInstalled];
    }
    METHOD_TRACE_OUT;
}

//- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;
//- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)TabView;

- (BOOL)tabView:(MOTabView *)tabView writeItem:(NSTabViewItem *)item toPasteboard:(NSPasteboard*)pboard {
    if ([self allowsSubcontrollerDragging]) {
        [pboard declareTypes:[NSArray arrayWithObject:MOViewControllerPboardType] owner:nil];
        [pboard setViewControllers:[NSArray arrayWithObject:[item identifier]] forType:MOViewControllerPboardType];
        return YES;
    } else {
        return NO;
    }
}

- (void)tabView:(MOTabView *)tabView dragEndedAtPoint:(NSPoint )aPoint withOperation:(NSDragOperation)dragOp forItem:(NSTabViewItem *)item {
    if (dragOp != NSDragOperationNone) {
        [self removeSubcontroller:[item identifier]];
    }
}

- (NSDragOperation)tabView:(MOTabView *)tabView validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOTabViewDropOperation)op {
    if ([self allowsSubcontrollerDropping] && (op == MOTabViewDropBeforeItem)) {
        // We only allow drop between two tabs to add another tab, not dropping onto a tab.
        if ([info draggingSource]) {
            // Only accept local drags, base class does not handle dragging controllers across app boundaries... too dangerous.
            NSPasteboard *pboard = [info draggingPasteboard];
            NSDragOperation sourceDragMask = [info draggingSourceOperationMask];
            
            if ([[pboard types] containsObject:MOViewControllerPboardType]) {
                if (sourceDragMask & NSDragOperationGeneric) {
                    return NSDragOperationGeneric;
                }
            }
        }
    }
    // We did not handle it as a view controller drop.  See if the delegate wants to handle it.
    if (_tvcFlags.delegateImplementsValidateDrop && _tvcFlags.delegateImplementsAcceptDrop) {
        return [[self delegate] tabViewController:self validateDrop:info proposedItemIndex:itemIndex proposedDropOperation:op];
    }
    return NSDragOperationNone;
}

- (BOOL)tabView:(MOTabView *)tabView acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOTabViewDropOperation)op {
    BOOL result = NO;
    if ([self allowsSubcontrollerDropping] && (op == MOTabViewDropBeforeItem)) {
        id dragSource = [info draggingSource];
        if (dragSource) {
            NSPasteboard *pboard = [info draggingPasteboard];
            if ([[pboard types] containsObject:MOViewControllerPboardType]) {
                NSArray *controllers = [pboard viewControllersForType:MOViewControllerPboardType];
                unsigned c = [controllers count];
                while (c--) {
                    MOViewController *curController = [controllers objectAtIndex:c];
                    [self insertSubcontroller:curController atIndex:itemIndex];
                    [[self tabView] selectTabViewItemAtIndex:itemIndex];
                }
                result = YES;
            }
        }
    }
    // We did not handle it as a view controller drop.  See if the delegate wants to handle it.
    if (_tvcFlags.delegateImplementsValidateDrop && _tvcFlags.delegateImplementsAcceptDrop) {
        return [[self delegate] tabViewController:self acceptDrop:info itemIndex:itemIndex dropOperation:op];
    }
    
    return result;
}

- (BOOL)allowsSubcontrollerDragging {
    return _tvcFlags.allowsSubcontrollerDragging;
}

- (void)setAllowsSubcontrollerDragging:(BOOL)flag {
    if (_tvcFlags.allowsSubcontrollerDragging != flag) {
        _tvcFlags.allowsSubcontrollerDragging = flag;
    }
}

- (BOOL)allowsSubcontrollerDropping {
    return _tvcFlags.allowsSubcontrollerDropping;
}

- (void)setAllowsSubcontrollerDropping:(BOOL)flag {
    if (_tvcFlags.allowsSubcontrollerDropping != flag) {
        _tvcFlags.allowsSubcontrollerDropping = flag;
        if ([self isViewLoaded] && flag) {
            [[self tabView] registerForDraggedTypes:[NSArray arrayWithObject:MOViewControllerPboardType]];
        }
    }
}


static NSString * const MOSelectedTabKey = @"MOSelectedTab";
static NSString * const MOFontKey = @"MOFont";
static NSString * const MOTabViewTypeKey = @"MOTabViewType";
static NSString * const MOAllowsTruncatedLabelsKey = @"MOAllowsTruncatedLabels";
static NSString * const MODrawsBackgroundKey = @"MODrawsBackground";
static NSString * const MOControlTintKey = @"MOControlTint";
static NSString * const MOControlSizeKey = @"MOControlSize";

- (NSMutableDictionary *)stateDictionaryIgnoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSMutableDictionary *dict = [super stateDictionaryIgnoringContentState:ignoreContentFlag];
    
    if (!ignoreContentFlag || ![self selectedTabIsContentConfiguration]) {
        int selIndex = [self indexOfSelectedSubcontroller];
        if (selIndex >= 0) {
            [dict setObject:[NSNumber numberWithInt:selIndex] forKey:MOSelectedTabKey];
        }
    }

    NSFont *font = [self font];
    if (![font isEqual:[NSFont systemFontOfSize:[NSFont systemFontSize]]]) {
        [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:font] forKey:MOFontKey];
    }
    NSTabViewType tabViewType = [self tabViewType];
    if (tabViewType != NSTopTabsBezelBorder) {
        [dict setObject:[NSNumber numberWithInt:tabViewType] forKey:MOTabViewTypeKey];
    }
    BOOL allowsTruncatedLabels = [self allowsTruncatedLabels];
    if (allowsTruncatedLabels) {
        [dict setObject:[NSNumber numberWithBool:allowsTruncatedLabels] forKey:MOAllowsTruncatedLabelsKey];
    }
    BOOL drawsBackground = [self drawsBackground];
    if (!drawsBackground) {
        [dict setObject:[NSNumber numberWithBool:drawsBackground] forKey:MODrawsBackgroundKey];
    }
    NSControlTint controlTint = [self controlTint];
    if (controlTint != NSDefaultControlTint) {
        [dict setObject:[NSNumber numberWithInt:controlTint] forKey:MOControlTintKey];
    }
    NSControlSize controlSize = [self controlSize];
    if (controlSize != NSRegularControlSize) {
        [dict setObject:[NSNumber numberWithInt:controlSize] forKey:MOControlSizeKey];
    }
     
    METHOD_TRACE_OUT;
    return dict;
}

- (void)takeStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super takeStateDictionary:dict ignoringContentState:ignoreContentFlag];
    
    if (!ignoreContentFlag || ![self selectedTabIsContentConfiguration]) {
        NSNumber *selIndexNum = [dict objectForKey:MOSelectedTabKey];
        int selIndex = -1;
        if (selIndexNum) {
            selIndex = [selIndexNum intValue];
        }
        [self selectSubcontrollerAtIndex:selIndex];
    }
    
    id val = [dict objectForKey:MOFontKey];
    if (val) {
        NSFont *font = [NSKeyedUnarchiver unarchiveObjectWithData:val];
        [self setFont:font];
    } else {
        [self setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
    }
    val = [dict objectForKey:MOTabViewTypeKey];
    if (val) {
        [self setTabViewType:[val intValue]];
    } else {
        [self setTabViewType:NSTopTabsBezelBorder];
    }
    val = [dict objectForKey:MOAllowsTruncatedLabelsKey];
    if (val) {
        [self setAllowsTruncatedLabels:[val boolValue]];
    } else {
        [self setAllowsTruncatedLabels:NO];
    }
    val = [dict objectForKey:MODrawsBackgroundKey];
    if (val) {
        [self setDrawsBackground:[val boolValue]];
    } else {
        [self setDrawsBackground:YES];
    }
    val = [dict objectForKey:MOControlTintKey];
    if (val) {
        [self setControlTint:[val intValue]];
    } else {
        [self setControlTint:NSDefaultControlTint];
    }
    val = [dict objectForKey:MOControlSizeKey];
    if (val) {
        [self setControlSize:[val intValue]];
    } else {
        [self setControlSize:NSRegularControlSize];
    }

    METHOD_TRACE_OUT;
}

- (BOOL)selectedTabIsContentConfiguration {
    return _tvcFlags.selectedTabIsContentConfiguration;
}

- (void)setSelectedTabIsContentConfiguration:(BOOL)flag {
    _tvcFlags.selectedTabIsContentConfiguration = flag;
}

- (NSFont *)font {
    return _font;
}

- (void)setFont:(NSFont *)font {
    MOAssertClass(font, NSFont);
    if (_font != font) {
        [_font release];
        _font = [font retain];
        if ([self isViewLoaded]) {
            [[self tabView] setFont:_font];
        }
    }
}

- (NSTabViewType)tabViewType {
    return _tabViewType;
}

- (void)setTabViewType:(NSTabViewType)tabViewType {
    if (_tabViewType != tabViewType) {
        _tabViewType = tabViewType;
        if ([self isViewLoaded]) {
            [[self tabView] setTabViewType:_tabViewType];
        }
    }
}

- (BOOL)allowsTruncatedLabels {
    return _tvcFlags.allowsTruncatedLabels;
}

- (void)setAllowsTruncatedLabels:(BOOL)flag {
    if (_tvcFlags.allowsTruncatedLabels != flag) {
        _tvcFlags.allowsTruncatedLabels = flag;
        if ([self isViewLoaded]) {
            [[self tabView] setAllowsTruncatedLabels:_tvcFlags.allowsTruncatedLabels];
        }
    }
}

- (BOOL)drawsBackground {
    return _tvcFlags.drawsBackground;
}

- (void)setDrawsBackground:(BOOL)flag {
    if (_tvcFlags.drawsBackground != flag) {
        _tvcFlags.drawsBackground = flag;
        if ([self isViewLoaded]) {
            [[self tabView] setDrawsBackground:_tvcFlags.drawsBackground];
        }
    }
}

- (NSControlTint)controlTint {
    return _controlTint;
}

- (void)setControlTint:(NSControlTint)controlTint {
    if (_controlTint != controlTint) {
        _controlTint = controlTint;
        if ([self isViewLoaded]) {
            [[self tabView] setControlTint:_controlTint];
        }
    }
}

- (NSControlSize)controlSize {
    return _controlSize;
}

- (void)setControlSize:(NSControlSize)controlSize {
    if (_controlSize != controlSize) {
        _controlSize = controlSize;
        if ([self isViewLoaded]) {
            [[self tabView] setControlSize:_controlSize];
        }
    }
}

- (id)delegate {
    return _delegate;
}

- (void)setDelegate:(id)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        _tvcFlags.delegateImplementsValidateDrop = ((delegate && [delegate respondsToSelector:@selector(tabViewController:validateDrop:proposedItemIndex:proposedDropOperation:)]) ? YES : NO);
        _tvcFlags.delegateImplementsAcceptDrop = ((delegate && [delegate respondsToSelector:@selector(tabViewController:acceptDrop:itemIndex:dropOperation:)]) ? YES : NO);
        _tvcFlags.delegateImplementsMenuForItem = ((delegate && [delegate respondsToSelector:@selector(tabViewController:menuForItemAtIndex:event:)]) ? YES : NO);
    }
}

- (NSMenu *)tabView:(MOTabView *)tabView menuForItemAtIndex:(int)itemIndex event:(NSEvent *)event {
    if (_tvcFlags.delegateImplementsMenuForItem) {
        return [[self delegate] tabViewController:self menuForItemAtIndex:itemIndex event:event];
    } else {
        return nil;
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
