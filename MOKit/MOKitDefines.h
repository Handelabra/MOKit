// MOKitDefines.h
// MOKit
//
// Copyright © 1996-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

// ABOUT MOKitDefines.h
//
// This little piece of cruft has to do with making sure that public symbols are
// exported from the framework and that private ones are not.  This applies to
// functions and global variables only.  Objective-C classes are all exported.
// Make sure that every non-static function or variable has a header
// declaration labelled either MOKIT_EXTERN or MOKIT_PRIVATE_EXTERN.  

#if !defined(__MOKIT_MOKitDefines__)
#define __MOKIT_MOKitDefines__ 1

#if defined(__cplusplus)
extern "C" {
#endif
    
//
//  Platform specific defs for externs
//

#ifdef __MACH__

#ifdef __cplusplus
// This isnt extern "C" because the compiler will not allow this if it has
// seen an extern "Objective-C"
#define MOKIT_EXTERN extern
#define MOKIT_PRIVATE_EXTERN __private_extern__
#else  // Not __cplusplus
#define MOKIT_EXTERN extern
#define MOKIT_PRIVATE_EXTERN __private_extern__
#endif  // __cplusplus

#else  // Not __MACH__

#error ERROR: Unknown platform not supported by MOKit

#endif  // __MACH__

#if defined(__cplusplus)
}
#endif
        
#endif // __MOKIT_MOKitDefines__


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
