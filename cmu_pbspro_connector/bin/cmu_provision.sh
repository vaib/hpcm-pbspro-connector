#!/bin/sh

# (C) Copyright 2012-2013 Altair Engineering, Inc.  All rights reserved.
# This code is provided "as is" without any warranty, express or implied, or
# indemnification of any kind.  All other terms and conditions are as
# specified in the Altair PBS EULA.

# HPCM Image Groups: A image group in HPCM represents a disk
#       image that has been captured (backed up). Based on this definition the
#       image group will be associated to the PBS Professional application
#       operating environment (aoe) native resource.


# Set GLOBAL VARIABLES
PID=$$
ERR=255

# Define CMU environment and construct absolute PATH for commands
CMU_PATH=/opt/clmgr
CMU_SHOW_LOGICAL_GROUPS=${CMU_PATH}/bin/cmu_show_image_groups
CMU_SHOW_NODES=${CMU_PATH}/bin/cmu_show_nodes
CMU_CLONE=${CMU_PATH}/bin/cmu_clone

# Verify that CMU commands
if [ ! -x "${CMU_SHOW_LOGICAL_GROUPS}" ]; then
    myecho "could not find executable ${CMU_SHOW_LOGICAL_GROUPS}"
    exit $ERR
fi
if [ ! -x "${CMU_CLONE}" ]; then
    myecho "could not find executable ${CMU_CLONE}"
    exit $ERR
fi

function myecho
{
    echo -e "$PID: $*"
}

# Check arguments
# 1. HPCM image group (aka PBS aoe)
# 2. valid HPCM client nodes

if [[ $# < 2 ]]; then
    myecho "usage: $0 <HPCM image group> <HPCM node to clone>"
    exit 1
fi

myecho "starting: $0 $*"

cmu_lg=$1
node=$2

# Reject provisioning the HPCM Server, which is also running PBS Professional Server/Scheduler
hostname=`hostname`
if [ "$node" = "$hostname" ]; then
    myecho "Cannot reboot own machine. Please provide another machine name"
    exit $ERR
fi

# Verify Image Group (aoe) exists
vnodes=`${CMU_SHOW_LOGICAL_GROUPS} ${cmu_lg}`
if [ $? -ne 0 ]; then
    myecho "${cmu_lg} is not a valid Image Group (aoe)"
    exit $ERR
fi

# Verify node exists in Image Group (aoe)
echo -e "${vnodes}" | grep "^${node}$"
if [ $? -ne 0 ]; then
    myecho "vnode ${node} is not associated to Image Group (aoe)"
    exit $ERR
fi

# Check whether node is already running the image group (aoe)
current_lg=`${CMU_SHOW_NODES} -o "%l" -n ${node}`
if [ "${current_image}" = "${cmu_lg}" ]; then
    myecho "Image Group (aoe) already running on ${node}."
    exit 0
fi

# We made it this far.. Kick off provisioning :o)
${CMU_CLONE} -n ${node} -i ${cmu_lg}
if [ $? -ne 0 ]; then
    myecho "CMU Provisioning FAILED!"
    exit $ERR
fi

myecho "${node} is now up and running with Image Group (aoe) ${cmu_lg}"
exit 0
