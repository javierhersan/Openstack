#!/bin/sh

#----------------------------------------------------------------------------------------
# Destroy physical scenario

cd /mnt/tmp/openstack_lab-stein_4n_classic_ovs-v06
sudo vnx -f openstack_lab.xml --destroy 			# Destroy physical scenario
