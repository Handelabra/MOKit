// NSEvent_MOLocationAdditions.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/NSEvent_MOLocationAdditions.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/MORuntimeUtilities.h>

@implementation NSEvent (MOLocationAdditions)

- (NSPoint)MO_locationInView:(NSView *)view {
    MOAssertClass(view, NSView);

    NSWindow *eventWindow = [self window];
    NSWindow *viewWindow = [view window];
    
    MOAssertClass(viewWindow, NSWindow);
    
    NSPoint loc = [self locationInWindow];
    if (eventWindow != viewWindow) {
        loc = [eventWindow convertBaseToScreen:loc];
        loc = [viewWindow convertScreenToBase:loc];
    }
    return [view convertPoint:loc fromView:nil];
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
