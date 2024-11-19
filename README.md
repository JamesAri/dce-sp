## About

Simple IAC demo for deploying loadbalancer(s) and backend(s) from https://github.com/maxotta/kiv-ds-vagrant/tree/master/demo-3.

*Used stack: Ansible, Terraform, Docker, Nginx, Python, Github Actions*

## Prerequisites (tested on):
	ansible [core 2.17.5]
	terraform v1.9.8

## Configuration

### Setting the SSH key for connecting to opennebula VMs (Ansible)

To override the default ssh private key file used for connecting to nuada VMs:

```sh title="deploy-iac.sh"
PRIVATE_KEY_FILE="~/.ssh/pk_nuada.pem"
```

go to `deploy-iac.sh` in the root of the project and replace the `"~/.ssh/pk_nuada.pem"` with your specific path to the ssh key. It is then used by ansible to connect to the remote VMs.

### Setting the provisioning part (Terraform)

First, go to the `terraform.tfvars.template` and rename it to `terraform.tfvars`, it will be used for setting the provisioning variables in terraform.
Next, lets look how we can configure the deployment:
```
one_username           = "username"
one_password           = "token"
one_endpoint           = "https://nuada.zcu.cz/RPC2"
vm_ssh_pubkey          = "ssh-rsa public key"
vm_ssh_privatekey_file = "ssh-rsa private key file"

vm_image_name     = "Ubuntu 22.04"
vm_image_url      = "https://marketplace.opennebula.io//appliance/4562be1a-4c11-4e9e-b60a-85a045f1de05/download/0"

vm_be_instance_count = 2
vm_lb_instance_count = 1
```

- provide `one_username` with your nuada **username**
- provide `one_password` with your nuada **token**
- you may specify the `one_endpoint` **EP** (this one is set for ZCU servers)
- provide `vm_ssh_pubkey` with **public key** (content, not file) which you setup for your nuada account
- provide `vm_ssh_privatekey_file` with **private key file** (file) corresponding to the above public key
- set the number of loadbalancing VMs via `vm_lb_instance_count` variable
- set the number of backend VMs via `vm_be_instance_count` variable
- I suggest you leave the `vm_image_name` and `vm_image_url` untouched, but feel free to experiment

## How to run

After you finish with the configuration, you may execute the `deploy-iac.sh` script, it will just run terraform and ansible for you.

## Github actions

Project also includes manually triggerable github action `docker-publish.yml` for building and publishing multi-platform (`linux/amd64,linux/arm64`) `backend` and `loadbalancer` applications to Docker Hub.

- [Loadbalancer](https://hub.docker.com/repository/docker/jamesari/loadbalancer)
- [Backend](https://hub.docker.com/repository/docker/jamesari/backend)

