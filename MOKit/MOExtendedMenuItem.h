// MOExtendedMenuItem.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOExtendedMenuItem
 @discussion Defines the MOExtendedMenuItem class.
 */


#if !defined(__MOKIT_MOExtendedMenuItem__)
#define __MOKIT_MOExtendedMenuItem__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @class MOExtendedMenuItem
 @abstract MOExtendedMenuItem is a subclass of NSMenuItem that adds support for a "default" state.
 @discussion MOExtendedMenuItem is a subclass of NSMenuItem that adds support for a "default" state.  This helps to solve the problem of what happens to menus that change title or other properties via validation methods when there's sometimes no valid target for the items.  
 
 For example, you might have a "Save" command that sends a -saveDocument: action to the first responder.  Wouldn't it be cool if the menu item actually said "Save <DocumentName>"?  You can easily do this by adding a -validateMenuItem: method to your document class that sets the menu item's title.  The problem is that when there is no active document, the menu item will be disabled, but it will still say "Save <DocumentName>" with the document name of the last active document!
 
 MOExtendedMenuItem and MOExtendedMenu cooperate to prevent this.  MOExtendedMenuItem has a -defaultTitle (as well as other default state).  MOExtendedMenu will revert each item in it to the default state at the beginning of its -update method.  If a -validateMenuItem: changes it again, cool, but if not, the default state sticks.  
 
 MOExtendedMenuItem will automatically set its default state during awakeFromNib.  So all you have to do is make sure that your menu items have their generic default state in your main nib.
 
 You can use MOExtendedMenuItem in a couple ways.  You could individually mark your menus and items in a nib file as being the MOExtendedMenuItem and MOExtendedMenu subclasses.  Or you can simply call +[MOExtendedMenuItem enableRevertToDefaultItemState] in your application's main() before calling NSApplicationMain and it will arrange to have everything work automatically.
 */
@interface MOExtendedMenuItem : NSMenuItem {
    @private
    NSString *_defaultTitle;
    NSString *_defaultKeyEquivalent;
    unsigned int _defaultKeyEquivalentModifierMask;
    NSImage *_defaultImage;
    int _defaultState;
}

/*!
 @method isRevertToDefaultItemStateEnabled
 @abstract Returns whether automatic use of MOExtendedMenuItem is enabled.
 @discussion Returns whether automatic use of MOExtendedMenuItem is enabled.  When it is enabled, all menus and menu items unarchived from nib files will use the MOExtendedMenuItem and MOExtendedMenu subclasses.
 @result Whether automatic use of MOExtendedMenuItem is enabled.
 */
+ (BOOL)isRevertToDefaultItemStateEnabled;

/*!
 @method enableRevertToDefaultItemState
 @abstract Enables automatic use of MOExtendedMenuItem.
 @discussion Enables automatic use of MOExtendedMenuItem.  When it is enabled, all menus and menu items unarchived from nib files will use the MOExtendedMenuItem and MOExtendedMenu subclasses.
 */
+ (void)enableRevertToDefaultItemState;
    
/*!
 @method defaultTitle
 @abstract Returns the default title.
 @discussion Returns the default title.
 @result The default title.
 */
- (NSString *)defaultTitle;

/*!
 @method setDefaultTitle:
 @abstract Sets the default title.
 @discussion Sets the default title.
 @param title The default title.
 */
- (void)setDefaultTitle:(NSString *)title;

/*!
 @method defaultKeyEquivalent
 @abstract Returns the default key equivalent.
 @discussion Returns the default key equivalent.
 @result The default key equivalent.
 */
- (NSString *)defaultKeyEquivalent;

/*!
 @method setDefaultKeyEquivalent:
 @abstract Sets the default key equivalent.
 @discussion Sets the default key equivalent.
 @param newDefaultKeyEquivalent The default key equivalent.
 */
- (void)setDefaultKeyEquivalent:(NSString *)newDefaultKeyEquivalent;

/*!
 @method defaultKeyEquivalentModifierMask
 @abstract Returns the default key equivalent modifier mask.
 @discussion Returns the default key equivalent modifier mask.
 @result The default key equivalent modifier mask.
 */
- (unsigned int)defaultKeyEquivalentModifierMask;

/*!
 @method setDefaultKeyEquivalentModifierMask:
 @abstract Sets the default key equivalent modifier mask.
 @discussion Sets the default key equivalent modifier mask.
 @param newDefaultKeyEquivalentModifierMask The default key equivalent modifier mask.
 */
- (void)setDefaultKeyEquivalentModifierMask:(unsigned int)newDefaultKeyEquivalentModifierMask;

/*!
 @method defaultImage
 @abstract Returns the default image.
 @discussion Returns the default image.
 @result The default image.
 */
- (NSImage *)defaultImage;

/*!
 @method setDefaultImage:
 @abstract Sets the default image.
 @discussion Sets the default image.
 @param newDefaultImage The default image.
 */
- (void)setDefaultImage:(NSImage *)newDefaultImage;

/*!
 @method defaultState
 @abstract Returns the default state.
 @discussion Returns the default state.
 @result The default state.
 */
- (int)defaultState;

/*!
 @method setDefaultState:
 @abstract Sets the default state.
 @discussion Sets the default state.
 @param newDefaultState The default state.
 */
- (void)setDefaultState:(int)newDefaultState;

/*!
 @method resetToDefaults
 @abstract Restores the item to its default state.
 @discussion Restores the item to its default state.  This is called for each item in a MOExtendedMenu at the beginning of each -update.
 */
- (void)resetToDefaults;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOExtendedMenuItem__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
