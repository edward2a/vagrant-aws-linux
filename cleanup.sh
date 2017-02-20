#!/bin/bash

echo "INFO: Removing instances"
vagrant destroy -f

# wait for instances to be terminated
echo "INFO: Waiting 30s for instances to be terminated"
sleep 30s

echo "INFO: Removing ec2 key pair"
[ -f "temp/ssh_key.id" ] && aws ec2 delete-key-pair --key-name $(cat temp/ssh_key.id)

echo "INFO: Removing ec2 security group"
[ -f "temp/group.name" ] && aws ec2 delete-security-group --group-name $(cat temp/group.name)

rm -rf import.json realreadme/ temp/ box/box-disk1.vmdk 
