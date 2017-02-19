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
aws ec2 create-security-group --group-name ${sg_name} --description ${sg_name} | jq -r .GroupId | tee temp/group.id && \
 echo ${sg_name} | tee temp/group.name

echo 'INFO: Authorizing AWS security group ingress'
aws ec2 authorize-security-group-ingress --group-name ${sg_name} --cidr ${my_ip}/32 --protocol tcp --port 22 && echo 'INFO: OK'


### Launch vagrant build for i_setup
echo "INFO: Launching AWS box and provisioining system updates"
vagrant up --provision-with system-upgrade i_setup

echo "INFO: Waiting 5 min for system to reboot"
sleep 300s

echo "INFO: Provisioning AWS box with vbox setup"
vagrant provision --provision-with vbox-setup i_setup

echo "INFO: Shutting down AWS setup box"
vagrant halt i_setup
### Vagrant build end for i_setup


### Some glue for i_setup
i_setup_id=$(cat .vagrant/machines/i_setup/aws/id)
echo "INFO: i_setup box is ${i_setup_id}"

i_setup_vol=$(aws ec2 describe-instances --instance-ids ${i_setup_id} | jq -r .Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId)
echo "INFO: i_setup volume to export is ${i_setup_vol}"
echo ${i_setup_vol} > temp/export_vol.id

echo "INFO: Detaching volume from i_setup box"
aws ec2 detach-volume --volume-id ${i_setup_vol}
sleep 10s
### Glue end for i_setup


### Launch build for i_export
ehco "INFO: Launching AWS box for image export"
vagrant up --no-provision

i_export_id=$(cat .vagrant/machines/i_export/aws/id)
i_export_ip=$(aws ec2 describe-instances --instance-ids ${i_export_id} | jq -r .Reservations[0].Instances[0].PublicIpAddress)
echo "INFO: i_export box is ${i_export_id}"

echo "INFO: Attaching i_setup volume to i_export as /dev/xvdz"
aws ec2 attach-volume --volume-id ${i_setup_vol} --instance-id ${i_export_id} --device '/dev/xvdz'
sleep 10s

echo "INFO: Starting image export process"
vagrant provision i_export

echo "INFO: Retrieving image from i_export box"
scp -o StrictHostKeyChecking=no -i temp/ssh_key.priv ec2-user@${i_export_ip}:/tmp/box.img.gz ./temp/

vagrant halt i_export
### Vagrant build for i_export end


### Some glue for building the vagrant box
################ NOTE/WARNING #################
# THE DYNAMIC IMAGE SIZE IS HARDCODED TO 8GiB #
###############################################
echo "INFO: Decompressing image and converting to VirtualBox format"
gunzip --keep -c temp/box.img.gz | VBoxManage convertfromraw stdin temp/box-disk1.vmdk 8589934592 --format VMDK

echo "INFO: Preparing import files..."
mkdir realreadme
tar -czf realreadme/amazon-2016-09.pkg -C box $(ls box)
sha1_sum=$(sha1sum amazon-2016-09.box | awk '{ print $1 }')
sed -e "s/@@@CHECKSUM@@@/${sha1_sum}/" -e "s/@@@IMPORT_PATH@@@/$PWD/" import_metadata.json > import.json

echo "INFO: Box export process finished"
echo "INFO: To start using the box, please import it into vagrant with the following command:"
echo "INFO: vagrant box add file://./import.json"
echo "INFO: time for an ice cream now!"

### Glue end for vagrant box
