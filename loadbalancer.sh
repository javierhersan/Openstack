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
# Load balancer (https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html)
neutron lbaas-loadbalancer-create --name lb Subnet1

# neutron lbaas-loadbalancer-show lb

neutron security-group-create lbaas
neutron security-group-rule-create \
  --direction ingress \
  --protocol tcp \
  --port-range-min 80 \
  --port-range-max 80 \
  --remote-ip-prefix 0.0.0.0/0 \
  lbaas
neutron security-group-rule-create \
  --direction ingress \
  --protocol tcp \
  --port-range-min 443 \
  --port-range-max 443 \
  --remote-ip-prefix 0.0.0.0/0 \
  lbaas
neutron security-group-rule-create \
  --direction ingress \
  --protocol icmp \
  lbaas

vip_port_id=$(neutron lbaas-loadbalancer-show lb -c vip_port_id -f value)

neutron port-update \
  --security-group lbaas \
  $vip_port_id

# Add HTTP listener
  
neutron lbaas-listener-create \
  --name lb-http \
  --loadbalancer lb \
  --protocol HTTP \
  --protocol-port 80
  
