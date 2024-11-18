[backends]
%{ for ip in backends ~}
${ip}
%{ endfor ~}

[loadbalancers]
%{ for ip in loadbalancers ~}
${ip}
%{ endfor ~}

[all:vars]
ansible_user=nodeadm
ansible_ssh_private_key_file=~/.ssh/pk_nuada.pem