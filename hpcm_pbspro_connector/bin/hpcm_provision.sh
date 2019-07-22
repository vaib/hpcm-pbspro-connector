#!/bin/sh
#
# Copyright (C) 1994-2019 Altair Engineering, Inc.
# For more information, contact Altair at www.altair.com.
#
# This file is part of the PBS Professional ("PBS Pro") software.
#
# Open Source License Information:
#
# PBS Pro is free software. You can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# PBS Pro is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Commercial License Information:
#
# For a copy of the commercial license terms and conditions,
# go to: (http://www.pbspro.com/UserArea/agreement.html)
# or contact the Altair Legal Department.
#
# Altair’s dual-license business model allows companies, individuals, and
# organizations to create proprietary derivative works of PBS Pro and
# distribute them - whether embedded or bundled with other software -
# under a commercial license agreement.
#
# Use of Altair’s trademarks, including but not limited to "PBS™",
# "PBS Professional®", and "PBS Pro™" and Altair’s logos is subject to Altair's
# trademark licensing policies.
#

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
