// MORegularExpression.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MORegularExpression
 @discussion Defines the MORegularExpression class.
 */

#if !defined(__MOKIT_MORegularExpression__)
#define __MOKIT_MORegularExpression__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @defined MO_REGEXP_MAX_SUBEXPRESSIONS
 @discussion The maximum number of subexpressions that MORegularExpression can handle.
 */
#define MO_REGEXP_MAX_SUBEXPRESSIONS 20

/*!
 @class MORegularExpression
 @abstract Represents a regular expression which can be matched against candidate strings.
 @discussion MORegularExpression objects are initialized from a pattern string in something similar to unix-style regular expression syntax (such as used in egrep) and can be used to match other strings against the pattern. In addition to the pattern string you can specify whether the expression should be case-insensitive. They are immutable. If you need to match another pattern, make another MORegularExpression.

 The implementation is almost entirely provided by Henry Spencer's Uniocode-based regular expression package which is used by the MOKit framework in a (slightly) modified form and was originally taken from TCL (8.3.2). The unmodified code can be found in the HSRegexp group/folder in the Readmes and Notes group of the MOKit_2 project. (Using FileMerge to compare the original HSRegexp folder with the modified MORegexp folder will show the exact changes made.)

 MORegularExpression uses the Advanced Regular Expression (ARE) syntax.  This is basically a further extension of POSIX Extended Regular Expression (ERE) syntax (basically, what egrep uses).  Details on the syntax can be found in the document <a href=../../../../DocumentationResources/RESyntax.rtf target=top>RESyntax.rtf</a> included with the MOKit framework (Safari and OmniWeb will show this RTF document directly in the browser, other browsers may need to use a helper application).

 In addition to simply matching candidate strings, MORegularExpressions can take advantage of the subexpressions defined within the regular expression and can return the matching ranges or substrings for any subexpression from a matching candidate string.
 */
@interface MORegularExpression : NSObject <NSCopying, NSCoding> {
    @private
    NSString *_expressionString;
    NSString *_lastString;
    NSRange _lastSubexpressionRanges[MO_REGEXP_MAX_SUBEXPRESSIONS];
    void *_compiledExpression;
    struct __reFlags {
        unsigned int ignoreCase:1;
        unsigned int lastStringWasMatch:1;
        unsigned int lastMatchWasCached:1;
        unsigned int RESERVED:29;
    } _reFlags;
}

/*!
 @method validExpressionString:
 @abstract Syntax checks a regular expression string.
 @discussion Given a candidate regular expression string, this method attempts to compile it into a regular expression to see if it is valid.  In effect it syntax checks regular expression strings.
 @param expressionString The candidate regular expression string.
 @result YES if the expressionString is a valid regular expression, NO otherwise.
 */
+ (BOOL)validExpressionString:(NSString *)expressionString;

/*!
 @method regularExpressionWithString:ignoreCase:
 @abstract Convenience factory for creating a new regular expression instance.
 @discussion Given a regular expression string and a flag indicating whether the expression should be case insensitive, this method returns a newly allocated, autoreleased MORegularExpression.
 @param expressionString The regular expression string.
 @param ignoreCaseFlag Whether the expression object should ignore case differences when matching candidate strings.
 @result The new autoreleased MORegularExpression, or nil if expressionString is not a valid regular expression string.
 */
+ (id)regularExpressionWithString:(NSString *)expressionString ignoreCase:(BOOL)ignoreCaseFlag;

/*!
 @method regularExpressionWithString:
 @abstract Convenience factory for creating a new regular expression instance.
 @discussion Given a regular expression string this method returns a newly allocated, autoreleased MORegularExpression. The new expression will be case sensitive.
 @param expressionString The regular expression string.
 @result The new autoreleased MORegularExpression, or nil if expressionString is not a valid regular expression string.
 */
+ (id)regularExpressionWithString:(NSString *)expressionString;

/*!
 @method initWithExpressionString:ignoreCase:
 @abstract Init method. Designated Initializer.
 @discussion This is the Designated Initializer for the MORegularExpression class.  Given a regular expression string and a flag indicating whether the expression should be case insensitive, this method initializes the receiver.
 @param expressionString The regular expression string.
 @param ignoreCaseFlag Whether the expression object should ignore case differences when matching candidate strings.
 @result The initialized MORegularExpression, or nil if expressionString is not a valid regular expression string.
 */
- (id)initWithExpressionString:(NSString *)expressionString ignoreCase:(BOOL)ignoreCaseFlag;

/*!
 @method initWithExpressionString:
 @abstract Init method.
 @discussion This simply calls the Designated Initializer with ignoreCase:NO.  Given a regular expression string this method initializes the receiver. The new expression will be case sensitive.
 @param expressionString The regular expression string.
 @result The initialized MORegularExpression, or nil if expressionString is not a valid regular expression string.
 */
- (id)initWithExpressionString:(NSString *)expressionString;

/*!
 @method expressionString
 @abstract Returns the regular expression string.
 @discussion Returns the regular expression string that was used to initialize the receiver.
 @result The regular expression string.
 */
- (NSString *)expressionString;

/*!
 @method ignoreCase
 @abstract Returns whether the receiver is case insensitive.
 @discussion Returns whether the receiver is case insensitive.
 @result YES if the receiver is case insensitive, NO if not.
 */
- (BOOL)ignoreCase;


/*!
 @method matchesCharacters:inRange:
 @abstract Check whether a specific range in a candidate character buffer matches the regular expression.
 @discussion Given a candidate character buffer and a range to match in, this method will return whether or not it matches the regular expression.  This is the primitive matching method.  All others call through to this one eventually.
 @param candidateChars The unichar buffer to test against the regular expression.
 @param searchRange The range of the buffer to use for matching.
 @result YES if the searchRange of the candidateChars matches the expression, NO if not.
 */
- (BOOL)matchesCharacters:(const unichar *)candidateChars inRange:(NSRange)searchRange;

/*!
 @method matchesString:inRange:
 @abstract Check whether a specific range in a candidate string matches the regular expression.
 @discussion Given a candidate string and a range to match in, this method will return whether or not it matches the regular expression.  This extracts a unichar buffer and calls -matchesCharacters:inRange:.
 @param candidate The string to test against the regular expression.
 @param searchRange The range of the string to use for matching.
 @result YES if the searchRange of the string matches the expression, NO if not.
 */
- (BOOL)matchesString:(NSString *)candidate inRange:(NSRange)searchRange;

/*!
 @method matchesString:
 @abstract Check whether a candidate string matches the regular expression.
 @discussion Given a candidate string, this method will return whether or not it matches the regular expression.  This method calls -matchesString:inRange: with a range encompassing the whole string.
 @param candidate The string to test against the regular expression.
 @result YES if the string matches the expression, NO if not.
 */
- (BOOL)matchesString:(NSString *)candidate;

/*!
 @method rangeForSubexpressionAtIndex:inCharacters:range:
 @abstract Retrieve a subexpression match range.
 @discussion Given a candidate character buffer and a range to match in and the index of a subexpression, this method will return the range from the candidate characters that matched the given subexpression index (if the string matches at all).
 @param index The index of the subexpression range to return.
 @param candidateChars The unichar buffer to test against the regular expression.
 @param searchRange The range of the buffer to use for matching.
 @result If the candidate characters match, the range of the subexpression match. If the candidate does not match, the range (NSNotFound, 0).
 */
- (NSRange)rangeForSubexpressionAtIndex:(unsigned)index inCharacters:(const unichar *)candidateChars range:(NSRange)searchRange;

/*!
 @method rangeForSubexpressionAtIndex:inString:range:
 @abstract Retrieve a subexpression match range.
 @discussion Given a candidate string and a range to match in and the index of a subexpression, this method will return the range from the candidate string that matched the given subexpression index (if the string matches at all).
 @param index The index of the subexpression range to return.
 @param candidate The string to test against the regular expression.
 @param searchRange The range of the string to use for matching.
 @result If the candidate string matches, the range of the subexpression match. If the candidate does not match, the range (NSNotFound, 0).
 */
- (NSRange)rangeForSubexpressionAtIndex:(unsigned)index inString:(NSString *)candidate range:(NSRange)searchRange;

/*!
 @method rangeForSubexpressionAtIndex:inString:
 @abstract Retrieve a subexpression match range.
 @discussion Given a candidate string and the index of a subexpression, this method will return the range from the candidate string that matched the given subexpression index (if the string matches at all).
 @param index The index of the subexpression range to return.
 @param candidate The string to test against the regular expression.
 @result If the candidate string matches, the range of the subexpression match. If the candidate does not match, the range (NSNotFound, 0).
 */
- (NSRange)rangeForSubexpressionAtIndex:(unsigned)index inString:(NSString *)candidate;

/*!
 @method substringForSubexpressionAtIndex:inString:
 @abstract Retrieve a subexpression match substring.
 @discussion Given a candidate string and the index of a subexpression, this method will return the substring from the candidate string that matched the given subexpression index (if the string matches at all).  The return value will be nil if the candidate does not match and the empty string if the candidate matches but the subexpression matched a zero-length range.  This is a convenience method that calls -rangeForSubexpressionAtIndex:inString: and then creates a substring from the range.  The convenience method is only implemented for the simple case of matching a whole NSString.  If you're matching within a sub-range or using unichar buffers, use the appropriate rangeForSubexpressionAtIndex:... API.
 @param index The index of the subexpression range to return.
 @param candidate The string to test against the regular expression.
 @result If the candidate string matches, the substring of the subexpression match. If the candidate does not match, the range, nil.
 */
- (NSString *)substringForSubexpressionAtIndex:(unsigned)index inString:(NSString *)candidate;

/*!
 @method rangesForSubexpressionsInCharacters:range:
 @abstract Retrieve all subexpression match ranges.
 @discussion Given a candidate character buffer and a range to match in, this method will return an array of ranges from the candidate characters that matched the subexpressions (if the string matches at all).  The range is MO_REGEXP_MAX_SUBEXPRESSIONS in length and any unused subexpressions will be {NSNotFound, 0}.  The returned array is valid only until the next match or subexpression operation on the receiver.  This method is useful when working with large candidate buffers and when you need to get information about multiple subexpressions.  MORegularExpression's caching makes repeated queries about a given string cheap, usually, but when the string is large, MORegularExpression does not cache (since the cost of caching starts to outweigh the benefit).  This API give you a way to get all the data you might need in one operation.
 @param candidateChars The unichar buffer to test against the regular expression.
 @param searchRange The range of the buffer to use for matching.
 @result If the candidate characters match, the array of subexpression match ranges.  If the candidate does not match, NULL.
 */
- (NSRange *)rangesForSubexpressionsInCharacters:(const unichar *)candidateChars range:(NSRange)searchRange;

/*!
 @method subexpressionsForString:
 @abstract Retrieve subexpression matches.
 @discussion Given a candidate string, this method will an array of all subexpression matches.

 This method should not be used and is included only for compatibility.  Use the rangeForSubexpression... or substringForSubexpression... methods instead which more accurately distinguish between the no-match case and the zero-length-match case.
 @result An array of the subexpression substrings.
 */
- (NSArray *)subexpressionsForString:(NSString *)candidate;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MORegularExpression__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
