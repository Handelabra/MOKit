// MODebug.m
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import <MOKit/MODebug_Private.h>
#import <objc/objc-class.h>

MOKIT_EXTERN void MOLog(NSString *formatString, ...) {
    va_list argp;

    va_start(argp, formatString);
    
    // Let NSString do the formatting.
    NSString *str = [[NSString alloc] initWithFormat:formatString arguments:argp];
    unsigned len = [str length];
    
    if (len > 0) {
        unsigned start, lineEnd, contentEnd;
        [str getLineStart:&start end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange(len-1, 1)];
        
        // Add a trailing newline if the string does not already have one.
        printf(((lineEnd == contentEnd) ? "%s\n" : "%s"), [str UTF8String]);
    } else {
        // Empty string, just print a newline.
        printf("\n");
    }
    [str release];
    va_end(argp);
}

@implementation NSObject (MODebugging)

- (NSString *)MO_shortDescription {
    return [NSString stringWithFormat:@"<%@: 0x%x>", NSStringFromClass([self class]), (unsigned)self];
}

@end

@implementation NSApplication (MODebugging)

- (IBAction)MO_dumpResponderChain:(id)sender {
    MODumpResponderChain();
}

- (IBAction)MO_dumpKeyLoops:(id)sender {
    MODumpKeyLoops();
}

@end

typedef void (*_MO_WindowDumpFunction)(NSWindow *window);

static void _MO_DoDumpFunctionForKeyAndMainWindows(_MO_WindowDumpFunction func) {
    NSWindow *keyWindow = nil;
    NSWindow *mainWindow = nil;

    // Get ivar value this way because -[NSApplication keyWindow/mainWindow] return nil when app is not active.
    // Use objc runtime API instead of direct reference to ivar in case NSApp's instance layout changes...
    object_getInstanceVariable(NSApp, "_keyWindow", (void **)(&keyWindow));
    object_getInstanceVariable(NSApp, "_mainWindow", (void **)(&mainWindow));
    
    printf("----- Key window\n");
    if (keyWindow) {
        func(keyWindow);
    } else {
        printf("(No key window)\n");
    }
    printf("----- Main window\n");
    if (mainWindow == keyWindow) {
        printf("(Main window is key window)\n");
    } else if (mainWindow) {
        func(mainWindow);
    } else {
        printf("(No main window)\n");
    }
}

static void _MO_DumpResponderChainForWindow(NSWindow *window) {
    printf("(0x%x, '%s', dumping responders starting with first responder)\n", (unsigned)window, [[window title] lossyCString]);

    id firstResponder = [window firstResponder];
    if (!firstResponder) {
        printf("    (No first responder)\n");
    } else {
        while (firstResponder) {
            printf("    %s\n", [[firstResponder MO_shortDescription] lossyCString]);
            firstResponder = [firstResponder nextResponder];
        }
    }
}

void MODumpResponderChain() {
    printf("================ Responder chain dump ================\n");
    _MO_DoDumpFunctionForKeyAndMainWindows(&_MO_DumpResponderChainForWindow);
}

static void _MO_DumpKeyLoopForWindow(NSWindow *window) {
    printf("(0x%x, '%s', dumping key loop starting with initial first responder)\n", (unsigned)window, [[window title] lossyCString]);

    id ifr = [window initialFirstResponder];
    if (!ifr) {
        printf("    (No initial first responder)\n");
    } else {
        NSHashTable *seenHash = NSCreateHashTable(NSNonRetainedObjectHashCallBacks, 0);
        id resp = ifr;
        while (!NSHashGet(seenHash, resp)) {
            NSHashInsert(seenHash, resp);
            printf("    %s\n", [[resp MO_shortDescription] lossyCString]);
            resp = [resp nextKeyView];
        }
        // Print the last one to "close the loop".
        printf("    %s\n", [[resp MO_shortDescription] lossyCString]);
        
        if (resp != ifr) {
            printf("    WARNING: key loop is not a strict loop!  (Traversing the loop never gets back to the window's initial first responder.)\n");
        }
    }
}

void MODumpKeyLoops() {
    printf("================ Key loop dump ================\n");
    _MO_DoDumpFunctionForKeyAndMainWindows(&_MO_DumpKeyLoopForWindow);
}

#ifdef DEBUG_LOGS
int _MO_traceIndent = 0;
#endif

/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
