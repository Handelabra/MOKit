// TestController.m
// MOKit
// VLVTest
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
    
    [vlView disableLayout];
    [vlView addStackedView:contentView1 withLabel:@"Test View 1"];
    [contentView1 release], contentView1 = nil;
    [vlView addStackedView:contentView2 withLabel:@"Test View 2"];
    [contentView2 release], contentView2 = nil;
    [vlView addStackedView:contentView3 withLabel:@"Test View 3"];
    [contentView3 release], contentView3 = nil;
    [vlView addStackedView:contentView4 withLabel:@"Test View 4"];
    [contentView4 release], contentView4 = nil;
    [vlView enableLayout];
    
    [vlView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];

    [animateCheckbox setState:[MOViewListView usesAnimation]];
    [appearancePopup selectItemAtIndex:[vlView labelBarAppearance] - 1];
}

- (IBAction)toggleControlSize:(id)sender {
    if ([vlView controlSize] == NSRegularControlSize) {
        [vlView setControlSize:NSSmallControlSize];
    } else {
        [vlView setControlSize:NSRegularControlSize];
    }
}

- (IBAction)toggleAnimate:(id)sender {
    [MOViewListView setUsesAnimation:(([animateCheckbox state] == NSOnState) ? YES : NO)];
}

- (IBAction)appearancePopupAction:(id)sender {
    [vlView setLabelBarAppearance:[appearancePopup indexOfSelectedItem] + 1];
}

- (BOOL)viewListView:(MOViewListView *)viewListView writeItem:(MOViewListViewItem *)item toPasteboard:(NSPasteboard*)pboard {
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pboard setString:[item label] forType:NSStringPboardType];
    return YES;
}

- (void)viewListView:(MOViewListView *)viewListView dragEndedWithOperation:(NSDragOperation)dragOp forItem:(MOViewListViewItem *)item {
    NSLog(@"dragEnded:%d", dragOp);
}

- (NSDragOperation)viewListView:(MOViewListView *)viewListView validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOViewListViewDropOperation)op {
    return NSDragOperationGeneric;
}

- (BOOL)viewListView:(MOViewListView *)viewListView acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOViewListViewDropOperation)op {
    if (op == MOViewListViewDropOnItem) {
        NSPasteboard *pboard = [info draggingPasteboard];
        NSString *str = [pboard stringForType:NSStringPboardType];
        if (str) {
            [[vlView viewListViewItemAtIndex:itemIndex] setLabel:str];
        }
    } else {
        NSLog(@"Drop above item at index %d", itemIndex);
    }
    return YES;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
