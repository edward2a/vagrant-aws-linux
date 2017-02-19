#!/usr/bin/sudo bash


### BEGIN VARS ###

vbox_add_filename='vbox-additions.iso'
required_packages='gcc kernel-devel'
svc_off='cloud-config cloud-final cloud-init cloud-init-local'
ssh_config_file='/etc/ssh/sshd_config'

### END VARS ###


### BEGIN FUNCTIONS ###

die() {
    echo "ERROR: Failed doing $1"
    exit 1
}

add_vagrant_user() {
    useradd -m vagrant
    echo -e "vagrant\nvagrant\n" | passwd vagrant
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/vagrant\n
}

disable_services() {
    for svc in ${svc_off}; do
        chkconfig ${svc} off
    done
}

get_vbox_additions() {
    vbox_latest=$(curl -s 'http://download.virtualbox.org/virtualbox/LATEST.TXT')

    curl -so ${vbox_add_filename} "http://download.virtualbox.org/virtualbox/${vbox_latest}/VBoxGuestAdditions_${vbox_latest}.iso"

}

install_vbox_additions() {
    mount -o loop,ro $vbox_add_filename /mnt
    /mnt/VBoxLinuxAdditions.run
    sleep 10s
    umount /mnt
    rm -f $vbox_add_filename
}

update_ssh_config() {
    sed -i \
        -e 's/^PermitRootLogin.*$/PermitRootLogin without-password/g' \
        -e 's/^PasswordAuthentication.*$/PasswordAuthentication yes/g' \
        -e 's/^UseDNS.*/UseDNS no/g' \
        $ssh_config_file
}

cleanup_system() {
    rm -rf /var/log/* /home/ec2-user/.ssh /root/.ssh
}

### END FUNCTIONS ###


### BEGIN EXEC ###

yum -y install $required_packages
add_vagrant_user || die 'vagrant user'
disable_services || die 'disable services'
install_vbox_additions || die 'install vbox additions'
update_ssh_config || die 'update ssh config'
cleanup_system || die 'cleanup system'

### END EXEC ###
