This vagrant definition is used to deploy RDO/juno with
specific patches [1] to allow an experimental openvswitch_firewall_driver.py
with connection tracking support.

openvswitch with connection tracking, is also checked out from
git and installed (ovs-install.sh).

[1] https://review.openstack.org/#/c/175347/

