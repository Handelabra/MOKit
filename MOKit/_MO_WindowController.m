// _MO_WindowController.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/_MO_WindowController.h>
#import <MOKit/MOViewController.h>
#import <MOKit/MORuntimeUtilities.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/MODebug_Private.h>

NSString *_MO_FocusRingNeedsDisplayNotification = @"_MO_FocusRingNeedsDisplay";
NSString *_MO_WindowControllerUpdateNotification = @"_MO_WindowControllerUpdate";

@interface _MO_FocusRingView : NSView {
    NSRect _ringRect;
    NSRect _clipRect;
}

- (void)setFocusRingRect:(NSRect)ringRect clipRect:(NSRect)clipRect;

@end

@implementation _MO_WindowController

- (id)initWithRootViewController:(MOViewController *)root {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (!root) {
        NSLog(@"%@ a non-nil root view controller is required.", MOFullMethodName(self, _cmd));
        [self release];
        return nil;
    }
    
    self = [super initWithWindow:nil];
    if (self) {
        _rootViewController = root;
        [self setShouldCascadeWindows:NO];
    }
    METHOD_TRACE_OUT;
    return self;
}

- (id)initWithWindow:(NSWindow *)window {
    NSLog(@"%@ is not supported.  _MO_WindowController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
    NSLog(@"%@ is not supported.  _MO_WindowController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (id)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner {
    NSLog(@"%@ is not supported.  _MO_WindowController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner {
    NSLog(@"%@ is not supported.  _MO_WindowController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (id)init {
    NSLog(@"%@ is not supported.  _MO_WindowController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (void)dealloc {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_lastVisibleFocusController release], _lastVisibleFocusController = nil;
    [_overlayWindow release], _overlayWindow = nil;
    if (_rootViewController && [self isWindowLoaded]) {
        [_rootViewController viewWillBeUninstalled];
    }
    [super dealloc];
    METHOD_TRACE_OUT;
}

- (id)rootViewController {
    return _rootViewController;
}

- (BOOL)isWindowLoaded {
    // Inherited version seems not to work for our use.  Not exactly sure why, but we'll just take over...  The flag gets set to YES as soon as -setWindow: is called.
    return _mwcFlags.windowIsLoaded;
}

- (void)_MO_installRootView {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOViewController *root = [self rootViewController];
    NSView *view = [root view];
    NSWindow *window = [self window];

    [window setContentView:view];
    id initialFR = [root firstKeyView];
    if (initialFR) {
        [window setInitialFirstResponder:initialFR];
    }
    [root viewWasInstalled];
    METHOD_TRACE_OUT;
}

- (void)loadWindow {
    // When the window controller is first asked for its window, it will try to load it with this method.  We do not want to go looking for nib files.  Our root view controller will provide the window for us.  If we do not have a root view controller yet, explicitly set the window to nil which will prevent NSWindowController from trying to load the window again and we will create and set the window when someone gives us a root view controller.
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);

    _mwcFlags.windowIsLoaded = YES;
    MOViewController *root = [self rootViewController];
    NSWindow *window = [root loadControllerWindow];

    // Set the window so future calls to -window will return it.
    [self setWindow:window];

    // Now that we have a window, we will want to install the root view controller's view as the content view.
    [self _MO_installRootView];

    METHOD_TRACE_OUT;
}

// Controller updating

- (void)_MO_updateController:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [controller update];
    
    NSArray *subcontrollers = [controller subcontrollers];
    unsigned i, c = [subcontrollers count];
    for (i=0; i<c; i++) {
        MOViewController *curSubcontroller = [subcontrollers objectAtIndex:i];
        if ([curSubcontroller isViewInstalled]) {
            [self _MO_updateController:curSubcontroller];
        }
    }
    METHOD_TRACE_OUT;
}

// Controller focus ring support

+ (void)_MO_enableWindowControllerUpdateNotifications {
    // Kicks off our special run loop performer for updating the focus ring.  This will be invoked for the first time either when the first instance of this class loads its window, if visible focus rings are already enabled at that point, or when visible focus rings are enabled if there are already instances with loaded windows.
    static BOOL enabled = NO;
    
    if (!enabled) {
        enabled = YES;
        [[NSRunLoop currentRunLoop] performSelector:@selector(_MO_postWindowControllerUpdate:) target:self argument:nil order:NSUpdateWindowsRunLoopOrdering + 100 modes:[NSArray arrayWithObjects:(NSString *)kCFRunLoopCommonModes, NSEventTrackingRunLoopMode, nil]];
    }
}

+ (void)_MO_postWindowControllerUpdate:(id)dummy {
    // This is our special run loop performer method.  It posts a notification that our instances are listening for and then schedules a new performer for the next spin of the event loop.
    [[NSNotificationCenter defaultCenter] postNotificationName:_MO_WindowControllerUpdateNotification object:self];
    [[NSRunLoop currentRunLoop] performSelector:@selector(_MO_postWindowControllerUpdate:) target:self argument:nil order:NSUpdateWindowsRunLoopOrdering + 100 modes:[NSArray arrayWithObjects:(NSString *)kCFRunLoopCommonModes, NSEventTrackingRunLoopMode, nil]];
}

- (void)_MO_updateFocusRing {
    // This is the real workhorse for updating the focus ring.
    if ([MOViewController activeControllerShowsFocus]) {
        // Create the overlay window if necessary.
        if (!_overlayWindow) {
            _overlayWindow = [[NSWindow alloc] initWithContentRect:[NSWindow contentRectForFrameRect:[[self window] frame] styleMask:NSBorderlessWindowMask] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
            [_overlayWindow setOpaque:NO];
            [_overlayWindow setIgnoresMouseEvents:YES];
            [_overlayWindow setOneShot:YES];
            [_overlayWindow setHasShadow: NO];
            [_overlayWindow setBackgroundColor:[NSColor clearColor]];
            
            _MO_FocusRingView *overlayView = [[_MO_FocusRingView alloc] init];
            [_overlayWindow setContentView:overlayView];
            [overlayView release];
            
            [[self window] addChildWindow:_overlayWindow ordered:NSWindowAbove];
            [_overlayWindow orderFront:self];
        }
        // Ensure that the overlay window tracks the size of the real window.
        float ringWidth = [MOViewController focusRingWidth];
        [_overlayWindow setFrame:NSInsetRect([[self window] frame], -ringWidth, -ringWidth) display:YES];
        
        // Figure out the focus rect, in the coordinates of the focus ring overlay view.
        NSRect ringRect = NSZeroRect;
        NSRect visRect = NSZeroRect;
        if (_lastVisibleFocusController) {
            visRect = NSInsetRect([[_lastVisibleFocusController view] visibleRect], -ringWidth, -ringWidth);
            if (!NSIsEmptyRect(visRect)) {
                // Only bother with all this if the vis rect is not empty.
                ringRect = visRect; //NSInsetRect([[_lastVisibleFocusController view] bounds], -ringWidth, -ringWidth);
                
                // ringRect = [[_lastVisibleFocusController contentView] convertRect:ringRect fromView:[_lastVisibleFocusController view]];
                // ringRect = [_lastVisibleFocusController focusRingRectForRect:ringRect];
                // ringRect = [[_lastVisibleFocusController view] convertRect:ringRect fromView:[_lastVisibleFocusController contentView]];
                
                // Convert to window coords.
                visRect = [[_lastVisibleFocusController view] convertRect:visRect toView:nil];
                ringRect = [[_lastVisibleFocusController view] convertRect:ringRect toView:nil];
                
                // Convert to ring view coords.
                visRect.origin = [[self window] convertBaseToScreen:visRect.origin];
                visRect.origin = [_overlayWindow convertScreenToBase:visRect.origin];
                visRect = [[_overlayWindow contentView] convertRect:visRect fromView:nil];
                ringRect.origin = [[self window] convertBaseToScreen:ringRect.origin];
                ringRect.origin = [_overlayWindow convertScreenToBase:ringRect.origin];
                ringRect = [[_overlayWindow contentView] convertRect:ringRect fromView:nil];
            }
        }
        // Set the current rect into the view.
        [[_overlayWindow contentView] setFocusRingRect:ringRect clipRect:visRect];
    } else {
        // Visible focus is not active.  If it was before and we still have an overlay window, get rid of it.
        if (_overlayWindow) {
            [[self window] removeChildWindow:_overlayWindow];
            [_overlayWindow release], _overlayWindow = nil;
        }
    }
}

- (void)_MO_windowControllerUpdate:(NSNotification *)notification {
    // Ensure a reasonable first responder
    NSWindow *window = [self window];
    if ([window firstResponder] == window) {
        [window makeFirstResponder:[self rootViewController]];
    }

    // Send view controllers their -update messages
    [self _MO_updateController:[self rootViewController]];
    
    // Update our caches of interesting responders in the current responder chain
    id responder = [window firstResponder];
    if (responder != _lastFirstResponder) {
        _lastFirstResponder = responder;  // not retained
        
        while (responder && ![responder isKindOfClass:[MOViewController class]]) {
            responder = [responder nextResponder];
        }
        _lastFocusController = responder;  // not retained
        
        while (responder && ![responder showsControllerFocus]) {
            responder = [responder supercontroller];
        }
        if (responder != _lastVisibleFocusController) {
            [_lastVisibleFocusController release];
            _lastVisibleFocusController = [responder retain];
        }
    }
    
    // Update the focus ring
    [self _MO_updateFocusRing];
}

- (void)_MO_focusRingNeedsDisplay:(NSNotification *)notification {
    // Just make sure the ring gets redisplayed.
    [[_overlayWindow contentView] setNeedsDisplay:YES];
}

- (void)windowDidLoad {
    [self controllerDidChangeLabel:[self rootViewController]];
    
    // We want to listen for focus ring update notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_MO_focusRingNeedsDisplay:) name:_MO_FocusRingNeedsDisplayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_MO_windowControllerUpdate:) name:_MO_WindowControllerUpdateNotification object:nil];

    [[self class] _MO_enableWindowControllerUpdateNotifications];
}

- (void)controllerDidChangeLabel:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (controller == [self rootViewController]) {
        if ([self isWindowLoaded]) {
            NSWindow *window = [self window];
            NSString *label = [controller label];
            [window setTitle:(label ? label : @"")];
            NSString *representedFilename = [controller representedFilename];
            if (representedFilename) {
                [window setRepresentedFilename:representedFilename];
            }
        }
    }
    METHOD_TRACE_OUT;
}

@end

@implementation _MO_FocusRingView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _clipRect = NSZeroRect;
        _ringRect = NSZeroRect;
    }
    return self;
}

- (void)setFocusRingRect:(NSRect)ringRect clipRect:(NSRect)clipRect {
    if (!NSEqualRects(_ringRect, ringRect) || !NSEqualRects(_clipRect, clipRect)) {
        [self setNeedsDisplayInRect:_clipRect];
        _ringRect = ringRect;
        _clipRect = clipRect;
        [self setNeedsDisplayInRect:_clipRect];
    }
}

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
    NSRectFill(rect);
    
    if (NSIntersectsRect(_clipRect, _ringRect)) {
        [[MOViewController focusRingColor] set];
        [NSBezierPath clipRect:_clipRect];
        NSFrameRectWithWidth(_ringRect, [MOViewController focusRingWidth]);
    }
}

@end

/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
