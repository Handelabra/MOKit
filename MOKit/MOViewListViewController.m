// MOViewListViewController.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOViewListViewController.h>
#import <MOKit/MOViewListView.h>
#import <MOKit/MOViewListViewItem.h>
#import <MOKit/MODebug_Private.h>

@interface MOViewListViewController (MOPrivate)
- (void)_MO_setExpandedItemsArray:(NSArray *)expItemIndexes;
@end

@implementation MOViewListViewController

- (id)init {
    self = [super init];
    if (self) {
        [self setControlSize:NSRegularControlSize];
        [self setLabelBarAppearance:MOViewListViewDefaultLabelBars];
        [self setBackgroundColor:[NSColor controlColor]];   
    }
    return self;
}

- (void)dealloc {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if ([self isViewLoaded]) {
        [_viewListView setDelegate:nil];
    }
    [_backgroundColor release], _backgroundColor = nil;
    [_savedExpandedItemsArray release], _savedExpandedItemsArray = nil;
    [super dealloc];
    METHOD_TRACE_OUT;
}

- (MOViewListView *)viewListView {
    (void)[self view];
    return _viewListView;
}

- (NSScrollView *)scrollView {
    return [self contentView];
}

- (BOOL)allowsSubcontrollerDragging {
    return _vlvcFlags.allowsSubcontrollerDragging;
}

- (void)setAllowsSubcontrollerDragging:(BOOL)flag {
    if (_vlvcFlags.allowsSubcontrollerDragging != flag) {
        _vlvcFlags.allowsSubcontrollerDragging = flag;
    }
}

- (BOOL)allowsSubcontrollerDropping {
    return _vlvcFlags.allowsSubcontrollerDropping;
}

- (void)setAllowsSubcontrollerDropping:(BOOL)flag {
    if (_vlvcFlags.allowsSubcontrollerDropping != flag) {
        _vlvcFlags.allowsSubcontrollerDropping = flag;
        if ([self isViewLoaded] && flag) {
            [[self viewListView] registerForDraggedTypes:[NSArray arrayWithObject:MOViewControllerPboardType]];
        }
    }
}

- (void)_MO_insertItemForSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOViewController *child = [[self subcontrollers] objectAtIndex:index];
    MOViewListViewItem *item = [[MOViewListViewItem allocWithZone:[self zone]] initWithView:nil andLabel:[child label]];
    [item setRepresentedObject:child];

    [_viewListView insertViewListViewItem:item atIndex:index];
    [item release];
    METHOD_TRACE_OUT;
}

- (void)_MO_removeItemForSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [_viewListView removeViewListViewItemAtIndex:index];
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
    NSScrollView *scrollView = [[NSScrollView allocWithZone:[self zone]] initWithFrame:MOViewControllerDefaultFrame];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    NSSize contentSize = [scrollView contentSize];
    _viewListView = [[MOViewListView allocWithZone:[self zone]] initWithFrame:NSMakeRect(0.0, 0.0, contentSize.width, contentSize.height)];
    [_viewListView setAutoresizingMask:NSViewWidthSizable];
    [scrollView setDocumentView:_viewListView];
    [_viewListView release];
    [self setContentView:scrollView];
    [self setFirstKeyView:_viewListView];
    [scrollView release];
    [_viewListView setDelegate:self];
    METHOD_TRACE_OUT;
}

- (void)viewDidLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super viewDidLoad];

    // Set appearance cover values
    MOViewListView *vlv = [self viewListView];
    [vlv setControlSize:[self controlSize]];
    [vlv setLabelBarAppearance:[self labelBarAppearance]];
    [vlv setBackgroundColor:[self backgroundColor]];
    
    // Create items for any children we already have.
    NSArray *children = [self subcontrollers];
    unsigned i, c = [children count];
    for (i=0; i<c; i++) {
        [self _MO_insertItemForSubcontrollerAtIndex:i];
    }
    
    if (_savedExpandedItemsArray) {
        [self _MO_setExpandedItemsArray:_savedExpandedItemsArray];
        [_savedExpandedItemsArray release], _savedExpandedItemsArray = nil;
    }
    
    METHOD_TRACE_OUT;
}

- (void)controllerDidChangeLabel:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super controllerDidChangeLabel:controller];
    if ([controller supercontroller] == self) {
        // This is one of ours, update the view list view
        if ([self isViewLoaded]) {
            NSArray *subcontrollers = [self subcontrollers];
            unsigned i = [subcontrollers indexOfObjectIdenticalTo:controller];
            if (i != NSNotFound) {
                [[_viewListView viewListViewItemAtIndex:i] setLabel:[controller label]];
            }
        }
    }
    METHOD_TRACE_OUT;
}

- (void)viewListView:(MOViewListView *)viewListView willExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (viewListViewItem) {
        // Make sure the view is loaded and set in the item.
        [viewListViewItem setView:[[viewListViewItem representedObject] view]];
        // !!!:mike:20030307 set firstKeyView of item from controller
    }
    METHOD_TRACE_OUT;
}

- (void)viewListView:(MOViewListView *)viewListView didExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (viewListViewItem) {
        // Send viewWasInstalled.
        [[viewListViewItem representedObject] viewWasInstalled];
    }
    METHOD_TRACE_OUT;
}

- (void)viewListView:(MOViewListView *)viewListView willCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (viewListViewItem) {
        // Send viewWillBeUninstalled.
        [[viewListViewItem representedObject] viewWillBeUninstalled];
    }
    METHOD_TRACE_OUT;
}

//- (void)viewListView:(MOViewListView *)viewListView didCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem;
//- (BOOL)viewListView:(MOViewListView *)viewListView shouldExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem;
//- (BOOL)viewListView:(MOViewListView *)viewListView shouldCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem;

- (BOOL)viewListView:(MOViewListView *)viewListView writeItem:(MOViewListViewItem *)item toPasteboard:(NSPasteboard*)pboard {
    if ([self allowsSubcontrollerDragging]) {
        [pboard declareTypes:[NSArray arrayWithObject:MOViewControllerPboardType] owner:nil];
        [pboard setViewControllers:[NSArray arrayWithObject:[item representedObject]] forType:MOViewControllerPboardType];
        return YES;
    } else {
        return NO;
    }
}

- (void)viewListView:(MOViewListView *)viewListView dragEndedAtPoint:(NSPoint )aPoint withOperation:(NSDragOperation)dragOp forItem:(MOViewListViewItem *)item {
    if (dragOp != NSDragOperationNone) {
        [self removeSubcontroller:[item representedObject]];
    }
}

- (NSDragOperation)viewListView:(MOViewListView *)viewListView validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOViewListViewDropOperation)op {
    if ([self allowsSubcontrollerDropping] && (op == MOViewListViewDropBeforeItem)) {
        // We only allow drop between two items to add another subcontroller, not dropping onto a label.
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
    if (_vlvcFlags.delegateImplementsValidateDrop && _vlvcFlags.delegateImplementsAcceptDrop) {
        return [[self delegate] viewListViewController:self validateDrop:info proposedItemIndex:itemIndex proposedDropOperation:op];
    }
    return NSDragOperationNone;
}

- (BOOL)viewListView:(MOViewListView *)viewListView acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOViewListViewDropOperation)op {
    BOOL result = NO;
    if ([self allowsSubcontrollerDropping] && (op == MOViewListViewDropBeforeItem)) {
        id dragSource = [info draggingSource];
        if (dragSource) {
            NSPasteboard *pboard = [info draggingPasteboard];
            if ([[pboard types] containsObject:MOViewControllerPboardType]) {
                NSArray *controllers = [pboard viewControllersForType:MOViewControllerPboardType];
                unsigned c = [controllers count];
                while (c--) {
                    MOViewController *curController = [controllers objectAtIndex:c];
                    [self insertSubcontroller:curController atIndex:itemIndex];
                    [[self viewListView] expandStackedViewAtIndex:itemIndex animate:NO];
                }
                result = YES;
            }
        }
    }
    // We did not handle it as a view controller drop.  See if the delegate wants to handle it.
    if (_vlvcFlags.delegateImplementsValidateDrop && _vlvcFlags.delegateImplementsAcceptDrop) {
        return [[self delegate] viewListViewController:self acceptDrop:info itemIndex:itemIndex dropOperation:op];
    }
    
    return result;
}

static NSString * const MOExpandedItemsKey = @"MOExpandedItems";
static NSString * const MOControlSizeKey = @"MOControlSize";
static NSString * const MOLabelBarAppearanceKey = @"MOLabelBarAppearance";
static NSString * const MOBackgroundColorKey = @"MOBackgroundColor";

- (NSArray *)_MO_expandedItemsArray {
    if ([self isViewLoaded]) {
        MOViewListView *vlv = [self viewListView];
        NSArray *items = [vlv viewListViewItems];
        unsigned i, c = [items count];
        NSMutableArray *expItemIndexes = nil;
    
        for (i=0; i<c; i++) {
            if (![[items objectAtIndex:i] isCollapsed]) {
                if (!expItemIndexes) {
                    expItemIndexes = [NSMutableArray array];
                }
                [expItemIndexes addObject:[NSNumber numberWithUnsignedInt:i]];
            }
        }
        return expItemIndexes;
    } else {
        return _savedExpandedItemsArray;
    }
}

- (void)_MO_setExpandedItemsArray:(NSArray *)expItemIndexes {
    if ([self isViewLoaded]) {
        MOViewListView *vlv = [self viewListView];
        NSArray *items = [vlv viewListViewItems];
        unsigned curIndex, indexCount = [expItemIndexes count];
        unsigned itemCount = [items count];
        unsigned curItem, lastItem = 0;
        unsigned j;
        
        for (curIndex=0; curIndex<indexCount; curIndex++) {
            curItem = [[expItemIndexes objectAtIndex:curIndex] unsignedIntValue];

            for (j=lastItem; j<curItem && j<itemCount; j++) {
                // Collapse everything up to the expanded item.
                [vlv collapseStackedViewAtIndex:j animate:NO];
            }
            if (curItem < itemCount) {
                // Expand the expanded item
                [vlv expandStackedViewAtIndex:curItem animate:NO];
            }
            lastItem = curItem + 1;
        }
        for (j=lastItem; j<itemCount; j++) {
            // Collapse everything after the last expanded item.
            [vlv collapseStackedViewAtIndex:j animate:NO];
        }
    } else {
        [_savedExpandedItemsArray release];
        _savedExpandedItemsArray = [expItemIndexes retain];
    }
}

- (NSMutableDictionary *)stateDictionaryIgnoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSMutableDictionary *dict = [super stateDictionaryIgnoringContentState:ignoreContentFlag];
    
    if (!ignoreContentFlag || ![self expandedItemsAreContentConfiguration]) {
        NSArray *expandedItemsArray = [self _MO_expandedItemsArray];
        if (expandedItemsArray) {
            [dict setObject:expandedItemsArray forKey:MOExpandedItemsKey];
        }
    }
        
    NSControlSize controlSize = [self controlSize];
    if (controlSize != NSRegularControlSize) {
        [dict setObject:[NSNumber numberWithInt:controlSize] forKey:MOControlSizeKey];
    }
    MOViewListViewLabelBarAppearance labelBarAppearance = [self labelBarAppearance];
    if (labelBarAppearance != MOViewListViewDefaultLabelBars) {
        [dict setObject:[NSNumber numberWithInt:labelBarAppearance] forKey:MOLabelBarAppearanceKey];
    }
    NSColor *bgColor = [self backgroundColor];
    if (![bgColor isEqual:[NSColor controlColor]]) {
        if (bgColor) {
            [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:bgColor] forKey:MOBackgroundColorKey];
        } else {
            [dict setObject:@"nil" forKey:MOBackgroundColorKey];
        }
    }

    METHOD_TRACE_OUT;
    return dict;
}

- (void)takeStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [super takeStateDictionary:dict ignoringContentState:ignoreContentFlag];
    
    if (!ignoreContentFlag || ![self expandedItemsAreContentConfiguration]) {
        [self _MO_setExpandedItemsArray:[dict objectForKey:MOExpandedItemsKey]];
    }
    
    id val = [dict objectForKey:MOControlSizeKey];
    if (val) {
        [self setControlSize:[val intValue]];
    } else {
        [self setControlSize:NSRegularControlSize];
    }
    val = [dict objectForKey:MOLabelBarAppearanceKey];
    if (val) {
        [self setLabelBarAppearance:[val intValue]];
    } else {
        [self setLabelBarAppearance:MOViewListViewDefaultLabelBars];
    }
    val = [dict objectForKey:MOBackgroundColorKey];
    if (val) {
        NSColor *color;
        if ([val isEqual:@"nil"]) {
            color = nil;
        } else {
            color = [NSKeyedUnarchiver unarchiveObjectWithData:val];
        }
        [self setBackgroundColor:color];
    } else {
        [self setBackgroundColor:[NSColor controlColor]];
    }

    METHOD_TRACE_OUT;
}

- (BOOL)expandedItemsAreContentConfiguration {
    return _vlvcFlags.expandedItemsAreContentConfiguration;
}

- (void)setExpandedItemsAreContentConfiguration:(BOOL)flag {
    _vlvcFlags.expandedItemsAreContentConfiguration = flag;
}

- (void)setControlSize:(NSControlSize)size {
    if (_controlSize != size) {
        _controlSize = size;
        if ([self isViewLoaded]) {
            [[self viewListView] setControlSize:size];
        }
    }
}

- (NSControlSize)controlSize {
    return _controlSize;
}

- (void)setLabelBarAppearance:(MOViewListViewLabelBarAppearance)labelBarAppearance {
    if (_labelBarAppearance != labelBarAppearance) {
        _labelBarAppearance = labelBarAppearance;
        if ([self isViewLoaded]) {
            [[self viewListView] setLabelBarAppearance:_labelBarAppearance];
        }
    }
}    

- (MOViewListViewLabelBarAppearance)labelBarAppearance {
    return _labelBarAppearance;
}

- (void)setBackgroundColor:(NSColor *)color {
    if (_backgroundColor != color) {
        [_backgroundColor release];
        _backgroundColor = [color retain];
        if ([self isViewLoaded]) {
            [[self viewListView] setBackgroundColor:_backgroundColor];
        }
    }
}

- (NSColor *)backgroundColor {
    return _backgroundColor;
}

- (id)delegate {
    return _delegate;
}

- (void)setDelegate:(id)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        _vlvcFlags.delegateImplementsValidateDrop = ((delegate && [delegate respondsToSelector:@selector(viewListViewController:validateDrop:proposedItemIndex:proposedDropOperation:)]) ? YES : NO);
        _vlvcFlags.delegateImplementsAcceptDrop = ((delegate && [delegate respondsToSelector:@selector(viewListViewController:acceptDrop:itemIndex:dropOperation:)]) ? YES : NO);
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
