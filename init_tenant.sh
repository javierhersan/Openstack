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
# Launch HEAT Template for initiate the tenant TNT00

# Login into the controller or login into an external machine with OpenStack installed for remote access

# Ensure we have copied the HOT (Heat Stack) and the environment file into the current directory of the controller or remote machine 
openstack stack create -t init-tenant.yaml -e init-tenant-env.yaml INIT_TNT00

#----------------------------------------------------------------------------------------
