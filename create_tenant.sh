#!/bin/sh

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
# Launch HEAT Template for creating a project and its associated user

# Login into the controller or login into an external machine with OpenStack installed for remote access

# Source as the admin (already done)
# source ~/keystone_admin 

# Ensure we have copied the HOT (Heat Stack) and the environment file into the current directory of the controller or remote machine 
openstack stack create -t create-tenant.yaml -e create-tenant-env.yaml TNT00
# openstack stack list

#----------------------------------------------------------------------------------------
