// TestController.h
// MOKit
// VCTest
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#if !defined(__MOVCTEST_TestController__)
#define __MOVCTEST_TestController__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKit.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
@interface TestController : MOViewController {
    IBOutlet NSForm *form;
    
    NSString *_value1;
    NSString *_value2;
    NSString *_value3;
    NSString *_value4;
}

- (NSString *)value1;
- (void)setValue1:(NSString *)newValue1;
- (NSString *)value2;
- (void)setValue2:(NSString *)newValue2;
- (NSString *)value3;
- (void)setValue3:(NSString *)newValue3;
- (NSString *)value4;
- (void)setValue4:(NSString *)newValue4;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOVCTEST_TestController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
