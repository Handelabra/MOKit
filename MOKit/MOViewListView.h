// MOViewListView.h
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

// ABOUT MOViewListView
//
// Implements a stack of disclosable views similar to those seen in PB, in
// some Microsoft apps, in the Jaguar Finder's Info window, and in Okito Composer
// among others.  A stack view is generally intended to live in a
// scroll view with a vertical scroller.  Sizing behavior is interesting.  The
// width of the stack view determines the width of its subviews, but the combined
// height of the subviews and labels determines the height of the stack view.  Thus,
// subviews of a stack view are generally expected to be able to take on any width,
// but are free to be as tall as they need to be.  The stack view watches for changes
// in the frame of its subviews and will adapt itself as needed.

/*!
 @header MOViewListViewItem
 @discussion Defines the MOViewListViewItem class.
 */

#if !defined(__MOKIT_MOViewListView__)
#define __MOKIT_MOViewListView__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
@class MOViewListViewItem;

/*!
 @enum MOViewListViewLabelBarAppearance
 @abstract Constants for setting MOViewListView label bar appearance.
 @discussion MOViewListView provides an API for switching between several predefined label bar appearances.  These constants specify the available presets.
 @constant MOViewListViewDefaultLabelBars The default scheme, currently the same as MOViewListViewLightGrayLabelBars.
 @constant MOViewListViewDarkGrayLabelBars Dark gray label bars, white text, white disclosure controls with shadows.
 @constant MOViewListViewLightGrayLabelBars Light gray label bars, black text, dark gray disclosure controls with no shadow.
 @constant MOViewListViewProjectBuilderLabelBars Slightly corduroy light gray bars with a darker border, black text, drak gray disclosure controls with no shadow.
 @constant MOViewListViewFinderLabelBars No label bars (same as background) but a single black line above each label, black text, drak gray disclosure controls with no shadow.
 */
typedef enum {
    MOViewListViewDefaultLabelBars = 0,
    MOViewListViewDarkGrayLabelBars = 1,
    MOViewListViewLightGrayLabelBars = 2,
    MOViewListViewProjectBuilderLabelBars = 3,
    MOViewListViewFinderLabelBars = 4,
} MOViewListViewLabelBarAppearance;

/*!
    @typedef    MOViewListViewDropOperation
    @abstract   Enumeration for types of drop operations supported by MOViewListView.
    @discussion Enumeration for types of drop operations supported by MOViewListView.
    @constant   MOViewListViewDropOnItem Drop operation constant for dropping something "onto" a label.
    @constant   MOViewListViewDropBeforeItem Drop operation constant for dropping something "between" two views (ie dropping a new item/subview into a view list view).
*/
typedef enum { MOViewListViewDropOnItem, MOViewListViewDropBeforeItem } MOViewListViewDropOperation;

/*!
 @class MOViewListView
 @abstract A MOViewListView is a vertical list of views that can be individually collapsed or expanded.
 @discussion A MOViewListView has a list of "stacked views" that it keeps arranged in a vertical stack.  The appearance and behavior is similar to similar UI seen in PB, in some Microsoft apps, in the Jaguar Finder's Info window, and in Okito Composer among others.  A MOViewListView is generally intended to live in a scroll view with a vertical scroller.  Sizing behavior is interesting.  The width of the MOViewListView determines the width of its subviews, but the combined height of the subviews and labels determines the height of the MOViewListView.  Thus, subviews of a MOViewListView are generally expected to be able to take on any width, but are free to be a specific height and as tall as they need to be.  The MOViewListView watches for changes in the frame of its subviews and will adapt itself as needed if any of the views change height.

 MOViewListView uses instances of MOViewListViewItem to manage its subviews.  Each MOViewListViewItem has a view and a label (and some other incidental attributes.)  MOViewListViewItem is similar in function to NSTabViewItem.  In particular one interesting use of MOViewListViewItem is to allow the subviews of a MOViewListView to be loaded lazily only when needed.  MOViewListViewItems can be created with no view initially and added to the MOViewListView.  The MOViewListView's delegate can then implement -viewListView:willExpandViewListViewItem: to load the view if necessary and set it into the MOViewListViewItem.  That way as long as an item is collapsed and has never been expanded, its view will not be loaded.

 MOViewListView has a lot of configurability with respect to its appearance.  It implements the standard Cocoa -controlSize/-setControlSize: methods and adapts the appearance of its label bars accordingly.  All the colors used for drawing the view (its background and labels) are also configurable.  In addition, a convenience API is provided that sets all the colors to several preset schemes (some of which mimic the appearance of this type of view used in PB and Finder.)

 MOViewListView can animate when collapsing or expanding subviews.  There is specific API for expanding and collapsing that takes a flag to indicate whether to animate.  There is also API that does not take that flag and those APIs animate or not depending on a user preference.  The preference for animation is enabled by default.  +usesAnimation and +setUsesAnimation: can be used to query and control this preference.

 By default MOViewListView adapts to any changes that require relayout of its subviews immediately as changes are made.  There is API for disabling/enabling this.  If you plan to make a whole series of changes, you may want to disable relayout before you begin and re-enable it when you are done to prevent unnecessary work during the changes.
 */
@interface MOViewListView : NSView {
    @private
#if 0
    // PUBLIC IB OUTLET DECLARATIONS
    // When parsing the header, IB will see this outlet declaration.  The real instance variable is named with an underbar.  When loading a nib file with a connection to this outlet, Cocoa will call the setter method -setDelegate:.
    IBOutlet id delegate;
#else
    // ACTUAL INSTANCE VARIABLE DECLARATIONS FOR OUTLETS
    id _delegate;
#endif
    NSMutableArray *_items;
    NSMutableArray *_labelViews;
    int _firstViewNeedingLayout;
    unsigned _layoutDisabled;
    NSControlSize _controlSize;
    int _animationViewIndex;
    float _animationAmountRevealed;
    NSView *_animationMaskingView;
    NSColor *_backgroundColor;
    MOViewListViewLabelBarAppearance _labelBarAppearance;
    Class _viewListLabelViewClass;
    
    int _dropIndex;
    MOViewListViewDropOperation _dropOperation;
    NSDragOperation _dragOperation;

    struct {
        unsigned int doingLayout:1;
        unsigned int delegateImplementsShouldExpand:1;
        unsigned int delegateImplementsWillExpand:1;
        unsigned int delegateImplementsDidExpand:1;
        unsigned int delegateImplementsShouldCollapse:1;
        unsigned int delegateImplementsWillCollapse:1;
        unsigned int delegateImplementsDidCollapse:1;
        unsigned int delegateImplementsValidateDrop:1;
        unsigned int delegateImplementsAcceptDrop:1;
        unsigned int _reserved:23;
    } _vlvFlags;
    void *_MO_reserved[5];
}

/*!
 @method setUsesAnimation:
 @abstract Sets whether animation is used for collapsing and expanding.
 @discussion Sets whether animation is used for collapsing and expanding.  This does not apply to the API that takes a specific flag indicating whether to animate.  It applies to user-initiated collapsing or expanding and to use of the API with no specific animation flag.  The setting is stored in NSUserDefaults with the key MOViewListViewUsesAnimation.  The default setting is YES.
 @param flag Whether to animate.
 */
+ (void)setUsesAnimation:(BOOL)flag;

/*!
 @method setUsesAnimation:
 @abstract Returns whether animation is used for collapsing and expanding.
 @discussion Returns whether animation is used for collapsing and expanding.  This does not apply to the API that takes a specific flag indicating whether to animate.  It applies to user-initiated collapsing or expanding and to use of the API with no specific animation flag.  The setting is fetched from NSUserDefaults with the key MOViewListViewUsesAnimation.  The default setting is YES.
 @result Whether to animate.
 */
+ (BOOL)usesAnimation;

/*!
 @method initWithFrame:
 @abstract Initializes an instance.
 @discussion Designated Initializer.  Initializes the receiver with the given frame.  This method calls the MOViewSizing method MO_setTakesMinSizeFromClipView:YES to ensure it always fills its clip view.
 @param frame The frame rectangle for the view.
 @result The initialized instance.
 */
- (id)initWithFrame:(NSRect)frame;

/*!
 @method numberOfViewListViewItems
 @abstract Returns the number of MOViewListViewItems the receiver has.
 @discussion Returns the number of MOViewListViewItems the receiver has.  This is basically the number of labels/subviews (although not all the managed views are technically subviews at a given time).
 @result The number of items.
 */
- (int)numberOfViewListViewItems;

/*!
 @method viewListViewItems
 @abstract Returns the receiver's array of MOViewListViewItems.
 @discussion Returns the receiver's array of MOViewListViewItems.
 @result The array of items.
 */
- (NSArray *)viewListViewItems;

/*!
 @method viewListViewItemAtIndex:
 @abstract Returns the MOViewListViewItem at the given index.
 @discussion Returns the MOViewListViewItem at the given index.
 @param index The index.
 @result The item.
 */
- (MOViewListViewItem *)viewListViewItemAtIndex:(int)index;

/*!
 @method insertViewListViewItem:atIndex:
 @abstract Inserts a new MOViewListViewItem into the receiver.
 @discussion Inserts a new MOViewListViewItem into the receiver.  The new item is inserted at the given index and will initially be collapsed.  This method is the primitive for inserting a new item.  All other add/insert methods eventually call this one.  This method calls -setViewListView:self on the new item.
 @param item The new item.
 @param index The index.
 */
- (void)insertViewListViewItem:(MOViewListViewItem *)item atIndex:(int)index;

/*!
 @method removeViewListViewItemAtIndex:
 @abstract Removes a MOViewListViewItem from the receiver.
 @discussion Removes a MOViewListViewItem from the receiver.  The item at the given index is removed.  This method is the primitive for removed an item.  This method calls -setViewListView:nil on the new item.
 @param index The index.
 */
- (void)removeViewListViewItemAtIndex:(int)index;

/*!
 @method addViewListViewItem:
 @abstract Adds a new MOViewListViewItem into the receiver.
 @discussion Adds a new MOViewListViewItem into the receiver.  This simply calls [self insertViewListViewItem:item atIndex:[self numberOfViewListViewItems]].
 @param item The new item.
 */
- (void)addViewListViewItem:(MOViewListViewItem *)item;

/*!
 @method indexOfStackedView:
 @abstract Returns the index of the given view.
 @discussion Returns the index of the given view.  This looks through the receiver's items for one that has the given view and returns the index of the item.  If the view is not owned by any of the receiver's items, this returns -1.
 @param view The view.
 @result The index, or -1 if the given view is not managed by the receiver.
 */
- (int)indexOfStackedView:(NSView *)view;

/*!
 @method insertStackedView:atIndex:withLabel:
 @abstract Inserts the given view into the receiver.
 @discussion Inserts the given view into the receiver.  This simply creates a new item and calls [self insertViewListViewItem:newItem atIndex:index].  The new item is returned.
 @param view The view.
 @param index The index.
 @param label The label for the new view.
 @result The MOViewListViewItem that was created.
 */
- (MOViewListViewItem *)insertStackedView:(NSView *)view atIndex:(int)index withLabel:(NSString *)label;

/*!
 @method addStackedView:withLabel:
 @abstract Adds the given view into the receiver.
 @discussion Adds the given view into the receiver.  This simply calls [self insertStackedView:view atIndex:[self numberOfViewListViewItems] withLabel:label].  The new item is returned.
 @param view The view.
 @param label The label for the new view.
 @result The MOViewListViewItem that was created.
 */
- (MOViewListViewItem *)addStackedView:(NSView *)view withLabel:(NSString *)label;
    // Convenience methods that create a MOViewListViewItem for you.

/*!
 @method collapseStackedViewAtIndex:animate:
 @abstract Collapses the view at the given index.
 @discussion Collapses the view at the given index.  This is the primitive for collpasing.  The animateFlag indicates whether to animate the collpasing.
 @param index The index.
 @param animateFlag Whether to animate.
 */
- (void)collapseStackedViewAtIndex:(int)index animate:(BOOL)animateFlag;

/*!
 @method expandStackedViewAtIndex:animate:
 @abstract Expands the view at the given index.
 @discussion Expands the view at the given index.  This is the primitive for expanding.  The animateFlag indicates whether to animate the expanding.
 @param index The index.
 @param animateFlag Whether to animate.
 */
- (void)expandStackedViewAtIndex:(int)index animate:(BOOL)animateFlag;

/*!
 @method toggleStackedViewAtIndex:animate:
 @abstract Toggles the collapsed state of the view at the given index.
 @discussion Toggles the collapsed state of the view at the given index.  The animateFlag indicates whether to animate.
 @param index The index.
 @param animateFlag Whether to animate.
 */
- (void)toggleStackedViewAtIndex:(int)index animate:(BOOL)animateFlag;

/*!
 @method collapseStackedViewAtIndex:
 @abstract Collapses the view at the given index.
 @discussion Collapses the view at the given index.  This calls [self collapseStackedViewAtIndex:index animate:[[self class] usesAnimation]].
 @param index The index.
 */
- (void)collapseStackedViewAtIndex:(int)index;

/*!
 @method expandStackedViewAtIndex:
 @abstract Expands the view at the given index.
 @discussion Expands the view at the given index.  This calls [self expandStackedViewAtIndex:index animate:[[self class] usesAnimation]].
 @param index The index.
 */
- (void)expandStackedViewAtIndex:(int)index;

/*!
 @method toggleStackedViewAtIndex:
 @abstract Toggles the collapsed state of the view at the given index.
 @discussion Toggles the collapsed state of the view at the given index.  This calls [self toggleStackedViewAtIndex:index animate:[[self class] usesAnimation]].
 @param index The index.
 */
- (void)toggleStackedViewAtIndex:(int)index;

/*!
 @method setDelegate:
 @abstract Sets the receiver's delegate.
 @discussion Sets the receiver's delegate.
 @param delegate The delegate.
 */
- (void)setDelegate:(id)delegate;

/*!
 @method delegate
 @abstract Returns the receiver's delegate.
 @discussion Returns the receiver's delegate.
 @result The delegate.
 */
- (id)delegate;

/*!
 @method setControlSize:
 @abstract Sets the receiver's control size.
 @discussion Sets the receiver's control size.
 @param size The control size.
 */
- (void)setControlSize:(NSControlSize)size;

/*!
 @method controlSize
 @abstract Returns the receiver's control size.
 @discussion Returns the receiver's control size.
 @result The control size.
 */
- (NSControlSize)controlSize;

/*!
 @method labelFont
 @abstract Returns the receiver's label font.
 @discussion Returns the receiver's label font.  MOViewListView uses the system font.  The size is determined by the controlSize.
 @result The font.
 */
- (NSFont *)labelFont;

/*!
 @method labelHeight
 @abstract Returns the receiver's label height.
 @discussion Returns the receiver's label height.  MOViewListView calculates this from the labelFont.
 @result The height of label bars.
 */
- (float)labelHeight;

/*!
 @method labelBarAppearance
 @abstract Returns the receiver's label bar appearance.
 @discussion Returns the receiver's label bar appearance.
 @param scheme The appearance type constant.
 */
- (MOViewListViewLabelBarAppearance)labelBarAppearance;

/*!
 @method setLabelBarAppearance:
 @abstract Sets the receiver's label bar appearance.
 @discussion Sets the receiver's label bar appearance.
 @param scheme The appearance type constant.
 */
- (void)setLabelBarAppearance:(MOViewListViewLabelBarAppearance)labelBarAppearance;

/*!
    @method     viewListLabelViewClass
    @abstract   Returns the MOViewListLabelView subclass used for labels in this instance.
    @discussion Returns the MOViewListLabelView subclass used for labels in this instance.  By default this returns [MOViewListLabelView class], but you can use -setViewListLabelViewClass: to substitue a custom subclass.
    @result     The class.
*/
- (Class)viewListLabelViewClass;

/*!
    @method     setViewListLabelViewClass:
    @abstract   Sets the MOViewListLabelView subclass used for labels in this instance.
    @discussion Sets the MOViewListLabelView subclass used for labels in this instance.  By default MOViewListView uses MOViewListLabelViews to implement its labels, but this method can be used to supply a substitue class (which should be a subclass of MOViewListLabelView.)  Calling this method with a new class will replace all existing label views for the receiver with new instances of the new class.
    @param      theClass The class.
*/
- (void)setViewListLabelViewClass:(Class)theClass;

/*!
 @method backgroundColor
 @abstract Returns the receiver's background color.
 @discussion Returns the receiver's background color.  If the background color is nil, then no background is drawn.  If the background color is not nil and is opaque (has alpha 1.0), then the view is opaque, otherwise it is not.  The default background color is [NSColor controlColor].
 @result The background color.
 */
- (NSColor *)backgroundColor;

/*!
 @method setBackgroundColor:
 @abstract Sets the receiver's background color.
 @discussion Sets the receiver's background color.  If the background color is nil, then no background is drawn.  If the background color is not nil and is opaque (has alpha 1.0), then the view is opaque, otherwise it is not.
 @param color The background color.
 */
- (void)setBackgroundColor:(NSColor *)color;

/*!
 @method frameForLabelBarAtIndex:
 @abstract Returns the frame for an item's label bar.
 @discussion Returns the frame for the label bar of the item with the given index.
 @param index The index.
 @result The frame for an item's label bar.
 */
- (NSRect)frameForLabelBarAtIndex:(int)index;

/*!
 @method frameForDisclosureControlAtIndex:
 @abstract Returns the frame for an item's disclosure control.
 @discussion Returns the frame for the disclosure control of the item with the given index.
 @param index The index.
 @result The frame for an item's disclosure control.
 */
- (NSRect)frameForDisclosureControlAtIndex:(int)index;

/*!
 @method frameForLabelTextAtIndex:
 @abstract Returns the frame for an item's label text.
 @discussion Returns the frame for the label text of the item with the given index.  Note that this rect is the whole area of the bar available for the label text.  It goes all the way to the end of the bar regardless of the length of the actual label.
 @param index The index.
 @result The frame for an item's label text.
 */
- (NSRect)frameForLabelTextAtIndex:(int)index;

/*!
 @method disableLayout
 @abstract Disables relayout of the subviews.
 @discussion Disables relayout of the subviews.  This method can be used to turn off immediate relayout of subviews in response to changes made to the views or the receiver's settings.  Use -enableLayout to turn it back on (and to cause any needed relayout to be done).  Multiple calls to this must be balanced with the same number of calls to -enableLayout (in other words, calls to this API stack).
 */
- (void)disableLayout;

/*!
 @method enableLayout
 @abstract Enables relayout of the subviews.
 @discussion Enables relayout of the subviews.  This method can be used to turn back on immediate relayout of subviews in response to changes made to the views or the receiver's settings after a previous call to -disableLayout.  If any relayout is needed, then this method will cause it to happen.  Multiple calls to -disableLayout must be balanced with the same number of calls to -enableLayout (in other words, calls to this API stack).
 */
- (void)enableLayout;

/*!
 @method isLayoutDisabled
 @abstract Returns whether the receiver will pend any necessary layout.
 @discussion Returns whether the receiver will pend any necessary layout.  This basically returns whether -disableLayout has been called more times than -enableLayout.
 @result Whether the receiver will pend any necessary layout.
 */
- (BOOL)isLayoutDisabled;

/*!
 @method sizeToFit
 @abstract Does any needed layout and makes sure the receiver is the right size.
 @discussion Does any needed layout and makes sure the receiver is the right size.  If layout is disabled, this does nothing.  Otherwise this does any necessary resizing of height of the stack view to fit all the subviews and labels currently visible, and it resizes widths of and repositions subviews to fit in the stack view.  (ie height is calculated bottom-up, width is enforced top-down.)
 */
- (void)sizeToFit;

/*!
 @method invalidateLayoutStartingWithStackedViewAtIndex:
 @abstract Invalidates layout of subviews and recevier.
 @discussion Invalidates layout of subviews and recevier.  If layout is not disabled, the new layout will be calculated immediately (by calling -sizeToFit).  Otherwise, the new layout will be done once layout is re-enabled.  MOViewListView calls this itself whenever changes are made that affect the layout.  It should usually not be necessary to invoke this method directly.
 @param index The index.
 */
- (void)invalidateLayoutStartingWithStackedViewAtIndex:(int)index;

/*!
 @method setNeedsDisplayForLabelBarAtIndex:
 @abstract Invalidates the display of the label for the item at the given index.
 @discussion Invalidates the display of the label for the item at the given index.  MOViewListViewItem's -setLabel: calls this to make sure the new label will be shown.
 @param index The index.
 */
- (void)setNeedsDisplayForLabelBarAtIndex:(int)index;

/*!
    @method     shouldExpandViewListViewItem:
    @abstract   Consults the delegate to determine if the given item can expand.
    @discussion Consults the delegate to determine if the given item can expand.  MOViewListLabelView uses this method during mouse tracking to ask whether it is OK to expand.  MOViewListView returns the delegate's answer if the delegate implements viewListView:shouldExpandViewListViewItem:, otherwise it returns YES.
    @param      item The item that wants to expand.
    @result     Whether the item should be allowed to expand.
*/
- (BOOL)shouldExpandViewListViewItem:(MOViewListViewItem *)item;

/*!
    @method     shouldCollapseViewListViewItem:
    @abstract   Consults the delegate to determine if the given item can collapse.
    @discussion Consults the delegate to determine if the given item can collapse.  MOViewListLabelView uses this method during mouse tracking to ask whether it is OK to collapse.  MOViewListView returns the delegate's answer if the delegate implements viewListView:shouldCollapseViewListViewItem:, otherwise it returns YES.
    @param      item The item that wants to collapse.
    @result     Whether the item should be allowed to collapse.
*/
- (BOOL)shouldCollapseViewListViewItem:(MOViewListViewItem *)item;

/*!
    @method     dragImageForItem:event:dragImageOffset:
    @abstract   Returns the image to use for dragging a view list view item/subview.
    @discussion Returns the image to use for dragging a view list view item/subview.  MOViewListView will create a default image, but subclasses can override if they need to do something different.  This method will be called with dragImageOffset set to NSZeroPoint, but it can be modified to re-position the returned image.  A dragImageOffset of NSZeroPoint will cause the image to be centered under the mouse.
    @param      dragItem The MOViewListViewItem that will be dragged.
    @param      dragEvent The event that started the drag.
    @param      dragImageOffsetPtr A pointer to a point that can be filled in to provide an image offset.
    @result     The image to use for the drag.
*/
- (NSImage *)dragImageForItem:(MOViewListViewItem *)dragItem event:(NSEvent *)dragEvent dragImageOffset:(NSPointPointer)dragImageOffsetPtr;

/*!
    @method     setDropItemIndex:dropOperation:
    @abstract   Method to allow delegate to reposition a drop.
    @discussion Method to allow delegate to reposition a drop.  To be used from viewListView:validateDrop:proposedItemIndex:proposedDropOperation: if you wish to "re-target" the proposed drop.  To specify a drop on the second item, one would specify itemIndex=1, and op=MOViewListViewDropOnItem.  To specify a drop after the last item, one would specify row=[[viewListView viewListViewItems] count], and op=MOViewListViewDropBeforeItem.
    @param      itemIndex The item index.
    @param      op The drop operation.
*/
- (void)setDropItemIndex:(int)itemIndex dropOperation:(MOViewListViewDropOperation)op;

@end

/*!
 @category NSObject(MOViewListViewDelegate)
 @abstract Informal delegate protocol for MOViewListView.
 @discussion Informal delegate protocol for MOViewListView.  This category declares the methods that MOViewListView will send to its delegate if it implements them.
 */
@interface NSObject (MOViewListViewDelegate)

/*!
 @method viewListView:shouldExpandViewListViewItem:
 @abstract Control whether to allow expanding.
 @discussion This method is sent to the delegate if it implements it whenever the user initiates expanding one of the viewListView's stacked views.  If the delegate returns NO, the expanding is not allowed, otherwise it is.  This method is not sent when expanding is initiated by the programmer.
 @param viewListView The MOViewListView whose item is expanding.
 @param viewListViewItem The MOViewListViewItem that is expanding.
 @result NO if the delegate wants to disallow the expansion, otherwise YES.
 */
- (BOOL)viewListView:(MOViewListView *)viewListView shouldExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem;

/*!
 @method viewListView:willExpandViewListViewItem:
 @abstract Tells the delegate that an item will expand.
 @discussion This method is sent to the delegate if it implements it whenever a view is about to be expanded.  A common reason to implement this is to make sure the item's view is loaded and ready to be displayed.
 @param viewListView The MOViewListView whose item is expanding.
 @param viewListViewItem The MOViewListViewItem that is expanding.
 */
- (void)viewListView:(MOViewListView *)viewListView willExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem;

/*!
 @method viewListView:didExpandViewListViewItem:
 @abstract Tells the delegate that an item did expand.
 @discussion This method is sent to the delegate if it implements it whenever a view has been expanded.  This message is sent after the expanding but before the final relayout and display of the MOViewListView.
 @param viewListView The MOViewListView whose item has expanded.
 @param viewListViewItem The MOViewListViewItem that has expanded.
 */
- (void)viewListView:(MOViewListView *)viewListView didExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem;

/*!
 @method viewListView:shouldCollapseViewListViewItem:
 @abstract Control whether to allow collapsing.
 @discussion This method is sent to the delegate if it implements it whenever the user initiates collapsing one of the viewListView's stacked views.  If the delegate returns NO, the collapsing is not allowed, otherwise it is.
 @param viewListView The MOViewListView whose item is collapsing.  This method is not sent when collapsing is initiated by the programmer
 @param viewListViewItem The MOViewListViewItem that is collapsing.
 @result NO if the delegate wants to disallow the collapse, otherwise YES.
 */
- (BOOL)viewListView:(MOViewListView *)viewListView shouldCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem;

/*!
 @method viewListView:willCollapseViewListViewItem:
 @abstract Tells the delegate that an item will collapse.
 @discussion This method is sent to the delegate if it implements it whenever a view is about to be collapsed.
 @param viewListView The MOViewListView whose item is collapsing.
 @param viewListViewItem The MOViewListViewItem that is collapsing.
 */
- (void)viewListView:(MOViewListView *)viewListView willCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem;

/*!
 @method viewListView:didCollapseViewListViewItem:
 @abstract Tells the delegate that an item did collapse.
 @discussion This method is sent to the delegate if it implements it whenever a view has been collapsed.  This message is sent after the collapsing but before the final relayout and display of the MOViewListView.
 @param viewListView The MOViewListView whose item has collapsed.
 @param viewListViewItem The MOViewListViewItem that has collapsed.
 */
- (void)viewListView:(MOViewListView *)viewListView didCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem;

/*!
    @method     viewListView:writeItem:toPasteboard:
    @abstract   Writes the given view list view item to the pasteboard.
    @discussion Writes the given view list view item to the pasteboard.  This method is invoked by MOViewListView when the user starts to drag a label.  To refuse the drag, return NO.  To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  The drag image and other drag related information will be set up and provided by the view list view once this call returns with YES. 
    @param      viewListView The sender.
    @param      item The item for the label being dragged.
    @param      pboard The pasteboard to write to.
    @result     Whether the delegate wrote the item to the pasteboard.
*/
- (BOOL)viewListView:(MOViewListView *)viewListView writeItem:(MOViewListViewItem *)item toPasteboard:(NSPasteboard*)pboard;

/*!
    @method     viewListView:dragEndedAtPoint:withOperation:forItem:
    @abstract   Notification that a drag of a label item has concluded.
    @discussion Notification that a drag of a label item has concluded.  This method is called after a drag initiated by the view list view has ended.  dragOp indicates what the operation was and can be used to determine if the drag succeeded or not.
    @param      viewListView The sender.
    @param      aPoint The drop point in screen coordinates.
    @param      dragOp The drag operation (NSDragOperationNone if there was no successful drop).
    @param      item The item for the tab that was dragged.
*/
- (void)viewListView:(MOViewListView *)viewListView dragEndedAtPoint:(NSPoint )aPoint withOperation:(NSDragOperation)dragOp forItem:(MOViewListViewItem *)item;

/*!
    @method     viewListView:validateDrop:proposedItemIndex:proposedDropOperation:
    @abstract   Validates a proposed drop operation.
    @discussion Validates a proposed drop operation.  This method is used by MOViewListView to determine a valid drop target.  Based on the mouse position, the view list view will suggest a proposed drop location.  This method must return a value that indicates which dragging operation the delegate will perform.  The delegate may "re-target" a drop if desired by calling -setDropItemIndex:dropOperation: on the sender and then returning something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).  See the documentation for -setDropItemIndex:dropOperation: for more info on what the itemIndex and op mean.
    @param      viewListView The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The proposed drop index.
    @param      op The proposed drop operation.
    @result     The drag operation that would occur if the drop happened at the current point.
*/
- (NSDragOperation)viewListView:(MOViewListView *)viewListView validateDrop:(id <NSDraggingInfo>)info proposedItemIndex:(int)itemIndex proposedDropOperation:(MOViewListViewDropOperation)op;

/*!
    @method     viewListView:acceptDrop:itemIndex:dropOperation:
    @abstract   Performs the drop.
    @discussion Performs the drop.  This method is called when the mouse is released over a view list view that previously decided to allow a drop via the -viewListView:validateDrop:proposedItemIndex:proposedDropOperation: method.  The delegate should incorporate the data from the dragging pasteboard at this time.  The itemIndex and op will be whatever values were last passed to -setDropItemIndex:dropOperation: or, if the delegate never called that method, the last proposed index and op that were passed to the -viewListView:validateDrop:proposedItemIndex:proposedDropOperation: method.
    @param      viewListView The sender.
    @param      info The NSDraggingInfo for the in-progress drag operation.
    @param      itemIndex The drop index.
    @param      op The drop operation.
    @result     Whether the drop was completed successfully.
*/
- (BOOL)viewListView:(MOViewListView *)viewListView acceptDrop:(id <NSDraggingInfo>)info itemIndex:(int)itemIndex dropOperation:(MOViewListViewDropOperation)op;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOViewListView__

/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
