// MORegexFormatter.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MORegexFormatter
 @discussion Defines the MORegexFormatter class.
 */

#if !defined(__MOKIT_MORegexFormatter__)
#define __MOKIT_MORegexFormatter__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif

@class MORegularExpression;

/*!
 @class MORegexFormatter
 @abstract A formatter that uses MORegularExpression objects to validate input.
 @discussion A MORegexFormatter has a list of MORegularExpressions that it uses to validate input.  If a candidate string matches one of the expressions, it is valid.  In addition to the list of expressions the formatter can be set to specifically allow or disallow the empty string.

 For formatting output MORegexFormatter allows a format pattern that can reference subexpression matches in the regular expression(s) to provide a normalized version of any conforming input.
 */
@interface MORegexFormatter : NSFormatter <NSCopying, NSCoding> {
  @private
    NSMutableArray *_expressions;
    NSString *_formatPattern;
    unsigned _lastMatchedExpressionIndex;
    struct __rfFlags {
        unsigned int allowsEmptyString:1;
        unsigned int RESERVED:31;
    } _rfFlags;
    void *_reserved;
}

/*!
 @method initWithRegularExpressions:
 @abstract Init method.
 @discussion Designated Initializer. Initializes the receiver given an array of regular expressions.
 @param expressions An NSArray of MORegularExpressions.
 @result The initialized receiver or nil if an error occurred during initialization.
 */
- (id)initWithRegularExpressions:(NSArray *)expressions;

/*!
 @method initWithRegularExpression:
 @abstract Init method.
 @discussion Initializes the receiver with a single regular expressions.
 @param expression A MORegularExpression object.
 @result The initialized receiver or nil if an error occurred during initialization.
 */
- (id)initWithRegularExpression:(MORegularExpression *)expression;

/*!
 @method regularExpressions
 @abstract Returns the formatter's list of regular expressions.
 @discussion Returns the formatter's list of regular expressions.
 @result The list of regular expressions.
 */
- (NSArray *)regularExpressions;

/*!
 @method insertRegularExpression:atIndex:
 @abstract Inserts a new regular expression.
 @discussion Inserts a new regular expression into the formatter's list of expressions at the given index.
 @param expression The new MORegularExpression to insert.
 @param index The index where the new expression should be inserted.
 */
- (void)insertRegularExpression:(MORegularExpression *)expression atIndex:(unsigned)index;

/*!
 @method addRegularExpression:
 @abstract Adds a new regular expression.
 @discussion Adds a new regular expression to the end of the formatter's list of expressions.
 @param expression The new MORegularExpression to add.
 */
- (void)addRegularExpression:(MORegularExpression *)expression;

/*!
 @method removeRegularExpressionAtIndex:
 @abstract Removes a regular expression.
 @discussion Removes the regular expression at the given index from the formatter's list of expressions.
 @param index The index of the expression to remove.
 */
- (void)removeRegularExpressionAtIndex:(unsigned)index;

/*!
 @method replaceRegularExpressionAtIndex:withRegularExpression:
 @abstract Replaces a regular expression.
 @discussion Replaces a regular expression in the formatter's list of expressions at the given index with a new regular expression.
 @param index The index of the expression to be replaced.
 @param expression The new MORegularExpression to replace the old one with.
 */
- (void)replaceRegularExpressionAtIndex:(unsigned)index withRegularExpression:(MORegularExpression *)expression;

/*!
 @method allowsEmptyString
 @abstract Returns whether empty strings are allowed as valid input.
 @discussion Returns whether empty strings are allowed as valid input.
 @result YES if the formatter allows empty strings, NO if not.
 */
- (BOOL)allowsEmptyString;

/*!
 @method setAllowsEmptyString:
 @abstract Sets whether empty strings are allowed as valid input.
 @discussion Sets whether empty strings are allowed as valid input.
 @param flag YES if empty strings should be allowed, NO if not.
 */
- (void)setAllowsEmptyString:(BOOL)flag;

/*!
 @method formatPattern
 @abstract Returns the format pattern for the formatter.
 @discussion Returns the format pattern for the formatter.  The format pattern is used to format the output text from the formatter.  See the -setFormatPattern: documentation for details about the syntax of the pattern.
 @result The format pattern string.
 */
- (NSString *)formatPattern;

/*!
 @method setFormatPattern:
 @abstract Sets the format pattern for the formatter.
 @discussion Sets the format pattern for the formatter. The format pattern is used to format the output text from the formatter. It allows the formatter to normalize the format of input values. The string can use "%#" where "#" is a subexpression index.  For example, if you have a telephone number formatter which matches with subexpressions for area code, prefix and number, you can reformat entered phone numbers to a standard format with something like "(%1) %2-%3".  If the formatter has multiple expressions, they all need to have the same subexpressions.  The default format pattern is "%0" which just means the whole matched string.
 @param pattern The format pattern string.
 */
- (void)setFormatPattern:(NSString *)pattern;

/*!
 @method validateString:matchedExpressionIndex:
 @abstract Checks a string against the regular expression list.
 @discussion This method is automatically invoked by the -getObjectValue:forString:errorDescription: method.  You should not need to call it directly, but subclasses can override it.  This method should take the -allowsEmptyString setting into account.  This method is responsible for validating input strings and for identifying which regular expression of the formatter matched the string if it is valid.  MORegexFormatter implements this to check for empty string, and if the string is empty, check whether it is valid or not using the -allowsEmptyString setting (if the string is empty and valid, the matchedIndex is set to NSNotFound).  If the string is not empty, it is checked against the formatters regular expressions until a match is found or all the expressions are tested.
 @param string The candidate string.
 @param matchedIndex A pointer to an unsigned int that will be set to the index of the matched regular expression if the return value is YES.
 @result YES if the string matches one of the formatter's regular expressions, NO otherwise.
 */
- (BOOL)validateString:(NSString *)string matchedExpressionIndex:(unsigned *)matchedIndex;

/*!
 @method objectForValidatedString:matchedExpressionIndex:
 @abstract Formats a valid string into its final object value.
 @discussion This method is automatically invoked by the -getObjectValue:forString:errorDescription: method.  You should not need to call it directly, but subclasses can override it.  If the string is empty and valid, the matchedIndex parameter will be NSNotFound.  This method is responsible for formatting or converting a valid string into its final form object value.  MORegexFormatter implements this by using the -formatPattern to construct a final string value.  A subclass might override this to, for example, convert a conforming phone number into an instance of a PhoneNumber class.  Overriding this method to do final conversion is easier than fully overriding -getObjectValue:forString:errorDescription:.
 @param string The validated string.
 @param matchedIndex The index of the matched regular expression (or NSNotFound is the string is the empty string).
 @result The final object value for the given validated string.
 */
- (id)objectForValidatedString:(NSString *)string matchedExpressionIndex:(unsigned)matchedIndex;

/*!
 @method stringForObjectValue:
 @abstract NSFormatter method for converting values to strings.
 @discussion NSFormatter method for converting values to strings. MORegexFormatter implements this simply to return the -description of the value.  In general, MORegexFormatter is used to validate strings not to convert them into other types.
 @param obj The object to be converted to a string.
 @result The string.
 */
- (NSString *)stringForObjectValue:(id)obj;

/*!
 @method getObjectValue:forString:errorDescription:
 @abstract NSFormatter method for validating input strings and converting them to final values.
 @discussion NSFormatter method for validating input strings and converting them to final values. MORegexFormatter implements this to test the candidate string against its list of regular expressions.  If it matches one of them, the string is valid. In this case, the formatPattern of the formatter is used to create an output string.
 @param obj A pointer to the output string, formatted according to the formatPattern.
 @param string The input string to be validated and converted.
 @param error A pointer to a pointer to an error string describing why the string was not valid.
 @result YES if the string matches one of the formatter's regular expressions, NO if not.  If YES, then obj will be filled in with a pointer to the resulting output string.  If NO, then error will be filled in with a pointer to an error string.
 */
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error;

/*!
 @method lastMatchedExpression
 @abstract Returns the last regular expression that matched an input string.
 @discussion Returns the last regular expression that matched an input string (or nil if the last input did not match any expression).  This can be useful to retrieve the expression so subexpressions can be extracted or further matching can be done based on which regular expression the input matched.  A subclass might use this to be able to reason about how to go on to convert the input value to a value of a different class.
 @result The last regular expression that matched an input string (or nil if the last input did not match any expression).
 */
- (MORegularExpression *)lastMatchedExpression;

@end

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MORegexFormatter__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
