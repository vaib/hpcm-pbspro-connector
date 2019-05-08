#!/bin/sh

# (C) Copyright 2012-2013 Altair Engineering, Inc.  All rights reserved.
# This code is provided "as is" without any warranty, express or implied, or
# indemnification of any kind.  All other terms and conditions are as
# specified in the Altair PBS EULA.

# HP CMU Logical Groups: A logical group in HP Insight CMU represents a disk
#       image that has been captured (backed up). Based on this definition the
#       logical group will be associated to the PBS Professional application
#       operating environment (aoe) native resource.


# Set GLOBAL VARIABLES
PID=$$
ERR=255

# Define CMU environment and construct absolute PATH for commands
CMU_PATH=/opt/cmu
CMU_SHOW_LOGICAL_GROUPS=${CMU_PATH}/bin/cmu_show_logical_groups
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
# 1. CMU logical group (aka PBS aoe)
# 2. valid CMU client nodes

if [[ $# < 2 ]]; then
    myecho "usage: $0 <CMU logical group> <CMU node to clone>"
    exit 1
fi

myecho "starting: $0 $*"

cmu_lg=$1
node=$2

# Reject provisioning the CMU Server, which is also running PBS Professional Server/Scheduler
hostname=`hostname`
if [ "$node" = "$hostname" ]; then
    myecho "Cannot reboot own machine. Please provide another machine name"
    exit $ERR
fi

# Verify Logical Group (aoe) exists
vnodes=`${CMU_SHOW_LOGICAL_GROUPS} ${cmu_lg}`
if [ $? -ne 0 ]; then
    myecho "${cmu_lg} is not a valid Logical Group (aoe)"
    exit $ERR
fi

# Verify node exists in Logical Group (aoe)
echo -e "${vnodes}" | grep "^${node}$"
if [ $? -ne 0 ]; then
    myecho "vnode ${node} is not associated to Logical Group (aoe)"
    exit $ERR
fi

# Check whether node is already running the logical group (aoe)
current_lg=`${CMU_SHOW_NODES} -o "%l" -n ${node}`
if [ "${current_image}" = "${cmu_lg}" ]; then
    myecho "Logical Group (aoe) already running on ${node}."
    exit 0
fi

# We made it this far.. Kick off provisioning :o)
${CMU_CLONE} -n ${node} -i ${cmu_lg}
if [ $? -ne 0 ]; then
    myecho "CMU Provisioning FAILED!"
    exit $ERR
fi

myecho "${node} is now up and running with Logical Group (aoe) ${cmu_lg}"
exit 0
