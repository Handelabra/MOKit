// NSView_MOSizing.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/NSView_MOSizing.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/MORuntimeUtilities.h>

//#define DO_DEBUG_LOGS

@interface NSView (MOSizing_Private)

+ (void)_MO_doSizingMethodReplacementIfNeeded;

@end

@implementation NSView (MOSizing)

/// Managing the side data

#ifndef MOKIT_NO_METHOD_REPLACEMENT
typedef struct _MOViewSizeDataStruct {
    NSSize minSize;
    NSSize maxSize;
    NSView *observingView;
    struct {
        unsigned int takesMinSizeFromClipView:1;
        unsigned int isObservingClipView:1;
        unsigned int _reserved:29;
    } flags;
} _MOViewSizeData;

static _MOViewSizeData *_newViewSizeDataFromZone(NSZone *zone) {
    _MOViewSizeData *newData = NSZoneMalloc(zone, sizeof(_MOViewSizeData));
    newData->minSize = NSMakeSize(0.0, 0.0);
    newData->maxSize = NSMakeSize(MAXFLOAT, MAXFLOAT);
    newData->observingView = nil;
    newData->flags.takesMinSizeFromClipView = NO;
    newData->flags.isObservingClipView = NO;
    return newData;
}

static void _freeViewSizeDataCallback(NSMapTable *mapTable, void *data) {
    NSZoneFree(NSZoneFromPointer(data), data);
}

static NSMapTableValueCallBacks _viewSizeDataCallbacks = {NULL, _freeViewSizeDataCallback, NULL};

static NSMapTable *_getViewSizeDataMap() {
    static NSMapTable *_viewSizeDataMap = NULL;
    if (!_viewSizeDataMap) {
        _viewSizeDataMap = NSCreateMapTableWithZone(NSNonRetainedObjectMapKeyCallBacks, _viewSizeDataCallbacks, 0, NULL);
    }
    return _viewSizeDataMap;
}

- (_MOViewSizeData *)_MO_viewSizeDataCreateIfNeeded:(BOOL)createFlag {
    NSMapTable *map = _getViewSizeDataMap();
    _MOViewSizeData *data = NSMapGet(map, self);
    if (!data && createFlag) {
        data = _newViewSizeDataFromZone([self zone]);
        NSMapInsertKnownAbsent(map, self, data);
    }
    return data;
}
#endif

/// Basic min size and max size API

#ifndef MOKIT_NO_METHOD_REPLACEMENT
// A helper method called to figure out the right frame
- (NSSize)_MO_constrainedFrameSizeForProposedSize:(NSSize)proposedSize {
    NSSize boundarySize = [self MO_minSize];
    if (proposedSize.width < boundarySize.width) {
        proposedSize.width = boundarySize.width;
    }
    if (proposedSize.height < boundarySize.height) {
        proposedSize.height = boundarySize.height;
    }

    boundarySize = [self MO_maxSize];
    if (proposedSize.width > boundarySize.width) {
        proposedSize.width = boundarySize.width;
    }
    if (proposedSize.height > boundarySize.height) {
        proposedSize.height = boundarySize.height;
    }
    return proposedSize;
}

- (void)_MO_ensureFrameContstraints {
    // Make sure we are within the current contraints
    NSSize curSize = [self frame].size;
    NSSize constrainedSize = [self _MO_constrainedFrameSizeForProposedSize:curSize];
    if (!NSEqualSizes(curSize, constrainedSize)) {
        [self setFrameSize:constrainedSize];
    }
    // Let a new natural size be computed, if the view can sizeToFit
    // ---:mferris:20021120 If a view has -MO_sizeConstraintsDidChange, giving it a chance to do so when constraints change is a good way to ensure that a previously larger minSize or a previously smaller maxSize will not continue to prevent the view from being the size it naturally desires to be.  It is a good idea for a view that will be used with MO_takesMinSizeFromClipView turned on to have a -MO_sizeConstraintsDidChange method.  Otherwise, as the clipview resizes smaller, the view may stay larger than it needs to be.  Often the -MO_sizeConstraintsDidChange will just call -sizeToFit.
    [(id)self MO_sizeConstraintsDidChange];
}
#endif

- (void)MO_sizeConstraintsDidChange {
    // Just for overriding...
    return;
}

- (NSSize)MO_minSize {
    NSSize minSize = NSMakeSize(0.0, 0.0);
#ifndef MOKIT_NO_METHOD_REPLACEMENT
    if (MOKitAllowsMethodReplacement()) {
        _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:NO];
        if (data) {
            minSize = data->minSize;

            if (data->flags.takesMinSizeFromClipView) {
                // If we are supposed to take min size from our clip view then see if we are in one and return its bounds size if we are.
                NSView *superview = [self superview];
                if (superview && [superview isKindOfClass:[NSClipView class]]) {
                    minSize = [superview bounds].size;
                }
            }
        }
    }
#endif
    return minSize;
}

- (void)MO_setMinSize:(NSSize)minSize {
#ifndef MOKIT_NO_METHOD_REPLACEMENT
    if (MOKitAllowsMethodReplacement()) {
        [[self class] _MO_doSizingMethodReplacementIfNeeded];
        _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:YES];
        MOParameterAssert(minSize.width <= data->maxSize.width);
        MOParameterAssert(minSize.height <= data->maxSize.height);
        data->minSize = minSize;
        // Make sure we are within the new contraints
        [self _MO_ensureFrameContstraints];
    }
#endif
}

- (NSSize)MO_maxSize {
    NSSize maxSize = NSMakeSize(MAXFLOAT, MAXFLOAT);
#ifndef MOKIT_NO_METHOD_REPLACEMENT
    if (MOKitAllowsMethodReplacement()) {
        _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:NO];
        if (data) {
            maxSize = data->maxSize;
        }
    }
#endif
    return maxSize;
}

- (void)MO_setMaxSize:(NSSize)maxSize {
#ifndef MOKIT_NO_METHOD_REPLACEMENT
    if (MOKitAllowsMethodReplacement()) {
        [[self class] _MO_doSizingMethodReplacementIfNeeded];
        _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:YES];
        MOParameterAssert(maxSize.width >= data->minSize.width);
        MOParameterAssert(maxSize.height >= data->minSize.height);
        data->maxSize = maxSize;
        // Make sure we are within the new contraints
        [self _MO_ensureFrameContstraints];
    }
#endif
}

/// NSClipView min size API

#ifndef MOKIT_NO_METHOD_REPLACEMENT
- (void)_MO_updateObservationOfSuperview:(NSView *)superview isBeingRemoved:(BOOL)removedFlag {
    _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:NO];
    BOOL shouldBeObserving = (data ? data->flags.takesMinSizeFromClipView : NO);
    BOOL isObserving = (data ? data->flags.isObservingClipView : NO);

    if (shouldBeObserving) {
        if (removedFlag || ![superview isKindOfClass:[NSClipView class]]) {
            shouldBeObserving = NO;
        }
    }

#ifdef DO_DEBUG_LOGS
    if ((data ? data->flags.takesMinSizeFromClipView : NO)) {
        NSLog(@"_MO_updateObservationOfSuperview:%@ isBeingRemoved:%@ - for view with takesMinSizeFromClipView - self=%@, shouldBeObserving=%@, isObserving=%@", superview, (removedFlag ? @"YES" : @"NO"), self, (shouldBeObserving ? @"YES" : @"NO"), (isObserving ? @"YES" : @"NO"));
    }
#endif

    // shouldBeObserving now indicates whether we should be watching for changes in our superview and using its size as our minSize.  Make sure we are observing or not as we should be.
    if (shouldBeObserving && !isObserving) {
        // We need to start observing.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_MO_clipViewFrameDidChange:) name:NSViewFrameDidChangeNotification object:superview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_MO_clipViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:superview];
        // data has to be non-NULL if shouldBeObserving is YES.
        data->flags.isObservingClipView = YES;
        data->observingView = superview;
#ifdef DO_DEBUG_LOGS
        NSLog(@"_MO_updateObservationOfSuperview:isBeingRemoved: - Started observing.");
#endif
    } else if (!shouldBeObserving && isObserving) {
        // We need to stop observing.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:superview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:superview];
        // data has to be non-NULL if isObserving is YES.
        data->flags.isObservingClipView = NO;
        data->observingView = nil;
#ifdef DO_DEBUG_LOGS
        NSLog(@"_MO_updateObservationOfSuperview:isBeingRemoved: - Stopped observing.");
#endif
    }
}

- (void)_MO_clipViewFrameDidChange:(NSNotification *)notification {
    // Update frame size appropriately
    NSView *superview = [self superview];
    if (superview) {
        [self _MO_ensureFrameContstraints];
    }
}

- (void)_MO_clipViewBoundsDidChange:(NSNotification *)notification {
    // Update frame size appropriately
    NSView *superview = [self superview];
    if (superview) {
        [self _MO_ensureFrameContstraints];
    }
}
#endif

- (BOOL)MO_takesMinSizeFromClipView {
    BOOL takes = NO;
#ifndef MOKIT_NO_METHOD_REPLACEMENT
    if (MOKitAllowsMethodReplacement()) {
        _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:NO];
        if (data) {
            takes = data->flags.takesMinSizeFromClipView;
        }
    }
#endif
    return takes;
}

- (void)MO_setTakesMinSizeFromClipView:(BOOL)flag {
#ifndef MOKIT_NO_METHOD_REPLACEMENT
    if (MOKitAllowsMethodReplacement()) {
        [[self class] _MO_doSizingMethodReplacementIfNeeded];
        _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:YES];
        data->flags.takesMinSizeFromClipView = flag;

        // Update observing status and frame size appropriately
        NSView *superview = [self superview];
        if (superview) {
            [self _MO_updateObservationOfSuperview:superview isBeingRemoved:NO];
            [self _MO_ensureFrameContstraints];
        }
    }
#endif
}

/// Replacements for NSView methods

// We replace 5 methods from NSView.  In all these replacements, the original replaced method will be invoked from the replacing method.  The comment above each replacement implementation explains exactly why the replacement is needed.

#ifndef MOKIT_NO_METHOD_REPLACEMENT

typedef void (*DeallocPrototype)(id self, SEL _cmd);
static DeallocPrototype _deallocIMP = NULL;

typedef void (*SetFramePrototype)(id self, SEL _cmd, NSRect frameRect);
static SetFramePrototype _setFrameIMP = NULL;

typedef void (*SetFrameSizePrototype)(id self, SEL _cmd, NSSize newSize);
static SetFrameSizePrototype _setFrameSizeIMP = NULL;

typedef void (*ViewWillMoveToSuperviewPrototype)(id self, SEL _cmd, NSView *newSuperview);
static ViewWillMoveToSuperviewPrototype _viewWillMoveToSuperviewIMP = NULL;

typedef void (*ViewDidMoveToSuperviewPrototype)(id self, SEL _cmd);
static ViewDidMoveToSuperviewPrototype _viewDidMoveToSuperviewIMP = NULL;

+ (void)_MO_doSizingMethodReplacementIfNeeded {
    // We do this in +load, not in +initialize, since this is a category on NSView and +load is actually invoked in all loaded categories through Obj-C runtime magic while +initialize is a normally invoked normally overridable method.
    static BOOL _hasReplacedMethods = NO;

    if (MOKitAllowsMethodReplacement()) {
        if (!_hasReplacedMethods) {
            _hasReplacedMethods = YES;
            _deallocIMP = (DeallocPrototype)[NSView MO_replaceInstanceSelector:@selector(dealloc) withMethodForSelector:@selector(_MO_replacementDealloc)];
            _setFrameIMP = (SetFramePrototype)[NSView MO_replaceInstanceSelector:@selector(setFrame:) withMethodForSelector:@selector(_MO_replacementSetFrame:)];
            _setFrameSizeIMP = (SetFrameSizePrototype)[NSView MO_replaceInstanceSelector:@selector(setFrameSize:) withMethodForSelector:@selector(_MO_replacementSetFrameSize:)];
            _viewWillMoveToSuperviewIMP = (ViewWillMoveToSuperviewPrototype)[NSView MO_replaceInstanceSelector:@selector(viewWillMoveToSuperview:) withMethodForSelector:@selector(_MO_replacementViewWillMoveToSuperview:)];
            _viewDidMoveToSuperviewIMP = (ViewDidMoveToSuperviewPrototype)[NSView MO_replaceInstanceSelector:@selector(viewDidMoveToSuperview) withMethodForSelector:@selector(_MO_replacementViewDidMoveToSuperview)];
        }
    }
}

// We replace -dealloc in order to ensure that our _MOViewSizeData structure, if any, is freed.  Note we do not need to worry about removing observers for the clipview minSize tracking feature since if the view is being deallocated, it has already been removed from its superview and we got the chance to remove our observers then.
- (void)_MO_replacementDealloc {
    _MOViewSizeData *data = [self _MO_viewSizeDataCreateIfNeeded:NO];
    if (data && data->observingView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:data->observingView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:data->observingView];
    }
    
    NSMapRemove(_getViewSizeDataMap(), self);
    
    if (_deallocIMP) {
        _deallocIMP(self, _cmd);
    }
}

// We replace setFrame: and setFrameSize: to enforce min and max sizes, if any.  Even though we know that one of these is primitive and the other merely calls it, and even though we could quickly find out which one is primitive, we still replace both since which is primitive and which is not is not documented and therefore should not be relied upon.  This means that for whichever is the non-primitive, we do the bounds checking twice which is slightly (but not very) wasteful.
- (void)_MO_replacementSetFrameSize:(NSSize)newSize {
    newSize = [self _MO_constrainedFrameSizeForProposedSize:newSize];
    if (_setFrameSizeIMP) {
        _setFrameSizeIMP(self, _cmd, newSize);
    }
}

- (void)_MO_replacementSetFrame:(NSRect)frameRect {
    frameRect.size = [self _MO_constrainedFrameSizeForProposedSize:frameRect.size];
    if (_setFrameIMP) {
        _setFrameIMP(self, _cmd, frameRect);
    }
}

// We replace viewWillMoveToSuperview: so that we can keep track of whether or not we are a subview of an NSClipView when MO_takesMinSizeFromClipView is turned on and we can start and stop observing notifications.
- (void)_MO_replacementViewWillMoveToSuperview:(NSView *)newSuperview {
    NSView *currentSuperview = [self superview];
    if (currentSuperview == newSuperview) {
        // No change, observation should be already correct
        return;
    }
    if (currentSuperview) {
        [self _MO_updateObservationOfSuperview:currentSuperview isBeingRemoved:YES];
    }
    if (newSuperview) {
        [self _MO_updateObservationOfSuperview:newSuperview isBeingRemoved:NO];
    }
    if (_viewWillMoveToSuperviewIMP) {
        _viewWillMoveToSuperviewIMP(self, _cmd, newSuperview);
    }
}

// We replace viewDidMoveToSuperview so that we can re-ensure frame constraints if we are added to a clipview and MO_takesMinSizeFromClipView is turned on.  We cannot do this in the replacement for viewWillMoveToSuperview: because at that point we are not yet the subview of the new superview and MO_minSize therefore would not return the correct value.
- (void)_MO_replacementViewDidMoveToSuperview {
    NSView *superview = [self superview];
    if (superview) {
        [self _MO_ensureFrameContstraints];
    }
    if (_viewDidMoveToSuperviewIMP) {
        _viewDidMoveToSuperviewIMP(self, _cmd);
    }
}
#endif

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
