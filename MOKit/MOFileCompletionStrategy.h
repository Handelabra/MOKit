// MOFileCompletionStrategy.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOFileCompletionStrategy
 @discussion Defines the MOFileCompletionStrategy class.
 */

// ABOUT MOFileCompletionStrategy
//
// This completion strategy does normal file/path completion.

#if !defined(__MOKIT_MOFileCompletionStrategy__)
#define __MOKIT_MOFileCompletionStrategy__ 1

#import <MOKit/MOKitDefines.h>
#import <MOKit/MOCompletionStrategy.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @class MOFileCompletionStrategy
 @abstract Implements path completion.
 @discussion MOFileCompletionStrategy implements straight-forward path completion. This class uses the basePath to provide a base to use when interpretting relative paths. There are several options to control the completion behavior including whether to append a "/" after directory completions and whether to append a space after filename completions.
*/
@interface MOFileCompletionStrategy : MOCompletionStrategy {
    @private
    struct __fcsFlags {
        unsigned int appendsSpaceOnFileMatch:1;
        unsigned int appendsSlashOnDirectoryMatch:1;
        unsigned int _reserved:30;
    } _fcsFlags;
}

/*!
 @method appendsSpaceOnFileMatch
 @abstract Returns whether a space should be appended after a non-directory completion.
 @discussion Returns whether a space should be appended after a non-directory completion. If YES, then after a complete plain filename completion, a space will be appended. Default is NO.
 @result Whether a space should be appended after a non-directory completion.
 */
- (BOOL)appendsSpaceOnFileMatch;

/*!
 @method setAppendsSpaceOnFileMatch:
 @abstract Sets whether a space should be appended after a non-directory completion.
 @discussion Sets whether a space should be appended after a non-directory completion. If YES, then after a complete plain filename completion, a space will be appended. Default is NO.
 @param flag Whether a space should be appended after a non-directory completion.
 */
- (void)setAppendsSpaceOnFileMatch:(BOOL)flag;

/*!
 @method appendsSlashOnDirectoryMatch
 @abstract Returns whether a slash should be appended after a directory completion.
 @discussion Returns whether a slash should be appended after a directory completion. If YES, then after a complete directory completion, a slash will be appended. Default is YES.
 @result Whether a slash should be appended after a directory completion.
 */
- (BOOL)appendsSlashOnDirectoryMatch;

/*!
 @method setAppendsSlashOnDirectoryMatch:
 @abstract Sets whether a slash should be appended after a directory completion.
 @discussion Sets whether a slash should be appended after a directory completion. If YES, then after a complete directory completion, a slash will be appended. Default is YES.
 @param flag Whether a slash should be appended after a directory completion.
 */
- (void)setAppendsSlashOnDirectoryMatch:(BOOL)flag;

/*!
 @method basePathFromProposedBasePath:path:
 @abstract Calculates the base path to use for the given path.
 @discussion Calculates the base path to use for the given path. This returns a standardized copy of basePath if path is not absolute, otherwise it returns nil.
 @param basePath The basePath passed into the main entry point methods.
 @param path The path prefix passed in as the prefix string to the main entry point methods.
 @result The base path to use for the given path.
 */
- (NSString *)basePathFromProposedBasePath:(NSString *)basePath path:(NSString *)path;

/*!
 @method addFilesMatchingPrefix:forChildrenOfDirectory:toMutableArray:
 @abstract Collects children of the given directory that start with the given prefix.
 @discussion Collects children of the given directory that start with the given prefix. Looking at every file in the given directory, finds any that start with the given prefix. Case-sensitive matches are looked for first, but if none are found, case-insensitive is allowed.
 @param partialName The partial name that the children are required to match. If this is nil, then all children are considered to match.
 @param dirPath The path to the directory to look in.
 @param matches An NSMutableArray to add any matches to.
 */
- (void)addFilesMatchingPrefix:(NSString *)partialName forChildrenOfDirectory:(NSString *)dirPath toMutableArray:(NSMutableArray *)matches;

/*!
 @method matchesForPrefixString:newPrefixString:basePath:
 @abstract Returns potential completions for a prefix path.
 @discussion This method first splits the prefix string into two pieces.  The first is the prefix up to the last path separator character and the second is the last (partial) path component. Then, the first part (the directory path) and the base path are passed to -basePathFromProposedBasePath:path: to find the effective basePath to use. Then, the effective basePath is prepended to the directory path and the result, along with the partial last path component are passed to -addFilesMatchingPrefix:forChildrenOfDirectory:toMutableArray: to generate the actual matches.  Finally, the new prefix string (the directory path) is assigned to *newStr.
 @param str The prefix string (path) that completions should be done against.
 @param newStr MOFileCompletionStrategy changes the prefix to remove the last partial path component.  Then the results array is returned containing full path components.
 @param basePath MOFileCompletionStrategy uses this as a path that serves as the base for evaluating relative paths.
 @result An array of path components starting with the given prefix path.
 */
- (NSArray *)matchesForPrefixString:(NSString *)path newPrefixString:(NSString **)newStr basePath:(NSString *)basePath;

/*!
 @method fullStringForPrefixString:completionString:isInitialPrefixMatch:basePath:
 @abstract Method for composing a prefix path and a completion.
 @discussion MOFileCompletionStrategy overrides this method to append the prefix and completion together as path components.  Also, if initialPrefixMatch is NO then the appendsSpaceOnFileMatch or appendsSlashOnDirectoryMatch setting is taken into account and a space or slash is added if needed.
 @param prefixStr The prefix string (directory path).
 @param completionStr The completion string (last path component).
 @param initialPrefixMatch If this is NO, then the appendsSpaceOnFileMatch or appendsSlashOnDirectoryMatch settings are taken into account and a space or slash may be appended to the resulting full string.
 @param basePath MOFileCompletionStrategy uses this as a path that serves as the base for evaluating relative paths.
 @result The composed completion which will be inserted into the NSTextView in place of the prefix.
 */
- (NSString *)fullStringForPrefixString:(NSString *)prefixStr completionString:(NSString *)completionStr isInitialPrefixMatch:(BOOL)initialPrefixMatch basePath:(NSString *)basePath;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOFileCompletionStrategy__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
