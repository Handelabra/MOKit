// MOCompletionManager.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOCompletionManager
 @discussion Defines the MOCompletionManager class.
 */

#if !defined(__MOKIT_MOCompletionManager__)
#define __MOKIT_MOCompletionManager__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
@class MOCompletionStrategy;

/*!
 @class MOCompletionManager
 @abstract Provides generic completion facilities for NSTextViews or textual editable NSControls.
 @discussion MOCompletionManager provides a small framework for implementing various types of escape completion.  The delegate of an NSTextView or editable NSControl can use an instance of MOCompletionManager to handle escape completion merely by calling a couple of methods at appropriate times. The class manages the completion and keeps state necessary for completion but does not implement any specific style of completion.  Subclasses of the abstract class MOCompletionStrategy provide the actual completion behavior.

 To use MOCompletionManager just alloc/init one.  Usually one instance will serve a single NSTextView or editable NSControl. You will need to create an array of completion strategies and pass it to setCompletionStrategies:.  MOKit comes with one strategy: MOFilenameCompletionStrategy.  You can create others by subclassing MOCompletionStrategy. Often a MOCompletionManager has a single completion strategy. If it has more than one, they are tried in order and the first one that returns possible completions in a given context is the one used.  If MOCompletionManager is the delegate of an NSTextView, then everything will just work, but usually this is not possible because you have a controller object that needs to be delegate.  Usually the controller object "has-a" MOCompletionManager.  In this case, you just need to implement a couple of the delegate messages to call into the MOCompletionManager: -textDidChange:, -textDidEndEditing:, and -textView:doCommandBySelector:.

 In the first two methods, you should call -dumpCompletionState in the MOCompletionManager.  For the last one, you should call -doCompletionInTextView:startLimit:basePath: if the command selector is -complete:.

 For controls, of course, the control variants of these delegate methods would be used: -controlTextDidChange:, -controlTextDidEndEditing:, and -control:textView:doCommandBySelector:.

 Completion works in a standardized way.  A MOCompletionStrategy object is used to generate a list of possible completions when completion is invoked for the first time in a given context. On that first completion, the longest common prefix of all the completions found is appended to the prefix string. On subsequent completions with the same context (ie no selection changes or editing in between) the actual completions are cycled through one at a time.
 */
@interface MOCompletionManager : NSObject {
    @private
    NSTextView *_cachedTextView;
    NSRange _cachedSelectedRange;
    NSString *_cachedBasePath;
    NSMutableArray *_completionStrategies;
    MOCompletionStrategy *_completionStrategy;
    NSArray *_completionMatches;
    unsigned _lastMatchIndex;
    NSRange _completionRange;
    NSString *_completionPrefixString;
    BOOL _dumpCompletionsEnabled;
    BOOL _completeWords;
}

/*!
 @method setCompletionStrategies:
 @abstract Set the completion strategies.
 @discussion This method sets the array of MOCompletionStrategy instances that the receiver should use to implement its completion behavior. If a MOCompletionManager has more thyan one completion strategy, each time a new completion is being done, the strategies are tried in order and the first one that returns any matches is used. Matches from multiple strategies are NOT mixed together.
 @param strategies The NSArray of MOCompletionStrategy instances.
 */
- (void)setCompletionStrategies:(NSArray *)strategies;

/*!
 @method completionStrategies
 @abstract Returns the completion strategies.
 @discussion This method returns the array of MOCompletionStrategy instances that the receiver uses to implement its completion behavior.
 @result The NSArray of MOCompletionStrategy instances.
 */
- (NSArray *)completionStrategies;

/*!
 @method dumpCompletionState
 @abstract Discard completion state so the next completion will start fresh.
 @discussion This method discards any stored state that the MOCompletionManager uses to provide cycling through multiple completions. It is called automatically, sometimes, if MOCompletionManager detects that the stored state is stale and that a new new completion state should be calculated. This happens, for example, if completion is requested for a different NSTextView from the last completion or if the selection range or base path has changed since the last completion. It is also called automatically following a successful completion that had only a single match. Finally, it is automatically called from MOCompletionManager's implementations of -textDidChange:, -textDidEndEditing:, -controlTextDidChange: and -controlTextDidEndEditing:. You should call this method from your own implementation of the methods above if your own object, instead of the MOCompletionManager, is the delegate of the text view or control doing the completion.
 */
- (void)dumpCompletionState;

/*!
 @method doCompletionInTextView:startLimit:basePath:
 @abstract Perform completion.
 @discussion This method is the main entry point for MOCompletionManager. It is called automatically from MOCompletionManager's implementation of -textView:doCommandBySelector: and -control:textView:doCommandBySelector: if the selector passed in is -complete:. You should call this method from your own implementation of the methods above if your own object, instead of the MOCompletionManager, is the delegate of the text view or control doing the completion.

 This method relies on state stored by the MOCompletionManager and on the receiver's MOCompletionStrategy instances to perform its job. The first thing it does is check if any existing state has become stale because the textView, selection range, or basePath have changed since the last completion. If the existing state is stale, it is dumped by calling -dumpCompletionState. Next, if there's no stored state (either because it was just dumped or because there just wasn't any), the proper prefix completion string is calculated and then the MOCompletionStrategy instances are given a chance, in order, to come up with possible completions. The first MOCompletionStrategy that returns any completions is the one that gets used.

 Finally, a completion is chosen and inserted into the text view at the selection. For the first completion after new completions have been calculated, the completion used is the longest common prefix of all the possible completions. Subsequent completions will cycle through the possible completions.
 @param textView The NSTextView to do the completion in.
 @param startLimit Usually 0, this allows specifying a backwards limit when scanning the text for a suitable completion prefix.
 @param basePath This is simply passed through to the MOCompletionStrategy instances. It is normally used for path-based completion to provide a base to evaluate relative paths against. In MOCompletionManager's implementations of -textView:doCommandBySelector: and -control:textView:doCommandBySelector:, the basePath passed to this method is nil.
 */
- (void)doCompletionInTextView:(NSTextView *)textView startLimit:(unsigned)startLimit basePath:(NSString *)basePath;

/*!
 @method setCompleteWords:
 @abstract Sets whether completion uses word boundaries or the entire text before the selection as the match prefix.
 @discussion Sets whether completion uses word boundaries or the entire text before the selection as the match prefix. YES by default. If YES, completion is done by word (where "word" means all characters from the selection back to the first whitespace character prior to the selection), if NO completion always uses the whole text (back to startLimit).  It is a good idea to set this to NO for text fields that hold a single path since it lets the completion work on paths with spaces in them. 
 @param flag Whether to parse match prefixes using word boundaries.
 */
- (void)setCompleteWords:(BOOL)flag;

/*!
 @method completeWords
 @abstract Returns whether completion uses word boundaries or the entire text before the selection as the match prefix.
 @discussion Returns whether completion uses word boundaries or the entire text before the selection as the match prefix. YES by default. If YES, completion is done by word (where "word" means all characters from the selection back to the first whitespace character prior to the selection), if NO completion always uses the whole text (back to startLimit).  It is a good idea to set this to NO for text fields that hold a single path since it lets the completion work on paths with spaces in them.
 @result Whether to parse match prefixes using word boundaries.
 */
- (BOOL)completeWords;

/*!
 @method textDidChange:
 @abstract NSTextView delegate method, dumps completion state.
 @discussion This NSTextView delegate method is implemented in case the MOCompletionManager is used directly as the delegate of an NSTextView.  It is implemented to call -dumpCompletionState.
 @param notification The notification.
 */
- (void)textDidChange:(NSNotification *)notification;

/*!
 @method textDidEndEditing:
 @abstract NSTextView delegate method, dumps completion state.
 @discussion This NSTextView delegate method is implemented in case the MOCompletionManager is used directly as the delegate of an NSTextView.  It is implemented to call -dumpCompletionState.
 @param notification The notification.
 */
- (void)textDidEndEditing:(NSNotification *)notification;

/*!
 @method textView:doCommandBySelector:
 @abstract NSTextView delegate method, performs completion.
 @discussion This NSTextView delegate method is implemented in case the MOCompletionManager is used directly as the delegate of an NSTextView.  It is implemented to call -doCompletionInTextView:startLimit:basePath: if the selector is -complete. It passes textView as the textView, 0 as the startLimit, and nil for basePath.
 @param textView The textView.
 @param commandSelector The selector being performed. This method looks for -complete:.
 */
- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;

/*!
 @method controlTextDidChange:
 @abstract NSControl delegate method, dumps completion state.
 @discussion This NSControl delegate method is implemented in case the MOCompletionManager is used directly as the delegate of an NSControl.  It is implemented to call -dumpCompletionState.
 @param notification The notification.
 */
- (void)controlTextDidChange:(NSNotification *)notification;

/*!
 @method controlTextDidEndEditing:
 @abstract NSControl delegate method, dumps completion state.
 @discussion This NSControl delegate method is implemented in case the MOCompletionManager is used directly as the delegate of an NSControl.  It is implemented to call -dumpCompletionState.
 @param notification The notification.
 */
- (void)controlTextDidEndEditing:(NSNotification *)notification;

/*!
 @method control:textView:doCommandBySelector:
 @abstract NSControl delegate method, performs completion.
 @discussion This NSControl delegate method is implemented in case the MOCompletionManager is used directly as the delegate of an NSControl.  It is implemented to call -doCompletionInTextView:startLimit:basePath: if the selector is -complete. It passes textView as the textView, 0 as the startLimit, and nil for basePath.
 @param control The control.
 @param textView The textView.
 @param commandSelector The selector being performed. This method looks for -complete:.
 */
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
    
@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOCompletionManager__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
