// MOViewController.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOViewController.h>
#import <MOKit/MOViewControllerView.h>
#import <MOKit/_MO_WindowController.h>
#import <MOKit/NSView_MOSizing.h>
#import <MOKit/MORuntimeUtilities.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/MODebug_Private.h>
#import <objc/objc-runtime.h>  // For objc_msgSend because there is no performSelector:withObject:withObject:withObject:

@interface MOViewController (MOInternal)

- (void)_MO_controller:(MOViewController *)controller notifyControllersWithSelector:(SEL)selector subcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index;

- (void)_MO_viewWillLoad;
- (void)_MO_viewDidLoad;

- (void)_MO_computeLastKeyView;

- (void)_MO_sendControllerDidChangeLabel;

@end

@implementation MOViewController

#pragma mark *** Init/dealloc methods

+ (NSString *)defaultViewNibName {
    return NSStringFromClass(self);
}

// Explaining the init madness:
//
// MOViewController has an unfortunate -init situation.  It needs to call an initializer on its superclass that is NOT the designated initializer since that is the only way to get NSWindowController to know about a nib properly is to go through an initializer  like-initWithWindowNibName:owner:.  This method will send self an -initWithWindow: (since it is the real DI).  We want to disallow -initWithWindow: as an initializer, but we need to allow it to be called when it is triggered through our -init method.
- (id)init {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    _vcFlags.initing = YES;
    self = [super initWithWindowNibName:[[self class] defaultViewNibName] owner:self];
    if (self) {
        [self setLabel:NSStringFromClass([self class])];
    }
    _vcFlags.initing = NO;
    METHOD_TRACE_OUT;
    return self;
}

- (id)initWithWindow:(NSWindow *)window {
    // NSWindowController DI.
    if (_vcFlags.initing) {
        // We are here because of the call to [super initWithWindowNib...] in our -init.  Let's just go through our own DI.
        return [super initWithWindow:nil];
    } else {
        // We do not allow this to be called directly.
        NSLog(@"%@ is not supported.  MOViewController disallows this initializer.", MOFullMethodName(self, _cmd));
        [self release];
        return nil;
    }
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
    // We do not allow this to be called directly.
    NSLog(@"%@ is not supported.  MOViewController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (id)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner {
    // We do not allow this to be called directly.
    NSLog(@"%@ is not supported.  MOViewController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner {
    // We do not allow this to be called directly.
    NSLog(@"%@ is not supported.  MOViewController disallows this initializer.", MOFullMethodName(self, _cmd));
    [self release];
    return nil;
}

- (void)dealloc {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    // Clean up our subcontrollers.
    unsigned c = [_subcontrollers count];
    while (c--) {
        [self removeSubcontrollerAtIndex:c];
    }
    [_subcontrollers release], _subcontrollers = nil;

    // Clean up our window if we have one
    if ([self wantsOwnWindow]) {
        [self setWantsOwnWindow:NO];
    }
    
    // Clean up our view
    if ([self isViewInstalled]) {
        [self viewWillBeUninstalled];
        [_view removeFromSuperview];
    }
    [_view release], _view = nil;
    [_contentView release], _contentView = nil;

    [_label release], _label = nil;
    [_icon release], _icon = nil;
    [_representedFilename release], _representedFilename = nil;
    
    if (_savedViewFramePtr) {
        NSZoneFree([self zone], _savedViewFramePtr), _savedViewFramePtr = NULL;
    }
    
    [super dealloc];
    METHOD_TRACE_OUT;
}

#pragma mark *** Controller hierarchy

- (id)supercontroller {
    return _supercontroller;
}

- (void)setSupercontroller:(MOViewController *)supercontroller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOAssertClassOrNil(supercontroller, MOViewController);
    _supercontroller = supercontroller;
    METHOD_TRACE_OUT;
}

- (void)_MO_controller:(MOViewController *)controller notifyControllersWithSelector:(SEL)selector subcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index  {
    // This method is a utility used when all controllers related to a particular controller need to be notified of something.
    // We want to send the selector (-controller:didInsertSubcontroller:atIndex:, -controller:willRemoveSubcontroller:atIndex:, -controllerViewWasInstalled: or -controllerViewWillBeUninstalled:) to ourself and all our ancestor controllers and to the subcontroller and all its descendant controllers (or all our descendant subcontrollers if the subcontroller argument is nil).

    MOAssertClass(controller, MOViewController);
    MOAssertClassOrNil(subcontroller, MOViewController);
    MOParameterAssert(selector);
    
    // First send to ourself
    if (subcontroller) {
        objc_msgSend(self, selector, controller, subcontroller, index);
    } else {
        [self performSelector:selector withObject:controller];
    }

    if (controller == self) {
        // Next we send to all our ancestor controllers
        MOViewController *supercontroller = [controller supercontroller];

        while (supercontroller) {
            if (subcontroller) {
                objc_msgSend(supercontroller, selector, controller, subcontroller, index);
            } else {
                [supercontroller performSelector:selector withObject:controller];
            }
            supercontroller = [supercontroller supercontroller];
        }

        // Next send to subcontroller
        if (subcontroller) {
            objc_msgSend(subcontroller, selector, controller, subcontroller, index);
        }
    }

    // Finally we let it go down the controller hierarchy of the new subcontroller.
    NSArray *subcontrollers = (((controller == self) && subcontroller) ? [subcontroller subcontrollers] : [self subcontrollers]);
    unsigned i, c = [subcontrollers count];
    for (i=0; i<c; i++) {
        [[subcontrollers objectAtIndex:i] _MO_controller:controller notifyControllersWithSelector:selector subcontroller:subcontroller atIndex:index];
    }
}

- (NSArray *)subcontrollers {
    return _subcontrollers;
}

- (void)insertSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOAssertClass(subcontroller, MOViewController);
    MOParameterAssert((index <= [_subcontrollers count]));
    MOAssert(([subcontroller supercontroller] == nil), @"The given subcontroller already is in a controller hierarchy.");

    if (!_subcontrollers) {
        _subcontrollers = [[NSMutableArray allocWithZone:[self zone]] init];
    }
    [_subcontrollers insertObject:subcontroller atIndex:index];
    [subcontroller setSupercontroller:self];
    [self _MO_controller:self notifyControllersWithSelector:@selector(controller:didInsertSubcontroller:atIndex:) subcontroller:subcontroller atIndex:index];
    METHOD_TRACE_OUT;
}

- (void)addSubcontroller:(MOViewController *)subcontroller {
    [self insertSubcontroller:subcontroller atIndex:[_subcontrollers count]];
}

- (void)removeSubcontrollerAtIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOParameterAssert((index < [_subcontrollers count]));
    MOViewController *subcontroller = [_subcontrollers objectAtIndex:index];

    if ([subcontroller isViewInstalled]) {
        // Brute force uninstall view if installed.
        [subcontroller viewWillBeUninstalled];
        [[subcontroller view] removeFromSuperview];
    }
    [self _MO_controller:self notifyControllersWithSelector:@selector(controller:willRemoveSubcontroller:atIndex:) subcontroller:subcontroller atIndex:index];
    [subcontroller setSupercontroller:nil];
    [_subcontrollers removeObjectAtIndex:index];
    METHOD_TRACE_OUT;
}

- (void)removeSubcontroller:(MOViewController *)subcontroller {
    MOAssertClass(subcontroller, MOViewController);
    MOParameterAssert(([subcontroller supercontroller] == self));
    
    unsigned index = [_subcontrollers indexOfObjectIdenticalTo:subcontroller];
    if (index != NSNotFound) {
        [self removeSubcontrollerAtIndex:index];
    }
}

- (void)controller:(MOViewController *)controller didInsertSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

- (void)controller:(MOViewController *)controller willRemoveSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

- (BOOL)isAncestorOfController:(MOViewController *)descendant {
    MOAssertClass(descendant, MOViewController);
    if (descendant == self) {
        return NO;
    }
    while ((descendant = [descendant supercontroller]) != nil) {
        if (descendant == self) {
            return YES;
        }
    }
    return NO;
}

#pragma mark *** Nib tracking/loading

- (NSString *)viewNibName {
    return [super windowNibName];
}

- (NSString *)viewNibPath {
    return [super windowNibPath];
}

- (NSString *)windowNibName {
    return [self viewNibName];
}

- (NSString *)windowNibPath {
    return [self viewNibPath];
}

- (BOOL)isViewLoaded {
    // If we have a view, or if we don't have one, but loading was done at some point.  Testing the isViewLoaded flag means that -setContentView:nil will "count" as having the view loaded.  If someone specifically calls -setContentView:nil, presumably it is becuase they do not want a view, for some reason, and we should no longer be trying to load or create it.
    return  (((_view != nil) || _vcFlags.isViewLoaded) ? YES : NO);
}

- (id)contentView {
    if (![self isViewLoaded]) {
        // Run pre-load hooks
        [self _MO_viewWillLoad];
        
        // Trigger NSWindowController to load the nib.
        // When this is complete, the nib should be loaded and -isWindowLoaded should be returning YES.
        (void)[self window];

        // Run post-load hooks
        if ([self isViewLoaded]) {
            [self _MO_viewDidLoad];
        }

        // If the view is already in a view hierarchy, let's note that it is installed.
        if ([_view superview]) {
            [self viewWasInstalled];
        }
    }
    return _contentView;
}

- (void)setContentView:(NSView *)aView {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOAssertClassOrNil(aView, NSView);
    MOAssert(![self isViewInstalled], @"setContentView: called while view controller's view is installed");
    if (_contentView != aView) {
        [_contentView release];
        _contentView = [aView retain];
        [_view release];
        _view = [[MOViewControllerView allocWithZone:[self zone]] initViewController:self contentView:_contentView];
    }
    // Record that the view is "loaded".  Even if the argument is nil, we count this as having "loaded".
    _vcFlags.isViewLoaded = YES;

    // And, make sure the machinery in the superclass knows that things are now "loaded" as well.
    if (![self isWindowLoaded]) {
        [self setWindow:nil];
    }    
    METHOD_TRACE_OUT;
}

- (NSView *)view {
    [self contentView]; // loads content view and creates view
    return _view;
}

- (void)setView:(NSView *)aView {
    NSLog(@"WARNING: -[MOViewController setView:] has been deprecated in favor of setContentView:.  Please change your code or update your nib files to connect to the new \"contentView\" outlet.");
    [self setContentView:aView];
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


- (void)loadView {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (![self isViewLoaded]) {
        [super loadWindow];
        // Get our sense of whether we loaded from superclass.
        _vcFlags.isViewLoaded = [self isWindowLoaded];
    }
    METHOD_TRACE_OUT;
}

- (void)loadWindow {
    [self loadView];
}

- (void)viewWillLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

- (void)viewDidLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

- (void)_MO_viewWillLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    [self viewWillLoad];
    METHOD_TRACE_OUT;
}

- (void)_MO_viewDidLoad {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    // (Re-)figure out the last key view to account for the fact that nextKeyView outlets may have been established after the firstKeyView outlet.
    [self _MO_computeLastKeyView];
    
    [self viewDidLoad];
    // Take pending view frame
    if (_savedViewFramePtr) {
        [[self view] setFrame:*_savedViewFramePtr];
        NSZoneFree([self zone], _savedViewFramePtr), _savedViewFramePtr = NULL;
    }
    METHOD_TRACE_OUT;
}

#pragma mark *** View install/uninstall

- (BOOL)isViewInstalled {
    return _vcFlags.isViewInstalled;
}

- (void)viewWasInstalled {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (!_vcFlags.isViewInstalled) {
        NSView *theView = [self view];

        // Insert ourself into the responder chain.
        NSResponder *origNextResponder = [theView nextResponder];
        [theView setNextResponder:self];
        [self setNextResponder:origNextResponder];

        // Insert ourself into the key view loop
        id firstKVOfSelf = [self firstKeyView];
        if (firstKVOfSelf) {
            // We must locate the controller whose key loop we should be inserted after
            MOViewController *supercontroller = [self supercontroller];
            if (supercontroller) {
                NSArray *subcontrollers = [supercontroller subcontrollers];
                unsigned myIndex = [subcontrollers indexOfObjectIdenticalTo:self];
                MOAssert((myIndex != NSNotFound), @"Error: %@ I am not a subcontroller of my supercontroller.  Aiiggghhhh!", MOFullMethodName(self, _cmd));
                MOViewController *insertAfterController = nil;
                // Start by searching backwards in the subcontrollers of our parent starting with the subcontroller right before us looking for one that both has a firstKeyView and is currently installed itself.
                unsigned insertAfterIndex = myIndex;
                while (insertAfterIndex--) {
                    MOViewController *curSibling = [subcontrollers objectAtIndex:insertAfterIndex];
                    if ([curSibling isViewInstalled] && [curSibling firstKeyView]) {
                        insertAfterController = curSibling;
                        break;
                    }
                }
                
                // If that fails, try to use our parent controller.
                if (!insertAfterController && [supercontroller firstKeyView]) {
                    insertAfterController = supercontroller;
                }
                    
                if (insertAfterController) {
                    id lastKVOfInsertAfterController = [insertAfterController lastKeyView];
                    id nextKVOfLastKVOfInsertAfterController = [lastKVOfInsertAfterController nextKeyView];
                    if (!nextKVOfLastKVOfInsertAfterController) {
                        nextKVOfLastKVOfInsertAfterController = lastKVOfInsertAfterController;
                    }
                    // Note this calls previousKeyView on our firstKeyView intentionally instead of using -lastKeyView.
                    id previousKVOfFirstKVOfSelf = [firstKVOfSelf previousKeyView];
                    if (!previousKVOfFirstKVOfSelf) {
                        previousKVOfFirstKVOfSelf = firstKVOfSelf;
                    }
                    [lastKVOfInsertAfterController setNextKeyView:firstKVOfSelf];
                    [previousKVOfFirstKVOfSelf setNextKeyView:nextKVOfLastKVOfInsertAfterController];
                }
                // Ultimately our firstKeyView and lastKeyView are never changed as the view is installed and uninstalled, but our firstKeyView's previousKeyView and our lastKeyView's nextKeyView are.
            }
        }
        
        _vcFlags.isViewInstalled = YES;
        _vcFlags.hasEverBeenInstalled = YES;

        [self _MO_controller:self notifyControllersWithSelector:@selector(controllerViewWasInstalled:) subcontroller:nil atIndex:NSNotFound];
    }
    METHOD_TRACE_OUT;
}

- (void)viewWillBeUninstalled {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (_vcFlags.isViewInstalled) {
        NSView *theView = [self view];

        [self _MO_controller:self notifyControllersWithSelector:@selector(controllerViewWillBeUninstalled:) subcontroller:nil atIndex:NSNotFound];

        // Remove ourself from the key view loop.
        // This is simpler than the install side.  All we need to do is set the nextKeyView of our firstKeyView's previousKeyView to be our lastKeyView's nextKeyView.  We also (re)set the nextKeyView of our lastKeyView to be our firstKeyView (if they are not the same view).  (It's actually simpler than it sounds.)
        id firstKeyView = [self firstKeyView];
        if (firstKeyView) {
            id lastKeyView = [self lastKeyView];
            [[firstKeyView previousKeyView] setNextKeyView:[lastKeyView nextKeyView]];
            if (firstKeyView != lastKeyView) {
                [lastKeyView setNextKeyView:firstKeyView];
            }
        }
        
        // Remove ourself from the responder chain.
        [theView setNextResponder:[self nextResponder]];

        _vcFlags.isViewInstalled = NO;
    }
    METHOD_TRACE_OUT;
}

- (void)controllerViewWasInstalled:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

- (void)controllerViewWillBeUninstalled:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

- (void)update {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

#pragma mark *** Keyboard UI

- (id)firstKeyView {
    (void)[self view];
    return _firstKeyView;
}

- (void)_MO_computeLastKeyView {
    _lastKeyView = [_firstKeyView previousKeyView];
    if (!_lastKeyView) {
        _lastKeyView = _firstKeyView;
    }
}

- (void)setFirstKeyView:(id)aFirstKeyView {
    MOAssert(!_vcFlags.hasEverBeenInstalled, @"Error: %@ must be called before the receiver's view has been installed.", MOFullMethodName(self, _cmd));
    if (_firstKeyView != aFirstKeyView) {
        _firstKeyView = aFirstKeyView;
        // Figure out the last key view
        [self _MO_computeLastKeyView];
        
        // !!!:mike:20030309 Should we tell anyone or do anything?
    }
}

- (id)lastKeyView {
    (void)[self view];
    return _lastKeyView;
}

- (void)keyDown:(NSEvent *)event {
    // Handle tabbing...  There are times when a MOViewController is first responder.  The common case of this is that when a top-level view controller's window would otherwise be first responder, the view controller is made first responder instead to try to ensure that the root view controller of a window always gets a shot at handling action and event messages.  But if a view controller is first responder, it is not part of the key view loop of the window and therefore keyboard navigation will not function without some help...
    static NSString *tabString = nil;
    static NSString *backTabString = nil;
    
    NSWindow *window = [[self contentView] window];
    
    // We only want to do our thing if we are first responder and the key event is a tab or backtab.  Otherwise we want to let NSWindow handle things, so we call super.
    if ([window firstResponder] == self) {
        if (!tabString) {
            unichar ch = NSTabCharacter;
            tabString = [[NSString alloc] initWithCharacters:&ch length:1];
        }
        if (!backTabString) {
            unichar ch = NSBackTabCharacter;
            backTabString = [[NSString alloc] initWithCharacters:&ch length:1];
        }
        NSString *eventChars = [event charactersIgnoringModifiers];
        if ([eventChars isEqualToString:tabString]) {
            // Tab
            // Try our firstKeyView, if we have one, otherwise, fall back to the window's initial first responder.
            id newFR = [self firstKeyView];
            if (!newFR) {
                newFR = [window initialFirstResponder];
            }
            // In order to be able to use NSWindow's -selectKeyViewFollowingView: (which does more work for us than -makeFirstResponder: would), we go to the previous key view of the one we actually want.
            newFR = [newFR previousKeyView];
            [window selectKeyViewFollowingView:newFR];
            return;
        } else if ([eventChars isEqualToString:backTabString]) {
            // Back-Tab (shift tab)
            // Try our firstKeyView, if we have one, otherwise, fall back to the window's initial first responder.
            id newFR = [self firstKeyView];
            if (!newFR) {
                newFR = [window initialFirstResponder];
            }
            // Just let NSWindow find the first view before the one we found that will accept first responder.
            [window selectKeyViewPrecedingView:newFR];
            return;
        }
    }
    // If we have not returned by now, call super.
    [super keyDown:event];
}

#pragma mark *** Own window stuff

- (void)setWantsOwnWindow:(BOOL)flag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    if (_vcFlags.wantsOwnWindow != flag) {
        if (_vcFlags.wantsOwnWindow) {
            [_ownWindowController release], _ownWindowController = nil;
        }
        _vcFlags.wantsOwnWindow = flag;
        if (_vcFlags.wantsOwnWindow) {
            _ownWindowController = [[_MO_WindowController allocWithZone:[self zone]] initWithRootViewController:self];
        }        
    }
    METHOD_TRACE_OUT;
}

- (BOOL)wantsOwnWindow {
    return _vcFlags.wantsOwnWindow;
}

- (NSWindow *)loadControllerWindow {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    Class winClass = [self controllerWindowClass];
    NSView *aView = [self view];  // If we're being asked to create the window, we're going to be loading the view anyway, so do not worry about laziness.
    NSRect viewFrame = [aView frame];
    NSWindow *window = [[winClass allocWithZone:[self zone]] initWithContentRect:viewFrame styleMask:[self controllerWindowStyleMask] backing:NSBackingStoreBuffered defer:YES];

    METHOD_TRACE_OUT;
    return [window autorelease];
}

- (Class)controllerWindowClass {
    return [NSWindow class];
}

- (unsigned int)controllerWindowStyleMask {
    // Normal document-style window.
    return (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask);
}

- (NSWindowController *)windowController {
    if (_vcFlags.wantsOwnWindow) {
        return _ownWindowController;
    } else {
        return [[self supercontroller] windowController];
    }
}

- (void)showWindow:(id)sender {
    if (_vcFlags.wantsOwnWindow) {
        [_ownWindowController showWindow:sender];
    } else {
        [[self supercontroller] showWindow:sender];
    }
}

#pragma mark *** Label stuff

- (void)setLabel:(NSString *)label icon:(NSImage *)icon representedFilename:(NSString *)path {
    MOAssertClass(label, NSString);
    MOAssertClassOrNil(icon, NSImage);
    MOAssertClassOrNil(path, NSString);
    BOOL sendNotice = NO;
    if (label != _label) {
        sendNotice = YES;
        [_label release];
        _label = [label copyWithZone:[self zone]];
    }
    if (path != _representedFilename) {
        sendNotice = YES;
        [_representedFilename release];
        _representedFilename = [path copyWithZone:[self zone]];
    }
    if (icon != _icon) {
        sendNotice = YES;
        [_icon release];
        _icon = [icon retain];
        _vcFlags.shouldFetchIcon = NO;
    }
    if (sendNotice) {
        [self _MO_sendControllerDidChangeLabel];
    }
}

- (void)setLabel:(NSString *)label {
    [self setLabel:label icon:[self icon] representedFilename:nil];
}

- (void)setIcon:(NSImage *)icon {
    [self setLabel:[self label] icon:icon representedFilename:[self representedFilename]];
}

- (void)setRepresentedFilename:(NSString *)path {
    [self setLabel:[self label] icon:[self icon] representedFilename:path];
}

- (void)setLabelAsFilename:(NSString *)path {
    MOAssertClass(path, NSString);
    [self setLabel:[path lastPathComponent] icon:nil representedFilename:path];
    // Fetch icon lazily since this will involve disk access and it may be common that no one ever asks...
    _vcFlags.shouldFetchIcon = YES;
}

- (NSString *)label {
    return _label;
}

- (NSImage *)icon {
    if (!_icon && _vcFlags.shouldFetchIcon) {
        _vcFlags.shouldFetchIcon = NO;
        if (_representedFilename) {
            _icon = [[[NSWorkspace sharedWorkspace] iconForFile:_representedFilename] retain];
        }
    }
    return _icon;
}

- (NSString *)representedFilename {
    return _representedFilename;
}

- (void)_MO_sendControllerDidChangeLabel {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    MOViewController *controller = self;

    while (controller) {
        [controller controllerDidChangeLabel:self];
        controller = [controller supercontroller];
    }
    if ([self wantsOwnWindow]) {
        [(_MO_WindowController *)[self windowController] controllerDidChangeLabel:self];
    }
    METHOD_TRACE_OUT;
}

- (void)controllerDidChangeLabel:(MOViewController *)controller {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    METHOD_TRACE_OUT;
}

#pragma mark *** Session state

// Global keys
static NSString * const MOSubcontrollerCountKey = @"MOSubcontrollerCount";
static NSString * const MOSubcontrollerKeyFormat = @"MOSubcontroller:%u";
static NSString * const MOClassKey = @"MOClass";

// Hierarchy config keys
static NSString * const MOLabelKey = @"MOLabel";
static NSString * const MOIconKey = @"MOIcon";
static NSString * const MORepresentedFilenameKey = @"MORepFile";

// Geometry config keys
static NSString * const MOFrameKey = @"MOFrame";

- (NSRect)_MO_viewFrameShouldArchive:(BOOL *)boolPtr {
    if ([self isViewLoaded]) {
        NSView *view = [self view];
        if (view) {
            *boolPtr = YES;
            return [view frame];
        } else {
            *boolPtr = NO;
            return MOViewControllerDefaultFrame;
        }
    } else {
        *boolPtr = (_savedViewFramePtr ? YES : NO);
        return (_savedViewFramePtr ? *_savedViewFramePtr : MOViewControllerDefaultFrame);
    }
}

- (void)_MO_setViewFrame:(NSRect)rect {
    if ([self isViewLoaded]) {
        NSView *view = [self view];
        if (view) {
            [view setFrame:rect];
        }
    } else {
        if (!_savedViewFramePtr) {
            _savedViewFramePtr = NSZoneMalloc([self zone], sizeof(NSRect));
        }
        *_savedViewFramePtr = rect;
    }
}

- (NSMutableDictionary *)stateDictionaryIgnoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // Save our class.
    NSString *className;
    id <MOViewControllerClassLoader> classLoader = [[self class] viewControllerClassLoader];
    if (classLoader) {
        className = [classLoader stringFromViewControllerClass:[self class]];
    } else {
        className = NSStringFromClass([self class]);
    }
    [dict setObject:className forKey:MOClassKey];

    // Save our label
    NSString *label = [self label];
    if (![label isEqualToString:NSStringFromClass([self class])]) {
        [dict setObject:label forKey:MOLabelKey];
    }
    NSImage *icon = [self icon];
    if (icon) {
        [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:icon] forKey:MOIconKey];
    }
    NSString *repFile = [self representedFilename];
    if (repFile) {
        [dict setObject:repFile forKey:MORepresentedFilenameKey];
    }
    
    // Save our view frame
    BOOL shouldArchiveFrame = NO;
    NSRect viewFrame = [self _MO_viewFrameShouldArchive:&shouldArchiveFrame];
    if (shouldArchiveFrame) {
        [dict setObject:NSStringFromRect(viewFrame) forKey:MOFrameKey];
    }

    if ([self savesSubcontrollerState]) {
        // Recursively save subcontroller configuration.
        NSArray *children = [self subcontrollers];
        unsigned i, c = [children count];
        [dict setObject:[NSNumber numberWithUnsignedInt:c] forKey:MOSubcontrollerCountKey];
        for (i=0; i<c; i++) {
            MOViewController *curChild = [children objectAtIndex:i];
            NSString *key = [[NSString allocWithZone:[self zone]] initWithFormat:MOSubcontrollerKeyFormat, i];
            NSDictionary *curChildDict = [curChild stateDictionaryIgnoringContentState:ignoreContentFlag];
            if ([curChildDict count] > 0) {
                [dict setObject:curChildDict forKey:key];
            }
            [key release];
        }
    }

    METHOD_TRACE_OUT;
    return dict;
}

- (void)takeStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    // Restore label stuff
    NSString *label = [dict objectForKey:MOLabelKey];
    if (!label) {
        label = NSStringFromClass([self class]);
    }
    NSData *iconData = [dict objectForKey:MOIconKey];
    NSImage *icon = nil;
    if (iconData) {
        icon = [NSKeyedUnarchiver unarchiveObjectWithData:iconData];
    }
    NSString *repFile = [dict objectForKey:MORepresentedFilenameKey];
    [self setLabel:label icon:icon representedFilename:repFile];

    // Restore our frame
    NSString *frameStr = [dict objectForKey:MOFrameKey];
    if (frameStr) {
        NSRect frame = NSRectFromString(frameStr);
        [self _MO_setViewFrame:frame];
    }
            
    if ([self savesSubcontrollerState]) {
        // Recursively restore subcontroller configuration.
        NSArray *children = [self subcontrollers];
        NSNumber *cNum = [dict objectForKey:MOSubcontrollerCountKey];
        unsigned i, c = [cNum unsignedIntValue];
        
        if (c > [children count]) {
            c = [children count];
        }

        for (i=0; i<c; i++) {
            MOViewController *curChild = [children objectAtIndex:i];
            NSString *key = [[NSString allocWithZone:[self zone]] initWithFormat:MOSubcontrollerKeyFormat, i];
            NSDictionary *curChildDict = [dict  objectForKey:key];
            [key release];
            if (curChildDict) {
                [curChild takeStateDictionary:curChildDict ignoringContentState:ignoreContentFlag];
            }
        }
    }
    METHOD_TRACE_OUT;
}

- (BOOL)savesSubcontrollerState {
    return YES;
}

+ (id)_MO_viewControllerWithStateDictionary:(NSDictionary *)dict {
    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
    NSString *className = [dict objectForKey:MOClassKey];
    if (!className || ![className isKindOfClass:[NSString class]]) {
        NSLog(@"%@: MOClass key is missing or not a string.", MOFullMethodName(self, _cmd));
        return nil;
    }
    Class theClass = Nil;
    id <MOViewControllerClassLoader> classLoader = [self viewControllerClassLoader];
    if (classLoader) {
        theClass = [classLoader viewControllerClassFromString:className];
    } else {
        theClass = NSClassFromString(className);
    }
    if (!theClass) {
        NSLog(@"%@: Could not locate class for MOClass key '%@'.", MOFullMethodName(self, _cmd), className);
        return nil;
    }
    MOViewController *controller = [[theClass allocWithZone:NULL] init];
            
    if ([controller savesSubcontrollerState]) {
        // Do subcontrollers.
        NSNumber *cNum = [dict objectForKey:MOSubcontrollerCountKey];
        if (cNum && ![cNum isKindOfClass:[NSNumber class]]) {
            NSLog(@"%@: MOSubcontrollerCount key is not a number.", MOFullMethodName(self, _cmd));
        } else if (cNum) {
            unsigned i, c = [cNum unsignedIntValue];
            
            for (i=0; i<c; i++) {
                NSString *key = [[NSString allocWithZone:[self zone]] initWithFormat:MOSubcontrollerKeyFormat, i];
                NSDictionary *curChildDict = [dict  objectForKey:key];
                [key release];
                if (curChildDict && ![curChildDict isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"%@: MOSubcontroller:%u key is not a dictionary.", MOFullMethodName(self, _cmd), i);
                } else if (curChildDict) {
                    MOViewController *newChild = [self _MO_viewControllerWithStateDictionary:curChildDict];
                    [controller addSubcontroller:newChild];
                }
            }
        }
    }
    METHOD_TRACE_OUT;
    
    return [controller autorelease];
}

+ (id)viewControllerWithStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag {
    MOViewController *controller = [self _MO_viewControllerWithStateDictionary:dict];
    [controller takeStateDictionary:dict ignoringContentState:ignoreContentFlag];
    return controller;
}

#pragma mark *** Class loader support

static id <MOViewControllerClassLoader> _classLoader = nil;

+ (void)setViewControllerClassLoader:(id <MOViewControllerClassLoader>)classLoader {
    _classLoader = classLoader;
}

+ (id <MOViewControllerClassLoader>)viewControllerClassLoader {
    return _classLoader;
}

#pragma mark *** Visible focus indication

static BOOL _activeControllerShowsFocus = NO;

+ (BOOL)activeControllerShowsFocus {
    return _activeControllerShowsFocus;
}

+ (void)setActiveControllerShowsFocus:(BOOL)flag {
    if (_activeControllerShowsFocus != flag) {
        _activeControllerShowsFocus = flag;
        [[NSNotificationCenter defaultCenter] postNotificationName:_MO_FocusRingNeedsDisplayNotification object:self];
    }
}

static NSColor *_focusRingColor = nil;
static float _focusRingWidth = 3.0;

+ (NSColor *)focusRingColor {
    if (_focusRingColor) {
        return _focusRingColor;
    } else {
        return [NSColor keyboardFocusIndicatorColor];
    }
}

+ (void)setFocusRingColor:(NSColor *)color {
    if (_focusRingColor != color) {
        [_focusRingColor release];
        _focusRingColor = [color retain];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:_MO_FocusRingNeedsDisplayNotification object:self];
    }
}

+ (float)focusRingWidth {
    return _focusRingWidth;
}

+ (void)setFocusRingWidth:(float)width {
    _focusRingWidth = width;
    [[NSNotificationCenter defaultCenter] postNotificationName:_MO_FocusRingNeedsDisplayNotification object:self];
}

- (BOOL)showsControllerFocus {
    return YES;
}

#pragma mark *** Misc minor overrides

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end

@implementation NSPasteboard (MOViewControllerPboard)

- (BOOL)setViewControllers:(NSArray *)controllers forType:(NSString *)dataType {
    MOAssertClass(controllers, NSArray);
    MOAssertClass(dataType, NSString);
    NSMutableArray *configs = [[NSMutableArray allocWithZone:[self zone]] init];
    unsigned i, c = [controllers count];
    for (i=0; i<c; i++) {
        MOViewController *curController = [controllers objectAtIndex:i];
        [configs addObject:[curController stateDictionaryIgnoringContentState:NO]];
    }
    BOOL result = [self setPropertyList:configs forType:dataType];
    [configs release];
    return result;
}

- (NSArray *)viewControllersForType:(NSString *)dataType {
    MOAssertClass(dataType, NSString);
    NSArray *configs = [self propertyListForType:dataType];
    if (configs) {
        NSMutableArray *controllers = [NSMutableArray array];
        unsigned i, c = [configs count];
        for (i=0; i<c; i++) {
            NSDictionary *stateDict = [configs objectAtIndex:i];
            MOViewController *newController = [MOViewController viewControllerWithStateDictionary:stateDict ignoringContentState:NO];
            if (newController) {
                [controllers addObject:newController];
            }
        }
        return controllers;
    } else {
        return nil;
    }
}

@end

NSString *MOViewControllerPboardType = @"MOViewControllerPboardType";

const NSRect MOViewControllerDefaultFrame = {{0.0, 0.0}, {500.0, 400.0}};

/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
