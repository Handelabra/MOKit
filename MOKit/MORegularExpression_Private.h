// MORegularExpression_Private.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

// ABOUT MORegularExpression
//
// Just some private functions used by MORegularExpression.  These basically wrap
// the regular expression package that the class is based on.

#if !defined(__MOKIT_MORegularExpression_Private__)
#define __MOKIT_MORegularExpression_Private__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
MOKIT_PRIVATE_EXTERN void MO_FreeRegex(void *re);
MOKIT_PRIVATE_EXTERN void *MO_TestAndCompileExpressionString(NSString *expressionString, BOOL ignoreCase);
BOOL MO_TestAndMatchCharactersInRangeWithExpression(const unichar *candidateChars, NSRange searchRange, void *re, NSRange *subrangeArray);

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MORegularExpression_Private__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
