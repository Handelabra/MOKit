#! /bin/sh
#
# imageFromFolder.sh <SourceFolder> [<DestinationFolder>]
#
# MOKit
#
# Copyright © 2002-2005, Mike Ferris.  All rights reserved.
# See bottom of file for license and disclaimer.
#
# Create an image containing the contents of <SourceFolder>.  The image will be named <SourceFolder>.dmg and will be placed in <DestinationFolder>, or if <DestinationFolder> is not specified, in the same folder as <SourceFolder>.

if [ $# -lt 1 -o $# -gt 2 ] ; then
    echo "usage: $0 <SourceFolder> [<DestinationFolder>]"
    exit 1
fi

SOURCE_FOLDER="$1"

if [ ! -d "${SOURCE_FOLDER}" ] ; then
    echo "usage: $0 <SourceFolder> [<DestinationFolder>]"
    echo "    ${SOURCE_FOLDER} does not exist or is not a folder."
    exit 1
fi

if [ $# -gt 1 ] ; then
    IMAGE_FOLDER="$2"
else
    IMAGE_FOLDER=`dirname ${SOURCE_FOLDER}`
fi

VOL_NAME=`basename ${SOURCE_FOLDER}`
IMAGE_PATH="${IMAGE_FOLDER}/${VOL_NAME}.dmg"
TEMP_IMAGE_PATH="${IMAGE_FOLDER}/${VOL_NAME}_temp.dmg"
MOUNT_PATH="/Volumes/${VOL_NAME}"

rm "${IMAGE_PATH}" "${TEMP_IMAGE_PATH}"

FOLDER_BLOCKS=`/usr/bin/du -s "${SOURCE_FOLDER}" | awk '{ print $1 }'`
PADDED_FOLDER_BLOCKS=`expr ${FOLDER_BLOCKS} + 100`

if [ ${PADDED_FOLDER_BLOCKS} -lt 10240 ] ; then
    PADDED_FOLDER_BLOCKS=10240
fi

echo hdiutil create -sectors ${PADDED_FOLDER_BLOCKS} -layout NONE -fs "HFS+" -volname "${VOL_NAME}"  "${TEMP_IMAGE_PATH}"
hdiutil create -sectors ${PADDED_FOLDER_BLOCKS} -layout NONE -fs "HFS+" -volname "${VOL_NAME}"  "${TEMP_IMAGE_PATH}"

if [ "z$?" != "z0" ] ; then
    echo "Error creating image ($?)."
    exit 1
fi

HDID_OUTPUT=`hdid "${TEMP_IMAGE_PATH}" | grep "${MOUNT_PATH}"`
DEVICE_NAME=`echo "${HDID_OUTPUT}" | awk '{ print $1 }' | sed -e 's%/dev/%%'`

if [ "z$?" != "z0" ] ; then
    echo "Error mounting new image ($?)."
    exit 1
fi

if [ ! -e "${MOUNT_PATH}" ] ; then
    echo "Error mounting new image (volume does not seem to be present)."
    exit 1
fi

ditto "${SOURCE_FOLDER}" "${MOUNT_PATH}"

hdiutil detach "${DEVICE_NAME}"

if [ "z$?" != "z0" ] ; then
    echo "Error ejecting image."
    exit 1
fi

hdiutil convert -format UDZO -o "${IMAGE_PATH}" "${TEMP_IMAGE_PATH}"

if [ "z$?" != "z0" ] ; then
    echo "Error compressing image."
    exit 1
fi

rm "${TEMP_IMAGE_PATH}"


# This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.
# The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
