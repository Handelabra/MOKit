// MOViewListView.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOViewListView.h>
#import <MOKit/MOViewListViewItem_Private.h>
#import <MOKit/MOAssertions.h>
#import <MOKit/NSView_MOSizing.h>
#import <MOKit/MOViewListLabelView.h>

//#define DO_DEBUG_LOGS

static const float _LabelBarHorizontalMargin = 4.0;
static const float _LabelBarVerticalMargin = 4.0;
static const float _SubviewLeftIndent = 10.0;
static const float _AnimationDuration = 0.20;
static const float _AnimationInterval = 1.0 / 30.0;  // shoot for 30 fps

@interface _MO_MaskingView : NSView {}
// Used for animation of collapsing/expanding
@end

@interface MOViewListView (MOPrivate)

- (void)_MO_commonInit;
- (void)_MO_viewDidChangeFrame:(NSNotification *)notification;
- (void)_MO_myViewDidChangeFrame:(NSNotification *)notification;
- (void)_MO_doNeededLayout;
- (void)_MO_animateViewAtIndex:(int)index;

@end

typedef enum {
    MOInitialVersion = 1,
} MOClassVersion;

static const MOClassVersion MOCurrentClassVersion = MOInitialVersion;

@implementation MOViewListView

+ (void)initialize {
    // Set the version.  Load classes, and init class variables.
    if (self == [MOViewListView class])  {
        [self setVersion:MOCurrentClassVersion];

        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:@"YES", @"MOViewListViewUsesAnimation", nil]];
    }
}

+ (void)setUsesAnimation:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setObject:(flag ? @"YES" : @"NO") forKey:@"MOViewListViewUsesAnimation"];
}

+ (BOOL)usesAnimation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MOViewListViewUsesAnimation"];
}

- (void)_MO_commonInit {
    _controlSize = NSRegularControlSize;
    _firstViewNeedingLayout = 0;
    _layoutDisabled = 0;
    _animationViewIndex = NSNotFound;
    _animationAmountRevealed = 0.0;
    _animationMaskingView = nil;
    _delegate = nil;
    _vlvFlags.doingLayout = NO;
    _vlvFlags.delegateImplementsShouldExpand = NO;
    _vlvFlags.delegateImplementsWillExpand = NO;
    _vlvFlags.delegateImplementsDidExpand = NO;
    _vlvFlags.delegateImplementsShouldCollapse = NO;
    _vlvFlags.delegateImplementsWillCollapse = NO;
    _vlvFlags.delegateImplementsDidCollapse = NO;    
    _vlvFlags.delegateImplementsValidateDrop = NO;
    _vlvFlags.delegateImplementsAcceptDrop = NO;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _items = [[NSMutableArray allocWithZone:[self zone]] init];
        _labelViews = [[NSMutableArray allocWithZone:[self zone]] init];
        
        [self _MO_commonInit];
        
        // Set initial appearance
        [self setLabelBarAppearance:MOViewListViewDefaultLabelBars];
        [self setBackgroundColor:[NSColor controlColor]];

        // We control subview sizing more directly
        [self setAutoresizesSubviews:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_MO_myViewDidChangeFrame:) name:NSViewFrameDidChangeNotification object:self];

        // Take our min size from the clip view we live in, if any
        [self MO_setTakesMinSizeFromClipView:YES];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_items release], _items = nil;
    [_backgroundColor release], _backgroundColor = nil;
    [super dealloc];
}

/// Simple management of the stacked views and labels

- (int)numberOfViewListViewItems {
    return [_items count];
}

- (NSArray *)viewListViewItems {
    return _items;
}

- (MOViewListViewItem *)viewListViewItemAtIndex:(int)index {
    MOParameterAssert((index < (int)[_items count]));
    return (MOViewListViewItem *)[_items objectAtIndex:index];
}

- (void)insertViewListViewItem:(MOViewListViewItem *)item atIndex:(int)index {
    MOAssertClass(item, MOViewListViewItem);
    MOParameterAssert((index <= [self numberOfViewListViewItems]));
    MOAssert(([_items indexOfObjectIdenticalTo:item] == NSNotFound), @"The item %@ is already an item of the MOViewListView %@", item, self);

    [item _MO_setCollapsed:YES];
    [_items insertObject:item atIndex:index];
    [item setViewListView:self];
    
    MOViewListLabelView *labelView = [[[self viewListLabelViewClass] allocWithZone:[self zone]] initWithViewListView:self andViewListViewItem:item];
    [self addSubview:labelView];
    [_labelViews insertObject:labelView atIndex:index];
    [labelView release];

    [self invalidateLayoutStartingWithStackedViewAtIndex:index];
}

- (void)removeViewListViewItemAtIndex:(int)index {
    MOParameterAssert((index < [self numberOfViewListViewItems]));

    MOViewListViewItem *item = [self viewListViewItemAtIndex:index];

    [item setViewListView:nil];
    [_items removeObjectAtIndex:index];
    
    MOViewListLabelView *labelView = [_labelViews objectAtIndex:index];
    [labelView invalidate];
    [labelView removeFromSuperview];
    [_labelViews removeObjectAtIndex:index];

    [self invalidateLayoutStartingWithStackedViewAtIndex:index];
}

- (void)addViewListViewItem:(MOViewListViewItem *)item {
    [self insertViewListViewItem:item atIndex:[self numberOfViewListViewItems]];
}

- (int)indexOfStackedView:(NSView *)view {
    MOAssertClass(view, NSView);

    unsigned i, c = [self numberOfViewListViewItems];
    for (i=0; i<c; i++) {
        if ([[self viewListViewItemAtIndex:i] view] == view) {
            return i;
        }
    }
    return -1;
}

- (MOViewListViewItem *)insertStackedView:(NSView *)view atIndex:(int)index withLabel:(NSString *)label {
    MOAssertClass(view, NSView);
    MOAssertString(label);

    MOViewListViewItem *newItem = [[MOViewListViewItem allocWithZone:[self zone]] initWithView:view andLabel:label];
    [self insertViewListViewItem:newItem atIndex:index];
    [newItem release];
    return newItem;
}

- (MOViewListViewItem *)addStackedView:(NSView *)view withLabel:(NSString *)label {
    return [self insertStackedView:view atIndex:[self numberOfViewListViewItems] withLabel:label];
}

- (void)collapseStackedViewAtIndex:(int)index animate:(BOOL)animateFlag {
    MOViewListViewItem *item = [self viewListViewItemAtIndex:index];
    if (![item isCollapsed]) {
        if (_vlvFlags.delegateImplementsWillCollapse) {
            [[self delegate] viewListView:self willCollapseViewListViewItem:item];
        }
        [item _MO_setCollapsed:YES];
        if (animateFlag) {
            [self _MO_animateViewAtIndex:index];
        }
        if (_vlvFlags.delegateImplementsDidCollapse) {
            [[self delegate] viewListView:self didCollapseViewListViewItem:item];
        }
        [self invalidateLayoutStartingWithStackedViewAtIndex:index];
        if (animateFlag) {
            [[self window] displayIfNeeded];
        }
    }
}

- (void)expandStackedViewAtIndex:(int)index animate:(BOOL)animateFlag {
    MOViewListViewItem *item = [self viewListViewItemAtIndex:index];
    if ([item isCollapsed]) {
        if (_vlvFlags.delegateImplementsWillExpand) {
            [[self delegate] viewListView:self willExpandViewListViewItem:item];
        }
        [item _MO_setCollapsed:NO];
        if (animateFlag) {
            [self _MO_animateViewAtIndex:index];
        }
        [self invalidateLayoutStartingWithStackedViewAtIndex:index];
        if (_vlvFlags.delegateImplementsDidExpand) {
            [[self delegate] viewListView:self didExpandViewListViewItem:item];
        }
        if (animateFlag) {
            [[self window] displayIfNeeded];
        }
    }
}

- (void)toggleStackedViewAtIndex:(int)index animate:(BOOL)animateFlag {
    if ([[self viewListViewItemAtIndex:index] isCollapsed]) {
        [self expandStackedViewAtIndex:index animate:animateFlag];
    } else {
        [self collapseStackedViewAtIndex:index animate:animateFlag];
    }
}

- (void)collapseStackedViewAtIndex:(int)index {
    [self collapseStackedViewAtIndex:index animate:[[self class] usesAnimation]];
}

- (void)expandStackedViewAtIndex:(int)index {
    [self expandStackedViewAtIndex:index animate:[[self class] usesAnimation]];
}

- (void)toggleStackedViewAtIndex:(int)index {
    [self toggleStackedViewAtIndex:index animate:[[self class] usesAnimation]];
}

- (void)setDelegate:(id)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        _vlvFlags.delegateImplementsShouldExpand = [_delegate respondsToSelector:@selector(viewListView:shouldExpandViewListViewItem:)];
        _vlvFlags.delegateImplementsWillExpand = [_delegate respondsToSelector:@selector(viewListView:willExpandViewListViewItem:)];
        _vlvFlags.delegateImplementsDidExpand = [_delegate respondsToSelector:@selector(viewListView:didExpandViewListViewItem:)];
        _vlvFlags.delegateImplementsShouldCollapse = [_delegate respondsToSelector:@selector(viewListView:shouldCollapseViewListViewItem:)];
        _vlvFlags.delegateImplementsWillCollapse = [_delegate respondsToSelector:@selector(viewListView:willCollapseViewListViewItem:)];
        _vlvFlags.delegateImplementsDidCollapse = [_delegate respondsToSelector:@selector(viewListView:didCollapseViewListViewItem:)];
        _vlvFlags.delegateImplementsValidateDrop = [_delegate respondsToSelector:@selector(viewListView:validateDrop:proposedItemIndex:proposedDropOperation:)];
        _vlvFlags.delegateImplementsAcceptDrop = [_delegate respondsToSelector:@selector(viewListView:acceptDrop:itemIndex:dropOperation:)];
    }
    
}

- (id)delegate {
    return _delegate;
}

/// Geometry and layout stuff

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    NSColor *bgColor = [self backgroundColor];
    return ((bgColor && ([bgColor alphaComponent] == 1.0)) ? YES : NO);
}

- (void)setControlSize:(NSControlSize)size {
    if (_controlSize != size) {
        _controlSize = size;
        [self invalidateLayoutStartingWithStackedViewAtIndex:0];
    }
}

- (NSControlSize)controlSize {
    return _controlSize;
}

- (NSFont *)labelFont {
    if ([self controlSize] == NSRegularControlSize) {
        return [NSFont systemFontOfSize:[NSFont systemFontSize]];
    } else {
        return [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
    }
}

- (float)labelHeight {
    NSFont *labelFont = [self labelFont];
    return [[self viewListLabelViewClass] labelHeightForFont:labelFont];
}

- (MOViewListViewLabelBarAppearance)labelBarAppearance {
    return _labelBarAppearance;
}

- (void)setLabelBarAppearance:(MOViewListViewLabelBarAppearance)labelBarAppearance {
    if (labelBarAppearance == MOViewListViewDefaultLabelBars) {
        labelBarAppearance = MOViewListViewLightGrayLabelBars;
    }
    if (labelBarAppearance != _labelBarAppearance) {
        _labelBarAppearance = labelBarAppearance;
        [self invalidateLayoutStartingWithStackedViewAtIndex:0];
    }
}

- (NSColor *)backgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)color {
    MOAssertClassOrNil(color, NSColor);
    
    if (color != _backgroundColor) {
        [_backgroundColor release];
        _backgroundColor = [color retain];
        [self setNeedsDisplay:YES];
    }
}

- (Class)viewListLabelViewClass {
    return _viewListLabelViewClass ? _viewListLabelViewClass : [MOViewListLabelView class];
}

- (void)setViewListLabelViewClass:(Class)theClass {
    if (theClass != _viewListLabelViewClass) {
        _viewListLabelViewClass = theClass;
        unsigned i, c = [_items count];
        i = c;
        while (i--) {
            MOViewListLabelView *oldLabelView = [_labelViews objectAtIndex:i];
            [oldLabelView invalidate];
            [oldLabelView removeFromSuperview];
            [_labelViews removeObjectAtIndex:i];
        }
        for (i=0; i<c; i++) {
            MOViewListLabelView *newLabelView = [[theClass allocWithZone:[self zone]] initWithViewListView:self andViewListViewItem:[_items objectAtIndex:i]];
            [self addSubview:newLabelView];
            [_labelViews addObject:newLabelView];
            [newLabelView release];
        }
        [self invalidateLayoutStartingWithStackedViewAtIndex:0];
    }
}

- (NSRect)frameForLabelBarAtIndex:(int)index {
    [self _MO_doNeededLayout];
    MOViewListViewItem *item = [self viewListViewItemAtIndex:index];
    NSRect labelFrame, bounds = [self bounds];

    labelFrame = NSMakeRect(NSMinX(bounds) + _LabelBarHorizontalMargin, [item labelYPosition], NSWidth(bounds) - (_LabelBarHorizontalMargin * 2.0), [self labelHeight]);

    return labelFrame;
}

- (NSRect)frameForDisclosureControlAtIndex:(int)index {
    [self _MO_doNeededLayout];
    MOViewListLabelView *labelView = [_labelViews objectAtIndex:index];
    NSRect rect = [self convertRect:[labelView frameForDisclosureControl] fromView:labelView];
    return rect;
}

- (NSRect)frameForLabelTextAtIndex:(int)index {
    [self _MO_doNeededLayout];
    MOViewListLabelView *labelView = [_labelViews objectAtIndex:index];
    NSRect rect = [self convertRect:[labelView frameForLabelText] fromView:labelView];
    return rect;
}

- (void)_MO_viewDidChangeFrame:(NSNotification *)notification {
    if (!_vlvFlags.doingLayout) {
        NSView *view = [notification object];
        int i = [self indexOfStackedView:view];

        // If it is ours (it should be) and it is expanded, then deal with it.
        if ((i != -1) && ([view superview] == self)) {
            [self invalidateLayoutStartingWithStackedViewAtIndex:i];
        }
    }
}

- (void)_MO_myViewDidChangeFrame:(NSNotification *)notification {
    if (!_vlvFlags.doingLayout) {
        [self invalidateLayoutStartingWithStackedViewAtIndex:0];
    }
}

- (void)_MO_doNeededLayout {
    if (_vlvFlags.doingLayout) {
        // Bail, this can recurse because of frame setting or scrolling activity during the relayout.
        return;
    }
    
    unsigned i, c = [self numberOfViewListViewItems];
    
#ifdef DO_DEBUG_LOGS
    NSLog(@"_MO_doNeededLayout - _firstViewNeedingLayout is %d", _firstViewNeedingLayout);
#endif

    if (_firstViewNeedingLayout > (int)c) {
        _firstViewNeedingLayout = c;
    }
    
    // Clear the _firstViewNeedingLayout first.
    int startAtIndex = _firstViewNeedingLayout;
    _firstViewNeedingLayout = c;

    _vlvFlags.doingLayout = YES;

    float curY, startY;
    MOViewListViewItem *item;
    NSRect curFrame, bounds = [self bounds];
    float labelHeight = [self labelHeight];
    
    if (startAtIndex > 0) {
        item = [self viewListViewItemAtIndex:startAtIndex-1];
        curY = [item labelYPosition];
        curY += labelHeight;
        if (_animationViewIndex == startAtIndex-1) {
            curY += _animationAmountRevealed;
        } else if ([item isCollapsed]) {
            curY += _LabelBarVerticalMargin;
        } else {
            curY += NSHeight([[item view] frame]);
        }
    } else {
        curY = NSMinY(bounds) + _LabelBarVerticalMargin;
    }
    startY = curY;
#ifdef DO_DEBUG_LOGS
    NSLog(@"_MO_doNeededLayout - initial y coord for layout is %.1f", curY);
#endif

    BOOL doScroll = NO;
    NSRect scrollRect = NSZeroRect;
    
    for (i=startAtIndex; i<c; i++) {
        item = [self viewListViewItemAtIndex:i];

        // Set y position for label
        [item _MO_setLabelYPosition:curY];
        
        // Size and position label view for label
        NSRect labelViewFrame = [self frameForLabelBarAtIndex:i];
        [[_labelViews objectAtIndex:i] setFrame:labelViewFrame];
        
#ifdef DO_DEBUG_LOGS
        NSLog(@"_MO_doNeededLayout - set labelYPosition for view at %d to %.1f", i, curY);
#endif
        curY += labelHeight;

        // Do view
        if (_animationViewIndex == (int)i) {
            // This view is animating.  Increment by the amount currently revealed by animation.
            if (![item isCollapsed]) {
                // It is animating open, try to keep the revealed part visible.
                doScroll = YES;
                scrollRect = NSMakeRect(NSMinX(bounds), curY - labelHeight, NSWidth(bounds), labelHeight + _animationAmountRevealed);
            }
            curY += _animationAmountRevealed;
            // Make sure the masking view is the right height.
            curFrame = [_animationMaskingView frame];
            curFrame.size.height = _animationAmountRevealed;
            [_animationMaskingView setFrame:curFrame];
        } else if ([item isCollapsed]) {
            NSView *view = [item view];

            // This view is collapsed.  Leave a gap between labels when views are collapsed
            curY += _LabelBarVerticalMargin;
            
            if ([view superview] == self) {
                [view removeFromSuperview];
            }
        } else {
            NSView *view = [item view];

            curFrame = [view frame];
            curFrame = NSMakeRect(NSMinX(bounds) + _SubviewLeftIndent, curY, NSWidth(bounds) - _SubviewLeftIndent - _LabelBarHorizontalMargin, NSHeight(curFrame));
            [view setFrame:curFrame];

#ifdef DO_DEBUG_LOGS
            NSLog(@"_MO_doNeededLayout - set frame for view at %d to {{%.1f, %.1f}, {%.1f, %.1f}}", i, NSMinX(curFrame), NSMinY(curFrame), NSWidth(curFrame), NSHeight(curFrame));
#endif

            if ([view superview] != self) {
                [self addSubview:view];
            }
            curY += NSHeight(curFrame);
        }
    }

    // Now set our own frame
    curFrame = [self frame];
    curFrame.size.height = curY;
    [self setFrame:curFrame];

    if (doScroll) {
        [self scrollRectToVisible:scrollRect];
    }

#ifdef DO_DEBUG_LOGS
    NSLog(@"_MO_doNeededLayout - set frame for self to {{%.1f, %.1f}, {%.1f, %.1f}}", NSMinX(curFrame), NSMinY(curFrame), NSWidth(curFrame), NSHeight(curFrame));
#endif
    
    // And invalidate display
    bounds = [self bounds];
    [self setNeedsDisplayInRect:NSMakeRect(NSMinX(bounds), startY, NSWidth(bounds), NSHeight(bounds) - startY)];

#ifdef DO_DEBUG_LOGS
    NSLog(@"_MO_doNeededLayout - invalidated display for self in {{%.1f, %.1f}, {%.1f, %.1f}}", NSMinX(bounds), startY, NSWidth(bounds), curY - startY);
#endif
    
    _vlvFlags.doingLayout = NO;
}

- (void)disableLayout {
    _layoutDisabled++;
}

- (void)enableLayout {
    if (_layoutDisabled > 0) {
        _layoutDisabled--;
    }
    if (_layoutDisabled == 0) {
        [self _MO_doNeededLayout];
    }
}

- (BOOL)isLayoutDisabled {
    return ((_layoutDisabled == 0) ? NO : YES);
}

- (void)sizeToFit {
    if (![self isLayoutDisabled]) {
        [self _MO_doNeededLayout];
    }
}

- (void)MO_sizeConstraintsDidChange {
    [self sizeToFit];
}

- (void)invalidateLayoutStartingWithStackedViewAtIndex:(int)index {
    MOParameterAssert((index <= [self numberOfViewListViewItems]) && (index >= 0));

    if (index < _firstViewNeedingLayout) {
        _firstViewNeedingLayout = index;
    }
#ifdef DO_DEBUG_LOGS
    NSLog(@"invalidateLayoutStartingWithStackedViewAtIndex:%d - invalidated: _firstViewNeedingLayout is now %d", index, _firstViewNeedingLayout);
#endif
    [self sizeToFit];
}

/// Drawing stuff

- (void)drawRect:(NSRect)rect {
    [self _MO_doNeededLayout];

#ifdef DO_DEBUG_LOGS
    NSLog(@"drawRect:{{%.1f, %.1f}, {%.1f, %.1f}}", NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
#endif

    // Draw background
    NSColor *bgColor = [self backgroundColor];
    if (bgColor) {
        [bgColor set];
        //[[NSColor redColor] set];  // Sometimes used for debugging purposes
        NSRectFillUsingOperation(rect, NSCompositeSourceOver);
    }
    
    // Draw drop tracking visuals
    if (_dragOperation != NSDragOperationNone) {
        [[NSColor blackColor] set];
        if (_dropOperation == MOViewListViewDropOnItem) {
            // Draw a box around the label view.
            id labelView = [_labelViews objectAtIndex:_dropIndex];
            NSRect rect = NSInsetRect([labelView frame], -2.0, -2.0);
            
            NSFrameRectWithWidth(rect, 2.0);
        } else {
            // Draw a line above the label.
            float y;
            NSRect rect = [self bounds];
            unsigned c = [_labelViews count];
            if (_dropIndex == (int)c) {
                if (c > 0) {
                    y = NSMaxY([[_labelViews objectAtIndex:c-1] frame]) + 1.0;
                } else {
                    y = NSMinY(rect) + 1.0;
                }
            } else {
                y = NSMinY([[_labelViews objectAtIndex:_dropIndex] frame]) - 3.0;
            }
            rect.origin.y = y;
            rect.size.height = 2.0;
            NSRectFill(rect);
        }
    }
}

- (void)_MO_animateViewAtIndex:(int)index {
    MOViewListViewItem *item = [self viewListViewItemAtIndex:index];
    BOOL isCollapsing = ([item isCollapsed] ? YES : NO);
    
    // Make sure layout is current
    [self _MO_doNeededLayout];

    // Prepare to image the view
    NSView *view = [item view];
    NSRect viewFrame = [view frame];
    
    // Take view out of hierarchy and make sure it is appropriate size
    if (isCollapsing) {
        // View is already the right size, but it needs to be removed from the view hierarchy.
        [view removeFromSuperview];
    } else {
        // View is not in hierarchy, and may not be right width, size it.
        NSRect myBounds = [self bounds];

        viewFrame = NSMakeRect(_SubviewLeftIndent, [item labelYPosition] + [self labelHeight], NSWidth(myBounds) - _SubviewLeftIndent, NSHeight(viewFrame));
        [view setFrame:viewFrame];
    }

    // Create the masking view and set it up.
    _animationMaskingView  = [[_MO_MaskingView allocWithZone:[self zone]] initWithFrame:NSMakeRect(NSMinX(viewFrame), NSMinY(viewFrame), NSWidth(viewFrame), (isCollapsing ? NSHeight(viewFrame) : 0.0))];
    [view setFrameOrigin:NSMakePoint(0.0, 0.0)];
    [_animationMaskingView addSubview:view];
    [self addSubview:_animationMaskingView];

    _animationViewIndex = index;
    _animationAmountRevealed = (isCollapsing ? NSHeight(viewFrame) : 0.0);

    NSDate *startDate = [NSDate date];

#ifdef DO_DEBUG_LOGS
    NSLog(@"_MO_animateViewAtIndex:%d - Starting periodic events, startDate = %@.", index, startDate);
#endif
    [NSEvent startPeriodicEventsAfterDelay:0.0 withPeriod:_AnimationInterval];

    while (1) {
        (void)[[self window] nextEventMatchingMask:NSPeriodicMask];

        float duration = -[startDate timeIntervalSinceNow];
        float percentDone = duration / _AnimationDuration;

        if (percentDone > 1.0) {
            percentDone = 1.0;
        }
        static const float _StartAngle = 1.570796;  // 90 degrees in radians
        static const float _AngleRange = 4.712389 - 1.570796;  // 270 degrees in radians - 90 degrees in radians

        // Scale the percentDone on a sine curve
        // Take the sin at percentDone of the way through the range from 90 to 270 degrees (sin 1.0 to -1.0)
        // Scale the sin between 0 and 1
        percentDone = 1.0 - ((sin(_StartAngle + (percentDone * _AngleRange)) + 1.0) / 2.0);

        if (percentDone > 1.0) {
            percentDone = 1.0;
        }

        _animationAmountRevealed = ((NSHeight(viewFrame) - _LabelBarVerticalMargin) * (isCollapsing ? 1.0 - percentDone : percentDone)) + _LabelBarVerticalMargin;

#ifdef DO_DEBUG_LOGS
        NSLog(@"_MO_animateViewAtIndex:%d - Got periodic event, duration = %.3f, percentDone = %.2f, amount revealed = %.1f.", index, duration, percentDone, _animationAmountRevealed);
#endif

        [self invalidateLayoutStartingWithStackedViewAtIndex:index];

        if (percentDone >= 1.0) {
            break;
        }

        [[self window] displayIfNeeded];
    }

    [NSEvent stopPeriodicEvents];

#ifdef DO_DEBUG_LOGS
    NSLog(@"Animation lasted %.3f seconds", -[startDate timeIntervalSinceNow]);
#endif

#ifdef DO_DEBUG_LOGS
    NSLog(@"_MO_animateViewAtIndex:%d - Stopped periodic events. Done.", index);
#endif

    _animationViewIndex = NSNotFound;
    _animationAmountRevealed = 0.0;
    // Clean up the masking view and put the subview in place for real if it was not collapsing
    [_animationMaskingView removeFromSuperview];
    [view removeFromSuperview];
    [_animationMaskingView release], _animationMaskingView = nil;
}

- (void)setNeedsDisplayForLabelBarAtIndex:(int)index {
    MOParameterAssert(index < (int)[_items count]);
    [[_labelViews objectAtIndex:index] setNeedsDisplay:YES];
}

- (BOOL)shouldExpandViewListViewItem:(MOViewListViewItem *)item {
    if (_vlvFlags.delegateImplementsShouldExpand) {
        if (![[self delegate] viewListView:self shouldExpandViewListViewItem:item]) {
            // Veto, do not expand.
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldCollapseViewListViewItem:(MOViewListViewItem *)item {
    if (_vlvFlags.delegateImplementsShouldCollapse) {
        if (![[self delegate] viewListView:self shouldCollapseViewListViewItem:item]) {
            // Veto, do not collapse.
            return NO;
        }
    }
    return YES;
}

- (NSImage *)dragImageForItem:(MOViewListViewItem *)dragItem event:(NSEvent *)dragEvent dragImageOffset:(NSPointPointer)dragImageOffsetPtr {
    // !!!:mferris:20030411 Need a better default drag image
    NSImage *image = [[NSImage allocWithZone:[self zone]] initWithSize:NSMakeSize(16.0, 16.0)];
    
    [image lockFocus];
    [[NSColor redColor] set];
    NSRectFill(NSMakeRect(0.0, 0.0, 16.0, 16.0));
    [image unlockFocus];
    if (dragImageOffsetPtr) {
        NSSize imageSize = [image size];
        *dragImageOffsetPtr = NSMakePoint(floor(imageSize.width / 2.0), floor(imageSize.height / 2.0));
    }
    return [image autorelease];
}

- (void)setDropItemIndex:(int)itemIndex dropOperation:(MOViewListViewDropOperation)op {
    MOAssert(((itemIndex > 0) && (itemIndex <= (int)[[self viewListViewItems] count] - ((op == MOViewListViewDropOnItem) ? 1 : 0))), @"-setDropItemIndex:dropOperation: itemIndex %d out of range.", itemIndex);
    _dropIndex = itemIndex;
    _dropOperation = op;
}

#define ITEMS_KEY @"com.lorax.MOViewListView.items"
#define CONTROL_SIZE_KEY @"com.lorax.MOViewListView.controlSize"
#define BACKGROUND_COLOR_KEY @"com.lorax.MOViewListView.bgColor"
#define LABEL_BAR_APPEARANCE_KEY @"com.lorax.MOViewListView.labelBarAppearance"
#define DELEGATE_KEY @"com.lorax.MOViewListView.delegate"

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_items forKey:ITEMS_KEY];
        [coder encodeInt:_controlSize forKey:CONTROL_SIZE_KEY];
        [coder encodeObject:_backgroundColor forKey:BACKGROUND_COLOR_KEY];
        [coder encodeInt:_labelBarAppearance forKey:LABEL_BAR_APPEARANCE_KEY];
        [coder encodeConditionalObject:_delegate forKey:DELEGATE_KEY];
    } else {
        [NSException raise:NSGenericException format:@"MOViewListView does not support old-style non-keyed NSCoding."];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        if ([coder allowsKeyedCoding]) {
            [self _MO_commonInit];

            NSArray *items = [coder decodeObjectForKey:ITEMS_KEY];
            if (items) {
                _items = [[NSMutableArray allocWithZone:[self zone]] initWithArray:items];
                _labelViews = [[NSMutableArray allocWithZone:[self zone]] init];
                unsigned i, c = [_items count];
                for (i=0; i<c; i++) {
                    MOViewListLabelView *labelView = [[[self viewListLabelViewClass] allocWithZone:[self zone]] initWithViewListView:self andViewListViewItem:[_items objectAtIndex:i]];
                    [self addSubview:labelView];
                    [_labelViews addObject:labelView];
                    [labelView release];
                }
            } else {
                _items = [[NSMutableArray allocWithZone:[self zone]] init];
            }
            [self setControlSize:[coder decodeIntForKey:CONTROL_SIZE_KEY]];
            [self setBackgroundColor:[coder decodeObjectForKey:BACKGROUND_COLOR_KEY]];
            [self setLabelBarAppearance:[coder decodeIntForKey:LABEL_BAR_APPEARANCE_KEY]];  // 0 is default
            [self setDelegate:[coder decodeObjectForKey:DELEGATE_KEY]];
        } else {
            [NSException raise:NSGenericException format:@"MOViewListView does not support old-style non-keyed NSCoding."];
        }
    }
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (NSDragOperation)_MO_validateDragging:(id <NSDraggingInfo>)sender {
    if (_vlvFlags.delegateImplementsValidateDrop && _vlvFlags.delegateImplementsAcceptDrop) {
        NSPoint p = [self convertPoint:[sender draggingLocation] fromView:nil];
        unsigned i, c = [_labelViews count];
        for (i=0; i<c; i++) {
            id curLabel = [_labelViews objectAtIndex:i];
            NSRect curFrame = [curLabel frame];
            if (p.y <= NSMinY(curFrame)) {
                // The mouse is above the current label.
                _dropIndex = i;
                _dropOperation = MOViewListViewDropBeforeItem;
                break;
            } else if (p.y < NSMaxY(curFrame)) {
                // The mouse is on the current label.
                _dropIndex = i;
                _dropOperation = MOViewListViewDropOnItem;
                break;
            }
        }
        if (i==c) {
            // The mouse is below the last label.
            _dropIndex = i;
            _dropOperation = MOViewListViewDropBeforeItem;
        }
        _dragOperation = [[self delegate] viewListView:self validateDrop:sender proposedItemIndex:_dropIndex proposedDropOperation:_dropOperation];
    } else {
        _dragOperation = NSDragOperationNone;
    }
    [self setNeedsDisplay:YES];
    
    return _dragOperation;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return [self _MO_validateDragging:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    return [self _MO_validateDragging:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [self setNeedsDisplay:YES];
    _dragOperation = NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    BOOL result = [[self delegate] viewListView:self acceptDrop:sender itemIndex:_dropIndex dropOperation:_dropOperation];
    _dragOperation = NSDragOperationNone;
    [self setNeedsDisplay:YES];
    return result;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    return;
}

@end

@implementation _MO_MaskingView
// This view is used during animation to mask off the part of the animating subview that should not be visible.

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizesSubviews:NO];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
