// TestController.m
// MOKit
// TableOutlineTest
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import "TestController.h"

@implementation TestController

- (id)init {
    return [self initWithWindowNibName:@"TestController"];
}

- (void)awakeFromNib {
    [self showWindow:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    _tableArray = [[NSMutableArray allocWithZone:[self zone]] init];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @"Foo", @"Row 1", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"2", @"Foo", @"Row 2", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @"Foo", @"Row 3", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"4", @"Foo", @"Row 4", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"5", @"Foo", @"Row 5", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"6", @"Foo", @"Row 6", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"7", @"Foo", @"Row 7", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"8", @"Foo", @"Row 8", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"9", @"Foo", @"Row 9", @"Bar", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"10", @"Foo", @"Row 10", @"Bar", nil]];

    NSMutableArray *tempArray;
    _outlineArray = [[NSMutableArray allocWithZone:[self zone]] init];
    tempArray = [[NSMutableArray allocWithZone:[self zone]] init];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @"Foo", @"Row 1", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"2", @"Foo", @"Row 2", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @"Foo", @"Row 3", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"4", @"Foo", @"Row 4", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"5", @"Foo", @"Row 5", @"Bar", nil]];
    [_outlineArray addObject:tempArray];
    [tempArray release];
    tempArray = [[NSMutableArray allocWithZone:[self zone]] init];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"6", @"Foo", @"Row 6", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"7", @"Foo", @"Row 7", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"8", @"Foo", @"Row 8", @"Bar", nil]];
    [_outlineArray addObject:tempArray];
    [tempArray release];
    tempArray = [[NSMutableArray allocWithZone:[self zone]] init];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"9", @"Foo", @"Row 9", @"Bar", nil]];
    [tempArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"10", @"Foo", @"Row 10", @"Bar", nil]];
    [_outlineArray addObject:tempArray];
    [tempArray release];
    tempArray = [[NSMutableArray allocWithZone:[self zone]] init];
    [_outlineArray addObject:tempArray];
    [tempArray release];
    
    [tableView registerForDraggedTypes:[NSArray arrayWithObject:@"MOTestTablePboardFormat"]];
    [[[[tableView tableColumns] objectAtIndex:1] dataCell] setMenu:contextMenu];

    [outlineView registerForDraggedTypes:[NSArray arrayWithObject:@"MOTestOutlinePboardFormat"]];
    [[[[outlineView tableColumns] objectAtIndex:1] dataCell] setMenu:contextMenu];
    [outlineView setAutoresizesOutlineColumn:NO];

    [self minRowHeightTextFieldAction:self];
    [self fontPopupAction:self];
    [self endEditingCheckboxAction:self];
    [self draggingCheckboxAction:self];

    [tableView reloadData];
    [outlineView reloadData];
}

- (IBAction)endEditingCheckboxAction:(id)sender {
    [tableView setUsesRowBasedEditing:[endEditingCheckbox state]];
    [outlineView setUsesRowBasedEditing:[endEditingCheckbox state]];
}

- (IBAction)draggingCheckboxAction:(id)sender {
    [tableView setIsDragSource:[draggingCheckbox state]];
    [outlineView setIsDragSource:[draggingCheckbox state]];
}

- (IBAction)fontPopupAction:(id)sender {
    int i = [fontPopup indexOfSelectedItem];
    NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    
    switch (i) {
        case 1:
            font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
            break;
        case 2:
            font = [NSFont fontWithName:@"Lucida Grande" size:24.0];
            break;
        case 3:
            font = [NSFont fontWithName:@"Times-Roman" size:14.0];
            break;
        case 4:
            font = [NSFont fontWithName:@"Times-Roman" size:30.0];
            break;
        case 5:
            font = [NSFont fontWithName:@"Helvetica" size:10.0];
            break;
        case 6:
            font = [NSFont fontWithName:@"Helvetica" size:30.0];
            break;
        default:
            break;
    }
    [tableView setFont:font];
    [outlineView setFont:font];
}

- (IBAction)minRowHeightTextFieldAction:(id)sender {
    int i = [minRowHeightTextField intValue];
    if (i != 0) {
        [tableView setMinRowHeight:i];
        [outlineView setMinRowHeight:i];
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tableArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    return [[_tableArray objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    [[_tableArray objectAtIndex:row] setObject:object forKey:[tableColumn identifier]];
}

- (BOOL)tableView:(MOExtendedTableView *)sender handleReturnKeyEvent:(NSEvent *)event {
    [sender createNewRow:self];
    return YES;
}

- (BOOL)tableView:(MOExtendedTableView *)sender handleDeleteKeyEvent:(NSEvent *)event {
    [sender delete:self];
    return YES;
}

- (BOOL)tableView:(MOExtendedTableView *)sender deleteRows:(NSArray *)rows {
    unsigned i = [rows count];

    while (i--) {
        int curRow = [[rows objectAtIndex:i] intValue];
        [_tableArray removeObjectAtIndex:curRow];
    }
    return YES;
}

- (BOOL)tableView:(MOExtendedTableView *)sender createNewRowAtIndex:(int)rowIndex {
    [_tableArray insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"New", @"Foo", @"New Row", @"Bar", nil] atIndex:rowIndex];
    return YES;
}

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard {
    unsigned i, c = [rows count];
    NSMutableArray *pbArray = [[NSMutableArray allocWithZone:[self zone]] init];

    for (i=0; i<c; i++) {
        int curRow = [[rows objectAtIndex:i] intValue];
        NSMutableDictionary *newDict = [[NSMutableDictionary allocWithZone:[self zone]] initWithDictionary:[_tableArray objectAtIndex:curRow]];
        [pbArray addObject:newDict];
        [newDict release];
    }

    [pboard declareTypes:[NSArray arrayWithObject:@"MOTestTablePboardFormat"] owner:nil];
    [pboard setPropertyList:pbArray forType:@"MOTestTablePboardFormat"];
    [pbArray release];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    NSDragOperation dragOp = NSDragOperationNone;
    if (op == NSTableViewDropAbove) {
        NSPasteboard *pboard = [info draggingPasteboard];
        if (pboard && [[pboard types] containsObject:@"MOTestTablePboardFormat"]) {
            dragOp = NSDragOperationGeneric;
        }
    }
    return dragOp;
}

- (BOOL)tableView:(MOExtendedTableView *)sender readRowsFromPasteboard:(NSPasteboard *)pboard row:(int)row dropOperation:(NSTableViewDropOperation)op pasteboardSourceType:(MOPasteboardSourceType)sourceType {
    NSArray *pbArray = [pboard propertyListForType:@"MOTestTablePboardFormat"];
    if (pbArray) {
        unsigned i, c = [pbArray count];
        for (i=0; i<c; i++) {
            NSMutableDictionary *newDict = [[NSMutableDictionary allocWithZone:[self zone]] initWithDictionary:[pbArray objectAtIndex:i]];
            [_tableArray insertObject:newDict atIndex:row++];
            [newDict release];
        }
    }
    return YES;
}

- (id)tableView:(MOExtendedTableView *)sender validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
    return (((!sendType || [sendType isEqualToString:@"MOTestTablePboardFormat"]) && (!returnType || [returnType isEqualToString:@"MOTestTablePboardFormat"])) ? sender : nil);
}

- (NSMenu *)tableView:(MOExtendedTableView *)sender willReturnMenu:(NSMenu *)menu forTableColumn:(NSTableColumn *)column row:(int)rowNum event:(NSEvent *)event {
    NSLog(@"tableView:willReturnMenu:");
    [[menu itemAtIndex:4] setTitle:[NSString stringWithFormat:@"Hello %@!", [[_tableArray objectAtIndex:rowNum] objectForKey:[column identifier]]]];
    return menu;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        item = _outlineArray;
    }
    return [item count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    if (!item) {
        item = _outlineArray;
    }
    return [item objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (!item || [item isKindOfClass:[NSArray class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if (!item) {
        return @"Root";
    } else if ([item isKindOfClass:[NSArray class]]) {
        if ([[tableColumn identifier] isEqualToString:@"Foo"]) {
            return [NSString stringWithFormat:@"Category %u", [_outlineArray indexOfObjectIdenticalTo:item]];
        } else {
            return [NSString stringWithFormat:@"%u children", [item count]];
        }
    } else {
        return [item objectForKey:[tableColumn identifier]];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if (!item || [item isKindOfClass:[NSArray class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    [item setObject:object forKey:[tableColumn identifier]];
}

- (BOOL)outlineView:(MOExtendedOutlineView *)sender deleteItems:(NSArray *)items {
    unsigned delCount = [items count], delIndex;
    for (delIndex=0; delIndex<delCount; delIndex++) {
        id delItem = [items objectAtIndex:delIndex];
        if (![delItem isKindOfClass:[NSArray class]]) {
            // Brute force find the item.  Obnly delete leaves.
            unsigned catCount = [_outlineArray count], catIndex;
            for (catIndex=0; catIndex<catCount; catIndex++) {
                NSMutableArray *cat = [_outlineArray objectAtIndex:catIndex];
                unsigned i = [cat indexOfObjectIdenticalTo:delItem];
                if (i != NSNotFound) {
                    [cat removeObjectAtIndex:i];
                    break;
                }
            }
        }
    }
    return YES;
}

- (BOOL)outlineView:(MOExtendedOutlineView *)sender createNewItemAtChildIndex:(int)childIndex ofItem:(id)item {
    NSLog(@"createNewItem");
    if (item) {
        [item insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"New", @"Foo", @"New Row", @"Bar", nil] atIndex:childIndex];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
    unsigned i, c = [items count];
    NSMutableArray *pbArray = [[NSMutableArray allocWithZone:[self zone]] init];
    BOOL result = NO;
    
    for (i=0; i<c; i++) {
        id curItem = [items objectAtIndex:i];
        if (![curItem isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *newDict = [[NSMutableDictionary allocWithZone:[self zone]] initWithDictionary:curItem];
            [pbArray addObject:newDict];
            [newDict release];
        }
    }

    if ([pbArray count]) {
        [pboard declareTypes:[NSArray arrayWithObject:@"MOTestOutlinePboardFormat"] owner:nil];
        [pboard setPropertyList:pbArray forType:@"MOTestOutlinePboardFormat"];
        result = YES;
    }
    [pbArray release];

    return result;
}

- (BOOL)outlineView:(MOExtendedOutlineView *)sender readItemsFromPasteboard:(NSPasteboard *)pboard item:(id)item childIndex:(int)childIndex pasteboardSourceType:(MOPasteboardSourceType)sourceType {
    if (item && [item isKindOfClass:[NSArray class]]) {
        NSArray *pbArray = [pboard propertyListForType:@"MOTestOutlinePboardFormat"];
        if (pbArray) {
            unsigned i, c = [pbArray count];
            for (i=0; i<c; i++) {
                NSMutableDictionary *newDict = [[NSMutableDictionary allocWithZone:[self zone]] initWithDictionary:[pbArray objectAtIndex:i]];
                if (childIndex == NSOutlineViewDropOnItemIndex) {
                    [item addObject:newDict];
                } else {
                    [item insertObject:newDict atIndex:childIndex++];
                }
                [newDict release];
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (NSDragOperation)outlineView:(NSOutlineView *)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index {
    NSDragOperation dragOp = NSDragOperationNone;
    if (index != NSOutlineViewDropOnItemIndex) {
        NSPasteboard *pboard = [info draggingPasteboard];
        if (pboard && [[pboard types] containsObject:@"MOTestOutlinePboardFormat"]) {
            dragOp = NSDragOperationGeneric;
        }
    }
    return dragOp;
}

- (id)outlineView:(MOExtendedOutlineView *)sender validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
    return (((!sendType || [sendType isEqualToString:@"MOTestOutlinePboardFormat"]) && (!returnType || [returnType isEqualToString:@"MOTestOutlinePboardFormat"])) ? sender : nil);
}

- (BOOL)outlineView:(MOExtendedOutlineView *)sender handleReturnKeyEvent:(NSEvent *)event {
    [sender createNewItem:self];
    return YES;
}

- (BOOL)outlineView:(MOExtendedOutlineView *)sender handleDeleteKeyEvent:(NSEvent *)event {
    [sender delete:self];
    return YES;
}

- (NSMenu *)outlineView:(MOExtendedOutlineView *)sender willReturnMenu:(NSMenu *)menu forTableColumn:(NSTableColumn *)column item:(id)item event:(NSEvent *)event {
    NSLog(@"outlineView:willReturnMenu:");
    if (item) {
        if ([item isKindOfClass:[NSArray class]]) {
            [[menu itemAtIndex:4] setTitle:[NSString stringWithFormat:@"Goodbye Category %d!", [_outlineArray indexOfObjectIdenticalTo:item]]];
        } else {
            [[menu itemAtIndex:4] setTitle:[NSString stringWithFormat:@"Goodbye %@!", [item objectForKey:[column identifier]]]];
        }
    }
    return menu;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
