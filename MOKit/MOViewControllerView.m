//
// MOViewControllerView.m
// MOKit
//
// Created by John Graziano on Thu Sep 25 2003.
// Copyright © 2003-2005 Pixar Animation Studios. All rights reserved.
//
// See bottom of file for license and disclaimer.

#import <MOKit/MOViewControllerView.h>
#import <MOKit/MOViewController.h>
#import <MOKit/NSView_MOSizing.h>

@implementation MOViewControllerView

- (id)initViewController:(MOViewController *)viewController contentView:(NSView *)contentView {
    if(contentView) {
        [super initWithFrame:[contentView frame]];
        [[contentView superview] addSubview:self positioned:NSWindowBelow relativeTo:contentView];
        [contentView setFrame:[self bounds]];
        [self addSubview:contentView];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:[contentView autoresizingMask]];
        _contentView = contentView;
    } else {
        // raise, perhaps??
        [super init];
    }
    
    _viewController = viewController;
    return self;
}

- (MOViewController *)viewController {
    return _viewController;
}

- (NSView *)contentView {
    return _contentView;
}

- (NSSize)minContentSize {
    return [_contentView MO_minSize];
}

- (void)setMinContentSize:(NSSize)minContentSize {
    [_contentView MO_setMinSize:minContentSize];
}

- (NSSize)maxContentSize {
    return [_contentView MO_maxSize];
}

- (void)setMaxContentSize:(NSSize)maxContentSize {
    [_contentView MO_setMaxSize:maxContentSize];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize; {
    [_contentView setFrame:[self bounds]];
}

@end


@implementation NSView (MOViewControllerReporting)

- (MOViewController *)viewController {
    return [[self superview] viewController];
}


@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.
 
 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
