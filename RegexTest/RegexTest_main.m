// RegexTest_main.m
// MOKit
// RegexTest
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <Foundation/Foundation.h>
#import <MOKit/MOKit.h>

#define DEFAULT_DATA_FILE @"RegexTestData.plist"

static NSArray *readTestData() {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    unsigned argCount = [args count];
    NSString *filePath;
    NSString *fileString;
    NSArray *testCases;

    if (argCount == 1) {
        // By default we look for a file with a standard name in the same directory as the test executable.
        filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:DEFAULT_DATA_FILE];
    } else if (argCount == 2) {
        filePath = [args objectAtIndex:1];
    } else {
        NSLog(@"usage: %@ [<dataFile>]\n\tYou must supply a file of test cases.", [[NSProcessInfo processInfo] processName]);
        exit(1);
    }

    fileString = [NSString stringWithContentsOfFile:filePath];
    if (!fileString) {
        NSLog(@"%@ Could not load data file '%@'", [[NSProcessInfo processInfo] processName], filePath);
        exit(1);
    }
    testCases = [fileString propertyList];
    if (!testCases || ![testCases isKindOfClass:[NSArray class]]) {
        NSLog(@"%@ Could not parse data file '%@'.  The data file must be an NSArray of test cases in property list format.  Each test case is a sub-array with five string objects that define the test case.", [[NSProcessInfo processInfo] processName], [args objectAtIndex:1]);
        exit(1);
    }
    return testCases;
}

static NSString *substituteSubexpressions(NSString *str, MORegularExpression *regex, NSString *candidate) {
    NSMutableString *result = [NSMutableString string];
    unsigned startIndex, curIndex, stopIndex = [str length];
    unichar curChar;
    NSString *substring;
    
    startIndex = curIndex = 0;
    while (curIndex < stopIndex) {
        curChar = [str characterAtIndex:curIndex];
        if (curChar == '\\') {
            if (curIndex + 1 < stopIndex) {
                curIndex++;
                curChar = [str characterAtIndex:curIndex];
                if ((curChar >= '0') && (curChar < '9')) {
                    // substitute a subexpression.
                    [result appendString:[str substringWithRange:NSMakeRange(startIndex, curIndex - 1 - startIndex)]];
                    startIndex = curIndex + 1;
                    substring = [regex substringForSubexpressionAtIndex:(curChar - '0') inString:candidate];
                    if (substring) {
                        [result appendString:substring];
                    }
                    // References to non-existent subexpressions by \n is allowed in regsub.  Nothing is substituted.
                } else {
                    [result appendString:[str substringWithRange:NSMakeRange(startIndex, curIndex - 1 - startIndex)]];
                    [result appendFormat:@"%c", (char)curChar];
                    startIndex = curIndex + 1;
                }
            }
        } else if (curChar == '&') {
            [result appendString:[str substringWithRange:NSMakeRange(startIndex, curIndex - startIndex)]];
            startIndex = curIndex + 1;
            substring = [regex substringForSubexpressionAtIndex:0 inString:candidate];
            if (substring) {
                [result appendString:substring];
            } else {
                // Substitutions of matched expression (subexp 0) when there's no match is not allowed.  This won't happen given the situation in the caller of this function.
                return nil;
            }
        }
        curIndex++;
    }
    if (startIndex != curIndex) {
        [result appendString:[str substringWithRange:NSMakeRange(startIndex, curIndex - startIndex)]];
    }
    return result;
}

typedef enum {
    TestSucceeded = 0,
    TestDidNotCompile = 1,
    TestDidCompile = 2,  // (but shouldn't have)
    TestDidNotMatch = 3,
    TestDidMatch = 4,  // (but shouldn't have)
    TestSubstitutionFailed = 5,
    TestSubstitutionNotCorrect = 6,
    TestCaseInvalid = 7
} TestResult;

static BOOL executeTestCase(NSArray *testCase, BOOL *failureExpected) {
    // A test case array has five elements defined as follows:
    //     0: The regular expression.
    //     1: The candidate string.
    //     2: "c" if the expression should not compile, "n" if candidate should not match, "y" if candidate should match.
    //     3: A substitution format string where "&" substitutes the full expression match substring and "\1" - "\9" substitutes subexpression match 1-9.
    //     4: The expected result of substituting the subexpression matches into the substitution string.
    //     5: Optional, if present it means that the test will fail, but that it is a known failure and should not be counted as failed.  The value of this element does not matter.

    unsigned i, c = [testCase count];
    MORegularExpression *regex;
    BOOL matches;
    NSString *substString;

    if (failureExpected) {
        // Make sure the value gets set.
        *failureExpected = NO;
    }

    // Validate test case
    if (![testCase isKindOfClass:[NSArray class]] || ((c = [testCase count]) < 5) || (c > 6)) {
        return TestCaseInvalid;
    }
    for (i=0; i<5; i++) {
        if (![[testCase objectAtIndex:i] isKindOfClass:[NSString class]]) {
            return TestCaseInvalid;
        }
    }
    
    if (failureExpected) {
        // Set the flag for real.  If the test is expected to fail, we still perform it anyway.
        *failureExpected = ((c == 6) ? YES : NO);
    }
    
    // Compile it.
    regex = [MORegularExpression regularExpressionWithString:[testCase objectAtIndex:0]];
    if (regex == NULL) {
        if ([[testCase objectAtIndex:2] isEqualToString:@"c"]) {
            return TestSucceeded;
        } else {
            return TestDidNotCompile;
        }
    } else if ([[testCase objectAtIndex:2] isEqualToString:@"c"]) {
        return TestDidCompile;
    }

    // Test it.
    matches = [regex matchesString:[testCase objectAtIndex:1]];
    if (!matches) {
        if ([[testCase objectAtIndex:2] isEqualToString:@"n"]) {
            return TestSucceeded;
        } else {
            return TestDidNotMatch;
        }
    } else if ([[testCase objectAtIndex:2] isEqualToString:@"n"]) {
        return TestDidMatch;
    }

    // Substitute it.
    // ---:mferris: We use subexpressionsForString: even though it's basically obsolete since it is implemented in terms of the newer API and it happens to be just what we want.
    substString = substituteSubexpressions([testCase objectAtIndex:3], regex, [testCase objectAtIndex:1]);
    if (!substString) {
        return TestSubstitutionFailed;
    } else if ([substString isEqualToString:[testCase objectAtIndex:4]]) {
        return TestSucceeded;
    } else {
        return TestSubstitutionNotCorrect;
    }
}

static NSString *testFailureString(TestResult result, NSArray *testCase) {
    switch (result) {
        case TestSucceeded:
            return @"Test succeeded.";
            break;
        case TestDidNotCompile:
            return [NSString stringWithFormat:@"Test expression '%@' was expected to compile successfully, but it did not.", [testCase objectAtIndex:0]];
            break;
        case TestDidCompile:
            return [NSString stringWithFormat:@"Test expression '%@' was not expected to compile, but it was compiled successfully.", [testCase objectAtIndex:0]];
            break;
        case TestDidNotMatch:
            return [NSString stringWithFormat:@"Test match string '%@' was expected to match expression '%@', but it did not.", [testCase objectAtIndex:1], [testCase objectAtIndex:0]];
            break;
        case TestDidMatch:
            return [NSString stringWithFormat:@"Test match string '%@' was not extpected to match expression '%@', but it did.", [testCase objectAtIndex:1], [testCase objectAtIndex:0]];
            break;
        case TestSubstitutionFailed:
            return [NSString stringWithFormat:@"Test subexpression substitution '%@' referenced non-existent subexpressions in expression '%@' for candidate '%@'.", [testCase objectAtIndex:3], [testCase objectAtIndex:0], [testCase objectAtIndex:1]];
            break;
        case TestSubstitutionNotCorrect:
            return [NSString stringWithFormat:@"Test subexpression substitution '%@' did not match expected result '%@' in expression '%@' for candidate '%@'.", [testCase objectAtIndex:3], [testCase objectAtIndex:4], [testCase objectAtIndex:0], [testCase objectAtIndex:1]];
            break;
        case TestCaseInvalid:
            return [NSString stringWithFormat:@"Test case is not valid.  It either does not contain the right number of  elements or some of the elements aren't strings '%@'.", testCase];
            break;
        default:
            return @"Unknown test result.";
            break;
    }
}

static unsigned totalTests = 0;
static unsigned failCount = 0;
static unsigned expectedFailureCount = 0;

static void testMORegularExpression() {
    NSAutoreleasePool *pool;
    NSArray *testCases = readTestData();
    unsigned i, c = [testCases count];
    TestResult result;
    BOOL failureExpected = NO;

    for (i=0; i<c; i++) {
        pool = [[NSAutoreleasePool alloc] init];

        result = executeTestCase([testCases objectAtIndex:i], &failureExpected);
        totalTests++;
        if (result != TestSucceeded) {
            if (!failureExpected) {
                failCount++;
            } else {
                expectedFailureCount++;
            }
            NSLog(@"%@Test case %u failed: %@", (failureExpected ? @"EXPECTED FAILURE: " : @""), i, testFailureString(result, [testCases objectAtIndex:i]));
        }

        [pool release];
    }
}

static void testMORegexFormatter() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    MORegexFormatter *formatter = [[MORegexFormatter alloc] init];
    MORegularExpression *exp;
    id objValue = nil;
    NSString *errorString = nil;
    NSString *testStr;
    BOOL result;
    
    exp = [[MORegularExpression alloc] initWithExpressionString:@"abcd*e" ignoreCase:YES];
    [formatter addRegularExpression:exp];
    [exp release];
    exp = [[MORegularExpression alloc] initWithExpressionString:@"xyz" ignoreCase:YES];
    [formatter addRegularExpression:exp];
    [exp release];

    // test empty string stuff
    testStr = @"";
    [formatter setAllowsEmptyString:YES];
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (!result) {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected empty string to be accepted but it was not.");
    } else if (![testStr isEqual:objValue]) {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected empty string value but got '%@'.", objValue);
    }

    [formatter setAllowsEmptyString:NO];
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected empty string to be rejected but it was not.");
    } else {
        NSLog(@"MORegexFormatter test: empty string was correctly rejected with error string: %@.", errorString);
    }

    // test simple matching
    testStr = @"blah blah abCde blah";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        if (![testStr isEqual:objValue]) {
            failCount++;
            NSLog(@"FAILURE: MORegexFormatter test: string '%@' badly formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        } else {
            NSLog(@"MORegexFormatter test: string '%@' formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        }
    } else {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be accepted but it was not (error str %@).", testStr, errorString);
    }
    testStr = @"blah blah abcddDe blah";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        if (![testStr isEqual:objValue]) {
            failCount++;
            NSLog(@"FAILURE: MORegexFormatter test: string '%@' badly formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        } else {
            NSLog(@"MORegexFormatter test: string '%@' formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        }
    } else {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be accepted but it was not (error str %@).", testStr, errorString);
    }
    testStr = @"blah blah Xyz blah";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        if (![testStr isEqual:objValue]) {
            failCount++;
            NSLog(@"FAILURE: MORegexFormatter test: string '%@' badly formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        } else {
            NSLog(@"MORegexFormatter test: string '%@' formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        }
    } else {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be accepted but it was not (error str %@).", testStr, errorString);
    }
    testStr = @"blah blah xyyyz blah";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be rejected but it was not.", testStr, errorString);
    } else {
        NSLog(@"MORegexFormatter test: string '%@' rejected, error string %@", testStr, errorString);
    }

    // Test format pattern
    [formatter setFormatPattern:@"%0"];
    testStr = @"blah blah abcddde blah";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        if (![@"abcddde" isEqual:objValue]) {
            failCount++;
            NSLog(@"FAILURE: MORegexFormatter test: string '%@' badly formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        } else {
            NSLog(@"MORegexFormatter test: string '%@' formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        }
    } else {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be accepted but it was not (error str %@).", testStr, errorString);
    }
    [formatter setFormatPattern:@"%{0}"];
    testStr = @"blah blah Xyz blah";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        if (![@"Xyz" isEqual:objValue]) {
            failCount++;
            NSLog(@"FAILURE: MORegexFormatter test: string '%@' badly formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        } else {
            NSLog(@"MORegexFormatter test: string '%@' formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        }
    } else {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be accepted but it was not (error str %@).", testStr, errorString);
    }

    // Test subexpression expansion with format pattern
    [formatter removeRegularExpressionAtIndex:0];
    [formatter removeRegularExpressionAtIndex:0];
    exp = [[MORegularExpression alloc] initWithExpressionString:@"(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)(m)(n)(o)" ignoreCase:YES];
    [formatter addRegularExpression:exp];
    [exp release];
    [formatter setFormatPattern:@"\\%2%1%{5}%{12}"];
    NSLog(@"Formatter pattern: %@, length %u", [formatter formatPattern], [[formatter formatPattern] length]);
    testStr = @"abcdefghijklmno";
    result = [formatter getObjectValue:&objValue forString:testStr errorDescription:&errorString];
    totalTests++;
    if (result) {
        if (![@"%2ael" isEqual:objValue]) {
            failCount++;
            NSLog(@"FAILURE: MORegexFormatter test: string '%@' badly formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        } else {
            NSLog(@"MORegexFormatter test: string '%@' formatted to '%@', matched expression %@", testStr, objValue, [formatter lastMatchedExpression]);
        }
    } else {
        failCount++;
        NSLog(@"FAILURE: MORegexFormatter test: expected '%@' to be accepted but it was not (error str %@).", testStr, errorString);
    }
    
    [pool release];
}

int main (int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    testMORegularExpression();

    testMORegexFormatter();

    if ((failCount == 0) && (expectedFailureCount == 0)) {
        NSLog(@"SUCCESS: All %u tests succeeded.", totalTests);
    } else if (failCount == 0) {
        NSLog(@"SUCCESS: %u of %u tests succeeded and the rest were expected to fail.", totalTests-expectedFailureCount, totalTests);
    } else if (expectedFailureCount==0) {
        NSLog(@"FAILURE: %u of %u tests failed.", failCount, totalTests);        
    } else {
        NSLog(@"FAILURE: %u of %u tests failed (but %u of the failures were expected).", failCount+expectedFailureCount, totalTests, expectedFailureCount);
    }

    [pool release];

    
    return (((failCount == 0) ? 0 : 1));
}


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
