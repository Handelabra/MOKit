// NSView_MOSizing.h
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header NSView_MOSizing
 @discussion Defines the MOSizing category on NSView.
 */

#if !defined(__MOKIT_NSView_MOSizing__)
#define __MOKIT_NSView_MOSizing__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @category NSView(MOSizing)
 @abstract NSView extension methods to implement min and max sizing behaviors.
 @discussion NSView extension methods implementing enforced minimum and maximum sizes for views.  Also supports a view automatically getting its minimum size from the size of the NSClipView it is a subview of.

 This category adds capabilities to all NSViews but does not affect the normal behavior of a view unless one or more of the "set" methods in the category are used.  The category is implemented using the method replacement methods from MORuntimeUtilties.  Specifically, +[NSObject MO_replaceInstanceSelector:withMethodForSelector:] is used to replace five NSView methods: -dealloc, -setFrame:, -setFrameSize:, -viewWillMoveToSuperview: and -viewDidMoveToSuperview.

 Method replacement is not to be taken lightly, although done properly it should be safe.  But becuase it is a slightly dicey business there are two mechanisms in MOKit to disable features that use method replacement.

 One is a build time switch:  if the macro MOKIT_NO_METHOD_REPLACEMENT is defined (via -DMOKIT_NO_METHOD_REPLACEMENT in the compiler flags) then no features of MOKit that use method replacement will be compiled into the framework.  The public API that depends on it will still be present but will be ineffective.

 The other is a runtime switch: if the user default MOKitAllowMethodReplacement is set to NO (it defaults to YES) then no method replacement will be done.  Again, the public API that depends on it will still be present but will be ineffective.

 Note that the minimum and maximum sizes and the setting for whether the min size tracks the clip view are NOT coded when a view is archived and so cannot be saved in a nib file.
 */
@interface NSView (MOSizing)

/// Basic min size and max size API

/*!
 @method MO_minSize
 @abstract Returns the minimum size for a view.
 @discussion This method returns the minimum size of a view. If MO_takesMinSizeFromClipView is YES and the view is currently the direct subview of an NSClipView, then this method returns the current bounds size of the clip view. If MO_setMinSize: has been previously called, this returns the size that was set with that method. Otherwise, this returns the size {0.0, 0.0}.
 @result The minimum size of the receiver.
 */
- (NSSize)MO_minSize;

/*!
 @method MO_setMinSize:
 @abstract Sets the minimum size for a view.
 @discussion This method sets the minimum size of a view. If MO_takesMinSizeFromClipView is YES and the view is currently the direct subview of an NSClipView, then the size set with this method will have no effect and the minimum size will instead be the size of the clip view's bounds rectangle.
 @param minSize The minimum size to be used for the receiver.
 */
- (void)MO_setMinSize:(NSSize)minSize;

/*!
 @method MO_maxSize
 @abstract Returns the maximum size for a view.
 @discussion This method returns the maximum size of a view. If MO_setMaxSize: has been previously called, this returns the size that was set with that method. Otherwise, this returns the size {MAXFLOAT, MAXFLOAT}.
 @result The maximum size of the receiver.
 */
- (NSSize)MO_maxSize;

/*!
 @method MO_setMaxSize:
 @abstract Sets the maximum size for a view.
 @discussion This method sets the maximum size of a view.
 @param maxSize The maximum size to be used for the receiver.
 */
- (void)MO_setMaxSize:(NSSize)maxSize;

/// NSClipView min size API

/*!
 @method MO_takesMinSizeFromClipView
 @abstract Returns whether the minimum size of the view should be the bounds size of the clip view it is in.
 @discussion This method returns whether the minimum size of the view should be the bounds size of the clip view it is in. If this is YES and the view is a direct subview of an NSClipView then MO_minSize will return the bounds size of the clip view. This setting has no effect when the receiver is not a subview of an NSClipView.
 @result YES if the view's minimum size should be the bounds size of its clip view, NO if not.
 */
- (BOOL)MO_takesMinSizeFromClipView;

/*!
 @method MO_setTakesMinSizeFromClipView:
 @abstract Sets whether the minimum size of the view should be the bounds size of the clip view it is in.
 @discussion This method sets whether the minimum size of the view should be the bounds size of the clip view it is in. If set to YES and the view is a direct subview of an NSClipView then MO_minSize will return the bounds size of the clip view. This setting has no effect when the receiver is not a subview of an NSClipView.

 This method is often called from an NSView subclass' -initWithFrame: override.  For example MOViewListView does this since it generally expects to live inside an NSClipView.  Views that use this feature are encouraged to have a -sizeToFit method.  When the clipview's size changes and the minimum size of the view is updated, if the view implemented -sizeToFit, it will be called.  This allows the view to shrink itself if its minSize just got smaller and it was bigger than it might naturally want to be, for example.
 @param flag YES if the view's minimum size should be the bounds size of its clip view, NO if not.
 */
- (void)MO_setTakesMinSizeFromClipView:(BOOL)flag;

/*!
    @method     MO_sizeConstraintsDidChange
    @abstract   This method is called whenever the min or max size contraints on a view may have changed.
    @discussion This method is called whenever the min or max size contraints on a view may have changed.  You should never call it directly, but you may wish to override it.  A common override of this method would invoke -sizeToFit to make sure the view is as close to its natural size as possible given the new contraints.  The default implementation does nothing.
*/
- (void)MO_sizeConstraintsDidChange;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_NSView_MOSizing__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
