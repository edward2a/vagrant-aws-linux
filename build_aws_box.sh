#!/bin/bash


### Sanity checks ###
# jq?
[ $(which jq 2>/dev/null) ] || { echo 'ERROR: I cannot read json without jq ;)'; exit 1; }

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
export key_name sg_name

echo 'INFO: Creating AWS key pair'
aws ec2 create-key-pair --key-name ${key_name} | jq -r .KeyMaterial > temp/ssh_key.priv && echo ${key_name}

echo 'INFO: Creating AWS security group'
aws ec2 create-security-group --group-name ${sg_name} --description ${sg_name} | jq -r .GroupId | tee temp/group.id


### Launch vagrant build
#vagrant up # need to put the security-group-name in the yaml or load it somehow
