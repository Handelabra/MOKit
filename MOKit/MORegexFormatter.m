// MORegexFormatter.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MORegexFormatter.h>
#import <MOKit/MORegularExpression.h>
#import <MOKit/MORuntimeUtilities.h>
#import <MOKit/MOAssertions.h>

typedef enum {
    MOInitialVersion = 1,
} MOClassVersion;

static const MOClassVersion MOCurrentClassVersion = MOInitialVersion;

@implementation MORegexFormatter

+ (void)initialize {
    // Set the version.  Load classes, and init class variables.
    if (self == [MORegexFormatter class])  {
        [self setVersion:MOCurrentClassVersion];
    }
}

- (id)initWithRegularExpressions:(NSArray *)expressions {
    self = [super init];
    if (self) {
        if (expressions) {
            BOOL ok = NO;
            
            if ([expressions isKindOfClass:[NSArray class]]) {
                unsigned i, c = [expressions count];
                ok = YES;
                for (i=0; i<c; i++) {
                    if (![[expressions objectAtIndex:i] isKindOfClass:[MORegularExpression class]]) {
                        ok = NO;
                        break;
                    }
                }
            }
            if (!ok) {
                [self release];
                return nil;
            }
            
            _expressions = [[NSMutableArray allocWithZone:[self zone]] initWithArray:expressions];
        } else {
            _expressions = nil;
        }
        _lastMatchedExpressionIndex = NSNotFound;
        _rfFlags.allowsEmptyString = YES;
        [self setFormatPattern:nil];
    }

    return self;
}

- (id)initWithRegularExpression:(MORegularExpression *)expression {
    return [self initWithRegularExpressions:(expression ? [NSArray arrayWithObject:expression] : nil)];
}

- (id)init {
    return [self initWithRegularExpressions:nil];
}

- (void)dealloc {
    [_expressions release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    MORegexFormatter *copyObj = [super copyWithZone:zone];
    if (copyObj) {
        copyObj->_expressions = [_expressions copyWithZone:zone];
        copyObj->_lastMatchedExpressionIndex = NSNotFound;
        copyObj->_rfFlags.allowsEmptyString = _rfFlags.allowsEmptyString;
        copyObj->_formatPattern = [_formatPattern copyWithZone:zone];
    }

    return copyObj;
}

#define EXPRESSIONS_KEY @"com.lorax.MORegexFormatter.expressions"
#define ALLOWS_EMPTY_STRING_KEY @"com.lorax.MORegexFormatter.allowsEmptyString"
#define FORMAT_PATTERN_KEY @"com.lorax.MORegexFormatter.formatPattern"

- (void)encodeWithCoder:(NSCoder *)coder {    
    [super encodeWithCoder:coder];

    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_expressions forKey:EXPRESSIONS_KEY];
        [coder encodeBool:(_rfFlags.allowsEmptyString ? YES : NO) forKey:ALLOWS_EMPTY_STRING_KEY];
        [coder encodeObject:_formatPattern forKey:FORMAT_PATTERN_KEY];
    } else {
        BOOL tempBool;
        [coder encodeObject:_expressions];
        tempBool = _rfFlags.allowsEmptyString;
        [coder encodeValueOfObjCType:"C" at:&tempBool];
        [coder encodeObject:_formatPattern];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if ([coder allowsKeyedCoding]) {
        NSArray *exps = [coder decodeObjectForKey:EXPRESSIONS_KEY];
        if (exps) {
            _expressions = [[NSMutableArray allocWithZone:[self zone]] initWithArray:exps];
        } else {
            _expressions = nil;
        }
        if ([coder containsValueForKey:ALLOWS_EMPTY_STRING_KEY]) {
            _rfFlags.allowsEmptyString = [coder decodeBoolForKey:ALLOWS_EMPTY_STRING_KEY];
        } else {
            _rfFlags.allowsEmptyString = YES;
        }
        [self setFormatPattern:[coder decodeObjectForKey:FORMAT_PATTERN_KEY]];
    } else {
        unsigned classVersion = [coder versionForClassName:@"MORegexFormatter"];

        if (classVersion > MOCurrentClassVersion)  {
            NSLog(@"%@: class version %u cannot read instances archived with version %u", MOFullMethodName(self, _cmd), MOCurrentClassVersion, classVersion);
            [self release];
            return nil;
        }

        if (classVersion >= MOInitialVersion) {
            BOOL tempBool;
            _expressions = [[coder decodeObject] retain];
            [coder decodeValueOfObjCType:"C" at:&tempBool];
            _rfFlags.allowsEmptyString = tempBool;
            [self setFormatPattern:[coder decodeObject]];
        }
    }
    _lastMatchedExpressionIndex = NSNotFound;
    return self;
}

- (NSArray *)regularExpressions {
    return _expressions;
}

- (void)insertRegularExpression:(MORegularExpression *)expression atIndex:(unsigned)index {
    MOAssertClass(expression, MORegularExpression);
    MOParameterAssert(index <= [_expressions count]);
    
    if (!_expressions) {
        _expressions = [[NSMutableArray allocWithZone:[self zone]] init];
    }
    [_expressions insertObject:expression atIndex:index];
}

- (void)addRegularExpression:(MORegularExpression *)expression {
    MOAssertClass(expression, MORegularExpression);

    [self insertRegularExpression:expression atIndex:(_expressions ? [_expressions count] : 0)];
}

- (void)removeRegularExpressionAtIndex:(unsigned)index {
    MOParameterAssert(index < [_expressions count]);

    if (_expressions) {
        [_expressions removeObjectAtIndex:index];
    }
}

- (void)replaceRegularExpressionAtIndex:(unsigned)index withRegularExpression:(MORegularExpression *)expression {
    MOParameterAssert(index < [_expressions count]);
    MOAssertClass(expression, MORegularExpression);

    if (!_expressions || ([_expressions count] <= index)) {
        [NSException raise:NSRangeException format:@"*** %@: array index beyond end of array.", MOFullMethodName(self, _cmd)];
    }
    [_expressions replaceObjectAtIndex:index withObject:expression];
}

- (BOOL)allowsEmptyString {
    return _rfFlags.allowsEmptyString;
}

- (void)setAllowsEmptyString:(BOOL)flag {
    _rfFlags.allowsEmptyString = flag;
}

- (NSString *)formatPattern {
    return _formatPattern;
}

- (void)setFormatPattern:(NSString *)pattern {
    MOAssertStringOrNil(pattern);

    if (pattern != _formatPattern) {
        [_formatPattern release];
        _formatPattern = [pattern copyWithZone:[self zone]];
    }
}

- (NSString *)stringForObjectValue:(id)obj {
    return [obj description];
}

- (BOOL)validateString:(NSString *)string matchedExpressionIndex:(unsigned *)matchedIndex {
    MOAssertStringOrNil(string);
    MOParameterAssert(matchedIndex != NULL);

    // First check empty string case
    if (!string || [string isEqualToString:@""]) {
        // Empty string, let that setting rule.
        if ([self allowsEmptyString]) {
            *matchedIndex = NSNotFound;
            return YES;
        } else {
            return NO;
        }
    }

    // Now check expressions
    if (_expressions) {
        unsigned i, c = [_expressions count];
        for (i=0; i<c; i++) {
            if ([[_expressions objectAtIndex:i] matchesString:string]) {
                if (matchedIndex) {
                    *matchedIndex = i;
                }
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

- (id)objectForValidatedString:(NSString *)string matchedExpressionIndex:(unsigned)matchedIndex {
    MOAssertStringOrNil(string);
    MOParameterAssert((matchedIndex == NSNotFound) || (matchedIndex < [[self regularExpressions] count]));
    
    if ([self allowsEmptyString] && [string isEqualToString:@""]) {
        return [[string copyWithZone:[self zone]] autorelease];
    } else {
        NSString *formatPattern = [self formatPattern];
        if (formatPattern) {
            NSRange searchRange = NSMakeRange(0, [formatPattern length]);
            NSRange percentRange;

            percentRange = [formatPattern rangeOfString:@"%" options:0 range:searchRange];

            if (percentRange.length > 0) {
                NSMutableString *buffer = [formatPattern mutableCopyWithZone:[self zone]];
                int locationOffset = 0;

                while (percentRange.length > 0) {
                    if ((percentRange.location > 0) && ([formatPattern characterAtIndex:percentRange.location - 1] == (unichar)'\\')) {
                        [buffer replaceCharactersInRange:NSMakeRange(percentRange.location - 1 + locationOffset, 1) withString:@""];
                        locationOffset -= 1;
                    } else {
                        // Might be a subexpression format sequence
                        if (percentRange.location + 1 < NSMaxRange(searchRange)) {
                            unichar digit = [formatPattern characterAtIndex:percentRange.location + 1];
                            unsigned subexpIndex = 0;
                            BOOL badIndex = NO;
                            
                            if (digit == (unichar)'{') {
                                // It looks like the extended syntax for subexpressions.
                                percentRange.length++;
                                unsigned scanIndex = percentRange.location + 2;
                                while (scanIndex < NSMaxRange(searchRange)) {
                                    digit = [formatPattern characterAtIndex:scanIndex];
                                    scanIndex++;
                                    percentRange.length++;
                                    if (digit == (unichar)'}') {
                                        break;
                                    } else if ((digit >= (unichar)'0') && (digit <= (unichar)'9')) {
                                        subexpIndex *= 10;
                                        subexpIndex += digit - (unichar)'0';
                                    } else {
                                        // Back off the percent range to just the percent character again and just skip it.
                                        percentRange.length = 1;
                                        badIndex = YES;
                                        break;
                                    }
                                }
                                
                            } else if ((digit >= (unichar)'0') && (digit <= (unichar)'9')) {
                                // It is a simple subexpression.
                                subexpIndex = digit - (unichar)'0';
                                percentRange.length++;
                            }

                            // If we have a good subexpIndex, do the substitution.
                            if (!badIndex && (subexpIndex < MO_REGEXP_MAX_SUBEXPRESSIONS)) {
                                NSString *subexp = [[[self regularExpressions] objectAtIndex:matchedIndex] substringForSubexpressionAtIndex:subexpIndex inString:string];
                                [buffer replaceCharactersInRange:NSMakeRange(percentRange.location + locationOffset, percentRange.length) withString:(subexp ? subexp : @"")];
                                locationOffset += [subexp length] - percentRange.length;
                            }
                        }
                    }

                    searchRange = NSMakeRange(NSMaxRange(percentRange), NSMaxRange(searchRange) - NSMaxRange(percentRange));
                    percentRange = [formatPattern rangeOfString:@"%" options:0 range:searchRange];
                }

                return [buffer autorelease];
            } else {
                return [[formatPattern copyWithZone:[self zone]] autorelease];
            }
        } else {
            return [[string copyWithZone:[self zone]] autorelease];
        }
    }
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error {
    MOAssertStringOrNil(string);
    
    unsigned matchedIndex;
    BOOL retval;
    
    // Reset the last match ivar
    _lastMatchedExpressionIndex = NSNotFound;

    if (error) {
        *error = nil;
    }

    if ([self validateString:string matchedExpressionIndex:&matchedIndex]) {
        _lastMatchedExpressionIndex = matchedIndex;
        retval = YES;
    } else {
        if (error) {
            if ((!string || [string isEqualToString:@""]) && ![self allowsEmptyString]) {
                *error = [NSString localizedStringWithFormat:NSLocalizedStringFromTableInBundle(@"Proposed value '' failed to format because the formatter does not allow empty strings.", @"MOKit", [NSBundle bundleForClass:[self class]], @"Error string for MORegexFormatter.")];
            } else if ([_expressions count] > 1) {
                *error = [NSString localizedStringWithFormat:NSLocalizedStringFromTableInBundle(@"Proposed value '%@' failed to format because it did not match the formatter's regular expressions.", @"MOKit", [NSBundle bundleForClass:[self class]], @"Error string for MORegexFormatter."), string];
            } else if ([_expressions count] == 1) {
                *error = [NSString localizedStringWithFormat:NSLocalizedStringFromTableInBundle(@"Proposed value '%@' failed to format because it did not match the formatter's regular expression.", @"MOKit", [NSBundle bundleForClass:[self class]], @"Error string for MORegexFormatter."), string];
            } else {
                *error = [NSString localizedStringWithFormat:NSLocalizedStringFromTableInBundle(@"Proposed value '%@' failed to format because formatter has no expressions to match.", @"MOKit", [NSBundle bundleForClass:[self class]], @"Error string for MORegexFormatter."), string];
            }
        }
        retval = NO;
    }

    // Format the string
    if (retval && obj) {
        NSString *formattedObj = [self objectForValidatedString:string matchedExpressionIndex:_lastMatchedExpressionIndex];
        *obj = formattedObj;
    }
    
    return retval;
}

- (MORegularExpression *)lastMatchedExpression {
    if (_lastMatchedExpressionIndex != NSNotFound) {
        return [_expressions objectAtIndex:_lastMatchedExpressionIndex];
    } else {
        return nil;
    }
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
