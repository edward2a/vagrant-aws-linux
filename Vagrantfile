# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

meta = YAML.load(open('metadata.yaml'))
puts meta

Vagrant.configure("2") do |config|

  config.vm.box = 'aws/dummy'
  config.ssh.username = 'ec2-user'
  config.ssh.private_key_path = 'temp/ssh_key.priv'

  config.vm.provider :aws do |aws|
    aws.aws_profile = meta['aws_profile']
    aws.region = meta['region']
    aws.ami = meta['image_id']
    aws.instance_type = meta['instance_type']
    aws.security_groups = meta['security_groups'] || ENV['sg_name']
    aws.keypair_name = meta['keypair_name'] || ENV['key_name']
    aws.associate_public_ip = meta['public_ip']
    aws.subnet_id = meta['subnet_id']
  end

#  config.vm.provision "shell", inline: <<-SHELL
#    ls -l /etc
#  SHELL

  config.vm.provision "shell",
    path: 'scripts/amzn_linux_vbox_setup.sh'

end
