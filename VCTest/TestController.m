// TestController.m
// MOKit
// VCTest
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import "TestController.h"

@implementation TestController

- (id)init {
    self = [super init];
    if (self) {
        [self setValue1:@""];
        [self setValue2:@""];
        [self setValue3:@""];
        [self setValue4:@""];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[form cellAtIndex:0] setStringValue:[self value1]];
    [[form cellAtIndex:1] setStringValue:[self value2]];
    [[form cellAtIndex:2] setStringValue:[self value3]];
    [[form cellAtIndex:3] setStringValue:[self value4]];
    
    NSSize frameSize = [[self contentView] frame].size;
    [[self contentView] MO_setMaxSize:NSMakeSize(frameSize.width*2, frameSize.height*2)]; 
    [[self contentView] MO_setMinSize:NSMakeSize(frameSize.width/2, frameSize.height/2)]; 
}


- (NSString *)value1 {
    return [[_value1 retain] autorelease];
}

- (void)setValue1:(NSString *)newValue1 {
    if (_value1 != newValue1) {
        [_value1 release];
        _value1 = [newValue1 copy];
        [[form cellAtIndex:0] setStringValue:[self value1]];
    }
}

- (NSString *)value2 {
    return [[_value2 retain] autorelease];
}

- (void)setValue2:(NSString *)newValue2 {
    if (_value2 != newValue2) {
        [_value2 release];
        _value2 = [newValue2 copy];
        [[form cellAtIndex:1] setStringValue:[self value2]];
    }
}

- (NSString *)value3 {
    return [[_value3 retain] autorelease];
}

- (void)setValue3:(NSString *)newValue3 {
    if (_value3 != newValue3) {
        [_value3 release];
        _value3 = [newValue3 copy];
        [[form cellAtIndex:2] setStringValue:[self value3]];
    }
}

- (NSString *)value4 {
    return [[_value4 retain] autorelease];
}

- (void)setValue4:(NSString *)newValue4 {
    if (_value4 != newValue4) {
        [_value4 release];
        _value4 = [newValue4 copy];
        [[form cellAtIndex:3] setStringValue:[self value4]];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    [self setValue1:[[form cellAtIndex:0] stringValue]];
    [self setValue2:[[form cellAtIndex:1] stringValue]];
    [self setValue3:[[form cellAtIndex:2] stringValue]];
    [self setValue4:[[form cellAtIndex:3] stringValue]];
}

- (NSMutableDictionary *)stateDictionaryIgnoringContentState:(BOOL)ignoreContentFlag {
    NSMutableDictionary *dict = [super stateDictionaryIgnoringContentState:ignoreContentFlag];
    if (!ignoreContentFlag) {
        [dict setObject:[self value1] forKey:@"Value1"];
        [dict setObject:[self value2] forKey:@"Value2"];
        [dict setObject:[self value3] forKey:@"Value3"];
        [dict setObject:[self value4] forKey:@"Value4"];
    }
    return dict;
}

- (void)takeStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag {
    [super takeStateDictionary:dict ignoringContentState:ignoreContentFlag];
    if (!ignoreContentFlag) {
        [self setValue1:[dict objectForKey:@"Value1"]];
        [self setValue2:[dict objectForKey:@"Value2"]];
        [self setValue3:[dict objectForKey:@"Value3"]];
        [self setValue4:[dict objectForKey:@"Value4"]];
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
