#!/bin/sh

#----------------------------------------------------------------------------------------
# Desplegar Openstack y el escenario físico

/lab/cnvr/bin/get-openstack-tutorial.sh
cd /mnt/tmp/openstack_lab-stein_4n_classic_ovs-v06
sudo vnx -f openstack_lab.xml --create 			# Deploy physical scenario
sudo vnx -f openstack_lab.xml -x start-all,load-img 		# Deploys Openstack services, creates external network and loads vm images
sudo vnx_config_nat ExtNet enp2s0 				# Configuring the NAT being the external_interface enp2s0

#----------------------------------------------------------------------------------------
# Credenciales admin Openstack

# source /root/bin/admin-openrc.sh # Admin credentials
export OS_USERNAME=admin
export OS_PASSWORD=xxxx
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_AUTH_TYPE=password

admin_project_id=$(openstack project show admin -c id -f value)
default_secgroup_id=$(openstack security group list -f value | grep default | grep $admin_project_id | cut -d " " -f1)

#----------------------------------------------------------------------------------------
# Create external network 
# * The external network is already created with the start-all vnx command

# openstack network create --share --external --provider-physical-network provider --provider-network-type flat ExtNet
# openstack subnet create --network ExtNet --gateway 10.0.10.1 --dns-nameserver 10.0.10.1 --subnet-range 10.0.10.0/24 --allocation-pool start=10.0.10.100,end=10.0.10.200 ExtSubNet

#----------------------------------------------------------------------------------------
# Load images to Openstack and create their flavours
# * The images are already loaded with the load-img vnx command
# * Its flavours are already created too with the start-all vnx command

# dhclient eth9 # Just in case the Internet connection is not active (Openstack Glance alternative interface)

# Create flavors if not created
# openstack flavor show m1.nano >/dev/null 2>&amp;1    || openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
# openstack flavor show m1.tiny >/dev/null 2>&amp;1    || openstack flavor create --id 1 --vcpus 1 --ram 512 --disk 1 m1.tiny
# openstack flavor show m1.smaller >/dev/null 2>&amp;1 || openstack flavor create --id 6 --vcpus 1 --ram 512 --disk 3 m1.smaller

# CentOS image
# Cirros image  
# wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
# wget -P /tmp/images http://vnx.dit.upm.es/vnx/filesystems/ostack-images/cirros-0.3.4-x86_64-disk-vnx.qcow2
# glance image-create --name "cirros-0.3.4-x86_64-vnx" --file /tmp/images/cirros-0.3.4-x86_64-disk-vnx.qcow2 --disk-format qcow2 --container-format bare --visibility public --progress
# rm /tmp/images/cirros-0.3.4-x86_64-disk*.qcow2

# Ubuntu image (trusty)
# wget -P /tmp/images http://vnx.dit.upm.es/vnx/filesystems/ostack-images/trusty-server-cloudimg-amd64-disk1-vnx.qcow2
# glance image-create --name "trusty-server-cloudimg-amd64-vnx" --file /tmp/images/trusty-server-cloudimg-amd64-disk1-vnx.qcow2 --disk-format qcow2 --container-format bare --visibility public --progress
# rm /tmp/images/trusty-server-cloudimg-amd64-disk1*.qcow2

# Ubuntu image (xenial)
# wget -P /tmp/images http://vnx.dit.upm.es/vnx/filesystems/ostack-images/xenial-server-cloudimg-amd64-disk1-vnx.qcow2
# glance image-create --name "xenial-server-cloudimg-amd64-vnx" --file /tmp/images/xenial-server-cloudimg-amd64-disk1-vnx.qcow2 --disk-format qcow2 --container-format bare --visibility public --progress
# rm /tmp/images/xenial-server-cloudimg-amd64-disk1*.qcow2

# wget -P /tmp/images http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
# glance image-create --name "CentOS-7-x86_64" --file /tmp/images/CentOS-7-x86_64-GenericCloud.qcow2 --disk-format qcow2 --container-format bare --visibility public --progress
# rm /tmp/images/CentOS-7-x86_64-GenericCloud.qcow2

#----------------------------------------------------------------------------------------
