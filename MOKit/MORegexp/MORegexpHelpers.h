// MORegexpHelpers.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.


#if !defined(__MOKIT_MORegexHelpers__)
#define __MOKIT_MORegexHelpers__ 1

#if defined(__cplusplus)
extern "C" {
#endif
    
// These functions implement a few utilities that the regexp package needs.

typedef unsigned short MO_unichar;

unsigned char MO_UniCharIsAlnum(MO_unichar x);
unsigned char MO_UniCharIsAlpha(MO_unichar x);
unsigned char MO_UniCharIsDigit(MO_unichar x);
unsigned char MO_UniCharIsSpace(MO_unichar x);

MO_unichar MO_UniCharToLower(MO_unichar c);
MO_unichar MO_UniCharToUpper(MO_unichar c);
MO_unichar MO_UniCharToTitle(MO_unichar c);

#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MORegexHelpers__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
