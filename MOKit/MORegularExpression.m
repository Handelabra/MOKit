// MORegularExpression.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MORegularExpression.h>
#import <MOKit/MORegularExpression_Private.h>
#import <MOKit/MORuntimeUtilities.h>
#import <MOKit/MOAssertions.h>

typedef enum {
    MOInitialVersion = 1,
    MOIgnoreCaseVersion = 2,
} MOClassVersion;

static const MOClassVersion MOCurrentClassVersion = MOIgnoreCaseVersion;

@implementation MORegularExpression

+ (void)initialize {
    if (self == [MORegularExpression class])  {
        [self setVersion:MOCurrentClassVersion];
    }
}

+ (BOOL)validExpressionString:(NSString *)expressionString {
    MOAssertString(expressionString);
    
    BOOL isValid = NO;
    void *re;

    if (!expressionString) {
        isValid = NO;
    } else {
        re = MO_TestAndCompileExpressionString(expressionString, NO);
        if (re) {
            MO_FreeRegex(re);
            isValid = YES;
        }
    }
    return isValid;
}

+ (id)regularExpressionWithString:(NSString *)expressionString ignoreCase:(BOOL)ignoreCaseFlag {
    return [[[[self class] allocWithZone:NULL] initWithExpressionString:expressionString ignoreCase:ignoreCaseFlag] autorelease];
}

+ (id)regularExpressionWithString:(NSString *)expressionString {
    return [[[[self class] allocWithZone:NULL] initWithExpressionString:expressionString] autorelease];
}

- (id)initWithExpressionString:(NSString *)expressionString ignoreCase:(BOOL)ignoreCaseFlag {
    self = [super init];

    if (self) {
        BOOL isValid = NO;
        unsigned i;
        
        if (expressionString && [expressionString isKindOfClass:[NSString class]]) {
            _reFlags.ignoreCase = ignoreCaseFlag;
            _expressionString = [expressionString copyWithZone:[self zone]];
            _compiledExpression = MO_TestAndCompileExpressionString(_expressionString, _reFlags.ignoreCase);
            if (_compiledExpression) {
                isValid = YES;
            }
        }
        if (!isValid) {
            //NSLog(@"%@: argument '%@' is not a valid regular expression.  Check the syntax.", MOFullMethodName(self, _cmd), expressionString, [self class]);
            [self release];
            return nil;
        }

        for (i=0; i<MO_REGEXP_MAX_SUBEXPRESSIONS; i++) {
            _lastSubexpressionRanges[i] = NSMakeRange(NSNotFound, 0);
        }
    }

    return self;
}

- (id)initWithExpressionString:(NSString *)expressionString {
    return [self initWithExpressionString:expressionString ignoreCase:NO];
}

- (id)init {
    return [self initWithExpressionString:@"" ignoreCase:NO];
}

- (id)copyWithZone:(NSZone *)zone {
    if (zone == [self zone]) {
        return [self retain];
    } else {
        return [[[self class] allocWithZone:zone] initWithExpressionString:_expressionString ignoreCase:_reFlags.ignoreCase];
    }
}

- (void)dealloc {
    [_lastString release], _lastString = nil;
    if (_compiledExpression) {
        MO_FreeRegex(_compiledExpression);
        _compiledExpression = NULL;
    }
    [_expressionString release], _compiledExpression = nil;
    [super dealloc];
}

- (BOOL)isEqual:(id)otherObj {
    if (otherObj == self) {
        return YES;
    } else if (!otherObj) {
        return NO;
    } else if ([otherObj isKindOfClass:[MORegularExpression class]]) {
        return ((([self ignoreCase] == [otherObj ignoreCase]) && [[self expressionString] isEqualToString:[otherObj expressionString]]) ? YES : NO);
    } else {
        return NO;
    }
}

- (unsigned)hash {
    return [_expressionString hash];
}

- (NSString *)expressionString {
    return _expressionString;
}

- (BOOL)ignoreCase {
    return _reFlags.ignoreCase;
}

// We only cache the last attempt if it is relatively small.
#define CACHE_LIMIT 256

- (BOOL)matchesCharacters:(const unichar *)candidateChars inRange:(NSRange)searchRange {
    BOOL isMatch = NO;

    // First, see if we can use the cache.
    if ((searchRange.length < CACHE_LIMIT) && _lastString) {
        // !!!:mferris:20021218 Could be a bit more efficient memory-wise using CFStringCreateMutableWithExternalCharactersNoCopy() and keeping the tempStr around as an instance variable... this would avoid the alloc of the tempStr each time at the expense of keeping it around as an ivar.
        NSString *tempStr = [[NSString allocWithZone:[self zone]] initWithCharactersNoCopy:(unichar *)(candidateChars + searchRange.location) length:searchRange.length freeWhenDone:NO];
        BOOL sameString = [_lastString isEqualToString:tempStr];
        [tempStr release];
        if (sameString) {
            _reFlags.lastMatchWasCached = YES;
            return _reFlags.lastStringWasMatch;
        }
    }

    // Cache was not helpful.
    if (_lastString) {
        // Clear the cache.
        [_lastString release], _lastString = nil;
    }
    isMatch = MO_TestAndMatchCharactersInRangeWithExpression(candidateChars, searchRange, _compiledExpression, _lastSubexpressionRanges);
    
    // Cache the search string, if it is short enough.
    if (searchRange.length < CACHE_LIMIT) {
        _lastString = [[NSString allocWithZone:[self zone]] initWithCharacters:(unichar *)(candidateChars + searchRange.location) length:searchRange.length];
        _reFlags.lastStringWasMatch = isMatch;
    }

    _reFlags.lastMatchWasCached = NO;
    return isMatch;
}

#define STACK_BUFF_SIZE 256

- (BOOL)matchesString:(NSString *)candidate inRange:(NSRange)searchRange {
    MOAssertString(candidate);

    const unichar *nativeBuff = CFStringGetCharactersPtr((CFStringRef)candidate);

    // Try to be as cheap as possible.  If we can use the strings native backing, do it.  Otherwise, if the searchRange is small, extract into a stack buffer, and, finally, if neither of those works, malloc a buffer.
    if (nativeBuff) {
        // Got native unichars for the whole string.
        return [self matchesCharacters:nativeBuff inRange:searchRange];
    } else {
        unichar stackBuff[STACK_BUFF_SIZE];
        unichar *charBuff;
        BOOL isMatch;
        
        // Need to extract chars.
        if (searchRange.length <= STACK_BUFF_SIZE) {
            charBuff = stackBuff;
        } else {
            charBuff = malloc(searchRange.length * sizeof(unichar));
        }
        [candidate getCharacters:charBuff range:searchRange];
        
        // Do the match, but with a zero-based range since we extracted only the searchRange's characters.
        isMatch = [self matchesCharacters:charBuff inRange:NSMakeRange(0, searchRange.length)];

        if (searchRange.length > STACK_BUFF_SIZE) {
            free(charBuff);
        }

        if (isMatch && !_reFlags.lastMatchWasCached) {
            // Now fix the subexpression match locations offsetting by searchRange.location.
            unsigned i;
            for (i=0; i<MO_REGEXP_MAX_SUBEXPRESSIONS; i++) {
                if (_lastSubexpressionRanges[i].location != NSNotFound) {
                    _lastSubexpressionRanges[i].location += searchRange.location;
                }
            }
        }
    
        return isMatch;
    }
}

- (BOOL)matchesString:(NSString *)candidate {
    return [self matchesString:candidate inRange:NSMakeRange(0, [candidate length])];
}

- (NSRange)rangeForSubexpressionAtIndex:(unsigned)index inCharacters:(const unichar *)candidateChars range:(NSRange)searchRange {
    if (index > MO_REGEXP_MAX_SUBEXPRESSIONS) {
        [NSException raise:NSInvalidArgumentException format:@"*** %@: index '%u' is greater than the supported number of subexpressions (%d).", MOFullMethodName(self, _cmd), index, MO_REGEXP_MAX_SUBEXPRESSIONS];
    }
    if ([self matchesCharacters:candidateChars inRange:searchRange]) {
        return _lastSubexpressionRanges[index];
    } else {
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSRange)rangeForSubexpressionAtIndex:(unsigned)index inString:(NSString *)candidate range:(NSRange)searchRange {
    if (index > MO_REGEXP_MAX_SUBEXPRESSIONS) {
        [NSException raise:NSInvalidArgumentException format:@"*** %@: index '%u' is greater than the supported number of subexpressions (%d).", MOFullMethodName(self, _cmd), index, MO_REGEXP_MAX_SUBEXPRESSIONS];
    }
    if ([self matchesString:candidate inRange:searchRange]) {
        return _lastSubexpressionRanges[index];
    } else {
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSRange)rangeForSubexpressionAtIndex:(unsigned)index inString:(NSString *)candidate {
    // matchesString does the hard work (and avoids the hard work iff it can).  So let it do it and we'll just grab the info out of _lastSubexpressionRanges.
    if (index > MO_REGEXP_MAX_SUBEXPRESSIONS) {
        [NSException raise:NSInvalidArgumentException format:@"*** %@: index '%u' is greater than the supported number of subexpressions (%d).", MOFullMethodName(self, _cmd), index, MO_REGEXP_MAX_SUBEXPRESSIONS];
    }
    if ([self matchesString:candidate]) {
        return _lastSubexpressionRanges[index];
    } else {
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSString *)substringForSubexpressionAtIndex:(unsigned)index inString:(NSString *)candidate {
    NSRange subRange = [self rangeForSubexpressionAtIndex:index inString:candidate];
    if (subRange.location != NSNotFound) {
        return [candidate substringWithRange:subRange];
    } else {
        return nil;
    }
}

- (NSRange *)rangesForSubexpressionsInCharacters:(const unichar *)candidateChars range:(NSRange)searchRange {
    if ([self matchesCharacters:candidateChars inRange:searchRange]) {
        return _lastSubexpressionRanges;
    } else {
        return NULL;
    }
}

- (NSArray *)subexpressionsForString:(NSString *)candidate {
    // This method is provided mainly to maintain compatibility with prior versions of MOKit.

    if ([self matchesString:candidate]) {
        int i;
        NSMutableArray *tempArray = [NSMutableArray array];
        NSString *substring;

        for (i=0; i<MO_REGEXP_MAX_SUBEXPRESSIONS; i++) {
            substring = [self substringForSubexpressionAtIndex:i inString:candidate];
            [tempArray addObject:(substring ? substring : @"")];
        }
        return tempArray;
    } else {
        return nil;
    }
}

#define EXPRESSION_STRING_KEY @"com.lorax.MORegularExpression.expressionString"
#define IGNORE_CASE_KEY @"com.lorax.MORegularExpression.ignoreCase"

- (void)encodeWithCoder:(NSCoder *)coder {
    // Do not call super.  NSObject does not conform to NSCoding.

    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_expressionString forKey:EXPRESSION_STRING_KEY];
        [coder encodeBool:_reFlags.ignoreCase forKey:IGNORE_CASE_KEY];
    } else {
        char tmpIgnoreCase = _reFlags.ignoreCase;
        [coder encodeObject:_expressionString];
        [coder encodeValueOfObjCType:"c" at:&tmpIgnoreCase];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    // Do not call super.  NSObject does not conform to NSCoding.
    if ([coder allowsKeyedCoding]) {
        _expressionString = [[coder decodeObjectForKey:EXPRESSION_STRING_KEY] copyWithZone:[self zone]];
        if ([coder containsValueForKey:IGNORE_CASE_KEY]) {
            _reFlags.ignoreCase = [coder decodeBoolForKey:IGNORE_CASE_KEY];
        } else {
            _reFlags.ignoreCase = NO;
        }
    } else {
        unsigned classVersion = [coder versionForClassName:@"MORegularExpression"];

        if (classVersion > MOCurrentClassVersion)  {
            NSLog(@"%@: class version %u cannot read instances archived with version %u", MOFullMethodName(self, _cmd), MOCurrentClassVersion, classVersion);
            [self release];
            return nil;
        }
        if (classVersion >= MOInitialVersion) {
            unsigned i;

            _expressionString = [[coder decodeObject] copyWithZone:[self zone]];
            for (i=0; i<MO_REGEXP_MAX_SUBEXPRESSIONS; i++) {
                _lastSubexpressionRanges[i] = NSMakeRange(NSNotFound, 0);
            }
        }
        if (classVersion >= MOIgnoreCaseVersion) {
            char tmpIgnoreCase;
            [coder decodeValueOfObjCType:"c" at:&tmpIgnoreCase];
            _reFlags.ignoreCase = (tmpIgnoreCase ? YES : NO);
        }
    }
    _compiledExpression = MO_TestAndCompileExpressionString(_expressionString, _reFlags.ignoreCase);
    return self;
}

- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"<%@:0x%x:%@, %@>", [self class], (unsigned)self, [self expressionString], ([self ignoreCase] ? @"case insensitive" : @"case sensitive")];
    return desc;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
