// MOViewListViewItem.h
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOViewListViewItem
 @discussion Defines the MOViewListViewItem class.
 */


#if !defined(__MOKIT_MOViewListViewItem__)
#define __MOKIT_MOViewListViewItem__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
@class MOViewListView;

/*!
 @class MOViewListViewItem
 @abstract MOViewListViewItem instances represent the indivdual views inside a MOViewListView.
 @discussion MOViewListViewItem used to keep track of the individual views in a MOViewListView.  MOViewListView uses them like NSTabView uses NSTabViewItems.  MOViewListViewItem keeps track of the actual view, the label to use for it within the MOViewListView, and some computed state for the item.

 In addition, MOViewListViewItem provides storage for several things that the client can use for any purpose.  Each item has an identifier, a representedObject and a userInfo.  Each of these can be any kind of object although NSStrings are traditional for identifiers and NSDictionaries are traditional for userInfo.  representedObject would be ideal for storing a reference to the controller object responsible for the view owned by the item (if any).

 One use for MOViewListViewItem is to preserve laziness of UI loading.  By default, MOViewListViewItems are collapsed.  Until an item is actually added to a MOViewListView and then expanded, there's no need for the view to be loaded and initialized.  In this case, you can create a MOViewListViewItem with no view set it in and add it to the MOViewListView so that its label will appear appropriately.  Then, the delegate of the MOViewListView can trigger the loading of the view when needed by implementing the -viewListView:willExpandViewListViewItem: method and making it load the view and use -setView: to set it into the item, if it has not been loaded yet.
 */
@interface MOViewListViewItem : NSObject <NSCoding> {
    @private
    MOViewListView *_viewListView;
    NSView *_view;
    NSString *_label;
    float _labelYPosition;
    struct {
        unsigned int collapsed:1;

        unsigned int _reserved:31;
    } _vlviFlags;

    id _identifier;
    id _representedObject;
    id _userInfo;
}

/*!
 @method initWithView:andLabel:
 @abstract Initializes an instance.
 @discussion Designated Initializer.  Initializes the receiver with the given view and label.
 @param view The view for this item.  This can be nil, and will be in cases where lazy nib loading is desired.
 @param label The label to use in the MOViewListView for this item.
 @result The initialized instance.
*/
- (id)initWithView:(NSView *)view andLabel:(NSString *)label;

/*!
 @method viewListView
 @abstract Returns the owning MOViewListView.
 @discussion This method returns the MOViewListView that owns the receiver (or nil, if the item is not currently being managed by any MOViewListView).
 @result The owning MOViewListView.
 */
- (MOViewListView *)viewListView;

/*!
 @method setViewListView:
 @abstract Sets the owning MOViewListView.
 @discussion Sets the owning MOViewListView.  This method is automatically called by MOViewListView and should not be called directly, but it can be overridden by subclasses.  Overriders should be sure to call super.  If the item has a view then this method will stop the old MOViewListView from observing its frame and will start the new MOViewListView observing its frame.
 @param viewListView owning MOViewListView.
 */
- (void)setViewListView:(MOViewListView *)viewListView;

/*!
 @method view
 @abstract Returns the item's view.
 @discussion This method returns the item's view (if any).
 @result The item's view.
 */
- (NSView *)view;

/*!
 @method setView:
 @abstract Sets the item's view.
 @discussion Sets the item's view.  This method can be called from the MOViewListView's delegate's -viewListView:willExpandViewListViewItem: method to implement lazy view loading.  If the item has a viewListView then this method will stop the MOViewListView from observing the old view's frame and will start the MOViewListView observing the new view's frame.
 @param view The view.
 */
- (void)setView:(NSView *)view;

/*!
 @method label
 @abstract Returns the item's label.
 @discussion This method returns the item's label (if any).
 @result The item's label.
 */
- (NSString *)label;

/*!
 @method setLabel:
 @abstract Sets the item's label.
 @discussion Sets the item's label.  If the item has a viewLisView, this method invalidates display for the item's label rect.
 @param label The label.
 */
- (void)setLabel:(NSString *)label;

/*!
 @method identifier
 @abstract Returns the item's identifier.
 @discussion This method returns the item's identifier (if any).  MOViewListView does not ever look at or use this object.  You can set any object as the identifier and use it however you like.  Traditionally identifiers are NSStrings, but they need not be.  The identifier is retained by the MOViewListViewItem.
 @result The item's identifier.
 */
- (id)identifier;

/*!
 @method setIdentifier:
 @abstract Sets the item's identifier.
 @discussion This method sets the item's identifier.  MOViewListView does not ever look at or use this object.  You can set any object as the identifier and use it however you like.  Traditionally identifiers are NSStrings, but they need not be.  The identifier is retained by the MOViewListViewItem.
 @param identifier The identifier.
 */
- (void)setIdentifier:(id)identifier;

/*!
 @method representedObject
 @abstract Returns the item's representedObject.
 @discussion This method returns the item's representedObject (if any).  MOViewListView does not ever look at or use this object.  You can set any object as the representedObject and use it however you like.  One good use for this is to keep a pointer to the controller object responsible for the item's view.  The representedObject is retained by the MOViewListViewItem.
 @result The item's representedObject.
 */
- (id)representedObject;

/*!
 @method setRepresentedObject:
 @abstract Sets the item's representedObject.
 @discussion This method sets the item's representedObject.  MOViewListView does not ever look at or use this object.  You can set any object as the representedObject and use it however you like.  One good use for this is to keep a pointer to the controller object responsible for the item's view.  The representedObject is retained by the MOViewListViewItem.
 @param obj The representedObject.
 */
- (void)setRepresentedObject:(id)obj;

/*!
 @method userInfo
 @abstract Returns the item's userInfo.
 @discussion This method returns the item's userInfo (if any).  MOViewListView does not ever look at or use this object.  You can set any object as the userInfo and use it however you like.  Traditionally userInfos are NSDictionaries, but they need not be.  The userInfo is retained by the MOViewListViewItem.
 @result The item's userInfo.
 */
- (id)userInfo;

/*!
 @method setUserInfo:
 @abstract Sets the item's userInfo.
 @discussion This method sets the item's userInfo (if any).  MOViewListView does not ever look at or use this object.  You can set any object as the userInfo and use it however you like.  Traditionally userInfos are NSDictionaries, but they need not be.  The userInfo is retained by the MOViewListViewItem.
 @param The userInfo.
 */
- (void)setUserInfo:(id)userInfo;

/*!
 @method isCollapsed
 @abstract Returns whether the item is collapsed.
 @discussion This method returns whether the item is collapsed.  This state is managed by the MOViewListView and cannot be modified directly.
 @result Whether the item is collapsed.
 */
- (BOOL)isCollapsed;

/*!
 @method labelYPosition
 @abstract Returns the y position of the top of the item's label rect within the MOViewListView.
 @discussion This method returns the y position of the top of the item's label rect within the MOViewListView.  This position is managed by the MOViewListView and cannot be modified directly.
 @result The y position of the top of the item's label rect within the MOViewListView.
 */
- (float)labelYPosition;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOViewListViewItem__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
