#! /bin/sh
#
# DistributionImages.sh <BINARY_DISTRIBUTION_ROOT> <SOURCE_DISTRIBUTION_ROOT> <DISTRIBUTION_NAME>
#
# MOKit
#
# Copyright © 2002-2005, Mike Ferris.  All rights reserved.
# See bottom of file for license and disclaimer.
#
# Script that implements the DistributionImages legacy Target in the MOKit project.  Working directory must be the project source directory.

if [ "z${DEPLOYMENT_POSTPROCESSING}" != "zYES" ] ; then
    echo "WARNING: Skipping DistributionImages target for non-install build"
    exit 0
fi

if [ "z$#" != "z3" ] ; then
    echo "ERROR: not enough arguments."
    echo "usage: DistributionImages.sh <BINARY_DISTRIBUTION_ROOT> <SOURCE_DISTRIBUTION_ROOT> <DISTRIBUTION_NAME>"
    exit 1
fi

BINARY_ROOT="$1"
SOURCE_ROOT="$2"
DIST_NAME="$3"

IFS="
"

################ Do binary distro image ################

# Note that these removals are actually working around bugs in the Jaguar development tools.  The files being removed should not be generated in the first place.
TO_BE_DELETED="${BINARY_ROOT}/Library/Frameworks/MOKit.framework/MOKit_debug
${BINARY_ROOT}/Library/Frameworks/MOKit.framework/MOKit_profile"
for i in ${TO_BE_DELETED} ; do
    chmod u+w `dirname "$i"`
    rm -f "$i"
    chmod u-w `dirname "$i"`
done

./imageFromFolder.sh "${BINARY_ROOT}"

################ Do source distro image ################
xcodebuild installsrc "SRCROOT=${SOURCE_ROOT}/${DIST_NAME}"

find "${SOURCE_ROOT}" -name CVS -prune -exec rm -rf \{\} \;
find "${SOURCE_ROOT}" -name .DS_Store -exec rm -f \{\} \;
find "${SOURCE_ROOT}" -name '*~.nib' -prune -exec rm -rf \{\} \;
find "${SOURCE_ROOT}" -name '*~' -prune -exec rm -rf \{\} \;
find "${SOURCE_ROOT}" -name '*.pbxuser' -exec rm -f \{\} \;
find "${SOURCE_ROOT}" -name '*.mode1' -exec rm -f \{\} \;

./imageFromFolder.sh "${SOURCE_ROOT}"

echo "===DONE==="


# This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.
# The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
