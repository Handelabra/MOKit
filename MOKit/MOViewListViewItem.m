// MOViewListViewItem.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOViewListViewItem_Private.h>
#import <MOKit/MOViewListView.h>
#import <MOKit/MOAssertions.h>

@implementation MOViewListViewItem

- (void)_MO_commonInit {
    _labelYPosition = 0.0;
}

- (id)initWithView:(NSView *)view andLabel:(NSString *)label {
    self = [super init];
    if (self) {
        _viewListView = nil;
        [self setView:view];
        [self setLabel:label];
        _identifier = nil;
        _representedObject = nil;
        _userInfo = nil;
        _vlviFlags.collapsed = YES;
        
        [self _MO_commonInit];
    }
    return self;
}

- (void)dealloc {
    [_view release], _view = nil;
    [_label release], _label = nil;
    [_identifier release], _identifier = nil;
    [_representedObject release], _representedObject = nil;
    [_userInfo release], _userInfo = nil;
    
    [super dealloc];
}

- (MOViewListView *)viewListView {
    return _viewListView;
}

- (void)setViewListView:(MOViewListView *)viewListView {
    MOAssertClassOrNil(viewListView, MOViewListView);
    
    if (viewListView != _viewListView) {
        NSView *view = [self view];
        if (_viewListView && view) {
            // Stop old view list view from observing the view
            [[NSNotificationCenter defaultCenter] removeObserver:_viewListView name:NSViewFrameDidChangeNotification object:view];
        }
        _viewListView = viewListView;
        if (_viewListView && view) {
            // Start new view list view observing the view
            [[NSNotificationCenter defaultCenter] addObserver:_viewListView selector:@selector(_MO_viewDidChangeFrame:) name:NSViewFrameDidChangeNotification object:view];
        }
    }
}

- (NSView *)view {
    return _view;
}

- (void)setView:(NSView *)view {
    MOAssertClassOrNil(view, NSView);
    
    if (view != _view) {
        MOViewListView *vlView = [self viewListView];
        if (vlView && _view) {
            // Stop view list view from observing old view
            [[NSNotificationCenter defaultCenter] removeObserver:vlView name:NSViewFrameDidChangeNotification object:_view];
        }
        [_view release];
        _view = [view retain];
        if (vlView && _view) {
            // Start view list view observing the new view
            [[NSNotificationCenter defaultCenter] addObserver:vlView selector:@selector(_MO_viewDidChangeFrame:) name:NSViewFrameDidChangeNotification object:_view];
        }
        if (vlView) {
            // Invalidate layout
            int i = [[vlView viewListViewItems] indexOfObjectIdenticalTo:self];
            if (i != NSNotFound) {
                [vlView invalidateLayoutStartingWithStackedViewAtIndex:i];
            }
        }
    }
}

- (NSString *)label {
    return _label;
}

- (void)setLabel:(NSString *)label {
    MOAssertClassOrNil(label, NSString);
    
    if (label != _label) {
        [_label release];
        _label = [label retain];
        MOViewListView *vlView = [self viewListView];
        if (vlView) {
            int i = [[vlView viewListViewItems] indexOfObjectIdenticalTo:self];
            if (i != NSNotFound) {
                [vlView setNeedsDisplayForLabelBarAtIndex:i];
            }
        }
    }
}

- (id)identifier {
    return _identifier;
}

- (void)setIdentifier:(id)identifier {
    if (identifier != _identifier) {
        [_identifier release];
        _identifier = [identifier retain];
    }
}

- (id)representedObject {
    return _representedObject;
}

- (void)setRepresentedObject:(id)obj {
    if (obj != _representedObject) {
        [_representedObject release];
        _representedObject = [obj retain];
    }
}

- (id)userInfo {
    return _userInfo;
}

- (void)setUserInfo:(id)userInfo {
    if (userInfo != _userInfo) {
        [_userInfo release];
        _userInfo = [userInfo retain];
    }
}

- (float)labelYPosition {
    return _labelYPosition;
}

- (void)_MO_setLabelYPosition:(float)position {
    _labelYPosition = position;
}

- (BOOL)isCollapsed {
    return _vlviFlags.collapsed;
}

- (void)_MO_setCollapsed:(BOOL)flag {
    _vlviFlags.collapsed = (flag ? YES : NO);
}

#define VIEW_LIST_VIEW_KEY @"com.lorax.MOViewListViewItem.viewListView"
#define VIEW_KEY @"com.lorax.MOViewListViewItem.view"
#define LABEL_KEY @"com.lorax.MOViewListViewItem.label"
#define COLLAPSED_KEY @"com.lorax.MOViewListViewItem.collapsed"
#define IDENTIFIER_KEY @"com.lorax.MOViewListViewItem.identifier"
#define REPRESENTED_OBJECT_KEY @"com.lorax.MOViewListViewItem.representedObject"
#define USER_INFO_KEY @"com.lorax.MOViewListViewItem.userInfo"

- (void)encodeWithCoder:(NSCoder *)coder {
    // Do not call super.  NSObject does not conform to NSCoding.

    if ([coder allowsKeyedCoding]) {
        [coder encodeConditionalObject:_viewListView forKey:VIEW_LIST_VIEW_KEY];
        [coder encodeObject:_view forKey:VIEW_KEY];
        [coder encodeObject:_label forKey:LABEL_KEY];
        [coder encodeBool:_vlviFlags.collapsed forKey:COLLAPSED_KEY];
        [coder encodeObject:_identifier forKey:IDENTIFIER_KEY];
        [coder encodeObject:_representedObject forKey:REPRESENTED_OBJECT_KEY];
        [coder encodeObject:_userInfo forKey:USER_INFO_KEY];
    } else {
        [NSException raise:NSGenericException format:@"MOViewListViewItem does not support old-style non-keyed NSCoding."];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    // Do not call super.  NSObject does not conform to NSCoding.

    if ([coder allowsKeyedCoding]) {
        [self _MO_commonInit];

        [self setView:[coder decodeObjectForKey:VIEW_KEY]];
        [self setLabel:[coder decodeObjectForKey:LABEL_KEY]];
        [self _MO_setCollapsed:[coder decodeBoolForKey:COLLAPSED_KEY]];
        [self setIdentifier:[coder decodeObjectForKey:IDENTIFIER_KEY]];
        [self setRepresentedObject:[coder decodeObjectForKey:REPRESENTED_OBJECT_KEY]];
        [self setUserInfo:[coder decodeObjectForKey:USER_INFO_KEY]];

        [self setViewListView:[coder decodeObjectForKey:VIEW_LIST_VIEW_KEY]];
    } else {
        [NSException raise:NSGenericException format:@"MOViewListViewItem does not support old-style non-keyed NSCoding."];
    }
    return self;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
