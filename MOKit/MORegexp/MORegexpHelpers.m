// MORegexpHelpers.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MORegexpHelpers.h>
#import <Foundation/Foundation.h>

unsigned char MO_UniCharIsAlnum(MO_unichar x) {
    static NSCharacterSet *charSet = nil;
    if (!charSet) {
        charSet = [[NSCharacterSet alphanumericCharacterSet] retain];
    }
    return [charSet characterIsMember:x];
}

unsigned char MO_UniCharIsAlpha(MO_unichar x) {
    static NSCharacterSet *charSet = nil;
    if (!charSet) {
        charSet = [[NSCharacterSet letterCharacterSet] retain];
    }
    return [charSet characterIsMember:x];
}

unsigned char MO_UniCharIsDigit(MO_unichar x) {
    static NSCharacterSet *charSet = nil;
    if (!charSet) {
        charSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
    }
    return [charSet characterIsMember:x];
}

unsigned char MO_UniCharIsSpace(MO_unichar x) {
    static NSCharacterSet *charSet = nil;
    if (!charSet) {
        charSet = [[NSCharacterSet whitespaceCharacterSet] retain];
    }
    return [charSet characterIsMember:x];
}

static CFMutableStringRef _sharedCFStr = NULL;
static UniChar _sharedCFStrStorage[1];

MO_unichar MO_UniCharToLower(MO_unichar c) {
    if (!_sharedCFStr) {
        _sharedCFStr = CFStringCreateMutableWithExternalCharactersNoCopy(NULL, _sharedCFStrStorage, 1, 1, kCFAllocatorNull);
    }
    _sharedCFStrStorage[0] = (UniChar)c;
    CFStringLowercase(_sharedCFStr, NULL);
    return _sharedCFStrStorage[0];
}

MO_unichar MO_UniCharToUpper(MO_unichar c) {
    if (!_sharedCFStr) {
        _sharedCFStr = CFStringCreateMutableWithExternalCharactersNoCopy(NULL, _sharedCFStrStorage, 1, 1, kCFAllocatorNull);
    }
    _sharedCFStrStorage[0] = (UniChar)c;
    CFStringUppercase(_sharedCFStr, NULL);
    return _sharedCFStrStorage[0];
}

MO_unichar MO_UniCharToTitle(MO_unichar c) {
    // !!!:mferris:20010210 Not really correct.  What is "title" case anyway?
    return MO_UniCharToUpper(c);
}


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
