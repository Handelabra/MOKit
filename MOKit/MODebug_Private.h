// MODebug_Private.h
// MOKit
//
// Copyright © 2003-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#if !defined(__MOKIT_MODebug_Private__)
#define __MOKIT_MODebug_Private__ 1

#import <Foundation/Foundation.h>
#import <MOKit/MODebug.h>

#if defined(__cplusplus)
extern "C" {
#endif

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

#endif // __MOKIT_MODebug_Private__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
