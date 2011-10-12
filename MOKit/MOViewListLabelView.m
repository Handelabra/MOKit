// MOViewListLabelView.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOViewListLabelView.h>
#import <MOKit/MOViewListView.h>
#import <MOKit/MOViewListViewItem.h>
#import <MOKit/MOAssertions.h>

static const float _DisclosureTrianglePad = 4.0;
static const float _RegularDisclosureTriangleDimension = 10.0;
static const float _SmallDisclosureTriangleDimension = 8.0;
static const float _LabelBarTextHeightPad = 2.0;

@implementation MOViewListLabelView

- (id)initWithViewListView:(MOViewListView *)viewListView andViewListViewItem:(MOViewListViewItem *)item {
    self = [super initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
    if (self) {
        _viewListView = viewListView;
        _item = item;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    NSLog(@"Use -initWithViewListView:andViewListViewItem:!");
    [self release];
    return nil;
}

- (MOViewListView *)viewListView {
    return _viewListView;
}

- (MOViewListViewItem *)viewListViewItem {
    return _item;
}

- (void)invalidate {
    _viewListView = nil;
    _item = nil;
}

+ (float)labelHeightForFont:(NSFont *)labelFont {
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    float height = [layoutManager defaultLineHeightForFont:labelFont];
    [layoutManager release];
    
    return height + (_LabelBarTextHeightPad * 2.0);
}

- (NSRect)frameForLabelText {
    MOAssert(_viewListView, @"Error. Attempt to use an invalidated MOViewListLabelView.");
    NSRect rect = [self bounds];
    float dim = (([_viewListView controlSize] == NSRegularControlSize) ? _RegularDisclosureTriangleDimension : _SmallDisclosureTriangleDimension);
    float extraSpace = _DisclosureTrianglePad + dim + _DisclosureTrianglePad;
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    float lineHeight = [layoutManager defaultLineHeightForFont:[_viewListView labelFont]];
    [layoutManager release];
    
    rect = NSMakeRect(NSMinX(rect) + extraSpace, NSMinY(rect) + ((NSHeight(rect) - lineHeight) / 2.0), NSWidth(rect) - extraSpace, lineHeight);
    return rect;
}

- (NSRect)frameForDisclosureControl {
    MOAssert(_viewListView, @"Error. Attempt to use an invalidated MOViewListLabelView.");
    NSRect rect = [self bounds];
    float dim = (([_viewListView controlSize] == NSRegularControlSize) ? _RegularDisclosureTriangleDimension : _SmallDisclosureTriangleDimension);
    rect = NSMakeRect(NSMinX(rect) + _DisclosureTrianglePad, NSMinY(rect) + ((NSHeight(rect) - dim) / 2.0) + 1.0, dim, dim);
    return rect;
}

/// Drawing

static void _drawUpperLeftTrianglePath(float dimension, BOOL right) {
    NSBezierPath *path = [[NSBezierPath allocWithZone:NULL] init];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    if (right) {
        [path moveToPoint:NSMakePoint(0.0, 1.0)];
        [path lineToPoint:NSMakePoint(0.0, dimension)];
        [path lineToPoint:NSMakePoint(dimension-1.0, ((dimension-1.0) / 2.0) + 1.0)];
    } else {
        [path moveToPoint:NSMakePoint(0.0, dimension)];
        [path lineToPoint:NSMakePoint(dimension-1.0, dimension)];
        [path lineToPoint:NSMakePoint((dimension-1.0) / 2.0, 1.0)];
    }
    [path closePath];
    [path fill];
    [path release];
}

static void _drawLowerRightTrianglePath(float dimension, BOOL right) {
    NSBezierPath *path = [[NSBezierPath allocWithZone:NULL] init];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    if (right) {
        [path moveToPoint:NSMakePoint(1.0, 0.0)];
        [path lineToPoint:NSMakePoint(1.0, dimension-1.0)];
        [path lineToPoint:NSMakePoint(dimension, (dimension-1.0) / 2.0)];
    } else {
        [path moveToPoint:NSMakePoint(1.0, dimension-1.0)];
        [path lineToPoint:NSMakePoint(dimension, dimension-1.0)];
        [path lineToPoint:NSMakePoint(((dimension-1.0) / 2.0) + 1.0, 0.0)];
    }
    [path closePath];
    [path fill];
    [path release];
}

static NSImage *_makeRetainedTriangleImage(float dimension, BOOL right, BOOL shadow, NSColor *color, NSColor *shadowColor) {
    NSImage *image = [[NSImage allocWithZone:NULL] initWithSize:NSMakeSize(dimension, dimension)];
    if (![image isValid]) {
        NSLog(@"Failed to lock focus on new image to draw!");
    } else {
        [image lockFocus];
        [[NSColor clearColor] set];
        NSRectFill(NSMakeRect(0.0, 0.0, dimension, dimension));

        if (shadow) {
            // Draw the shadow first, then the real triangle
            if (shadowColor) {
                [shadowColor set];
                _drawLowerRightTrianglePath(dimension, right);
            }
            [color set];
            _drawUpperLeftTrianglePath(dimension, right);
        } else {
            // Draw the real triangle (in "pressed" position)
            [color set];
            _drawLowerRightTrianglePath(dimension, right);
        }
        [image unlockFocus];
    }
    return image;
}

typedef struct _MO__TriangleImages {
    NSImage *collapsedTriangle;
    NSImage *expandedTriangle;
    NSImage *highlightedCollapsedTriangle;
    NSImage *highlightedExpandedTriangle;
} _MO_TriangleImages;

#define NUM_APPEARANCES 5

// Cache for images for each appearance, and for each control size
static _MO_TriangleImages _imageCache[NUM_APPEARANCES*2] = {
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil},
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}
};

static unsigned _imageCacheIndexForAppearanceAndSize(MOViewListViewLabelBarAppearance appearance, NSControlSize controlSize) {
    if (controlSize == NSRegularControlSize) {
        return appearance;
    } else {
        return appearance + NUM_APPEARANCES;
    }
}

- (NSColor *)_MO_disclosureControlColorForAppearance:(MOViewListViewLabelBarAppearance)appearance {
    switch (appearance) {
        case MOViewListViewDarkGrayLabelBars:
            return [NSColor whiteColor];
        case MOViewListViewProjectBuilderLabelBars:
            return [NSColor colorWithCalibratedWhite:0.45 alpha:1.0];
        case MOViewListViewFinderLabelBars:
            return [NSColor colorWithCalibratedWhite:0.45 alpha:1.0];
        case MOViewListViewLightGrayLabelBars:
        default:
            return [NSColor colorWithCalibratedWhite:0.31 alpha:1.0];
    }
}

- (NSColor *)_MO_disclosureControlShadowColorForAppearance:(MOViewListViewLabelBarAppearance)appearance {
    switch (appearance) {
        case MOViewListViewDarkGrayLabelBars:
            return [NSColor blackColor];
        case MOViewListViewProjectBuilderLabelBars:
            return nil;
        case MOViewListViewFinderLabelBars:
            return nil;
        case MOViewListViewLightGrayLabelBars:
        default:
            return nil;
    }
}

- (NSImage *)_MO_collapsedDisclosureTriangle:(BOOL)highlighted {
    MOViewListViewLabelBarAppearance appearance = [_viewListView labelBarAppearance];
    NSControlSize controlSize = [_viewListView controlSize];
    unsigned cacheIndex = _imageCacheIndexForAppearanceAndSize(appearance, controlSize);
    
    if (highlighted) {
        if (!_imageCache[cacheIndex].highlightedCollapsedTriangle) {
            _imageCache[cacheIndex].highlightedCollapsedTriangle = _makeRetainedTriangleImage(((controlSize == NSRegularControlSize) ? _RegularDisclosureTriangleDimension : _SmallDisclosureTriangleDimension), YES, NO, [self _MO_disclosureControlColorForAppearance:appearance], nil);
        }
        return _imageCache[cacheIndex].highlightedCollapsedTriangle;
    } else {
        if (!_imageCache[cacheIndex].collapsedTriangle) {
            _imageCache[cacheIndex].collapsedTriangle = _makeRetainedTriangleImage(((controlSize == NSRegularControlSize) ? _RegularDisclosureTriangleDimension : _SmallDisclosureTriangleDimension), YES, YES, [self _MO_disclosureControlColorForAppearance:appearance], [self _MO_disclosureControlShadowColorForAppearance:appearance]);
        }
        return _imageCache[cacheIndex].collapsedTriangle;
    }
}

- (NSImage *)_MO_expandedDisclosureTriangle:(BOOL)highlighted {
    MOViewListViewLabelBarAppearance appearance = [_viewListView labelBarAppearance];
    NSControlSize controlSize = [_viewListView controlSize];
    unsigned cacheIndex = _imageCacheIndexForAppearanceAndSize(appearance, controlSize);

    if (highlighted) {
        if (!_imageCache[cacheIndex].highlightedExpandedTriangle) {
            _imageCache[cacheIndex].highlightedExpandedTriangle = _makeRetainedTriangleImage(((controlSize == NSRegularControlSize) ? _RegularDisclosureTriangleDimension : _SmallDisclosureTriangleDimension), NO, NO, [self _MO_disclosureControlColorForAppearance:appearance], nil);
        }
        return _imageCache[cacheIndex].highlightedExpandedTriangle;
    } else {
        if (!_imageCache[cacheIndex].expandedTriangle) {
            _imageCache[cacheIndex].expandedTriangle = _makeRetainedTriangleImage(((controlSize == NSRegularControlSize) ? _RegularDisclosureTriangleDimension : _SmallDisclosureTriangleDimension), NO, YES, [self _MO_disclosureControlColorForAppearance:appearance], [self _MO_disclosureControlShadowColorForAppearance:appearance]);
        }
        return _imageCache[cacheIndex].expandedTriangle;
    }
}

- (NSColor *)_MO_labelTextColorForAppearance:(MOViewListViewLabelBarAppearance)appearance {
    switch (appearance) {
        case MOViewListViewDarkGrayLabelBars:
            return [NSColor whiteColor];
        case MOViewListViewProjectBuilderLabelBars:
            return [NSColor blackColor];
        case MOViewListViewFinderLabelBars:
            return [NSColor blackColor];
        case MOViewListViewLightGrayLabelBars:
        default:
            return [NSColor blackColor];
    }
}

- (NSTextFieldCell *)_MO_labelTextFieldCell {
    static NSTextFieldCell *_cell = nil;
    if (!_cell) {
        _cell = [[NSTextFieldCell allocWithZone:[self zone]] initTextCell:@""];
        [_cell setBordered:NO];
        [_cell setBezeled:NO];
    }
    [_cell setTextColor:[self _MO_labelTextColorForAppearance:[_viewListView labelBarAppearance]]];
    [_cell setFont:[_viewListView labelFont]];
    return _cell;
}

- (void)_MO_drawFinderLabelBarBackground {
    // With this style, the label bars have a line above them that extends to the edges of the view (no inset)
    NSRect bounds = [self bounds];
    [[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] set];
    NSRectFillUsingOperation(NSMakeRect(NSMinX(bounds), NSMinY(bounds), NSWidth(bounds), 1.0), NSCompositeSourceOver);
}

- (void)_MO_drawSimpleLabelBarBackgroundWithBarColor:(NSColor *)barColor borderColor:(NSColor *)borderColor {
    // With this style the label bar is a solid color, optionally with a one-pixel border around it of a separate color
    NSRect bounds = [self bounds];
    if (borderColor) {
        if (barColor) {
            [barColor set];
            NSRectFillUsingOperation(NSInsetRect(bounds, 1.0, 1.0), NSCompositeSourceOver);
        }
        [borderColor set];
        NSFrameRectWithWidthUsingOperation(bounds, 1.0, NSCompositeSourceOver);
    } else {
        if (barColor) {
            [barColor set];
            NSRectFillUsingOperation(bounds, NSCompositeSourceOver);
        }
    }
}

- (void)drawLabelBarBackground {
    MOAssert(_viewListView, @"Error. Attempt to use an invalidated MOViewListLabelView.");
    // The bar
    switch ([_viewListView labelBarAppearance]) {
        case MOViewListViewDarkGrayLabelBars:
            [self _MO_drawSimpleLabelBarBackgroundWithBarColor:[NSColor colorWithCalibratedWhite:0.42 alpha:1.0] borderColor:nil];
            break;
        case MOViewListViewProjectBuilderLabelBars:
            [self _MO_drawSimpleLabelBarBackgroundWithBarColor:[NSColor colorWithCalibratedWhite:0.68 alpha:0.55] borderColor:[NSColor colorWithCalibratedWhite:0.68 alpha:.84]];
            break;
        case MOViewListViewFinderLabelBars:
            [self _MO_drawFinderLabelBarBackground];
            break;
        case MOViewListViewLightGrayLabelBars:
        default:
            [self _MO_drawSimpleLabelBarBackgroundWithBarColor:[NSColor colorWithCalibratedWhite:0.67 alpha:1.0] borderColor:nil];
            break;
    }
}

- (void)drawRect:(NSRect)rect {
    MOAssert(_viewListView, @"Error. Attempt to use an invalidated MOViewListLabelView.");
    [self drawLabelBarBackground];

    // The triangle
    NSRect tempRect = [self frameForDisclosureControl];
    BOOL drawHighlighted = (_vllvFlags.trackingInDisclosureTriangle ? YES : NO);
    NSImage *triangleImage = ([_item isCollapsed] ? [self _MO_collapsedDisclosureTriangle:drawHighlighted] : [self _MO_expandedDisclosureTriangle:drawHighlighted]);
    [triangleImage compositeToPoint:NSMakePoint(NSMinX(tempRect), NSMaxY(tempRect)) operation:NSCompositeSourceOver];

    // The label
    NSString *label = [_item label];
    if (label && ![label isEqualToString:@""]) {
        NSTextFieldCell *labelCell = [self _MO_labelTextFieldCell];
        [labelCell setStringValue:label];
        tempRect = [self frameForLabelText];
        [labelCell drawWithFrame:tempRect inView:self];
    }
}

- (BOOL)isFlipped {
    return YES;
}

/// Mouse tracking

// ---:mferris:20030528 To avoid burning 8 bytes of ivar space, we assume that there can only be one label tracking the mouse at any time and use a static to remember the initial mouse position.
static NSPoint _dragAnchorPoint;

static float _distance(NSPoint p1, NSPoint p2) {
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    return sqrt((dx*dx) + (dy*dy));
}

- (void)mouseDown:(NSEvent *)event {
    MOAssert(_viewListView, @"Error. Attempt to use an invalidated MOViewListLabelView.");
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // Check whether the click is in a disclosure triangle
    NSRect triangleRect = [self frameForDisclosureControl];
    if ([self mouse:p inRect:[self frameForDisclosureControl]]) {
        if ([_item isCollapsed]) {
            if (![_viewListView shouldExpandViewListViewItem:_item]) {
                // Veto, do not do anything.
                return;
            }
        } else {
            if (![_viewListView shouldCollapseViewListViewItem:_item]) {
                // Veto, do not do anything.
                return;
            }
        }
        _vllvFlags.isTrackingDisclosureTriangle = YES;
        _vllvFlags.trackingInDisclosureTriangle = YES;
        [self setNeedsDisplayInRect:triangleRect];
    } else {
        // Could be a drag.
        if ([[[self viewListView] delegate] respondsToSelector:@selector(viewListView:writeItem:toPasteboard:)]) {
            _vllvFlags.couldBeADrag = YES;
            _dragAnchorPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        }
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (_vllvFlags.isTrackingDisclosureTriangle) {
        NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
        NSRect triangleRect = [self frameForDisclosureControl];
        if ([self mouse:p inRect:triangleRect] != _vllvFlags.trackingInDisclosureTriangle) {
            _vllvFlags.trackingInDisclosureTriangle = !_vllvFlags.trackingInDisclosureTriangle;
            [self setNeedsDisplayInRect:triangleRect];
        }
    } else if (_vllvFlags.couldBeADrag) {
        NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
        if (_distance(p, _dragAnchorPoint) > 4.0) {
            // Mouse moved far enough to be a drag.
            NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
            MOViewListView *vlv = [self viewListView];
            MOViewListViewItem *vlvi = [self viewListViewItem];
            if ([[vlv delegate] viewListView:vlv writeItem:vlvi toPasteboard:pboard]) {
                NSPoint dragImageOffset = NSZeroPoint;
                NSImage *image = [vlv dragImageForItem:vlvi event:event dragImageOffset:&dragImageOffset];
                // !!!:mferris:20030415  Offset stuff not working...
                [self dragImage:image at:p offset:NSMakeSize(p.x - _dragAnchorPoint.x - dragImageOffset.x, p.y - _dragAnchorPoint.y - dragImageOffset.y) event:event pasteboard:pboard source:self slideBack:YES];
            }
        }
    }
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation {
    MOViewListView *vlv = [self viewListView];
    if ([[vlv delegate] respondsToSelector:@selector(viewListView:dragEndedAtPoint:withOperation:forItem:)]) {
        [[vlv delegate] viewListView:vlv dragEndedAtPoint:aPoint withOperation:operation forItem:[self viewListViewItem]];
    }
}

- (void)mouseUp:(NSEvent *)event {
    if (_vllvFlags.isTrackingDisclosureTriangle) {
        // Let mouseDragged: logic update the state one final time.
        [self mouseDragged:event];

        BOOL doIt = _vllvFlags.trackingInDisclosureTriangle;
        [self setNeedsDisplayInRect:[self frameForDisclosureControl]];
        _vllvFlags.isTrackingDisclosureTriangle = NO;
        _vllvFlags.trackingInDisclosureTriangle = NO;

        if (doIt) {
            // Mouse went up inside the tracking rect, toggle.
            [_viewListView toggleStackedViewAtIndex:[[_viewListView viewListViewItems] indexOfObjectIdenticalTo:_item]];
        }
    }
    _vllvFlags.couldBeADrag = NO;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
