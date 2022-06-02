#!/bin/bash
cd /home/ec2-user/workspace/clone_infra_OnSlave
echo "[webserver]" > /etc/ansible/hosts
aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress, Tags[?Key=='Name'].Value|[0]]" --output text | grep web_server2 | awk '{print $1}' >> /etc/ansible/hosts
#ip_address="$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress, Tags[?Key=='Name'].Value|[0]]" --output text | grep web_server2 | awk '{print $1}')"
#ssh-copy-id $ip_address
ansible webserver -m ping -u ubuntu
ansible-playbook playbook.yaml -u ubuntu