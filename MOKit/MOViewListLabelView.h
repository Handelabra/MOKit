// MOViewListLabelView.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOViewListLabelView
 @discussion Defines the MOViewListLabelView class.
 */


#if !defined(__MOKIT_MOViewListLabelView__)
#define __MOKIT_MOViewListLabelView__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif

@class MOViewListView;
@class MOViewListViewItem;

/*!
 @class MOViewListLabelView
 @abstract ABSTRACT GOES HERE
 @discussion MOViewListLabelView is, like, um, really cool, ya know.
 */
@interface MOViewListLabelView : NSView {
    @private
    MOViewListView *_viewListView;
    MOViewListViewItem *_item;
    struct {
        unsigned int isTrackingDisclosureTriangle:1;
        unsigned int trackingInDisclosureTriangle:1;
        unsigned int couldBeADrag:1;
        unsigned int _reserved:29;
    } _vllvFlags;
}

- (id)initWithViewListView:(MOViewListView *)viewListView andViewListViewItem:(MOViewListViewItem *)item;

- (MOViewListView *)viewListView;
- (MOViewListViewItem *)viewListViewItem;

- (void)invalidate;

+ (float)labelHeightForFont:(NSFont *)font;

- (NSRect)frameForLabelText;
- (NSRect)frameForDisclosureControl;

- (void)drawLabelBarBackground;

/*!
 @method mouseDown:
 @abstract Override to track clicks in disclosure controls and implement label dragging.
 @discussion Override to track clicks in disclosure controls and implement label dragging.
 @param event The event.
 */
- (void)mouseDown:(NSEvent *)event;

/*!
 @method mouseDragged:
 @abstract Override to track clicks in disclosure controls and implement label dragging.
 @discussion Override to track clicks in disclosure controls and implement label dragging.
 @param event The event.
 */
- (void)mouseDragged:(NSEvent *)event;

/*!
 @method mouseUp:
 @abstract Override to track clicks in disclosure controls and implement label dragging.
 @discussion Override to track clicks in disclosure controls and implement label dragging.
 @param event The event.
 */
- (void)mouseUp:(NSEvent *)event;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOViewListLabelView__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
