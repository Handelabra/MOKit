// MOViewControllerView.h
// MOKit
//
// Created by John Graziano on Thu Sep 25 2003.
// Copyright © 2003-2005, Pixar Animation Studios. All rights reserved.
//
// See bottom of file for license and disclaimer.

#if !defined(__MOKIT_MOViewControllerView__)
#define __MOKIT_MOViewControllerView__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
    
@class MOViewController;

@interface MOViewControllerView : NSView
{
  @private
    MOViewController    *_viewController;
    NSView              *_contentView;
}

- (id)initViewController:(MOViewController *)viewController contentView:(NSView *)contentView;

- (MOViewController *)viewController;
- (NSView *)contentView; 

- (NSSize)minContentSize;
- (void)setMinContentSize:(NSSize)minContentSize;

- (NSSize)maxContentSize;
- (void)setMaxContentSize:(NSSize)maxContentSize;

@end


@interface NSView (MOViewControllerReporting)

- (MOViewController *)viewController;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOViewController__

/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.
 
 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
