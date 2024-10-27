#!/usr/bin/bash

set -e

# Run as Root
if [[  $EUID -ne 0 ]];then
	echo "Run as root";
	exit 1
fi

pacman -S virt-manager virt-viewer qemu-full dnsmasq spice-vdagent

# libvirtd config
sed -i "/unix_sock_group/s/#//" /etc/libvirt/libvirtd.conf
sed -i "/unix_sock_ro_perms/s/#//" /etc/libvirt/libvirtd.conf

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
systemctl enable --now libvirtd.service
systemctl enable --now spice-vdagentd # for clipboard support
# clipboard: https://unix.stackexchange.com/a/671298

echo "Virt-Manager Insalled Reboot and launch virt-manager --connect qemu:///system"
echo "Run virsh net-start default to startup NAT"
