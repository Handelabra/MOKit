// TestController.h
// MOKit
// VLVTest
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#if !defined(__MOVLVTEST_TestController__)
#define __MOVLVTEST_TestController__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKit.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
@interface TestController : NSWindowController {
    IBOutlet MOViewListView *vlView;

    IBOutlet NSView *contentView1;
    IBOutlet NSView *contentView2;
    IBOutlet NSView *contentView3;
    IBOutlet NSView *contentView4;

    IBOutlet NSButton *animateCheckbox;
    IBOutlet NSPopUpButton *appearancePopup;
}

- (IBAction)toggleControlSize:(id)sender;
- (IBAction)toggleAnimate:(id)sender;
- (IBAction)appearancePopupAction:(id)sender;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOVLVTEST_TestController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
