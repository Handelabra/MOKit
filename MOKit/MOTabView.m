// MOTabView.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOTabView.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/MORuntimeUtilities.h>

@interface NSTabViewItem (MOPrivatesOnParade) 
// Private kit method...
- (NSRect)_tabRect;
@end

@implementation MOTabView

- (void)setDelegate:(id)delegate {
    [super setDelegate:delegate];
    delegate = [self delegate];
    _mtvFlags.delegateImplementsWriteItem = (delegate ? [delegate respondsToSelector:@selector(tabView:writeItem:toPasteboard:)] : NO);
    _mtvFlags.delegateImplementsDragEnded = (delegate ? [delegate respondsToSelector:@selector(tabView:dragEndedAtPoint:withOperation:forItem:)] : NO);
    _mtvFlags.delegateImplementsValidateDrop = (delegate ? [delegate respondsToSelector:@selector(tabView:validateDrop:proposedItemIndex:proposedDropOperation:)] : NO);
    _mtvFlags.delegateImplementsAcceptDrop = (delegate ? [delegate respondsToSelector:@selector(tabView:acceptDrop:itemIndex:dropOperation:)] : NO);
    _mtvFlags.delegateImplementsMenuForItem = (delegate ? [delegate respondsToSelector:@selector(tabView:menuForItemAtIndex:event:)] : NO);
}

- (NSImage*)dragImageForItem:(NSTabViewItem *)dragItem event:(NSEvent *)dragEvent dragImageOffset:(NSPointPointer)dragImageOffsetPtr {
    // !!!:mferris:20030411 Need a better default drag image
    NSImage *image = [[NSImage allocWithZone:[self zone]] initWithSize:NSMakeSize(16.0, 16.0)];
    
    [image lockFocus];
    [[NSColor redColor] set];
    NSRectFill(NSMakeRect(0.0, 0.0, 16.0, 16.0));
    [image unlockFocus];
    if (dragImageOffsetPtr) {
        NSSize imageSize = [image size];
        *dragImageOffsetPtr = NSMakePoint(floor(imageSize.width / 2.0), floor(imageSize.height / 2.0));
    }
    return [image autorelease];
}

- (void)setDropItemIndex:(int)itemIndex dropOperation:(MOTabViewDropOperation)op {
    MOAssert(((itemIndex > 0) && (itemIndex <= (int)[[self tabViewItems] count] - ((op == MOTabViewDropOnItem) ? 1 : 0))), @"-setDropItemIndex:dropOperation: itemIndex %d out of range.", itemIndex);
    _dropIndex = itemIndex;
    _dropOperation = op;
}

- (NSRect)_MO_tabBarRect {
    NSTabViewType tabType = [self tabViewType];
    NSRect bounds = [self bounds];
    NSRect contentRect = [self contentRect];
    BOOL isFlipped = [self isFlipped];
    NSRect tabBarRect = bounds;
    
    switch (tabType) {
        case NSTopTabsBezelBorder:
            if (!isFlipped) {
                tabBarRect.size.height = NSMaxY(bounds) - NSMaxY(contentRect);
                tabBarRect.origin.y = NSMaxY(contentRect);
            } else {
                tabBarRect.size.height = NSMinY(contentRect) - NSMinY(bounds);
            }
            break;
        case NSLeftTabsBezelBorder:
            tabBarRect.size.width = NSMinX(contentRect) - NSMinX(bounds);
            break;
        case NSBottomTabsBezelBorder:
            if (isFlipped) {
                tabBarRect.size.height = NSMaxY(bounds) - NSMaxY(contentRect);
                tabBarRect.origin.y = NSMaxY(contentRect);
            } else {
                tabBarRect.size.height = NSMinY(contentRect) - NSMinY(bounds);
            }
            break;
        case NSRightTabsBezelBorder:
            tabBarRect.size.width = NSMaxX(bounds) - NSMaxX(contentRect);
            tabBarRect.origin.x = NSMaxX(contentRect);
            break;
        default:
            tabBarRect = NSZeroRect;
            break;
    }
    return tabBarRect;
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    
    if (_dragOperation != NSDragOperationNone) {
        // Draw drop indication
        // ---:mferris:20030415 If we got here (_dragOperation != NSDragOperationNone) that means that validation happened successfully and we can assume that the private tab item API is present.  We can also assume that the view has tabs.
        if (_dropOperation == MOTabViewDropOnItem) {
            // Shade the tab the drop will be "on"
            NSRect tabRect = [[[self tabViewItems] objectAtIndex:_dropIndex] _tabRect];
            [[NSColor colorWithCalibratedWhite:0.3 alpha:0.3] set];
            NSRectFillUsingOperation(NSInsetRect(tabRect, 2.0, 2.0), NSCompositeSourceOver);
        } else {
            // Draw an insertion point where the tab will be inserted
            NSArray *items = [self tabViewItems];
            unsigned c = [items count];
            NSRect insertionPointRect;
            NSTabViewType tabType = [self tabViewType];
            if (c == 0) {
                insertionPointRect = [self _MO_tabBarRect];
                if ((tabType == NSTopTabsBezelBorder) || (tabType == NSBottomTabsBezelBorder)) {
                    insertionPointRect.origin.x += floor(NSWidth(insertionPointRect) / 2.0);
                    insertionPointRect.size.width = 3.0;
                } else {
                    insertionPointRect.origin.y += floor(NSHeight(insertionPointRect) / 2.0);
                    insertionPointRect.size.height = 3.0;
                }
            } else {
                BOOL afterRect = (((int)[items count] == _dropIndex) ? YES : NO);
                NSRect tabRect = [[items objectAtIndex:(afterRect ? _dropIndex - 1 : _dropIndex)] _tabRect];
                insertionPointRect = tabRect;
                BOOL isFlipped = [self isFlipped];
                
                if ((tabType == NSTopTabsBezelBorder) || (tabType == NSBottomTabsBezelBorder)) {
                    // Tabs go left to right
                    if (afterRect) {
                        insertionPointRect.origin.x = NSMaxX(tabRect) - 3.0;
                    } else {
                        insertionPointRect.origin.x = NSMinX(tabRect) + 1.0;
                    }
                    insertionPointRect.size.width = 3.0;
                } else if (((tabType == NSLeftTabsBezelBorder) && isFlipped) || ((tabType == NSRightTabsBezelBorder) && isFlipped)) {
                    // Tabs go minY to maxY
                    if (afterRect) {
                        insertionPointRect.origin.y = NSMaxY(tabRect) - 3.0;
                    } else {
                        insertionPointRect.origin.y = NSMinY(tabRect) + 1.0;
                    }
                    insertionPointRect.size.height = 3.0;
                } else {
                    // Tabs go maxY to minY
                    if (afterRect) {
                        insertionPointRect.origin.y = NSMinY(tabRect) + 1.0;
                    } else {
                        insertionPointRect.origin.y = NSMaxY(tabRect) - 3.0;
                    }
                    insertionPointRect.size.height = 3.0;
                }
            }
            [[NSColor blackColor] set];
            NSRectFill(insertionPointRect);
        }
    }
}

static float _distance(NSPoint p1, NSPoint p2) {
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    return sqrt((dx*dx) + (dy*dy));
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint clickPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    NSTabViewItem *clickedItem = [self tabViewItemAtPoint:clickPoint];
    
    if (!clickedItem || !_mtvFlags.delegateImplementsWriteItem) {
        // Click is not on a tab or delegate does not implement drag method... pass.
        [super mouseDown:event];
        return;
    }
    
    // Get tab highlighted...
    // !!!:mferris:20030411 This is skanky, and not only that, but it does not work
//     [self takeValue:clickedItem forKey:@"_pressedTabViewItem"];
//     [self setNeedsDisplay:YES];
    
    while (1) {
        NSEvent *curEvent = [NSApp nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask) untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES];
        
        if ([curEvent type] == NSLeftMouseUp) {
            // Mouse went up before a drag started, put the up event back on the queue and let super handle things.
            [NSApp postEvent:curEvent atStart:YES];
            [super mouseDown:event];
            return;
        }
        NSPoint curPoint = [self convertPoint:[curEvent locationInWindow] fromView:nil];
        if (_distance(curPoint, clickPoint) > 4) {
            // Mouse moved far enough to be a drag.
            NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
            if ([[self delegate] tabView:self writeItem:clickedItem toPasteboard:pboard]) {
                NSPoint dragImageOffset = NSZeroPoint;
                NSImage *image = [self dragImageForItem:clickedItem event:event dragImageOffset:&dragImageOffset];
                _draggingItem = clickedItem;
                // !!!:mferris:20030415  Offset stuff not working...
                [self dragImage:image at:curPoint offset:NSMakeSize(curPoint.x - clickPoint.x - dragImageOffset.x, curPoint.y - clickPoint.y - dragImageOffset.y) event:curEvent pasteboard:pboard source:self slideBack:YES];
                _draggingItem = nil;
                return;
            } else {
                // Delegate declined to drag.  Push the last drag event we got back on the queue to avoid confusing super or causing update delays if the mouse is not still in motion.
                [NSApp postEvent:curEvent atStart:YES];
                [super mouseDown:event];
                return;
            }
        }
    }
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation {
    if (_mtvFlags.delegateImplementsDragEnded) {
        [[self delegate] tabView:self dragEndedAtPoint:aPoint withOperation:operation forItem:_draggingItem];
    }
}

static BOOL _MO_tabViewItemImplementsTabRect() {
    static BOOL checked = NO;
    static BOOL implements = YES;
    if (checked) {
        checked = YES;
        implements = [NSTabViewItem instancesRespondToSelector:@selector(_tabRect)];
    }
    return implements;
}

- (NSDragOperation)_MO_validateDragging:(id <NSDraggingInfo>)sender {
    NSDragOperation origDragOp = _dragOperation;
    int origDropIndex = _dropIndex;
    MOTabViewDropOperation origDropOp = _dropOperation;
    BOOL done = NO;
    
    _dropIndex = NSNotFound;
    _dragOperation = NSDragOperationNone;
    
    if (!_mtvFlags.delegateImplementsValidateDrop || !_mtvFlags.delegateImplementsAcceptDrop) {
        // No drop support.
        done = YES;
    }
    if (!done && !_MO_tabViewItemImplementsTabRect()) {
        // We rely on this private method for proper functioning...
        NSLog(@"MOTabView: Oops, NSTabViewItem's -_tabRect method seems to have gone away...  MOTabView's drop support is broken.");
        done = YES;
    }

    NSTabViewType tabType = [self tabViewType];
    
    if (!done && ((tabType == NSNoTabsBezelBorder) || (tabType == NSNoTabsLineBorder) || (tabType == NSNoTabsNoBorder))) {
        // No tab bar
        done = YES;
    }
    
    // We need to figure out the initial dropIndex and dropOperation
    
    // First, get the rect of the tab bar and if the drop is not over it, stop now.
    NSRect tabBarRect = [self _MO_tabBarRect];
    NSPoint dropPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
    
    if (!done && ![self mouse:dropPoint inRect:tabBarRect]) {
        // Not over tab bar
        done = YES;
    }
    
    if (!done) {
        // Now we start looking at tab rects
        NSArray *items = [self tabViewItems];
        unsigned i, c = [items count];
        id delegate = [self delegate];
        
        if (c == 0) {
            // No tabs at all, the only thing that makes sense is...
            _dropIndex = 0;
            _dropOperation = MOTabViewDropBeforeItem;
            _dragOperation = [delegate tabView:self validateDrop:sender proposedItemIndex:_dropIndex proposedDropOperation:_dropOperation];
            done = YES;
        } else {
            // Start looking at the tabs.
            NSTabViewItem *curItem;
            NSRect prevRect, curRect;
            BOOL isFlipped = [self isFlipped];
            
    #define BEFORE_MARGIN_PROPORTION 0.25
    #define MIDDLE_MARGIN_PROPORTION 0.5
    #define AFTER_MARGIN_PROPORTION 0.75
            prevRect = NSZeroRect;
            
            for (i=0; i<c; i++) {
                curItem = [items objectAtIndex:i];
                curRect = [curItem _tabRect];
                BOOL doTest = NO;
                int test1Index = NSNotFound, test2Index = NSNotFound;
                MOTabViewDropOperation test1Op = NSDragOperationNone, test2Op = NSDragOperationNone;
                
                if ((tabType == NSTopTabsBezelBorder) || (tabType == NSBottomTabsBezelBorder)) {
                    // Tabs go left to right
                    if (dropPoint.x < NSMinX(curRect) + (NSWidth(curRect) * BEFORE_MARGIN_PROPORTION)) {
                        // Check for before first
                        doTest = YES;
                        test1Index = i;
                        test1Op = MOTabViewDropBeforeItem;
                        if ([self mouse:dropPoint inRect:curRect]) {
                            test2Index = i;
                        } else if ([self mouse:dropPoint inRect:prevRect]) {
                            test2Index = i-1;
                        } else {
                            test2Index = NSNotFound;
                        }
                        test2Op = MOTabViewDropOnItem;
                    } else if (dropPoint.x < NSMinX(curRect) + (NSWidth(curRect) * AFTER_MARGIN_PROPORTION)) {
                        // Check for on first
                        doTest = YES;
                        test1Index = i;
                        test1Op = MOTabViewDropOnItem;
                        if (dropPoint.x < NSMinX(curRect) + (NSWidth(curRect) * MIDDLE_MARGIN_PROPORTION)) {
                            test2Index = i;
                        } else {
                            test2Index = i+1;
                        }
                        test2Op = MOTabViewDropBeforeItem;
                    }
                } else if (((tabType == NSLeftTabsBezelBorder) && isFlipped) || ((tabType == NSRightTabsBezelBorder) && isFlipped)) {
                    // Tabs go minY to maxY
                    if (dropPoint.y < NSMinY(curRect) + (NSHeight(curRect) * BEFORE_MARGIN_PROPORTION)) {
                        // Check for before first
                        doTest = YES;
                        test1Index = i;
                        test1Op = MOTabViewDropBeforeItem;
                        if ([self mouse:dropPoint inRect:curRect]) {
                            test2Index = i;
                        } else if ([self mouse:dropPoint inRect:prevRect]) {
                            test2Index = i-1;
                        } else {
                            test2Index = NSNotFound;
                        }
                        test2Op = MOTabViewDropOnItem;
                    } else if (dropPoint.y < NSMinY(curRect) + (NSHeight(curRect) * AFTER_MARGIN_PROPORTION)) {
                        // Check for on first
                        doTest = YES;
                        test1Index = i;
                        test1Op = MOTabViewDropOnItem;
                        if (dropPoint.y < NSMinY(curRect) + (NSHeight(curRect) * MIDDLE_MARGIN_PROPORTION)) {
                            test2Index = i;
                        } else {
                            test2Index = i+1;
                        }
                        test2Op = MOTabViewDropBeforeItem;
                    }
                } else {
                    // Tabs go maxY to minY
                    if (dropPoint.y > NSMaxY(curRect) - (NSHeight(curRect) * BEFORE_MARGIN_PROPORTION)) {
                        // Check for before first
                        doTest = YES;
                        test1Index = i;
                        test1Op = MOTabViewDropBeforeItem;
                        if ([self mouse:dropPoint inRect:curRect]) {
                            test2Index = i;
                        } else if ([self mouse:dropPoint inRect:prevRect]) {
                            test2Index = i-1;
                        } else {
                            test2Index = NSNotFound;
                        }
                        test2Op = MOTabViewDropOnItem;
                    } else if (dropPoint.y > NSMaxY(curRect) - (NSHeight(curRect) * AFTER_MARGIN_PROPORTION)) {
                        // Check for on first
                        doTest = YES;
                        test1Index = i;
                        test1Op = MOTabViewDropOnItem;
                        if (dropPoint.y > NSMaxY(curRect) - (NSHeight(curRect) * MIDDLE_MARGIN_PROPORTION)) {
                            test2Index = i;
                        } else {
                            test2Index = i+1;
                        }
                        test2Op = MOTabViewDropBeforeItem;
                    }
                }
                if (doTest) {
                    _dropIndex = test1Index;
                    _dropOperation = test1Op;
                    _dragOperation = [delegate tabView:self validateDrop:sender proposedItemIndex:_dropIndex proposedDropOperation:_dropOperation];
                    if ((_dragOperation == NSDragOperationNone) && (test2Index != NSNotFound)) {
                        _dropIndex = test2Index;
                        _dropOperation = test2Op;
                        _dragOperation = [delegate tabView:self validateDrop:sender proposedItemIndex:_dropIndex proposedDropOperation:_dropOperation];
                    }
                    done = YES;
                    break;
                }
                prevRect = curRect;
            }
            
            if (!done) {
                // If we  are not done, we should check for after the lasst item, and, possibly, for on the last item.
                _dropIndex = c;
                _dropOperation = MOTabViewDropBeforeItem;
                _dragOperation = [delegate tabView:self validateDrop:sender proposedItemIndex:_dropIndex proposedDropOperation:_dropOperation];
                if ((_dragOperation == NSDragOperationNone) && ([self mouse:dropPoint inRect:curRect])) {
                    _dropIndex = c-1;
                    _dropOperation = MOTabViewDropOnItem;
                    _dragOperation = [delegate tabView:self validateDrop:sender proposedItemIndex:_dropIndex proposedDropOperation:_dropOperation];
                }
                done = YES;
            }
        }
    }
    
    if ((_dragOperation != NSDragOperationNone) && (_dropOperation == MOTabViewDropOnItem)) {
        // Switch to the target tab
        [self selectTabViewItemAtIndex:_dropIndex];
    }
    if ((origDragOp != _dragOperation) || (origDropIndex != _dropIndex) || (origDropOp != _dropOperation)) {
        [self setNeedsDisplayInRect:tabBarRect];
    }
    
    return _dragOperation;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return [self _MO_validateDragging:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender; {
    return [self _MO_validateDragging:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    if (_dragOperation != NSDragOperationNone) {
        [self setNeedsDisplayInRect:[self _MO_tabBarRect]];
    }
    _dropIndex = NSNotFound;
    _dragOperation = NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    BOOL result = [[self delegate] tabView:self acceptDrop:sender itemIndex:_dropIndex dropOperation:_dropOperation];
    [self setNeedsDisplayInRect:[self _MO_tabBarRect]];
    _dropIndex = NSNotFound;
    _dragOperation = NSDragOperationNone;
    return result;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    return;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if (_mtvFlags.delegateImplementsMenuForItem) {
        NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
        NSTabViewItem *item = [self tabViewItemAtPoint:p];
        int index = -1;
        if (item) {
            index = [self indexOfTabViewItem:item];
        }
        return [[self delegate] tabView:self menuForItemAtIndex:index event:event];
    } else {
        return [super menuForEvent:event];
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
