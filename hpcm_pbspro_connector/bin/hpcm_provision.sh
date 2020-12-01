#!/bin/sh
#
# Copyright (C) 1994-2020 Altair Engineering, Inc.
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

export OSCAR_HOME=/opt/oscar
export PATH=$PATH:/opt/clmgr/sbin:/opt/clmgr/bin:/opt/sgi/sbin:/opt/sgi/bin:/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/c3/bin:/opt/pbs/bin:/opt/pbs/sbin:/sbin:/bin:/usr/diags/bin:/lib:/usr/lib64:/usr/share:/usr/local/share:/opt/oscar/lib:/opt/sgi/lib:/usr/lib/systemimager/perl:/opt/clmgr/lib


# Define CMU environment and construct absolute PATH for commands
CMU_PATH=/opt/clmgr
{
    echo -e "$PID: $*"
}


cmu_lg=$1
node=$2

/opt/clmgr/bin/cm node provision -n $node -i $cmu_lg -s && /opt/clmgr/bin/cm power reset -t node $node
if [ $? -ne 0 ]; then
    #echo "HPCM OS Provisioning FAILED!"
    exit $ERR
fi

echo "${node} is now up and running with Image Group (aoe) ${cmu_lg}"
exit 0
