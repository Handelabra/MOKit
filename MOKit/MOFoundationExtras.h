// MOFoundationExtras.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MOFoundationExtras
 @discussion This is a collection of categories on Foundation objects.  It has become a time honored tradition for any framework to have categories which add various useful non-primitive methods to Foundation.  Well, who is MOKit to buck this tradition?  Of course, for maximum utility, such non-primitive methods should always be implemented in terms of the primitives for the class.  Especially if it is a class cluster.  (This is generally the natural way to implement them anyway.) 
 */

#if !defined(__MOKIT_MOFoundationExtras__)
#define __MOKIT_MOFoundationExtras__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
/*!
 @category NSString(MOFoundationExtras)
 @abstract Additional NSString methods added by MOKit.
 @discussion Additional NSString methods added by MOKit.
 */
@interface NSString (MOFoundationExtras)

/*!
 @method MO_stringByReplacingBackslashWithSlash
 @abstract Returns a new string with all backslashes replaced by slashes.
 @discussion Returns a new string with all backslashes replaced by slashes. This method is useful for standardizing a path from Windows to a POSIX path.  Foundation now provides better facilities for this sort of thing, in general, but this method remains for compatibility.
 @result The new string with slashes instead of backslashes.
 */
- (NSString *)MO_stringByReplacingBackslashWithSlash;

@end

/*!
 @category NSMutableString(MOFoundationExtras)
 @abstract Additional NSMutableString methods added by MOKit.
 @discussion Additional NSMutableString methods added by MOKit.
 */
@interface NSMutableString (MOFoundationExtras)

/*!
 @method MO_standardizeEndOfLineToLF
 @abstract One of a collection of methods to standardize line endings.
 @discussion Converts all line endings in the receiver to unix-style linefeeds.  Any valid form of line ending is recognized including recognizing CRLF as a single line ending.
 */
- (void)MO_standardizeEndOfLineToLF;

/*!
 @method MO_standardizeEndOfLineToCRLF
 @abstract One of a collection of methods to standardize line endings.
 @discussion Converts all line endings in the receiver to Windows-style carriage return followed by linefeed.  Any valid form of line ending is recognized including recognizing CRLF as a single line ending.
 */
- (void)MO_standardizeEndOfLineToCRLF;

/*!
 @method MO_standardizeEndOfLineToCR
 @abstract One of a collection of methods to standardize line endings.
 @discussion Converts all line endings in the receiver to Mac-style carriage return.  Any valid form of line ending is recognized including recognizing CRLF as a single line ending.
 */
- (void)MO_standardizeEndOfLineToCR;

/*!
 @method MO_standardizeEndOfLineToParagraphSeparator
 @abstract One of a collection of methods to standardize line endings.
 @discussion Converts all line endings in the receiver to the Unicode paragraph separator character.  Any valid form of line ending is recognized including recognizing CRLF as a single line ending.
 */
- (void)MO_standardizeEndOfLineToParagraphSeparator;

/*!
 @method MO_standardizeEndOfLineToLineSeparator
 @abstract One of a collection of methods to standardize line endings.
 @discussion Converts all line endings in the receiver to the Unicode line separator character.  Any valid form of line ending is recognized including recognizing CRLF as a single line ending.
 */
- (void)MO_standardizeEndOfLineToLineSeparator;

@end

/*!
 @category NSArray(MOFoundationExtras)
 @abstract Additional NSArray methods added by MOKit.
 @discussion Additional NSArray methods added by MOKit.
 */
@interface NSArray (MOFoundationExtras)

/*!
 @method MO_longestCommonPrefixForStrings
 @abstract Returns longest common prefix of a list of strings.
 @discussion The receiving array should contain NSString objects.  This method will determine the longest common prefix for all the strings in the receiver and return it.
 @result The longest common prefix string.
 */
- (NSString *)MO_longestCommonPrefixForStrings;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MOFoundationExtras__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
