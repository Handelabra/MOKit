// MOSplitViewController.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOSplitViewController
 @discussion Defines the MOSplitViewController class.
 */


#if !defined(__MOKIT_MOSplitViewController__)
#define __MOKIT_MOSplitViewController__ 1

#import <MOKit/MOKitDefines.h>
#import <MOKit/MOViewController.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @class MOSplitViewController
 @abstract A view controller that manages an NSSplitView.
 @discussion MOSplitViewController is a subclass of MOViewController that manages an NSSplitView.  Each of its subcontrollers is a split in the split view.  MOSplitViewController manages installing and uninstalling its subcontrollers' views as they are added and removed.
 */
@interface MOSplitViewController : MOViewController {
    @private
    struct {
        unsigned int vertical:1;
        unsigned int paneSplitter:1;
        unsigned int _reserved:30;
    } _svcFlags;
    void *_svcReserved;
}

/*!
    @method     splitView
    @abstract   Returns the receiver's NSSplitView.
    @discussion Returns the receiver's NSSplitView.  This method will cause the view to be loaded if necessary.
    @result     The NSSplitView.
*/
- (NSSplitView *)splitView;

/*!
    @method     setVertical:
    @abstract   Sets whether the split view is vertical.
    @discussion Sets whether the split view is vertical.  Covers NSSplitView's setVertical: method.  By providing this convenience API MOSplitViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      flag Whether the split view is vertical.
*/
- (void)setVertical:(BOOL)flag;

/*!
    @method     isVertical
    @abstract   Returns whether the split view is vertical.
    @discussion Returns whether the split view is vertical.  Covers NSSplitView's isVertical: method.  By providing this convenience API MOSplitViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     Whether the split view is vertical.
*/
- (BOOL)isVertical;

/*!
    @method     setPaneSplitter:
    @abstract   Sets whether the split view is a pane splitter.
    @discussion Sets whether the split view is a pane splitter.  Covers NSSplitView's setIsPaneSplitter: method.  By providing this convenience API MOSplitViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      flag Whether the split view is a pane splitter.
*/
- (void)setPaneSplitter:(BOOL)flag;

/*!
    @method     isPaneSplitter
    @abstract   Returns whether the split view is a pane splitter.
    @discussion Returns whether the split view is a pane splitter.  Covers NSSplitView's isPaneSplitter: method.  By providing this convenience API MOSplitViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     Whether the split view is a pane splitter.
*/
- (BOOL)isPaneSplitter;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOSplitViewController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
