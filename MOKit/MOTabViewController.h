// MOTabViewController.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOTabViewController
 @discussion Defines the MOTabViewController class.
 */


#if !defined(__MOKIT_MOTabViewController__)
#define __MOKIT_MOTabViewController__ 1

#import <MOKit/MOKitDefines.h>
#import <MOKit/MOViewController.h>
#import <MOKit/MOTabView.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
 @class MOTabViewController
 @abstract A view controller that manages an NSTabView.
 @discussion MOTabViewController is a subclass of MOViewController that manages an NSTabView.  Each of its subcontrollers is a tab in the tab view.  MOTabViewController manages swapping the views as the selected tab changes and ensures that a subcontroller's view is loaded only when it is about to be installed as the selected tab item view.
 */
@interface MOTabViewController : MOViewController {
    @private
    NSFont *_font;
    NSTabViewType _tabViewType;
    NSControlTint _controlTint;
    NSControlSize _controlSize;
    int _selectedItemIndex;
    id _delegate;
    struct {
        unsigned int selectedTabIsContentConfiguration:1;
        unsigned int allowsTruncatedLabels:1;
        unsigned int drawsBackground:1;
        unsigned int allowsSubcontrollerDragging:1;
        unsigned int allowsSubcontrollerDropping:1;
        unsigned int delegateImplementsValidateDrop:1;
        unsigned int delegateImplementsAcceptDrop:1;
        unsigned int delegateImplementsMenuForItem:1;
        unsigned int _reserved:25;
    } _tvcFlags;
    void *_tvcReserved;
}

/*!
    @method     tabViewItemClass
    @abstract   Returns the subclass of NSTabViewItem to use.
    @discussion Returns the subclass of NSTabViewItem to use.  MOTabViewController manages the tab view items of its tab view.  This method is provided in case a subclass wants to use a subclass of NSTabViewItem.  The default return value of this method is [NSTabViewItem class].
    @result     The subclass of NSTabViewItem to use.
*/
+ (Class)tabViewItemClass;

/*!
    @method     tabView
    @abstract   Returns the receiver's NSTabView.
    @discussion Returns the receiver's NSTabView.  This method will cause the view to be loaded if necessary.
    @result     The NSTabView.
*/
- (id)tabView;

/*!
    @method     indexOfSelectedSubcontroller
    @abstract   Returns the index of the selected subcontroller.
    @discussion Returns the index of the selected subcontroller.  This method does NOT cause the view to be loaded if it is not already.
    @result     The index of the selected subcontroller.
*/
- (int)indexOfSelectedSubcontroller;

/*!
    @method     selectSubcontrollerAtIndex:
    @abstract   Selects the subcontroller at the given index, making it the active tab.
    @discussion Selects the subcontroller at the given index, making it the active tab.  This method does NOT cause the view to be loaded if it is not already.
    @param      selIndex The index.
*/
- (void)selectSubcontrollerAtIndex:(int)selIndex;

/*!
    @method     selectedSubcontroller
    @abstract   Returns the subcontroller for the selected tab
    @discussion Returns the subcontroller for the selected tab.  This method does NOT cause the view to be loaded if it is not already.
    @result     The subcontroller.
*/
- (id)selectedSubcontroller;

/*!
    @method     selectSubcontroller:
    @abstract   Selects the given subcontroller, making it the active tab.
    @discussion Selects the given subcontroller, making it the active tab.  This method does NOT cause the view to be loaded if it is not already.
    @param      subcontroller The subcontroller.
*/
- (void)selectSubcontroller:(MOViewController *)subcontroller;

/*!
    @method     allowsSubcontrollerDragging
    @abstract   Returns whether the receiver allows tabs to be dragged.
    @discussion Returns whether the receiver allows tabs to be dragged.  NO by default.  If set to YES then tabs can be dragged off the tab bar.  A dragged tab's subcontroller is placed on the pasteboard using the MOViewControllerPboardType.
    @result     Whether the receiver allows tabs to be dragged.
*/
- (BOOL)allowsSubcontrollerDragging;

/*!
    @method     setAllowsSubcontrollerDragging:
    @abstract   Sets whether the receiver allows tabs to be dragged.
    @discussion Sets whether the receiver allows tabs to be dragged.  NO by default.  If set to YES then tabs can be dragged off the tab bar.  A dragged tab's subcontroller is placed on the pasteboard using the MOViewControllerPboardType.
    @param      flag Whether the receiver allows tabs to be dragged.
*/
- (void)setAllowsSubcontrollerDragging:(BOOL)flag;

/*!
    @method     allowsSubcontrollerDropping
    @abstract   Returns whether the receiver allows controllers to be dropped on it to create new tabs.
    @discussion Returns whether the receiver allows controllers to be dropped on it to create new tabs.  NO by default.  If set to YES then controllers can be dragged onto the tab bar to create new tabs.  Pasteboard content of MOViewControllerPboardType is accepted as a drag type.
    @result     Whether the receiver allows controllers to be dropped on it to create new tabs.
*/
- (BOOL)allowsSubcontrollerDropping;

/*!
    @method     setAllowsSubcontrollerDropping:
    @abstract   Sets whether the receiver allows controllers to be dropped on it to create new tabs.
    @discussion Sets whether the receiver allows controllers to be dropped on it to create new tabs.  NO by default.  If set to YES then controllers can be dragged onto the tab bar to create new tabs.  Pasteboard content of MOViewControllerPboardType is accepted as a drag type.  A MOTabViewController may still accept drops of things other than controllers on or between its tabs without this being set to YES.
    @param      flag Whether the receiver allows controllers to be dropped on it to create new tabs.
*/
- (void)setAllowsSubcontrollerDropping:(BOOL)flag;

/*!
    @method     selectedTabIsContentConfiguration
    @abstract   Returns whether the selected tab is considered content configuration.
    @discussion Returns whether the selected tab is considered content configuration.  By default, this is NO and the selected tab is considered geometry configuration.
    @result     Whether the selected tab is considered content configuration.
*/
- (BOOL)selectedTabIsContentConfiguration;

/*!
    @method     setSelectedTabIsContentConfiguration:
    @abstract   Sets whether the selected tab is considered content configuration.
    @discussion Sets whether the selected tab is considered content configuration.  By default, this is NO and the selected tab is considered geometry configuration.  If the set of tabs that the receiver manages is based somehow on the data content it is displaying, this API can be used to make the MOTabViewController save that state as content configuration.
    @param      flag Whether the selected tab is considered content configuration.
*/
- (void)setSelectedTabIsContentConfiguration:(BOOL)flag;

/*!
    @method     font
    @abstract   Returns the receiver's view's font.
    @discussion Returns the receiver's view's font.  Covers NSTabView's font method.  By providing this convenience API MOTabViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.
    @result     The receiver's font.
*/
- (NSFont *)font;

/*!
    @method     setFont:
    @abstract   Sets the receiver's view's font.
    @discussion Sets the receiver's view's font.  Covers NSTabView's setFont: method.  By providing this convenience API MOTabViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      font The font.
*/
- (void)setFont:(NSFont *)font;

/*!
    @method     tabViewType
    @abstract   Returns the receiver's view's tabViewType.
    @discussion Returns the receiver's view's tabViewType.  Covers NSTabView's tabViewType method.  By providing this convenience API MOTabViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     The receiver's tabViewType.
 */
- (NSTabViewType)tabViewType;

/*!
    @method     setTabViewType:
    @abstract   Sets the receiver's view's tabViewType.
    @discussion Sets the receiver's view's tabViewType.  Covers NSTabView's setTabViewType: method.  By providing this convenience API MOTabViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      tabViewType The tabViewType.
 */
- (void)setTabViewType:(NSTabViewType)tabViewType;

/*!
    @method     allowsTruncatedLabels
    @abstract   Returns the receiver's view's allowsTruncatedLabels.
    @discussion Returns the receiver's view's allowsTruncatedLabels.  Covers NSTabView's allowsTruncatedLabels method.  By providing this convenience API MOTabViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     The receiver's allowsTruncatedLabels.
 */
- (BOOL)allowsTruncatedLabels;

/*!
    @method     setAllowsTruncatedLabels:
    @abstract   Sets the receiver's view's allowsTruncatedLabels.
    @discussion Sets the receiver's view's allowsTruncatedLabels.  Covers NSTabView's setAllowsTruncatedLabels: method.  By providing this convenience API MOTabViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      flag The allowsTruncatedLabels.
 */
- (void)setAllowsTruncatedLabels:(BOOL)flag;

/*!
    @method     drawsBackground
    @abstract   Returns the receiver's view's drawsBackground.
    @discussion Returns the receiver's view's drawsBackground.  Covers NSTabView's drawsBackground method.  By providing this convenience API MOTabViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     The receiver's drawsBackground.
 */
- (BOOL)drawsBackground;

/*!
    @method     setDrawsBackground:
    @abstract   Sets the receiver's view's drawsBackground.
    @discussion Sets the receiver's view's drawsBackground.  Covers NSTabView's setDrawsBackground: method.  By providing this convenience API MOTabViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      flag The drawsBackground.
 */
- (void)setDrawsBackground:(BOOL)flag;

/*!
    @method     controlTint
    @abstract   Returns the receiver's view's controlTint.
    @discussion Returns the receiver's view's controlTint.  Covers NSTabView's controlTint method.  By providing this convenience API MOTabViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     The receiver's controlTint.
 */
- (NSControlTint)controlTint;

/*!
    @method     setControlTint:
    @abstract   Sets the receiver's view's controlTint.
    @discussion Sets the receiver's view's controlTint.  Covers NSTabView's setControlTint: method.  By providing this convenience API MOTabViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      controlTint The controlTint.
 */
- (void)setControlTint:(NSControlTint)controlTint;

/*!
    @method     controlSize
    @abstract   Returns the receiver's view's controlSize.
    @discussion Returns the receiver's view's controlSize.  Covers NSTabView's controlSize method.  By providing this convenience API MOTabViewController also makes it possible to query this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @result     The receiver's controlSize.
 */
- (NSControlSize)controlSize;

/*!
    @method     setControlSize:
    @abstract   Sets the receiver's view's controlSize.
    @discussion Sets the receiver's view's controlSize.  Covers NSTabView's setControlSize: method.  By providing this convenience API MOTabViewController also makes it possible to set this state without having to cause the view to be created if it is not yet needed.  This state is saved and restored as part of the controller's geometry configuration.
    @param      controlSize The controlSize.
 */
- (void)setControlSize:(NSControlSize)controlSize;

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

@interface NSObject (MOTabViewControllerDelegate)

/*!
    @method     tabViewController:validateDrop:proposedItemIndex:proposedDropOperation:
    @abstract   Validates a proposed drop operation.
    @discussion Validates a proposed drop operation.  !!!:mferris:20030505 needs more detail
    @param      tabViewController The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The proposed drop index.
    @param      op The proposed drop operation.
    @result     The drag operation that would occur if the drop happened at the current point.
*/
- (NSDragOperation)tabViewController:(MOTabViewController *)tabViewController validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOTabViewDropOperation)op;

/*!
    @method     tabViewController:acceptDrop:itemIndex:dropOperation:
    @abstract   Performs the drop.
    @discussion Performs the drop.  !!!:mferris:20030505 needs more detail
    @param      tabViewController The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The drop index.
    @param      op The drop operation.
    @result     Whether the drop was completed successfully.
*/
- (BOOL)tabViewController:(MOTabViewController *)tabViewController acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOTabViewDropOperation)op;

/*!
    @method     tabViewController:menuForItemAtIndex:event:
    @abstract   Message sent to delegate when the tab view controller needs a context menu.
    @discussion Message sent to delegate when the tab view controller needs a context menu.  This message is sent when the user right-clicks or control-clicks in the tab bar of a tab view.  The delegate can return a menu to use as the context menu.  This method covers the similar method from MOTabView exposing the ability to supply the context menu to the delegate of the controller.
    @param      tabViewController The sender.
    @param      itemIndex The index of the tab that the mouse is over, or -1 if the mouse is over the tab bar but not an actual tab.
    @param      event The event.
    @result     A menu to use as the context menu or nil if there should be no menu.
*/
- (NSMenu *)tabViewController:(MOTabViewController *)tabViewController menuForItemAtIndex:(int)itemIndex event:(NSEvent *)event;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOTabViewController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
