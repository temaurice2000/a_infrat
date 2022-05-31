#!/bin/bash
sudo su
cat /etc/ansible/hosts
echo "[webserver]" >> /etc/ansible/hosts
cat /etc/ansible/hosts
# aws ec2 describe-instances --query "Reservations[*].Instances[*].[PrivateIpAddress, Tags[?Key=='Name'].Value|[0]]" --output text | grep web_server | awk '{print $1}' >> /etc/ansible/hosts
# ip_address="$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[PrivateIpAddress, Tags[?Key=='Name'].Value|[0]]" --output text | grep web_server | awk '{print $1}')"
# ssh-copy-id $ip_address
# ansible ping -m webserver -u ubuntu