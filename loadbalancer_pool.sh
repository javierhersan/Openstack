#!/bin/sh

#----------------------------------------------------------------------------------------
# Credenciales admin TNT00 Project

# source /root/bin/admin-openrc.sh # Admin credentials
export OS_USERNAME=tnt00user
export OS_PASSWORD=password
export OS_PROJECT_NAME=TNT00
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_AUTH_TYPE=password

TNT00_project_id=$(openstack project show TNT00 -c id -f value)
default_secgroup_id=$(openstack security group list -f value | grep default | grep $TNT00_project_id | cut -d " " -f1)

#----------------------------------------------------------------------------------------
# Crear la pool de servidores
neutron lbaas-pool-create \
  --name lb-pool-http \
  --lb-algorithm ROUND_ROBIN \
  --listener lb-http \
  --protocol HTTP
 
# Añadir servidores al pool
# https://docs.openstack.org/python-openstackclient/pike/cli/command-list.html
# openstack server list
string=$(openstack server show Server1 -c addresses -f value)
string=$(echo "${string%%;*}")
private_ip_vm1=$(echo "${string#Net1=}")

string=$(openstack server show Server2 -c addresses -f value)
string=$(echo "${string%%;*}")
private_ip_vm2=$(echo "${string#Net1=}")

string=$(openstack server show Server3 -c addresses -f value)
string=$(echo "${string%%;*}")
private_ip_vm3=$(echo "${string#Net1=}")

neutron lbaas-member-create \
  --name lb-http-member-1 \
  --subnet Subnet1 \
  --address $private_ip_vm1 \
  --protocol-port 80 \
  lb-pool-http
neutron lbaas-member-create \
  --name lb-http-member-2 \
  --subnet Subnet1 \
  --address $private_ip_vm2 \
  --protocol-port 80 \
  lb-pool-http
neutron lbaas-member-create \
  --name lb-http-member-3 \
  --subnet Subnet1 \
  --address $private_ip_vm3 \
  --protocol-port 80 \
  lb-pool-http

# Monitoriza si algún servidor se ha caído para retirarlo del pool
#neutron lbaas-healthmonitor-create \
#  --delay 5 \
#  --max-retries 2 \
#  --timeout 10 \
#  --type HTTP \
#  --pool lb-pool-http

#floating_ip=$(openstack floating ip create ExtNet -c floating_ip_address -f value)
vip_port_id=$(neutron lbaas-loadbalancer-show lb -c vip_port_id -f value)
floating_ip_id=$(openstack floating ip create --project TNT00 --subnet ExtSubNet ExtNet -c id -f value)
neutron floatingip-associate $floating_ip_id $vip_port_id

# neutron lbaas-loadbalancer-stats lb

