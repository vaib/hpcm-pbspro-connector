# (C) Copyright 2012-2013 Altair Engineering, Inc.  All rights reserved.
# This code is provided "as is" without any warranty, express or implied, or
# indemnification of any kind.  All other terms and conditions are as
# specified in the Altair PBS EULA.

import pbs
import os

e = pbs.event()
vnode = e.vnode
aoe = e.aoe

pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Env = %s" % repr(os.environ))
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: PBS Node = %s" % vnode)
pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: AOE = %s" % aoe)

ret = os.system("/opt/cmu/contrib/hpcm_pbspro_connector/bin/hpcm_provision.sh " + aoe + " " + vnode)
if ret != 0:
    pbs.logmsg(pbs.LOG_DEBUG, "PROVISIONING: Failed - retcode = %s" % str(ret))
    e.reject("Reboot provisioning failed", ret)
else:
    os.system("/opt/cmu/bin/cmu_power -p BOOT -n " + vnode)
    e.accept(0)
