// MORegexFormatterInspector.m
// MOKit
// MOFormatterPalette
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import "MORegexFormatterInspector.h"
#import <MOKit/MOKit.h>

@implementation MORegexFormatterInspector

/************************ Left over test methods ************************/

#if 0
- (void)ok:(id)sender {
    NSLog(@"%@: object is %@", MOFullMethodName(self, _cmd), [self object]);
    [super ok:sender];
}

- (void)touch:(id)sender {
    NSLog(@"%@: object is %@", MOFullMethodName(self, _cmd), [self object]);
    [super touch:sender];
}

- (void)textDidBeginEditing:(NSNotification *)notification {
    NSLog(@"%@: object is %@", MOFullMethodName(self, _cmd), [self object]);
    [super textDidBeginEditing:notification];
}
#endif

- (id)init {
    self = [super init];
    if ([NSBundle loadNibNamed:@"MORegexFormatterInspector" owner:self] == NO) {
        NSLog(@"Couldn't load MORegexFormatterInspector.nib");
    } else {
        // Set formatter for table view.
        [[[[expressionTableView tableColumns] objectAtIndex:0] dataCell] setFormatter:[[MORESyntaxFormatter allocWithZone:[expressionTableView zone]] init]];
        // observe app updates.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillUpdate:) name:NSApplicationWillUpdateNotification object:NSApp];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (BOOL)wantsButtons {
    return NO;
}

- (BOOL)isResizable {
    return YES;
}

- (void)updateButtons {
    BOOL hasSelection = (([expressionTableView numberOfSelectedRows] > 0) ? YES : NO);
    [[expressionButtons cellAtRow:0 column:1] setEnabled:hasSelection];
}

- (void)applicationWillUpdate:(NSNotification *)notification {
    if ([[self window] isVisible]) {
        [self updateButtons];
    }
}

- (void)revert:(id)sender {
    MORegexFormatter *formatter = [self object];
    [super revert:sender];
    [allowsEmptyStringCheckbox setState:[formatter allowsEmptyString]];
    [formatPatternTextField setStringValue:[formatter formatPattern]];
    [expressionTableView reloadData];
    [self updateButtons];
}

- (void)newExpressionAction:(id)sender {
    MORegexFormatter *formatter = [self object];
    MORegularExpression *expression = [[MORegularExpression allocWithZone:[formatter zone]] initWithExpressionString:NSLocalizedStringFromTableInBundle(@"newExpression", @"FormatterPalette", [NSBundle bundleForClass:[self class]], @"Default expression for newly added expressions in MORegexFormatter inspector.")];
    if (expression) {
        [formatter addRegularExpression:expression];
    }
    [expressionTableView reloadData];
}

- (void)removeExpressionAction:(id)sender {
    MORegexFormatter *formatter = [self object];
    unsigned i;
    
    for (i = [expressionTableView numberOfRows]; i>0; --i) {
        if ([expressionTableView isRowSelected:i]) {
            [formatter removeRegularExpressionAtIndex:i];
        }
    }
    [expressionTableView reloadData];
    [self ok:sender];
}

- (void)allowsEmptyStringAction:(id)sender {
    BOOL flag = [allowsEmptyStringCheckbox state];
    [[self object] setAllowsEmptyString:flag];
    [self ok:sender];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[[self object] regularExpressions] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    return [[[self object] regularExpressions] objectAtIndex:row];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)expression forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    if (expression) {
        [[self object] replaceRegularExpressionAtIndex:row withRegularExpression:expression];
        [self ok:tableView];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    id notifier = [notification object];
    if (notifier == formatPatternTextField) {
        [[self object] setFormatPattern:[notifier stringValue]];
        [self ok:notifier];
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
