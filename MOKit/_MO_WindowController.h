// _MO_WindowController.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

// This private class is for use by MOViewController only.  It is used when a MOViewController lives in its own window.

#if !defined(__MOKIT__MO_WindowController__)
#define __MOKIT__MO_WindowController__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
@class MOViewController;

@interface _MO_WindowController : NSWindowController {
    @private
    MOViewController *_rootViewController;
    
    void *_lastFirstResponder;
    void *_lastFocusController;
    id _lastVisibleFocusController;
    
    NSWindow *_overlayWindow;
    
    struct {
        unsigned int windowIsLoaded:1;
        unsigned int _reserved:31;
    } _mwcFlags;
}

- (id)initWithRootViewController:(MOViewController *)root;
    // Only supported init method.  root must be non-nil.

- (id)rootViewController;

- (void)controllerDidChangeLabel:(MOViewController *)controller;

@end

MOKIT_PRIVATE_EXTERN NSString *_MO_FocusRingNeedsDisplayNotification;

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT__MO_WindowController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
