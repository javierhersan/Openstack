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
# Firewall (https://docs.openstack.org/newton/networking-guide/fwaas-v2-scenario.html#configure-firewall-as-a-service-v2)

# openstack server list

# SSH Admin Server traffic rule
string=$(openstack server show ServerAdmin -c addresses -f value)
string=$(echo "${string%%;*}")
string=$(echo "${string#Net1=}")
server_admin_internal_ip=$(echo "${string%%,*}") # The firewall is applied after the NAT so we need the internal IP
openstack firewall group rule create --protocol tcp \
  --destination-ip-address $server_admin_internal_ip \
  --destination-port 22 \
  --action allow --name ssh_ingress

# HTTP Server traffic rule
load_balancer_internal_address=$(neutron lbaas-loadbalancer-show lb -c vip_address -f value) 
openstack firewall group rule create --protocol tcp \
  --destination-ip-address $load_balancer_internal_address \
  --destination-port 80 \
  --action allow --name http_ingress
  
# All internal traffic is allowed to egress
openstack firewall group rule create --protocol any \
  --source-ip-address 10.103.82.0/24 \
  --action allow --name egress

# Firewall policy
openstack firewall group policy create ingressfirewallpolicy
openstack firewall group policy add rule ingressfirewallpolicy ssh_ingress
openstack firewall group policy add rule ingressfirewallpolicy http_ingress
openstack firewall group policy create egressfirewallpolicy
openstack firewall group policy add rule egressfirewallpolicy egress  
# FWaaS always adds a default deny all rule at the lowest precedence of each policy. Consequently, a firewall policy with no rules blocks all traffic by default.

string=$(openstack router show RTR1TNT82CL3 -c interfaces_info -f value)
string=$(echo "${string%%,*}")
string=$(echo "${string#*:}")
string=$(echo "${string#*"'"}")
string=$(echo "${string%"'"*}")
internal_router_port=$(echo "${string%"'"*}")
 
openstack firewall group create --port $internal_router_port --ingress-firewall-policy ingressfirewallpolicy --egress-firewall-policy egressfirewallpolicy --project TNT00 --name firewall

