// MOViewController.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOViewController
 @discussion Defines the MOViewController class.
 */

// !!!:mferris:20030117 This code is still incomplete and largely untested (except for what is exercised in the still evolving VCTest target.)  See the project todo list for some of the major incomplete areas of the class.

#if !defined(__MOKIT_MOViewController__)
#define __MOKIT_MOViewController__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    

/*!
    @protocol MOViewControllerClassLoader
    @abstract   Protocol defining API for MOViewController to request unknown controller classes to be loaded.
    @discussion Protocol defining API for MOViewController to request unknown controller classes to be loaded.  See the documentation for MOViewController's +setViewControllerClassLoader: for more information.
*/
@protocol MOViewControllerClassLoader

/*!
    @method     viewControllerClassFromString:
    @abstract   Callback method that MOViewController's +viewControllerWithStateDictionary:ignoringContentState: will call when it encounters a class name in a state dictionary.
    @discussion Callback method that MOViewController's +viewControllerWithStateDictionary:ignoringContentState: will call when it encounters a class name in a state dictionary.  See the documentation for MOViewController's +setViewControllerClassLoader: for more information.
    @param      className The name of the class that needs to be loaded.
    @result     The class object.
*/
- (Class)viewControllerClassFromString:(NSString *)className;

/*!
    @method     stringFromViewControllerClass:
    @abstract   Callback method that MOViewController's -stateDictionaryIgnoringContentState: will call to get a name to archive for a given controller class.
    @discussion Callback method that MOViewController's -stateDictionaryIgnoringContentState: will call to get a name to archive for a given controller class.  See the documentation for MOViewController's +setViewControllerClassLoader: for more information.
    @param      theClass The class that is being written to a state dictionary.
    @result     The name to write to the state dictionary.
*/
- (NSString *)stringFromViewControllerClass:(Class)theClass;

@end


/*!
 @class MOViewController
 @abstract Base class for a controller that manages a hunk of view hierarchy.
 @discussion 
 
    <h3> Introduction </h3>

    Generally a ViewController is a controller class, in the MVC sense, that owns, and is responsible for controlling, a self-contained hunk of interface functionality.  MOViewController is an abstract base class which implements the basic functionality and which is subclassed to form specific kinds of ViewControllers.  MOViewController is a subclass of NSWindowController, but instead of owning a whole window, it owns a chunk of view hierarchy.  Some subclasses will be domain-generic, some will be domain-specific.
    
    Examples of domain-generic ViewControllers would include: MOSplitViewController, MOTabViewController, MOViewListViewController.  Usually, as is evident from the examples, generic ViewControllers manage some sort of container view.
    
    MOViewControllers have a number of primary properties:
    <ul>
    <li> They create and own blobs of interface </li>
    <li> They nest to form a hierarchy </li>
    <li> They participate in the responder chain and are therefore eligible to handle events and action messages </li>
    </ul>
    
    MOViewController is a base class for a controller that manages a view.  It inherits nib loading and managing from NSWindowController, but instead of owning and controlling a whole window, a MOViewController owns and controls a hunk of view hierarchy.  
 
    <h3> A MOViewController creates/loads its interface </h3>
    
    MOViewControllers are responsible for creating or loading their interfaces at runtime (and destroying them when they deallocate).  It is possible to instantiate any number of the same type of MOViewController and thus each instance must create or load a new copy of its view.
    
    MOViewController usually loads its interface from a nib file that contains (at least) a top-level "disembodied" (i.e. window-less) NSView.  The base MOViewController class provides general facilities for locating and loading the nib file associated with a MOViewController subclass (by default a MOViewController subclass looks for a nib file with the same name as the class).  When a MOViewController loads its interface from a nib the MOViewController itself is the "File's Owner" of the nib and therefore may have outlet and action connections established during nib loading to and from the interface elements being loaded.  Some subclasses of MOViewController may choose to simply create their interfaces programmatically, often because they are so simple (e.g. a MOSplitViewController really only needs to alloc/init an NSSplitView).
    
    MOViewControllers are lazy.  They create or load their interfaces only when they are first actually needed (which should usually be right before they are about to actually be shown on the screen for the first time).  Subclasses should take care to maintain this laziness and should avoid asking a child MOViewController for its view until it is really needed.  This is especially true for the generic "container"-style subclasses that can break the laziness for almost everything.  For example, MOTabViewController takes care not to ask for the views of its children that are not the active tab until the user actually selects the tab and the view needs to be shown.

    <h3> The difference between contentView and view </h3>
    
    MOViewController has methods -contentView and -view.  These are different views.  The -contentView is the view that is connected to the "contentView" outlet in your nib file or the view that you create programmatically and set using -setContentView:.
    
    The -view is a special view that MOViewController creates.  Once the -contentView is loaded, this special view is created and the -contentView is made a subview of it.  Here are some guidelines on which one to use in different circumstances.
    
    In your -viewDidLoad, you generally will want to talk to the -contentView.  Remember that the -contentView is the one that you created (in the nib file or programmatically) and if you need to do further configuration on it, you access it through the -contentView method.
    
    A parent controller should use the -view of its children.  In particular, when a prent controller is going to install one of its child controllers.  It should install the -view of its child.
    
    If you need to programmatically change the autosizing behavior of a controller's view, you should talk to its -view.  When the -contentView is first loaded, and the -view is created, the -view is given the same autosizing settings as the -contentView, by default.  But if they need to change after that you must change the settings directly on the -view.
    
    The reason that MOViewController has these two different views is to support minimum and maximum siuzes for controllers' views.  You can use the -setMinContentSize: and -setMaxContentSize: API to set miminum and maximum sizes for your controller's -contentView.  MOViewController uses its special -view to make sure that the minimum and maximum sizes get respected without confusing whatever view your controllers' view may be installed in.  The special view of a controller does this by letting the -contentView inside it start to crop if the -view is made smaller than the minimum size and letting the -contentView be smaller than the -view if the -view is made larger than the maximum size.  This provides a safe "backstop" behavior which prevents cases which could cause the interface to get into sizing states that it could not get back out of again.
    
    <h3> The ViewController hierarchy </h3>
    
    MOViewControllers are typically aggregated together into a hierarchy.  Each MOViewController can have any number of child MOViewControllers.  The hierarchy of MOViewControllers implies/requires an analogous (intended) hierarchy of the views that the ViewControllers own.  The parent MOViewController is responsible for installing and uninstalling the views of its child MOViewControllers somewhere in its own view hierarchy.
    
    Note that there is not one MOViewController per view.  ViewControllers almost always have a coarser granularity than views.  Consider the following window:
    
    <img src="../../../../DocumentationResources/MOViewController_example1.tiff">

    There might be three MOViewControllers here:  a ParentViewController that owns the content view of the whole window, and two instances of ChildViewController that own the content view of each box.  The ParentViewController really owns a view with two boxes in it.  The ChildViewController really owns a view with a scroll view and a button inside of it.  (And the scroll view contains a clip view, scroller, and header view.  And the clip view contains a table view.)  The ParentViewController either creates the ChildViewControllers itself (if they are always the same) or it might be given them through API it presents (-setSlot1Controller:/-setSlot2Controller: for instance).  Once the ParentViewController has its ChildViewControllers for each slot, it asks them for their views and installs the views inside the boxes that are inside the view it owns.
    
    As the above example shows, the parent MOViewController need not install the view of a child MOViewController directly in the view that it owns.  It might be installed into one of its subviews.  In fact, while a MOViewController technically owns a single view, it should be thought of as owning the entire view hierarchy under its view (up to but not including the views owned by any child ViewControllers).

    <h4> Combined ViewController and view hierarchy </h4>

    It is useful to think about ViewControllers and views as forming a combined hierarchy (although there need not be a representation of that combined hierarchy in the program).  This combined hierarchy is formed by taking the view hierarchy and inserting each ViewController into it in between the view that ViewController owns and that view's superview.  In the above example, the combined hierarchy (using Cocoa widget structure) looks like this:

    <ul>
    <li> <strong>ParentViewController</strong>
        <ul>
        <li> Window's contentView
            <ul>
            <li> NSBox (Slot 1)
                <ul>
                <li> <strong>ChildViewController (1)</strong>
                    <ul>
                    <li> box's contentView
                        <ul>
                        <li> NSScrollView
                            <ul>
                            <li> NSClipView
                                <ul>
                                <li> NSTableView </li>
                                </ul>
                            </li>
                            <li> NSScroller (vert) </li>
                            <li> NSScroller (horiz) </li>
                            <li> NSTableHeaderView </li>
                            <li> NSTableCornerView </li>
                            </ul>
                        </li>
                        <li> NSButton </li>
                        </ul>
                    </li>
                    </ul>
                </li>
                </ul>
            </li>
            <li> NSBox (Slot 2)
                <ul>
                <li> <strong>ChildViewController (2)</strong>
                    <ul>
                    <li> box's contentView
                        <ul>
                        <li> NSScrollView
                            <ul>
                            <li> NSClipView
                                <ul>
                                <li> NSTableView </li>
                                </ul>
                            </li>
                            <li> NSScroller (vert) </li>
                            <li> NSScroller (horiz) </li>
                            <li> NSTableHeaderView </li>
                            <li> NSTableCornerView </li>
                            </ul>
                        </li>
                        <li> NSButton </li>
                        </ul>
                    </li>
                    </ul>
                </li>
                </ul>
            </li>
            </ul>
        </li>
        </ul>
    </li>
    </ul>

    This is more detail than most folks would care about (especially the innards of the scroll views), but it is provided to make it clear that a ViewController can own an entire view hierarchy, not just a single view.
    
    With this combined hierarchy it is easier to see the ownership details.  The two ChildViewControllers own every view that is nested under them in this example since they themselves have no child MOViewControllers.  The ParentViewController owns the views nested under it except that the (view) ownership stops when a new ViewController occurs.  So, in this example, the ParentViewController owns the window content view and the two NSBoxes.
    
    This combined hierarchy is actually present at runtime in the form of the responder chain.  Like an NSWindowController is the nextResponder of its window, a MOViewController is the nextResponder of its view when that view is installed in a view hierarchy (and the controllers own nextResponder is the view's superview).  In other words, a MOViewController inserts itself into the responder chain in between its own view and the superview of its view.  This allows it to receive focus-dispatched (nil-target) action messages and even to be in line for event handling (although the uses for a MOViewController directly implementing event-handling methods are rare).

    <h4> Knowing about child and parent ViewControllers </h4>

    A MOViewController knows in the abstract sense that it may have a parent and children.  
    
    A specific MOViewController subclass may or may not know specific details about its children (such as how many there will be and of what specific subclass(es) of MOViewController they are).
    
    A MOViewController subclass, however, should never make assumptions about its parent.
    
    It can sometimes be necessary for a MOViewController to know about other specific MOViewControllers (for the purposes of setting up relationships between what is shown in one and what is shown in the other, for example), but these relationships should be separated from the MOViewController hierarchy.  In other words a FooViewController may need to know about some associated BarViewController, but it should not accomplish this by assuming its parent ViewController is the BarViewController (or its parent's second child, etc...).  It should have other API or mechanism for finding its associated BarViewController.  Such relationships can often be accomplished through notification protocols, or, sometimes, a more direct knowledge is necessary.  But in any case, the relative path through the ViewController hierarchy is not the right way to set up such relationships.

    <h4> Installing and uninstalling a ViewController's view is dynamic </h4>

    "Installing" and "uninstalling" refer to putting a MOViewController's view into a view hierarchy or taking it back out again.  The example above shows a situation where the views of all the child MOViewControllers are always installed.  This is sometimes the case in real MOViewControllers, but not always.
    
    A MOSplitViewController manages a variable number of child MOViewControllers.  Each child MOViewController represents one split of the NSSplitView and the views of all the child MOViewControllers are always installed.
    
    On the other hand, a MOTabViewController also manages a variable number of child MOViewControllers.  Each child MOViewController represents one tab in the NSTabView, and at any given time only the child for the currently selected tab is installed.  In effect the MOTabViewController swaps one child at a time into a single area of its UI.
    
    <h4> ViewController Hierarchy is Dynamic </h4>
    
    The hierarchy of MOViewControllers can change at runtime.  This is where a lot of the potential for user-driven interface configurability comes from.  For example MOTabViewController might be implemented to support dragging an individual tab out into a separate floating window or into some other MOTabViewController.  Doing this would result in runtime rearrangement of the actual MOViewController hierarchy.
    
    There are many implications to such "tear-off" functionality that are not discussed in this document and are ultimately a matter of higher level policy, but the dynamic nature of the MOViewController hierarchy provides the basis for being able to support such features.

    <h3> ViewController and Focus-dispatched actions </h3>
    
    User interface initiated commands and actions typically come in two varieties.
    
    Some actions are always performed by the same receiver.  In the example above, the two buttons labeled "Remove Row" are examples.  Each one is wired directly into the ChildViewController that owns it and each one acts on the table within the same ChildViewController.  This type of action is not ambiguous and ViewController need not provide any mechanism or policy at all (except inasmuch as it may be the explicit target of the action).
    
    However, other actions are dispatched based on the current focus within the application.  Menu and toolbar items often cause this type of action and the Cut/Copy/Paste commands are canonical examples.  There is one Copy menu item, but there are any number of things that a user might want to copy.  What gets copied typically depends on what UI element in the active window has "focus".  Typically, this same "focus" concept is used to determine who gets typing events.  There's a dynamic chain of objects, the responder chain, starting at the UI control that currently has the "focus" that are all able to get a crack at handling such actions and the first one in the chain who can handle an action is the one that gets it.  The responder chain is formed by -nextResponder links.  Normally a view's -nextResponder is its superview, the -nextResponder of the content view of a window is the window, and the window's -nextResponder is its NSWindowController (if it has one).
    
    When using MOViewControllers, the controllers are in this chain.  A MOViewController subclass should be able to implement methods to handle actions and have those methods called when some view within its owned view hierarchy has focus (and the view(s) themselves do not handle the action directly).  In order to allow a MOViewController to insert itself into the responder chain, a parent MOViewController is responsible for informing its child MOViewController whenever it has installed that child's view or is about to uninstall the child's view and the base MOViewController class handles managing the changes to the responder chain that need to be done as it is installed and uninstalled.  When a MOViewController's view is installed, the controller inserts itself into the responder chain in between its view and the superview in which its view was installed.  When a MOViewController's view is about to be uninstalled, it removes itself from the responder chain and restores the original chain (ie makes its view's next responder by its view's superview).

    <h3> Top-level ViewControllers and owned windows </h3>
    
    A MOViewController that has no parent MOViewController can be asked to live in its own window.  If this happens, the MOViewController will own a window that it lives in and will manage that window.  The MOViewController's view will be the -contentView of the window.  Whether a MOViewController lives in its own window can change over time.  A MOViewController might live in a MOViewController hierarchy for a while and then be removed from the hierarchy (torn off) and put into its own window, then later be put back into a hierarchy, discarding the window.
    
    As an extension of the rule that a MOViewController should not assume specifics about its parent MOViewController, it is usually not a good idea for a MOViewController to decide for itself to live in a separate window.  Rather, this should be left up to the object that created the MOViewController or to a higher level mechanism.

    <h3> Other MOViewController services </h3>
    
    The MOViewController base class defines a number of other services that can be assumed to be common among all MOViewControllers.
    
    <h4> Labels and icons </h4>
    
    Each ViewController can have a label and an icon.  These can be the same for all instances of a subclass or they can be per-instance.  They can change over time.  Special support is provided for when the label/icon are a file system path and file icon.  A parent ViewController can access its children's labels and icons.  For example, a MOTabViewController uses the labels of its subcontrollers as the actual tab labels.  A MOViewController that owns its own window uses its label and icon for the window's title.  Label changes cause a notification to be propagated up the MOViewController hierarchy so parents can be aware when a child's label changes.
    
    <h4> Controller state saving and restoring </h4>
    
    A mechanism is provided for saving the state of a MOViewController and later restoring it.  A MOViewController can provide a "state dictionary" for itself and can restore its state from a dictionary that it is given.  State typically includes information about the geometry and other visual configuration of the MOViewController and its view.
    
    MOViewController provides an API to get a state dictionary out of a MOViewController hierarchy and to apply it back again later.  Subclasses are responsible for implementing the details of what gets saved for their specific content and how to apply it back.  MOViewController manages traversing the hierarchy (and, notably, making sure that restoring a saved configuration does not cause immediate non-lazy interface loading).
    
    The MOViewController base class automatically stores its class name, its label and icon, its view's frame information, and the state dictionaries of its subcontrollers.  A MOViewController that should not store and restore the state of its subcontrollers can override -savesSubcontrollerState to return NO.
    
    Here are some further examples of state saved by different kinds of controllers in MOKit.  MOTabViewController stores the selected tab, the tab font, the tab view style, and various other settable attributes of the NSTabView it manages.  MOSplitViewController stores whether it is horizontal or vertical and whether it uses a pane splitter or a normal splitter.  MOViewListView stores the expansion state of its subcontrollers as well as various attributes of the MOViewListView.
    
    Custom MOViewControllers should store anything that is needed to restore themselves to their current visual appearance and internal state.
    
    A distinction is made between state that is independent of the specific content the MOViewController might be showing and state depends on the content.  For example, in a subclass that manages a UI with an outline view, the column widths and order might be independent of its content, while the selection and the expansion state of the items might be dependent on the content.  A MOViewController can be asked to provide a state dictionary with or without the content-dependent state (the content-independent state is always included).  Similarly, when being given a dictionary to restore its state from, the MOViewController may be asked to ignore any content-dependent state, if it is present.  When writing a subclass of MOViewController, you should think carefully about which category each piece of state falls into.
    
    It is also wise, when implementing a custom MOViewController, to make your override of -takeStateDictionary:ignoringContentState: forgiving.  You should be prepared for incomplete or incorrect information and handle those cases gracefully.  This is especially true for content-dependent state since you never know, when restoring state at a later date, if the content has changed since the state was saved amking the content-dependent state stale or inappropriate.
    
    In addition to the basic API that allows getting and resotring state in a pre-built MOViewController hierarchy, MOViewController provides an API to create a MOViewController hierarchy from a state dictionary.  With this API, MOViewController uses the class information recorded in the state dictionary to actually create the hierarchy (which then resotres its state from the rest of the information in the dictionary.)
    
    <h4> Keyboard UI loop support </h4>
    
    MOViewController provides a mechanism for allowing reasonable handling of key-loops for keyboard controlled UI access.  A MOViewController has a -firstKeyView outlet.  Usually this is connected in Interface Builder to the first view that should receive focus in the MOViewController's interface.  It can also be set programmatically.  The -firstKeyView of a MOViewController should be a member of a complete key loop.  When the -firstKeyView is set, MOViewController computes the -lastKeyView by traversing to the -firstKeyView's -previousKeyView.  Once MOViewController  knows the first and last key view it can manage the key loop for the whole hierarchy as subcontrollers are installed and uninstalled.
    
    This mechanism is designed and implemented but has not been tested fully and is likely to need some further tweaks.
    
    <h3> Writing a MOViewController subclass </h3>

    This section discusses the actual steps involved in creating a new MOViewController subclass.  There are only a few things you really need to do.  And there are a number of things you may want to do in addition to the required steps.

    <h4> First steps </h4>

    The first thing you need to do to is make a subclass and create the interface.  A minimal subclass does not actually need to implement any methods.  MOViewController, by default, will look for a nib file named the same as the subclass to load as its interface.

    Here is a minimal subclass:
    
    <pre>
        &#64;interface MyCustomController : MOViewController {
        &#32;&#32;&#32;&#32;&#64;private
        &#32;&#32;&#32;&#32;// instance variables (should be private)
        }
        
        &#64;end
        
        &#64;implementation MyCustomController
        
        &#64;end
    </pre>
    
    Add any instance variables you need, including outlets that will be connected to your interface.  Add any methods you need, including actions that will be connected from your interface.

    Once you have the class, create a new empty nib file.  Drag the MOViewController.h header into the nib so that IB will know about the class.  Then drag your MyCustomController.h header into the nib.

    Select the File's Owner icon in the nib file, go to the Class inspector pane (Cmd-5 will bring up the Class inspector).  Set the File's Onwer's class to MyCustomController.

    Drag a Custom View off the "Cocoa Container Views" palette into your nib window.  When you drop it, a View icon should appear.  Double-clicking this icon will show your view in a window (but the window is not part of the nib file.)  You can tell the difference between a view and a window in IB because the IB window holding a view has a dark gray border around its edge.

    Connect the "contentView" outlet of the File's Owner to the view you just added.  To do this Control-drag a connection line from File's Owner to the View icon in the nib window.  Then select the "contentView" outlet in the inspector and click the Connect button.

    Now you can define the interface for your controller within the custom view.  Create the interface, making any connections you need.  Remember to connect the outlets and actions for your controller to the File's Owner icon in the nib file.

    <h4> Trying it out </h4>
    
    This is all that is needed to make a simple controller.  You can try it out by simply creating an instance of your controller and giving it a window to live in like this:
    
    <pre>
        &#32;&#32;&#32;&#32;MyCustomController *controller = [[MyCustomController alloc] init];
        &#32;&#32;&#32;&#32;[controller setWantsOwnWindow:YES];
        &#32;&#32;&#32;&#32;[controller showWindow:nil];
    </pre>
    
    (This code could be run from anywhere.  A good place to test it out might be in the -applicationDidFinishLaunching: method of your application delegate.)
    
    Commonly overridden methods
    
    There are a number of MOViewController methods that are commonly overridden for various purposes.
    
    The designated initializer for MOViewController is -init.  If you need to do initialization when an instance of your subclass is created, override that method.  The common idiom for overriding a designated initializer looks like this:
    
    <pre>
        - (id)init {
        &#32;&#32;&#32;&#32;self = [super init];
        &#32;&#32;&#32;&#32;if (self) {
        &#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;// Your init code here.
        &#32;&#32;&#32;&#32;}
        &#32;&#32;&#32;&#32;return self;
        }
    </pre>
    
    Init methods like this are not special to MOViewController.  All Cocoa init methods should follow this pattern.  The first thing you should do is call the superclass' designated initializer.  Note that the return value is assigned to self.  This is because it is permissable for an init method to replace the receiving instance with a new instance if it needs to.  When init methods fail they return nil, so the next line makes sure the superclass did not fail to do its initialization.  If the superclass failed, we do not do anything.  Finally, we return self.
    
    Be careful what you do in your controller's init method.  The controller's interface is not loaded yet, and the init method should never do anything to cause the interface to be loaded (such as sending a [self view] message).  Any initialization that can be put off until the view gets loaded should be.  Only do what is absolutely required in the init method.
    
    Even more common than overriding -init is overriding -viewDidLoad.  This message will be sent to the controller right after it loads its nib file.  At this time, the controller's outlets and actions will have been set up and you can do any further initialization of the interface that might be needed.  In general, you should set up everything you can in the nib file, but some things must be done in code, and -viewDidLoad gives you a place to do them.
    
    <pre>
        - (void)viewDidLoad {
        &#32;&#32;&#32;&#32;[super viewDidLoad];
        &#32;&#32;&#32;&#32;// Your setup code here
        }
    </pre>
        
    Always call super's implementation of viewDidLoad when you override it.  There is a similar method, -viewWillLoad, that can be overridden if you need to do any work prior to the interface being loaded.
    
    As with many Objective-C classes, you may need to override -dealloc to release any objects that your controller has references to.  Note that the contents of the nib file is taken care of by the MOViewController base class, so you do NOT need to release objects that were loaded from your nib file.
    
    Sometimes a controller may need to know when the controller hierarchy it is part of changes.  MOViewController has two methods that can be overridden for this.  -controller:didInsertSubcontroller:atIndex: and -controller:willRemoveSubcontroller:atIndex:.  When a subcontroller is being added or removed, the controller itself, all its ancestors, and all its descendants are sent these messages.  When overriding these, be sure to call super and be sure to keep in mind that these messages are sent to many objects.  It is common to examine the controller or subcontroller arguments to these methods to be sure that the change is one that you are interested in before doing any work.
    
    Similarly, a controller may need to know when it is installed or uninstalled in a view hierarchy.  MOViewController has two methods that can be overridden for this.  -controllerViewWasInstalled: and -controllerViewWillBeUninstalled:.  When a controller's view is installed or uninstalled, the controller itself, all its ancestors, and all its descendants are sent these messages.  When overriding these, be sure to call super and be sure to keep in mind that these messages are sent to many objects.  It is common to examine the controller argument to these methods to be sure that the change is one that you are interested in before doing any work.
    
    If you need to do any validation or other work every time through the event loop when your controller's UI is visible, you can override the -update method.  This method will be called at the end of each event for all controllers that are currently installed and whose ancestors are all currently installed (ie whose UI is currently installed in some window).  Note that this -update mechanism only works if the top-level controller of your controller's hierarchy is installed in its own window using the -setWantsOwnWindow: API.
    
    If, for some reason the name of the nib file for a MOViewController subclass is not the same as the class' name, you can override +defaultViewNibName. to return the actual name of the nib file to load for that class.  Note that overriding this method will affect any subclasses of your custom controller class as well as your class itself.
    
    <h4> Nib-less controllers </h4>
    
 Sometimes a controller does not want to get its interface from a nib file.  A MOViewController subclass can create its own interface programmatically.  To do this, it should override -loadView.  Within the override of loadView, the subclass should call [self setContentView:theView] once it has created its view.
    
    <h4> Controller labels </h4>
    
    It is a good idea to give your controller a meaningful label.  That may be a constant label that is the same for all instances or it may be instance-specific.  It may change over time.  I may include an icon and it may or may not represent a file path.
    
    Use the setLabel: API and related methods to set a label for your controller.  If the label is the same for all instances, then doing this from an -init override may be the easiest way.
    
    If you need to know when your controller or one of its descendants changes its label you can override -controllerDidChangeLabel:.  For example, a MOTabViewController overrides this to watch its children's labels, and if they change it updates the labels on its tabs.
    
    <h4> State saving </h4>
    
    If you wish to be able to save and restore the state of your controller, you should override -stateDictionaryIgnoringContentState: and -takeStateDictionary:ignoringContentState:.
    
    Both methods should always call super.
    
    -stateDictionaryIgnoringContentState: should call super and then add its own specific state to the mutable dictionary returned by the superclass implementation.
    
    -takeStateDictionary:ignoringContentState: should call super and then restore any of its own specific state it finds in the dictionary.
        
    <h3> MOViewController and NSController </h3>

    This section discusses how the new NSController facility that has been introduced in Panther fits in with MOViewController.   First, NSController is kind of an unfortunate class name since it is so general and the term "controller" is so overloaded.  It is important to note that NSController and MOViewController are not filling the same roles.  In fact they can be extremely powerful when used in combination.
    
    A MOViewController may optionally own one or more NSControllers.  Typically these NSControllers would be loaded from the MOViewController's nib file along with the MOViewController's interface.  NSControllers are really useful for binding data to UI elements.  The trick is how that binding happens.  In a demo, it is common to see NSControllers used in a simplistic way.  The NSController is bound to UI elements, but the data that is being bound is created and managed automatically by the controller.  This makes for nice demos, but it is not a complete picture of how a real application would use NSController.
    
    In a real application, the NSController will have bindings at both "ends".  On the "front end" it will be bound to UI elements the same as in the demo case.  But instead of owning and managing its own data, it will instead be bound to external data on the "back end".  These bindings will be through the File's Owner of the nib file containing the NSController.
    
    For applications that use MOViewController, the File's Owner of the nbib file is going to be a MOViewController subclass.  This means that the NSController bindings to data will go through the MOViewController.
    
    Let's look at a specific example.  Imagine you are building a rolodex application.  The model objects are Person objects with the obvious collection of keys (data members) like name, address, etc...  The application has a document class that manages a list of Person objects.  It also has a MOViewController subclass (PersonListController) that shows a list of Person objects and allows editing, inserting, removing.  The PersonListController class knows about the document whose Person objects it will be showing.  Both the PersonListController and the document class are Key-value Coding compliant (which simply means that the methods for accessing the document of the PersonListController and the Person array of the document follow the KVC naming conventions).
    
    The PersonListController's nib file has a table view and maybe some individual text fields and things.  It also has an NSArrayController.  The table and fields and other UI elements are bound to the NSArrayController just like you may have seen in NSController demos.  But, in addition, the NSArrayController is bound to the controller's document's array of Person objects.  This is done, in the bindings inspector for the NSArrayController, by binding the "contentArray" of the NSArrayController to the File's Owner with the key path "document.people" (assuming that the PersonListController's key for getting to its document is "document" and the document class' key for getting to the array of Person objects is "people".)
    
    Binding through the File's Owner gives a couple of benefits:
    
    <ul>
    <li>It is possible to establish the binding in the nib file instead of having to do it programmatically.</li>
    <li>It is completely automatic that the PersonListController's UI gets bound to the correct document's people.</li>
    </ul>

    In a simple case, the PersonListController might not need a single line of actual code (since it inherits the ability to have an associated document from MOViewController (which inherits it from NSWindowController).  By using NSController, the following features are automatically supported:
    
    <ul>
    <li>If the document's list of people changes in any way, the UI will update.</li>
    <li>If the user edits the fields of a Person through the PersonListController UI, the underlying Person objects will automatically be updated.</li>
    <li>If a PersonListController changes which document it is attached to, the UI will update to show the people in the new document.</li>
    </ul>

    <h3> Future feature ideas </h3>
    
    This is a working list of future directions for MOViewController:
    
    <ul>
    <li> Toolbar support </li>
    <li> Hot key support </li>
    <li> Unified controller-level drag & drop support </li>
    <li> ViewController Builder - IB like app for defining and configuring hierarchies with runtime support for loading them in </li>
    </ul>
  
 */
@interface MOViewController : NSWindowController {
    @private
#if 0
    // PUBLIC IB OUTLET DECLARATIONS
    // When parsing the header, IB will see these outlet declarations.  The real instance variables are named with underbars.  When loading a nib file with connections to these outlets, Cocoa will call the setter methods -setContentView: and -setFirstKeyView:.
    IBOutlet NSView *contentView;
    IBOutlet NSView *firstKeyView;
#else
    // ACTUAL INSTANCE VARIABLE DECLARATIONS FOR OUTLETS
    NSView *_contentView;
    NSView *_firstKeyView;
#endif

    NSView *_view;
    NSView *_lastKeyView;
    
    MOViewController *_supercontroller;
    NSMutableArray *_subcontrollers;

    id _ownWindowController;

    NSString *_label;
    NSString *_representedFilename;
    NSImage *_icon;

    NSRect *_savedViewFramePtr;

    struct {
        unsigned int initing:1;
        unsigned int isViewLoaded:1;
        unsigned int isViewInstalled:1;
        unsigned int hasEverBeenInstalled:1;
        unsigned int wantsOwnWindow:1;
        unsigned int shouldFetchIcon:1;
        unsigned int _reserved:26;
    } _vcFlags;

    void *_vcReserved1;
    void *_vcReserved2;
}

/*!
    @method     defaultViewNibName
    @abstract   Returns the name of the nib file containing the view for the receiving class.
    @discussion Returns the name of the nib file containing the view for the receiving class.  By default, this returns the name of the class which means that this method does not need to be overridden normally if you name your nib files and classes with the same names.
    @result     The name of the nib file.
*/
+ (NSString *)defaultViewNibName;

/*!
    @method     init
    @abstract   Designated initializer.
    @discussion Designated initializer.  Note that ALL the inherited initializers from NSWindowController are explicitly disallowed for MOViewController except for -init.  This method initializes the controller so that it will load the nib file returned by +defaultViewNibName.
    @result     The initialized instance.
*/
- (id)init;

- (id)initWithWindow:(NSWindow *)window;
- (id)initWithWindowNibName:(NSString *)windowNibName;
- (id)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner;
- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner;
    // Disallowed initializers.  These initializers are inherited from NSWindowController and are disabled for use with MOViewController.  Do not call them.  These are intentionally not documented.

/*!
    @method     supercontroller
    @abstract   Returns the receiver's supercontroller.
    @discussion Returns the receiver's supercontroller.
    @result     The receiver's supercontroller.
*/
- (id)supercontroller;

/*!
    @method     setSupercontroller:
    @abstract   Sets the receiver's supercontroller.
    @discussion Sets the receiver's supercontroller.  This method is invoked automatically when a controller is added to or removed from its supercontroller.  Overrides should call super.  This method should never be called directly.
    @param      supercontroller The new supercontroller.
*/
- (void)setSupercontroller:(MOViewController *)supercontroller;

/*!
    @method     subcontrollers
    @abstract   Returns the receiver's array of subcontrollers.
    @discussion Returns the receiver's array of subcontrollers.
    @result     The receiver's array of subcontrollers.
*/
- (NSArray *)subcontrollers;

/*!
    @method     insertSubcontroller:atIndex:
    @abstract   Inserts the given controller as a subcontroller of the receiver.
    @discussion Inserts the given controller as a subcontroller of the receiver.  This is the primitive method for adding a subcontroller.  The controller is inserted at the given index.
    @param      subcontroller The new subcontroller.
    @param      index The index for insertion.
*/
- (void)insertSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index;

/*!
    @method     addSubcontroller:
    @abstract   Adds the given controller as a subcontroller of the receiver.
    @discussion Adds the given controller as a subcontroller of the receiver.  This method calls -insertSubcontroller:atIndex: to insert the new controller at the end of the subcontroller array.
    @param      subcontroller The new subcontroller.
*/
- (void)addSubcontroller:(MOViewController *)subcontroller;

/*!
    @method     removeSubcontrollerAtIndex:
    @abstract   Removes the subcontroller of the receiver at the given index.
    @discussion Removes the subcontroller of the receiver at the given index.  This is the primitive method for removing a subcontroller.
    @param      index The index of the subcontroller to be removed.
*/
- (void)removeSubcontrollerAtIndex:(unsigned)index;

/*!
    @method     removeSubcontroller:
    @abstract   Removes the given subcontroller of the receiver.
    @discussion Removes the given subcontroller of the receiver.  This method calls -removeSubcontrollerAtIndex: after finding the index for the given subcontroller.
    @param      subcontroller The subcontroller to be removed.
*/
- (void)removeSubcontroller:(MOViewController *)subcontroller;

/*!
    @method     controller:didInsertSubcontroller:atIndex:
    @abstract   Called when subcontrollers are inserted into the hierarchy.
    @discussion Called when subcontrollers are inserted into the hierarchy.  This method is purely for overriding by controller subclasses that need to be aware of changes in the controller hierarchy.  Right after a controller has a new subcontroller inserted this method is sent to the controller, to all its ancestors, to the subcontroller and to all the subcontroller's descendants.  Overrides should call super.  This method should never be called directly.
    @param      controller The controller that had a new subcontroller inserted.
    @param      subcontroller The subcontroller that was inserted.
    @param      index The index of the subcontroller.
*/
- (void)controller:(MOViewController *)controller didInsertSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index;

/*!
    @method     controller:willRemoveSubcontroller:atIndex:
    @abstract   Called when subcontrollers are removed from the hierarchy.
    @discussion Called when subcontrollers are removed from the hierarchy.  This method is purely for overriding by controller subclasses that need to be aware of changes in the controller hierarchy.  Right before a controller has a subcontroller removed this method is sent to the controller, to all its ancestors, to the subcontroller and to all the subcontroller's descendants.  Overrides should call super.  This method should never be called directly.
    @param      controller The controller that had a new subcontroller inserted.
    @param      subcontroller The subcontroller that was inserted.
    @param      index The index of the subcontroller.
*/
- (void)controller:(MOViewController *)controller willRemoveSubcontroller:(MOViewController *)subcontroller atIndex:(unsigned)index;

/*!
    @method     isAncestorOfController:
    @abstract   Returns whether the receiver is an ancestor of the given controller.
    @discussion Returns whether the receiver is an ancestor of the given controller.
    @param      descendant The potential descendant.
    @result     Whether the receiver is an ancestor of the given controller.
*/
- (BOOL)isAncestorOfController:(MOViewController *)descendant;

/*!
    @method     viewNibName
    @abstract   Returns the name of the nib file that this controller loads.
    @discussion Returns the name of the nib file that this controller loads.  This is basically a rename of the inherited -windowNibName (and -windowNibName will also return the same name).
    @result     The nib file name.
*/
- (NSString *)viewNibName;

/*!
    @method     viewNibPath
    @abstract   Returns the path of the nib file that this controller loads.
    @discussion Returns the path of the nib file that this controller loads.  This is basically a rename of the inherited -windowNibPath (and -windowNibPath will also return the same name).
    @result     The nib file path.
*/
- (NSString *)viewNibPath;

/*!
    @method     isViewLoaded
    @abstract   Returns whether the receiver's view has been loaded (or created).
    @discussion Returns whether the receiver's view has been loaded (or created).  If the controller has loaded its nib or has had an explicit call to -setContentView: (even -setContentView:nil), this will reutrn YES.  This is often used to avoid asking questions or to postpone work that would cause the view to be loaded in order to keep nib file loading as lazy as possible.
    @result     Whether the receiver's view has been loaded (or created).
*/
- (BOOL)isViewLoaded;

/*!
     @method     view
     @abstract   Returns the receiver's base view, loading the content view if necessary.
     @discussion Returns the receiver's base view, loading the content view if necessary.  Calls to this method should be avoided until it is time to actually install the view into a view hierarchy in order to preserve laziness.  Use -isViewLoaded to avoid asking for the view if you do not want it to be loaded.
     @result     The receiver's view.
     */
- (id)view;

/*!
     @method     contentView
     @abstract   Returns the receiver's contentView, loading it if necessary.
     @discussion Returns the receiver's contentView, loading it if necessary.  Calls to this method should be avoided until it is time to actually install the view into a view hierarchy in order to preserve laziness.  Use -isViewLoaded to avoid asking for the view if you do not want it to be loaded.
     @result     The receiver's contentView.
     */
- (id)contentView;

/*!
    @method     setContentView:
    @abstract   Sets the receiver's contentView.
    @discussion Sets the receiver's contentView.  There is one common direct use of this method: it is often called from the -loadView of a subclass that programmatically constructs its view instead of loading it from a nib file.  This method is called implicitly when loading the nib file of a controller to estabnlish the view outlet connection.  It is rare to need to override this method and it is rare to call it directly other than from an override of -loadView. 
    @param      aView The contentView.
*/
- (void)setContentView:(NSView *)aView;



/*!
    @method     minContentSize
    @abstract   Returns the minimum size for the content view.
    @discussion Returns the minimum size for the content view.  If the containing view (or window) is smaller than the content view's minimum size, the content view will clip on the right/lower edges
*/
- (NSSize)minContentSize;

/*!
    @method     setMinContentSize:
    @abstract   Sets the minimum size for the content view.
    @discussion Sets the minimum size for the content view.  If the containing view (or window) is smaller than the content view's minimum size, the content view will clip on the right/lower edges
*/
- (void)setMinContentSize:(NSSize)minContentSize;

/*!
    @method     maxContentSize
    @abstract   Returns the max size for the content view.
    @discussion Returns the max size for the content view.
*/
- (NSSize)maxContentSize;

/*!
    @method     setMaxContentSize:
    @abstract   Sets the max size for the content view.
    @discussion Sets the max size for the content view.
*/
- (void)setMaxContentSize:(NSSize)maxContentSize;

/*!
    @method     loadView
    @abstract   Loads (or creates) the controller's view.
    @discussion Loads (or creates) the controller's view.  MOViewController's implementation attempts to load the controller's nib file.  Subclasses may override if they create their view programmatically instead of through loading a nib.  In this case, the override should create the view and call -setContentView: to give ownership of it to the controller.  This method should never be called directly.
*/
- (void)loadView;

/*!
    @method     viewWillLoad
    @abstract   Sent immediately before the receiver loads its view.
    @discussion Sent immediately before the receiver loads its view.  Subclasses may override to prepare for the view to be loaded.  Overrides should call super.  This method should never be called directly.
*/
- (void)viewWillLoad;

/*!
    @method     viewDidLoad
    @abstract   Sent immediately after the receiver loads its view.
    @discussion Sent immediately after the receiver loads its view.  Subclasses may override to finish setting up after the view is loaded.  Overrides should call super.  This method should never be called directly.
*/
- (void)viewDidLoad;

/*!
    @method     isViewInstalled
    @abstract   Returns whether the controller's view is currently installed in a view hierarchy.
    @discussion Returns whether the controller's view is currently installed in a view hierarchy.
    @result     (description)
*/
- (BOOL)isViewInstalled;

/*!
    @method     viewWasInstalled
    @abstract   Notifies the controller that its view was installed in a view hierarchy.
    @discussion Notifies the controller that its view was installed in a view hierarchy.  This method MUST be sent to the controller AFTER its view has been installed.  Usually it is the controller's supercontroller that installs the view and then sends this message.  This method should not be overridden.  Instead, override the -controllerViewWasInstalled: method if you need to do anything when your controller's view has been installed.
*/
- (void)viewWasInstalled;

/*!
    @method     viewWillBeUninstalled
    @abstract   Notifies the controller that its view is about to be uninstalled from a view hierarchy.
    @discussion Notifies the controller that its view is about to be uninstalled from a view hierarchy.  This method MUST be sent to the controller BEFORE its view has been uninstalled.  Usually it is the controller's supercontroller that sends this message and then uninstalls the view.  This method should not be overridden.  Instead, override the -controllerViewWillBeUninstalled: method if you need to do anything when your controller's view is about to be uninstalled.
*/
- (void)viewWillBeUninstalled;

/*!
    @method     controllerViewWasInstalled:
    @abstract   Called when a controller's view has been installed.
    @discussion Called when a controller's view has been installed.  This method is purely for overriding by controller subclasses that need to be aware when views are installed.  Right after a controller's view is installed this method is sent to the controller, to all its ancestors, and to all the controller's descendants.  Overrides should call super.  This method should never be called directly.
    @param      controller The controller whose view was installed.
*/
- (void)controllerViewWasInstalled:(MOViewController *)controller;

/*!
    @method     controllerViewWillBeUninstalled:
    @abstract   Called when a controller's view is about to be uninstalled.
    @discussion Called when a controller's view is about to be uninstalled.  This method is purely for overriding by controller subclasses that need to be aware when views are uninstalled.  Right before a controller's view is uninstalled this method is sent to the controller, to all its ancestors, and to all the controller's descendants.  Overrides should call super.  This method should never be called directly.
    @param      controller The controller whose view will be uninstalled.
*/
- (void)controllerViewWillBeUninstalled:(MOViewController *)controller;

/*!
    @method     update
    @abstract   Sent to any installed controllers after their window is updated.
    @discussion Sent to any installed controllers after their window is updated.  This method is automatically invoked on any controllers that are currently (fully) installed at the end of each event loop.  View controllers are updated immediately following the -update of the window that contains them.  "Fully" installed means that the controller must be installed in its supercontroller and its supercontroller and all its ancestor controllers must also be installed.  It is also required that the top-level ancestor controller owns the window that contains the controller (in the -setWantsOwnWindow:YES sense).
                
                Note that -update is not responsible for recursing and sending update messages to the receiver's subcontrollers.  This is handled elsewhere.  If you invoke -update directly it will update the receiver only, not its subcontrollers.
*/
- (void)update;

/*!
    @method     firstKeyView
    @abstract   Returns the controller's firstKeyView.
    @discussion Returns the controller's firstKeyView.  This method will cause the controller's view to be loaded if necessary.  Usually the firstKeyView is set via an outlet connection in Interface Builder.  For proper functioning, there should be a complete tab-loop defined in the controller's nib file (if there is more than one view that should be able to get focus).
    @result     The controller's firstKeyView.
*/
- (id)firstKeyView;

/*!
    @method     setFirstKeyView:
    @abstract   Sets the controller's firstKeyView.
    @discussion Sets the controller's firstKeyView.  Usually this is called during nib loading to connect the outlet.  The firstKeyView should be a view within the controller's owned view hierarchy.  It is not directly retained by the controller.  At the time this method is called, the given firstKeyView should already be a member of a complete tab-loop (or, if there's only one interesting view, it should have no nextKeyView).  The controller's lastKeyView will be calculated when this method is called (actually, because there's no order guarantee of any order for IB outlet conenctions, the lastKeyView will also be computed at -viewDidLoad time).  The firstKeyView MUST be set prior to the controller's view ever being installed.  Practically speaking this means that it should be set through an outlet connection in Interface Builder or in a subclasses' override of -loadView for subclasses that programmatically create their views.
*/
- (void)setFirstKeyView:(id)aFirstKeyView;

/*!
    @method     lastKeyView
    @abstract   Returns the controller's lastKeyView.
    @discussion Returns the controller's lastKeyView.  This method will cause the controller's view to be loaded if necessary.  This method returns the firstKeyView's previousKeyView or the firstKeyView if it has no previousKeyView.  This property is not directly settable.  Instead it is calculated from the firstKeyView at the time it is set (or after the controller's nib has loaded).
*/
- (id)lastKeyView;

/*!
    @method     setWantsOwnWindow:
    @abstract   Used to give a controller its own window (or take it away).
    @discussion Used to give a controller its own window (or take it away).  If the flkag is YES then the receiver will be a top-level controller that owns and manages its own window.  If the flag is NO, the controller will not have its own window (and will generally be inserted as a subcontroller within a larger controller hierarchy.)
    @param      flag Whether the controller should own and manage its own window.
*/
- (void)setWantsOwnWindow:(BOOL)flag;

/*!
    @method     wantsOwnWindow
    @abstract   Returns whether the controller should own and manage its own window.
    @discussion Returns whether the controller should own and manage its own window.
    @result     Whether the controller should own and manage its own window.
*/
- (BOOL)wantsOwnWindow;

/*!
    @method     loadControllerWindow
    @abstract   Called when the window that the controller will live in needs to be created.
    @discussion Called when the window that the controller will live in needs to be created.  When a controller is set to have its own window, this method is called when that window actually needs to be created.  MOViewController's implementation allocates a new window of the class returned by -controllerWindowClass with the style mask returned by -controllerWindowStyleMask.
    @result     The window that the controller should live in.
*/
- (NSWindow *)loadControllerWindow;

/*!
    @method     controllerWindowClass
    @abstract   Returns the NSWindow subclass that should be used when the receiver creates its own window.
    @discussion Returns the NSWindow subclass that should be used when the receiver creates its own window.  MOViewController's implementation returns [NSWindow class].
    @result     The window class.
*/
- (Class)controllerWindowClass;

/*!
    @method     controllerWindowStyleMask
    @abstract   Returns the NSWindow style mask that should be used when the receiver creates its own window.
    @discussion Returns the NSWindow style mask that should be used when the receiver creates its own window.  MOViewController's implementation returns (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask).
    @result     The window style mask.
*/
- (unsigned)controllerWindowStyleMask;

/*!
    @method     windowController
    @abstract   Returns the NSWindowController that manages the window the receiver is in.
    @discussion Returns the NSWindowController that manages the window the receiver is in.  If the receiver owns its own window then this returns the NSWindowController it uses to manage it.  Otherwise it returns [[self supercontroller] windowController].
    @result     The window controller.
*/
- (NSWindowController *)windowController;

/*!
    @method     showWindow:
    @abstract   Tells the NSWindowController that manages the window the receiver is in to show itself.
    @discussion Tells the NSWindowController that manages the window the receiver is in to show itself.  If the receiver owns its own window then this sends -showWindow: to the NSWindowController it uses to manage it.  Otherwise it sends [[self supercontroller] showWindow:sender].
    @param      sender Action sender, ignored.
*/
- (void)showWindow:(id)sender;

/*!
    @method     setLabel:icon:representedFilename:
    @abstract   Sets the label, icon, and representedFilename of the receiver.
    @discussion Sets the label, icon, and representedFilename of the receiver.  This is the primitive method for setting the label, icon, and representedFilename.  The other related set methods simply call this one.
    @param      label The label, this must be non-nil.
    @param      icon The icon, may be nil.
    @param      path The representedFilename, may be nil.
*/
- (void)setLabel:(NSString *)label icon:(NSImage *)icon representedFilename:(NSString *)path;

/*!
    @method     setLabel:
    @abstract   Sets the label of the receiver.
    @discussion Sets the label of the receiver.  The clears the existing representedFilename.  It preserves any existing icon.
    @param      label The label, this must be non-nil.
*/
- (void)setLabel:(NSString *)label;

/*!
    @method     setIcon:
    @abstract   Sets the icon of the receiver.
    @discussion Sets the icon of the receiver.  The preserves the existing label and representedFilename.
    @param      icon The icon, may be nil.
*/
- (void)setIcon:(NSImage *)label;

/*!
    @method     setRepresentedFilename:
    @abstract   Sets the representedFilename of the receiver.
    @discussion Sets the representedFilename of the receiver.  The preserves the existing label and icon.
    @param      path The representedFilename, may be nil.
*/
- (void)setRepresentedFilename:(NSString *)path;

/*!
    @method     setLabelAsFilename:
    @abstract   Sets the label, icon, and representedFilename of the receiver.
    @discussion Sets the label, icon, and representedFilename of the receiver.  The label and icon are calculated from the given representedFilename.
    @param      path The representedFilename, may be nil.
*/
- (void)setLabelAsFilename:(NSString *)path;

/*!
    @method     label
    @abstract   Returns the label of the receiver.
    @discussion Returns the label of the receiver.  If the label has never been set, MOViewController returns the class' name by default.
    @result     The label.
*/
- (NSString *)label;

/*!
    @method     icon
    @abstract   Returns the icon of the receiver.
    @discussion Returns the icon of the receiver.
    @result     The icon.
*/
- (NSImage *)icon;

/*!
    @method     representedFilename
    @abstract   Returns the representedFilename of the receiver.
    @discussion Returns the representedFilename of the receiver.
    @result     The representedFilename.
*/
- (NSString *)representedFilename;

/*!
    @method     controllerDidChangeLabel:
    @abstract   Sent when a controller's label, icon, or representedFilename changes.
    @discussion Sent when a controller's label, icon, or representedFilename changes.  This method is sent to the controller and all its ancestors.  Overrides should call super.  This method should never be called directly.
    @param      controller The controller whose label changed.
*/
- (void)controllerDidChangeLabel:(MOViewController *)controller;

/*!
    @method     stateDictionaryIgnoringContentState:
    @abstract   Returns the state dictionary for the receiver.
    @discussion Returns the state dictionary for the receiver.  MOViewController saves its view's frame and, if [self savesSubcontrollerState] is YES, it recursively saves info about all its subcontrollers.  Subclasses may override this method to store their own additional state.  The ignoreContentFlag argument indicates whether state that relies on the current content of the controller should be saved.  Non-content state should be limited to state that does not depend on the data being displayed.  Content state can be used to store state that depends on the data being displayed.  For example, if a controller contains an outline that always shows three columns and shows data from a document, the column order and sizes are non-content state, but the expansion state of the outline contents and the selected items should be considered content state.  On the other hand, if the outline always shows the same hierarchy, then the expansion state could be considered non-content state.  Sometimes generic controller subclasses may need to provide API to allow clients to decide whether a particular piece of information is content state or not based on how they are used.  See MOTabViewController for an example of this.
    
                Subclasses should always call super.  Subclasses should take care not to cause view loading when overriding this method.  If the view has not been loaded, this method should not cause it to be loaded simply to gather and return the (default) geometry configuration.
    @param      ignoreContentFlag If this is YES then any content-specific state should not be added to the result dictionary.
    @result     The state dictionary for the receiver.
*/
- (NSMutableDictionary *)stateDictionaryIgnoringContentState:(BOOL)ignoreContentFlag;

/*!
    @method     takeStateDictionary:ignoringContentState:
    @abstract   Restores the receiver's state from the state dictionary.
    @discussion Restores the receiver's state from the state dictionary.  MOViewController restores its view's frame and, if [self savesSubcontrollerState] is YES, it recursively restores info for all its subcontrollers.  Subclasses may override this method to restore their own additional state.  The ignoreContentFlag argument indicates whether state that relies on the current content of the controller should be restored.  Non-content state should be limited to state that does not depend on the data being displayed.  Content state can be used to store state that depends on the data being displayed.  For example, if a controller contains an outline that always shows three columns and shows data from a document, the column order and sizes are non-content state, but the expansion state of the outline contents and the selected items should be considered content state.  On the other hand, if the outline always shows the same hierarchy, then the expansion state could be considered non-content state.  Sometimes generic controller subclasses may need to provide API to allow clients to decide whether a particular piece of information is content state or not based on how they are used.  See MOTabViewController for an example of this.
    
                Subclasses should always call super.  Subclasses should take care not to cause view loading when overriding this method.  In some cases this may require storing away some of the information until the view loads and it can be applied.
    @param      dict The state dictionary to be restored.
    @param      ignoreContentFlag If this is YES then any content-specific state in the dictionary should be ignored.
*/
- (void)takeStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag;

/*!
    @method     savesSubcontrollerState
    @abstract   Returns whether subcontroller state should be saved.
    @discussion Returns whether subcontroller state should be saved.  This controls whether -stateDictionaryIgnoringContentState: will generate configuration state for subcontrollers.  It also controls whether -takeStateDictionary:ignoringContentState: will attempt to restore state for subcontrollers if it exists in the dictionaries they are given.  The default is YES.
    @result     Whether subcontroller state should be saved.
*/
- (BOOL)savesSubcontrollerState;

/*!
    @method     viewControllerWithStateDictionary:ignoringContentState:
    @abstract   Create a controller hierarchy from a saved state dictionary.
    @discussion Create a controller hierarchy from a saved state dictionary.  This method uses the information in the given state dictionary to recreate a controller hierarchy.  Contrast this with -takeStateDictionary:ignoringContentState: which applies a state dictionary to an existing controller hierarchy.  Actually, this method first builds the controller hierarchy, given the information in the state dictionary, and then simply calls -takeStateDictionary:ignoringContentState: on the root controller of the hierarchy it has created.
    
                If no MOViewControllerClassLoader has been set, then this method will use NSClassFromString to locate the classes to use for each controller in the dictionary.  If there is a MOViewControllerClassLoader, then it will be asked to resolve controller class names into classes.
    
    @param      dict The state dictionary.
    @param      ignoreContentFlag If this is YES then any content-specific state in the dictionary should be ignored.
    @result     The newly constructed top-level controller. 
*/
+ (id)viewControllerWithStateDictionary:(NSDictionary *)dict ignoringContentState:(BOOL)ignoreContentFlag;

/*!
    @method     setViewControllerClassLoader:
    @abstract   Sets the object to use to load unknown controller classes.
    @discussion Sets the object to use to load unknown controller classes.  +viewControllerWithStateDictionary:ignoringContentState: will send this object a -viewControllerClassFromString: message whenever it encounters a controller class name in a state dictionary.  The object may do whatever it needs to do to locate and load the code for the requested class.  It can even return a different class, but doing so is potentially dangerous unless the substitution is part of an overall design.
    
                Similarly, -stateDictionaryIgnoringContentState: will call -stringFromViewControllerClass: for each controller being saved to get the name to use within the state dictionary.
                
                If no MOViewControllerClassLoader is set then MOViewController will use NSClassFromString() and NSStringFromClass() to map classes back and forth from their names.
    @param      classLoader The object to use to resolve controller class names.
*/
+ (void)setViewControllerClassLoader:(id <MOViewControllerClassLoader>)classLoader;

/*!
    @method     viewControllerClassLoader
    @abstract   Gets the object to use to load unknown controller classes.
    @discussion Gets the object to use to load unknown controller classes.  +viewControllerWithStateDictionary:ignoringContentState: will send this object a -viewControllerClassFromString: message whenever it encounters a controller class name in a state dictionary.  The object may do whatever it needs to do to locate and load the code for the requested class.  It can even return a different class, but doing so is potentially dangerous unless the substitution is part of an overall design.
    
                Similarly, -stateDictionaryIgnoringContentState: will call -stringFromViewControllerClass: for each controller being saved to get the name to use within the state dictionary.
                
                If no MOViewControllerClassLoader is set then MOViewController will use NSClassFromString() and NSStringFromClass() to map classes back and forth from their names.
    @result     The object to use to resolve controller class names.
*/
+ (id <MOViewControllerClassLoader>)viewControllerClassLoader;

/*!
    @method     activeControllerShowsFocus
    @abstract   Returns whether MOViewController will visibly show a ring around the controller that contains the first responder in its window.
    @discussion Returns whether MOViewController will visibly show a ring around the controller that contains the first responder in its window.  The default is NO.  If set to YES, then MOViewController will draw a focus ring around the first view controller in the responder chain that returns YES for -showsControllerFocus. 
    @result     Whether MOViewController will visibly show focus.
*/
+ (BOOL)activeControllerShowsFocus;

/*!
    @method     setActiveControllerShowsFocus:
    @abstract   Sets whether MOViewController will visibly show a ring around the controller that contains the first responder in its window.
    @discussion Sets whether MOViewController will visibly show a ring around the controller that contains the first responder in its window.  The default is NO.  If set to YES, then MOViewController will draw a focus ring around the first view controller in the responder chain that returns YES for -showsControllerFocus. 
    @param      flag Whether MOViewController will visibly show focus.
*/
+ (void)setActiveControllerShowsFocus:(BOOL)flag;

/*!
    @method     focusRingColor
    @abstract   Returns the color to use to draw the controller focus ring.
    @discussion Returns the color to use to draw the controller focus ring.  If +activeControllerShowsFocus returns YES, then the focus ring will be drawn with the color returned by this method.  The default is [NSColor keyboardFocusIndicatorColor].
    @result     The color to use to draw the controller focus ring.
*/
+ (NSColor *)focusRingColor;

/*!
    @method     setFocusRingColor:
    @abstract   Sets the color to use to draw the controller focus ring.
    @discussion Sets the color to use to draw the controller focus ring.  If +activeControllerShowsFocus returns YES, then the focus ring will be drawn with the color set through this method.  The default is [NSColor keyboardFocusIndicatorColor].
    @param      color The color to use to draw the controller focus ring.
*/
+ (void)setFocusRingColor:(NSColor *)color;

/*!
    @method     focusRingWidth
    @abstract   Returns the width of the line used to draw the controller focus ring.
    @discussion Returns the width of the line used to draw the controller focus ring.  If +activeControllerShowsFocus returns YES, then the focus ring will be drawn with the width returned by this method.  The default is 3.0.
    @result     The width of the line used to draw the controller focus ring.
*/
+ (float)focusRingWidth;

/*!
    @method     setFocusRingWidth:
    @abstract   Sets the width of the line used to draw the controller focus ring.
    @discussion Sets the width of the line used to draw the controller focus ring.  If +activeControllerShowsFocus returns YES, then the focus ring will be drawn with the width set through this method.  The default is 3.0.
    @param      width The width of the line used to draw the controller focus ring.
*/
+ (void)setFocusRingWidth:(float)width;

/*!
    @method     showsControllerFocus
    @abstract   Returns whether this controller should show a focus ring.
    @discussion Returns whether this controller should show a focus ring.  When +activeControllerShowsFocus is set to YES, this method is called to see if any particular controller should or should not show a focus ring.  The default is YES.  If this is overridden to return NO, then the focus ring will be drawn around this controller's supercontroller (if it returns YES for -showsControllerFocus... otherwise its supercontroller, and so on).  This is provided as an override point for controller classes that may not want to ever be drawn with a focus ring, preferring instead to let their supercontrollers reflect focus
    @result     Whether this controller should show a focus ring.
*/
- (BOOL)showsControllerFocus;

@end

/*!
    @category   NSPasteboard(MOViewControllerPboard)
    @abstract   NSPastboard additions to support reading and writing view controllers.
    @discussion NSPastboard additions to support reading and writing view controllers.  MOViewControllers are written to the pasteboard using their state dictionaries as the persistent representation (by calling -stateDictionaryIgnoringContentState:).  They are read back by recreating the controller hierarchies using the +viewControllerWithStateDictionary:ignoringContentState: factory method.  This means that if you pass a controller through the pasteboard, you get a new equivalent controller hierarchy when you take it back out, you do NOT get the original controller hierarchy.  Note that this also means that the new hierarchy will be equivalent only to the extent supported by its state dictionary.  If a controller subclass fails to save and restore some aspect of its state, that aspect will be lost when the controller passes through the pasteboard.
*/
@interface NSPasteboard (MOViewControllerPboard)

/*!
    @method     setViewControllers:forType:
    @abstract   Writes the state dictionaries for the given controllers to the pasteboard with the given type.
    @discussion Writes the state dictionaries for the given controllers to the pasteboard with the given type.  This method calls -stateDictionaryIgnoringContentState:NO on each controller and puts the resulting dictionaries into an array which it then writes to the pasteboard.  Usually, the pasteboard type will be MOViewControllerPboardType, but in specialized situations a more specialized pasteboard type can be defined and used instead.
    @param      controllers An array of the controllers to be written.
    @param      dataType The pasteboard type to write the data as (the written data is the same regardless of the type).
    @result     Whether the write was successful.
*/
- (BOOL)setViewControllers:(NSArray *)controllers forType:(NSString *)dataType;

/*!
    @method     viewControllersForType:
    @abstract   Recreates the controllers for the state dictionaries on the pasteboard.
    @discussion Recreates the controllers for the state dictionaries on the pasteboard.  This method calls +viewControllerWithStateDictionary:ignoringContentState: for each dictionarty in the array on the pasteboard to create corresponding new controller hierarchies.  Usually, the pasteboard type will be MOViewControllerPboardType, but in specialized situations a more specialized pasteboard type can be defined and used instead.  The data on the pasteboard should have been written with -setViewControllers:forType:
    @param      dataType The pasteboard type to write the data as (the data format is expected to be the same regardless of the type).
    @result     An array of the newly created MOViewControllers.
*/
- (NSArray *)viewControllersForType:(NSString *)dataType;

@end

MOKIT_EXTERN NSString *MOViewControllerPboardType;

MOKIT_EXTERN const NSRect MOViewControllerDefaultFrame;
    // This constant rect can be used by subclasses that create their views programatically.  It is a reasonable size rect for an initial view size if you don't have any special requirements.

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOViewController__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
