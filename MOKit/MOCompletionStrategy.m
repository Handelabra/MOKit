// MOCompletionStrategy.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOCompletionStrategy.h>
#import <MOKit/MOCompletionManager.h>
#import <MOKit/MOAssertions.h>

typedef enum {
    MOInitialVersion = 1,
} MOClassVersion;

static const MOClassVersion MOCurrentClassVersion = MOInitialVersion;

@implementation MOCompletionStrategy

+ (void)initialize {
    // Set the version.  Load classes, and init class variables.
    if (self == [MOCompletionStrategy class])  {
        [self setVersion:MOCurrentClassVersion];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if (self == [MOCompletionStrategy class]) {
        MOAbstractClassError(MOCompletionStrategy);
        return nil;
    }
    return [super allocWithZone:zone];
}

- (NSArray *)matchesForPrefixString:(NSString *)str newPrefixString:(NSString **)newStr basePath:(NSString *)basePath {
    MOSubclassResponsibilityError(MOCompletionStrategy);
    return nil;
}

- (NSString *)fullStringForPrefixString:(NSString *)prefixStr completionString:(NSString *)completionStr isInitialPrefixMatch:(BOOL)initialPrefixMatch basePath:(NSString *)basePath {
    MOAssertStringOrNil(prefixStr);
    MOAssertStringOrNil(completionStr);
    MOAssertStringOrNil(basePath);
    return (prefixStr ? (completionStr ? [prefixStr stringByAppendingString:completionStr] : prefixStr) : completionStr);
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
