// MOCompletionStrategy.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOCompletionStrategy
 @discussion Defines the MOCompletionStrategy class.
 */

#if !defined(__MOKIT_MOCompletionStrategy__)
#define __MOKIT_MOCompletionStrategy__ 1

#import <Cocoa/Cocoa.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @class MOCompletionStrategy
 @abstract Subclasses implement the actual completion logic for MOCompletionManager.
 @discussion MOCompletionStrategy is an abstract superclass. Subclasses of MOCompletionStrategy are used to define the actual completion behavior for a MOCompletionManager. MOCompletionStrategy subclasses must override one method and may optionally override a second as well. The required method to override is -matchesForPrefixString:newPrefixString:basePath: which should return the possible completions for the given prefix string. MOCompletionStrategy subclasses that need to glue together the prefix and the completions is special ways can override -fullStringForPrefixString:completionString:isInitialPrefixMatch:basePath: to do something more clever than simply appending the completion to the prefix.
 */
@interface MOCompletionStrategy : NSObject {}

/*!
 @method matchesForPrefixString:newPrefixString:basePath:
 @abstract The basic method for returning possible completions.
 @discussion This is the primary method that a MOCompletionStrategy must override. Given a prefix string and a base path (which is basically user-defined info passed in from the client of the MOCompletionManager), this method is responsible for figuring out possible completions and returning them in an array. The completion strings returned should not include the prefix. Composing the prefix with a possible completion is done separately.
 @param str The prefix string that completions should be done against.
 @param newStr A pointer to an NSString pointer. If the MOCompletionStrategy wants to modify the prefix string, it can do so by passing a new prefix string back through this pointer. If a MOCompletionStrategy does not assign into this pointer, the prefix string is left unchanged.
 @param basePath In general user-defined info passed in to MOCompletionManager and passed along to the MOCompletionStrategy. In practice this is often a path that is used for path-based completion as a base for evaluating relative paths.
 @result An array of NSStrings which are the possible completions for the given prefix string. Or nil if there are no completions.
 */
- (NSArray *)matchesForPrefixString:(NSString *)str newPrefixString:(NSString **)newStr basePath:(NSString *)basePath;

/*!
 @method fullStringForPrefixString:completionString:isInitialPrefixMatch:basePath:
 @abstract Method for composing a prefix and a completion.
 @discussion This method is responsible for creating the full string given a prefix string and a completion. The default implementation simply appends the completion string to the prefix string. Subclasses can override to do trickier kinds of combining.
 @param prefixStr The prefix string.
 @param completionStr The completion string (this is always one of the strings returned from a previous call to -matchesForPrefixString:newPrefixString:basePath:).
 @param initialPrefixMatch This is YES if the composition is being done on the prefix and the longest common prefix of all the possible completions. It is NO otherwise. Some subclasses may alter their behavior based on this information.
 @param basePath In general user-defined info passed in to MOCompletionManager and passed along to the MOCompletionStrategy. In practice this is often a path that is used for path-based completion as a base for evaluating relative paths.
 @result The composed completion which will be inserted into the NSTextView in place of the prefix.
 */
- (NSString *)fullStringForPrefixString:(NSString *)prefixStr completionString:(NSString *)completionStr isInitialPrefixMatch:(BOOL)initialPrefixMatch basePath:(NSString *)basePath;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOCompletionStrategy__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
