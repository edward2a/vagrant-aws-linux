#!/bin/bash


### Sanity checks ###
# jq? curl?
[ $(which jq 2>/dev/null) ] || { echo 'ERROR: I cannot read json without jq ;)'; exit 1; }
[ $(which curl 2>/dev/null) ] || { echo 'ERROR: Please give me curl to find who am I in the world.'; exit 1; }

# silly quuestion but, is vagrant installed?
[ $(which vagrant 2>/dev/null) ] || { echo 'ERROR: I cannot find vagrant... am I going nuts?'; exit 1; }

# check for aws plugin and install it if not there
vagrant_aws_installed=$(vagrant plugin list | grep -c 'vagrant-aws')
if [ ${vagrant_aws_installed} == 0 ]; then
    vagrant plugin install vagrant-aws
fi

# check if dummy box in place else add it
vagrant_aws_dummy_installed=$(vagrant box list | grep -c 'aws/dummy')
if [ ${vagrant_aws_dummy_installed} == 0 ]; then
    vagrant box add --name 'aws/dummy' ./dummy.box
fi
###

### pre reqs for aws
[ -d temp ] && rm -rf ./temp
mkdir temp

key_name="temp-key-$((RANDOM))$((RANDOM))"
sg_name="temp-sg-$((RANDOM))"
my_ip=$(curl -s 'http://api.ipify.org')
export key_name sg_name my_ip

echo 'INFO: Creating AWS key pair'
aws ec2 create-key-pair --key-name ${key_name} | jq -r .KeyMaterial > temp/ssh_key.priv && \
 echo ${key_name} | tee temp/ssh_key.id

echo 'INFO: Creating AWS security group'
aws ec2 create-security-group --group-name ${sg_name} --description ${sg_name} | jq -r .GroupId | tee temp/group.id

echo 'INFO: Authorizing AWS security group ingress'
aws ec2 authorize-security-group-ingress --group-name ${sg_name} --cidr ${my_ip}/32 --protocol tcp --port 22 && echo 'INFO: OK'


### Launch vagrant build
vagrant up
