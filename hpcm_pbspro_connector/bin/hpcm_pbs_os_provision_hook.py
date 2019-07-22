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

pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Env = %s" % repr(os.environ))
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: PBS Node = %s" % vnode)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: AOE = %s" % aoe)

ret = os.system("/opt/clmgr/contrib/hpcm_pbspro_connector/bin/hpcm_provision.sh " + aoe + " " + vnode)
if ret != 0:
    pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Failed - retcode = %s" % str(ret))
    e.reject("Reboot provisioning failed", ret)
else:
    os.system("/opt/clmgr/bin/cmu_power -p BOOT -n " + vnode)
    e.accept(0)
