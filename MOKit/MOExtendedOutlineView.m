// MOExtendedOutlineView.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOExtendedOutlineView.h>
#import <MOKit/NSView_MOSizing.h>

@interface MOExtendedOutlineView (MOPrivate)

- (BOOL)_MO_doReadFromPasteboard:(NSPasteboard *)pboard item:(id)item childIndex:(int)childIndex pasteboardSourceType:(MOPasteboardSourceType)pbSourceType;

@end

@interface NSOutlineView (MOPrivatesOnParade)

- (BOOL)_dragShouldBeginFromMouseDown:(NSEvent *)event;
    // ---:mferris:20030103 We override this private method (found using class-dump).  This is a horrible thing to do and you should never do anything like this.  That being said, this is one of the safer uses of private API one can have.  It overrides a method, adding a small amount of additional behavior, but still calling super.  If the superclass stops calling this method, our additionakl behavior will not happen, but nothing else will break.  Similarly, if our superclass stops responding to this method then it will also necessarily not be invoking it anymore...

@end


@implementation MOExtendedOutlineView

- (void)_MO_commonInit {
    _eovFlags.dataSourceImplementsDeleteItems = NO;
    _eovFlags.dataSourceImplementsCreateNewItem = NO;
    _eovFlags.dataSourceImplementsWriteItemsToPasteboard = NO;
    _eovFlags.dataSourceImplementsReadItemsFromPasteboard = NO;
    _eovFlags.dataSourceImplementsValidRequestor = NO;
    _eovFlags.delegateImplementsHandleReturnKey = NO;
    _eovFlags.delegateImplementsHandleDeleteKey = NO;
    _eovFlags.delegateImplementsWillReturnMenu = NO;
    _eovFlags.selectionDidChange = NO;
    
    [self MO_setTakesMinSizeFromClipView:YES];    
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _MO_commonInit];
        _eovFlags.usesRowBasedEditing = NO;
        [self setMinRowHeight:0.0];
    }
    return self;
}

- (void)setUsesRowBasedEditing:(BOOL)flag {
    _eovFlags.usesRowBasedEditing = flag;
}

- (BOOL)usesRowBasedEditing {
    return _eovFlags.usesRowBasedEditing;
}

- (void)textDidEndEditing:(NSNotification *)notification {
    BOOL usesRowBasedEditing = [self usesRowBasedEditing];
    BOOL shouldEndAllEditing = NO;
    
    if (usesRowBasedEditing) {
        // Replace the notification with a new one with a different NSTextMovement in its userInfo.
        NSMutableDictionary *userInfo = (NSMutableDictionary *)[notification userInfo];
        userInfo = (userInfo ? [[NSMutableDictionary allocWithZone:[self zone]] initWithDictionary:userInfo] : [[NSMutableDictionary allocWithZone:[self zone]] init]);
        NSNumber *textMovementNum = [userInfo objectForKey:@"NSTextMovement"];
        int textMovement = NSIllegalTextMovement;
        
        if (textMovementNum) {
            textMovement = [textMovementNum intValue];
            if (textMovement == NSReturnTextMovement) {
                // Return always ends editing
                textMovement = NSIllegalTextMovement;
                shouldEndAllEditing = YES;
            } else if (textMovement == NSTabTextMovement) {
                // Allow tabbing forward in a row, but if we're in the last column, end editing.
                int editedColumn = [self editedColumn];
                if ((editedColumn < 0) || (editedColumn == [self numberOfColumns] - 1)) {
                    textMovement = NSIllegalTextMovement;
                    shouldEndAllEditing = YES;
                }
            } else if (textMovement == NSBacktabTextMovement) {
                // Allow tabbing backward in a row, but if we're in the first column, end editing.
                int editedColumn = [self editedColumn];
                if (editedColumn < 1) {
                    textMovement = NSIllegalTextMovement;
                    shouldEndAllEditing = YES;
                }                
            }
        }
        
        textMovementNum = [[NSNumber allocWithZone:[self zone]] initWithInt:textMovement];
        [userInfo setObject:textMovementNum forKey:@"NSTextMovement"];
        notification = [NSNotification notificationWithName:[notification name] object:[notification object] userInfo:userInfo];
        [textMovementNum release];
        [userInfo release];
    }
    
    [super textDidEndEditing:notification];

    if (usesRowBasedEditing && shouldEndAllEditing) {
        [[self window] makeFirstResponder:self];
    }
}

- (void)setIsDragSource:(BOOL)flag {
    _eovFlags.isDragSource = flag;
}

- (BOOL)isDragSource {
    return _eovFlags.isDragSource;
}

- (void)setFont:(NSFont *)font {
    NSArray *columns = [self tableColumns];
    unsigned i, c = [columns count];

    for (i=0; i<c; i++) {
        [[[columns objectAtIndex:i] dataCell] setFont:font];
    }
    [self setRowHeight:[font defaultLineHeightForFont]];
    [self setNeedsDisplay:YES];
}

- (void)setMinRowHeight:(float)height {
    if (_minRowHeight != height) {
        _minRowHeight = height;
        // Enforce it
        [self setRowHeight:[self rowHeight]];
    }
}

- (float)minRowHeight {
    return _minRowHeight;
}

- (void)setRowHeight:(float)rowHeight {
    float minRowHeight = [self minRowHeight];
    if (rowHeight < minRowHeight) {
        rowHeight = minRowHeight;
    }
    [super setRowHeight:rowHeight];
}

- (void)_MO_gropeDataSource {
    id aSource = [super dataSource];
    _eovFlags.dataSourceImplementsDeleteItems = ((aSource && [aSource respondsToSelector:@selector(outlineView:deleteItems:)]) ? YES : NO);
    _eovFlags.dataSourceImplementsCreateNewItem = ((aSource && [aSource respondsToSelector:@selector(outlineView:createNewItemAtChildIndex:ofItem:)]) ? YES : NO);
    _eovFlags.dataSourceImplementsWriteItemsToPasteboard = ((aSource && [aSource respondsToSelector:@selector(outlineView:writeItems:toPasteboard:)]) ? YES : NO);
    _eovFlags.dataSourceImplementsReadItemsFromPasteboard = ((aSource && [aSource respondsToSelector:@selector(outlineView:readItemsFromPasteboard:item:childIndex:pasteboardSourceType:)]) ? YES : NO);
    _eovFlags.dataSourceImplementsValidRequestor = ((aSource && [aSource respondsToSelector:@selector(outlineView:validRequestorForSendType:returnType:)]) ? YES : NO);    
    _eovFlags.dataSourceImplementsDraggingExited = ((aSource && [aSource respondsToSelector:@selector(outlineViewDraggingExited:)]) ? YES : NO);    
    _eovFlags.dataSourceImplementsDraggingOperationMask = ((aSource && [aSource respondsToSelector:@selector(outlineView:draggingSourceOperationMaskForLocal:)]) ? YES : NO);    
    _eovFlags.dataSourceImplementsDraggingBeganAt = ((aSource && [aSource respondsToSelector:@selector(outlineView:draggedImage:beganAt:)]) ? YES : NO);    
    _eovFlags.dataSourceImplementsDraggingMovedTo = ((aSource && [aSource respondsToSelector:@selector(outlineView:draggedImage:movedTo:)]) ? YES : NO);    
    _eovFlags.dataSourceImplementsDraggingEndedAt = ((aSource && [aSource respondsToSelector:@selector(outlineView:draggedImage:endedAt:operation:)]) ? YES : NO);    
    _eovFlags.dataSourceImplementsDraggingIgnoresModifiers = ((aSource && [aSource respondsToSelector:@selector(outlineViewIgnoreModifierKeysWhileDragging:)]) ? YES : NO);    
}

- (void)setDataSource:(id)aSource {
    [super setDataSource:aSource];
    [self _MO_gropeDataSource];
}

- (void)_MO_gropeDelegate {
    id aDelegate = [super delegate];
    _eovFlags.delegateImplementsHandleReturnKey = ((aDelegate && [aDelegate respondsToSelector:@selector(outlineView:handleReturnKeyEvent:)]) ? YES : NO);
    _eovFlags.delegateImplementsHandleDeleteKey = ((aDelegate && [aDelegate respondsToSelector:@selector(outlineView:handleDeleteKeyEvent:)]) ? YES : NO);
    _eovFlags.delegateImplementsWillReturnMenu = ((aDelegate && [aDelegate respondsToSelector:@selector(outlineView:willReturnMenu:forTableColumn:item:event:)]) ? YES : NO);    
}

- (void)setDelegate:(id)aDelegate {
    [super setDelegate:aDelegate];
    [self _MO_gropeDelegate];
}    

- (void)keyDown:(NSEvent *)event {
    NSString *characters = [event characters];
    BOOL handled = NO;

    // ???:mferris:20021129 Should this try to handle multi-character events?  I think they generally only happen if a key has been assigned multiple characters for insertion, not merely through any sort of coalescing of separate key events, so I think this limitation is not practically a problem.
    if (([characters length] == 1) && ![event isARepeat]) {
        unichar ch = [characters characterAtIndex:0];

        switch (ch) {
            case NSNewlineCharacter:
            case NSCarriageReturnCharacter:
            case NSEnterCharacter:
                if (_eovFlags.delegateImplementsHandleReturnKey) {
                    handled = [[self delegate] outlineView:self handleReturnKeyEvent:event];
                }
                break;
            case NSBackspaceCharacter:
            case NSDeleteCharacter:
            case NSDeleteFunctionKey:
                if (_eovFlags.delegateImplementsHandleDeleteKey) {
                    handled = [[self delegate] outlineView:self handleDeleteKeyEvent:event];
                }
                break;
        }
    }

    if (!handled) {
        [super keyDown:event];
    }
}

- (void)selectAll:(id)sender {
    _eovFlags.selectionDidChange = YES;
    [super selectAll:sender];
}

- (void)deselectAll:(id)sender {
    _eovFlags.selectionDidChange = YES;
    [super deselectAll:sender];
}

- (void)selectColumn:(int)column byExtendingSelection:(BOOL)extend {
    _eovFlags.selectionDidChange = YES;
    [super selectColumn:column byExtendingSelection:extend];
}

- (void)selectRow:(int)row byExtendingSelection:(BOOL)extend {
    _eovFlags.selectionDidChange = YES;
    [super selectRow:row byExtendingSelection:extend];
}

- (void)deselectColumn:(int)column {
    _eovFlags.selectionDidChange = YES;
    [super deselectColumn:column];
}

- (void)deselectRow:(int)row {
    _eovFlags.selectionDidChange = YES;
    [super deselectRow:row];
}

- (NSArray *)_MO_selectedItems {
    NSArray *rows = [[[self selectedRowEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *items = [[NSMutableArray allocWithZone:[self zone]] init];
    unsigned i, c = [rows count];

    for (i=0; i<c; i++) {
        id curItem = [self itemAtRow:[[rows objectAtIndex:i] intValue]];
        if (curItem) {
            [items addObject:curItem];
        }
    }
    return [items autorelease];
}

- (id)_MO_parentOfItem:(id)item getChildIndex:(int *)childIndexPtr {
    // We basically go up the rows until we find a row with an item whose level is one less than the given item.  This only works for items the outline knows about (ie if the item is inside a collapsed ancestor this will fail and return nil.  Generally it should be used with the item from a known row.)
    int row = [self rowForItem:item];

    if (row == -1) {
        // Outline does not know about item.
        if (childIndexPtr) {
            *childIndexPtr = -1;
        }
        return nil;
    }

    int origLevel = [self levelForRow:row];

    id parent = nil;
    int childIndex = 0;

    while (row-- > 0) {
        int curLevel = [self levelForRow:row];
        if (curLevel == origLevel - 1) {
            // Found the parent.
            parent = [self itemAtRow:row];
            break;
        } else if (curLevel == origLevel) {
            // Current row is a sibling of our item.
            childIndex++;
        }
    }
    if (childIndexPtr) {
        *childIndexPtr = childIndex;
    }
    return parent;
}

- (BOOL)_MO_deleteItems:(NSArray *)items {
    // If items is nil, delete selected items
    BOOL didIt = NO;

    if (_eovFlags.dataSourceImplementsDeleteItems) {
        id dataSource = [self dataSource];
        if (!items) {
            items = [self _MO_selectedItems];
        }
        NSMutableSet *parents = [[NSMutableSet allocWithZone:[self zone]] init];
        unsigned i, c = [items count];
        BOOL needFullReload = NO;
        id parent;

        for (i=0; i<c; i++) {
            parent = [self _MO_parentOfItem:[items objectAtIndex:i] getChildIndex:NULL];
            if (parent) {
                [parents addObject:parent];
            } else {
                needFullReload = YES;
                break;
            }
        }
        _eovFlags.selectionDidChange = NO;
        didIt = [dataSource outlineView:self deleteItems:items];
        if (didIt) {
            if (!_eovFlags.selectionDidChange) {
                if (needFullReload) {
                    [self reloadData];
                } else {
                    NSEnumerator *enumerator = [parents objectEnumerator];
                    while ((parent = [enumerator nextObject]) != nil) {
                        [self reloadItem:parent reloadChildren:YES];
                    }
                }
                [self deselectAll:self];
            }
        }
        [parents release];
    }
    return didIt;
}

- (IBAction)delete:(id)sender {
    if (![self _MO_deleteItems:nil]) {
        NSBeep();
    }
}

- (int)_MO_lastSelectedRow {
    // Find the last selected row
    NSEnumerator *selectedRowEnumerator = [self  selectedRowEnumerator];
    int lastRow = -1, curRow;
    NSNumber *curRowNum;
    while ((curRowNum = [selectedRowEnumerator nextObject]) != nil) {
        curRow = [curRowNum intValue];
        if (curRow > lastRow) {
            lastRow = curRow;
        }
    }
    return lastRow;
}

- (id)_MO_parentItemForInsertionAndGetChildIndex:(int *)childIndexPtr getRow:(int *)rowPtr {
    int lastRow = [self _MO_lastSelectedRow];
    id parentItem = nil;
    int childIndex = -1;
    int newRow = 0;
    BOOL incrementChild = YES;
    
    if (lastRow == -1) {
        // No selection.  We'll insert at the end of the outline.
        lastRow = [self numberOfRows];
        if (lastRow == 0) {
            parentItem = nil;
            childIndex = 0;
            newRow = 0;
            // We do not want to increment the child index in this case.
            incrementChild = NO;
        } else {
            newRow = lastRow;
            lastRow--;
        }
    } else {
        newRow = lastRow + 1;
    }
    if (childIndex == -1) {
        // Figure out the parentItem and childIndex for the row
        id item = [self itemAtRow:lastRow];
        parentItem = [self _MO_parentOfItem:item getChildIndex:&childIndex];
    }
    if ((childIndex != -1) && incrementChild) {
        // We want to insert after the last item.
        childIndex++;
    }
    if (childIndexPtr) {
        *childIndexPtr = childIndex;
    }
    if (rowPtr) {
        *rowPtr = newRow;
    }
    return parentItem;
}

- (IBAction)createNewItem:(id)sender {
    BOOL didIt = NO;

    if (_eovFlags.dataSourceImplementsCreateNewItem) {
        id dataSource = [self dataSource];
        id parentItem = nil;
        int childIndex = -1;
        int newRow = 0;
        
        parentItem = [self _MO_parentItemForInsertionAndGetChildIndex:&childIndex getRow:&newRow];
        if (childIndex != -1) {
            _eovFlags.selectionDidChange = NO;
            didIt = [dataSource outlineView:self createNewItemAtChildIndex:childIndex ofItem:parentItem];
            if (didIt) {
                if (!_eovFlags.selectionDidChange) {
                    if (parentItem) {
                        [self reloadItem:parentItem reloadChildren:YES];
                    } else {
                        [self reloadData];
                    }
                    [self selectRow:newRow byExtendingSelection:NO];
                    [self scrollRowToVisible:newRow];
                }
            }
        }
    }
    if (!didIt) {
        NSBeep();
    }
}

- (IBAction)copy:(id)sender {
    if (![self writeSelectionToPasteboard:[NSPasteboard generalPasteboard] types:nil]) {
        NSBeep();
    }
}

- (IBAction)cut:(id)sender {
    BOOL didIt = NO;

    if (_eovFlags.dataSourceImplementsDeleteItems && _eovFlags.dataSourceImplementsWriteItemsToPasteboard) {
        id dataSource = [self dataSource];
        NSArray *items = [self _MO_selectedItems];
        didIt = [dataSource outlineView:self writeItems:items toPasteboard:[NSPasteboard generalPasteboard]];
        if (didIt) {
            didIt = [self _MO_deleteItems:items];
        }
    }
    if (!didIt) {
        NSBeep();
    }
}

- (IBAction)paste:(id)sender {
    if (![self readSelectionFromPasteboard:[NSPasteboard generalPasteboard]]) {
        NSBeep();
    }
}

- (BOOL)_MO_doReadFromPasteboard:(NSPasteboard *)pboard item:(id)item childIndex:(int)childIndex pasteboardSourceType:(MOPasteboardSourceType)pbSourceType {
    id dataSource = [self dataSource];
    int origNumberOfChildren = ([dataSource outlineView:self isItemExpandable:item] ? [dataSource outlineView:self numberOfChildrenOfItem:item] : 0);
    _eovFlags.selectionDidChange = NO;
    BOOL didIt = [dataSource outlineView:self readItemsFromPasteboard:pboard item:item childIndex:childIndex pasteboardSourceType:pbSourceType];
    if (didIt) {
        if (!_eovFlags.selectionDidChange) {
            if (item) {
                [self reloadItem:item reloadChildren:YES];
            } else {
                [self reloadData];
            }
            int newNumberOfChildren = ([dataSource outlineView:self isItemExpandable:item] ? [dataSource outlineView:self numberOfChildrenOfItem:item] : 0);
            if (newNumberOfChildren > origNumberOfChildren) {
                int i, c = newNumberOfChildren - origNumberOfChildren;
                id selItem = ((childIndex == NSOutlineViewDropOnItemIndex) ? item : [dataSource outlineView:self child:childIndex ofItem:item]);
                if (selItem) {
                    int row = [self rowForItem:selItem];
                    [self selectRow:row byExtendingSelection:NO];
                    NSRect scrollRect = [self rectOfRow:row];
                    for (i=1; i<c; i++) {
                        row = [self rowForItem:[dataSource outlineView:self child:childIndex+i ofItem:item]];
                        [self selectRow:row byExtendingSelection:YES];
                        scrollRect = NSUnionRect(scrollRect, [self rectOfRow:row+i]);
                    }
                    [self scrollRectToVisible:scrollRect];
                }
            } else {
                [self deselectAll:self];
            }
        }
    }
    return didIt;
}

- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
    id requestor = nil;
    
    if (_eovFlags.dataSourceImplementsValidRequestor) {
        id dataSource = [self dataSource];
        requestor = [dataSource outlineView:self validRequestorForSendType:sendType returnType:returnType];
    }
    if (!requestor) {
        return [super validRequestorForSendType:sendType returnType:returnType];
    } else {
        return requestor;
    }
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard {
    BOOL didIt = NO;

    if (_eovFlags.dataSourceImplementsReadItemsFromPasteboard) {
        id parentItem = nil;
        int childIndex = -1;

        parentItem = [self _MO_parentItemForInsertionAndGetChildIndex:&childIndex getRow:NULL];

        if (childIndex != -1) {
            didIt = [self _MO_doReadFromPasteboard:pboard item:parentItem childIndex:childIndex pasteboardSourceType:MOPasteboardSourceTypeService];
        }
    }
    return didIt;
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types {
    BOOL didIt = NO;

    if (_eovFlags.dataSourceImplementsWriteItemsToPasteboard) {
        id dataSource = [self dataSource];
        NSArray *items = [self _MO_selectedItems];
        didIt = [dataSource outlineView:self writeItems:items toPasteboard:pboard];
    }
    return didIt;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [super draggingExited:sender];
    if (_eovFlags.dataSourceImplementsDraggingExited) {
        [[self dataSource] outlineViewDraggingExited:self];
    }
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
    if (_eovFlags.dataSourceImplementsDraggingOperationMask) {
        return [[self dataSource] outlineView:self draggingSourceOperationMaskForLocal:flag];
    } else {
        return [super draggingSourceOperationMaskForLocal:flag];
    }
}

- (void)draggedImage:(NSImage *)image beganAt:(NSPoint)screenPoint {
    if (_eovFlags.dataSourceImplementsDraggingBeganAt) {
        [[self dataSource] outlineView:self draggedImage:image beganAt:screenPoint];
    }
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    if (_eovFlags.dataSourceImplementsDraggingEndedAt) {
        [[self dataSource] outlineView:self draggedImage:image endedAt:screenPoint operation:operation];
    }
}

- (void)draggedImage:(NSImage *)image movedTo:(NSPoint)screenPoint {
    if (_eovFlags.dataSourceImplementsDraggingMovedTo) {
        [[self dataSource] outlineView:self draggedImage:image movedTo:screenPoint];
    }
}

- (BOOL)ignoreModifierKeysWhileDragging {
    if (_eovFlags.dataSourceImplementsDraggingIgnoresModifiers) {
        return [[self dataSource] outlineViewIgnoreModifierKeysWhileDragging:self];
    } else {
        return NO;
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
    int column = [self columnAtPoint:loc];
    int row = [self rowAtPoint:loc];
    NSMenu *menu = nil;
    NSTableColumn *tableColumn = nil;
    
    if ((column >= 0) || (row >= 0)) {
        // Select if necessary.
        if ((row >= 0) && ![self isRowSelected:row]) {
            [self selectRow:row byExtendingSelection:NO];
        }
        
        if (column >= 0) {
            tableColumn = [[self tableColumns] objectAtIndex:column];
            NSRect cellRect = ((row >= 0) ? [self frameOfCellAtColumn:column row:row] : NSZeroRect);
            menu = [[tableColumn dataCellForRow:row] menuForEvent:event inRect:cellRect ofView:self];
        }
    }
    if (!menu) {
        // If we did not get a per-cell menu, see if there's one for the whole outline.
        menu = [super menuForEvent:event];
    }
    
    if (_eovFlags.delegateImplementsWillReturnMenu) {
        id delegate = [self delegate];
        menu = [delegate outlineView:self willReturnMenu:menu forTableColumn:tableColumn item:((row >= 0) ? [self itemAtRow:row] : nil) event:event];
    }

    if (menu) {
        // Become first responder if necessary.
        [[self window] makeFirstResponder:self];
    }

    return menu;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
    SEL action = [anItem action];

    if (action == @selector(delete:)) {
        // Enabled if there's a selection and our dataSource implements the right method.
        return ((_eovFlags.dataSourceImplementsDeleteItems && ([self numberOfSelectedRows] > 0)) ? YES : NO);
    } else if (action == @selector(createNewRow:)) {
        // Enabled if our dataSource implements the right method.
        return ((_eovFlags.dataSourceImplementsCreateNewItem) ? YES : NO);
    } else if (action == @selector(copy:)) {
        // Enabled if there's a selection and our dataSource implements the right method.
        return ((_eovFlags.dataSourceImplementsWriteItemsToPasteboard && ([self numberOfSelectedRows] > 0)) ? YES : NO);
    } else if (action == @selector(cut:)) {
        // Enabled if there's a selection and our dataSource implements the right method.
        return ((_eovFlags.dataSourceImplementsWriteItemsToPasteboard && _eovFlags.dataSourceImplementsDeleteItems && ([self numberOfSelectedRows] > 0)) ? YES : NO);
    } else if (action == @selector(paste:)) {
        // Enabled if the pasteboard contains a type we can use and our dataSource implements the right method.
        BOOL enable = _eovFlags.dataSourceImplementsReadItemsFromPasteboard;
        if (enable && _eovFlags.dataSourceImplementsValidRequestor) {
            id dataSource = [self dataSource];
            NSArray *types = [[NSPasteboard generalPasteboard] types];
            unsigned i, c = [types count];
            for (i=0; (i<c) && enable; i++) {
                enable = (([dataSource outlineView:self validRequestorForSendType:nil returnType:[types objectAtIndex:i]] != nil) ? YES : NO);
            }
        }
        return enable;
    }
    return YES;
}

- (BOOL)_dragShouldBeginFromMouseDown: (NSEvent *)event {
    if ([self isDragSource]) {
        return [super _dragShouldBeginFromMouseDown:event];
    } else {
        return NO;
    }
    
}

#define MIN_ROW_HEIGHT_KEY @"com.lorax.MOExtendedOutlineView.minRowHeight"
#define ROW_BASED_EDITING_KEY @"com.lorax.MOExtendedOutlineView.rowBasedEditing"

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    if ([coder allowsKeyedCoding]) {
        [coder encodeFloat:_minRowHeight forKey:MIN_ROW_HEIGHT_KEY];
        [coder encodeBool:_eovFlags.usesRowBasedEditing forKey:ROW_BASED_EDITING_KEY];
    } else {
        [NSException raise:NSGenericException format:@"MOExtendedOutlineView does not support old-style non-keyed NSCoding."];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        if ([coder allowsKeyedCoding]) {
            [self _MO_commonInit];

            [self setMinRowHeight:[coder decodeFloatForKey:MIN_ROW_HEIGHT_KEY]];
            [self setUsesRowBasedEditing:[coder decodeBoolForKey:ROW_BASED_EDITING_KEY]];

            // Make sure we get the scoop on the dataSource and delegate in case NSOutlineView does not call the set methods in its initWithCoder:.
            [self _MO_gropeDataSource];
            [self _MO_gropeDelegate];
        } else {
            [NSException raise:NSGenericException format:@"MOExtendedOutlineView does not support old-style non-keyed NSCoding."];
        }
    }
    return self;
}

@end

@implementation NSObject (MOExtendedOutlineViewDefaultDataSourceMethods)

// Default implementation of the acceptDrop: dataSource method to call the more generic readRowsFromPasteboard: method if it is implemented.  This allows a single dataSource method to deal with pasteboard reading for drag & drop, copy/paste, and services.
- (BOOL)outlineView:(NSOutlineView *)sender acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)childIndex {
    if ([sender respondsToSelector:@selector(_MO_doReadFromPasteboard:item:childIndex:pasteboardSourceType:)] && [self respondsToSelector:@selector(outlineView:readItemsFromPasteboard:item:childIndex:pasteboardSourceType:)]) {
        MOPasteboardSourceType sourceType = (([info draggingSource] == sender) ? MOPasteboardSourceTypeSelfDrop : MOPasteboardSourceTypeDrop);
        BOOL retval = [(MOExtendedOutlineView *)sender _MO_doReadFromPasteboard:[info draggingPasteboard] item:item childIndex:childIndex pasteboardSourceType:sourceType];
        return retval;
    } else {
        return NO;
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
