#!/usr/bin/sudo bash


### BEGIN VARS ###

vbox_add_filename='vbox-additions.iso'
required_packages='gcc kernel-devel kernel-headers dkms make bzip2 perl'
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
    echo "INFO: Downloading latest VBox Additions image (${vbox_latest})"
    curl -s -o ${vbox_add_filename} "http://download.virtualbox.org/virtualbox/${vbox_latest}/VBoxGuestAdditions_${vbox_latest}.iso"

}

install_vbox_additions() {
    local failed=0
    local kern_ver=$(uname -r)

    echo "INFO: Installing VBox Additions"
    export KERN_DIR=/usr/src/kernels/${kern_ver}
    ln -s $KERN_DIR /usr/src/linux

    mount -o loop,ro $vbox_add_filename /mnt
    /mnt/VBoxLinuxAdditions.run || failed=$?
    sleep 10s
    umount /mnt
    rm -f $vbox_add_filename

    # module install will fail to load vboxguest.ko (missing device) so will test for installation instead
    [ $(ls /lib/modules/${kern_ver}/misc/ | grep -c vbox) -gt 2 ] && failed=0

    return ${failed}
}

update_ssh_config() {
    echo "INFO: Updating SSH config"
    sed -i \
        -e 's/^PermitRootLogin.*$/PermitRootLogin without-password/g' \
        -e 's/^PasswordAuthentication.*$/PasswordAuthentication yes/g' \
        -e 's/^UseDNS.*/UseDNS no/g' \
        $ssh_config_file
}

cleanup_system() {
    echo "INFO: Cleaning up system"
    rm -rf /var/log/* /home/ec2-user/.ssh /root/.ssh
    history -c
}

### END FUNCTIONS ###


### BEGIN EXEC ###

yum -y install $required_packages
add_vagrant_user || die 'vagrant user'
disable_services || die 'disable services'
get_vbox_additions || die 'failed to download vbox additions'
install_vbox_additions || die 'install vbox additions'
update_ssh_config || die 'update ssh config'
cleanup_system || die 'cleanup system'

### END EXEC ###
