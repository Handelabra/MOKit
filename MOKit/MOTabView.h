// MOTabView.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOTabView
 @discussion Defines the MOTabView class.
 */


#if !defined(__MOKIT_MOTabView__)
#define __MOKIT_MOTabView__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
    @typedef    MOTabViewDropOperation
    @abstract   Enumeration for types of drop operations supported by MOTabView.
    @discussion Enumeration for types of drop operations supported by MOTabView.
    @constant   MOTabViewDropOnItem Drop operation constant for dropping something "onto" a tab.
    @constant   MOTabViewDropBeforeItem Drop operation constant for dropping something "between" tabs (ie dropping a new tab into a tab view).
*/
typedef enum { MOTabViewDropOnItem, MOTabViewDropBeforeItem } MOTabViewDropOperation;

/*!
 @class MOTabView
 @abstract MOTabView extends NSTabView to add drag & drop support.
 @discussion MOTabView extends NSTabView to add drag & drop support.  The tab view's delegate can implement various new methods to support dragging of tabs and accepting drops.  As a drag source, MOTabView allows tabs to be dragged.  As a drag destination MOTabView supports drops either "onto" a tab or "between" tabs.  In both cases, it is left to the delegate to deal with the actual pasteboard content.
 */
@interface MOTabView : NSTabView {
    @private
    struct {
        unsigned int delegateImplementsWriteItem:1;
        unsigned int delegateImplementsDragEnded:1;
        unsigned int delegateImplementsValidateDrop:1;
        unsigned int delegateImplementsAcceptDrop:1;
        unsigned int delegateImplementsMenuForItem:1;
        unsigned int _reserved:27;
    } _mtvFlags;
    
    NSTabViewItem *_draggingItem;
    
    int _dropIndex;
    MOTabViewDropOperation _dropOperation;
    NSDragOperation _dragOperation;
}

/*!
    @method     dragImageForItem:event:dragImageOffset:
    @abstract   Returns the image to use for dragging a tab.
    @discussion Returns the image to use for dragging a tab.  MOTabView will create a default image, but subclasses can override if they need to do something different.  This method will be called with dragImageOffset set to NSZeroPoint, but it can be modified to re-position the returned image.  A dragImageOffset of NSZeroPoint will cause the image to be centered under the mouse.
    @param      dragItem The NSTabViewItem that will be dragged.
    @param      dragEvent The event that started the drag.
    @param      dragImageOffsetPtr A pointer to a point that can be filled in to provide an image offset.
    @result     The image to use for the drag.
*/
- (NSImage *)dragImageForItem:(NSTabViewItem *)dragItem event:(NSEvent *)dragEvent dragImageOffset:(NSPointPointer)dragImageOffsetPtr;

/*!
    @method     setDropItemIndex:dropOperation:
    @abstract   Method to allow delegate to reposition a drop.
    @discussion Method to allow delegate to reposition a drop.  To be used from tabView:validateDrop:proposedItemIndex:proposedDropOperation: if you wish to "re-target" the proposed drop.  To specify a drop on the second item, one would specify itemIndex=1, and op=MOTabViewDropOnItem.  To specify a drop after the last item, one would specify row=[[tabView tabViewItems] count], and op=MOTabViewDropBeforeItem.
    @param      itemIndex The item index.
    @param      op The drop operation.
*/
- (void)setDropItemIndex:(int)itemIndex dropOperation:(MOTabViewDropOperation)op;

@end

/*!
    @category   NSObject(MOTabViewDelegate)
    @abstract   Informal delegate protocol for MOTabView.
    @discussion Informal delegate protocol for MOTabView.  This category declares the methods that MOTabView will send to its delegate if it implements them.
*/
@interface NSObject (MOTabViewDelegate)

/*!
    @method     tabView:writeItem:toPasteboard:
    @abstract   Writes the given tab view item to the pasteboard.
    @discussion Writes the given tab view item to the pasteboard.  This method is invoked by MOTabView when the user starts to drag a tab.  To refuse the drag, return NO.  To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  The drag image and other drag related information will be set up and provided by the tab view once this call returns with YES. 
    @param      tabView The sender.
    @param      item The item for the tab being dragged.
    @param      pboard The pasteboard to write to.
    @result     Whether the delegate wrote the item to the pasteboard.
*/
- (BOOL)tabView:(id)tabView writeItem:(NSTabViewItem *)item toPasteboard:(NSPasteboard*)pboard;

/*!
    @method     tabView:dragEndedAtPoint:withOperation:forItem:
    @abstract   Notification that a drag of a tab item has concluded.
    @discussion Notification that a drag of a tab item has concluded.  This method is called after a drag initiated by the tab view has ended.  dragOp indicates what the operation was and can be used to determine if the drag succeeded or not.
    @param      tabView The sender.
    @param      aPoint The drop point in screen coordinates.
    @param      dragOp The drag operation (NSDragOperationNone if there was no successful drop).
    @param      item The item for the tab that was dragged.
*/
- (void)tabView:(id)tabView dragEndedAtPoint:(NSPoint)aPoint withOperation:(NSDragOperation)dragOp forItem:(NSTabViewItem *)item;

/*!
    @method     tabView:validateDrop:proposedItemIndex:proposedDropOperation:
    @abstract   Validates a proposed drop operation.
    @discussion Validates a proposed drop operation.  This method is used by MOTabView to determine a valid drop target.  Based on the mouse position, the tab view will suggest a proposed drop location.  This method must return a value that indicates which dragging operation the delegate will perform.  The delegate may "re-target" a drop if desired by calling -setDropItemIndex:dropOperation: on the sender and then returning something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).  See the documentation for -setDropItemIndex:dropOperation: for more info on what the itemIndex and op mean.
    @param      tabView The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The proposed drop index.
    @param      op The proposed drop operation.
    @result     The drag operation that would occur if the drop happened at the current point.
*/
- (NSDragOperation)tabView:(id)tabView validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOTabViewDropOperation)op;

/*!
    @method     tabView:acceptDrop:itemIndex:dropOperation:
    @abstract   Performs the drop.
    @discussion Performs the drop.  This method is called when the mouse is released over a tab view that previously decided to allow a drop via the -tabView:validateDrop:proposedItemIndex:proposedDropOperation: method.  The delegate should incorporate the data from the dragging pasteboard at this time.  The itemIndex and op will be whatever values were last passed to setDropItemIndex:dropOperation: or, if the delegate never called that method, the last proposed index and op that were passed to the -tabView:validateDrop:proposedItemIndex:proposedDropOperation: method.
    @param      tabView The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The drop index.
    @param      op The drop operation.
    @result     Whether the drop was completed successfully.
*/
- (BOOL)tabView:(id)tabView acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOTabViewDropOperation)op;


/*!
    @method     tabView:menuForItemAtIndex:event:
    @abstract   Message sent to delegate when the tab view needs a context menu.
    @discussion Message sent to delegate when the tab view needs a context menu.  This message is sent when the user right-clicks or control-clicks in the tab bar of a tab view.  The delegate can return a menu to use as the context menu.
    @param      tabView The sender
    @param      itemIndex The index of the tab that the mouse is over, or -1 if the mouse is over the tab bar but not an actual tab.
    @param      event The event.
    @result     A menu to use as the context menu or nil if there should be no menu.
*/
- (NSMenu *)tabView:(id)tabView menuForItemAtIndex:(int)itemIndex event:(NSEvent *)event;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOTabView__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
