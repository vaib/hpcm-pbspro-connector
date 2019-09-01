# (C) Copyright 2012-2013 Altair Engineering, Inc.  All rights reserved.
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

import pbs
import os

e = pbs.event()
vnode = e.vnode
aoe = e.aoe

# event=provision runs only on server. user can request an aoe to be provisioned with a kernal of his choice on either disk or tmpfs and on a flat node, or ICE etc.
# provisioning CLI in HPCM requires more than AOE and Vnode. It requires kernal, rootfs type and node type. Based on this info, right image is provisioned on right node. So user will have to supply  this additional information. Since support by PBS in this regard is not possible in limited time, a workaround is provided.

# Provision hook will run on PBS Server but provisioning is started from admin node
# Check for admin node? Read from json config file.

kernel = os.environ["PBS_HPCM_KERNAL"]
prov   = os.environ["PBS_HPCM_PROVTYPE"].lower()
rootfs = os.environ["PBS_HPCM_ROOTFS"].lower()

pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Env = %s" % repr(os.environ))
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: PBS Node = %s" % vnode)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: AOE = %s" % aoe)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: PROVISION TYPE = %s" % prov)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: KERNAL = %s" % kernal)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: ROOTFS = %s" % rootfs)

if 'PBS_HOOK_CONFIG_FILE' in os.environ:
    import json
    config_file = os.environ["PBS_HOOK_CONFIG_FILE"]
    #pbs.logmsg(pbs.EVENT_DEBUG, "%s: Config file is %s" % (caller_name(), config_file))
    config = json.load(open(config_file, 'r'), object_hook=decode_dict)

server = pbs.server().name
admin = config['admin-node']

pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: server name = %s" % server)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: admin node = %s" % admin)

if admin == server:
    ret = os.system("/opt/clmgr/contrib/hpcm_pbspro_connector/bin/hpcm_provision.sh " + aoe + " " + vnode + " " + kernal + " " + prov + " " + rootfs)
    if ret != 0:
        pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Failed - retcode = %s" % str(ret))
        e.reject("Reboot provisioning failed", ret)
    else:
        e.accept(0)
else:
    ret = os.system("ssh ${admin} /opt/clmgr/contrib/hpcm_pbspro_connector/bin/hpcm_provision.sh " + aoe + " " + vnode + " " + kernal + " " + prov + " " + rootfs)
    if ret != 0:
        pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Failed - retcode = %s" % str(ret))
        e.reject("Reboot provisioning failed", ret)
    else:
        e.accept(0)
