// MOViewListViewController.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOViewListViewController
 @discussion Defines the MOViewListViewController class.
 */


#if !defined(__MOKIT_MOViewListViewController__)
#define __MOKIT_MOViewListViewController__ 1

#import <MOKit/MOKitDefines.h>
#import <MOKit/MOViewController.h>
#import <MOKit/MOViewListView.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @class MOViewListViewController
 @abstract A view controller that manages an MOViewListView.
 @discussion MOViewListViewController is a subclass of MOViewController that manages a MOViewListView.  Each of its subcontrollers is an item in the view list view.  MOViewListViewController ensures that a subcontroller's view is loaded only when its item in the view list view is first expanded.
 */
@interface MOViewListViewController : MOViewController {
    @private
    MOViewListView *_viewListView;
    NSControlSize _controlSize;
    MOViewListViewLabelBarAppearance _labelBarAppearance;
    NSColor *_backgroundColor;
    NSArray *_savedExpandedItemsArray;
    id _delegate;
    struct {
        unsigned int expandedItemsAreContentConfiguration:1;
        unsigned int allowsSubcontrollerDragging:1;
        unsigned int allowsSubcontrollerDropping:1;
        unsigned int delegateImplementsValidateDrop:1;
        unsigned int delegateImplementsAcceptDrop:1;
        unsigned int _reserved:27;
    } _vlvcFlags;
    void *_vlvcReserved;
}

/*!
    @method     viewListView
    @abstract   Returns the receiver's MOViewListView.
    @discussion Returns the receiver's MOViewListView.  This method will cause the view to be loaded if necessary.
    @result     The MOViewListView.
*/
- (MOViewListView *)viewListView;

/*!
    @method     scrollView
    @abstract   Returns the receiver's NSScrollView.
    @discussion Returns the receiver's NSScrollView.  This method will cause the view to be loaded if necessary.
    @result     The NSScrollView.
*/
- (NSScrollView *)scrollView;

/*!
    @method     allowsSubcontrollerDragging
    @abstract   Returns whether the receiver allows item labels to be dragged.
    @discussion Returns whether the receiver allows item labels to be dragged.  NO by default.  If set to YES then item labels can be dragged from the view lst view.  A dragged label's subcontroller is placed on the pasteboard using the MOViewControllerPboardType.
    @result     Whether the receiver allows item labels to be dragged.
*/
- (BOOL)allowsSubcontrollerDragging;

/*!
    @method     setAllowsSubcontrollerDragging:
    @abstract   Sets whether the receiver allows item labels to be dragged.
    @discussion Sets whether the receiver allows item labels to be dragged.  NO by default.  If set to YES then item labels can be dragged from the view lst view.  A dragged label's subcontroller is placed on the pasteboard using the MOViewControllerPboardType.
    @param      flag Whether the receiver allows item labels to be dragged.
*/
- (void)setAllowsSubcontrollerDragging:(BOOL)flag;

/*!
    @method     allowsSubcontrollerDropping
    @abstract   Returns whether the receiver allows controllers to be dropped on it to create new subcontrollers.
    @discussion Returns whether the receiver allows controllers to be dropped on it to create new subcontrollers.  NO by default.  If set to YES then controllers can be dragged onto the view list view to create new subcontrollers.  Pasteboard content of MOViewControllerPboardType is accepted as a drag type.
    @result     Whether the receiver allows controllers to be dropped on it to create new tabs.
*/
- (BOOL)allowsSubcontrollerDropping;

/*!
    @method     setAllowsSubcontrollerDropping:
    @abstract   Sets whether the receiver allows controllers to be dropped on it to create new subcontrollers.
    @discussion Sets whether the receiver allows controllers to be dropped on it to create new subcontrollers.  NO by default.  If set to YES then controllers can be dragged onto the view list view to create new subcontrollers.  Pasteboard content of MOViewControllerPboardType is accepted as a drag type.  A MOViewListViewController may still accept drops of things other than controllers on or between its labels without this being set to YES.
    @param      flag Whether the receiver allows controllers to be dropped on it to create new subcontrollers.
*/
- (void)setAllowsSubcontrollerDropping:(BOOL)flag;

/*!
    @method     expandedItemsAreContentConfiguration
    @abstract   Returns whether the expanded items are considered content configuration.
    @discussion Returns whether the expanded items are considered content configuration.  By default, this is NO and the expanded items are considered geometry configuration.
    @result     Whether the expanded items are considered content configuration.
*/
- (BOOL)expandedItemsAreContentConfiguration;

/*!
    @method     setExpandedItemsAreContentConfiguration:
    @abstract   Sets whether the expanded items are considered content configuration.
    @discussion Sets whether the expanded items are considered content configuration.  By default, this is NO and the expanded items are considered geometry configuration.  If the set of items that the receiver manages is based somehow on the data content it is displaying, this API can be used to make the MOViewListViewController save that state as content configuration.
    @param      flag Whether the expanded items are considered content configuration.
*/
- (void)setExpandedItemsAreContentConfiguration:(BOOL)flag;

/*!
    @method setControlSize:
    @abstract Sets the receiver's view's control size.
    @discussion Sets the receiver's view's control size.  Covers MOViewListView's setControlSize: method.  By providing this convenience API MOViewListViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param size The control size.
*/
- (void)setControlSize:(NSControlSize)size;

/*!
    @method controlSize
    @abstract Returns the receiver's view's control size.
    @discussion Returns the receiver's view's control size.  Covers MOViewListView's controlSize method.  By providing this convenience API MOViewListViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result The control size.
*/
- (NSControlSize)controlSize;

/*!
    @method setLabelBarAppearance:
    @abstract Sets the receiver's view's label bar appearance.
    @discussion Sets the receiver's view's label bar appearance.  Covers MOViewListView's setLabelBarAppearance: method.  By providing this convenience API MOViewListViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param scheme The appearance type constant.
*/
- (void)setLabelBarAppearance:(MOViewListViewLabelBarAppearance)labelBarAppearance;

/*!
    @method labelBarAppearance
    @abstract Returns the receiver's view's label bar appearance.
    @discussion Returns the receiver's view's label bar appearance.  Covers MOViewListView's labelBarAppearance method.  By providing this convenience API MOViewListViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param scheme The appearance type constant.
*/
- (MOViewListViewLabelBarAppearance)labelBarAppearance;

/*!
    @method setBackgroundColor:
    @abstract Sets the receiver's view's background color.
    @discussion Sets the receiver's view's background color.  Covers MOViewListView's setBackgroundColor: method.  By providing this convenience API MOViewListViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param color The background color.
*/
- (void)setBackgroundColor:(NSColor *)color;

/*!
    @method backgroundColor
    @abstract Returns the receiver's view's background color.
    @discussion Returns the receiver's view's background color.  Covers MOViewListView's backgroundColor method.  By providing this convenience API MOViewListViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result The background color.
*/
- (NSColor *)backgroundColor;

/*!
    @method     delegate
    @abstract   Returns the receiver's delegate.
    @discussion Returns the receiver's delegate.
    @result     The delegate.
*/
- (id)delegate;

/*!
    @method     setDelegate:
    @abstract   Sets the receiver's delegate.
    @discussion Sets the receiver's delegate.
    @param      delegate The delegate.
*/
- (void)setDelegate:(id)delegate;

@end

@interface NSObject (MOViewListViewControllerDelegate)

/*!
    @method     viewListViewController:validateDrop:proposedItemIndex:proposedDropOperation:
    @abstract   Validates a proposed drop operation.
    @discussion Validates a proposed drop operation.  !!!:mferris:20030603 needs more detail
    @param      viewListViewController The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The proposed drop index.
    @param      op The proposed drop operation.
    @result     The drag operation that would occur if the drop happened at the current point.
*/
- (NSDragOperation)viewListViewController:(MOViewListViewController *)viewListViewController validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOViewListViewDropOperation)op;

/*!
    @method     viewListViewController:acceptDrop:itemIndex:dropOperation:
    @abstract   Performs the drop.
    @discussion Performs the drop.  !!!:mferris:20030603 needs more detail
    @param      viewListViewController The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The drop index.
    @param      op The drop operation.
    @result     Whether the drop was completed successfully.
*/
- (BOOL)viewListViewController:(MOViewListViewController *)viewListViewController acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOViewListViewDropOperation)op;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOViewListViewController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
