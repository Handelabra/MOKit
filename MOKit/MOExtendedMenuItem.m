// MOExtendedMenuItem.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOExtendedMenuItem.h>
#import <MOKit/MOExtendedMenu.h>

@implementation MOExtendedMenuItem

static BOOL _isDefaultStateEnabled = NO;

+ (BOOL)isRevertToDefaultItemStateEnabled {
    return _isDefaultStateEnabled;
}

+ (void)enableRevertToDefaultItemState {
    if (!_isDefaultStateEnabled) {
        _isDefaultStateEnabled = YES;
        [NSUnarchiver decodeClassName:@"NSMenuItem" asClassName:@"MOExtendedMenuItem"];
        [NSUnarchiver decodeClassName:@"NSMenu" asClassName:@"MOExtendedMenu"];
        [NSKeyedUnarchiver setClass:[MOExtendedMenuItem class] forClassName:@"NSMenuItem"];
        [NSKeyedUnarchiver setClass:[MOExtendedMenu class] forClassName:@"NSMenu"];
    }
}

- (void)_initDefaults {
    [self setDefaultTitle:[self title]];
    [self setDefaultKeyEquivalent:[self keyEquivalent]];
    [self setDefaultKeyEquivalentModifierMask:[self keyEquivalentModifierMask]];
    [self setDefaultImage:[self image]];
    [self setDefaultState:[self state]];
}

- (id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode {
    self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode];
    if (self) {
        // Set initial default title to same as title
        [self _initDefaults];
    }
    return self;
}

- (void)dealloc {
    [_defaultTitle release], _defaultTitle = nil;
    [_defaultKeyEquivalent release], _defaultKeyEquivalent = nil;
    [_defaultImage release], _defaultImage = nil;
    [super dealloc];
}

- (void)awakeFromNib {
    // Set initial default title to same as title
    [self _initDefaults];
}

- (NSString *)defaultTitle {
    return [[_defaultTitle retain] autorelease];
}

- (void)setDefaultTitle:(NSString *)title {
    if (_defaultTitle != title) {
        [_defaultTitle release];
        _defaultTitle = [title copyWithZone:[self zone]];
    }
}

- (NSString *)defaultKeyEquivalent {
    return [[_defaultKeyEquivalent retain] autorelease];
}

- (void)setDefaultKeyEquivalent:(NSString *)newDefaultKeyEquivalent {
    if (_defaultKeyEquivalent != newDefaultKeyEquivalent) {
        [_defaultKeyEquivalent release];
        _defaultKeyEquivalent = [newDefaultKeyEquivalent copyWithZone:[self zone]];
    }
}

- (unsigned)defaultKeyEquivalentModifierMask {
    return _defaultKeyEquivalentModifierMask;
}

- (void)setDefaultKeyEquivalentModifierMask:(unsigned)newDefaultKeyEquivalentModifierMask {
    if (_defaultKeyEquivalentModifierMask != newDefaultKeyEquivalentModifierMask) {
        _defaultKeyEquivalentModifierMask = newDefaultKeyEquivalentModifierMask;
    }
}

- (NSImage *)defaultImage {
    return [[_defaultImage retain] autorelease];
}

- (void)setDefaultImage:(NSImage *)newDefaultImage {
    if (_defaultImage != newDefaultImage) {
        [_defaultImage release];
        _defaultImage = [newDefaultImage retain];
    }
}

- (int)defaultState {
    return _defaultState;
}

- (void)setDefaultState:(int)newDefaultState {
    if (_defaultState != newDefaultState) {
        _defaultState = newDefaultState;
    }
}

- (void)resetToDefaults {
    [self setTitle:[self defaultTitle]];
    [self setKeyEquivalent:[self defaultKeyEquivalent]];
    [self setKeyEquivalentModifierMask:[self defaultKeyEquivalentModifierMask]];
    [self setImage:[self defaultImage]];
    [self setState:[self defaultState]];
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
