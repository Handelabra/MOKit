// MORESyntaxFormatter.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MORESyntaxFormatter.h>
#import <MOKit/MORegularExpression.h>
#import <MOKit/MOAssertions.h>

@implementation MORESyntaxFormatter

- (NSString *)stringForObjectValue:(id)obj {
    return ((obj && [obj isKindOfClass:[MORegularExpression class]]) ? [obj expressionString] : @"");
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error {
    MOAssertStringOrNil(string);
    
    if (string && ![string isEqualToString:@""]) {
        MORegularExpression *expression = [[MORegularExpression allocWithZone:[self zone]] initWithExpressionString:string];
        if (expression) {
            if (obj) {
                *obj = expression;
            }
            return YES;
        } else {
            if (error) {
                *error = NSLocalizedStringFromTableInBundle(@"Regular expression string is not valid.", @"MOKit", [NSBundle bundleForClass:[self class]], @"Displayable error message for mal-formed regular expressions.");
            }
            return NO;
        }
    } else {
        // nil or empty string
        if (obj) {
            *obj = nil;
        }
        return YES;
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
