#!/bin/sh

# Exit on error
set -e

# Run terraform stack
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

# Use this private key for opennebula VMs
PRIVATE_KEY_FILE="~/.ssh/pk_nuada.pem"

# Deploy services via ansible
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key $PRIVATE_KEY_FILE -i ansible/inventory/hosts ansible/site.yml 

