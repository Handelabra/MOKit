// MORESyntaxFormatter.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MORESyntaxFormatter
 @discussion Defines the MORESyntaxFormatter class.
 */

#if !defined(__MOKIT_MORESyntaxFormatter__)
#define __MOKIT_MORESyntaxFormatter__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
 @class MORESyntaxFormatter
 @abstract A formatter that validates input strings to ensure that they are valid regular expressions.
 @discussion A MORESyntaxFormatter attempts to compile its input strings as regular expressions.  If they compile then they are valid input and the resulting MORegularExpression is the "value", otherwise the string is not valid input.
*/
@interface MORESyntaxFormatter : NSFormatter {}

/*!
 @method stringForObjectValue:
 @abstract NSFormatter method for converting values to strings.
 @discussion NSFormatter method for converting values to strings. MORESyntaxFormatter accepts MORegularExpressions as values and converts them to their expression strings.
 @param obj The MORegularExpression object to be converted to a string.
 @result The expression string of the MORegularExpression value object.
 */
- (NSString *)stringForObjectValue:(id)obj;

/*!
 @method getObjectValue:forString:errorDescription:
 @abstract NSFormatter method for validating input strings and converting them to final values.
 @discussion NSFormatter method for validating input strings and converting them to final values. MORESyntaxFormatter attempts to create a MORegularExpression using the input string as the expression string.  If it succeeds, the resulting MORegularExpression is the value, otherwise, the input is not valid.
 @param obj A pointer to the output MORegularExpression.
 @param string The input string to be validated and converted.
 @param error A pointer to a pointer to an error string describing why the string was not valid.
 @result YES if the string can be compiled into a valid regular expression, NO if not.  If YES, then obj will be filled in with a pointer to the resulting MORegularExpression.  If NO, then error will be filled in with a pointer to an error string.
     */
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MORESyntaxFormatter__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
