// MOCompletionManager.m
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MOCompletionManager.h>
#import <MOKit/MOCompletionStrategy.h>
#import <MOKit/MOFoundationExtras.h>
#import <MOKit/MOAssertions.h>

typedef enum {
    MOInitialVersion = 1,
} MOClassVersion;

static const MOClassVersion MOCurrentClassVersion = MOInitialVersion;

@implementation MOCompletionManager

+ (void)initialize {
    // Set the version.  Load classes, and init class variables.
    if (self == [MOCompletionManager class])  {
        [self setVersion:MOCurrentClassVersion];
    }
}

- (id)init {
    self = [super init];

    if (self != nil) {
        _cachedTextView = nil;
        _cachedSelectedRange = NSMakeRange(NSNotFound, 0);
        _cachedBasePath = nil;
        _completionStrategy = nil;
        _completionMatches = nil;
        _lastMatchIndex = NSNotFound;
        _completionRange = NSMakeRange(NSNotFound, 0);
        _completionPrefixString = nil;
        _dumpCompletionsEnabled = YES;
        _completeWords = YES;

        _completionStrategies = nil;
    }
    
    return self;
}

- (void)dealloc {
    _dumpCompletionsEnabled = YES;
    [self dumpCompletionState];
    [_completionStrategies release];
    [super dealloc];
}

- (void)setCompletionStrategies:(NSArray *)strategies {
    MOAssertClass(strategies, NSArray);
    unsigned i, c = [strategies count];
    for (i=0; i<c; i++) {
        MOAssertClass([strategies objectAtIndex:i], MOCompletionStrategy);
    }
    if (strategies != _completionStrategies) {
        [_completionStrategies release];
        _completionStrategies = [[NSArray allocWithZone:[self zone]] initWithArray:strategies];
    }
}

- (NSArray *)completionStrategies {
    return _completionStrategies;
}

- (void)dumpCompletionState {
    if (_dumpCompletionsEnabled) {
        //NSLog(@"Dumping completion state");
        _cachedTextView = nil;
        _cachedSelectedRange = NSMakeRange(NSNotFound, 0);
        [_cachedBasePath release], _cachedBasePath = nil;
        _completionStrategy = nil;
        [_completionMatches release], _completionMatches = nil;
        _lastMatchIndex = NSNotFound;
        _completionRange = NSMakeRange(NSNotFound, 0);
        [_completionPrefixString release], _completionPrefixString = nil;
    }
}

- (void)doCompletionInTextView:(NSTextView *)textView startLimit:(unsigned)startLimit basePath:(NSString *)basePath {
    static NSCharacterSet *completableSet = nil;
    static NSCharacterSet *nonCompletableSet = nil;

    MOAssertClass(textView, NSTextView);
    MOAssertStringOrNil(basePath);
    MOParameterAssert((startLimit <= [[textView string] length]));

    NSRange selectedRange = [textView selectedRange];
    unsigned i, c;
    
    // Set up the statics
    if (!completableSet) {
        nonCompletableSet = [[NSCharacterSet whitespaceCharacterSet] retain];
        completableSet = [[nonCompletableSet invertedSet] retain];
    }

    if ((textView != _cachedTextView) || (selectedRange.location != _cachedSelectedRange.location) || (selectedRange.length != _cachedSelectedRange.length) || (((basePath != nil) || (_cachedBasePath != nil)) && (![basePath isEqualToString:_cachedBasePath]))) {
        [self dumpCompletionState];
        _cachedTextView = textView;
        _cachedBasePath = [basePath copyWithZone:[self zone]];
    }

    if (_lastMatchIndex == NSNotFound) {
        NSString *string = [textView string];
        NSRange searchRange, foundRange;
        NSString *path;

        // Find the search path and partial name.
        searchRange.location = startLimit;
        if (selectedRange.location <= searchRange.location) {
            NSBeep();
            return;
        }
        searchRange.length = selectedRange.location - searchRange.location;
        if (_completeWords) {
            foundRange = [string rangeOfCharacterFromSet:nonCompletableSet options:NSBackwardsSearch range:searchRange];
        } else {
            foundRange = NSMakeRange(NSNotFound, 0);
        }
        if (foundRange.length > 0) {
            _completionRange = NSMakeRange(NSMaxRange(foundRange), NSMaxRange(selectedRange) - NSMaxRange(foundRange));
            path = [string substringWithRange:NSMakeRange(NSMaxRange(foundRange), NSMaxRange(searchRange) - NSMaxRange(foundRange))];
        } else {
            _completionRange = NSMakeRange(searchRange.location, NSMaxRange(selectedRange) - searchRange.location);
            path = [string substringWithRange:searchRange];
        }

        // Get the matches.
        c = [_completionStrategies count];
        for (i=0; i<c; i++) {
            _completionStrategy = [_completionStrategies objectAtIndex:i];
            //NSLog(@"Trying completion strategy '%@' with prefix '%@' and basePath '%@'", NSStringFromClass([_completionStrategy class]), path, basePath);
            _completionPrefixString = nil;
            _completionMatches = [_completionStrategy matchesForPrefixString:path newPrefixString:&_completionPrefixString basePath:basePath];
            if ([_completionMatches count] > 0) {
                break;
            }
        }
        [_completionMatches retain];
        [_completionPrefixString retain];
    }

    c = [_completionMatches count];
    if (c == 0) {
        NSBeep();
    } else {
        NSString *match;
        BOOL initialPrefixMatch;
        
        // Prevent the text and selection mucking happening here from dumping completion state.
        _dumpCompletionsEnabled = NO;
        
        if (_lastMatchIndex == NSNotFound) {
            _lastMatchIndex = c - 1;
            match = [_completionMatches MO_longestCommonPrefixForStrings];
            initialPrefixMatch = ((c > 1) ? YES : NO);
        } else {
            _lastMatchIndex = ((_lastMatchIndex + 1) % c);
            match = [_completionMatches objectAtIndex:_lastMatchIndex];
            initialPrefixMatch = NO;
        }

        // Get the (possibly) processed full string.
        match = [_completionStrategy fullStringForPrefixString:_completionPrefixString completionString:match isInitialPrefixMatch:initialPrefixMatch basePath:basePath];

        [textView replaceCharactersInRange:_completionRange withString:match];
        _completionRange.length = [match length];
        _cachedSelectedRange = NSMakeRange(NSMaxRange(_completionRange), 0);
        [textView setSelectedRange:_cachedSelectedRange];
        [textView scrollRangeToVisible:_cachedSelectedRange];

        _dumpCompletionsEnabled = YES;
        if (initialPrefixMatch) {
            NSBeep();
        }
        if (c == 1) {
            // Only one match, just get ready to complete the next component.
            [self dumpCompletionState];
        }
    }
}

- (void)setCompleteWords:(BOOL)flag {
    _completeWords = flag;
}

- (BOOL)completeWords {
    return _completeWords;
}

- (void)textDidChange:(NSNotification *)notification {
    [self dumpCompletionState];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    [self dumpCompletionState];
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(complete:)) {
        // ???:mferris: Should this use the textView's window's document path (if it has one) for the basePath?
        [self doCompletionInTextView:textView startLimit:0 basePath:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self dumpCompletionState];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    [self dumpCompletionState];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(complete:)) {
        // ???:mferris: Should this use the textView's window's document path (if it has one) for the basePath?
        [self doCompletionInTextView:textView startLimit:0 basePath:nil];
        return YES;
    } else {
        return NO;
    }
}


@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
