// MOExtendedOutlineView.h
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOExtendedOutlineView
 @discussion Defines the MOExtendedOutlineView class.
 */


#if !defined(__MOKIT_MOExtendedOutlineView__)
#define __MOKIT_MOExtendedOutlineView__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>
#import <MOKit/MOExtendedTableView.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @class MOExtendedOutlineView
 @abstract MOExtendedOutlineView adds a number of new features to the standard NSOutlineView.
 @discussion MOExtendedOutlineView adds a number of new features to the standard NSOutlineView.  There are a few simple additional features such as being able to alter the way editing ends, setting a minimum row height, a convenience method for changing the font of the whole outline, and support for per-cell context menus.

 MOExtendedOutlineView also adds a number of new, optional, dataSource and delegate methods.  It defines dataSource API for user-initiated item creation and deletion with accompanying action methods to wire controls to.  It defines delegate API to allow the delegate to easily handle return or delete key presses in the outline.  It adds delegate API to provide, replace or alter a outline's context menu.  And, there's dataSource API that unifies handling of pasteboard contents for drag&drop, copy/paste, and Services.
 */
@interface MOExtendedOutlineView : NSOutlineView {
    @private
    float _minRowHeight;
    struct {
        unsigned int usesRowBasedEditing:1;
        unsigned int isDragSource:1;
        unsigned int dataSourceImplementsDeleteItems:1;
        unsigned int dataSourceImplementsCreateNewItem:1;
        unsigned int dataSourceImplementsWriteItemsToPasteboard:1;
        unsigned int dataSourceImplementsReadItemsFromPasteboard:1;
        unsigned int dataSourceImplementsValidRequestor:1;
        unsigned int dataSourceImplementsDraggingExited:1;
        unsigned int dataSourceImplementsDraggingOperationMask:1;
        unsigned int dataSourceImplementsDraggingBeganAt:1;
        unsigned int dataSourceImplementsDraggingMovedTo:1;
        unsigned int dataSourceImplementsDraggingEndedAt:1;
        unsigned int dataSourceImplementsDraggingIgnoresModifiers:1;
        unsigned int delegateImplementsHandleReturnKey:1;
        unsigned int delegateImplementsHandleDeleteKey:1;
        unsigned int delegateImplementsWillReturnMenu:1;
        unsigned int selectionDidChange:1;
        unsigned int _reserved:15;
    } _eovFlags;
    void *_MO_reserved;
}

/*!
 @method setUsesRowBasedEditing:
 @abstract Sets whether editing is row-based.
 @discussion Sets whether editing is row-based.  NO by default, in which case the outline behaves like NSOutlineView.  If this is turned on then it effects what happens as textual editing of a cell's value ends.  Hitting return or Enter will end editing instead of starting editing in the next row.  Tabbing and backtabbing will take you horizontally through the cells in a row but tabbing off the end of a row or shift-tabbing off the beginning will cause editing to end instead of changing rows.

 This behavior can often be desirable in situations where editing the value of a row is not the most common operation and it is rarely desirable to edit multiple values in multiple rows all at once. 
 @param flag Whether editing is row-based.
 */
- (void)setUsesRowBasedEditing:(BOOL)flag;

/*!
 @method usesRowBasedEditing
 @abstract Returns whether editing is row-based.
 @discussion Returns whether editing is row-based.  NO by default, in which case the outline behaves like NSOutlineView.  If this is turned on then it effects what happens as textual editing of a cell's value ends.  Hitting return or Enter will end editing instead of starting editing in the next row.  Tabbing and backtabbing will take you horizontally through the cells in a row but tabbing off the end of a row or shift-tabbing off the beginning will cause editing to end instead of changing rows.

 This behavior can often be desirable in situations where editing the value of a row is not the most common operation and it is rarely desirable to edit multiple values in multiple rows all at once.
 @result Whether editing is row-based.
 */
- (BOOL)usesRowBasedEditing;

/*!
 @method textDidEndEditing:
 @abstract Overridden to support row-based editing.
 @discussion This method is overridden to support row-based editing. It always calls super but sometimes it replaces the notification with a different one that alters the NSTextMovement key in the userInfo of the original notification.
 @param notification The notification.
 */
- (void)textDidEndEditing:(NSNotification *)notification;

/*!
 @method setIsDragSource:
 @abstract Does the outline act as a drag source.
 @discussion Sets whether the outline allows rows to be dragged.  Since MOExtendedOutlineView extends the use of the -outlineView:writeItems:toPasteboard: to include Copy/Paste and Services support, the dataSource may implement that method without wanting to allow drags.  This method makes it possible to support the Copy menu command without supporting dragging.  The default is YES which means dragging is allowed as long as the dataSource implements -outlineView:writeItems:toPasteboard:.
 @param flag Whether the outline allows rows to be dragged.
 */
- (void)setIsDragSource:(BOOL)flag;

/*!
 @method isDragSource
 @abstract Does the outline act as a drag source.
 @discussion Returns whether the outline allows rows to be dragged.  Since MOExtendedOutlineView extends the use of the -outlineView:writeItems:toPasteboard: to include Copy/Paste and Services support, the dataSource may implement that method without wanting to allow drags.  This method makes it possible to support the Copy menu command without supporting dragging.  The default is YES which means dragging is allowed as long as the dataSource implements -outlineView:writeItems:toPasteboard:.
 @result Whether the outline allows rows to be dragged.
 */
- (BOOL)isDragSource;

/*!
 @method setFont:
 @abstract Sets the font of all text-based columns.
 @discussion This is a convenience method that does two things.  First it goes through all the outline's NSTableColumns and sets the font in each one's -dataCell.  Second, it adjusts the row-height of the outline to something appropriate for the font.

 If the font setting will ultimately be based on a user preference, and there is other content than text in your outlines, it is probably a good idea to set a minimum row height for the outline that will accomodate the non-text content.  (Don't forget the disclosure triangles...)
 @param font The font.
 */
- (void)setFont:(NSFont *)font;

/*!
 @method setMinRowHeight:
 @abstract Sets a minimum row height for the outline.
 @discussion Sets a minimum row height for the outline.  If you set this then calls to setRowHeight: with heights smaller than the minimum will cause the row height to be set to the minimum instead.

 This method can be useful if the control over the row-height is somehow in the user's hands andd you want to set a lower limit.  For example, if the font of the outline will be a user preference but there is also non-textual content that requires a minimum row height.
 @param height The minimum row height.
 */
- (void)setMinRowHeight:(float)height;

/*!
 @method minRowHeight
 @abstract Returns the minimum row height for the outline.
 @discussion Returns the minimum row height for the outline.  Calls to setRowHeight: with heights smaller than the minimum will cause the row height to be set to the minimum instead.
 @result The minimum row height.
 */
- (float)minRowHeight;

/*!
 @method setRowHeight:
 @abstract Overridden to support -setMinRowHeight:.
 @discussion Overridden to support -setMinRowHeight:.  This sets rowHeight to the minimum if it was less, then it calls super.
 @param rowHeight The desired row height.
 */
- (void)setRowHeight:(float)rowHeight;

/*!
 @method keyDown:
 @abstract Overridden to support the return/backspace delegate API.
 @discussion Overridden to support the -outlineView:handleReturnKeyEvent: and -outlineView:handleDeleteKeyEvent: delegate API.  This looks for those characters, and if the delegate implements the appropriate method, calls it.  For other keys, or if the delegate does not implement the right method, or if the delegate's implementation returns NO, this calls super.
 @param event The keyDown event.
 */
- (void)keyDown:(NSEvent *)event;

/*!
 @method delete:
 @abstract Action method for user-initiated deletion of selected items.
 @discussion Action method for user-initiated deletion of selected items.  This is the action of the Delete or Clear menu item and can also be wired to delete buttons or other UI elements.  It causes the selected items to be deleted by sending the dataSource the -outlineView:deleteItems: message, if it implements it.  If the dataSource does not implement that method or it returns NO, this beeps.  If the dataSource method does not alter the selection, then the outline will deselect all rows after a successful deletion.
 @param sender The sender of the action.
 */
- (IBAction)delete:(id)sender;

/*!
 @method createNewItem:
 @abstract Action method for user-initiated creation of a new item.
 @discussion Action method for user-initiated creation of a new item.  This can be wired to Add buttons or other UI elements.  It causes a new item to be inserted directly under (as a sibling of) the last currently selected item (or at the end if there is no selection), by sending the dataSource the -outlineView:createNewItemAtChildIndex:ofItem: message, if it implements it.  If the dataSource does not implement that method or it returns NO, this beeps.  If the dataSource method does not alter the selection, then the outline will select the new row (as the only selected row) after a successful deletion.
 @param sender The sender of the action.
 */
- (IBAction)createNewItem:(id)sender;

/*!
 @method copy:
 @abstract Action method for the Copy command.
 @discussion Action method for the Copy command.  This causes the selected items to be written to the general pasteboard by sending the dataSource the -outlineView:writeItems:toPasteboard: message, if it implements it.  If the dataSource does not implement that method or it returns NO, this beeps.
 @param sender The sender of the action.
 */
- (IBAction)copy:(id)sender;

/*!
 @method cut:
 @abstract Action method for the Cut command.
 @discussion Action method for the Cut command.  This causes the selected items to be written to the general pasteboard by sending the dataSource the -outlineView:writeItems:toPasteboard: message and then deletes them by sending it the -outlineView:deleteItems:, if it implements both.  If the dataSource does not implement either method or one returns NO, this beeps.  (If the writing of items to the pasteboard returns NO, the deletion is not attempted.)  If the dataSource methods do not alter the selection, then the outline will deselect all rows after a successful cut.
 @param sender The sender of the action.
 */
- (IBAction)cut:(id)sender;

/*!
 @method paste:
 @abstract Action method for the Paste command.
 @discussion Action method for the Paste command.  This causes new items to be read from the pasteboard and inserted directly under (as siblings of) the last currently selected item (or at the end if there is no selection), by sending the dataSource the -outlineView:readItemsFromPasteboard:item:childIndex:pasteboardSourceType: message, if it implements it.  If the dataSource does not implement that method or it returns NO, this beeps.  If the dataSource method does not alter the selection, then the outline will attempt to select the new rows (as the only selected rows).  To do this, the outline starts at the insertion row and selects a number of rows equal to the difference between the outline's number of rows before the paste and the number after the paste.
 @param sender The sender of the action.
 */
- (IBAction)paste:(id)sender;

/*!
 @method validateUserInterfaceItem:
 @abstract User command validation.
 @discussion This method implements validation for the delete:, createNewItem:, copy:, cut:, and paste: actions.  Validation is based on whether the dataSource implements the appropriate methods and also on whether the command currently makes sense (eg is there a selection for delete:, copy:, and cut:, and does the pasteboard contain a type that can be read for paste:).

 The validation for paste: will send the -outlineView:validRequestorForSendType:returnType: dataSource method, if it is implemented.  The send type will be nil and the return type will be a type that is currently on the pasteboard.  If the dataSource returns a requestor for any of the types on the pasteboard, then Paste will be enabled.

 For any other commands, this returns YES.
 @param anItem The user interface item being validated.
 @result YES if the item should be enabled, NO if not.
 */
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem;

/*!
 @method validRequestorForSendType:returnType:
 @abstract Services and Paste validation.
 @discussion This method is sent by the Services mechanism to find out whether a particular service is applicable.  MOExtendedOutlineView implements this method to send the -outlineView:validRequestorForSendType:returnType: dataSource method, if it is implemented.  If the delegate does not implement it this method calls super.  Note that for Services to be enabled, someone must call NSApplication's -registerServicesMenuSendTypes:returnTypes: with arrays of the supported send and return types to make the application globally aware that these types are supported.
 @param sendType The pasteboard type that will be sent to the service.
 @param returnType The pasteboard type that will come from the service.
 @result a "requestor" to handle the service.
 */
- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType;

/*!
 @method readSelectionFromPasteboard:
 @abstract Services support method.
 @discussion This method is sent by the Services mechanism to get the outline to read the results of a service.  This causes new items to be read from the pasteboard and inserted directly under (as siblings of) the last currently selected item (or at the end if there is no selection), by sending the dataSource the -outlineView:readItemsFromPasteboard:item:childIndex:pasteboardSourceType: message, if it implements it.  If the dataSource does not implement that method or it returns NO, this does nothing.  If the dataSource method does not alter the selection, then the outline will attempt to select the new rows (as the only selected rows).  To do this, the outline starts at the insertion row and selects a number of rows equal to the difference between the outline's number of rows before the new rows are read and the number after the new rows are read.  Note that for Services to be enabled, someone must call NSApplication's -registerServicesMenuSendTypes:returnTypes: with arrays of the supported send and return types to make the application globally aware that these types are supported.
 @param pboard The pasteboard to read from.
 @result YES if the read succeeded, NO if not.
 */
- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard;

/*!
 @method writeSelectionToPasteboard:types:
 @abstract Services support method.
 @discussion This method is sent by the Services mechanism to get the outline to provide input to a service.  This causes selected items to be written to the pasteboard, by sending the dataSource the -outlineView:writeItems:toPasteboard: message, if it implements it.  If the dataSource does not implement that method or it returns NO, this does nothing.  Note that for Services to be enabled, someone must call NSApplication's -registerServicesMenuSendTypes:returnTypes: with arrays of the supported send and return types to make the application globally aware that these types are supported.
 @param pboard The pasteboard to write to.
 @result YES if the write succeeded, NO if not.
 */
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types;

/*!
 @method menuForEvent:
 @abstract Override to support per-cell context menus.
 @discussion Cocoa sends this method when it needs a context menu.  This override figures out what item and column the mouse event was over.  If it was over a real cell, first the row for that cell is selected if it is not already selected, then the column's NSTableColumn is sent a -dataCellForRow: message and the resulting cell is asked for its menu.  If the cell has no menu or if the click was not over a cell, then super is called (which will return any menu set on the outline with the -setMenu: or wired to the menu outlet of the outline in IB).  Finally, if the delegate implements -outlineView:willReturnMenu:forTableColumn:item:event:, that message is sent (passing the menu we found, or nil if no menu was found.)  The delegate may create and return a new menu, return nil to block the menu being shown or modify the provided menu and return it.
 @param event The event that caused the view to require its context menu (usually a right-mouseDown: or Control-mouseDown:).
 @result The menu that should be used.
 */
- (NSMenu *)menuForEvent:(NSEvent *)event;

@end

/*!
 @category NSObject(MOExtendedOutlineViewDataSource)
 @abstract Informal protocol declaring additional dataSource methods for MOExtendedOutlineView.
 @discussion Informal protocol declaring additional dataSource methods for MOExtendedOutlineView.  MOExtendedOutlineView defines a number of additional optional methods that will be sent to the outline's dataSource if it implements them.
 */
@interface NSObject (MOExtendedOutlineViewDataSource)

/*!
 @method outlineView:deleteItems:
 @abstract Support for user-initiated item deletion.
 @discussion This method is sent by the -delete: and -cut: action methods to ask the dataSource to delete one or more items.  The array is guaranteed to be sorted in ascending row index order. If the dataSource is able to successfully delete the items it should return YES, if it cannot delete the items for any reason it should return NO.  If this method does not alter the selection, then the outline will deselect all rows after a successful deletion.
 @param sender The sending MOExtendedOutlineView.
 @param items The array of items.
 @result YES if the rows are successfully deleted, NO if not.
 */
- (BOOL)outlineView:(id)sender deleteItems:(NSArray *)items;

/*!
 @method outlineView:createNewItemAtChildIndex:ofItem:
 @abstract Support for user-initiated item creation.
 @discussion This method is sent by the -createNewItem: action method to ask the dataSource to create a new item at a given childIndex of a given parent item in the outline. If the dataSource is able to successfully create the item it should return YES, if it cannot create the item for any reason it should return NO.
 @param sender The sending MOExtendedOutlineView.
 @param childIndex The child index where the new item should be inserted within the given parent.
 @param item The parent item that the new item should be inserted into.
 @result YES if the row is successfully created, NO if not.
 */
- (BOOL)outlineView:(id)sender createNewItemAtChildIndex:(int)childIndex ofItem:(id)item;

/*!
 @method outlineView:readItemsFromPasteboard:item:childIndex:pasteboardSourceType:
 @abstract Consolidated method for handling reading rows from a pasteboard.
 @discussion This method provides a single funnel point for reading items from the pasteboard for drag&frop, copy/paste, and Services.  It is sent by the outlines' -paste: and -readSelectionFromPasteboard: methods.  It is also sent from MOKit's delfault NSObject implementation of the standard NSOutlineView drag&drop dataSource method -outlineView:acceptDrop:item:childIndex:.  An implementation should read the data from the pasteboard and insert new items (usually).

 In case the exact semantics for handling the different kinds of operations is required, an enumeration constant is passed in that identifies why the method is being called (ie whether it is for copy/paste or drag&drop or Services.)  For drag&drop the constant also tells you whether the source of the new rows is the same outline that is receiving them or some other source.

 For copy/paste and Services, the child index and item will be computed so that the new rows will be inserted as siblings after the last selected item.  In some circumstances for copy/paste or for Services, especially, you may want to ignore the childIndex and item parameters and work directly from the selection.  For instance, if a Service took row data as input from the selected rows, you may want to replace the selected rows with the output data.  Note that for Services to be enabled, someone must call NSApplication's -registerServicesMenuSendTypes:returnTypes: with arrays of the supported send and return types to make the application globally aware that these types are supported.

 For drag&drop, you can use the information about whether the source was the same outline to decide whether to move or copy the rows by default.  Note also that to accept drops, someone must register the outline for the drop types it supports by sending the outline a -registerForDraggedTypes: message.
 @param sender The sending MOExtendedOutlineView.
 @param pboard The pasteboard to read the data from.
 @param childIndex The child index of where to insert the new items within the given parent item.  May be NSOutlineViewDropOnItemIndex if the drop is "onto" an item instead of between two items.
 @param item The parent item into which the new items should be inserted.  May be nil if the items should be inserted as top-level objects.
 @param sourceType Where the pasteboard came from (ie what sort of operation is happening).
 @result YES if the operation is successful, NO if not.
 */
- (BOOL)outlineView:(id)sender readItemsFromPasteboard:(NSPasteboard *)pboard item:(id)item childIndex:(int)childIndex pasteboardSourceType:(MOPasteboardSourceType)sourceType;

/*!
 @method outlineView:validRequestorForSendType:returnType:
 @abstract Support for pasteboard validation.
 @discussion This method is sent by -validRequestorForSendType:returnType: to validate Service menu items, and it is also sent by -validateUserInterfaceItem: to validate the Paste command.  Implementors should return sender if the send and return types are able to be handled and nil otherwise.  When this is sent to validate the Paste command, the sendType is nil and the returnType is one of the types currently on the pasteboard.  Note that for Services to be enabled, someone must call NSApplication's -registerServicesMenuSendTypes:returnTypes: with arrays of the supported send and return types to make the application globally aware that these types are supported.
 @param sender The sending MOExtendedOutlineView.
 @param sendType The type of data that will be requested as input for a Service.
 @param returnType The type of data that will be provided as output for a Service or that is on the pasteboard for Paste.
 @result sender if the send and return types can be handled, nil if not.
 */
- (id)outlineView:(id)sender validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType;

/*!
 @method outlineViewDraggingExited:
 @abstract Data source method for notifying when sender is no longer tracking a drop.
 @discussion This method is invoked from MOExtendedOutlineView's draggingExited: implementation if the dataSource responds.
 @param sender The sending MOExtendedOutlineView.
 */
- (void)outlineViewDraggingExited:(id)sender;

/*!
 @method outlineView:draggingSourceOperationMaskForLocal:
 @abstract Data source method for altering the drag source operation mask.
 @discussion This method is invoked from MOExtendedOutlineView's draggingSourceOperationMaskForLocal: implementation if the dataSource responds.
 @param sender The sending MOExtendedOutlineView.
 @param localFlag Whether the drag destination is in the current application or a different one.
 @result sender if the send and return types can be handled, nil if not.
 */
- (NSDragOperation)outlineView:(id)sender draggingSourceOperationMaskForLocal:(BOOL)localFlag;

/*!
    @method     outlineView:draggedImage:beganAt:
    @abstract   Data source method for notification of drag source activity.
    @discussion Data source method for notification of drag source activity.  This method is invoked from MOExtendedOutlineView's -draggedImage:beganAt: implementation if the dataSource responds.
    @param      sender The sending MOExtendedOutlineView.
    @param      image The drag image.
    @param      screenPoint The screen point where the drag began.
*/
- (void)outlineView:(id)sender draggedImage:(NSImage *)image beganAt:(NSPoint)screenPoint;

/*!
    @method     outlineView:draggedImage:endedAt:operation:
    @abstract   Data source method for notification of drag source activity.
    @discussion Data source method for notification of drag source activity.  This method is invoked from MOExtendedOutlineView's -draggedImage:endedAt:operation: implementation if the dataSource responds.
    @param      sender The sending MOExtendedOutlineView.
    @param      image The drag image.
    @param      screenPoint The screen point where the drag ended.
    @param      operation The operation that was performed (or NSDragOperationNone if the drag was not successful).
*/
- (void)outlineView:(id)sender draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation;

/*!
    @method     outlineView:draggedImage:movedTo:
    @abstract   Data source method for notification of drag source activity.
    @discussion Data source method for notification of drag source activity.  This method is invoked from MOExtendedOutlineView's -draggedImage:movedTo: implementation if the dataSource responds.
    @param      sender The sending MOExtendedOutlineView.
    @param      image The drag image.
    @param      screenPoint The screen point where the drag is currently.
*/
- (void)outlineView:(id)sender draggedImage:(NSImage *)image movedTo:(NSPoint)screenPoint;

/*!
    @method     outlineViewIgnoreModifierKeysWhileDragging:
    @abstract   Data source method for controlling whether modifiers are ignored.
    @discussion Data source method for controlling whether modifiers are ignored.  This method is invoked from MOExtendedOutlineView's -ignoreModifierKeysWhileDragging implementation if the dataSource responds.
    @param      sender The sending MOExtendedOutlineView.
    @result     Whether the dragging session should ignore modifier keys.
*/
- (BOOL)outlineViewIgnoreModifierKeysWhileDragging:(id)sender;

@end

/*!
 @category NSObject(MOExtendedOutlineViewDelegate)
 @abstract Informal protocol declaring additional delegate methods for MOExtendedOutlineView.
 @discussion Informal protocol declaring additional delegate methods for MOExtendedOutlineView.  MOExtendedOutlineView defines a number of additional optional methods that will be sent to the outline's delegate if it implements them.
 */
@interface NSObject (MOExtendedOutlineViewDelegate)

/*!
 @method outlineView:handleReturnKeyEvent:
 @abstract Support for catching typing of return or enter.
 @discussion Support for catching typing of return or enter.  MOExtendedOutlineView will call this method if the user types Return or Enter while there is no cell editing going on (when cell editing is going on, the Return or Enter is handled by the cell being edited and usually causes editing to end and (depending on whether row-based editing is enabled) editing to transfer to another cell in the outline).

 One common implementation of this method makes return add new rows.  To do this simply implement this method and call [sender createNewRow:self].
 @param sender The sending MOExtendedOutlineView.
 @param event The key event.
 @result YES if the event was handled, NO if the sender should call [super keyDown:event].
 */
- (BOOL)outlineView:(id)sender handleReturnKeyEvent:(NSEvent *)event;

/*!
 @method outlineView:handleDeleteKeyEvent:
 @abstract Support for catching typing of backspace or delete.
 @discussion Support for catching typing of backspace or delete.  MOExtendedOutlineView will call this method if the user types Backspace or Delete or Del while there is no cell editing going on (when editing is going on, the editing cell handles the key as a normal text editing command).

 One common implementation of this method makes backspace delete the selected rows.  To do this simply implement this method and call [sender delete:self].
 @param sender The sending MOExtendedOutlineView.
 @param event The key event.
 @result YES if the event was handled, NO if the sender should call [super keyDown:event].
 */
- (BOOL)outlineView:(id)sender handleDeleteKeyEvent:(NSEvent *)event;

/*!
 @method outlineView:willReturnMenu:forTableColumn:item:event:
 @abstract Support for modifying or replacing a context menu before it is shown.
 @discussion Support for modifying or replacing a context menu before it is shown.  If the dataCell for the column and row has a menu, it will be passed in as the menu parameter, otherwise, if the outline itself has a menu, it will be passed as the menu paramter.  If no menu can be found the menu paramter will be nil.  If menu is non-nil, the delegate is free to modify it and return it, or to return a totally different NSMenu.  In any case, this can return nil to prevent any menu from popping.

 If you change the dataCell's or the outline's menu, be aware that the changes will be permanent unless and until a subsequent call to this method changes them again (or you change them directly through other means).  One reason you might change the menu is if your delegate implements the actions for its items, but you want to use the same NSMenu instance for multiple instances of the outline/delegate combo.  In this case, before showing the menu for any given outline, this method might set the targets of the menu's items to the appropriate delegate instance (ie the receiving delegate instance).
 @param sender The sending MOExtendedOutlineView.
 @param menu The dataCell's or outline's menu, if any.
 @param column The NSTableColumn, might be nil if click was not over any column.
 @param item The item that was clicked, might be nil if click was not over any row.
 @param event The event that prompted popping the context menu.
 @result The menu to display.  This can be the menu parameter, a different menu, or nil to prevent any menu from being displayed.
 */
- (NSMenu *)outlineView:(id)sender willReturnMenu:(NSMenu *)menu forTableColumn:(NSTableColumn *)column item:(id)item event:(NSEvent *)event;

@end

/*!
 @category NSObject(MOExtendedOutlineViewDefaultDataSourceMethods)
 @abstract MOKit provides default implementation for one NSOutlineView dataSource method.
 @discussion MOKit provides default implementation for one NSOutlineView dataSource method.
 */
@interface NSObject (MOExtendedOutlineViewDefaultDataSourceMethods)

/*!
 @method outlineView:acceptDrop:item:childIndex:
 @abstract Default implementation for NSOutlineView dataSource method.
 @discussion Default implementation for NSOutlineView dataSource method.  This method is provided to make the new MOExtendedOutlineView datSource API -outlineView:readItemsFromPasteboard:item:childIndex:pasteboardSourceType: into the funnel for all pasteboard reading.  The implementation of this method simply checks whether the dataSource implements the new method, and if it does, it sends it with [info draggingPasteboard] as the pasteboard.  The pasteboardSourceType is either MOPasteboardSourceTypeSelfDrop or MOPasteboardSourceTypeDrop depending on whether [info draggingSource] is the sender.
 @param sender The sending MOExtendedOutlineView.
 @param info The dragging info object.
 @param item The parent item into which to insert the new items.
 @param childIndex The child index to insert the new items at within the given parent item.  May be NSOutlineViewDropOnItemIndex if the drop is "onto" the item instead of between two items.
 @result YES if the operation is successful, NO if not.
 */
- (BOOL)outlineView:(NSOutlineView*)sender acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)childIndex;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOExtendedOutlineView__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
