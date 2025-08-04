#!/usr/bin/bash

set -e

# Run as Root
if [[  $EUID -ne 0 ]];then
    echo "Run as root";
    exit 1
fi

pacman -S virt-manager dnsmasq qemu-base qemu-desktop

# libvirtd config
sed -i "/unix_sock_group/s/#//" /etc/libvirt/libvirtd.conf
sed -i "/unix_sock_ro_perms/s/#//" /etc/libvirt/libvirtd.conf

# virtstoraged
sed -i "/unix_sock_group/s/#//" /etc/libvirt/virtstoraged.conf
sed -i "/unix_sock_ro_perms/s/#//" /etc/libvirt/virtstoraged.conf

# virtnetwork
echo -e "\nfirewall_backend=iptables" /etc/libvirt/network.conf

# Qemu user
echo "###################################################################
# Qemu user
user = \"$(whoami)\"
group = \"libvirt\"" >> /etc/libvirt/qemu.conf

# enable ip forwarding for ufw firewall
sed -i "/net\/ipv4\/ip_forward=1/s/#//" /etc/ufw/sysctl.conf
sysctl -p /etc/ufw/sysctl.conf
ufw reload

# add user to groups
usermod -aG qemu,libvirt-qemu,libvirt,kvm "$(whoami)"

# Enable systemd services
# qemu interface network nodedev storage
systemctl enable --now virtqemud.service virtlxcd.service \
  virtinterfaced.service virtnetworkd.service virtstoraged.service \
  virtnodedevd.service

echo "Virt-Manager Insalled Reboot and launch virt-manager --connect qemu:///system"
echo "Run virsh net-start default to startup NAT"
