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
backend_port=5000