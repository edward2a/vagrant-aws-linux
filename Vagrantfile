# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

meta = YAML.load(open('metadata.yaml'))

# check required info
if ENV['sg_name'] == nil and meta['security_groups'] == nil
  begin
    meta['security_groups'] = open('temp/group.id').read().strip()
  rescue
    abort('Missing security group information.')
  end
end

if ENV['key_name'] == nil and meta['keypair_name'] == nil
  begin
    meta['keypair_name'] = open('temp/ssh_key.id').read().strip()
  rescue
    abort('Missing ssh key information.')
  end
end

# print config
puts 'Using the following configuration:', meta

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
