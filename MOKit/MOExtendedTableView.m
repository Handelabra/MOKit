// MOExtendedTableView.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOExtendedTableView.h>
#import <MOKit/NSView_MOSizing.h>

@interface MOExtendedTableView (MOPrivate)

- (BOOL)_MO_doReadFromPasteboard:(NSPasteboard *)pboard row:(int)row dropOperation:(NSTableViewDropOperation)dropOp pasteboardSourceType:(MOPasteboardSourceType)pbSourceType;

@end

@interface NSTableView (MOPrivatesOnParade)

- (BOOL)_dragShouldBeginFromMouseDown:(NSEvent *)event;
    // ---:mferris:20030103 We override this private method (found using class-dump).  This is a horrible thing to do and you should never do anything like this.  That being said, this is one of the safer uses of private API one can have.  It overrides a method, adding a small amount of additional behavior, but still calling super.  If the superclass stops calling this method, our additionakl behavior will not happen, but nothing else will break.  Similarly, if our superclass stops responding to this method then it will also necessarily not be invoking it anymore...

@end

@implementation MOExtendedTableView

- (void)_MO_commonInit {
    _etvFlags.dataSourceImplementsDeleteRows = NO;
    _etvFlags.dataSourceImplementsCreateNewRow = NO;
    _etvFlags.dataSourceImplementsWriteRowsToPasteboard = NO;
    _etvFlags.dataSourceImplementsReadRowsFromPasteboard = NO;
    _etvFlags.dataSourceImplementsValidRequestor = NO;
    _etvFlags.delegateImplementsHandleReturnKey = NO;
    _etvFlags.delegateImplementsHandleDeleteKey = NO;
    _etvFlags.delegateImplementsWillReturnMenu = NO;
    _etvFlags.selectionDidChange = NO;
    
    [self MO_setTakesMinSizeFromClipView:YES];    
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _MO_commonInit];
        _etvFlags.usesRowBasedEditing = NO;
        [self setMinRowHeight:0.0];
    }
    return self;
}

- (void)setUsesRowBasedEditing:(BOOL)flag {
    _etvFlags.usesRowBasedEditing = flag;
}

- (BOOL)usesRowBasedEditing {
    return _etvFlags.usesRowBasedEditing;
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
    _etvFlags.isDragSource = flag;
}

- (BOOL)isDragSource {
    return _etvFlags.isDragSource;
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
    _etvFlags.dataSourceImplementsDeleteRows = ((aSource && [aSource respondsToSelector:@selector(tableView:deleteRows:)]) ? YES : NO);
    _etvFlags.dataSourceImplementsCreateNewRow = ((aSource && [aSource respondsToSelector:@selector(tableView:createNewRowAtIndex:)]) ? YES : NO);
    _etvFlags.dataSourceImplementsWriteRowsToPasteboard = ((aSource && [aSource respondsToSelector:@selector(tableView:writeRows:toPasteboard:)]) ? YES : NO);
    _etvFlags.dataSourceImplementsReadRowsFromPasteboard = ((aSource && [aSource respondsToSelector:@selector(tableView:readRowsFromPasteboard:row:dropOperation:pasteboardSourceType:)]) ? YES : NO);
    _etvFlags.dataSourceImplementsValidRequestor = ((aSource && [aSource respondsToSelector:@selector(tableView:validRequestorForSendType:returnType:)]) ? YES : NO);    
    _etvFlags.dataSourceImplementsDraggingExited = ((aSource && [aSource respondsToSelector:@selector(tableViewDraggingExited:)]) ? YES : NO);    
    _etvFlags.dataSourceImplementsDraggingOperationMask = ((aSource && [aSource respondsToSelector:@selector(tableView:draggingSourceOperationMaskForLocal:)]) ? YES : NO);    
    _etvFlags.dataSourceImplementsDraggingBeganAt = ((aSource && [aSource respondsToSelector:@selector(tableView:draggedImage:beganAt:)]) ? YES : NO);    
    _etvFlags.dataSourceImplementsDraggingMovedTo = ((aSource && [aSource respondsToSelector:@selector(tableView:draggedImage:movedTo:)]) ? YES : NO);    
    _etvFlags.dataSourceImplementsDraggingEndedAt = ((aSource && [aSource respondsToSelector:@selector(tableView:draggedImage:endedAt:operation:)]) ? YES : NO);    
    _etvFlags.dataSourceImplementsDraggingIgnoresModifiers = ((aSource && [aSource respondsToSelector:@selector(tableViewIgnoreModifierKeysWhileDragging:)]) ? YES : NO);    
}

- (void)setDataSource:(id)aSource {
    [super setDataSource:aSource];
    [self _MO_gropeDataSource];
}

- (void)_MO_gropeDelegate {
    id aDelegate = [super delegate];
    _etvFlags.delegateImplementsHandleReturnKey = ((aDelegate && [aDelegate respondsToSelector:@selector(tableView:handleReturnKeyEvent:)]) ? YES : NO);
    _etvFlags.delegateImplementsHandleDeleteKey = ((aDelegate && [aDelegate respondsToSelector:@selector(tableView:handleDeleteKeyEvent:)]) ? YES : NO);
    _etvFlags.delegateImplementsWillReturnMenu = ((aDelegate && [aDelegate respondsToSelector:@selector(tableView:willReturnMenu:forTableColumn:row:event:)]) ? YES : NO);    
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
                if (_etvFlags.delegateImplementsHandleReturnKey) {
                    handled = [[self delegate] tableView:self handleReturnKeyEvent:event];
                }
                break;
            case NSBackspaceCharacter:
            case NSDeleteCharacter:
            case NSDeleteFunctionKey:
                if (_etvFlags.delegateImplementsHandleDeleteKey) {
                    handled = [[self delegate] tableView:self handleDeleteKeyEvent:event];
                }
                break;
        }
    }

    if (!handled) {
        [super keyDown:event];
    }
}

- (void)selectAll:(id)sender {
    _etvFlags.selectionDidChange = YES;
    [super selectAll:sender];
}

- (void)deselectAll:(id)sender {
    _etvFlags.selectionDidChange = YES;
    [super deselectAll:sender];
}

- (void)selectColumn:(int)column byExtendingSelection:(BOOL)extend {
    _etvFlags.selectionDidChange = YES;
    [super selectColumn:column byExtendingSelection:extend];
}

- (void)selectRow:(int)row byExtendingSelection:(BOOL)extend {
    _etvFlags.selectionDidChange = YES;
    [super selectRow:row byExtendingSelection:extend];
}

- (void)deselectColumn:(int)column {
    _etvFlags.selectionDidChange = YES;
    [super deselectColumn:column];
}

- (void)deselectRow:(int)row {
    _etvFlags.selectionDidChange = YES;
    [super deselectRow:row];
}

- (IBAction)delete:(id)sender {
    BOOL didIt = NO;
    
    if (_etvFlags.dataSourceImplementsDeleteRows) {
        id dataSource = [self dataSource];
        NSArray *rows = [[[self selectedRowEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        _etvFlags.selectionDidChange = NO;
        didIt = [dataSource tableView:self deleteRows:rows];
        if (didIt) {
            if (!_etvFlags.selectionDidChange) {
                [self reloadData];
                [self deselectAll:self];
            }
        }
    }
    if (!didIt) {
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

- (IBAction)createNewRow:(id)sender {
    BOOL didIt = NO;

    if (_etvFlags.dataSourceImplementsCreateNewRow) {
        id dataSource = [self dataSource];
        int lastRow = [self _MO_lastSelectedRow];

        if (lastRow == -1) {
            // No selection, insert at the end of the table
            lastRow = [self numberOfRows];
        } else {
            // Add one becuase we want to insert after the last selected row
            lastRow++;
        }

        _etvFlags.selectionDidChange = NO;
        didIt = [dataSource tableView:self createNewRowAtIndex:lastRow];
        if (didIt) {
            if (!_etvFlags.selectionDidChange) {
                [self reloadData];
                [self selectRow:lastRow byExtendingSelection:NO];
                [self scrollRowToVisible:lastRow];
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

    if (_etvFlags.dataSourceImplementsDeleteRows && _etvFlags.dataSourceImplementsWriteRowsToPasteboard) {
        id dataSource = [self dataSource];
        NSArray *rows = [[[self selectedRowEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        _etvFlags.selectionDidChange = NO;
        didIt = [dataSource tableView:self writeRows:rows toPasteboard:[NSPasteboard generalPasteboard]];
        if (didIt) {
            didIt = [dataSource tableView:self deleteRows:rows];
        }
        if (didIt) {
            if (!_etvFlags.selectionDidChange) {
                [self reloadData];
                [self deselectAll:self];
            }
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

- (BOOL)_MO_doReadFromPasteboard:(NSPasteboard *)pboard row:(int)row dropOperation:(NSTableViewDropOperation)dropOp pasteboardSourceType:(MOPasteboardSourceType)pbSourceType {
    id dataSource = [self dataSource];
    int origNumberOfRows = [self numberOfRows];
    _etvFlags.selectionDidChange = NO;
    BOOL didIt = [dataSource tableView:self readRowsFromPasteboard:pboard row:row dropOperation:dropOp pasteboardSourceType:pbSourceType];
    if (didIt) {
        if (!_etvFlags.selectionDidChange) {
            [self reloadData];
            int newNumerOfRows = [self numberOfRows];
            if (newNumerOfRows > origNumberOfRows) {
                int i, c = newNumerOfRows - origNumberOfRows;
                [self selectRow:row byExtendingSelection:NO];
                NSRect scrollRect = [self rectOfRow:row];
                for (i=1; i<c; i++) {
                    [self selectRow:row+i byExtendingSelection:YES];
                    scrollRect = NSUnionRect(scrollRect, [self rectOfRow:row+i]);
                }
                [self scrollRectToVisible:scrollRect];
            } else {
                [self deselectAll:self];
            }
        }
    }
    return didIt;
}

- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
    id requestor = nil;
    
    if (_etvFlags.dataSourceImplementsValidRequestor) {
        id dataSource = [self dataSource];
        requestor = [dataSource tableView:self validRequestorForSendType:sendType returnType:returnType];
    }
    if (!requestor) {
        return [super validRequestorForSendType:sendType returnType:returnType];
    } else {
        return requestor;
    }
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard {
    BOOL didIt = NO;

    if (_etvFlags.dataSourceImplementsReadRowsFromPasteboard) {
        int lastRow = [self _MO_lastSelectedRow];

        if (lastRow == -1) {
            // No selection, insert at the end of the table
            lastRow = [self numberOfRows];
        } else {
            // We want to insert above the row after the last selected row (ie below the last selected row).
            lastRow++;
        }
        didIt = [self _MO_doReadFromPasteboard:pboard row:lastRow dropOperation:NSTableViewDropAbove pasteboardSourceType:MOPasteboardSourceTypeService];
    }
    return didIt;
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types {
    BOOL didIt = NO;

    if (_etvFlags.dataSourceImplementsWriteRowsToPasteboard) {
        id dataSource = [self dataSource];
        NSArray *rows = [[[self selectedRowEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        didIt = [dataSource tableView:self writeRows:rows toPasteboard:pboard];
    }
    return didIt;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [super draggingExited:sender];
    if (_etvFlags.dataSourceImplementsDraggingExited) {
        [[self dataSource] tableViewDraggingExited:self];
    }
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
    if (_etvFlags.dataSourceImplementsDraggingOperationMask) {
        return [[self dataSource] tableView:self draggingSourceOperationMaskForLocal:flag];
    } else {
        return [super draggingSourceOperationMaskForLocal:flag];
    }
}

- (void)draggedImage:(NSImage *)image beganAt:(NSPoint)screenPoint {
    if (_etvFlags.dataSourceImplementsDraggingBeganAt) {
        [[self dataSource] tableView:self draggedImage:image beganAt:screenPoint];
    }
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    if (_etvFlags.dataSourceImplementsDraggingEndedAt) {
        [[self dataSource] tableView:self draggedImage:image endedAt:screenPoint operation:operation];
    }
}

- (void)draggedImage:(NSImage *)image movedTo:(NSPoint)screenPoint {
    if (_etvFlags.dataSourceImplementsDraggingMovedTo) {
        [[self dataSource] tableView:self draggedImage:image movedTo:screenPoint];
    }
}

- (BOOL)ignoreModifierKeysWhileDragging {
    if (_etvFlags.dataSourceImplementsDraggingIgnoresModifiers) {
        return [[self dataSource] tableViewIgnoreModifierKeysWhileDragging:self];
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
        // If we did not get a per-cell menu, see if there's one for the whole table.
        menu = [super menuForEvent:event];
    }
    
    if (_etvFlags.delegateImplementsWillReturnMenu) {
        id delegate = [self delegate];
        menu = [delegate tableView:self willReturnMenu:menu forTableColumn:tableColumn row:row event:event];
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
        return ((_etvFlags.dataSourceImplementsDeleteRows && ([self numberOfSelectedRows] > 0)) ? YES : NO);
    } else if (action == @selector(createNewRow:)) {
        // Enabled if our dataSource implements the right method.
        return ((_etvFlags.dataSourceImplementsCreateNewRow) ? YES : NO);
    } else if (action == @selector(copy:)) {
        // Enabled if there's a selection and our dataSource implements the right method.
        return ((_etvFlags.dataSourceImplementsWriteRowsToPasteboard && ([self numberOfSelectedRows] > 0)) ? YES : NO);
    } else if (action == @selector(cut:)) {
        // Enabled if there's a selection and our dataSource implements the right method.
        return ((_etvFlags.dataSourceImplementsWriteRowsToPasteboard && _etvFlags.dataSourceImplementsDeleteRows && ([self numberOfSelectedRows] > 0)) ? YES : NO);
    } else if (action == @selector(paste:)) {
        // Enabled if the pasteboard contains a type we can use and our dataSource implements the right method.
        BOOL enable = _etvFlags.dataSourceImplementsReadRowsFromPasteboard;
        if (enable && _etvFlags.dataSourceImplementsValidRequestor) {
            id dataSource = [self dataSource];
            NSArray *types = [[NSPasteboard generalPasteboard] types];
            unsigned i, c = [types count];
            for (i=0; (i<c) && enable; i++) {
                enable = (([dataSource tableView:self validRequestorForSendType:nil returnType:[types objectAtIndex:i]] != nil) ? YES : NO);
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

#define MIN_ROW_HEIGHT_KEY @"com.lorax.MOExtendedTableView.minRowHeight"
#define ROW_BASED_EDITING_KEY @"com.lorax.MOExtendedTableView.rowBasedEditing"

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    if ([coder allowsKeyedCoding]) {
        [coder encodeFloat:_minRowHeight forKey:MIN_ROW_HEIGHT_KEY];
        [coder encodeBool:_etvFlags.usesRowBasedEditing forKey:ROW_BASED_EDITING_KEY];
    } else {
        [NSException raise:NSGenericException format:@"MOExtendedTableView does not support old-style non-keyed NSCoding."];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        if ([coder allowsKeyedCoding]) {
            [self _MO_commonInit];

            [self setMinRowHeight:[coder decodeFloatForKey:MIN_ROW_HEIGHT_KEY]];
            [self setUsesRowBasedEditing:[coder decodeBoolForKey:ROW_BASED_EDITING_KEY]];

            // Make sure we get the scoop on the dataSource and delegate in case NSTableView does not call the set methods in its initWithCoder:.
            [self _MO_gropeDataSource];
            [self _MO_gropeDelegate];
        } else {
            [NSException raise:NSGenericException format:@"MOExtendedTableView does not support old-style non-keyed NSCoding."];
        }
    }
    return self;
}

@end

@implementation NSObject (MOExtendedTableViewDefaultDataSourceMethods)

// Default implementation of the acceptDrop: dataSource method to call the more generic readRowsFromPasteboard: method if it is implemented.  This allows a single dataSource method to deal with pasteboard reading for drag & drop, copy/paste, and services.
- (BOOL)tableView:(NSTableView*)sender acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
    if ([sender respondsToSelector:@selector(_MO_doReadFromPasteboard:row:dropOperation:pasteboardSourceType:)] && [self respondsToSelector:@selector(tableView:readRowsFromPasteboard:row:dropOperation:pasteboardSourceType:)]) {
        MOPasteboardSourceType sourceType = (([info draggingSource] == sender) ? MOPasteboardSourceTypeSelfDrop : MOPasteboardSourceTypeDrop);
        BOOL retval = [(id)sender _MO_doReadFromPasteboard:[info draggingPasteboard] row:row dropOperation:op pasteboardSourceType:sourceType];
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
