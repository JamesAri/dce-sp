#!/bin/sh

# --- Exit on error ---
set -e

# --- Run terraform stack ---
# terraform -chdir=terraform init
# terraform -chdir=terraform apply -auto-approve

# --- Use this private key for opennebula VMs ---
PRIVATE_KEY_FILE="~/.ssh/pk_nuada.pem"

# --- Wait for the VMs to be ready ---
MAX_RETRIES=15
echo "Waiting for VMs to be ready..."

# Extract the list of hosts (IP addresses only) from the groups [backends] and [loadbalancers] in the inventory file
HOSTS=$(awk '/^\[/{group=$0} /^[0-9]/ && (group == "[backends]" || group == "[loadbalancers]") {print $1}' ansible/inventory/hosts)

for host in $HOSTS; do
  echo "Checking $host"
  retries=0
  while true; do
    if ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 -i $PRIVATE_KEY_FILE nodeadm@$host 'echo VM is ready' 2>/dev/null; then
      echo "$host is ready!"
      break
    fi
    
    retries=$((retries + 1))
    if [ $retries -ge $MAX_RETRIES ]; then
      echo "Failed to connect to $host after $MAX_RETRIES attempts. Exiting."
      exit 1
    fi
    
    echo "Waiting for $host to be ready (attempt $retries/$MAX_RETRIES)..."
    sleep 10
  done
done

# --- Deploy services via ansible ---
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key $PRIVATE_KEY_FILE -i ansible/inventory/hosts ansible/site.yml 

