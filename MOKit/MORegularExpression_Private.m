// MORegularExpression_Private.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MORegularExpression_Private.h>
#import <MOKit/MORegularExpression.h>
#import "regcustom.h"

void MO_FreeRegex(void *re) {    
    MO_ReFree((regex_t *)re);
    free(re);
}

void *MO_TestAndCompileExpressionString(NSString *expressionString, BOOL ignoreCase) {
    // Caller frees return value if non-null.
    regex_t *re = NULL;
    int err;
    int flags;
    unsigned len;
    unichar *chrs;
    
    re = malloc(sizeof(regex_t));
    if (ignoreCase) {
        flags = (REG_ADVANCED | REG_ICASE);
    } else {
        flags = (REG_ADVANCED);
    }
    // !!!:mferris:20021028 Avoid malloc for small strings?
    len = [expressionString length];
    chrs = malloc(sizeof(unichar) * len);
    [expressionString getCharacters:chrs];
    err = MO_ReComp(re, chrs, len, flags);
    free(chrs);
    if (err != REG_OKAY) {
        MO_ReFree(re), re = NULL;
    }
    return re;
}

BOOL MO_TestAndMatchCharactersInRangeWithExpression(const unichar *candidateChars, NSRange searchRange, void *re, NSRange *subrangeArray) {
    const unichar *theChars;
    BOOL retVal;
    size_t nmatch = MO_REGEXP_MAX_SUBEXPRESSIONS;
    regmatch_t pmatch[MO_REGEXP_MAX_SUBEXPRESSIONS];
    
    theChars = candidateChars + searchRange.location;
    
    retVal = ((MO_ReExec((regex_t *)re, theChars, searchRange.length, NULL, nmatch, pmatch, 0) == REG_OKAY) ? YES : NO);
    if (subrangeArray) {
        if (retVal) {
            unsigned i;
            NSRange result;
            for (i=0; i<MO_REGEXP_MAX_SUBEXPRESSIONS; i++) {
                if (i < nmatch && (pmatch[i].rm_so >= 0)) {
                    result = NSMakeRange(searchRange.location + pmatch[i].rm_so, pmatch[i].rm_eo - pmatch[i].rm_so);
                    subrangeArray[i] = result;
                } else {
                    subrangeArray[i] = NSMakeRange(NSNotFound, 0);
                }
            }
        } else {
            unsigned i;
            for (i=0; i<MO_REGEXP_MAX_SUBEXPRESSIONS; i++) {
                subrangeArray[i] = NSMakeRange(NSNotFound, 0);
            }
        }
    }
    return retVal;
}


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
