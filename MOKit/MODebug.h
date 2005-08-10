// MODebug.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

/*!
 @header MODebug
 @discussion Various helpful utilities for debugging. 
 */

#if !defined(__MOKIT_MODebug__)
#define __MOKIT_MODebug__ 1

#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <MOKit/MOKitDefines.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
 @function MOLog
 @abstract Like NSLog but does not output process and timestamp info.
 @discussion Often when doing debug output, the extra prefix info that NSLog includes out just clutters the output and makes it harder to read and harder to format reasonably.  On the other hand, printf does not support the %@ escape to include strings and other Obj-C objects' descriptions in the output.  MOLog is a varargs function like NSLog that supports the %@ escape (and all other +[NSString stringWithFormat:] features).  No prefix information (like process info and timestamps) will be printed.  If the formatted output does not end with a newline, a newline will be added.
 @param formatString The format string for the log output.
 @param ... additional arguments that supply values required by the escape sequences in formatString.
 */
MOKIT_EXTERN void MOLog(NSString *formatString, ...);

/*!
 @category NSObject(MODebugging)
 @abstract NSObject debugging utility methods.
 @discussion NSObject debugging utility methods.
 */
@interface NSObject (MODebugging)

/*!
    @method     MO_shortDescription
    @abstract   Returns a short description string.
    @discussion Returns a short description string.  Unlike -description, this is not intended to be subclassed.  It returns a description string like "<Classname: 0xAddress>" just like NSObject's -description method.  You can use it when logging debug output where you know you want a short description in the above form and not whatever extra information a class may decide to include in its -description string.
    @result     The short decription string.
*/
- (NSString *)MO_shortDescription;

@end

/*!
 @category NSApplication(MODebugging)
 @abstract NSApplication debugging utility methods.
 @discussion NSApplication debugging utility methods.
 */
@interface NSApplication (MODebugging)

/*!
    @method     MO_dumpResponderChain:
    @abstract   Logs the responder chains of the key and main windows, starting from their firstResponders.
    @discussion Logs the responder chains of the key and main windows, starting from their firstResponders.  This can be wired to a debug menu command.  It just calls the function MODumpResponderChain().
    @param      sender The sender, unused.
*/
- (IBAction)MO_dumpResponderChain:(id)sender;

/*!
    @method     MO_dumpKeyLoops:
    @abstract   Logs the key loops of the key and main windows, starting from their initialFirstResponders.
    @discussion Logs the key loops of the key and main windows, starting from their initialFirstResponders.  This can be wired to a debug menu command.  It just calls the function MODumpKeyLoops().
    @param      sender The sender, unused.
*/
- (IBAction)MO_dumpKeyLoops:(id)sender;

@end

/*!
    @function   MODumpResponderChain
    @abstract   Logs the responder chains of the key and main windows, starting from their firstResponders.
    @discussion Logs the responder chains of the key and main windows, starting from their firstResponders.
*/
MOKIT_EXTERN void MODumpResponderChain();

/*!
    @function   MODumpKeyLoops
    @abstract   Logs the key loops of the key and main windows, starting from their initialFirstResponders.
    @discussion Logs the key loops of the key and main windows, starting from their initialFirstResponders.
*/
MOKIT_EXTERN void MODumpKeyLoops();



// This is a couple silly little macros that allow for quick and dirty indented method trace logs.  It is mostly useful during class development and a more real mechanism might be nice at some point...

// A good way to use this is to put something like:
//    METHOD_TRACE_IN(@"Debug: %s (%@)", __PRETTY_FUNCTION__, [self MO_shortDescription]);
// as the very first line of your method and:
//    METHOD_TRACE_OUT;
// as the last line (except the return statement).
// If the method has multiple returns the METHOD_TRACE_OUT should go before each one.  The form of the METHOD_TRACE_IN will print a nicely formatted indication of what method is indicating including the class that implements the method.  The second part will print the receiver's description which generally includes the class of the 

//#define DEBUG_LOGS

#ifdef DEBUG_LOGS
MOKIT_EXTERN int _MO_traceIndent;
#define METHOD_TRACE_IN(_msg_, _args_...) { \
    unsigned i; \
        for (i=0; i<_MO_traceIndent; i++) printf("    "); \
            NSString *outStr = [NSString stringWithFormat:(_msg_), ## _args_]; \
                printf("%s\n", [outStr lossyCString]); \
                    _MO_traceIndent++;\
}
#define METHOD_TRACE_OUT { \
    _MO_traceIndent--; \
}
#else
#define METHOD_TRACE_IN(_msg_, _args_...)
#define METHOD_TRACE_OUT
#endif


#if defined(__cplusplus)
}
#endif

#endif // __MOKIT_MODebug__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
