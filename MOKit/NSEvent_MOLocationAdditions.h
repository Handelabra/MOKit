// NSEvent_MOLocationAdditions.h
// MOKit
//
// Copyright © 2004-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header NSEvent_MOLocationAdditions
 @discussion Defines location utility extensions for NSEvent.
 */

#if !defined(__MOKIT_NSEvent_MOLocationAdditions__)
#define __MOKIT_NSEvent_MOLocationAdditions__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @category NSEvent(MOLocationAdditions)
 @abstract A cateogry on NSEvent that defines location utility extensions.
 @discussion A cateogry on NSEvent that defines location utility extensions.
 */
@interface NSEvent (MOLocationAdditions)

/*!
 @method MO_locationInView:
 @abstract Returns the event's location in the bounds coordinates of the given view.
 @discussion Returns the event's location in the bounds coordinates of the given view.  It is OK if the view is in a different window from the window associated with the event, but the given view must be in some window.
 @result The event's location in the bounds coordinates of the given view.
 */
- (NSPoint)MO_locationInView:(NSView *)view;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_NSEvent_MOLocationAdditions__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
