// MOFileCompletionStrategy.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOFileCompletionStrategy.h>
#import <MOKit/MOFoundationExtras.h>
#import <MOKit/MOAssertions.h>

typedef enum {
    MOInitialVersion = 1,
} MOClassVersion;

static const MOClassVersion MOCurrentClassVersion = MOInitialVersion;

@implementation MOFileCompletionStrategy

+ (void)initialize {
    // Set the version.  Load classes, and init class variables.
    if (self == [MOFileCompletionStrategy class])  {
        [self setVersion:MOCurrentClassVersion];
    }
}

- (id)init {
    self = [super init];
    _fcsFlags.appendsSpaceOnFileMatch = NO;
    _fcsFlags.appendsSlashOnDirectoryMatch = YES;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)appendsSpaceOnFileMatch {
    return _fcsFlags.appendsSpaceOnFileMatch;
}

- (void)setAppendsSpaceOnFileMatch:(BOOL)flag {
    _fcsFlags.appendsSpaceOnFileMatch = flag;
}

- (BOOL)appendsSlashOnDirectoryMatch {
    return _fcsFlags.appendsSlashOnDirectoryMatch;
}

- (void)setAppendsSlashOnDirectoryMatch:(BOOL)flag {
    _fcsFlags.appendsSlashOnDirectoryMatch = flag;
}

- (NSString *)basePathFromProposedBasePath:(NSString *)basePath path:(NSString *)path {
    MOAssertStringOrNil(basePath);
    MOAssertStringOrNil(path);
    if (![path isAbsolutePath]) {
        if (basePath) {
            basePath = [basePath stringByStandardizingPath];
        }
    } else {
        basePath = nil;
    }
    return basePath;
}

- (void)addFilesMatchingPrefix:(NSString *)partialName forChildrenOfDirectory:(NSString *)dirPath toMutableArray:(NSMutableArray *)matches {
    MOAssertStringOrNil(partialName);
    MOAssertStringOrNil(dirPath);
    MOAssertClass(matches, NSMutableArray);
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *children = [[fm directoryContentsAtPath:dirPath] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    unsigned i, c;
    NSString *curChild;

    c = [children count];
    for (i=0; i<c; i++) {
        curChild = [children objectAtIndex:i];
        if (!partialName || ([curChild rangeOfString:partialName options:NSAnchoredSearch range:NSMakeRange(0, [curChild length])].length != 0)) {
            [matches addObject:curChild];
        }
    }

    // ---:mferris: Allow case-insensitive completions, but only if there aren't any for the correct case.  Allow this on any OS/filesystem.  What the hell...
    if ([matches count] == 0) {
        for (i=0; i<c; i++) {
            curChild = [children objectAtIndex:i];
            if (!partialName || ([curChild rangeOfString:partialName options:(NSAnchoredSearch | NSCaseInsensitiveSearch) range:NSMakeRange(0, [curChild length])].length != 0)) {
                [matches addObject:curChild];
            }
        }
    }
}

- (NSArray *)matchesForPrefixString:(NSString *)path newPrefixString:(NSString **)newStr basePath:(NSString *)basePath {
    MOAssertStringOrNil(path);
    MOAssertStringOrNil(basePath);
    unichar ch;
    NSString *partialName = nil;
    NSMutableArray *matches = [[[NSMutableArray allocWithZone:[self zone]] init] autorelease];
    
    if (([path isEqualToString:@""]) || ((ch = [path characterAtIndex:[path length] - 1]) == (unichar)'/') || (ch == (unichar)'\\')) {
        partialName = nil;
    } else {
        partialName = [path lastPathComponent];
        path = [path stringByDeletingLastPathComponent];
    }
    path = [path stringByStandardizingPath];
    basePath = [self basePathFromProposedBasePath:basePath path:path];

    //NSLog(@"FileCompletionStrategy basePath: '%@', path: '%@', partialName: '%@'.", basePath, path, partialName);

    // Now find the matches
    [self addFilesMatchingPrefix:partialName forChildrenOfDirectory:(basePath ? [basePath stringByAppendingPathComponent:path] : path) toMutableArray:matches];

#if 0
    // ---:mferris: This code was supposed to allow completion based on a an array of paths as well as the default path.  It is disabled because I haven't really thought through the full implications of such a change
    // !!!:mferris:20021127 At least, this puts a bit of a wrench into the case-sensitive vs. case-insensitive logic implemented by addFilesMatchingPrefix:...
    if (basePath && _paths) {
        // This was a non-absolute path, also add matches for any directories in our path list
        unsigned i, c = [_paths count];
        for (i=0; i<c; i++) {
            [self addFilesMatchingPrefix:partialName forChildrenOfDirectory:[_paths objectAtIndex:i] toMutableArray:matches];
        }
    }
#endif
    
    if (newStr) {
        *newStr = [[path copyWithZone:[self zone]] autorelease];
    }
    //NSLog(@"FileCompletionStrategy matches: '%@'\nNew prefix string: '%@'.", matches, path);
    return matches;
}

- (NSString *)fullStringForPrefixString:(NSString *)prefixStr completionString:(NSString *)completionStr isInitialPrefixMatch:(BOOL)initialPrefixMatch basePath:(NSString *)basePath {
    MOAssertStringOrNil(prefixStr);
    MOAssertStringOrNil(completionStr);
    MOAssertStringOrNil(basePath);
    NSString *fullStr;

    if (!completionStr || [completionStr isEqualToString:@""]) {
        if (!prefixStr || [prefixStr isEqualToString:@""]) {
            fullStr = @"";
        } else {
            fullStr = [prefixStr stringByAppendingString:@"/"];
        }
    } else {
        fullStr = [prefixStr stringByAppendingPathComponent:completionStr];
    }
    fullStr = [fullStr MO_stringByReplacingBackslashWithSlash];
    if (!initialPrefixMatch) {
        NSString *tempPath = fullStr;
        BOOL exists, isDir = NO;
        
        basePath = [self basePathFromProposedBasePath:basePath path:fullStr];
        if (basePath) {
            tempPath = [basePath stringByAppendingPathComponent:fullStr];
        }
        exists = [[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDir];
#if 0
        // ---:mferris: This code was supposed to allow completion based on a an array of paths as well as the default path.  It is disabled because I haven't really thought through the full implications of such a change
        if (!exists && basePath && _paths) {
            unsigned i, c = [_paths count];
            for (i=0; (!exists && i<c); i++) {
                tempPath = [[_paths objectAtIndex:i] stringByAppendingPathComponent:fullStr];
                exists = [[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDir];
            }
        }
#endif
        if (exists && isDir) {
            if (_fcsFlags.appendsSlashOnDirectoryMatch) {
                fullStr = [fullStr stringByAppendingString:@"/"];
            }
        } else if (exists) {
            if (_fcsFlags.appendsSpaceOnFileMatch) {
                fullStr = [fullStr stringByAppendingString:@" "];
            }
        }
    }
    return fullStr;
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
