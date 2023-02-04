export OS_USERNAME=admin
export OS_PASSWORD=xxxx
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_AUTH_TYPE=password

openstack image create --container-format bare --disk-format qcow2 \
  --file serverdb_snapshot.raw ServerDBSnapshot
